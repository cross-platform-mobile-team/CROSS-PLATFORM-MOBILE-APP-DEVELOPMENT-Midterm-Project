import { createServer } from 'node:http';
import { randomUUID } from 'node:crypto';
import { ApiError, fail, fields, email, password, text, task, revision } from './validation.js';
import { digest, token, hashPassword, verifyPassword, RateLimiter } from './security.js';
import { openStore, transaction, snapshot, replaceTasks } from './store.js';
import { openapi } from './openapi.js';

const publicUser = (row) => ({ id: row.id, email: row.email, name: row.name, createdAt: row.created_at });
const accessMs = 15 * 60 * 1000;
const sessionMs = 7 * 24 * 60 * 60 * 1000;

async function readBody(req) {
  if (Number(req.headers['content-length']) > 1024 * 1024) fail(413, 'too_large', 'Request body exceeds 1 MiB.');
  const chunks = [];
  let bytes = 0;
  for await (const chunk of req) {
    bytes += chunk.length;
    if (bytes > 1024 * 1024) fail(413, 'too_large', 'Request body exceeds 1 MiB.');
    chunks.push(chunk);
  }
  if (bytes === 0) return {};
  if (!/^application\/json(?:\s*;|$)/i.test(req.headers['content-type'] ?? '')) fail(415, 'content_type', 'Use application/json.');
  try { return JSON.parse(Buffer.concat(chunks).toString('utf8')); }
  catch { fail(400, 'invalid_json', 'Malformed JSON.'); }
}

function discover(tasks, query, now) {
  const allowed = ['q', 'status', 'priority', 'due', 'tag', 'sort', 'limit', 'offset', 'today'];
  for (const key of query.keys()) if (!allowed.includes(key)) fail(422, 'validation', 'Unknown query parameter.');
  const choice = (name, values, fallback) => {
    const value = query.get(name) ?? fallback;
    if (!values.includes(value)) fail(422, 'validation', `Invalid ${name}.`);
    return value;
  };
  const status = choice('status', ['all', 'pending', 'completed'], 'all');
  const priority = choice('priority', ['all', 'low', 'medium', 'high'], 'all');
  const due = choice('due', ['all', 'overdue', 'today', 'upcoming', 'noDate'], 'all');
  const sort = choice('sort', ['newest', 'priority', 'dueDate', 'title'], 'newest');
  const limit = Number(query.get('limit') ?? 20);
  const offset = Number(query.get('offset') ?? 0);
  if (!Number.isInteger(limit) || limit < 1 || limit > 100 || !Number.isInteger(offset) || offset < 0 || offset > 500) {
    fail(422, 'validation', 'limit must be 1-100; offset must be 0-500.');
  }
  const today = query.get('today') ?? now.slice(0, 10);
  task({ id: 'date-check', title: 'Date check', dueDate: today }, now);
  const q = text(query.get('q') ?? '', 'Query', 200).toLowerCase();
  const tag = text(query.get('tag') ?? '', 'Tag', 24).toLowerCase();
  const result = tasks.filter((t) => {
    if (!`${t.title} ${t.notes} ${t.tags.join(' ')}`.toLowerCase().includes(q)) return false;
    if (status !== 'all' && t.completed !== (status === 'completed')) return false;
    if (priority !== 'all' && t.priority !== priority) return false;
    if (tag && !t.tags.includes(tag)) return false;
    return due === 'all' || (due === 'noDate' && t.dueDate === null) ||
      (due === 'overdue' && t.dueDate !== null && t.dueDate < today && !t.completed) ||
      (due === 'today' && t.dueDate === today) || (due === 'upcoming' && t.dueDate !== null && t.dueDate > today);
  });
  const cmp = (a, b) => a < b ? -1 : a > b ? 1 : 0;
  result.sort((a, b) => {
    let order;
    if (sort === 'newest') order = cmp(b.createdAt, a.createdAt);
    if (sort === 'title') order = cmp(a.title.toLowerCase(), b.title.toLowerCase());
    if (sort === 'priority') order = ['low', 'medium', 'high'].indexOf(b.priority) - ['low', 'medium', 'high'].indexOf(a.priority);
    if (sort === 'dueDate') order = a.dueDate === null ? (b.dueDate === null ? 0 : 1) : b.dueDate === null ? -1 : cmp(a.dueDate, b.dueDate);
    return order || cmp(a.id, b.id);
  });
  return { tasks: result.slice(offset, offset + limit), total: result.length, limit, offset };
}

