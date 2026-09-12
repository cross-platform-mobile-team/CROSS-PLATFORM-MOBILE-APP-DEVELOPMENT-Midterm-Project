# Remaining work

This basic project is not ready for final coursework submission.

Current source-matched status: [current-verified-state.md](current-verified-state.md).
Hosted run 34628335925 at 0753db1 passed all three jobs; this supersedes older
CI status for that source only. Local Android remains unavailable. Manual
Narrator, clean-machine setup and release install/launch are still open gates.
The dated sections below retain the conditions of their original milestones.

## Historical Android and CI boundary - 2026-09-09

Android tooling absence is no longer a project-wide blocker. GitHub Actions
[run #2](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886)
passed debug/release APK builds and 9 offline/controlled workflows on an Android
16/API 36 hosted emulator. It also uploaded both APKs and `SHA256SUMS.txt`.

This does not prove manual release-APK installation/launch, a physical device,
Android account/backend connectivity, screen-reader behavior, clean-machine setup,
or Play Store readiness. `android/app/build.gradle.kts` still signs the release
variant with the debug key, which is suitable only for coursework/demo evidence.
On the other Windows host used on September 9, `flutter doctor -v` reports Android license status
unknown, and Gradle inside the Codex command sandbox cannot establish a required
Java loopback connection. CI is therefore the completed Android build/E2E evidence;
no completed local Android build is claimed.

## Current local Edge verification - 2026-09-10

The D:/flutter host still has no Android SDK; it uses Flutter 3.47.1/Dart 3.13.1.
2026-09-10: the deterministic harness passed six repetitions across three newly
opened non-persistent Edge sessions, with individual raw logs and lifecycle
records. This reduces dependence on one already-open session but still uses one
host/toolchain and shared build/caches. It is not clean-machine, Narrator, online
failure or cross-browser evidence. Report work is deferred by user request.
The native persisted suite had one interrupted first-case stall; its unchanged
standalone rerun passed 3 cases. Both logs remain under edge-sessions-20260910.
The original stall is not diagnosed or claimed fixed.

Test-level repetitions (2026-09-09): three fresh invocations each of selected
unit/widget/golden/Windows suites passed (12/12 total). This extends the initial
Edge experiment but still uses one warm host and unequal workloads. It does not
establish a general failure rate or clean-machine operation. That experiment alone
did not establish CI execution; the later hosted run above does.

Update 2026-09-09 (account settings): automated coverage now includes signed-in
profile/password/session headings, form validation, invalid-field focus recovery,
ordered credential traversal, IME actions and a 200% text deletion-error path.
These widget tests use a synthetic account and mocked HTTP, so they do not prove
Narrator output, physical keyboard/IME behavior or whole-page focus order in the
release build. The exact manual protocol remains NOT RUN in
`docs/accessibility-testing.md`. Account settings are no longer an untested form
area, but manual assistive-technology evidence is still required.

Update 2026-09-09: a gated synthetic Edge harness now closes the prior browser
discovery/controlled-retry gap and passed a five-run same-session experiment.
Flutter's direct integration_test Web-device command remains unsupported on this
SDK. The harness is a real Edge workflow but not the shipped app entrypoint; its
fake failures do not establish online-network failure behavior. Five warm-session
runs on one host are insufficient for a general flakiness percentage. Manual
Narrator/full focus-order, other browsers/hosts and clean-machine work remain.

Latest update (2026-09-08) supersedes historical browser/sample gaps below:
Edge online create/edit/complete/delete/undo and reload/re-login were exercised
against isolated SQLite. A sample CLI assertion checks create/search/reset,
unchanged localStorage and zero API calls. Phone/wide screenshots are evidence
of browser resizing, not a phone device. Safe sample entry is now implemented.
Six new widget cases include login/register/recovery accessibility guidelines,
keyboard focus and register at 200% text. Tags no longer announce as checkboxes.
At that milestone, browser filter ordering/controlled retry automation, Narrator,
full keyboard focus-order, other account-setting forms, repeated runs,
clean-machine setup, Android tooling and submission materials remained. Later
2026-09-09 increments closed the browser harness and automated account-settings
gaps only. Enabling Flutter semantics programmatically for automation is not a
screen-reader test.

Latest lifecycle update: three independently reset real-preference native cases
now cover create, edit/completion and cancel/delete/undo, with full metadata and
unaffected-record assertions. Earlier statements about those missing independent
cases below are historical. Browser/runtime, manual accessibility, safe demo-data
entry and stability studies still remain. A combined native multi-file invocation
failed while launching the second app; standalone rerun passed. Run suites as
separate commands and retain both results; no verified runner root cause is claimed.

## Backend extension - 2026-09-07

Account API and Flutter online mode now exist alongside the offline demo.
Native online auth/task/isolation/conflict flow has passed against a fresh real
SQLite server. Read backend/README.md and architecture/backend.md for exact scope.
This is local-development capability, not a public deployment/security audit.
Email ownership verification, SMTP delivery, MFA, public TLS/proxy, distributed
rate limiting, monitoring and clean-machine operational deployment are absent.
Recovery is via a saved one-time code, not a pretend email. Tokens stay in memory;
restart/page refresh requires login. No automatic offline/online sync or conflict
merge. Online snapshots cap data at 500 tasks and requests at 1 MiB. The backend
uses synchronous SQLite in a single process. Android account-mode runtime still
requires separate evidence; the current Android CI covers offline/controlled
workflows only, and build success alone is not proof of online connectivity.

## Earlier app/coursework boundaries

Update 2026-09-07: four independent native cases now cover compact/wide validation,
seeded search/AND filters/exact order and gated load/write failure recovery. They
use fake storage and logical view overrides; edit/delete remain combined native
workflows. Browser E2E, physical resize, manual accessibility and repeated-run
stability remain unverified. Do not infer Android support from viewport widths.

- Notes/priority/dates/tags, filters, editing, confirmed deletion and one-level
  session undo are implemented. Dates currently use a validated text field.
- Eight goldens and selected automated accessibility checks now pass; full E2E
  scenario coverage, manual accessibility and stability benchmarks remain.
- The controlled search defect is detected at widget level, with genuine
  fail/fix evidence. It is not a native E2E experiment or a flakiness benchmark.
- Golden fixtures use the Android rendering variant on a Windows test host,
  not an Android device. Raster equality is not established across host/SDK versions.
- Accessibility checks cover four visible list/form states, one focus transition
  and opening/cancelling Edit at 200% text; they are not a complete focus-order,
  screen-reader or WCAG compliance audit.
- Windows release was built/launched, and two real-storage integration workflows
  passed. Tests cover CRUD and metadata/filter interaction, then remount
  the app with a fresh repository; it does not test an
  OS reboot or process restart. At that earlier milestone Android was unverified.
- Hosted CI and APK creation now pass as described above. No manual APK launch,
  report, video or clean-machine reproduction claim is made.
- Local preferences have no backup/migration/multi-tab coordination. Invalid
  JSON is preserved and surfaced as an error rather than replaced silently.
- Retry reloads saved tasks; submit again to retry a failed write.
- Native tests register Flutter's test input channel to prevent interference from
  Windows IME when injecting text. They do not establish physical-keyboard/IME
  compatibility. A separate manual keyboard/accessibility pass is still required.
- Official report template, instructor and team details are required later.
