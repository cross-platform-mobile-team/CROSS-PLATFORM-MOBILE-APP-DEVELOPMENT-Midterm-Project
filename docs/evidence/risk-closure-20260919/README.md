# Risk closure evidence

Source baseline: 06d3790deb6b5b1376311e102b15b968b2b51baf plus the local
snapshot-budget, regression-test and CI changes of 19 September 2026.
These outputs were collected before publication. On 20 September the user
authorized pre-push verification and publication to main-test. Hosted success
must be checked separately against the resulting commit.

20 September pre-push rerun: format (0 changes), analyze (no issues), Flutter
coverage suite (104 PASS), API suite (17 PASS), helper syntax and all three
SDK/resolver/backend-CI synthetic contracts PASS. Fresh outputs use the
prepush-20260920 prefix. No golden baselines were regenerated.
An optional Python YAML-parser check could not run because PyYAML is absent;
no package was installed. Hosted workflow acceptance remains a separate gate.

| Command or selection | Log | Result |
| --- | --- | --- |
| node --test --test-name-pattern='maximum snapshot' backend/test/api.test.js before fix | snapshot-before.txt | Expected regression FAIL: 413 instead of 200 |
| node --test backend/test/api.test.js after fix | backend-after.txt | 17 PASS |
| flutter test --coverage --reporter expanded | flutter.txt | 104 PASS |
| dart format --output=none --set-exit-if-changed . | format.txt | PASS |
| flutter analyze | analyze.txt | PASS |
| flutter test integration_test/pending_capture_test.dart -d windows --reporter expanded | windows-pending.txt | 4 PASS |
| flutter test integration_test/independent_scenarios_test.dart -d windows --reporter expanded | windows-independent_scenarios.txt | 4 PASS |
| flutter test integration_test/persisted_scenarios_test.dart -d windows --reporter expanded | windows-persisted_scenarios.txt | 3 PASS |
| flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded | windows-windows_workflow.txt | 2 PASS |
| flutter test integration_test/quick_create_exit_test.dart -d windows --reporter expanded | windows-quick_create_exit.txt | 1 PASS |
| ./scripts/test-online-windows.ps1 | windows-online.txt | 1 PASS with isolated SQLite |
| ./scripts/test-online-windows.ps1 -TargetDevice emulator-5554 -ApiHost 10.0.2.2 | android-online.txt | 1 PASS on API 36; debug build/install also PASS |
| scripts/tests/backend-ci-contract.ps1 | ci-contract.txt | Synthetic PASS |
| scripts/tests/android-environment-contract.ps1 | android-env-contract.txt | Synthetic PASS |
| scripts/tests/flutter-resolver-contract.ps1 | flutter-resolver-contract.txt | Synthetic PASS |
| flutter/dart versions, doctor -v, devices | environment.txt | Recorded; doctor warnings retained |
| flutter build windows --release | build-windows.txt | PASS |
| flutter build web --release | build-web.txt | PASS; not a new browser interaction run |
| flutter build apk --release | build-apk.txt | PASS; normal pub refresh after native tests |

Flutter commands use C:/Users/LENOVO/flutter-sdk/bin/*.bat after dot-sourcing
scripts/use-android-d.ps1. Native selections run separately and clear only their
own test preference keys. API tests use temporary/in-memory stores, never a
production account. The before-fix diagnostic is preserved unchanged.

The Linux online orchestration helper has a syntax check, but cannot be run as a
Linux emulator workflow on this Windows host. Hosted CI remains NOT RUN.
Packaged Word rendering failed because bundled LibreOffice is absent; the
Word COM PDF export and PDFium fallback are documented in docs/report/QA.md.
