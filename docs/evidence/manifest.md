# Evidence manifest

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
