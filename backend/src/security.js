import { randomBytes, scrypt, timingSafeEqual, createHash } from 'node:crypto';
import { promisify } from 'node:util';
import { fail } from './validation.js';

const derive = promisify(scrypt);
// OWASP's scrypt N=2^15, r=8, p=3 alternative (32 MiB); no test-only weak hash.
const options = { N: 32768, r: 8, p: 3, maxmem: 64 * 1024 * 1024 };
let active = 0;
async function passwordKey(value, salt) {
  if (active >= 4) fail(503, 'busy', 'Account service is busy. Try again shortly.');
  active++;
  try { return await derive(value, salt, 64, options); }
  finally { active--; }
}
export const token = () => randomBytes(32).toString('base64url');
export const digest = (value) => createHash('sha256').update(value).digest('hex');
export async function hashPassword(value) {
  const salt = randomBytes(16).toString('hex');
  const key = await passwordKey(value, salt);
  return `scrypt$32768$8$3$${salt}$${key.toString('hex')}`;
}
export async function verifyPassword(value, encoded) {
  if (typeof value !== 'string' || value.length > 128) return false;
  const [, , , , salt, hex] = encoded.split('$');
  const key = await passwordKey(value, salt);
  const expected = Buffer.from(hex, 'hex');
  return expected.length === key.length && timingSafeEqual(expected, key);
}

// Fixed windows; bounded memory. No trust in client-supplied proxy headers.
export class RateLimiter {
  constructor(limit, windowMs, clock) {
    this.limit = limit;
    this.windowMs = windowMs;
    this.clock = clock;
    this.entries = new Map();
  }
  allow(key) {
    const now = this.clock();
    for (const [k, entry] of this.entries) if (entry.until <= now) this.entries.delete(k);
    let entry = this.entries.get(key);
    if (!entry) {
      if (this.entries.size >= 10000) return false;
      entry = { count: 0, until: now + this.windowMs };
      this.entries.set(key, entry);
    }
    return ++entry.count <= this.limit;
  }
}
