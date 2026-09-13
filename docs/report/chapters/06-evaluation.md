# Testing experiments and evaluation

## Evaluation protocol and evidence identity

Evaluation separates source identity, test selection, environment and observed outcome. The evaluated working tree is baseline 39dd199 plus the draft-consistency update. On 13 September 2026, the updated Flutter suite ran with coverage enabled, the Node API suite ran locally and the Windows draft-exit case passed. Logs are retained under docs/evidence/capture-fix/. These fresh checks are distinct from the retained desktop UI milestone and earlier Android CI. No historical result is relabelled as a new execution.

The local Flutter environment is Flutter 3.47.1 with Dart 3.13.1 on Windows 11, build 26200.9445. The backend uses Node 22.14.0 and the runtime's built-in SQLite support. Android SDK availability differs between the local and earlier hosts. This report therefore uses the dated hosted Android record rather than implying that the present machine executed Android tests during preparation.

Table 6.1 Results and their actual verification boundaries

| Check | Recorded outcome | Boundary and qualification |
| --- | --- | --- |
| Flutter analysis | PASS during report preparation | Static analysis, not runtime correctness |
| Flutter suite with coverage | 100 cases PASS on 13 September | Includes four new draft-consistency cases; no coverage percentage asserted |
| Node API suite | 14 cases PASS on 13 September | Local HTTP, account and SQLite behaviors |
| Windows workflows | Draft-exit case PASS; historical 11-case selection PASS | New exit check distinguished from retained native/API workflows |
| Windows release build | PASS in retained minimal UI evidence | Build result, not a clean-machine install certificate |
| Edge UI harness | Final 1 of 1 run PASS after corrections | Four earlier failed attempts retained; not a five-run success result |
| Android hosted gate | 9 executions PASS at 9ca2a96 | Historical API 36 emulator evidence, not the newest UI revision |

The 100-case result is not added to 15 golden images as though they were unrelated test populations. Golden comparisons are included in the Flutter suite and maintain 15 unchanged baseline images. Similarly, the historical 11 native cases describe selected Windows workflows rather than 11 different platforms. Counting is useful for locating evidence, but the acceptance conditions determine what those counts mean.

## Scenario design and assertion strength

The fresh-create scenario begins with isolated storage, observes an empty state, submits a valid record and checks its appearance. A validation scenario submits invalid input, observes readable validation, corrects the form and verifies a successful save. Discovery scenarios seed known records and assert normalized search, combined filters and exact ordering. Edit, completion, delete and undo scenarios compare full records and unaffected tasks where appropriate.

The persisted suite resets only its dedicated test preference keys. It does not clear all preferences on the host. A fresh repository and UI remount then verifies that persisted records can be read back. This is stronger than checking the previous widget's in-memory list, but it remains a remount rather than terminating and restarting the operating-system process. The distinction is stated because both actions are sometimes described imprecisely as a restart.

Independent controlled-repository cases exercise compact and wide validation, seeded discovery and recovery from load or write failures. Each case receives a fresh repository and resets its viewport. Completion gates make the pending interval observable. The online Windows scenario adds the actual API and isolated SQLite store. Separating these cases makes a failure easier to localize than a single long scenario that depends on the records created by every preceding step.

An adequate assertion checks the intended invariant. After editing, retaining the identifier and metadata matters. After filtering, exact membership matters. After deleting one task, preserving another matters. After retry, preventing duplicate writes matters. These are stronger oracles than merely checking that no exception escaped, or that a button responded to a tap.

## Intentional semantic defect

The intentional-defect experiment asks whether UI automation detects a search error that leaves compilation and basic navigation intact. The correct implementation uses normalized substring matching. The temporary faulty patch replaces that comparison with prefix matching. The fixture contains Review Flutter testing and Write report, and the query includes surrounding whitespace and uppercase text: FLUTTER. The first task should still match because normalization and substring search are both required.

The baseline regression test passed before the change. With the faulty comparison, the expected task could not be found and the command failed. Restoring substring matching made the same regression pass again. The repository retains the buggy patch, corrected patch and unedited baseline, failure and recovery logs. The permanent test remains in the corrected source tree; the production implementation is not left intentionally defective.

Table 6.2 Deliberate search-defect experiment

