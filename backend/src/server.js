import { resolve } from 'node:path';
import { createApi } from './api.js';

const host = process.env.HOST ?? '127.0.0.1';
const port = Number(process.env.PORT ?? 8080);
if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('Invalid PORT');
const origins = (process.env.CORS_ORIGINS ?? 'http://localhost:7357,http://127.0.0.1:7357').split(',').map((s) => s.trim()).filter(Boolean);
if (origins.includes('*')) throw new Error('CORS_ORIGINS must contain exact trusted origins, not a wildcard.');
const api = await createApi({ filename: resolve(process.env.DATABASE_PATH ?? './data/taskflow.sqlite'), origins,
  log: (event) => console.log(JSON.stringify(event)) });
api.server.listen(port, host, () => console.log(`TaskFlow API listening on http://${host}:${port}`));
let stopping = false;
async function stop() {
  if (stopping) return;
  stopping = true;
  await api.close();
}
process.on('SIGINT', stop);
process.on('SIGTERM', stop);
api.server.on('error', (error) => { console.error(`Server error: ${error.code ?? 'unknown'}`); process.exitCode = 1; stop(); });
