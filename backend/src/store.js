import { DatabaseSync } from 'node:sqlite';
import { mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { fail } from './validation.js';

export function openStore(filename) {
  if (filename !== ':memory:') mkdirSync(dirname(filename), { recursive: true });
  const db = new DatabaseSync(filename);
  db.exec('PRAGMA foreign_keys=ON; PRAGMA journal_mode=WAL; PRAGMA busy_timeout=5000;');
  const version = db.prepare('PRAGMA user_version').get().user_version;
  if (version > 1) { db.close(); throw new Error('Database schema is newer than this server.'); }
  if (version === 0) {
    db.exec(`BEGIN IMMEDIATE;
      CREATE TABLE users (
        id TEXT PRIMARY KEY, email TEXT NOT NULL UNIQUE, name TEXT NOT NULL,
        password_hash TEXT NOT NULL, recovery_hash TEXT NOT NULL, created_at TEXT NOT NULL,
        revision INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        access_hash TEXT NOT NULL UNIQUE, refresh_hash TEXT NOT NULL UNIQUE,
        access_expires INTEGER NOT NULL, expires INTEGER NOT NULL, created_at TEXT NOT NULL
      );
      CREATE INDEX sessions_user ON sessions(user_id);
      CREATE TABLE used_refresh (
        hash TEXT PRIMARY KEY, session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE
      );
      CREATE TABLE tasks (
        user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(user_id, id)
      );
      CREATE TABLE audit (
        id INTEGER PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        event TEXT NOT NULL, at TEXT NOT NULL
      );
      PRAGMA user_version=1;
      COMMIT;`);
  }
  return db;
}
export function transaction(db, fn) {
  db.exec('BEGIN IMMEDIATE');
  try {
    const result = fn();
    db.exec('COMMIT');
    return result;
  } catch (error) { db.exec('ROLLBACK'); throw error; }
}
export function snapshot(db, userId) {
  const user = db.prepare('SELECT revision FROM users WHERE id=?').get(userId);
  if (!user) fail(401, 'unauthorized', 'Sign in again.');
  return {
    revision: user.revision,
    tasks: db.prepare('SELECT payload FROM tasks WHERE user_id=? ORDER BY id').all(userId).map((row) => JSON.parse(row.payload)),
  };
}
export function replaceTasks(db, userId, expected, tasks, now) {
  return transaction(db, () => {
    const current = snapshot(db, userId);
    if (expected !== current.revision) fail(409, 'conflict', 'Tasks changed in another session. Reload before saving.');
    const prior = new Map(current.tasks.map((task) => [task.id, task]));
    const next = tasks.map((task) => {
      const old = prior.get(task.id);
      const base = { ...task, createdAt: old?.createdAt ?? task.createdAt };
      const unchanged = old && Object.keys(base).every((key) => JSON.stringify(base[key]) === JSON.stringify(old[key]));
      return { ...base, updatedAt: unchanged ? old.updatedAt : now,
        completedAt: base.completed ? (old?.completedAt ?? now) : null };
    });
    db.prepare('DELETE FROM tasks WHERE user_id=?').run(userId);
    const insert = db.prepare('INSERT INTO tasks(user_id,id,payload) VALUES(?,?,?)');
    for (const task of next) insert.run(userId, task.id, JSON.stringify(task));
    db.prepare('UPDATE users SET revision=revision+1 WHERE id=?').run(userId);
    return { revision: current.revision + 1, tasks: next };
  });
}
