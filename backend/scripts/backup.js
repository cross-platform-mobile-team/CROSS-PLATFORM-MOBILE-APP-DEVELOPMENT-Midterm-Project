import { DatabaseSync } from 'node:sqlite';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

const [sourceArg, destinationArg] = process.argv.slice(2);
if (!sourceArg || !destinationArg) throw new Error('Usage: node scripts/backup.js existing.sqlite new-backup.sqlite');
const source = resolve(sourceArg), destination = resolve(destinationArg);
if (!existsSync(source) || existsSync(destination) || source === destination) {
  throw new Error('Source must exist and backup destination must not already exist.');
}
const db = new DatabaseSync(source);
try {
  db.prepare('VACUUM INTO ?').run(destination);
  const copy = new DatabaseSync(destination, { readOnly: true });
  try {
    if (copy.prepare('PRAGMA integrity_check').get().integrity_check !== 'ok') throw new Error('Backup integrity check failed.');
  } finally { copy.close(); }
  console.log('Consistent SQLite backup created; keep it private.');
} finally { db.close(); }
