# Evidence manifest

## Android and CI verification on the other host - 2026-09-09

| Check | Result | Evidence |
|---|---|---|
| Current host toolchain | READY; Flutter doctor reports Android license status unknown | Flutter 3.47.0/Dart 3.13.0; SDK `C:\Android\sdk`; JDK 17; NDK `28.2.13676358`; API 36 AVD |
| Current local quality gate | PASS | Format 40 files unchanged; analyze; 57 Flutter; 14 API; 10 Windows; Web/Windows release |
| CI run #1, commit `60689a2` | CANCELLED/SUPERSEDED after Android SDK executable lookup failed | [Run #1](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34376768204) |
| CI run #2, commit `9ca2a96` | PASS, all 3 jobs | [Run #2](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886) |
| Windows quality gates in run #2 | PASS | Format, analyze, 57 Flutter, 14 API, Web release, Windows release |
| Android debug/release APKs | PASS | `Android APKs` job; artifact `taskflow-android-apks` |
| Android API 36 E2E | PASS, 9 case executions | Independent 4 + persisted 3 + preference-backed 2, each suite a separate command |
| APK provenance | PASS | Artifact includes both APKs and `SHA256SUMS.txt`; 14-day retention through 2026-09-23 |
| Manual release install/launch, physical device, Android account mode | NOT RUN | Do not infer from hosted emulator success |

Exact observed run/job/artifact metadata and scope boundaries are retained in
[android-ci-20260909.md](android-ci-20260909.md). Earlier sections preserve the
toolchain status and results at their dated milestones.

## Latest: independent Edge sessions and runner safeguards - 2026-09-10

User deferred report work. [Verification notes and raw results](edge-sessions-20260910/README.md)
cover 3 newly opened Edge sessions, 2 existing workflows per session, all 6 PASS.
Command: `scripts/test-edge-harness.ps1 -Flutter C:\Users\LENOVO\flutter-sdk\bin\flutter.bat -Sessions 3 -Repetitions 2`.
Individual logs, exit codes, timestamps and separate workflow/lifecycle durations
are preserved; default main.dart Web release was restored. This remains one-host
synthetic-harness evidence, not online failure, Narrator or clean-machine testing.

All files below are in `edge-sessions-20260910/`:

| Gate | Outcome | Raw file |
|---|---|---|
| Three Edge sessions / six workflows | PASS | sessions.json; session-1/ through session-3/; fresh-sessions-orchestration-20260910.txt |
| Synthetic runner failure propagation, no overwrite, median | PASS (not app evidence) | runner-contract-20260910.txt |
| Dart format / Flutter analyze | PASS / PASS | format.txt; analyze.txt |
| Flutter tests / coverage | PASS 57 / PASS 57; 8 goldens unchanged | flutter-tests.txt; flutter-coverage.txt |
| Backend syntax / Node tests | PASS / PASS 14 | backend-tests-20260910.txt (tests); syntax command checked directly |
| Windows preference / controlled suites | PASS 2 / PASS 4 | native-windows_workflow_test.txt; native-independent_scenarios_test.txt |
| Windows persisted suite, initial attempt | INTERRUPTED at first case; not PASS | native-persisted_scenarios_test.txt |
| Same persisted suite, standalone --timeout 90s | PASS 3, no code/assertion change; original stall unexplained | native-persisted-retry.txt |
| Windows real API/SQLite | PASS 1 | native-online.txt |
| Windows release / default Web release | PASS / PASS | build-windows.txt; fresh-sessions-orchestration-20260910.txt |
| Android/APK on this local host | NOT RUN; Android SDK absent | environment.md records local toolchain |
| Manual Narrator / clean-machine setup | NOT RUN | Separate future gates |

Upstream CI evidence at `9ca2a96` was retained during synchronization, and its run
34377270886 was rechecked through GitHub's API as completed/success. This is a
different execution from this local gate; see [Android CI evidence](android-ci-20260909.md).

## Previous: test-level repetitions and publication - 2026-09-09

