# Bootstrap verification - 2026-09-05

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
