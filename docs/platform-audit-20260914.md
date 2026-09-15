# Platform audit — 14 September 2026

Baseline: d0b145d. User requests bug review and Android/iOS/Windows execution;
Android SDK/emulator installation on D: is authorized. No publication requested.

## Plan and acceptance criteria

1. Recheck tools; keep Android SDK, AVD and build caches on D: where configurable.
2. Run Flutter/API checks and independent Windows native suites; preserve failures.
3. Build/install/launch Android and run isolated integration scenarios on an AVD.
4. Add missing iOS scaffold; inspect plugin/network configuration. Actual iOS
   build and simulator execution require macOS/Xcode and must remain NOT RUN here.
5. Fix reproduced issues with regressions, then record exact verified boundaries.

Passing selected tests is not proof of absence of every possible bug.
Evidence directory: docs/evidence/platform-audit-20260914/.

## Verified before 15 September continuation

- Flutter suite with coverage: PASS, 100 cases; backend: PASS, 14 cases.
- Windows: PASS, 15 case executions across independent (4), persisted (3),
  lifecycle (2), draft exit (1), online (1), pending capture (4).
- Windows release build and static analysis: PASS.
- Android API 36 emulator booted; no TaskFlow Android pass was recorded yet.
- Android release attempts failed first on the SDK 23 NDK wrapper, then Kotlin
  cross-drive caching, then stale incremental storage. All logs remain intact.
- NDK 28.2.13676358 installed explicitly; packages resolved with enforce-lockfile
  into D:/Android/pub-cache, without dependency version changes.
- iOS runner added, but build/install/E2E remain NOT RUN without macOS/Xcode.

## 15 September recovery

With no Java build process remaining, moved only the generated plugin Kotlin
cache from build/shared_preferences_android/kotlin to
build/kotlin-cache-before-recovery-20260915. This is recoverable; report assets,
other build artifacts and user data were not cleared. Fresh logs are under
docs/evidence/platform-audit-20260915/. Emulator restarted from the existing D: AVD.

Release initially failed on a stale generated integration-test registration
with --no-pub. A normal flutter build apk --release refreshed the registration
and passed. APK installation, cold launch and process-restart persistence were
verified visually on API 36. All 15 Android native cases passed across six
separate invocations, including the real API/SQLite case over the debug-only
10.0.2.2 HTTP configuration. See the 15 September evidence README for commands,
SHA256, screenshots, raw logs and boundaries. The release artifact was restored
after testing and the emulator stopped to free memory. iOS remains NOT RUN.

Final 15 September gates: 100 Flutter cases with coverage, 14 API cases,
static analysis and full-project formatting PASS. No golden replacements or
dependency upgrades. Neither these tests nor the platform smoke checks prove
absence of every possible bug. Physical Android, full IME/VoiceOver/Narrator,
release HTTPS account deployment and iOS execution remain separate gates.
