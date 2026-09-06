# Golden and accessibility verification

Agent-assisted working notes for student review, checked 2026-09-06.

## Reproduction environment

- Host: Windows 11 10.0.26200.9168, Flutter 3.47.1 / Dart 3.13.1.
- Run from repository root after `flutter pub get`, retaining pubspec.lock.
- Eight baselines: empty, populated, invalid title and load error, each at
  390 x 960 and 1280 x 900 logical pixels; device pixel ratio 1, en-US,
  normal text scale, fixed sample records, no network or preference storage.
- `TargetPlatformVariant.only(TargetPlatform.android)` selects Material rendering
  consistently. It does not run an Android app, emulator or native storage.
- Flutter test defaults disable shadows; the outlined elevation in screenshots
  is a test-rendering characteristic, not a native screenshot claim.
- `test/support/visual_fixture.dart` loads vendored Roboto regular/medium/bold
  and MaterialIcons from Flutter's generated asset bundle. Tests reset view and
  locale; platform variants handle restoring platform state.
- Roboto files were copied unchanged from Flutter 3.47.1's
  `bin/cache/artifacts/material_fonts/`; Apache 2.0 licence is retained in
  `test/fonts/LICENSE.txt`. They are test-only, not added to production assets.
  MaterialIcons is provided by the SDK through `uses-material-design: true`.

## Verify and deliberately update

```sh
flutter test test/golden --reporter expanded
flutter test test/widget/accessibility_test.dart --reporter expanded
```

Use the normal exact comparator, without a custom tolerance. If a baseline fails,
inspect the expected, actual and diff PNGs in `test/golden/failures/` before making
changes. Check the SDK, fonts and viewport before diagnosing an app regression.
Do not commit generated failure images as new baselines or update all screenshots
without review. For an intended UI change only:

```sh
flutter test test/golden --update-goldens --reporter expanded
flutter test test/golden --reporter expanded
```

Inspect every changed PNG and explain its reason in the commit. Initial review
found missing icon glyphs; loading MaterialIcons resolved them before acceptance.
All eight accepted images were visually inspected: readable labels/icons, both
task cards visible, inline validation and retry visible, no clipped content at
the captured sizes. These are initial baselines, not an observed visual-regression
diff experiment. The subsequent normal suite compares against them without updates.

Flutter documents that fonts/SDK/host differences can affect goldens; a baseline
passing here is not a guarantee of identical raster output on other hosts.
[Official golden API](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)
(accessed 2026-09-06).

## Accessibility scope and findings

Four 390 x 960 states run label, 48-pixel tap-target and text-contrast guidelines.
Separate cases exercise Tab leaving the title field with the Windows rendering
variant, text-input submission, and scrolling to Edit/opening/cancelling a dialog
at 200% text scale. This is widget-level input, not a physical-keyboard test.

The initial guideline run measured 3.19 contrast for the 12-pixel validation text
against a required 4.5. The production theme now uses a darker 14-pixel semibold
error style. The final automated checks pass. The development failure log also
contains test-harness errors (late semantics disposal and ambiguous scrollable);
these are not app bugs. The harness now uses the test's built-in semantics,
platform variants and explicit scrolling/settling.

Guideline checks cover selected visible states, not all forms or all screen-reader
behavior. Manual focus order, OS IME, Narrator and browser semantics still need
separate evidence. This is not a WCAG conformance certification.
[Flutter accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing)
(accessed 2026-09-06) describes guideline checks and platform inspection.
