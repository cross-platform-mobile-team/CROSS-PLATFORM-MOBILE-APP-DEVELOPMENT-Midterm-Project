# Android loopback follow-up — 2026-10-11

See [diagnosis, repeatable commands and limits](../../android-loopback-fix-20261011.md).

| Check | Result | Evidence |
|---|---|---|
| Java selector without workaround | FAIL, reproduces original error | [probe](loopback-probe-default.log) |
| Java selector/pipe with scoped TCP fallback | PASS | [probe](loopback-probe-final.log) |
| Wrapper parse, environment restoration, exit/exception behavior | PASS | [final validation](loopback-wrapper-final-validation.log), [nonzero exit](loopback-wrapper-failure.log) |
| APK release build | PASS, 53,308,746 bytes | [build](apk-loopback-release-final.log), [SHA-256](android-release-sha256.log) |
| Release APK install / cold launch | PASS | [install](android-release-install.log), [launch](android-release-launch.log), [screen](android-release-launch.png) |
| Release process restart preserves synthetic task | PASS | [restart](android-release-restart.log), [hierarchy](android-release-restart-ui.xml), [screen](android-release-restart.png) |
| Native CRUD and metadata | 2 scenarios PASS | [driver log](android-drive-windows_workflow.log) |
| Native persisted scenarios | 3 scenarios PASS | [driver log](android-drive-persisted_scenarios.log) |
| Native validation, search/filter/order, load/write recovery | 4 scenarios PASS | [driver log](android-drive-independent_scenarios.log) |
| Real API/SQLite account isolation and conflict | 1 scenario PASS | [driver log](android-drive-online.log) |
| Native pending requests | 4 scenarios PASS | [driver log](android-drive-pending_capture.log) |
| Native quick-create exit | 1 scenario PASS | [driver log](android-drive-quick_create_exit.log) |
| Static analysis | PASS | [log](android-loopback-analyze.log) |
| Formatting of source directories | PASS, no changes | [log](android-loopback-format.log) |

Native runs use Android 16/API 36 x86_64 emulator, debug mode, SwiftShader/OpenGLES, standard `integrationDriver()`, and `--no-dds`. Fixture data is synthetic; native text injection uses the test channel. These runs do not measure mobile release performance or physical IME behavior. The real API runner uses a separate temporary SQLite database and stops its exact child server. `+N` in binding output can include teardown; counts above are named scenarios only.

TalkBack 16.0 was bound with touch exploration enabled. [Service state](android-talkback-service-final.log), [Email focus](android-talkback-email-touch.png), [Password after Tab](android-talkback-password-tab.png), [creation with TalkBack active](android-talkback-task-added.png). This is a basic compatibility check. Speech/audio quality, physical swipe/double-tap completion, and a full manual screen-reader audit remain unverified. TalkBack settings were restored. iOS and Windows Narrator are NOT RUN.

The first post-loopback build was deliberately interrupted after AGP began extracting Platform 36; the next failed on a stale integration-test registrant. The successful release used normal Flutter dependency refresh and automatic SDK downloads disabled. Those failed logs are retained. No JDK installation, system networking/firewall change or global environment change was made.

Earlier `android-fixed-*` and failed `android-drive-*-adb-failure` logs preserve the ambiguous status finder, ADB/DDS connection failures, and unsupported golden proxy-stream failure. A format scan over the whole repository raced with generated Gradle directories; the retained failure was replaced by a successful scan of explicit Dart source directories. The emulator was cold-booted without loading/saving snapshots; later driver results are the successful evidence. Failed commands are not reclassified as passes.

Total: **15 named Android native scenarios PASS** across six separate invocations. APK checksum was rechecked after native tests and is unchanged.
