# Initial rubric traceability

Verified increment (2026-09-07): independent native seeded discovery, controlled
load/write recovery and compact/wide validation. Acceptance and commands are
recorded in docs/project-plan.md and integration_test/independent_scenarios_test.dart.

| Requirement | Bootstrap implementation | Verification | Remaining |
|---|---|---|---|
| Flutter architecture | Repository -> controller -> screen with metadata/filter domain types | Unit/widget tests | Architecture diagrams |
| Meaningful workflow | CRUD, metadata, search, filters, sort, undo | Widget CRUD/metadata tests and Windows workflows | Broader failure/platform scenarios |
| Robustness | Loading, empty, error/retry, persist before state change | Independent native load/write failure and draft-preserving recovery; API/client failures | Browser failure evidence |
| Cross-platform | Android/Web/Windows runners | Web build; Windows release launch and integration test | Android verification, broader platform evidence |
| Testing pyramid | 49 unit/widget/golden cases, 7 native cases across 3 suites, 14 API cases | Latest evidence/manifest.md; independent-e2e.md | Split native edit/delete scenarios; report comparison |
| Visual/accessibility | Phone/wide baselines, darker validation errors | test/golden; widget/accessibility_test.dart; docs/golden-testing.md | Manual screen-reader/focus order and other forms |
| Experiments | Search mutation detected by permanent widget regression | evidence/intentional_defect/README.md, buggy/fix patches, baseline/fail/pass logs | Timing/stability, native defect detection, report interpretation |
| Research and submission | Original prompt retained | NOT RUN | Sources, Word/PDF, video, oral exam |
| User-authorized backend | Account/session/task API, SQLite, Flutter online/offline gateway | backend/test/api.test.js; test/unit/api_client_test.dart; test/widget/account_flow_test.dart; integration_test/online_workflow_test.dart; backend-*-20260907 logs | Public deployment/hardening, email verification and browser runtime validation are not claimed |
