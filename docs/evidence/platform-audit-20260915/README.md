# Android continuation — 15 September 2026

Source: d0b145d plus the platform-audit changes. Publication was subsequently
authorized during the 15 September review; see ../../project-progress-20260915.md.
Earlier logs under ../platform-audit-20260914/ remain historical and unchanged.

## Release verification

- android-release.txt: FAIL, stale GeneratedPluginRegistrant referenced the
  integration_test plugin in a release build after --no-pub.
- android-release-refresh.txt: PASS, flutter build apk --release regenerated
  the release registry correctly. Kotlin cache recovery also passed this build.
- android-install.txt: PASS after waiting for sys.boot_completed=1. An earlier
  immediate install attempt before boot completion reported missing package
  service; it was not an application failure or successful installation.
- android-launch.txt: PASS, adb am start -W reports Status: ok, cold launch.
- android-process-restart.txt and android-release-persisted.png: created
  Android-release-check using Android input events, force-stopped the package,
  launched it again, entered offline mode and visually verified the same task.
  This is a process restart, not an OS reboot or a physical-device test.
- android-release-entry.png: inspected release account-entry layout.
- apk-metadata.txt: application ID com.taskflow.taskflow_qa_lab, name TaskFlow,
  version 1.0.0+1, min API 24, target API 36.

Release APK: build/app/outputs/flutter-apk/app-release.apk, 53,112,106 bytes.
SHA256: 9f1a3c1743980f6f3d67176f4592023d35ec093f62fb09d0573a79b5b5b89e88.
It uses the existing coursework debug signing key, not production signing.
No HTTPS backend or physical-device online-mode claim is made.

## Execution environment

Google APIs Android 16/API 36 x86_64, emulator 37.1.11, WHPX, SwiftShader,
720x1280 at density 240, 2048 MB guest RAM, 2 cores. The same D: AVD was reused.
The emulator was stopped during the memory-heavy release build and restarted
for install/run. SDK, AVD, Gradle cache and Pub cache are under D:/Android.
Only the generated Kotlin plugin cache was moved aside; no task data was erased.

## Automated Android integration

Each suite ran in its own Flutter invocation with -d emulator-5554 and
--reporter expanded (normal dependency refresh, no --no-pub):

| Suite | Cases | Result |
| --- | ---: | --- |
| independent_scenarios_test | 4 | PASS |
| persisted_scenarios_test | 3 | PASS |
| windows_workflow_test (historical filename) | 2 | PASS |
| quick_create_exit_test | 1 | PASS |
| pending_capture_test | 4 | PASS |
| online_workflow_test | 1 | PASS |

The files named android-<suite>.txt contain raw build/install/test outputs.
Controlled viewport overrides do not imply physical rotation or IME testing.
Tests clear only their dedicated preferences; the manual release task remains
outside those test keys. android-online.txt records the real API/SQLite test
using test-online-windows.ps1 -TargetDevice emulator-5554 -ApiHost 10.0.2.2.
The helper created an isolated database and stopped its own server afterward.
The debug-only HTTP configuration was exercised; this is not release HTTPS
or physical-device online evidence. Total Android native executions: 15 PASS.
The release APK was restored afterward (android-release-restore.txt), then the
emulator and the dedicated Gradle daemon were stopped to release host memory.
iOS remains NOT RUN on this Windows host; see ../../ios-validation.md.

## Final source gates

- flutter test --coverage --reporter expanded: PASS, 100 cases (flutter-final.txt).
- flutter analyze: PASS (analyze-final.txt).
- dart format --output=none --set-exit-if-changed .: PASS (format-all.txt).
- node --test backend/test/*.test.js: PASS, 14 cases (backend-final.txt).
- No golden baselines or dependency versions were changed.
- environment.txt records the post-test host check; emulator is absent there
  because it was deliberately stopped after testing. Flutter doctor still
  reports PATH and SDK 23 license-status warnings; no iOS toolchain is available.
- Windows results remain the 15-case execution and release-build record from
  14 September, not relabelled as today's new execution.
