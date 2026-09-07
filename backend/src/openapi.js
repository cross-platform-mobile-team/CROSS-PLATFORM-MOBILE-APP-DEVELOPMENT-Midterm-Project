const ref = (name) => ({ $ref: `#/components/schemas/${name}` });
const json = (schema) => ({ 'application/json': { schema } });
const response = (schema, description = 'Success') => ({ description, content: json(schema) });
const object = (properties, required = Object.keys(properties)) => ({ type: 'object', additionalProperties: false, properties, required });
const str = { type: 'string' };
const body = (schema) => ({ required: true, content: json(schema) });
const errors = Object.fromEntries([400, 401, 403, 404, 409, 413, 415, 422, 428, 429, 500, 503].map((code) => [code, response(ref('Error'), 'Structured error; see error.code and requestId.')]));
const op = (summary, result, input, { auth = true, status = 200, parameters = [] } = {}) => ({
  summary, security: auth ? [{ bearerAuth: [] }] : [], parameters,
  ...(input ? { requestBody: body(input) } : {}),
  responses: { ...errors, [status]: result ? response(result) : { description: 'Success; no body' } },
});
const id = { name: 'id', in: 'path', required: true, schema: { type: 'string', pattern: '^[a-zA-Z0-9_-]{1,80}$' } };
const match = { name: 'If-Match', in: 'header', required: true, description: 'Quoted collection revision from GET tasks, e.g. "0".', schema: str };
const taskFields = {
  id: { type: 'string', pattern: '^[a-zA-Z0-9_-]{1,80}$' },
  title: { type: 'string', minLength: 1, maxLength: 120 }, notes: { type: 'string', maxLength: 2000 },
  priority: { type: 'string', enum: ['low', 'medium', 'high'] }, completed: { type: 'boolean' },
  dueDate: { type: ['string', 'null'], format: 'date' },
  tags: { type: 'array', maxItems: 10, items: { type: 'string', minLength: 1, maxLength: 24 } },
  createdAt: { type: 'string', format: 'date-time' },
};
const taskInput = object(taskFields, ['title']);
const { id: _id, createdAt: _created, ...editable } = taskFields;
export const openapi = {
  openapi: '3.1.0', info: { title: 'TaskFlow account and task API', version: '1.0.0',
    description: 'Single-process local-development backend. Bearer sessions, per-user isolation, revision-checked writes. HTTPS is required outside local development. Offline Flutter data is not uploaded automatically.' },
  servers: [{ url: 'http://127.0.0.1:8080', description: 'Local development only' }],
  components: { securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', description: 'Opaque access token, not a JWT. Refresh rotates both credentials.' } }, schemas: {
    Error: object({ error: object({ code: str, message: str, requestId: str }) }),
    User: object({ id: str, email: { type: 'string', format: 'email' }, name: str, createdAt: { type: 'string', format: 'date-time' } }),
    Session: object({ accessToken: str, refreshToken: str, expiresIn: { type: 'integer' }, sessionId: str }),
    Login: object({ ...{ accessToken: str, refreshToken: str, expiresIn: { type: 'integer' }, sessionId: str }, user: ref('User') }),
    Registration: object({ accessToken: str, refreshToken: str, expiresIn: { type: 'integer' }, sessionId: str, user: ref('User'), recoveryCode: str }),
    Task: object({ ...taskFields, updatedAt: { type: 'string', format: 'date-time' }, completedAt: { type: ['string', 'null'], format: 'date-time' } }),
    Revision: { type: 'integer', minimum: 0 },
    Snapshot: object({ revision: ref('Revision'), tasks: { type: 'array', maxItems: 500, items: ref('Task') } }),
  } },
  paths: {
    '/health': { get: op('Database readiness probe', object({ status: str, service: str, schemaVersion: { type: 'integer' } }), null, { auth: false }) },
    '/openapi.json': { get: op('This OpenAPI contract', { type: 'object' }, null, { auth: false }) },
    '/v1/auth/register': { post: op('Register; save the recovery code shown once', ref('Registration'), object({ email: str, password: { type: 'string', minLength: 12, maxLength: 128 }, name: { type: 'string', minLength: 1, maxLength: 80 } }), { auth: false, status: 201 }) },
    '/v1/auth/login': { post: op('Create a session; at most 10 live sessions per user', ref('Login'), object({ email: str, password: str }), { auth: false }) },
    '/v1/auth/refresh': { post: op('Rotate credentials; reusing an old refresh token revokes that session', ref('Session'), object({ refreshToken: str }), { auth: false }) },
    '/v1/auth/reset-password': { post: op('Consume a recovery code, revoke sessions and return a new recovery code', object({ recoveryCode: str }), object({ email: str, recoveryCode: str, newPassword: { type: 'string', minLength: 12, maxLength: 128 } }), { auth: false }) },
    '/v1/auth/me': {
      get: op('Read own profile', object({ user: ref('User') })),
      patch: op('Update own display name; email is immutable', object({ user: ref('User') }), object({ name: { type: 'string', minLength: 1, maxLength: 80 } })),
      delete: op('Permanently delete own account, tasks, audit and sessions', null, object({ currentPassword: str }), { status: 204 }),
    },
    '/v1/auth/password': { post: op('Change password and revoke every session', null, object({ currentPassword: str, newPassword: { type: 'string', minLength: 12, maxLength: 128 } }), { status: 204 }) },
    '/v1/auth/logout': { post: op('Revoke current session', null, null, { status: 204 }) },
    '/v1/auth/logout-all': { post: op('Revoke all own sessions', null, null, { status: 204 }) },
    '/v1/auth/sessions': { get: op('List own unexpired sessions; never returns credentials', object({ sessions: { type: 'array', items: object({ id: str, createdAt: str, expiresAt: str, current: { type: 'boolean' } }) } })) },
    '/v1/auth/sessions/{id}': { delete: op('Revoke one own session', null, null, { status: 204, parameters: [id] }) },
    '/v1/auth/activity': { get: op('Latest 50 account audit events; no credential/IP payloads', object({ events: { type: 'array', items: object({ event: str, at: str }) } })) },
    '/v1/tasks/snapshot': {
      get: op('Read complete own collection with revision', ref('Snapshot')),
      put: op('Atomically replace own collection if revision matches; enables Flutter undo', ref('Snapshot'), object({ revision: ref('Revision'), tasks: { type: 'array', maxItems: 500, items: object({ ...taskFields,
        updatedAt: { description: 'Accepted for snapshot round trips but ignored; computed by the server.' },
        completedAt: { description: 'Accepted for snapshot round trips but ignored; computed by the server.' },
      }, ['id', 'title']) } })),
    },
    '/v1/tasks/stats': { get: op('Own task counts', object({ total: { type: 'integer' }, pending: { type: 'integer' }, completed: { type: 'integer' }, revision: ref('Revision') })) },
    '/v1/tasks': {
      get: op('Search/filter/sort/paginate own tasks; filters combine with AND', object({ tasks: { type: 'array', items: ref('Task') }, total: { type: 'integer' }, limit: { type: 'integer' }, offset: { type: 'integer' }, revision: ref('Revision') }), null, { parameters: [
        ...['q', 'tag'].map((name) => ({ name, in: 'query', schema: str })),
        ...Object.entries({ status: ['all', 'pending', 'completed'], priority: ['all', 'low', 'medium', 'high'], due: ['all', 'overdue', 'today', 'upcoming', 'noDate'], sort: ['newest', 'priority', 'dueDate', 'title'] }).map(([name, values]) => ({ name, in: 'query', schema: { type: 'string', enum: values } })),
        { name: 'today', in: 'query', description: 'Calendar YYYY-MM-DD; defaults to server UTC day. Send local day if needed.', schema: { type: 'string', format: 'date' } },
        { name: 'limit', in: 'query', schema: { type: 'integer', minimum: 1, maximum: 100, default: 20 } },
        { name: 'offset', in: 'query', schema: { type: 'integer', minimum: 0, maximum: 500, default: 0 } },
      ] }),
      post: op('Create own task; ID generated if omitted', object({ task: ref('Task'), revision: ref('Revision') }), taskInput, { status: 201, parameters: [match] }),
    },
    '/v1/tasks/{id}': {
      get: op('Read one own task', object({ task: ref('Task'), revision: ref('Revision') }), null, { parameters: [id] }),
      patch: op('Update own task fields', object({ task: ref('Task'), revision: ref('Revision') }), object(editable, []), { parameters: [id, match] }),
      delete: op('Delete own task; no permanent server trash', object({ revision: ref('Revision') }), null, { parameters: [id, match] }),
    },
  },
};
