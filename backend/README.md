# TaskFlow API

Account-based backend for the Flutter task manager. This is an original,
agent-assisted coursework implementation for team review, not an audited public
production service. It runs locally without cloud accounts or npm dependencies.

## Run on Windows

Verified development runtime: Node.js 22.14.0 with built-in SQLite 3.47.2.
Node's SQLite API is experimental in that version. Keep one server process per
database and use the recorded runtime for reproduction; review a maintained,
patched runtime before public deployment. No SDK/database installation is needed
on the current development machine.

From repository root, in one terminal:

```powershell
.\scripts\run-backend.ps1
# Or:
cd backend
npm.cmd ci --ignore-scripts
npm.cmd start
```

No `.env` is required for the defaults. To customize, copy `.env.example` to
`.env` locally and review HOST, PORT, DATABASE_PATH and CORS_ORIGINS. Never commit
the real `.env`, database, backups or logs containing private data. Defaults:

The PowerShell launcher explicitly selects port 8080; use `-Port 8082` to
override it. `npm.cmd start` instead respects PORT from the environment/`.env`.

- Listen: `127.0.0.1:8080` (not exposed on all network interfaces).
- Database: `backend/data/taskflow.sqlite` when started by the commands above.
- Browser origins: exactly `http://localhost:7357`, `http://127.0.0.1:7357`.
- Readiness: `GET /health`; machine-readable reference: `GET /openapi.json`.

In a second terminal, from repository root:

```powershell
& 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat' run -d windows
# Web: keep the allowed origin/port fixed.
& 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat' run -d edge --web-port 7357
```

The app now starts on Sign in. Choose Create account, use an email-shaped account
identifier, and set a 12-128-character password. Save the recovery code privately
when prompted; it is shown once. Email ownership is NOT verified and no email is
sent. Never use a real password reused from another service for the demo.

The account menu supports display-name changes, password change, session listing
and revocation, sign-out/all sessions and permanent account deletion with password
confirmation. Forgot password consumes the saved recovery code and gives a new
code; the old code and all previous sessions are revoked. Without the password or
recovery code there is no automatic recovery or undocumented admin backdoor.

Use offline demo requires no server/account and retains the original local
preferences. Online and offline data are separate. There is no silent upload,
background sync, multi-device live push or automatic conflict merging.

## API contract

All `/v1/tasks` and authenticated account routes require
`Authorization: Bearer <accessToken>`. Send JSON bodies with application/json.
Access tokens last 15 minutes; refresh sessions expire absolutely after 7 days.
Refresh tokens are one-use: clients must serialize refresh attempts. Only ten
live sessions per account are retained; oldest sessions are revoked first.

| Method/path | Behavior |
|---|---|
| POST /v1/auth/register | email, name, password -> user, tokens, one-time recoveryCode |
| POST /v1/auth/login | email, password -> user and tokens |
| POST /v1/auth/refresh | refreshToken -> rotated tokens; replay revokes the session |
| POST /v1/auth/reset-password | email, recoveryCode, newPassword -> replacement recoveryCode |
| GET/PATCH /v1/auth/me | Read profile / update name; email is immutable |
| DELETE /v1/auth/me | currentPassword; permanently delete own account and related rows |
| POST /v1/auth/password | currentPassword, newPassword; revoke every session |
| POST /v1/auth/logout | Revoke this session |
| POST /v1/auth/logout-all | Revoke all own sessions |
| GET /v1/auth/sessions | List own sessions without tokens |
| DELETE /v1/auth/sessions/{id} | Revoke only an owned session |
| GET /v1/auth/activity | Latest 50 account events, no credential payloads |
| GET /v1/tasks/snapshot | Complete own task collection plus revision |
| PUT /v1/tasks/snapshot | Atomic replacement: `{revision, tasks}`; at most 500 tasks |
| GET /v1/tasks | Search/filter/sort/paginate own tasks |
| POST /v1/tasks | Create task; ID generated when omitted |
| GET/PATCH/DELETE /v1/tasks/{id} | Read/edit/delete an owned task |
| GET /v1/tasks/stats | Total, pending and completed counts |

