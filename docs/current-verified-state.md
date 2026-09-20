# Current verified state

20 September publication continuation: user authorized pushing the reviewed
risk-closure increment to main-test after repeat checks. Windows, Web and APK
release builds PASS; the older no-push statement below describes capture time.

## Risk closure — 2026-09-19

Baseline 06d3790 plus local snapshot-capacity correction: 104 Flutter,
17 API and 15 Windows native cases PASS; analyze and format PASS.
See [scope and remaining acceptance](risk-closure-20260919.md) and
[original logs](evidence/risk-closure-20260919/README.md).
Expanded Windows/Android CI is not yet hosted-verified. Only Windows hardware
is available; iOS, physical Android and manual Narrator remain unverified.
No new commit/push is implied. Historical entries below retain their dates.

## System fixes — 2026-09-16

Implementation `bba02cd` follows `04105d6` with five fixes: atomic Android
environment setup, portable Flutter resolution, strict API creation dates,
visible task-form validation recovery, and fail-fast backend CI checks.
[Commands and original fail/pass outputs](evidence/system-fixes-20260916/README.md).
103 Flutter cases including 15 unchanged goldens, 15 API cases, three persisted
Windows cases and one Windows API case PASS. Windows and Web release builds PASS.
Local Android rerun is NOT RUN: the C: host lacks SDK platform 36 and has no
connected emulator. Previous platform and report evidence below remains dated.

## Platform audit and publication review — 2026-09-15

Latest: [progress review](project-progress-20260915.md) and
[platform evidence](evidence/platform-audit-20260915/README.md).
100 Flutter cases and 14 API cases PASS, repeated during publication review.
Android: 15 native cases and release install/launch/restart persistence PASS.
Windows: 15 native cases and release build PASS on 14 September.
iOS scaffold exists; build/run NOT RUN without Mac/Xcode. No new Edge run.
Submission readiness is estimated at 80%, not an expected grade or bug-free claim.
The entries below are historical, not the latest platform status.

## Minimal desktop UI — 2026-09-13 (local worktree)

User-requested indigo/off-white TaskFlow workspace: see minimal-desktop-ui.md.
96 Flutter cases PASS, including 15 reviewed new goldens; 14 backend cases PASS;
11 Windows E2E cases PASS across separate invocations; Windows Release PASS.
Exact commands/logs and Edge status are in the latest evidence manifest.
Earlier 92-case/unchanged-golden statements below describe the previous slice.
No new commit, push, hosted CI or Android execution is claimed.

## Quick-create exit increment - 2026-09-12

UI spacing was published as 4913c2d after an additional 84-case PASS. The next
slice protects explicit offline/sample draft exits; its full Flutter coverage
run passes 92 cases, 15 unchanged goldens, including metadata-after-rebuild safety.
New independent Windows case adds
one to the previous ten; see latest manifest for each gate and quick-create-exit.md
for scope. Historical references to uncommitted UI below describe capture time.
Hosted results for older SHAs must not be assigned to this increment.

## Historical UI spacing capture - 2026-09-12

After abbc203: form gaps, enlarged dropdowns, floating-label clipping and
redundant dirty-state rebuilds fixed. Flutter coverage invocation passes 84
cases with 15 goldens (four added/reviewed, eleven unchanged). See
[UI audit](ui-spacing-20260912.md) and latest manifest. This was uncommitted at
capture time, then published as 4913c2d; run 34697153061 subsequently succeeded.

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