`scripts/repeat-test-levels.ps1 -FlutterSdk C:\Users\LENOVO\flutter-sdk -Repetitions 3`
completed 12/12 invocations: controller unit (4 cases), search widget (1), golden
(8), independent Windows (4), each repeated three times in fresh Flutter processes.
Raw logs, exact commands, timestamps, exit codes and timings:
[test-levels-20260909/results.json](test-levels-20260909/results.json).
Interpretation: [test-level experiment](../experiments/test-levels-20260909.md).

PowerShell parsing, Dart format and Flutter analyze were checked before publication.
The account-settings full quality gate below applies to the unchanged Flutter and
backend source in this publication: 57 Flutter, 14 API, 10 Windows cases and both
release builds PASS. Repetitions add observations, not new unique test cases.
At that milestone, Android/APK, CI, clean-machine setup and Narrator were NOT RUN.

## Previous: signed-in account settings accessibility - 2026-09-09

| Command/check | Result | Raw artifact |
|---|---|---|
| flutter test test/widget/account_settings_accessibility_test.dart --reporter expanded | PASS, 2 isolated widget cases | accessibility-account-focused-20260909.txt |
| dart format --output=none --set-exit-if-changed . | PASS, 40 files unchanged | accessibility-format-20260909.txt |
| flutter analyze | PASS, no issues | accessibility-analyze-20260909.txt |
| flutter test --reporter expanded | PASS, 57 | accessibility-tests-20260909.txt |
| flutter test --coverage --reporter expanded | PASS, 57 including 8 unchanged goldens | accessibility-coverage-20260909.txt |
| cd backend; npm run check; npm test | PASS, syntax and 14 API cases | accessibility-api-check-20260909.txt; accessibility-api-20260909.txt |
| Three offline/controlled Windows suites, separate invocations | PASS, 2 + 4 + 3 cases | accessibility-native-windows_workflow_test-20260909.txt; accessibility-native-independent_scenarios_test-20260909.txt; accessibility-native-persisted_scenarios_test-20260909.txt |
| scripts/test-online-windows.ps1 | PASS, 1 isolated real API/SQLite case | accessibility-native-online-20260909.txt |
| flutter build windows --release | PASS | accessibility-build-windows-20260909.txt |
| flutter build web --release | PASS, default main.dart | accessibility-build-web-20260909.txt |
| scripts/test-edge-harness.ps1 -Repetitions 1 | PASS, one smoke run (8.785 s), own Edge/server closed and default Web build restored | accessibility-edge-harness-20260909.txt |
| Environment version/doctor/devices recheck | PASS for Windows/Web; Android SDK absent | accessibility-environment-20260909.txt |
| flutter build apk --release | NOT RUN, Android SDK absent | accessibility-environment-20260909.txt |
| Manual Narrator, physical keyboard/IME and whole-page focus order | NOT RUN; executable protocol prepared | ../accessibility-testing.md |

The two new cases use a synthetic signed-in account and mocked HTTP. They cover
semantic headings, profile/password validation, focus recovery, ordered form
traversal, IME Next/Done actions, guidelines and a deletion-error path at 200%
text. They do not establish real Narrator output, physical keyboard/IME behavior
or WCAG conformance. The Edge value above is one additional smoke observation,
not an update to the earlier five-run stability experiment or a failure rate.

## Previous: deterministic Edge failures, discovery and repetition - 2026-09-09

