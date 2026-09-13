# Appendix A Reproduction guide

## Environment and safe setup

Check out branch main-test and record the exact source revision before repeating a result. Use the pinned project SDK expectations and resolved pubspec.lock. On the report-preparation machine, Flutter is installed at C:/Users/LENOVO/flutter-sdk and is not on PATH. Run flutter --version, dart --version, flutter doctor -v and flutter devices before selecting a native target. The commands below assume the corresponding executables are on PATH; otherwise use their full paths. Do not install an SDK or change system configuration merely to reproduce a document claim.

Run flutter pub get, then flutter analyze and flutter test --coverage. The backend gate is node --test backend/test/*.test.js. Keep output and exit status together. The report does not publish a coverage percentage because a percentage was not calculated and checked for this manuscript. A generated coverage file alone should not be converted into an invented coverage claim.

Run native suites in separate invocations. The selected files are integration_test/independent_scenarios_test.dart, integration_test/persisted_scenarios_test.dart, integration_test/quick_create_exit_test.dart and integration_test/windows_workflow_test.dart. Use flutter test followed by the actual file and -d windows. Verify the current filenames against the repository before execution. The real API workflow is orchestrated by scripts/test-online-windows.ps1 with an isolated service and database. Never direct synthetic test accounts or destructive account tests at a production endpoint.

For browser reproduction, inspect scripts/test-edge-harness.ps1 and its supported parameters. It manages a QA build, server and isolated browser session, retains logs and restores the default Web build. The harness is a controlled in-memory test surface, not a replacement for the separate online browser lifecycle evidence. Output folders are unique and must not be overwritten to hide unsuccessful attempts.

## Deliberate defect safety

The intentional-defect package is docs/evidence/intentional_defect. Read its README before using either patch. Reproduce the defect only in an isolated worktree, run test/widget/search_regression_test.dart, then restore the corrected implementation and rerun the same test. Do not leave the faulty search in the development branch. A patch failing to apply to a later revision requires inspection, not forceful replacement of unrelated work.

Additional engineering findings and their original diagnostics are maintained separately in docs/report/DEFERRED_REVIEW.md for a later manuscript update. They are outside the selected experiment results reported here and have not been relabelled as passing checks.

# Appendix B Evidence index

Table B.1 Evidence packages used in this report

| Package or file | Purpose | Interpretation |
| --- | --- | --- |
| docs/evidence/manifest.md | Master evidence inventory | Consult dated sections and source revisions |
| docs/evidence/minimal-ui-20260913 | Current UI milestone logs | Windows, Flutter, API and corrected Edge run |
| docs/evidence/intentional_defect | Baseline, faulty patch, fail log and fix pass | One selected search defect |
| docs/experiments/test-levels-20260909.md | Experiment method and timing summary | Unequal workloads, three rounds, one host |
| docs/evidence/test-levels-20260909 | Raw timing outputs | Whole-command wall time |
| docs/evidence/android-ci-20260909.md | Hosted Android result | Historical revision 9ca2a96 |
| docs/accessibility-testing.md | Automated scope and manual protocol | Manual protocol remains unexecuted |
| docs/report/evidence | Fresh report-preparation suite logs | Additional review tracked separately |

# Appendix C Submission verification

The recorded team is Nguyễn Bá Hùng, student ID 523K0006, and Nguyễn Bảo Long, student ID 523K0014. Both members belong to class 23K50201, Faculty of Information Technology, major Software Engineering. The instructor is Mai Văn Mạnh. Submission date, signatures and individual contribution allocation require confirmation by the team; no percentage or signed declaration is supplied here.

Before submission, both members should verify the report against the final source revision, reproduce the central workflows and explain the intentional defect. The final source package must retain configuration examples and dependencies but exclude secrets and generated caches. The course additionally requires a usable English presentation video within its time limit and meaningful participation by every member. Report completion does not substitute for those deliverables.
