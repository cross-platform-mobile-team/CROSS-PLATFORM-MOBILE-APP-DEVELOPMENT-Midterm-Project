# Backend architecture and security boundaries

Agent-assisted project notes, 2026-09-07. Scope was authorized by the user, not
mandated by Topic 4. Read alongside source and actual tests.

```text
Flutter account screens -> ApiClient (memory-only bearer/refresh credentials)
                                  |
TaskScreen -> TaskController -> RemoteTaskRepository -> REST API
                    |                                 |
             offline repository                 validation + owner/session check
                    |                                 |
              preferences                         SQLite transaction
                                               users / sessions / tasks / audit
```

The offline repository remains independent. AccountGateway swaps the UI subtree
and repository on account changes so one user's tasks are not reused for another.
The controller publishes mutations only after a successful save. Remote snapshots
require a prior successful load and matching revision. Failed/uncertain saves clear
the cached revision until explicit reload; the client does not replay writes blindly.

## Data and lifecycle

- users: unique normalized email, display name, salted password hash, recovery-code
  digest, creation time and monotonically increasing task-collection revision.
- sessions: user foreign key, digests of access/refresh tokens, access/absolute
  expirations. used_refresh records consumed tokens for session-family replay
  revocation. Foreign-key cascades remove associated credentials on deletion.
- tasks: composite `(user_id, id)` primary key with validated JSON payload. A query
  never uses client-supplied user_id; it is obtained from the authenticated session.
- audit: account events only, at most 100/account, newest 50 exposed to the owner;
  no passwords, request payloads, recovery codes or token values.
- Schema version stored in PRAGMA user_version. Initialization and writes are
  transactional; prepared statements bind values instead of concatenating SQL.

## Threats and controls

| Threat | Implemented control | Evidence/remaining limit |
|---|---|---|
| Another user's task/session ID | Every lookup/mutation constrained by authenticated owner | API ownership tests; no admin API |
| Lost updates | Atomic collection revision comparison; 409 on mismatch | Concurrent-writer API test and native online workflow |
| Stolen database | Salted scrypt passwords; SHA-256 digests of random 256-bit tokens/codes | No raw credentials stored; DB encryption/access control still required |
| Credential replay | Expiration, refresh rotation, replay-triggered revocation, logout/all | API auth tests; no MFA or external identity provider |
| Password/recovery guessing | IP auth rate limits, generic login/recovery failures, high-entropy recovery code | Single-process limits; registration enumeration remains documented |
| CPU/memory exhaustion | 1 MiB request cap, 500 tasks/account, bounded input, max 4 simultaneous scrypt jobs | Boundary tests; no load/DoS audit or horizontal scaling claim |
| SQL/mass-assignment attacks | Prepared statements, allowed-field checks, immutable owner and ID | Invalid fields and ownership tests |
| Browser-origin or credential leakage | Exact CORS allowlist, memory-only bearer auth, HTTPS except explicit local hosts, no redirects/cross-origin API requests | Client route tests; manual browser/security inspection still needed |
| Lost response after commit | Invalidate client revision; require reload before another snapshot write | Client failure tests; no automatic merge |

The password derivation uses scrypt N=32768, r=8, p=3, a random 16-byte salt and
64-byte derived key, with constant-time key comparison. Parameters are retained
with the hash; changing them later requires an explicit hash-upgrade strategy.
This is one of OWASP's documented scrypt trade-offs; it is not a proof that the
whole application is secure. [OWASP password storage](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
(read 2026-09-07).

Random credentials use Node crypto; scrypt is asynchronous, with a concurrency
cap to bound application-level password jobs. [Node 22.14 crypto API](https://nodejs.org/download/release/v22.14.0/docs/api/crypto.html)
(read 2026-09-07). SQLite statements use the built-in synchronous API, so large
operations can block the server event loop; this bounded single-process backend
is not a high-throughput architecture. [Node 22.14 SQLite API](https://nodejs.org/download/release/v22.14.0/docs/api/sqlite.html)
(read 2026-09-07).

The Flutter network boundary uses the Dart-maintained BSD-3-Clause `http` package,
resolved to 1.6.0, with an injected client for deterministic tests. It supports
native and browser clients. [Package metadata and documentation](https://pub.dev/packages/http)
(read 2026-09-07). The application does not add a JWT, web framework or ORM merely
to increase dependency count; this choice also means our HTTP/security handling
must remain explicitly tested and reviewed.
