# Initial rubric traceability

Test timing/repetition increment: `scripts/repeat-test-levels.ps1` measures fresh
Flutter invocations for four existing suites, with rotated order and raw results.
All 12 invocations passed; interpretation and evidence are recorded in
docs/experiments/test-levels-20260909.md.

Current increment (2026-09-09): the signed-in account settings screen now has
automated semantics, validation-focus, keyboard-order and 200% text coverage.
`docs/accessibility-testing.md` separates these widget assertions from the manual
Narrator/full-page focus audit, which remains NOT RUN.

Current increment (2026-09-09): close the browser failure/discovery evidence gap
with a compile-time-gated, synthetic in-memory Edge harness because the installed
Flutter runner does not support `integration_test` on Web devices.

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
| Robustness | Loading, empty, error/retry, persist before state change | Native plus Edge harness load/save failures, Retry and draft preservation; API/client failures | Public deployment/long-duration failure evidence |
| Cross-platform | Android/Web/Windows runners | Edge online lifecycle/sample plus deterministic harness; Windows release/native suites | Android verification, another browser/host |
| Testing pyramid | 57 unit/widget/golden cases, 10 native cases across 4 suites, 14 API cases; Edge CLI checks | Latest evidence/manifest.md; independent-e2e.md; web-edge-testing.md | Browser/platform expansion; report comparison |
| Visual/accessibility | Phone/wide baselines, validation errors, account entry/settings guidelines, focus recovery/order, 200% text and text-only tag semantics | test/golden; widget/accessibility_test.dart; widget/sample_accessibility_test.dart; widget/account_settings_accessibility_test.dart; Edge snapshots | Manual Narrator/full-page physical focus order and clean-machine assistive-technology pass |
| Safe sample data | Fresh in-memory repository per sample entry; no offline overwrite/upload | Widget isolation/reset and scripts/browser/edge-sample-check.js | Clean-machine demo rehearsal |
| Experiments | Search mutation; repeated browser and four test-level commands | Intentional-defect fail/fix artifacts; five-run Edge and three-round test-level timing experiments | Broader sessions/hosts and report synthesis |
| Research and submission | Original prompt retained | NOT RUN | Sources, Word/PDF, video, oral exam |
| User-authorized backend | Account/session/task API, SQLite, Flutter online/offline gateway | API/client/widget/native tests and Edge online/re-login evidence | Public deployment/hardening and email verification are not claimed |
