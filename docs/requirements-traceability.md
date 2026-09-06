# Initial rubric traceability

| Requirement | Bootstrap implementation | Verification | Remaining |
|---|---|---|---|
| Flutter architecture | Repository -> controller -> screen with metadata/filter domain types | Unit/widget tests | Architecture diagrams |
| Meaningful workflow | CRUD, metadata, search, filters, sort, undo | Widget CRUD/metadata tests and Windows workflows | Broader failure/platform scenarios |
| Robustness | Loading, empty, error/retry, persist before state change | Failure tests | Broader recovery scenarios |
| Cross-platform | Android/Web/Windows runners | Web build; Windows release launch and integration test | Android verification, broader platform evidence |
| Testing pyramid | Unit/widget, 8 goldens, 2 native workflows | quality-tests-20260906.txt; quality-windows-20260906.txt | Independent full E2E scenario coverage; report comparison |
| Visual/accessibility | Phone/wide baselines, darker validation errors | test/golden; widget/accessibility_test.dart; docs/golden-testing.md | Manual screen-reader/focus order and other forms |
| Experiments | Search mutation detected by permanent widget regression | evidence/intentional_defect/README.md, buggy/fix patches, baseline/fail/pass logs | Timing/stability, native defect detection, report interpretation |
| Research and submission | Original prompt retained | NOT RUN | Sources, Word/PDF, video, oral exam |