export async function createApi({ filename = ':memory:', origins = ['http://localhost:7357', 'http://127.0.0.1:7357'],
  clock = Date.now, authLimit = 20, log = () => {} } = {}) {
  const db = openStore(filename);
  const dummy = await hashPassword(token());
  const authRate = new RateLimiter(authLimit, 15 * 60 * 1000, clock);
  const generalRate = new RateLimiter(300, 60 * 1000, clock);
  const iso = () => new Date(clock()).toISOString();
  const audit = (id, event) => {
    db.prepare('INSERT INTO audit(user_id,event,at) VALUES(?,?,?)').run(id, event, iso());
    db.prepare('DELETE FROM audit WHERE user_id=? AND id NOT IN (SELECT id FROM audit WHERE user_id=? ORDER BY id DESC LIMIT 100)').run(id, id);
  };
  const issueSession = (userId) => {
    db.prepare('DELETE FROM sessions WHERE expires<=?').run(clock());
    const accessToken = token(), refreshToken = token();
    const id = randomUUID();
    db.prepare('INSERT INTO sessions VALUES(?,?,?,?,?,?,?)').run(id, userId, digest(accessToken), digest(refreshToken), clock() + accessMs, clock() + sessionMs, iso());
    db.prepare('DELETE FROM sessions WHERE user_id=? AND id NOT IN (SELECT id FROM sessions WHERE user_id=? ORDER BY created_at DESC, rowid DESC LIMIT 10)').run(userId, userId);
    return { accessToken, refreshToken, expiresIn: accessMs / 1000, sessionId: id };
  };
  const authenticate = (req) => {
    const match = /^Bearer ([A-Za-z0-9_-]{43})$/.exec(req.headers.authorization ?? '');
    const session = match && db.prepare('SELECT * FROM sessions WHERE access_hash=? AND access_expires>? AND expires>?').get(digest(match[1]), clock(), clock());
    if (!session) fail(401, 'unauthorized', 'Your session expired. Sign in again.');
    const user = db.prepare('SELECT * FROM users WHERE id=?').get(session.user_id);
    return { user, session };
  };
  const server = createServer(async (req, res) => {
    const requestId = randomUUID();
    const started = clock();
    let path = '/';
    res.setHeader('X-Request-ID', requestId);
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('Cache-Control', 'no-store');
    const send = (status, value) => {
      res.statusCode = status;
      if (value === undefined) res.end();
      else {
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        if (Number.isInteger(value.revision)) res.setHeader('ETag', `"${value.revision}"`);
        res.end(JSON.stringify(value));
      }
    };
    try {
      const url = new URL(req.url, 'http://localhost');
      path = url.pathname;
      const origin = req.headers.origin;
      if (origin) {
        if (!origins.includes(origin)) fail(403, 'origin', 'This browser origin is not allowed.');
        res.setHeader('Access-Control-Allow-Origin', origin);
        res.setHeader('Vary', 'Origin');
        res.setHeader('Access-Control-Expose-Headers', 'ETag,X-Request-ID');
      }
      if (req.method === 'OPTIONS') {
        res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
        res.setHeader('Access-Control-Allow-Headers', 'Authorization,Content-Type,If-Match');
        send(204); return;
      }
      const ip = req.socket.remoteAddress ?? 'unknown';
      if (!generalRate.allow(ip)) fail(429, 'rate_limited', 'Too many requests. Try again later.');
      if (path === '/health' && req.method === 'GET') {
        db.prepare('SELECT 1').get(); send(200, { status: 'ok', service: 'taskflow-api', schemaVersion: 1 }); return;
      }
      if (path === '/openapi.json' && req.method === 'GET') { send(200, openapi); return; }
      if (path.startsWith('/v1/auth/') && req.method !== 'GET' && !authRate.allow(ip)) {
        fail(429, 'rate_limited', 'Too many account requests. Try again later.');
      }
      const body = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method) ? await readBody(req) : {};
      if (path === '/v1/auth/register' && req.method === 'POST') {
        fields(body, ['email', 'password', 'name']);
        const address = email(body.email), name = text(body.name, 'Name', 80, 1);
        const hash = await hashPassword(password(body.password));
        const result = transaction(db, () => {
          if (db.prepare('SELECT id FROM users WHERE email=?').get(address)) fail(409, 'account_exists', 'Unable to register this email. Try signing in.');
          const id = randomUUID(), recoveryCode = token();
          db.prepare('INSERT INTO users(id,email,name,password_hash,recovery_hash,created_at) VALUES(?,?,?,?,?,?)').run(id, address, name, hash, digest(recoveryCode), iso());
          audit(id, 'registered');
          return { user: publicUser(db.prepare('SELECT * FROM users WHERE id=?').get(id)), ...issueSession(id), recoveryCode };
        });
        send(201, result); return;
      }
      if (path === '/v1/auth/login' && req.method === 'POST') {
        fields(body, ['email', 'password']);
        const address = email(body.email);
        const row = db.prepare('SELECT * FROM users WHERE email=?').get(address);
        const correct = await verifyPassword(body.password, row?.password_hash ?? dummy);
        const latest = row && db.prepare('SELECT * FROM users WHERE id=?').get(row.id);
        if (!correct || !latest || latest.password_hash !== row.password_hash) fail(401, 'invalid_credentials', 'Email or password is incorrect.');
        send(200, transaction(db, () => { audit(row.id, 'login'); return { user: publicUser(latest), ...issueSession(row.id) }; })); return;
      }
      if (path === '/v1/auth/refresh' && req.method === 'POST') {
        fields(body, ['refreshToken']);
        const raw = text(body.refreshToken, 'Refresh token', 100, 1);
        const hash = digest(raw);
        const reused = db.prepare('SELECT session_id FROM used_refresh WHERE hash=?').get(hash);
        if (reused) {
          db.prepare('DELETE FROM sessions WHERE id=?').run(reused.session_id);
          fail(401, 'refresh_reused', 'Session revoked after refresh-token reuse. Sign in again.');
        }
        const session = db.prepare('SELECT * FROM sessions WHERE refresh_hash=? AND expires>?').get(hash, clock());
        if (!session) fail(401, 'unauthorized', 'Sign in again.');
        const accessToken = token(), refreshToken = token();
        transaction(db, () => {
          db.prepare('INSERT INTO used_refresh VALUES(?,?)').run(hash, session.id);
          db.prepare('UPDATE sessions SET access_hash=?,refresh_hash=?,access_expires=? WHERE id=?').run(digest(accessToken), digest(refreshToken), clock() + accessMs, session.id);
        });
        send(200, { accessToken, refreshToken, expiresIn: accessMs / 1000, sessionId: session.id }); return;
      }
      if (path === '/v1/auth/reset-password' && req.method === 'POST') {
        fields(body, ['email', 'recoveryCode', 'newPassword']);
        const address = email(body.email), recovery = text(body.recoveryCode, 'Recovery code', 100, 1);
        const row = db.prepare('SELECT * FROM users WHERE email=?').get(address);
        if (!row || digest(recovery) !== row.recovery_hash) fail(401, 'invalid_recovery', 'Email or recovery code is incorrect.');
        const hash = await hashPassword(password(body.newPassword));
        const recoveryCode = token();
        transaction(db, () => {
          const result = db.prepare('UPDATE users SET password_hash=?, recovery_hash=? WHERE id=? AND recovery_hash=?').run(hash, digest(recoveryCode), row.id, row.recovery_hash);
          if (result.changes !== 1) fail(401, 'invalid_recovery', 'Recovery code already used.');
          db.prepare('DELETE FROM sessions WHERE user_id=?').run(row.id);
          audit(row.id, 'password_reset');
        });
        send(200, { recoveryCode }); return;
      }
      if (!path.startsWith('/v1/')) fail(404, 'not_found', 'Route not found.');
      const { user, session } = authenticate(req);
      if (path === '/v1/auth/me' && req.method === 'GET') { send(200, { user: publicUser(user) }); return; }
      if (path === '/v1/auth/me' && req.method === 'PATCH') {
        fields(body, ['name']);
        db.prepare('UPDATE users SET name=? WHERE id=?').run(text(body.name, 'Name', 80, 1), user.id);
        send(200, { user: publicUser(db.prepare('SELECT * FROM users WHERE id=?').get(user.id)) }); return;
      }
      if (path === '/v1/auth/sessions' && req.method === 'GET') {
        const sessions = db.prepare('SELECT id,created_at,expires FROM sessions WHERE user_id=? AND expires>? ORDER BY created_at DESC').all(user.id, clock());
        send(200, { sessions: sessions.map((s) => ({ id: s.id, createdAt: s.created_at, expiresAt: new Date(s.expires).toISOString(), current: s.id === session.id })) }); return;
      }
      if (path === '/v1/auth/activity' && req.method === 'GET') {
        send(200, { events: db.prepare('SELECT event,at FROM audit WHERE user_id=? ORDER BY id DESC LIMIT 50').all(user.id) }); return;
      }
      if (path.startsWith('/v1/auth/sessions/') && req.method === 'DELETE') {
        const result = db.prepare('DELETE FROM sessions WHERE id=? AND user_id=?').run(path.slice('/v1/auth/sessions/'.length), user.id);
        if (!result.changes) fail(404, 'not_found', 'Session not found.');
        send(204); return;
      }
      if (path === '/v1/auth/logout' && req.method === 'POST') {
        db.prepare('DELETE FROM sessions WHERE id=?').run(session.id); send(204); return;
      }
      if (path === '/v1/auth/logout-all' && req.method === 'POST') {
        db.prepare('DELETE FROM sessions WHERE user_id=?').run(user.id); send(204); return;
      }
      if ((path === '/v1/auth/password' && req.method === 'POST') || (path === '/v1/auth/me' && req.method === 'DELETE')) {
        fields(body, path.endsWith('/password') ? ['currentPassword', 'newPassword'] : ['currentPassword']);
        if (!await verifyPassword(body.currentPassword, user.password_hash)) fail(401, 'invalid_password', 'Current password is incorrect.');
        const hash = path.endsWith('/password') ? await hashPassword(password(body.newPassword)) : null;
        const fresh = authenticate(req).user;
        if (fresh.password_hash !== user.password_hash) fail(409, 'conflict', 'Account changed. Try again.');
        transaction(db, () => {
          if (hash) {
            db.prepare('UPDATE users SET password_hash=? WHERE id=?').run(hash, user.id);
            db.prepare('DELETE FROM sessions WHERE user_id=?').run(user.id);
            audit(user.id, 'password_changed');
          } else db.prepare('DELETE FROM users WHERE id=?').run(user.id);
        });
        send(204); return;
      }
      if (path.startsWith('/v1/tasks')) {
        const current = snapshot(db, user.id);
        if (path === '/v1/tasks/snapshot' && req.method === 'GET') { send(200, current); return; }
        if (path === '/v1/tasks/snapshot' && req.method === 'PUT') {
          fields(body, ['revision', 'tasks']);
          if (!Array.isArray(body.tasks) || body.tasks.length > 500) fail(422, 'validation', 'At most 500 tasks are allowed.');
          const tasks = body.tasks.map((t) => task(t, iso()));
          if (new Set(tasks.map((t) => t.id)).size !== tasks.length) fail(422, 'validation', 'Duplicate task IDs.');
          send(200, replaceTasks(db, user.id, revision(body.revision), tasks, iso())); return;
        }
        if (path === '/v1/tasks' && req.method === 'GET') { send(200, { ...discover(current.tasks, url.searchParams, iso()), revision: current.revision }); return; }
        if (path === '/v1/tasks/stats' && req.method === 'GET') {
          send(200, { total: current.tasks.length, completed: current.tasks.filter((t) => t.completed).length,
            pending: current.tasks.filter((t) => !t.completed).length, revision: current.revision }); return;
        }
        const etag = () => {
          if (!/^"\d+"$/.test(req.headers['if-match'] ?? '')) fail(428, 'precondition_required', 'Supply the latest quoted revision in If-Match.');
          return revision(Number(req.headers['if-match'].slice(1, -1)));
        };
        if (path === '/v1/tasks' && req.method === 'POST') {
          fields(body, ['id', 'title', 'notes', 'priority', 'dueDate', 'tags', 'createdAt', 'completed']);
          const created = task({ ...body, id: body.id ?? randomUUID() }, iso());
          if (current.tasks.length >= 500) fail(422, 'validation', 'At most 500 tasks are allowed.');
          if (current.tasks.some((t) => t.id === created.id)) fail(409, 'conflict', 'Task ID already exists.');
          const result = replaceTasks(db, user.id, etag(), [...current.tasks.map((t) => task(t, iso())), created], iso());
          send(201, { task: result.tasks.find((t) => t.id === created.id), revision: result.revision }); return;
        }
        const match = /^\/v1\/tasks\/([a-zA-Z0-9_-]{1,80})$/.exec(path);
        if (match) {
          const found = current.tasks.find((t) => t.id === match[1]);
          if (!found) fail(404, 'not_found', 'Task not found.');
          if (req.method === 'GET') { send(200, { task: found, revision: current.revision }); return; }
          if (req.method === 'PATCH' || req.method === 'DELETE') {
            if (req.method === 'PATCH') fields(body, ['title', 'notes', 'priority', 'dueDate', 'tags', 'completed']);
            const next = req.method === 'DELETE' ? current.tasks.filter((t) => t.id !== found.id) : current.tasks.map((t) => t.id === found.id ? { ...t, ...body } : t);
            const result = replaceTasks(db, user.id, etag(), next.map((t) => task(t, iso())), iso());
            send(200, { revision: result.revision, ...(req.method === 'PATCH' ? { task: result.tasks.find((t) => t.id === found.id) } : {}) }); return;
          }
        }
      }
      fail(404, 'not_found', 'Route not found.');
    } catch (error) {
      const known = error instanceof ApiError;
      if (error.status === 429) res.setHeader('Retry-After', '900');
      send(known ? error.status : 500, { error: { code: known ? error.code : 'internal',
        message: known ? error.message : 'The server could not complete the request.', requestId } });
    } finally {
      // Never log URL query strings, user-supplied IDs, bodies, tokens or passwords.
      log({ requestId, method: req.method, status: res.statusCode, durationMs: clock() - started });
    }
  });
  server.requestTimeout = 15000;
  server.headersTimeout = 10000;
  server.keepAliveTimeout = 5000;
  return { server, db, close: async () => {
    if (server.listening) await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
    db.close();
  } };
}
