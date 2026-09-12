# Environment

Package A recheck 2026-09-12: version, doctor and devices confirm Flutter 3.47.1
(6655482ec0), Dart 3.13.1, Windows 10.0.26200.9445, VS Build Tools 17.14.39,
Chrome 149.0.7827.201 and Edge 152.0.4191.66. Android SDK remains absent;
Flutter/Dart remain outside PATH. Use C:/Users/LENOVO/flutter-sdk/bin/*.bat.
No installation or SDK upgrade performed. Current evidence index:
[current-verified-state.md](current-verified-state.md).

2026-09-12 bug audit: Flutter/Dart version, doctor and device list rechecked;
raw output: evidence/bug-audit-20260912/environment.txt. Windows 10.0.26200.9445,
Flutter 3.47.1 / Dart 3.13.1, Edge 152.0.4191.66. Android SDK absent; no installs.

UI refresh host rechecked 2026-09-11: Flutter 3.47.1 / Dart 3.13.1, Windows
10.0.26200.9168, VS Build Tools 2022 17.14.39 and Edge 152.0.4191.66 remain the
same. Android SDK is absent locally; no upgrades/installations performed.

## Current continuation host - 2026-09-10

Version, doctor and devices rechecked for dedicated loading-widget tests:
the Flutter 3.47.1/Dart 3.13.1, Windows/Edge/Chrome and missing local Android SDK
status below are unchanged. No toolchain installation or modification.

Checkout D:/flutter uses Flutter 3.47.1/Dart 3.13.1 at
C:/Users/LENOVO/flutter-sdk. Windows, Edge and Chrome are available; no Android
SDK exists on this host. The exact version/doctor/device recheck is recorded in
the dated entry below. Upstream commits through ef45561 from the other host were
retained, including Dart 3.13.0 compatibility and successful Android CI evidence.

## Other development host - 2026-09-09

- Windows 11 `10.0.26200.9168`; Flutter 3.47.0 (`4cf2416426`), Dart 3.13.0
  and DevTools 2.60.0 at `C:\Users\Nguyen Long\develop\flutter`.
- Android SDK `C:\Android\sdk`, build-tools 36.0.0, platform 37.0, emulator
  37.1.11, NDK `28.2.13676358`, and Temurin JDK 17.0.20.1.
- Google APIs Android 16/API 36 x86_64 AVD `taskflow_api36` was detected as
  `emulator-5554`; WHPX `10.0.26200` is installed and usable.
- `flutter doctor -v` passed every category except Android license status, which
  remains unknown. No license acceptance is claimed.
- Local source gates passed with this Flutter SDK: format (40 files unchanged),
  analyze, 57 Flutter tests including 8 unchanged goldens, 14 Node tests, 10
  Windows native workflows, and Web/Windows release builds.
- Gradle launched from the Codex command sandbox cannot establish its required
  Java loopback connection (`SocketException: Invalid argument: connect`), so no
  completed local APK/E2E result is claimed. This is recorded as a host-execution
  boundary, not an application failure.
- GitHub Actions run
  [#2](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886)
  independently passed Windows gates, debug/release APK builds, checksum upload,
  and 9 Android workflows on an API 36 hosted emulator.

## Historical verified environments

The dated entries below remain accurate for the machines and milestones where
they were recorded. Their statements that Android SDK was missing do not describe
every host. The September 10 D:/flutter host still lacks the Android SDK.

### Environment rechecked 2026-09-07

Rechecked 2026-09-10 for fresh Edge-session automation: `flutter --version`,
`dart --version`, `flutter doctor -v` and `flutter devices` report Flutter 3.47.1
(6655482ec0 / engine 5d53178869), Dart 3.13.1, DevTools 2.60.0, Windows
10.0.26200.9168, VS Build Tools 2022 17.14.39, Windows SDK 10.0.26100.0,
Chrome 149.0.7827.201 and Edge 152.0.4191.66. Android SDK remains absent;
Flutter/Dart remain outside PATH. No SDK or global tool installation performed.

Rechecked again for the test-level repetition/publication increment on 2026-09-09:
Flutter/Dart version, doctor and devices match the account-settings gate below.
No toolchain changes; the experiment reuses warm SDK/build caches on this host.

Rechecked 2026-09-09 before the account-settings accessibility increment:
Flutter 3.47.1 (framework 6655482ec0, engine 5d53178869), Dart 3.13.1 and
DevTools 2.60.0. Windows 11 10.0.26200.9168, Chrome 149.0.7827.201 and Edge
152.0.4191.66 remain discoverable. Visual Studio Build Tools 2022 17.14.39 and
Windows SDK 10.0.26100.0 remain ready. Flutter/Dart are still outside PATH and
Android SDK is still absent; no SDK/tool was installed or modified.

Rechecked 2026-09-09 before the browser-harness increment: versions and devices
are unchanged (Flutter 3.47.1, Dart 3.13.1, Windows/Chrome/Edge available,
Android SDK absent, Flutter/Dart still outside PATH). A direct attempt to run the
independent integration suite on Edge was rejected by Flutter with "Web devices
are not supported for integration tests yet"; this motivates the gated Web QA
harness and is not recorded as an application test failure.

Edge/sample gate executed 2026-09-08 using this same installed SDK/toolchain.
Browser automation used Edge 152.0.4191.66 with an isolated temporary profile,
Playwright CLI 0.1.19 via npx (no global install), a loopback Web server on 7358
and isolated Node/SQLite API on 8082. Default app API remains 8080. See
web-edge-testing.md for setup and evidence/manifest.md for exact gate results.

Rechecked again for the persisted-lifecycle increment: Flutter/Dart, doctor and
devices unchanged from the values below; Windows toolchain ready, Android absent.

Backend increment (2026-09-06/07): PATH Node.js 22.14.0,
built-in SQLite 3.47.2; optional bundled Node 24.19.0 available, not globally
installed by this task. `node:sqlite` emits its experimental warning on Node 22.
Flutter/Dart version, doctor and devices were rechecked before implementation;
the versions and Android limitation below remain unchanged. Dart http resolved
to 1.6.0 through pub; no backend npm production dependencies.

- Windows 11 Home Single Language, 10.0.26200.9168.
- Flutter 3.47.1 stable (6655482ec0), Dart 3.13.1.
- SDK: C:/Users/LENOVO/flutter-sdk, not on PATH.
- Chrome 149.0.7827.201; Edge 152.0.4191.66 (doctor/devices rechecked 2026-09-07).
- Android SDK missing; Android build/device tests NOT RUN.
- Visual Studio Build Tools 2022 17.14.39 installed at D:/VSBuildTools2022;
  C++ workload, CMake and Windows SDK 10.0.26100 available. Doctor PASS for Windows.
  Windows release build and native integration test PASS.
- Git initially had an invalid unborn HEAD and incorrect flutter/flutter remote.

Recheck using flutter doctor -v and flutter devices on each test machine.

Latest recheck used the SDK's explicit bin/flutter.bat and bin/dart.bat paths:
version commands, doctor -v and devices. Engine revision: 5d53178869;
DevTools 2.60.0. Doctor still reports PATH warnings and missing Android SDK.
Golden rendering parameters and font sources are recorded in golden-testing.md;
the host's vi-VN locale is overridden to en-US in visual fixtures.
Color-studio continuation recheck: Windows 10.0.26200.9445; Flutter 3.47.1,
Dart 3.13.1, VS Build Tools 17.14.39, Edge 152.0.4191.66, Chrome
149.0.7827.201. Android SDK still absent. SDK remains outside PATH.
