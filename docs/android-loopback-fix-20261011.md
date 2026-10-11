# Android build: Windows Java loopback workaround (2026-10-11)

Agent-assisted engineering record for review. This follows the UI/UX audit and preserves its source changes.

## Diagnosis and scoped fix

An independent Java probe fails at `Selector.open()` on this host with `PipeImpl` / `UnixDomainSockets.connect0` and `Invalid argument: connect`. This reproduces outside Gradle. Changing installed JDK versions or shortening a real socket directory did not fix the failure.

The installed OpenJDK 17 source and [upstream PipeImpl](https://raw.githubusercontent.com/openjdk/jdk17u/master/src/java.base/windows/classes/sun/nio/ch/PipeImpl.java) (accessed 2026-10-11) show that listener bind failure falls back from Unix-domain sockets to TCP loopback. A failure at connect happens after that fallback boundary. This explains why the original connect error prevents the fallback. It does not identify the underlying Windows/driver cause.

`scripts/with-java-tcp-fallback.ps1` sets `jdk.net.unixdomain.tmpdir` to an explicit file sentinel under ignored `build/`, causing the listener bind to fail and use the JDK's existing TCP path. It runs only the supplied command and child processes with the option, restores the prior `JAVA_TOOL_OPTIONS` in `finally`, and propagates the command exit code. It also disables Gradle's automatic SDK component downloads. This is a host workaround, not an application-code change or a general replacement for Unix-domain sockets. Reassess it after a JDK/Windows upgrade. Do not set it globally for unrelated Java applications requiring Unix-domain sockets.

From the repository root:

```powershell
& ./scripts/with-java-tcp-fallback.ps1 { flutter build apk --release }
& ./scripts/with-java-tcp-fallback.ps1 { flutter drive --driver=test_driver/native_driver.dart --target=integration_test/windows_workflow_test.dart -d emulator-5554 --debug --no-dds --no-pub }
```

Reproduce the low-level probe using the installed JDK:

```powershell
& "$env:JAVA_HOME/bin/java.exe" scripts/diagnostics/JavaLoopbackProbe.java
& ./scripts/with-java-tcp-fallback.ps1 { & "$env:JAVA_HOME/bin/java.exe" scripts/diagnostics/JavaLoopbackProbe.java }
```

Release builds should run with the normal dependency refresh after integration tests; `--no-pub` can retain an integration-test registrant and fail Java compilation. The first completed post-loopback attempt exposed that separate issue; its failed log is retained.

## Side effects and preserved failures

The first APK attempt with the TCP workaround passed daemon connection, then Android Gradle Plugin automatically began installing Platform 36 revision 2 using an already accepted license. It extracted platform files before the task daemon was deliberately stopped. The `daemon disappeared` result from this attempt is an intentional interruption, not recurrence of the loopback error. Subsequent runs disable `android.builder.sdkDownload` and use files present on disk. No firewall, system networking, global environment, or JDK installation was changed. Prior failed logs are preserved.

The existing API 36 AVD is launched with `-read-only -no-snapshot-save -no-window -no-audio -gpu swiftshader`; emulator writes are disposable. TalkBack 16.0 is installed. iOS requires a Mac/Xcode host and remains outside this Windows verification.

## Verification

- Release APK build PASS: `flutter build apk --release` through the wrapper, 108.0 seconds reported by Flutter. Artifact: `build/app/outputs/flutter-apk/app-release.apk`, 53,308,746 bytes, SHA-256 `81de5fca8442acf267b51394b1082244642cd5cac4c1b78c41b70297e9fc1b14`. The coursework release still uses the repository's existing debug signing configuration; no distribution signing change was made.
- Installation PASS on Android 16/API 36 x86_64 AVD. Cold launch returned `Status: ok`. A synthetic task survived a real `am force-stop` / activity restart and reopening offline mode, verified in the Android accessibility hierarchy.
- TalkBack 16.0 smoke check: Android reports the service bound with spoken feedback and touch exploration enabled; screenshots show accessibility focus on the heading, Email, Password after Tab, and task input. Offline creation worked with the service active. ADB input is not proof of physical TalkBack swipe/double-tap behavior; injected swipes did not establish sequential reading. Speech content/audio quality and full screen-reader task completion remain unverified. Emulator audio was disabled. Accessibility settings were restored to their original disabled state afterward.
- Windows Narrator and iOS VoiceOver remain NOT RUN. iOS build/native requires Mac/Xcode. These are separate verification requirements, not APK build errors.
- Android native: **15 named scenarios PASS** (CRUD/metadata 2, persisted 3, independent 4, pending capture 4, quick-create exit 1, online API/SQLite 1). Static analysis PASS; all 70 Dart source files formatted with zero changes on the final check; both PowerShell scripts parse successfully. See [raw evidence index](evidence/android-loopback-20261011/README.md).
- ADB instability recurred in one driver launch before assertions. Cold-booting the disposable AVD with `-no-snapshot-load` restored successful online and subsequent suite execution on this run. This is observed local verification, not a claim that every future ADB disconnect is resolved.

## Android runner findings

The first Android CRUD run found two `Completed` labels (status chip plus card). The assertion now targets the status inside `CheckboxListTile`, including after remount. The online scenario uses the same precise status finder. Assertions were not relaxed; the app status still must match and persistence/server revisions are still checked.

Subsequent `flutter test` attempts hit a transient ADB/DDS connection failure. Direct ADB forwarding returned HTTP 200 from the running VM service. `flutter test --no-dds` executed both scenarios successfully but failed its runner's `integration_test.VmServiceProxyGoldenFileComparator` stream subscription, so that command remains FAIL. The equivalent `flutter drive --no-dds` with the standard `integrationDriver()` completed successfully. No Flutter SDK source was changed and no runner errors were hidden. All attempts are retained.

`scripts/test-online-windows.ps1 -DirectVmDriver` opts into that same driver for the isolated online API/SQLite scenario. Its default runner, synthetic data isolation, child-server cleanup and environment restoration remain unchanged. Native logs may include the binding's teardown in their `+N` total; the evidence table counts named test scenarios only.
