# TaskFlow minimal desktop UI — 2026-09-13

User-requested UI refactor, not a new product/backend scope or report increment.
Changes are local; this request does not publish a new commit.

## Design and implementation

- Off-white `#F8FAFC` canvas, white cards, `#E2E8F0` borders, indigo `#4F46E5`.
  Quick capture uses a diffuse 3% black shadow. Existing Roboto/Material icons;
  no network font, additional dependency, copied artwork or SDK upgrade.
- `SidebarNavigation`: actual all/pending/completed counts, selected and hover
  states, Local/Account/Sample identification and existing workspace actions.
  Sample mode explicitly says session-only. There is no invented sync service.
- `TaskHeader`: semantic heading and actual completed/total progress, separate
  from repository-loading indicators. The visible product name is TaskFlow.
- `QuickTaskInput`: inline desktop capture, Enter submit, working calendar and
  priority shortcuts, visible selected metadata, retained optional detail fields.
  Both controls update the same validated draft used by persistence.
- `EmptyStateWidget`: centered line icon, readable empty/no-match messages.
- Search supports Ctrl+K and Command+K within the active workspace. Sort is a
  pill popup menu; advanced combined filters retain the accessible existing
  dialog (rather than compressing its five fields into a small popup).
- Sidebar switches off below 1100 logical pixels or at large text. Capture
  stacks below 700 available pixels or at large text. The canvas has a stable
  key: title and invalid raw dates survive resize. The sidebar scrolls in short
  windows; floating pending-operation notices avoid its bottom actions.
- Material controls supply hover, focus and press feedback. No measured FPS,
  zero-jank, large-list scalability or screen-reader claim is made.

## Regression protection

`test/widget/minimal_workspace_test.dart` covers search shortcuts, quick
priority/date persistence and reset, sorting while retaining status filters,
actual completion counts, resize draft preservation and 200% text layout.
Existing CRUD, loading/retry, validation, edit and quick-create exit guards stay
in force. Do not reset the metadata baseline to mutable draft values.

Fifteen golden baselines were intentionally reviewed and replaced because of
the requested design tokens, branding and workspace layout. Phone/wide empty,
populated, validation/error, auth/account and 1x/2x dialogs were inspected.
Golden Android rendering variants are not Android-device execution.

## Evidence

Raw logs: `docs/evidence/minimal-ui-20260913/`.
`coverage-verified.txt`: 96 PASS (including 15 golden cases), no tap warnings.
`analyze.txt`: PASS. `backend.txt`: 14 PASS.
`native-independent.txt`: 4 PASS; `native-persisted.txt`: 3 PASS;
`native-exit.txt`: 1 PASS. Later gate results are indexed in the manifest.
`native-workflow.txt`: 2 PASS; `native-online.txt`: 1 PASS; Windows Release and
default Web release builds PASS. `edge-verified.txt`: corrected-script 1/1 PASS.

The first Edge run (`edge.txt`) genuinely failed: its readiness selector still
expected the retired app-bar heading. `scripts/browser/edge-harness-check.js`
now waits for the actual semantic workspace greeting; scenario assertions were
not removed. Three subsequent attempts exposed a second stale assumption:
Flutter's focused input name includes the new visible hint after a newline.
`edge-focus-diagnostic.txt` records the actual focused INPUT name and unchanged
validation description. The typing helper now verifies its exact first-line
label, then types through the keyboard into that verified active input. It keeps
bounded waits, readable diagnostics and the existing validation/order assertions.
Every attempt is recorded separately, not substituted for a failure.
Earlier coverage logs include test-target warnings; final tests tap the menu
item itself and ensure workspace exit actions are visible.

## Boundaries

Windows and Edge checks apply only to this host and recorded runs. Local Android
APK/E2E are NOT RUN: Android SDK is absent. No new hosted CI result is claimed.
Manual Narrator, clean-machine setup and release installation remain outstanding.
This slice does not complete roadmap B2–G or deferred report/video work.
