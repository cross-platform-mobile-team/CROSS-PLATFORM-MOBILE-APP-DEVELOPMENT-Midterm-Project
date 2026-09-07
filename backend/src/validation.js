export class ApiError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}
export function fail(status, code, message) {
  throw new ApiError(status, code, message);
}
export function object(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    fail(422, 'validation', 'A JSON object is required.');
  }
  return value;
}
export function fields(value, allowed) {
  object(value);
  if (Object.keys(value).some((key) => !allowed.includes(key))) {
    fail(422, 'validation', 'An unknown or read-only field was supplied.');
  }
}
export function text(value, name, max, min = 0) {
  if (typeof value !== 'string' || value.trim().length < min || value.trim().length > max) {
    fail(422, 'validation', `${name} must contain ${min}-${max} characters.`);
  }
  return value.trim();
}
export function email(value) {
  const result = text(value, 'Email', 254, 3).toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(result)) fail(422, 'validation', 'Enter a valid email.');
  return result;
}
export function password(value) {
  if (typeof value !== 'string' || value.length < 12 || value.length > 128) {
    fail(422, 'validation', 'Password must contain 12-128 characters.');
  }
  return value; // Never trim a password.
}
export function revision(value) {
  if (!Number.isSafeInteger(value) || value < 0) fail(422, 'validation', 'A non-negative integer revision is required.');
  return value;
}
export function task(value, now) {
  fields(value, ['id', 'title', 'notes', 'priority', 'dueDate', 'tags', 'createdAt', 'completed', 'updatedAt', 'completedAt']);
  const id = text(value.id, 'Task ID', 80, 1);
  if (!/^[a-zA-Z0-9_-]+$/.test(id)) fail(422, 'validation', 'Invalid task ID.');
  const title = text(value.title, 'Title', 120, 1);
  const notes = value.notes ?? '';
  if (typeof notes !== 'string' || notes.length > 2000) fail(422, 'validation', 'Notes must be at most 2000 characters.');
  const priority = value.priority ?? 'medium';
  if (!['low', 'medium', 'high'].includes(priority)) fail(422, 'validation', 'Invalid priority.');
  const dueDate = value.dueDate ?? null;
  if (dueDate !== null && (typeof dueDate !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(dueDate) ||
      !Number.isFinite(Date.parse(dueDate)) || new Date(dueDate).toISOString().slice(0, 10) !== dueDate)) {
    fail(422, 'validation', 'Enter a valid date as YYYY-MM-DD.');
  }
  if (value.completed !== undefined && typeof value.completed !== 'boolean') fail(422, 'validation', 'Completed must be boolean.');
  if (!Array.isArray(value.tags ?? []) || (value.tags ?? []).length > 10) fail(422, 'validation', 'At most 10 tags are allowed.');
  const tags = [...new Set((value.tags ?? []).map((tag) => text(tag, 'Tag', 24, 1).toLowerCase()))].sort();
  const createdAt = value.createdAt ?? now;
  if (typeof createdAt !== 'string' || !/^\d{4}-\d{2}-\d{2}T.*(Z|[+-]\d{2}:\d{2})$/.test(createdAt) || !Number.isFinite(Date.parse(createdAt))) {
    fail(422, 'validation', 'createdAt must be an ISO timestamp with timezone.');
  }
  return { id, title, notes, priority, dueDate, tags, completed: value.completed ?? false, createdAt: new Date(createdAt).toISOString() };
}
