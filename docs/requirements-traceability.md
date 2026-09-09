# Initial rubric traceability

Verified increment: independently reset real-preference happy path,
edit/completion and deletion/undo, with exact metadata preservation and unaffected
record assertions. See integration_test/persisted_scenarios_test.dart.

Verified increment (2026-09-07): independent native seeded discovery, controlled
load/write recovery and compact/wide validation. Acceptance and commands are
recorded in docs/project-plan.md and integration_test/independent_scenarios_test.dart.

| Requirement | Bootstrap implementation | Verification | Remaining |
|---|---|---|---|
| Flutter architecture | Repository -> controller -> screen with metadata/filter domain types | Unit/widget tests | Architecture diagrams |
| Meaningful workflow | CRUD, metadata, search, filters, sort, undo | Widget CRUD/metadata tests and Windows workflows | Broader failure/platform scenarios |
| Robustness | Loading, empty, error/retry, persist before state change | Independent native load/write failure and draft-preserving recovery; API/client failures | Browser failure evidence |
| Cross-platform | Android/Web/Windows runners | Edge online lifecycle/re-login and sample checks; Windows release and native suites | Android verification, broader browser failure coverage |
| Testing pyramid | 55 unit/widget/golden cases, 10 native cases across 4 suites, 14 API cases; Edge CLI checks | Latest evidence/manifest.md; independent-e2e.md; web-edge-testing.md | Browser/platform expansion; report comparison |
| Visual/accessibility | Phone/wide baselines, validation errors, account guidelines, text-only tag semantics | test/golden; widget/accessibility_test.dart; widget/sample_accessibility_test.dart; Edge snapshots | Manual screen-reader/full focus order and account-settings forms |
| Safe sample data | Fresh in-memory repository per sample entry; no offline overwrite/upload | Widget isolation/reset and scripts/browser/edge-sample-check.js | Clean-machine demo rehearsal |
| Experiments | Search mutation detected by permanent widget regression | evidence/intentional_defect/README.md, buggy/fix patches, baseline/fail/pass logs | Timing/stability, native defect detection, report interpretation |
| Research and submission | Original prompt retained | NOT RUN | Sources, Word/PDF, video, oral exam |
| User-authorized backend | Account/session/task API, SQLite, Flutter online/offline gateway | API/client/widget/native tests and Edge online/re-login evidence | Public deployment/hardening and email verification are not claimed |
