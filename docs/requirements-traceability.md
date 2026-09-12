# Rubric traceability

## Current verified state

B1 edit slice: accidental Cancel/Escape/Back -> edit_task_dialog.dart and raw
metadata dirty callback -> edit_draft_test.dart (five cases) plus persisted edit
scenario -> evidence/upgrade-b1-20260912/. See upgrade-b1.md for remaining B scope.

The authoritative current summary is [current-verified-state.md](current-verified-state.md).
Pre-upgrade baseline 0753db1 had 72 Flutter cases including 11 goldens, 10 Windows executions,
14 API cases and SHA-matched successful hosted jobs. See its explicit limits.
The dated entries below preserve the incremental history; their older counts
must not be used as current totals. Package A adds this distinction and the
[A-G upgrade roadmap](upgrade-roadmap.md); no application behavior changes.

## Historical implementation increments

Bug-audit risks (2026-09-12): unknown/failed-load snapshots must not overwrite
stored tasks; stale account requests must not clear newer sessions. Add explicit
regressions and preserve fail/fix logs under evidence/bug-audit-20260912/.
Also cover invalid_password after a successful token refresh without signing
out a valid session. Six new regression cases; see bug-audit-20260912.md.

Color studio acceptance: color supplements text/status, never replaces it;
decorative geometry excluded from semantics; compact/200% layout and existing
CRUD/retry assertions remain. Visual baselines require explicit review.

UI refresh (2026-09-11): shared theme and surfaces, responsive task status rail,
auth split layout and account sections. Existing validation/CRUD/loading semantics
remain covered. Navigation/large-text tests and sign-in/settings goldens added;
all eight changed task goldens reviewed before intentional baseline replacement.
At this UI-refresh milestone: 66 cases including 11 goldens; 10 Windows cases pass.
See evidence/manifest.md for commands, logs and unverified Android/manual gates.

Dedicated loading widget coverage (2026-09-10): task_loading_test.dart adds four
cases for compact/wide initial loading, error-to-retry-to-empty, and pending-save
draft preservation/duplicate-submit prevention. The local Flutter suite now has
61 cases at that milestone; historical CI counts remain tied to their original commits.

2026-09-10 engineering increment (report deferred): fresh Edge sessions extend
the one-session repetition study. `scripts/test-edge-harness.ps1 -Sessions 3
-Repetitions 2` retains individual logs and machine-readable results; synthetic
runner contracts protect failure propagation and evidence preservation. This
addresses browser repeatability/reproducibility, not broader-host or CI coverage.

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

Current Android/CI increment (2026-09-09): GitHub Actions run #2 passed Windows
quality gates, debug/release APK builds with checksum artifact, and 9 isolated
workflow executions on an Android 16/API 36 emulator.

| Requirement | Bootstrap implementation | Verification | Remaining |
|---|---|---|---|
| Flutter architecture | Repository -> controller -> screen with metadata/filter domain types | Unit/widget tests | Architecture diagrams |
| Meaningful workflow | CRUD, metadata, search, filters, sort, undo | Widget CRUD/metadata tests and Windows workflows | Broader failure/platform scenarios |
| Robustness | Loading, empty, error/retry, persist before state change | Native plus Edge harness load/save failures, Retry and draft preservation; API/client failures | Public deployment/long-duration failure evidence |
| Cross-platform | Android/Web/Windows runners | Edge online lifecycle/sample plus deterministic harness; Windows release/native suites; hosted API 36 APK/E2E gate | Physical Android/manual APK and Android online mode; another browser/host |
| Testing pyramid | 77 local unit/widget/golden cases after B1; 10 Windows scenarios across 4 suites, 14 API cases; Edge CLI checks; separate hosted Android evidence | current-verified-state.md; evidence/manifest.md; independent-e2e.md; web-edge-testing.md | Manual platform checks; report comparison; historical Android counts must stay SHA-specific |
| Visual/accessibility | Phone/wide baselines, validation errors, account entry/settings guidelines, focus recovery/order, 200% text and text-only tag semantics | test/golden; widget/accessibility_test.dart; widget/sample_accessibility_test.dart; widget/account_settings_accessibility_test.dart; Edge snapshots | Manual Narrator/full-page physical focus order and clean-machine assistive-technology pass |
| Safe sample data | Fresh in-memory repository per sample entry; no offline overwrite/upload | Widget isolation/reset and scripts/browser/edge-sample-check.js | Clean-machine demo rehearsal |
| Experiments | Search mutation; repeated browser and four test-level commands | Intentional-defect fail/fix artifacts; five-run Edge and three-round test-level timing experiments | Broader sessions/hosts and report synthesis |
| Research and submission | Original prompt retained | NOT RUN | Sources, Word/PDF, video, oral exam |
| User-authorized backend | Account/session/task API, SQLite, Flutter online/offline gateway | API/client/widget/native tests and Edge online/re-login evidence | Public deployment/hardening and email verification are not claimed |
| CI execution | Pinned Windows quality, Android APK and API 36 emulator jobs in `.github/workflows/quality.yml` | Run #2 PASS; both APKs and checksum file uploaded | Re-run on later source changes; clean-machine/manual evidence |
| Android native | SDK/NDK/JDK plus local API 36 AVD; 9 offline/controlled scenarios in CI | Hosted API 36 build/E2E PASS | Manual APK install/launch, physical device, online mode and production signing |
