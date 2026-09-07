# Account backend increment - 2026-09-06

User-requested scope expansion; agent-assisted implementation for student review.
No public deployment, paid service, third-party account, or global installation.

1. Backend: Node.js HTTP API, SQLite schema/versioned initialization, parameterized
   queries, validation, bounded JSON, explicit CORS origins, health, error envelope.
2. Accounts: registration/login, scrypt password hashes, hashed random access and
   refresh tokens, expiring/rotating sessions, logout/all sessions, profile update,
   password change, one-time recovery code reset, account deletion with password.
3. Tasks: tenant ownership on every query, CRUD/search/filter/sort/pagination,
   statistics and atomic revision-checked snapshots for the existing repository
   interface. No silent overwrites on stale writes or partial snapshot commits.
4. Flutter: account screens and remote repository, session refresh, error/conflict
   handling, account actions, explicit offline alternative; no automatic migration
   or token storage in browser localStorage/shared preferences.
5. Verification: real HTTP/SQLite tests, auth/ownership/concurrency/validation and
   recovery negative cases, Flutter client/widget tests, native online workflow,
   existing offline quality gates and release builds. Record actual results.
6. Handoff: API reference, configuration template, run/backup/restore guidance,
   threat model and honest deployment limitations, refreshed traceability/evidence.

Acceptance: two independent users cannot see/change each other's data; passwords
and raw credentials are not stored in SQLite or logged; expired/revoked sessions
fail; stale writes get 409; accounts/tasks survive a server restart; Flutter can
register, log in, mutate tasks and log out against the real server.

Local runtime checked: PATH Node 22.14.0 / SQLite 3.47.2; bundled Node 24.19.0
also available. Use standard Node APIs, no npm production dependencies. Built-in
SQLite is experimental in Node 22; keep a single process and small bounded datasets.
Existing Flutter 3.47.1/Dart 3.13.1, Windows/Web available, Android SDK missing.

Implementation update 2026-09-07: all six increment areas now have source, API/client
tests, native online evidence and documentation. Remaining limitations include
public deployment/operations, email verification/SMTP/MFA and online browser/Android
runtime verification. This is not completion of the coursework report/video.