| Command/check | Result | Raw artifact |
|---|---|---|
| flutter test integration_test/independent_scenarios_test.dart -d edge --reporter expanded | NOT RUN by runner: Web integration devices unsupported | browser-integration-unsupported-20260909.txt |
| flutter build web --target lib/browser_test_harness.dart --dart-define=TASKFLOW_BROWSER_HARNESS=true | PASS | browser-harness-build-20260909.txt |
| scripts/browser/edge-harness-check.js via Edge 152 / CLI 0.1.19 | PASS, 11 controlled assertions | browser-harness-final-20260909.txt |
| scripts/browser/repeat-edge-harness.ps1 -Repetitions 5 | PASS 5/5; mean 7.583 s, median 7.461 s, 7.202-8.024 s | browser-harness-repeat5-20260909.txt |
| scripts/test-edge-harness.ps1 ... -Repetitions 1 | PASS final orchestration smoke; own resources closed, default build restored | browser-harness-orchestrated-final-20260909.txt |
| dart format --output=none --set-exit-if-changed . | PASS, 39 files unchanged | harness-format-20260909.txt |
| flutter analyze | PASS | harness-analyze-20260909.txt |
| flutter test --reporter expanded | PASS, 55 | harness-tests-20260909.txt |
| flutter test --coverage --reporter expanded | PASS, 55 and 8 unchanged goldens | harness-coverage-20260909.txt |
| cd backend; npm run check; npm test | PASS, syntax and 14 API cases | harness-api-20260909.txt |
| Three offline/controlled Windows suites, separate invocations | PASS, 2 + 4 + 3 cases | harness-native-windows_workflow_test-20260909.txt; harness-native-independent_scenarios_test-20260909.txt; harness-native-persisted_scenarios_test-20260909.txt |
| scripts/test-online-windows.ps1 | PASS, 1 real API/SQLite case | harness-native-online-20260909.txt |
| flutter build windows --release | PASS | harness-build-windows-20260909.txt |
| flutter build web --release | PASS, normal main.dart restored | harness-build-web-20260909.txt |
| flutter build apk --release | NOT RUN, doctor confirms Android SDK absent | harness-doctor-20260909.txt |

Harness assertions cover load Retry, accessible validation, save failure, draft
preservation/retry, normalized search, pending/high/exact-tag AND filters, title
order, no-match and Clear/newest restoration. It uses only synthetic in-memory
data. The five-run series shares one browser session and warm host/cache; do not
generalize it as a population failure rate. See the experiment document.

Retained development failures: browser-harness-partial-20260909.txt (`URL` not
available in CLI evaluator); partial-rerun (semantics readiness); partial-focus
(duplicate live announcement); partial-validation (async ARIA update); partial-save
(asserted before rendered checkbox); dialog/dialog-rerun (raw ARIA whitespace and
duplicate notice). dialog-finalize PASSed all implemented checks before filter
selectors were added. Fixes use observable waits/current accessible roles, not
longer arbitrary sleeps or weaker product assertions.
The earlier browser-harness-orchestrated-20260909.txt PASS (8.578 s) preceded
final port-collision and restore-exit safeguards; the final script was rerun in
browser-harness-orchestrated-final-20260909.txt (PASS, 9.240 s).

Environment logs: harness-flutter-version-20260909.txt,
harness-dart-version-20260909.txt, harness-doctor-20260909.txt and
harness-devices-20260909.txt. Flutter/Dart remain outside PATH; Windows, Chrome
and Edge are available. Android SDK is absent. At that milestone totals were 55
Flutter, 14 API and 10 Windows cases; browser assertions are reported separately.

## Previous: safe samples, Edge and accessibility - 2026-09-08

Baseline source 62190d8 plus the preceding persisted-lifecycle and current sample
increments. Flutter 3.47.1 / Dart 3.13.1, Windows 11 10.0.26200.9168, Edge
152.0.4191.66, Node 22.14.0. Reproduction: ../web-edge-testing.md.

| Command/check | Result | Raw artifact in this directory |
|---|---|---|
| dart format --output=none --set-exit-if-changed . | PASS, 38 files unchanged | edge-format-20260908.txt |
| flutter analyze | PASS | edge-analyze-20260908.txt |
| flutter test --reporter expanded | PASS, 55 | edge-tests-20260908.txt |
| flutter test --coverage --reporter expanded | PASS, 55 including 8 unchanged goldens | edge-coverage-20260908.txt |
| cd backend; npm run check; npm test | PASS, syntax and 14 API cases | edge-api-20260908.txt |
| flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded | PASS, 2 | edge-native-windows_workflow_test-20260908.txt |
| flutter test integration_test/independent_scenarios_test.dart -d windows --reporter expanded | PASS, 4 | edge-native-independent_scenarios_test-20260908.txt |
| flutter test integration_test/persisted_scenarios_test.dart -d windows --reporter expanded | PASS, 3 | edge-native-persisted_scenarios_test-20260908.txt |
| scripts/test-online-windows.ps1 | PASS, 1 | edge-native-online-20260908.txt |
| flutter build windows --release | PASS | edge-build-windows-20260908.txt |
| flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8082 | PASS, isolated browser-test build | edge-test-build-20260908.txt |
| flutter build web --release | PASS, default API restored to 127.0.0.1:8080 | edge-build-web-20260908.txt |
| Edge online create/edit/complete/delete/undo and reload/re-login | PASS, observed real API/SQLite workflow | edge-server-check-20260908.txt; edge-online-restored-20260908.txt; edge-relogin-20260908.txt |
| Pinned CLI run-code scripts/browser/edge-sample-check.js | PASS, final keyboard/no-Tab version, then confirmation run | edge-sample-no-tab-20260908.txt; edge-sample-confirm-20260908.txt |
| Edge sample tag semantics | PASS, tags exposed as text, not checkboxes | edge-sample-semantics-20260908.txt |
| Android/APK | NOT RUN, missing SDK | None |
| Narrator/full focus order, clean-machine release/setup, CI and timing/stability study | NOT RUN | None |

