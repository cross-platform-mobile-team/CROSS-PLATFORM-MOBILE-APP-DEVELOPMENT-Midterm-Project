# Automation audit — 22 September 2026

Baseline b4479e3 plus reviewed local color/motion UI and this audit's changes.
Publication authorized by the user. Final status is recorded below; incomplete
or failing attempts are retained, not counted as passes.

## Regression found through real Edge automation

MotionSurface's decorative Focus added a semantics node that merged heading
and error text into one accessible group. Edge's unchanged error-text assertion
failed in four repetitions (edge.txt). A new widget regression reproduced the
merged label (semantics-before.txt). `includeSemantics: false` keeps focus
observation while preserving descendant semantics. The repaired widget suite
passes (motion-final.txt, six tests).

The first fixed test run also revealed a test-resource cleanup error: the
SemanticsHandle must be disposed before end-of-test verification, not through
addTearDown. motion-fixed.txt retains that failure; motion-final.txt fixes it.

Edge then exposed a stale exact-label locator: Flutter's focused title input
has raw aria-label `Task title\nWhat needs to get done?`, normalized to spaces
by Playwright. The runner now accepts the two exact observed accessible names,
and still verifies the raw first-line label, aria-invalid, exact validation
description, draft value and final task set. edge-final.txt retains those
intermediate failures; it is NOT the final successful run despite its name.

## Source checks

- flutter-final.txt: `flutter test --coverage --reporter expanded`, 110 PASS,
  including 15 unchanged reviewed goldens from the color/motion increment.
- backend.txt: `node --test --test-concurrency=1` in backend, 17 PASS.
- *-contract scripts: edge-runner.txt, android-environment.txt,
  flutter-resolver.txt, backend-ci.txt. Synthetic runner checks, not app E2E.
- environment.txt: Flutter/Dart versions, doctor and devices before emulator
  startup. Existing warnings remain; no SDK installation or upgrade performed.

## Interrupted native attempts

windows-independent_scenarios.txt stopped advancing after two cases during
concurrent local checks and was interrupted; cause is not established. A fresh
90-second-bounded invocation passed four cases in its -final.txt output.
Android's initial windows_workflow suite lost emulator-5554 during execution;
its log is an incomplete failure, not a product assertion failure or PASS.

## 23 September continuation

The order failure persisted with an exact bounded wait and confirmed dropdown
selection, ruling out the initial timing hypothesis. A real Edge screenshot
showed Alpha before Beta, while the semantics snapshot still placed Beta before
Alpha at stale positions. Task cards now retain their identity but have explicit
semantics containers and ordinal traversal keys. No business sorting rule or
expected ordering was relaxed. The initial edit missed the semantics import;
flutter-semantics-order.txt retains that compile failure. With the import fixed,
flutter-order-fixed.txt passes 110 cases without golden updates.
edge-visible-order-before.png shows the synthetic Alpha task visually first;
edge-order-diagnostic.txt and edge-observable-order.txt record the stale Beta
accessibility order. Final Edge verification uses fresh browser sessions.

Windows Application Error events confirm headless QEMU crashes (0xc0000005),
not TaskFlow assertions: emulator-crashes.txt. A software-renderer retry also
lost the device. These are failed infrastructure runs, not passing Android
evidence; the successful host-renderer results are listed below.

## Verified post-fix gates

- Flutter: 110 PASS in flutter-order-fixed.txt; 15 golden images unchanged.
- Edge: 4/4 PASS in two fresh sessions, edge-order-fixed.txt and
  edge-session-{1,2}-{results.json,run-1.txt,run-2.txt}. Each run verifies load
  retry, invalid form semantics, save failure/draft preservation, successful
  retry, normalized search, combined filters, exact ordering and clear/reset.
  Use `scripts/test-edge-harness.ps1 -Flutter <flutter.bat> -Sessions 2
  -Repetitions 2`. This is a finite same-host experiment, not a reliability rate.
- Backend: 17 PASS; runner contracts PASS (see source checks above).
- Format/analyze: PASS in format-order-fixed.txt and analyze-order-fixed.txt.
- Windows: 15 PASS in windows-*-order-fixed.txt across five isolated offline
  suites (4+3+2+1+4) plus one real API/SQLite suite. Commands use separate
  `flutter test integration_test/<suite>_test.dart -d windows --timeout 90s
  --reporter expanded` invocations and scripts/test-online-windows.ps1.
- Android API 36: 15 PASS across the five android-*-host.txt suites (4+3+2+1+4)
  and android-online-host.txt (1 real API/SQLite workflow). The successful
  emulator invocation used `-gpu host -cores 2 -memory 1536 -no-snapshot` without
  `-no-window`; headless attempts remain failed as documented above. The AVD
  was stopped after verification. These are emulator, not physical-device tests.

The first post-E2E APK build failed on a generated registrant still referring
to integration_test (build-apk.txt). This is retained; a separate release build
after native runners finish must pass before release acceptance. Do not delete
the whole build folder or manually patch GeneratedPluginRegistrant.java.
The 23 September build-apk-final.txt attempt has no completion output and is
not counted as PASS. The 24 September continuation uses fresh pub resolution
and build-apk-20260924.txt, preserving the earlier outputs.

Windows release PASS: build-windows-order-fixed.txt. Web release PASS: final
default-app restoration in edge-order-fixed.txt (not the test-harness bundle).

24 September release gate: APK PASS in build-apk-20260924.txt after fresh
dependency resolution (release-pub-get-20260924.txt), exit 0, 50.7 MB. SHA256 is
recorded in apk-checksum-20260924.txt. No source or dependency version change
was required. All three release builds now pass for the corrected source.

## Limits

Passing these finite scenarios cannot establish universal bug freedom. iOS is
NOT RUN without macOS/Xcode. Physical-device, manual screen-reader, clean-host
setup and frame-time profiling are not inferred from these checks. Reports and
video were not modified. New hosted CI must be checked against the pushed SHA.
