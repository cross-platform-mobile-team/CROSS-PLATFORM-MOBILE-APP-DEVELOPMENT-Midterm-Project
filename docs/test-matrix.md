# Bootstrap tests

| Risk | Scenario | Level |
|---|---|---|
| Invalid title | Blank and 120/121-character boundaries | Unit |
| Search misses tasks | Padded mixed-case substring | Unit |
| Nondeterministic data | Inject clock/ID; verify persisted completion | Unit |
| Write failure publishes bad state | Failed save followed by load recovery | Unit |
| Serialization loss | Task JSON round trip | Unit |
| Broken UI workflow | Empty -> invalid -> create -> complete at 390/1100 widths | Widget |
| Recovery unavailable | Initial failure -> Retry -> empty | Widget |

Command: flutter test --coverage. Tests isolate repositories and use finite UI
settling. Source: test/unit/task_controller_test.dart and test/widget/task_screen_test.dart.
Native smoke: integration_test/windows_workflow_test.dart runs create/complete/
reload against real local preferences under a separate test key. PASS on Windows.
This paragraph describes the initial smoke test; later milestones below supersede
its scope. The independent full multi-scenario E2E suite is still pending.

## CRUD milestone (2026-09-06)

- Unit: edit preserves fields, rejects blank input, retries failed edits; delete/
  undo persistence, failed delete/undo, missing ID, latest-only undo and write serialization.
- Widget: edit validation and retained draft after failed save; cancel deletion,
  confirm deletion and undo on 390/1100 logical-pixel viewports.
- Windows: create/edit/complete/delete/undo/remount with real isolated preferences.
- Raw unit/widget output: evidence/crud-tests-20260906.txt (15 tests total).
- Native output: evidence/windows-crud-20260906.txt.

## Metadata milestone (2026-09-06)

- Legacy JSON gets defaults; new metadata survives serialization and task mutations.
- Tag normalization/immutability/limits; notes limit; invalid calendar dates rejected.
- Combined filters, exact tag, note search, overdue/today/future/no-date boundaries.
- Stable priority/due sorting, with null dates last.
- Phone/wide forms: create metadata, reject invalid date, filter to empty, clear,
  edit fields and remove date. Shared interaction helper also runs on Windows with
  real isolated local preferences and remount verification.
- Metadata milestone total: 24 unit/widget tests and 2 native Windows tests.

## Visual, accessibility and regression milestone (2026-09-06)

| Risk | Scenario | Level | Command from repository root |
|---|---|---|---|
| Layout changes unnoticed | Empty/populated/validation/error at 390x960 and 1280x900 | 8 golden cases | flutter test test/golden |
| Inaccessible controls/text | Labels, tap sizes and contrast in four visible states | 4 widget cases | flutter test test/widget/accessibility_test.dart |
| Keyboard/text-scale breakage | Tab and submit; edit/cancel at 200% phone text | 2 widget cases | flutter test test/widget/accessibility_test.dart |
| Prefix-only search regression | Search padded uppercase middle word, verify saved card | 1 widget case | flutter test test/widget/search_regression_test.dart |

Current total: 39 unit/widget/golden cases plus 2 Windows integration workflows.
See golden-testing.md for controlled environment, review process and coverage
limits; evidence/intentional_defect/README.md for mutation reproduction.
Full suite: `flutter test --coverage --reporter expanded`.
Native: `flutter test integration_test/windows_workflow_test.dart -d windows --reporter expanded`.
