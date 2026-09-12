# Test matrix

Current totals and source-matched evidence: [current verified state](current-verified-state.md).
Sections below are dated test-design milestones, not additive current counts.
Package A (upgrade-roadmap.md) changes only documentation/evidence; B/C will
add dirty-draft and conflict recovery risks with their own tests and initial states.

## Bug audit - 2026-09-12

Snapshot safety: three unit cases plus a real widget draft/retry flow in
snapshot_safety_test.dart / failed_load_safety_test.dart. Session safety: late
logout and wrong password after refresh in session_race_test.dart. Use
`flutter test --no-pub`; see bug-audit-20260912.md for fail/fix evidence.

## UI refresh - 2026-09-11

- `test/widget/workspace_layout_test.dart`: desktop status navigation changes
  visible tasks without storage mutation; 200% text falls back to one column.
- `test/golden/auth_screen_golden_test.dart`: compact/wide sign-in appearance.
- `test/golden/account_screen_golden_test.dart`: synthetic signed-in settings.
- Eight existing task goldens intentionally updated after visual review.
  Full 66-case suite and 10 Windows cases pass; see evidence/manifest.md.

## Dedicated widget loading coverage - 2026-09-10

`flutter test test/widget/task_loading_test.dart --reporter expanded`: four cases,
fresh in-memory repositories and Completer gates. Initial loading at 390/1100
widths checks progress label, disabled Add, no premature empty/data state and
blocked keyboard submission. Releasing the gate restores data/controls. A load
failure transitions through gated Retry to empty. Pending save retains the draft
and blocks duplicate keyboard submission; release produces exactly one stored
task and clears the successfully saved draft. No sleeps or real storage/network.

## Android and CI gate - 2026-09-09

| Risk | Scenario | Command/job | Result |
|---|---|---|---|
| Android compile drift | Build debug and release APK with Flutter 3.47.0, JDK 17 and NDK r28c | `Android APKs` | PASS |
| Platform workflow regression | Independent 4, persisted 3 and preference-backed 2 scenarios on Android 16/API 36 | `Android E2E (API 36)` | PASS, 9/9 executions |
| Artifact provenance | Generate `SHA256SUMS.txt` and upload both APKs | `Android APKs` | PASS; `taskflow-android-apks`, 14-day retention |
| Windows/host drift | Format, analyze, 57 Flutter, 14 API and release builds | `Windows quality gates` | PASS |
| Release runtime | Install and manually launch release APK | Local/physical-device protocol | NOT RUN |
| Android online mode | Use an externally reachable HTTPS API rather than emulator localhost | Future targeted E2E | NOT RUN |

