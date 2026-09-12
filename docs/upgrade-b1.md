# Upgrade B1: edit-draft protection

2026-09-12; base c57407a, changes authorized for main-test. Agent-assisted
engineering notes for student review, not the coursework report.

## Implemented slice

- Cancel, Escape and Navigator back request confirmation only when edit inputs
  differ from their initial values. Reverting inputs removes the dirty state.
- Continue editing preserves inputs; Discard closes without calling save.
- Compare raw metadata inputs, including an invalid date that cannot yet become
  a TaskDetails calendar value. Normalized model values alone would miss it.
- While saving, dismissal and duplicate save remain disabled. The nested
  confirmation is guarded against repeated opening; its safe action gets focus.
- Drafts stay in widget memory. No preferences, API schema, packages or golden
  baselines changed. Closing a tab/process is not protected by this slice.

## Tests and evidence

`test/widget/edit_draft_test.dart` has five isolated cases: reverted title,
continue/discard with a save spy, invalid-date back/Escape, pending save with
a completer gate, and 390-pixel/200% text confirmation.

The persisted edit scenario now attempts Cancel, verifies storage is unchanged,
continues editing, saves and remounts a fresh repository/UI while preserving
metadata. This is the existing scenario extended, not an extra E2E case.

The first targeted run exposed missing Escape handling with the non-dismissible
route. CallbackShortcuts now explicitly routes Escape through requestClose.
The successful four-case rerun is draft-tests.txt; the fifth large-text case
was added later. coverage.txt is the intermediate 76-case run; final results
are indexed separately in evidence/manifest.md. Do not relabel preliminary logs.

## Boundaries / next slice

This completes the edit-dialog portion of B1 only. Quick-create workspace-exit
protection and B2 collapsed-field validation/focus auditing remain next.
Native tests cover persistence, not OS restart or IME. Edge's existing harness
checks regressions, not the new confirmation specifically. Narrator, clean-host
setup and local Android (SDK absent) remain unverified. Hosted CI for c57407a
or earlier does not prove this source revision. No report/video work performed.
