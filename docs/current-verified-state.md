# Current verified state

## B1 edit-slice update - 2026-09-12

Application changes after c57407a: dirty Cancel/Escape/Back confirmation, raw
invalid-date protection and five widget regressions. Final coverage run passes
77 cases (11 unchanged goldens). The persisted edit scenario adds keep-draft /
storage-before-save checks; native case counts are not increased. See
[B1 scope](upgrade-b1.md) and [latest gates](evidence/manifest.md).
The 0753db1 results below are the pre-upgrade baseline, not CI for this source.

## Pre-upgrade verified baseline

Reviewed 2026-09-12 for upgrade roadmap package A. This is an engineering
evidence index, not a claim that the coursework is ready to submit.

## Source and interpretation

Application/test baseline: `0753db13134af2fccce86d559825fe76ea2f3dde`, branch
`main-test`. Package A changes documentation/evidence only. Earlier dated
sections in other documents are historical snapshots, not current test counts.
Raw outputs captured before that commit remain unchanged.

| Scope | Verified result | Evidence | Boundary |
|---|---|---|---|
| Flutter unit/widget/golden | 72 passing case executions, including 11 golden cases | [Final suite](evidence/bug-audit-20260912/tests-final.txt), [coverage run](evidence/bug-audit-20260912/coverage-final.txt) | Not 72 E2E scenarios; no coverage percentage inferred |
| Windows integration | 2 preference workflows + 4 controlled-repository cases + 3 independently reset persisted cases + 1 API case | [Commands and logs](evidence/manifest.md#bug-audit---2026-09-12) | 10 executions across four separately launched suites; remount is not process restart |
| Backend | 14 API cases pass | [Raw log](evidence/bug-audit-20260912/backend.txt) | Isolated synthetic data, not production security certification |
| Edge | 1 harness repetition passes; default Web build restored | [Runner](evidence/bug-audit-20260912/edge.txt), [workflow](evidence/bug-audit-20260912/edge-workflow.txt) | In-memory harness, not direct Flutter Web integration_test or screen-reader proof |
| Windows/Web release build | PASS | [Windows](evidence/bug-audit-20260912/windows-build.txt), [Web restoration](evidence/bug-audit-20260912/edge.txt) | Not clean-machine installation |
| Hosted CI at baseline SHA | All three jobs completed successfully | [Run 34628335925](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34628335925), [job metadata](evidence/upgrade-a-20260912/ci-jobs.json) | Windows quality gates, Android APKs, Android E2E API 36; job status alone is not a new case-count measurement |
| Hosted APK artifact | `taskflow-android-apks`, not expired at inspection | [Artifact metadata](evidence/upgrade-a-20260912/ci-artifacts.json) | Availability is time-limited; not downloaded/installed in package A |

Use the raw artifact response for the UTC expiration timestamp. A later push
creates a different SHA; it must not inherit this hosted PASS automatically.

## Trace a risk to evidence

| Risk | Implementation | Test | Result |
|---|---|---|---|
| Unknown snapshot overwrites saved data | `TaskController` load gate | `test/unit/snapshot_safety_test.dart`, `test/widget/failed_load_safety_test.dart` | [Fail/fix audit](bug-audit-20260912.md) |
| Stale logout clears newer session | `ApiClient` generation-scoped cleanup | `test/unit/session_race_test.dart` | [Final suite](evidence/bug-audit-20260912/tests-final.txt) |
| Search silently becomes prefix-only | Domain substring search | `test/widget/search_regression_test.dart` | [Intentional defect](evidence/intentional_defect/README.md) |
| False browser-runner PASS | Exit-code and unique-output safeguards | `scripts/tests/edge-runner-contract.ps1` | [Synthetic contract log](evidence/bug-audit-20260912/runner-contract.txt); not app evidence |

## Remaining gates and next step

- Local Android APK/device execution: NOT RUN, Android SDK absent on this host.
  Hosted Android success above is separate evidence, not a local installation.
- Manual Narrator/full-page keyboard protocol, clean-machine setup and manual
  release installation remain NOT RUN. Automated semantics are not Narrator.
- Report, video, official template/team metadata and contribution review remain
  submission work; none is completed by this documentation increment.
- Package A establishes this index and refreshes analysis/coverage checks.
  No new quality-runner script is added: existing runners already preserve
  exit codes and separate invocations. Avoid extra orchestration without need.
- Next: package B, draft/dirty-form protection, followed by C recovery/conflicts.
  See [upgrade roadmap](upgrade-roadmap.md). B-G are not implemented by A.

Do not add repetition counts to the number of unique tests or relabel earlier
failures/interrupted runs. New implementation increments require fresh gates.
