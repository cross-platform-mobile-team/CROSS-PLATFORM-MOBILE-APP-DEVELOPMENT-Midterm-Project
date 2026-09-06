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