Source: GitHub Actions
[run #2](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886)
at commit `9ca2a96`. The three Android files ran as separate Flutter invocations;
the online API/SQLite Windows case is not included. Detecting `emulator-5554`
locally is readiness evidence, not a local passing test.

## Repetition across test levels - 2026-09-09

`scripts/repeat-test-levels.ps1` launches the existing controller unit suite (4),
search regression widget case (1), golden suite (8) and independent Windows suite
(4) three times each. Fixtures reset per test; each invocation is a new Flutter
process. Rotated order reduces but does not eliminate warm-cache/order effects.
See experiments/test-levels-20260909.md for raw results and interpretation.

## Account settings accessibility - 2026-09-09

| Risk | Scenario / command | Level and evidence |
|---|---|---|
| Signed-in forms have no accessible structure | Assert account and three section headings through semantics | Widget; `account_settings_accessibility_test.dart` |
| Validation leaves keyboard/screen-reader users stranded | Empty profile/password/delete actions return focus to the first invalid field and expose readable errors | Widget; same file |
| Keyboard traversal skips or reorders credential controls | Display name -> Save profile -> current password; IME Next -> new password; Done validates | Widget; Windows-style key/action events with explicit ordered form groups |
| Large text hides destructive/recovery actions | Scroll to account deletion, trigger safe empty-password error at 390 x 900 and 200% text | Widget; no overflow/exception and no HTTP mutation |

Command: `flutter test test/widget/account_settings_accessibility_test.dart
--reporter expanded`. Automated semantics/guideline checks are not Narrator or
physical keyboard evidence; the manual protocol remains NOT RUN in
`docs/accessibility-testing.md`.

## Current additions - 2026-09-08

| Risk | Scenario / command | Level and evidence |
|---|---|---|
| Samples mutate private data | Reset sandbox, retain pre-existing offline task, no API calls; flutter test test/widget/sample_accessibility_test.dart | Widget; 6 new cases including following accessibility checks |
| Account forms inaccessible | Login/register/recovery invalid-form guidelines, keyboard Email/Password focus and register at 200% text | Widget; same file, edge-tests-20260908.txt |
| Decorative tags announce controls | Find individual Tag: flutter semantics | Widget regression and Edge semantics snapshots |
| Web lifecycle loses saved edits | Online create/edit/complete/delete/undo, reload and sign in again | Real Edge/HTTP/SQLite; web-edge-testing.md |
| Sample reset or isolation breaks in browser | scripts/browser/edge-sample-check.js via pinned CLI | Edge assertions; sample creation/search/reset/storage/network |

Current full gate: 57 Flutter (8 unchanged goldens), 14 API, 10 Windows case
executions, and 9 hosted Android case executions of the three offline/controlled
native suites.
Historical sections below describe earlier milestones, not current totals.

## Edge deterministic harness - 2026-09-09

| Risk | Controlled assertion | Command |
|---|---|---|
| Web runner gap | Direct integration_test Edge attempt retained as unsupported | flutter test integration_test/independent_scenarios_test.dart -d edge |
| Load/save failure | Initial load error -> Retry; first save error -> draft retained -> Retry/save | scripts/test-edge-harness.ps1 |
| Invalid form inaccessible | Blank title sets ARIA invalid and error description | scripts/browser/edge-harness-check.js |
| Discovery regression | Padded uppercase search + pending AND high AND normalized exact tag | Same script; asserts Alpha/Beta exact order |
| State leak/flakiness | URL-reset scenarios repeated five times | scripts/browser/repeat-edge-harness.ps1 |

Observed series: 5/5 PASS in one isolated Edge session, mean 7.583 s. This is a
bounded sample, not a general flakiness rate; see the experiment document.

| Risk | Scenario | Level |
|---|---|---|
| Invalid title | Blank and 120/121-character boundaries | Unit |
| Search misses tasks | Padded mixed-case substring | Unit |
| Nondeterministic data | Inject clock/ID; verify persisted completion | Unit |
| Write failure publishes bad state | Failed save followed by load recovery | Unit |
| Serialization loss | Task JSON round trip | Unit |
| Broken UI workflow | Empty -> invalid -> create -> complete at 390/1100 widths | Widget |
| Recovery unavailable | Initial failure -> Retry -> empty | Widget |

Command: flutter test --coverage. Tests isolate repositories and use finite UI
settling. Source: test/unit/task_controller_test.dart and test/widget/task_screen_test.dart.
Native smoke: integration_test/windows_workflow_test.dart runs create/complete/
reload against real local preferences under a separate test key. PASS on Windows.
This paragraph describes the initial smoke test; later milestones below supersede
its scope. The independent full multi-scenario E2E suite is still pending.

## CRUD milestone (2026-09-06)

- Unit: edit preserves fields, rejects blank input, retries failed edits; delete/
  undo persistence, failed delete/undo, missing ID, latest-only undo and write serialization.
- Widget: edit validation and retained draft after failed save; cancel deletion,
  confirm deletion and undo on 390/1100 logical-pixel viewports.
- Windows: create/edit/complete/delete/undo/remount with real isolated preferences.
- Raw unit/widget output: evidence/crud-tests-20260906.txt (15 tests total).
- Native output: evidence/windows-crud-20260906.txt.

## Metadata milestone (2026-09-06)

- Legacy JSON gets defaults; new metadata survives serialization and task mutations.
- Tag normalization/immutability/limits; notes limit; invalid calendar dates rejected.
- Combined filters, exact tag, note search, overdue/today/future/no-date boundaries.
- Stable priority/due sorting, with null dates last.
- Phone/wide forms: create metadata, reject invalid date, filter to empty, clear,
  edit fields and remove date. Shared interaction helper also runs on Windows with
  real isolated local preferences and remount verification.
- Metadata milestone total: 24 unit/widget tests and 2 native Windows tests.

## Visual, accessibility and regression milestone (2026-09-06)

| Risk | Scenario | Level | Command from repository root |
|---|---|---|---|
| Layout changes unnoticed | Empty/populated/validation/error at 390x960 and 1280x900 | 8 golden cases | flutter test test/golden |
| Inaccessible controls/text | Labels, tap sizes and contrast in four visible states | 4 widget cases | flutter test test/widget/accessibility_test.dart |
| Keyboard/text-scale breakage | Tab and submit; edit/cancel at 200% phone text | 2 widget cases | flutter test test/widget/accessibility_test.dart |
| Prefix-only search regression | Search padded uppercase middle word, verify saved card | 1 widget case | flutter test test/widget/search_regression_test.dart |

At the visual milestone: 39 unit/widget/golden cases plus 2 Windows integration workflows.
See golden-testing.md for controlled environment, review process and coverage
limits; evidence/intentional_defect/README.md for mutation reproduction.
Full suite: `flutter test --coverage --reporter expanded`.
Native: `flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded`.

## Backend increment (2026-09-07)

| Risk | Scenario/evidence | Level/command |
|---|---|---|
| Account/tenant breach | Foreign task/session IDs, injected owner/role fields, deletion cascades | Real HTTP/SQLite: cd backend; npm test |
| Credential replay/loss | Expired/reused refresh, logout/all/revoke, password and one-use recovery, hashed storage | Real HTTP/SQLite: backend/test/api.test.js |
| Data loss | Atomic invalid-snapshot rejection, simultaneous stale writers, restart persistence, consistent backup | Real HTTP/SQLite: backend/test/api.test.js |
| Unsafe HTTP input | CORS, malformed/null JSON, content type, request cap, auth rate limit | Real HTTP/SQLite: backend/test/api.test.js |
| Client retry/session race | Single-flight refresh, no blind snapshot replay, cancelled login, wrong password vs expired session, logout offline | flutter test test/unit/api_client_test.dart |
| Broken account UI | Validation, registration/recovery acknowledgement, failed login, offline isolation | flutter test test/widget/account_flow_test.dart |
| Broken native connectivity | Register -> create -> other sessions see persistence -> cross-user isolation -> stale write blocked -> logout/login -> cleanup | scripts/test-online-windows.ps1 |

14 Node API cases, 49 Flutter unit/widget/golden cases, 2 offline Windows workflows
and 1 real online Windows workflow. Counts are not coverage percentages. Native
typing still uses the registered test input channel. Public deployments, browser
online E2E and Android are not inferred from these results.

## Independent native increment (2026-09-07)

Command: `flutter test integration_test/independent_scenarios_test.dart -d windows --reporter expanded`.

| Risk | Case | Assertions |
|---|---|---|
| Invalid data or responsive regression | Empty/validation/correction at 390 and 1100 logical widths | No invalid save, readable error, one corrected task in UI/repository |
| Filter OR instead of AND; ignored sort/search normalization | Fixed four-task discovery fixture | Exact Alpha/Beta title order, exclusions, no-match and clear |
| Premature success or lost draft | Controlled load/save errors and gated Retry | Loading and disabled submit, unchanged storage on failure, retained draft, one saved task after retry |

4 additional Windows cases bring the native total to 7 (2 preferences + 1 real
API + 4 controlled repository). The unit/widget/golden total stays 49, API stays
14. This is not 7 real-database tests. See independent-e2e.md for boundaries.

## Persisted lifecycle increment (2026-09-07)

Command: `flutter test integration_test/persisted_scenarios_test.dart -d windows --reporter expanded`.
Three new independent native cases: empty create/remount, seeded edit/complete/
remount and seeded cancel/delete/undo/remount. Storage is SharedPreferencesAsync
with three dedicated test keys, not the production key; compare full serialized
records and the unaffected task. Native total becomes 10; Flutter/API counts stay
49/14. This is repository/UI remount persistence, not process-restart evidence.

Run native files in separate Flutter invocations. A combined two-file run failed
at launching the second app on this host; see persisted-existing-native-20260907.txt.
The second file then passed as a standalone command, without changing assertions
or adding waits. Root cause below the runner launch boundary remains unconfirmed.
## Fresh browser-session runner (2026-09-10)

| Risk | Fixture/action | Expected result | Verification |
|---|---|---|---|
| Success depends on an already-used browser profile | Three newly named non-persistent Edge sessions; two existing harness workflows each | Validation, discovery, retry and draft assertions pass independently of prior session | `scripts/test-edge-harness.ps1 -Sessions 3 -Repetitions 2` with explicit Flutter path |
| A failing CLI invocation is hidden by a later pass | Synthetic sequence: pass, missing PASS marker, exit 7 despite marker, pass | All four records retained; runner throws after finishing | `scripts/tests/edge-runner-contract.ps1` |
| Evidence overwritten or even-count summary incorrect | Reuse result directory; two successful synthetic runs | Reuse rejected with identical original hash; median is average of middle pair | Same synthetic contract test; not browser/application evidence |
