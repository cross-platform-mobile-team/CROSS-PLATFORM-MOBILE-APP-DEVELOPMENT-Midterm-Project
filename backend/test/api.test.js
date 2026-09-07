import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, basename } from 'node:path';
import { createApi } from '../src/api.js';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { DatabaseSync } from 'node:sqlite';

const secret = 'A-test-only-passphrase!';
async function fixture(t, options = {}) {
  const app = await createApi(options);
  await new Promise((resolve) => app.server.listen(0, '127.0.0.1', resolve));
  t.after(() => app.close());
  const base = `http://127.0.0.1:${app.server.address().port}`;
  const call = async (path, { method = 'GET', body, access, headers = {} } = {}) => {
    const result = await fetch(`${base}${path}`, { method,
      headers: { ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}), ...(access ? { Authorization: `Bearer ${access}` } : {}), ...headers },
      ...(body !== undefined ? { body: JSON.stringify(body) } : {}) });
    return { status: result.status, headers: result.headers, body: result.status === 204 ? null : await result.json() };
  };
  const register = async (address = 'alice@example.test') => {
    const response = await call('/v1/auth/register', { method: 'POST', body: { email: address, name: 'Alice', password: secret } });
    assert.equal(response.status, 201);
    return response.body;
  };
  return { ...app, call, register, base };
}
const item = (id = 'one', title = 'Review Flutter testing') => ({ id, title, createdAt: '2026-09-06T00:00:00.000Z', completed: false });

test('register, hashed credentials, normalized email, duplicate and login', async (t) => {
  const { call, register, db } = await fixture(t);
  const account = await register(' ALICE@example.test ');
  assert.equal(account.user.email, 'alice@example.test');
  const stored = db.prepare('SELECT * FROM users').get();
  assert.ok(stored.password_hash.startsWith('scrypt$32768$8$3$'));
  assert.ok(!stored.password_hash.includes(secret));
  assert.notEqual(stored.recovery_hash, account.recoveryCode);
  const session = db.prepare('SELECT * FROM sessions').get();
  assert.notEqual(session.access_hash, account.accessToken);
  assert.notEqual(session.refresh_hash, account.refreshToken);
  const login = await call('/v1/auth/login', { method: 'POST', body: { email: 'ALICE@example.test', password: secret } });
  assert.equal(login.status, 200);
  assert.equal((await call('/v1/auth/me', { access: login.body.accessToken })).body.user.id, account.user.id);
  assert.equal((await call('/v1/auth/login', { method: 'POST', body: { email: 'alice@example.test', password: 'wrong' } })).status, 401);
  assert.equal((await call('/v1/auth/register', { method: 'POST', body: { email: 'alice@example.test', name: 'Other', password: secret } })).status, 409);
});

test('validation rejects weak password and mass-assigned account privilege', async (t) => {
  const { call } = await fixture(t);
  for (const body of [{ email: 'bad', name: 'A', password: secret }, { email: 'a@example.test', name: 'A', password: 'short' },
    { email: 'a@example.test', name: 'A', password: secret, role: 'admin' }]) {
    assert.equal((await call('/v1/auth/register', { method: 'POST', body })).status, 422);
  }
  assert.equal((await call('/v1/tasks/snapshot')).status, 401);
});

test('refresh rotates credentials; replay revokes the entire session', async (t) => {
  let now = Date.parse('2026-09-06T00:00:00Z');
  const { call, register } = await fixture(t, { clock: () => now });
  const a = await register();
  now += 16 * 60 * 1000;
  assert.equal((await call('/v1/auth/me', { access: a.accessToken })).status, 401);
  const rotated = await call('/v1/auth/refresh', { method: 'POST', body: { refreshToken: a.refreshToken } });
  assert.equal(rotated.status, 200);
  assert.equal((await call('/v1/auth/me', { access: rotated.body.accessToken })).status, 200);
  assert.equal((await call('/v1/auth/refresh', { method: 'POST', body: { refreshToken: a.refreshToken } })).status, 401);
  assert.equal((await call('/v1/auth/me', { access: rotated.body.accessToken })).status, 401);
});

