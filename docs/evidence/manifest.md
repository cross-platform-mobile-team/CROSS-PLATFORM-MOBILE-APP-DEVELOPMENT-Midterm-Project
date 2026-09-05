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

Windows executable SHA256:
`E1CC3ED8CCB76BB623C9224DF582F30AE937C97D184E982F188A3E31EABB87BB`.
Build: `flutter build windows --release` (Flutter 3.47.1).
Test: `flutter test integration_test/windows_workflow_test.dart -d windows`.
The native test uses a dedicated preference key and removes it after testing.
