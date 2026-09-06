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
Golden and the full multi-scenario E2E suite remain future work.

## CRUD milestone (2026-09-06)

- Unit: edit preserves fields, rejects blank input, retries failed edits; delete/
  undo persistence, failed delete/undo, missing ID, latest-only undo and write serialization.
- Widget: edit validation and retained draft after failed save; cancel deletion,
  confirm deletion and undo on 390/1100 logical-pixel viewports.
- Windows: create/edit/complete/delete/undo/remount with real isolated preferences.
- Raw unit/widget output: evidence/crud-tests-20260906.txt (15 tests total).
- Native output: evidence/windows-crud-20260906.txt.