test('absolute refresh expiration and logout cannot be bypassed', async (t) => {
  let now = Date.now();
  const { call, register } = await fixture(t, { clock: () => now });
  const a = await register();
  now += 8 * 24 * 60 * 60 * 1000;
  assert.equal((await call('/v1/auth/refresh', { method: 'POST', body: { refreshToken: a.refreshToken } })).status, 401);
  const login = await call('/v1/auth/login', { method: 'POST', body: { email: a.user.email, password: secret } });
  assert.equal((await call('/v1/auth/logout', { method: 'POST', access: login.body.accessToken })).status, 204);
  assert.equal((await call('/v1/auth/refresh', { method: 'POST', body: { refreshToken: login.body.refreshToken } })).status, 401);
});

test('per-user CRUD, read isolation, owner injection and no cross-user delete', async (t) => {
  const { call, register } = await fixture(t);
  const a = await register(), b = await register('bob@example.test');
  const created = await call('/v1/tasks', { method: 'POST', access: a.accessToken, headers: { 'If-Match': '"0"' }, body: item() });
  assert.equal(created.status, 201);
  assert.equal((await call('/v1/tasks/one', { access: b.accessToken })).status, 404);
  assert.equal((await call('/v1/tasks/one', { method: 'DELETE', access: b.accessToken, headers: { 'If-Match': '"0"' } })).status, 404);
  assert.deepEqual((await call('/v1/tasks/snapshot', { access: b.accessToken })).body.tasks, []);
  const edited = await call('/v1/tasks/one', { method: 'PATCH', access: a.accessToken, headers: { 'If-Match': '"1"' }, body: { completed: true, notes: 'Ready' } });
  assert.equal(edited.status, 200);
  assert.ok(edited.body.task.completedAt);
  assert.equal(edited.body.task.createdAt, created.body.task.createdAt);
  assert.equal((await call('/v1/tasks/one', { method: 'PATCH', access: a.accessToken, headers: { 'If-Match': '"2"' }, body: { userId: b.user.id } })).status, 422);
  assert.equal((await call('/v1/tasks/one', { method: 'DELETE', access: a.accessToken, headers: { 'If-Match': '"2"' } })).status, 200);
  assert.equal((await call('/v1/tasks/one', { access: a.accessToken })).status, 404);
});

test('snapshot validation and stale writers never partially replace saved data', async (t) => {
  const { call, register } = await fixture(t);
  const { accessToken: access } = await register();
  const put = (body) => call('/v1/tasks/snapshot', { method: 'PUT', access, body });
  assert.equal((await put({ revision: 0, tasks: [item()] })).status, 200);
  assert.equal((await put({ revision: 0, tasks: [] })).status, 409);
  for (const tasks of [[item('same'), item('same')], [item('ok'), { ...item('bad'), dueDate: '2026-02-30' }],
    [{ ...item(), completed: 'true' }], [{ ...item(), title: '' }], [{ ...item(), notes: 'x'.repeat(2001) }],
    [{ ...item(), tags: ['x'.repeat(25)] }], [{ ...item(), priority: 'urgent' }], [{ ...item(), user_id: 'other' }]]) {
    assert.equal((await put({ revision: 1, tasks })).status, 422);
  }
  const saved = await call('/v1/tasks/snapshot', { access });
  assert.equal(saved.body.revision, 1);
  assert.equal(saved.body.tasks[0].id, 'one');
  assert.equal((await call('/v1/tasks/one', { method: 'DELETE', access })).status, 428);
  const simultaneous = await Promise.all([put({ revision: 1, tasks: [item('left')] }), put({ revision: 1, tasks: [item('right')] })]);
  assert.deepEqual(simultaneous.map((r) => r.status).sort(), [200, 409]);
});

test('search, filters, deterministic sort, stats and pagination', async (t) => {
  const { call, register } = await fixture(t);
  const { accessToken: access } = await register();
  const tasks = [{ ...item('b'), priority: 'high', tags: [' Course ', 'course'], dueDate: '2026-09-01' },
    { ...item('a', 'Write notes'), priority: 'high', notes: 'Flutter notes', dueDate: '2026-09-07' },
    { ...item('c', 'Done'), completed: true }];
  await call('/v1/tasks/snapshot', { method: 'PUT', access, body: { revision: 0, tasks } });
  const search = await call('/v1/tasks?q=%20FLUTTER%20&sort=priority&limit=1', { access });
  assert.equal(search.body.total, 2);
  assert.equal(search.body.tasks[0].id, 'a');
  const overdue = await call('/v1/tasks?due=overdue&today=2026-09-06&tag=COURSE&status=pending', { access });
  assert.deepEqual(overdue.body.tasks.map((t) => t.id), ['b']);
  assert.deepEqual(overdue.body.tasks[0].tags, ['course']);
  assert.equal((await call('/v1/tasks?limit=0', { access })).status, 422);
  assert.equal((await call('/v1/tasks?sort=injection', { access })).status, 422);
  assert.equal((await call('/v1/tasks/stats', { access })).body.completed, 1);
});

