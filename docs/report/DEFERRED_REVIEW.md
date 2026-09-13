# Report review record — resolved capture finding

The previously deferred capture finding was corrected on 13 September 2026 at
the user's request. This internal record is not included in the manuscript.
Student review is required before submission of this AI-assisted manuscript.

## Pending-create diagnostic

Baseline: 39dd199. Enter First task, hold the save with a Completer, press Add,
then enter Second draft before releasing the save. The first task is saved,
but the newer title is cleared. Expected Second draft; observed empty string.
The existing 96-case Flutter suite passes, while this additional probe fails.
The application now resets only the submitted draft, preserving newer input.
Four permanent widget cases cover compact/wide successful and failed writes.
The updated suite passes 100 cases; analysis and 14 API cases pass, together
with the Windows draft-exit integration case. Logs: docs/evidence/capture-fix/.

Keep evidence/pending_capture_test.dart.txt and evidence/pending-capture.txt.
The original failure remains preserved. The permanent regression is
test/widget/pending_capture_test.dart. These checks do not certify absence of
all possible defects or unconditional submission readiness.

## Other pending submission checks

Confirm submission date and real member contributions. Do not invent percentages.
Manual accessibility, clean-machine installation and current-revision Android
evidence remain distinct from the existing measured results.
