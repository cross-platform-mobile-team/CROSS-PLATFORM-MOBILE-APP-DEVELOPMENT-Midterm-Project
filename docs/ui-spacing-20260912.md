# UI spacing, clipping and edit rebuild audit

Initially user requested UI fixes only; the subsequent continuation request
authorized publication to main-test after checks. Base abbc203; no report, dependency
or SDK changes. This is an agent-assisted engineering record for student review.

## Confirmed defects and fixes

The three new form_layout_test.dart cases all failed before the fix. The raw
before.txt records adjacent fields with no gap and enlarged dropdown RenderFlex
overflows. Edit/metadata/filter fields now have 20px gaps. Dropdowns expand to
available width with intrinsic item height rather than a dense fixed row.

Visual inspection exposed top floating-label clipping and long truncated labels
at 200% text. Dialog scroll padding now protects labels; date/tag instructions
sit below short labels. Edit titles wrap across up to three lines, preserving
Done-to-save. Lower fields scroll while dialog actions remain accessible.

Dirty listeners rebuild the Edit parent only when the dirty boolean changes,
not every cursor movement/keystroke. A test verifies metadata widget identity
and stable position during same-height typing. This is not an FPS benchmark
or proof that every source of jank has been eliminated.

## Verification

Three layout tests and four new dialog goldens cover 390px, text 100%/200%,
spacing, dropdown opening and typing stability. All four final golden images
were visually reviewed; eleven existing baselines were not changed. Initial
images revealed clipping, fixed before final image review. No actual Android
device run is implied by the pinned golden rendering variant.

Full Flutter coverage invocation passes 84 cases. See evidence/manifest.md for
native, Edge and build results; logs are under evidence/ui-spacing-20260912/.
The final layout-only rerun includes an extra identity assertion added after
the full coverage run; it does not add another case.

## Limits

No frame-time profiling, Narrator, clean-machine setup or local Android run
(SDK absent). The browser harness is a general regression gate, not visual
evidence for every modified dialog. B1 quick-create exit protection and B2
remain separate roadmap work. Publication is authorized by the follow-up request.
