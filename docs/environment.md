# Environment rechecked 2026-09-06

- Windows 11 Home Single Language, 10.0.26200.9168.
- Flutter 3.47.1 stable (6655482ec0), Dart 3.13.1.
- SDK: C:/Users/LENOVO/flutter-sdk, not on PATH.
- Chrome 149.0.7827.201; Edge 152.0.4191.62.
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
