# Intentional search defect - 2026-09-06

Agent-assisted experiment record for student review.

## Question, hypothesis and controls

Can a widget-level user workflow detect a semantic search regression even though
the app still compiles? Hypothesis: changing normalized substring matching into
prefix matching hides an existing task when a middle word is entered.

Host/SDK: Windows 11 10.0.26200.9168, Flutter 3.47.1, Dart 3.13.1.
The same test, view, fake repository and records are used for each run. No network,
real preferences, arbitrary sleeps or timing thresholds are involved. Data:
`Review Flutter testing` and `Write report`, stable IDs and UTC creation dates.
Query: ` FLUTTER ` (trimmed and lowercased by the app).

The permanent `test/widget/search_regression_test.dart` asserts the matching task
inside a CheckboxListTile and excludes the unrelated task. It cannot pass merely
because query text is visible in an input field.

## Observed results

| Variant | Command output | Exit | Result |
|---|---|---|---|
| Correct baseline | baseline.txt | 0 | 1 test passed |
| Injected prefix comparison | fail.txt | 1 | Expected task widget missing |
| Restored substring comparison | pass.txt | 0 | 1 test passed |

One measured run per variant, not a benchmark or flakiness estimate. Raw runner
output is unedited; paths and runner durations describe this machine only.
`buggy.patch` is the minimal injected diff; `fix.patch` is its inverse.

Root cause: `startsWith` checks only the beginning of the concatenated searchable
text. `flutter` occurs after `review `, so the task is wrongly removed. Restoring
`contains` preserves normalized substring behavior. The final source is corrected;
the regression test remains. This proves detection of this defect at widget level,
not coverage of all search defects, native input or storage.

## Reproduce safely

Use a disposable checkout of this revision, not a worktree with unrelated edits.
From its root, run `flutter pub get` with Flutter 3.47.1. In PowerShell:

```powershell
$flutterExe = 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat'
# Set this to your own installed SDK path on another machine.
& $flutterExe test test/widget/search_regression_test.dart --reporter expanded
git apply --check docs/evidence/intentional_defect/buggy.patch
git apply docs/evidence/intentional_defect/buggy.patch
try {
  & $flutterExe test test/widget/search_regression_test.dart --reporter expanded
  if ($LASTEXITCODE -eq 0) { throw 'Expected regression failure was not detected.' }
} finally {
  git apply docs/evidence/intentional_defect/fix.patch
}
& $flutterExe test test/widget/search_regression_test.dart --reporter expanded
git diff -- lib/features/tasks/domain/task_filters.dart
```

The first/final tests should pass, middle test should fail specifically for the
missing task, and final source diff should be empty. An unrelated compiler/setup
failure is not successful defect detection. Do not commit the injected defect.
Patch files use LF in Git to make reproduction independent of Windows log encoding.
