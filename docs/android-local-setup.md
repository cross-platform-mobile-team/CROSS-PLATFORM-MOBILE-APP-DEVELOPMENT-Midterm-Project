# Android on the D: drive

This host uses Flutter 3.47.1, an existing JDK 21.0.3, and the following paths:

- D:/Android/sdk — SDK, build-tools 36.0.0, platform 36, NDK 28.2.13676358,
  emulator 37.1.11 and Google APIs x86_64 API 36 revision 7.
- D:/Android/avd/taskflow_api36.avd — emulator data.
- D:/Android/gradle — Gradle downloads and cache.
- D:/Android/pub-cache — Dart packages, on the same drive as the project to
  avoid Kotlin's cross-drive incremental-cache failure.
- D:/Android/downloads — original downloaded archives.

Flutter's SDK/JDK locations were configured for this host. To reuse the AVD and
keep Gradle data on D:, dot-source the helper in each new PowerShell session:

```powershell
. ./scripts/use-android-d.ps1
& C:/Users/LENOVO/flutter-sdk/bin/flutter.bat pub get --enforce-lockfile
& D:/Android/sdk/emulator/emulator.exe -avd taskflow_api36 -gpu swiftshader -no-snapshot
& C:/Users/LENOVO/flutter-sdk/bin/flutter.bat devices
& C:/Users/LENOVO/flutter-sdk/bin/flutter.bat run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

The last command's account mode requires `./scripts/run-backend.ps1` in another
terminal. Offline and sample modes do not require a backend. 10.0.2.2 is the
Android emulator's alias for host loopback; a physical phone needs a reachable
HTTPS API origin. No public backend is provided.

The debug manifest permits cleartext only to 10.0.2.2, localhost and 127.0.0.1.
No cleartext exception is added to release. Use an HTTPS endpoint for release
account testing. APKs use the existing coursework debug signing configuration,
not a production distribution key.

Isolated online test (synthetic accounts, disposable database):

```powershell
. ./scripts/use-android-d.ps1
./scripts/test-online-windows.ps1 -TargetDevice emulator-5554 -ApiHost 10.0.2.2
```

The helper's filename is historical; Windows remains its default. It binds the
test server only to host loopback and stops only its own server process.

## Toolchain findings

Google's current download was command-line tools 22.0, archive 15859902. SHA256:
90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a.
SDK Manager then installed latest 23.0, whose Windows compatibility wrapper
split the NDK package identifier during Flutter's automatic installation.
The retained 22.0 bootstrap tool installed the required NDK explicitly:

```powershell
. ./scripts/use-android-d.ps1
& D:/Android/sdk/cmdline-tools/bootstrap/cmdline-tools/bin/sdkmanager.bat --sdk_root=D:/Android/sdk 'ndk;28.2.13676358'
```

Android image SHA1 was verified against Google's repository metadata:
c6bf44bdcd885bb902b4ba752d111a073ad7a817. SDK licenses were accepted using
the bootstrap manager; the newer wrapper reports --licenses is no longer needed,
so Flutter doctor's unknown-license warning is not a test result.

See platform-audit-20260914.md for actual PASS/FAIL/NOT RUN results.

After changing PUB_CACHE from C: to D:, stale plugin Kotlin incremental caches
must be retired with the build stopped. The 15 September recovery moved only
build/shared_preferences_android/kotlin to an ignored backup, rather than
clearing all build/report artifacts. Keep Android builds and test invocations
sequential. After switching from integration testing to release, use
`flutter build apk --release` (without --no-pub) so Flutter regenerates the
release plugin registrant and excludes integration_test. A stale registrant
caused a genuine compile failure with --no-pub; the normal build passed.

On this 16 GB host, D:/Android/gradle/gradle.properties limits Gradle to a 3 GB
heap and two workers. The first heavy build ran with the emulator stopped;
this is a local resource setting, not a measured app performance improvement.
Sources (accessed 2026-09-14):
https://developer.android.com/studio
https://developer.android.com/studio/run/emulator-networking
https://developer.android.com/privacy-and-security/security-config