Create/PATCH/DELETE task endpoints require an `If-Match` header containing the
quoted collection revision, e.g. `"0"`. Snapshot PUT carries the revision in its
body. Revisions increment atomically and are scoped to the account, not the task.
409 means another writer changed the collection: reload, review and retry the
intended edit. Never automatically overwrite the latest state with a stale list.

Task fields: id, title, notes, priority (low/medium/high), completed, dueDate
(YYYY-MM-DD or null), tags and createdAt (ISO timezone timestamp). The server
maintains updatedAt/completedAt; caller-provided versions are ignored for snapshot
round trips. Existing createdAt cannot be rewritten. Tags are trimmed/lowercased,
deduplicated and sorted. Title: 1-120 trimmed characters; notes: 0-2000; tags:
at most 10, each 1-24 characters. IDs allow ASCII letters/digits/underscore/hyphen.

GET tasks query: q (title/notes/tags substring), status, priority, due, tag, sort,
limit (1-100, default 20), offset (0-500). Sort: newest/priority/dueDate/title;
ties use ID ascending, undated tasks sort last. Filters combine with AND. The
optional `today=YYYY-MM-DD` controls due filtering; default is the server's UTC
day. Flutter currently loads a bounded full snapshot and uses the existing local
calendar-day filters rather than pagination. This is a small-task-list design.

Standard failures contain `{error: {code, message, requestId}}`. Important statuses:
400 malformed JSON, 401 unauthorized/incorrect credential, 403 disallowed origin,
404 missing or not-owned resource, 409 conflict, 413 body over 1 MiB, 415 wrong
content type, 422 invalid data, 428 missing If-Match, 429 rate limit, 503 busy
password worker capacity. Unexpected errors return a generic 500, not stack traces.

## Verification

```powershell
cd backend
npm.cmd run check
npm.cmd test
# From repository root:
& 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat' test --coverage
.\scripts\test-online-windows.ps1
```

The native test helper allocates a unique database under ignored build/, starts
only its own loopback server on port 8081, polls readiness with a deadline, runs
the Flutter workflow and stops that exact process. It refuses an occupied port.
The retained test database contains only synthetic test identities; inspect logs
there when diagnosing failures. It does not reset production preferences/database.
Do not run the native test against real accounts: it creates/deletes fixed test
identities and requires the helper's clean isolated database.

## Backup and restore

SQLite migration 1 is automatic and transactional; newer unknown schema versions
are rejected. No schema is dropped on startup. Do not copy just the live SQLite
file while WAL writes are active; use the consistent snapshot helper:

```powershell
cd backend
# Parent directory must exist; destination must not already exist.
node scripts/backup.js data/taskflow.sqlite data/taskflow-backup.sqlite
```

The helper uses VACUUM INTO and checks the resulting database integrity. Keep
backups private: password hashes and account data are sensitive even without raw
tokens. Protect the data directory with OS permissions; encryption at rest is an
operator responsibility. To restore, stop the server, preserve the original
database and WAL files, then set DATABASE_PATH to the verified standalone backup
and start one server process. Do not overwrite a running database. Revoke sessions
after incident recovery: restoring a historical backup can resurrect old sessions.

## Boundaries before Internet deployment

This increment does not configure TLS/reverse proxy, email verification/SMTP,
MFA, bot/abuse controls across multiple processes, encryption at rest, monitoring,
automated backups, availability targets or a penetration test. In-memory limits
reset on restart. CORS is browser policy, not authorization; every data route also
checks the bearer session and owner. Account registration can reveal an existing
email through 409; public deployment needs an anti-enumeration policy.

The client keeps tokens only in memory, so app restart/page refresh signs out.
No plaintext credential is stored in SharedPreferences/localStorage. Online
network failures require retry; uncertain writes require reload because the server
may already have committed. Logging out without connectivity clears local tokens,
but the server session cannot be confirmed revoked until it expires/is revoked.

Android has the Internet permission for HTTPS release endpoints, but Android build
and runtime remain NOT RUN (SDK missing). Emulator HTTP configuration and actual
device reachability need explicit platform verification, not a support claim.

See [backend architecture and security](../docs/architecture/backend.md) and
[evidence](../docs/evidence/manifest.md). This does not complete the report/video
or imply a coursework score or production-readiness certification.