test('recovery is single-use, rotates the code and revokes all sessions', async (t) => {
  const { call, register } = await fixture(t);
  const a = await register();
  const reset = (code) => call('/v1/auth/reset-password', { method: 'POST', body: { email: a.user.email, recoveryCode: code, newPassword: 'Another-test-passphrase!' } });
  assert.equal((await reset('not-the-code')).status, 401);
  const result = await reset(a.recoveryCode);
  assert.equal(result.status, 200);
  assert.notEqual(result.body.recoveryCode, a.recoveryCode);
  assert.equal((await reset(a.recoveryCode)).status, 401);
  assert.equal((await call('/v1/auth/me', { access: a.accessToken })).status, 401);
  assert.equal((await call('/v1/auth/login', { method: 'POST', body: { email: a.user.email, password: secret } })).status, 401);
  assert.equal((await call('/v1/auth/login', { method: 'POST', body: { email: a.user.email, password: 'Another-test-passphrase!' } })).status, 200);
});

test('profile, session ownership/revocation and password change', async (t) => {
  const { call, register } = await fixture(t);
  const a = await register(), b = await register('bob@example.test');
  assert.equal((await call('/v1/auth/me', { method: 'PATCH', access: a.accessToken, body: { name: 'New name' } })).body.user.name, 'New name');
  assert.equal((await call(`/v1/auth/sessions/${a.sessionId}`, { method: 'DELETE', access: b.accessToken })).status, 404);
  assert.equal((await call('/v1/auth/sessions', { access: a.accessToken })).body.sessions.length, 1);
  assert.equal((await call('/v1/auth/password', { method: 'POST', access: a.accessToken, body: { currentPassword: 'wrong', newPassword: secret } })).status, 401);
  assert.equal((await call('/v1/auth/password', { method: 'POST', access: a.accessToken, body: { currentPassword: secret, newPassword: 'A-new-test-passphrase!' } })).status, 204);
  assert.equal((await call('/v1/auth/me', { access: a.accessToken })).status, 401);
  assert.equal((await call('/v1/auth/me', { access: b.accessToken })).status, 200);
});

test('account deletion requires password and cascades only its own data', async (t) => {
  const { call, register, db } = await fixture(t);
  const a = await register(), b = await register('bob@example.test');
  await call('/v1/tasks/snapshot', { method: 'PUT', access: a.accessToken, body: { revision: 0, tasks: [item()] } });
  assert.equal((await call('/v1/auth/me', { method: 'DELETE', access: a.accessToken, body: { currentPassword: 'wrong' } })).status, 401);
  assert.equal((await call('/v1/auth/me', { method: 'DELETE', access: a.accessToken, body: { currentPassword: secret } })).status, 204);
  for (const table of ['tasks', 'sessions', 'audit']) assert.equal(db.prepare(`SELECT count(*) AS n FROM ${table} WHERE user_id=?`).get(a.user.id).n, 0);
  assert.equal((await call('/v1/auth/me', { access: b.accessToken })).status, 200);
});

