# Bootstrap decisions

## Snapshot request budget and CI selection 19 September 2026

- The one-MiB global body limit contradicted 500 bounded task records. A real
  failing HTTP regression established 413 instead of 200. Authenticated snapshot
  PUT now permits 8 MiB, covering canonical JSON including six-byte character
  escapes. Other routes stay at 1 MiB. Record, field, revision and ownership
  limits remain; session authentication is checked before buffering and again
  before mutation. This is not an unbounded import endpoint.
- Native CI now selects the same six suites as local Windows verification.
  Android Linux orchestration owns a temporary SQLite database and ephemeral
  local port; no production URL is accepted. Windows keeps its existing helper.
- Pin Node 22.14.0 because this is the locally tested built-in SQLite runtime.
  setup-node's exact-version input was checked against the official README:
  https://github.com/actions/setup-node/tree/v4 (accessed 19 September 2026).
  No runtime dependency was added. New hosted execution is pending publication.

## Deterministic browser harness - 2026-09-09

- The installed Flutter runner cannot execute integration_test on Web devices.
  Use a separate target guarded by `TASKFLOW_BROWSER_HARNESS=true`, rather than
  adding production failure buttons/query behavior or pretending native logical
  viewports are browser execution.
- Reuse the repository interface with a small deterministic fake: fixed seeds,
  counters for exactly one load/save failure, no API/preferences. The default
  `main.dart` and release behavior remain unchanged.
- Drive accessible roles and observable conditions with the already pinned CLI;
  normalize raw ARIA-label whitespace for exact order comparison. Retain script
  debugging failures and do not convert five warm-session passes into a broad
  reliability claim.

## Sample and Edge increment - 2026-09-08

- Seed only an explicitly selected in-memory sandbox. Never seed/clear the user's
  persisted offline repository, and never upload offline/sample tasks to accounts.
  Fresh repository identity remounts controller/UI on each sample entry.
- Wrap decorative tag Chips in individual text Semantics nodes; preserve visual
  design and completion checkboxes. Regression checks plus real Edge snapshots
  establish the intended labels, not a full screen-reader audit.
- Extend SDK accessibility guidelines and keyboard/text-scale tests without new
  Flutter packages or changed goldens. Use Playwright CLI 0.1.19 through npx only
  as a local QA tool; no npm app dependency/global installation. Keep credentials
  and browser traces private; publish reviewed synthetic-data screenshots only.

## Backend expansion - 2026-09-06

- The user explicitly requested account-based backend behavior after the offline
  scope discussion. Preserve offline tests and data as a separate mode.
- Node HTTP/crypto/sqlite and SQLite transactions avoid another installed database
  service and native npm addons. Standard library only; explicit route/validation
  modules, prepared statements and API tests are required to keep this maintainable.
- Add Dart's `http` client: the Dart-maintained BSD-3-Clause package supports
  browser/native clients; dart:io alone cannot serve Flutter Web. Package metadata,
  licence and usage read at https://pub.dev/packages/http on 2026-09-06; resolve
  through pub rather than guessing a version, retain pubspec.lock.
- Opaque random bearer/refresh tokens, only digests on the server, in-memory on
  the client. No credential persistence in SharedPreferences. Re-login after app
  restart is deliberate. Passwords use salted scrypt, not plain/fast hashes.
- Recovery uses a high-entropy code shown once, not simulated email delivery.
  SMTP/email verification, social login and MFA are not claimed or configured.

- Constructor injection and Flutter ChangeNotifier suit this single feature.
- shared_preferences 2.5.5 was resolved by pub. The downloaded package README and
  BSD license were inspected on 2026-09-05. The Flutter-maintained plugin supports
  Android/Web/Windows; the SDK has no uniform persistence API across these targets.
  Async API avoids the legacy process-local cache. This is small non-critical
  data; preferences do not guarantee disk durability. Reconsider a database later.
- Persist before publishing new state; failed writes preserve the prior list.
- Sort newest first and use ID ascending for ties; inject clock/ID in tests.
- Keep Flutter 3.47.1 fixed for a reproducible baseline.

- Metadata uses optional top-level JSON keys in the existing storage format, so
  legacy tasks receive defaults without destructive migration. Tags are immutable.
- Calendar dates serialize as YYYY-MM-DD (no UTC conversion). Overdue excludes
  completed tasks. Other due filters combine with the selected status via AND.
- Keep quick creation compact with optional details; share metadata form fields
  between creation and editing. No additional dependencies were introduced.

## Visual verification decisions - 2026-09-06

- Use Flutter's built-in golden matcher and accessibility guidelines, no new
  package. Vendor test-only Roboto files with their Apache 2.0 licence and load
  SDK MaterialIcons explicitly to avoid missing glyphs in goldens.
- Fix host/SDK, locale, pixel ratio, sizes, rendering variant and seed data.
  Keep exact image comparison. Host/SDK changes require reviewed baseline changes.
- Darker/larger/semibold inline error text addresses the observed contrast failure;
  no guideline suppression or lower threshold was introduced.
- Keep the search mutation as two patches and authentic logs, never as active
  buggy source. Its test verifies saved task UI rather than matching input text.
- Prefer independent, meaningful test scenarios over inflating test counts;
  these checks supplement, not replace, device E2E and manual accessibility.
