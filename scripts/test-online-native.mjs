// CI/Linux counterpart of test-online-windows.ps1. Only synthetic accounts and
// an isolated database are used. No credentials or response bodies are logged.
import { spawn } from 'node:child_process';
import { mkdir, mkdtemp } from 'node:fs/promises';
import { resolve, join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { createApi } from '../backend/src/api.js';

const { values } = parseArgs({ options: {
  device: { type: 'string', default: 'emulator-5554' },
  host: { type: 'string', default: '10.0.2.2' },
} });
if (!['10.0.2.2', '127.0.0.1'].includes(values.host)) throw new Error('Only local test API hosts are allowed.');
if (process.platform === 'win32') throw new Error('On Windows use scripts/test-online-windows.ps1.');
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
await mkdir(join(root, 'build'), { recursive: true });
const folder = await mkdtemp(join(root, 'build', 'online-native-'));
const api = await createApi({ filename: join(folder, 'test.sqlite') });
let child;
const interrupt = () => child?.kill('SIGTERM');
process.once('SIGINT', interrupt);
process.once('SIGTERM', interrupt);
try {
  await new Promise((resolve, reject) => {
    api.server.once('error', reject);
    api.server.listen(0, '127.0.0.1', resolve);
  });
  const port = api.server.address().port;
  child = spawn('flutter', ['test', 'integration_test/online_workflow_test.dart',
    '-d', values.device, `--dart-define=API_BASE_URL=http://${values.host}:${port}`,
    '--reporter', 'expanded'], { cwd: root, stdio: 'inherit' });
  process.exitCode = await new Promise((resolve, reject) => {
    child.once('error', reject);
    child.once('exit', code => resolve(code ?? 1));
  });
} finally {
  process.removeListener('SIGINT', interrupt);
  process.removeListener('SIGTERM', interrupt);
  await api.close();
  console.log(`Isolated native test database: ${folder}`);
}