test('CORS, malformed bodies, rate limits and safe logs', async (t) => {
  const logs = [];
  const { call, base } = await fixture(t, { authLimit: 2, log: (event) => logs.push(event) });
  assert.equal((await call('/health', { headers: { Origin: 'https://untrusted.example' } })).status, 403);
  const preflight = await call('/v1/tasks', { method: 'OPTIONS', headers: { Origin: 'http://localhost:7357' } });
  assert.equal(preflight.status, 204);
  assert.equal(preflight.headers.get('access-control-allow-origin'), 'http://localhost:7357');
  const malformed = await fetch(`${base}/v1/auth/login`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{' });
  assert.equal(malformed.status, 400);
  await call('/v1/auth/login', { method: 'POST', body: { email: 'a@example.test', password: 'not-secret' } });
  assert.equal((await call('/v1/auth/login', { method: 'POST', body: {} })).status, 429);
  assert.ok(!JSON.stringify(logs).includes('not-secret'));
  assert.ok(logs.every((entry) => Object.keys(entry).sort().join() === 'durationMs,method,requestId,status'));
});

test('SQLite API persistence, sessions, schema and backup survive restart', async () => {
  const folder = mkdtempSync(join(tmpdir(), 'taskflow-api-test-'));
  let api;
  try {
    const filename = join(folder, 'store.sqlite');
    const start = async () => {
      api = await createApi({ filename });
      await new Promise((resolve) => api.server.listen(0, '127.0.0.1', resolve));
      return `http://127.0.0.1:${api.server.address().port}`;
    };
    const base = await start();
    const registered = await fetch(`${base}/v1/auth/register`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: 'persist@example.test', name: 'Persisted', password: secret }) });
    assert.equal(registered.status, 201);
    const account = await registered.json();
    const headers = { 'Content-Type': 'application/json', Authorization: `Bearer ${account.accessToken}` };
    const saved = await fetch(`${base}/v1/tasks/snapshot`, { method: 'PUT', headers, body: JSON.stringify({ revision: 0, tasks: [item()] }) });
    assert.equal(saved.status, 200);
    await api.close();
    api = null;
    const reopened = await start();
    const restored = await fetch(`${reopened}/v1/tasks/snapshot`, { headers });
    assert.equal(restored.status, 200); // The hashed session, not just task rows, persisted.
    const state = await restored.json();
    assert.equal(state.tasks[0].title, item().title);
    assert.equal(state.revision, 1);
    assert.equal(api.db.prepare('PRAGMA user_version').get().user_version, 1);
    const destination = join(folder, 'backup.sqlite');
    const backup = spawnSync(process.execPath, [fileURLToPath(new URL('../scripts/backup.js', import.meta.url)), filename, destination], { encoding: 'utf8' });
    assert.equal(backup.status, 0, backup.stderr);
    const restoredDb = new DatabaseSync(destination, { readOnly: true });
    try {
      const row = restoredDb.prepare('SELECT payload FROM tasks').get();
      assert.equal(JSON.parse(row.payload).title, item().title);
      assert.equal(restoredDb.prepare('PRAGMA integrity_check').get().integrity_check, 'ok');
    } finally { restoredDb.close(); }
  } finally {
    await api?.close();
    // Only the exact directory allocated by this test can be removed.
    assert.equal(dirname(folder), tmpdir());
    assert.ok(basename(folder).startsWith('taskflow-api-test-'));
    rmSync(folder, { recursive: true });
  }
});

test('body limits, content type, null bodies and contract endpoint', async (t) => {
  const { base, call, register } = await fixture(t);
  const a = await register();
  assert.equal((await call('/v1/tasks', { method: 'POST', access: a.accessToken, body: null })).status, 422);
  const oversized = await fetch(`${base}/v1/auth/login`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: 'x'.repeat(1024 * 1024 + 1) });
  assert.equal(oversized.status, 413);
  const wrongType = await fetch(`${base}/v1/auth/login`, { method: 'POST', headers: { 'Content-Type': 'text/plain' }, body: '{}' });
  assert.equal(wrongType.status, 415);
  const spec = await call('/openapi.json');
  assert.equal(spec.status, 200);
  assert.equal(spec.body.openapi, '3.1.0');
  assert.ok(spec.body.paths['/v1/tasks/snapshot'].put);
});

test('logout-all and one-session revocation do not sign out another user', async (t) => {
  const { call, register } = await fixture(t);
  const a = await register(), b = await register('bob@example.test');
  const other = (await call('/v1/auth/login', { method: 'POST', body: { email: a.user.email, password: secret } })).body;
  assert.equal((await call(`/v1/auth/sessions/${other.sessionId}`, { method: 'DELETE', access: a.accessToken })).status, 204);
  assert.equal((await call('/v1/auth/me', { access: other.accessToken })).status, 401);
  assert.equal((await call('/v1/auth/logout-all', { method: 'POST', access: a.accessToken })).status, 204);
  assert.equal((await call('/v1/auth/me', { access: a.accessToken })).status, 401);
  assert.equal((await call('/v1/auth/me', { access: b.accessToken })).status, 200);
});