| Stage | Observation | Interpretation |
| --- | --- | --- |
| Baseline | One regression case PASS, exit 0 | Correct search satisfies this fixture |
| Fault injection | Same case FAIL, exit 1 | Prefix-only search loses a middle-word match |
| Correction | Same case PASS, exit 0 | Restored substring behavior satisfies the oracle |

This experiment supports RQ2 with a genuine semantic failure rather than a fabricated log or a deliberately invalid syntax change. It does not estimate mutation score or general defect-detection probability. Only one selected defect and one regression case were used, with one recorded run at each stage. Broader mutation testing could be useful later, but it is not a result of this experiment.

## Test-level timing experiment

A separate experiment recorded three rounds of selected test levels on one Windows host. Each command used a fresh Flutter invocation, with the order rotated across rounds and dependencies already resolved. The measured duration is whole-command wall time, including process startup and, for native execution, build and launch overhead. The selected workloads are unequal: four unit cases, one widget case, eight golden cases and four native controlled-repository cases.

Table 6.3 Whole-command duration in seconds for the selected suites

| Selection | Three recorded durations in seconds | Arithmetic mean in seconds |
| --- | --- | --- |
| Unit, 4 cases | 4.707 / 4.360 / 5.499 | 4.855 |
| Widget, 1 case | 6.111 / 6.436 / 6.733 | 6.427 |
| Golden, 8 cases | 8.857 / 8.074 / 7.113 | 8.015 |
| Windows integration, 4 cases | 41.812 / 40.525 / 38.814 | 40.384 |

All twelve selected commands passed. Within this setup, the native selection required substantially more wall time than the other selected commands. That observation helps justify running narrow tests during development before the larger native gate. It does not establish a fair per-test speed ranking, because the scenario counts and assertions differ, nor does it predict cold-cache CI duration.

The small sample cannot support a general reliability estimate. Three successful repetitions can reveal an immediate deterministic failure, but rare timing failures may remain unseen. Warm caches and one host also restrict external validity. The most useful conclusion is procedural: retain raw results, state the workload and rotate order, then avoid converting a small local experiment into an unsupported universal comparison.

## Browser automation and maintenance findings

The browser harness is compiled through an explicit QA entry point and uses synthetic in-memory data. It can hold repository operations and inject failures without touching account data or preferences. A separate real API scenario covers account task lifecycle. These two forms of browser testing must be reported independently because the controlled harness does not establish actual persistence or network behavior.

During the desktop redesign, the harness initially searched for an old heading. A later attempt assumed the input's accessible name was unchanged after focus, while the observed name included a second line. The corrected script checks the intended first line and verifies the active input before typing. Four failed attempts and the final successful run are retained. This is evidence of automation maintenance after a legitimate UI change, not evidence that four application defects were found and fixed.

The earlier browser stability experiment and multi-session work remain useful historical observations, but the current one-run success cannot inherit their repetition count. The script also retains raw outputs and exit codes and restores the default Web build after the harness. Those safeguards improve the reproducibility of evidence collection. They do not prove that all browsers, clean machines or assistive technologies behave identically.

## Threats to validity and remaining gates

Internal validity depends on using independent fixtures and meaningful assertions. A fake may model an error more simply than a real transport failure, so a passing recovery test is not a complete network proof. Golden results depend on fonts and rendering environment. Test-level timings include overhead and unequal work. Browser-script corrections change the measurement procedure, which is why previous failed attempts remain visible rather than being replaced.

External validity is limited by the small coursework dataset, the selected Windows host and historical emulator configuration. The eager task list has not been stress-tested at the server's 500-record acceptance limit. No frame-time or sustained API-load study is reported. A successful APK build or hosted emulator test does not establish manual physical-device installation, account-mode connectivity on Android or production signing.

Construct validity also matters. Automated accessibility guidelines do not equal a complete screen-reader review, and successful remount does not equal process restart. Passing the selected checks does not imply absence of bugs. These distinctions prevent convenience metrics, especially total test count, from replacing the actual user risks under evaluation.

The next evidence gates are manual screen-reader and whole-page keyboard testing, clean-machine setup, release-artifact installation and current-revision Android verification where the environment allows it. Submission readiness additionally requires closure of open engineering findings, the team's presentation video and a confirmed contribution record. These items remain separate from the document's formatting and narrative completion.