Sample CLI assertions: visible created task, normalized search hides unrelated
seed, reset after re-entry, unchanged localStorage and no /v1/ requests. Six new
widget cases cover isolation and account accessibility. Edge snapshots/observed
keyboard focus are not proof of screen-reader support or complete WCAG compliance.
Native total remains 10, run in separate Flutter invocations. No goldens changed.

### Retained development failures and scope

- edge-a11y-initial-20260907.txt: initial six widget cases PASS.
- edge-a11y-final-20260907.txt: FAIL after adding tag-label assertion; label merged
  into parent semantics. Individual container semantics fixed it;
  edge-a11y-rerun-20260907.txt PASS. Assertions were not weakened.
- edge-format-20260907.txt / edge-analyze-20260907.txt: development formatting
  and curly-brace lint failures, corrected before the final full gates.
- edge-sample-20260907.txt / edge-sample-rerun-20260907.txt: earlier CLI input
  attempts FAIL; edge-sample-final-20260908.txt earlier version PASS once.
- edge-sample-result-20260908.txt: browser session unavailable after a pause,
  not an app failure. Reopened only the isolated test browser.
- edge-sample-result-rerun-20260908.txt and edge-sample-keyboard-20260908.txt:
  FAIL waiting for creation; DOM input had text while title validation remained
  empty. Final helper uses focused keyboard typing without immediately tabbing
  out. Both subsequent runs PASS; no definitive engine root cause or reliability
  percentage is claimed. Do not increase waits or remove visibility assertions.
- edge-test-build-20260907.txt: earlier successful test-config build, superseded
  by the 20260908 build. Existing native combined-run failure remains below.

Private browser traces/profile, synthetic DB and build products remain ignored.
Only reviewed screenshots with synthetic data may be copied into this directory.
Reviewed images: screenshots/edge-sample-phone-20260908.png (390x844),
screenshots/edge-sample-wide-20260908.png (1280x900),
screenshots/edge-online-restored-20260908.png and
screenshots/edge-login-keyboard-20260908.png. The last image contains only a
synthetic email and an empty password field; none includes tokens or recovery codes.

## Previous: independent persisted lifecycle - 2026-09-07

Baseline source: 62190d8; unchanged Flutter 3.47.1 / Dart 3.13.1 and Windows
10.0.26200.9168 after version/doctor/device recheck. Review and scope:
docs/project-review-20260907.md (repository-relative path).

| Command/check | Result | Raw artifact in this directory |
|---|---|---|
| flutter test integration_test/persisted_scenarios_test.dart -d windows --reporter expanded | PASS, 3 independent real-preference cases | persisted-native-20260907.txt |
| dart format --output=none --set-exit-if-changed . | PASS, 36 files unchanged | persisted-format-20260907.txt |
| flutter analyze | PASS, no issues | persisted-analyze-20260907.txt |
| flutter test --reporter expanded | PASS, 49 cases | persisted-tests-20260907.txt |
| flutter test --coverage --reporter expanded | PASS, 49 cases with unchanged 8 goldens | persisted-coverage-20260907.txt |
| cd backend; npm run check; npm test | PASS syntax and 14 API cases | persisted-api-20260907.txt (tests); syntax terminal output |
| Two native files in one invocation: windows_workflow_test.dart + independent_scenarios_test.dart | FAIL at second app launch after 2 first-suite cases pass | persisted-existing-native-20260907.txt |
| flutter test integration_test/independent_scenarios_test.dart -d windows --reporter expanded | PASS, 4 cases on separate invocation | persisted-independent-rerun-20260907.txt |
| flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded | PASS, 2 cases on separate invocation | persisted-storage-rerun-20260907.txt |
| scripts/test-online-windows.ps1 | PASS, 1 API/SQLite case | persisted-online-20260907.txt |
| flutter build windows --release | PASS | persisted-build-windows-20260907.txt |
| flutter build web --release | PASS | persisted-build-web-20260907.txt |
| Android/APK | NOT RUN, Android SDK missing | No artifact |
| Browser online E2E, physical IME, screen reader, clean-machine setup, CI/stability | NOT RUN | No claim |

