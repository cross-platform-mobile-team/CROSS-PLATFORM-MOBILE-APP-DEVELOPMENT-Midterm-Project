# Environment rechecked 2026-09-07

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
