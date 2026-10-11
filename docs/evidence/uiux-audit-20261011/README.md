# UI/UX audit evidence — 11 October 2026

Local engineering evidence; no publication. **Follow-up:** the APK blocker was subsequently resolved; see [Android loopback diagnosis and current verification](../../android-loopback-fix-20261011.md). This table preserves the original audit results. See [implementation](../../uiux-audit-implementation-20261011.md) for scope, timing method and limits.

| Check | Result | Evidence |
|---|---|---|
| Flutter unit/widget/golden + coverage | 133 PASS | [log](uiux-final-coverage.log) |
| Static analysis | PASS | [log](uiux-final-analyze.log) |
| Formatting | 69 files, zero changes | [log](uiux-format.log) |
| API Node tests | 17 PASS | [log](uiux-api-tests-node.log) |
| Windows independent scenarios | 4 PASS | [log](uiux-native-independent_scenarios.log) |
| Windows persisted scenarios | 3 PASS | [log](uiux-native-persisted_scenarios.log) |
| Windows workflow | 2 PASS | [log](uiux-native-windows_workflow.log) |
| Windows pending capture | 4 PASS | [log](uiux-native-pending_capture.log) |
| Windows quick-create exit | 1 PASS | [log](uiux-native-quick_create_exit.log) |
| Windows real API/SQLite online lifecycle | 1 PASS | [final rerun](uiux-native-online-final.log), [earlier run](uiux-native-online.log) |
| Web release build | PASS | [log](uiux-build-web.log) |
| Windows profile, eager then lazy | Both complete runs PASS | [eager](uiux-profile-eager.log), [lazy](uiux-profile-lazy.log), [raw metrics](profile-metrics.json) |
| Android APK | BLOCKED: Java loopback connection | [initial](uiux-build-apk.log), [stacktrace](uiux-gradle-diagnostic.log), [short socket path](uiux-build-apk-tempdir.log), [JDK21](uiux-build-apk-jdk21.log), [JBR25](uiux-build-apk-jbr25.log) |

The five fake-HTTP recovery cases cover conflict, committed timeout, deletion, committed replacement timeout, and failed reload. They verify preserved editable fields, explicit decisions, no write on reload, preservation of server completion status, and no duplicate replacement. They are not real-server evidence. Windows online uses an isolated synthetic database and account; the server is stopped by the runner. Other native cases preceded the final replacement-ID fix; the online case was rerun afterward.

Browser scripts passed Node syntax checks, but no browser interaction run is claimed. Current Android/iOS native and manual Narrator/TalkBack/VoiceOver remain NOT RUN. Logical viewport/inset tests do not establish native IME behavior. The APK blocker reproduces with installed runtimes; no SDK installation or global settings changes were made.

## Visual review

Before images come from Git HEAD; after images are current deterministic Flutter goldens, not native screenshots. The injected fixture clock and UTC session conversion keep date/time comparisons repeatable. 13 existing baselines changed after visual inspection; two existing edit-dialog baselines stayed unchanged; two audit baselines were added. Golden tolerances were not relaxed.

| Screen | Before | After |
|---|---|---|
| Phone tasks | [before](before-phone-populated.png) | [after](after-phone-populated.png) |
| Wide tasks | [before](before-wide-populated.png) | [after](after-wide-populated.png) |
| Account settings | [before](before-account-settings.png) | [after](after-account-settings.png) |
| Sign in | [before](before-phone-sign-in.png) | [after](after-phone-sign-in.png) |

[390x844 acceptance screen](audit-phone-390x844.png) · [retained-draft comparison](audit-edit-recovery.png). Review/difference sheets are `uiux-review-0.png` through `-3.png` and `uiux-diff-0.png` through `-3.png`.

Initial failing test/golden/profile attempts remain alongside final evidence. `uiux-tests-initial/second/third`, `uiux-lazy-coverage`, `uiux-golden-review`, `uiux-profile-before` and `uiux-profile-drive-before` are iteration evidence, not PASS claims. Performance figures come from one complete Windows run per strategy and do not prove mobile speed or zero jank.
