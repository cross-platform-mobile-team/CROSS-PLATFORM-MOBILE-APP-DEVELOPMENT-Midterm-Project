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
Golden and native E2E suites remain future work.