Native coverage totals 10 cases across 4 files (5 native preferences, 4 fake,
1 real API). The failed combined invocation is retained, not rewritten as a pass;
its second suite passed separately with unchanged code. Use separate native suite
commands. Root cause of the runner's missing debug connection is not confirmed.
These counts are workflow coverage, not a reliability percentage. New tests clear
only three named test preference keys, never all settings or production task data.

## Latest: independent native E2E and publication gate - 2026-09-07

Flutter 3.47.1 / Dart 3.13.1, Windows 11 10.0.26200.9168, Node 22.14.0.
Doctor/devices rechecked: Windows/Chrome/Edge available (Edge 152.0.4191.66),
Android SDK missing. See independent-e2e.md for fixtures, mechanisms and limits.

| Command | Result | Raw artifact in this directory |
|---|---|---|
| flutter test integration_test/independent_scenarios_test.dart -d windows --reporter expanded | PASS, 4 independent controlled-repository native cases | independent-windows-first-20260907.txt |
| dart format --output=none --set-exit-if-changed . | PASS, 35 files unchanged | independent-format-20260907.txt |
| flutter analyze | PASS, no issues | independent-analyze-20260907.txt |
| flutter test --reporter expanded | PASS, 49 cases | independent-tests-20260907.txt |
| flutter test --coverage --reporter expanded | PASS, 49 cases including unchanged 8 goldens | independent-coverage-20260907.txt |
| cd backend; npm run check; npm test | PASS syntax and 14 HTTP/SQLite cases | independent-api-20260907.txt (test output); syntax in terminal |
| flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded | PASS, 2 real-preference workflows | independent-storage-20260907.txt |
| scripts/test-online-windows.ps1 | PASS, 1 real API/SQLite workflow | independent-online-20260907.txt |
| flutter build windows --release | PASS | independent-build-windows-20260907.txt |
| flutter build web --release | PASS | independent-build-web-20260907.txt |
| Android build/APK/runtime | NOT RUN, missing SDK | No artifact |
| Online browser E2E, physical resize, manual screen reader, clean-machine setup, CI, repeated-run stability | NOT RUN | No claim |

Native total is 7 across three suites, not 7 real-storage/network workflows.
The independent tests use logical viewport overrides and injected fake storage;
these are not another platform. All fixture accounts/data are synthetic and no
user database/preferences are reset. One run is not a flakiness experiment.

## Latest: account backend and Flutter integration - 2026-09-07

