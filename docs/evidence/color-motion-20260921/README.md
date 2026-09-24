# Color and motion UI evidence

Local changes after b4479e3. No push, hosted CI or new report edition claimed.
Flutter 3.47.1 / Dart 3.13.1, Windows 11 10.0.26200.9457.

## Verified source gates

- `flutter test --coverage --reporter expanded`: 107 PASS in full-suite.txt.
- `dart format --output=none --set-exit-if-changed .`: PASS in format.txt.
- `flutter analyze`: PASS in analyze.txt.
- Added 3 motion tests; existing validation, loading/retry, drafts, semantics,
  touch targets, contrast and large-text checks remain enabled.

## Intentional visual changes

Fifteen golden baselines changed: eight task states, phone/wide sign-in,
account settings and four edit/filter dialog variants. Inspected actual images
and the workspace difference against previous pixels; no comparator tolerance
was changed. Explicit reviewed update: `flutter test test/golden --update-goldens
--reporter expanded` (golden-reviewed-update.txt). Full suite subsequently passed.
Images are under test/golden/baselines; intermediate failure images remain
ignored under test/golden/failures.

The initial run (behavior-first.txt) failed because decorated task tiles needed
their own Material ink surface. The next run (behavior-after.txt) exposed a
phone test tapping an offscreen Edit button; the test now scrolls to it. The
behavior-final.txt run passed all 92 unit/widget cases. Visual inspection also
caught corner clipping in account panels; moving padding inside Material fixed
it before baseline acceptance. Earlier failed outputs remain authentic.

windows-persisted_scenarios.txt records the initial native failure from a stale
Card-ancestor locator. The locator now uses the stable task-card key and visible
title without changing persisted-data assertions; reruns use the -final suffix.

## Native verification

Windows: 15 cases PASS across six separate invocations. Independent scenarios
(4) use windows-independent_scenarios.txt; persisted (3), preference workflows
(2), exit (1) and pending capture (4) use windows-*-final.txt; real API/SQLite
(1) uses windows-online.txt. These preserve isolated test preference keys.
Backend regression suite: 17 PASS in backend.txt; backend source unchanged.

## Continuation on 22 September

Final format check passed (63 files, no changes) in format-final.txt; final
analysis passed with no issues in analyze-final.txt after the native locator
change. The earlier build-web.txt stops before a success marker; its process
was no longer available on continuation. It is an incomplete attempt, not PASS.
Fresh Web and APK build outputs use the -final suffix to retain that attempt.

Release builds: Windows PASS (build-windows.txt), Web PASS
(build-web-final.txt, `flutter build web --release --no-web-resources-cdn`),
Android APK PASS (build-apk-final.txt, `flutter build apk --release`, 50.7 MB).
Both fresh builds exited 0. Android emitted a non-fatal SDK XML v3/v4 tooling
warning; it remains in the raw output. No SDK installation/update was performed.
Outputs stay ignored under build/windows/x64/runner/Release, build/web and
build/app/outputs/flutter-apk/app-release.apk; distribute the whole Windows
Release folder, not only its executable.

## Platform boundaries

Native and build results are stored in the separate windows-* and build-* logs.
A successful build does not establish manual use on that platform. No new
Android emulator run, Edge interaction run, iOS run, Narrator audit or frame-time
profile is claimed in this increment. Transitions use finite durations and
respect disableAnimations; this is not a quantified performance improvement.