Environment: Flutter 3.47.1/Dart 3.13.1, Windows 11 10.0.26200.9168,
Node 22.14.0 / SQLite 3.47.2. Commands use the installed SDK bin/*.bat paths;
Node/npm are on PATH. API tests use only synthetic accounts and isolated databases.

| Check | Result | Artifact in this directory |
|---|---|---|
| cd backend; npm run check | PASS (JavaScript syntax) | backend-syntax-20260907.txt |
| cd backend; npm test | PASS, 14 real HTTP/SQLite tests | backend-api-20260907.txt |
| dart format --output=none --set-exit-if-changed . | PASS, 34 files unchanged | backend-format-20260907.txt |
| flutter analyze | PASS | backend-analyze-20260907.txt |
| flutter test | PASS, 49 tests | backend-flutter-plain-20260907.txt |
| flutter test --coverage | PASS, 49 tests including unchanged 8 goldens | backend-flutter-tests-20260907.txt |
| scripts/test-online-windows.ps1 | PASS, 1 real API + native Flutter workflow | backend-online-windows-20260907.txt |
| flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded | PASS, 2 offline workflows | backend-offline-windows-20260907.txt |
| flutter build web --release | PASS | backend-build-web-20260907.txt |
| flutter build windows --release | PASS | backend-build-windows-20260907.txt |
| Android/APK | NOT RUN, Android SDK missing | No artifact claimed |
| Public deployment, browser online E2E, manual screen reader/IME, load/security audit | NOT RUN | Outside this local verification |

Backend tests cover actual auth/task endpoints, isolation, validation, token
rotation/replay/revocation, recovery-code consumption, transaction conflicts,
restart persistence and backup. Windows online flow registers an account, stores
a task, reads it through another session, verifies another account cannot see it,
rejects a stale writer, logs out/in and verifies persistence. Its helper retains
synthetic database/server logs under ignored build/ for diagnosis, never production
data. Flutter tests retain offline baseline checks; no golden was regenerated.

Source and test result scope are documented in backend/README.md and
docs/architecture/backend.md (paths relative to root). These are functional local
results, not a security certification or availability benchmark. No real user
credentials, tokens or database files are included in these evidence artifacts.

Local Windows distribution: `build/TaskFlow-Windows-x64-backend-20260907.zip`
(ignored; 12,348,198 bytes, 17 ZIP entries). Includes the complete Release
directory, not only the executable. SHA-256:
`72107aea592a66ced34738cf8ed81fe6e81400f6639b69663ea1749e40264823`.
The API runs separately using scripts/run-backend.ps1; it is not bundled into
the Windows ZIP. The ZIP contents were inspected; clean-machine installation
has not been verified.

## Latest: visual/accessibility/defect milestone - 2026-09-06

Commands ran from D:/flutter with Flutter 3.47.1 and Dart 3.13.1, using the
explicit SDK bin/*.bat paths because they are not on PATH. Environment details:
[environment.md](../environment.md). Earlier sections below are historical.

| Command/check | Result | Raw artifact relative to this folder |
|---|---|---|
| dart format --output=none --set-exit-if-changed . | PASS, 25 files unchanged | quality-format-20260906.txt |
| flutter analyze | PASS, no issues | quality-analyze-20260906.txt |
| flutter test --reporter expanded | PASS, 39 cases | quality-tests-plain-20260906.txt |
| flutter test --coverage --reporter expanded | PASS, 39 cases | quality-tests-20260906.txt; local ignored coverage/lcov.info |
| flutter test test/golden --update-goldens --reporter expanded | PASS, 8 initial baselines generated and reviewed | golden-generation-20260906.txt |
| Golden comparison without updates | PASS, 8 cases included in both full runs | quality-tests-plain-20260906.txt; quality-tests-20260906.txt |
| flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded | PASS, 2 native workflows | quality-windows-20260906.txt |
| flutter build windows --release | PASS | quality-build-windows-20260906.txt |
| flutter build web --release | PASS | quality-build-web-20260906.txt |
| Search mutation baseline / defect / fix | PASS / expected FAIL / PASS | intentional_defect/baseline.txt, fail.txt, pass.txt |
| Android E2E / flutter build apk --release | NOT RUN, missing Android SDK | environment.md; obtain user approval before installing tools |
| Browser E2E, clean-machine release launch, manual accessibility | NOT RUN in this milestone | Next work, not inferred from successful builds |

Defect hypothesis, root cause, limitations, exact command and patches:
[intentional_defect/README.md](intentional_defect/README.md),
[buggy.patch](intentional_defect/buggy.patch), [fix.patch](intentional_defect/fix.patch).
Patch applicability was checked using git apply --check and the inverse check.

Eight PNGs live in `test/golden/baselines/` relative to repository root:
`phone-empty.png`, `phone-populated.png`, `phone-validation.png`, `phone-error.png`,
`wide-empty.png`, `wide-populated.png`, `wide-validation.png`, `wide-error.png`.
All were visually reviewed; see [golden-testing.md](../golden-testing.md) for
configuration, font licence/provenance and update policy. They are rendered test
images, not screenshots of an Android device or a Windows release app.

`accessibility-development-fail-20260906.txt` preserves the initial development
run: genuine contrast failure plus test-fixture mistakes. Subsequent final runs
pass after error-style and fixture corrections; this is separate from the deliberate
search-defect experiment. No assertion or contrast threshold was weakened.

The Windows Release directory and `build/TaskFlow-Windows-x64.zip` were rebuilt
locally and remain ignored. The native integration run launched current code in
debug mode; this milestone does not claim a fresh-machine release smoke test.
Coverage was collected, but no coverage percentage or stability claim is inferred
from the count of passing tests. CI/report/video are still incomplete.

Publication status: local implementation commit `9466681` succeeded; push to
`main/test` was REJECTED because the migrated remote already contains `main`.
Read-only remote inspection found only main at `2f5983614f37c44b2cd298f89db6657eb11bdbc1`,
whose source tree matches the previous metadata milestone. No remote branch was
deleted or overwritten. This historical naming blocker was resolved on 2026-09-06:
with user approval of a name without an agent-name prefix, the local branch was
renamed to `main-test` and successfully pushed, including commits `9466681` and
`286c69e`. Its upstream is `origin/main-test`; remote main remains unchanged.
Only branch/configuration and documentation changed during publication; the app
and tests are unchanged from the quality-gate runs above, which were not repeated.

## Historical bootstrap verification - 2026-09-05

Observed local results with Flutter 3.47.1:

| Check | Result |
|---|---|
| flutter analyze | PASS - no issues |
| flutter test --coverage | PASS - 7 tests |
| flutter build web --release | PASS - build/web |
| Windows release build and launch | PASS on development machine |
| Windows integration workflow | PASS - 1 test, windows-integration.txt |
| Android build/device E2E | NOT RUN - missing toolchain |
| Golden tests, CI, defect experiment | NOT RUN - future milestones |

This is a summary of observed tool output, not fabricated raw logs or full
submission evidence. See environment.md and the test source for reproduction.

Historical Windows executable SHA256 (2026-09-05 bootstrap):
`E1CC3ED8CCB76BB623C9224DF582F30AE937C97D184E982F188A3E31EABB87BB`.
Build: `flutter build windows --release` (Flutter 3.47.1).
Test: `flutter test integration_test/windows_workflow_test.dart -d windows`.
The native test uses a dedicated preference key and removes it after testing.

## CRUD milestone - 2026-09-06

| Check | Result | Evidence |
|---|---|---|
| Format / analyze | PASS | Local command output, Flutter 3.47.1 |
| Unit/widget with coverage | PASS - 15 tests | crud-tests-20260906.txt |
| Windows integration | PASS - 1 extended workflow | windows-crud-20260906.txt |
| Web release build | PASS | build/web (ignored output) |
| Windows release build | PASS | build/windows/x64/runner/Release (ignored output) |

Workflow: create, rename, complete, confirm delete, undo and remount with real
local storage. Windows ZIP rebuilt locally; binaries are not committed.
Remaining coursework evidence includes golden baselines, broader E2E scenarios,
accessibility review, controlled defect experiment and repeated-run analysis.

## Metadata and filters - 2026-09-06

- 24 unit/widget tests: metadata-tests-20260906.txt.
- 2 Windows workflows: windows-metadata-pass-20260906.txt.
- First Windows attempt: windows-metadata-20260906.txt (FAIL).
- Diagnostic scroll attempt: windows-metadata-debug-20260906.txt (FAIL).
- Root cause investigation: injected replacement date remained the old invalid
  value on Windows, and a text finder mistook form input for a saved task. Registering
  the test text-input channel resolved this interaction; the integration binding
  defaults to not registering it (verified in installed Flutter SDK source).
- Helpers now verify the actual editable value and identify a saved task inside
  CheckboxListTile, scroll deliberately and use bounded scrolling for lazy content.
- These are real debugging records, not the planned intentional product-defect
  experiment. Native rendering/storage are real; native IME itself is excluded.
- Final format/analyze, Web release build and Windows release build PASS with
  Flutter 3.47.1. Local Windows ZIP refreshed; generated artifacts remain ignored.
