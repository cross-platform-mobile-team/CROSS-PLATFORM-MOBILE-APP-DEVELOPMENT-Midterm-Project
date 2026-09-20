# Testing experiments and evaluation

## Evaluation protocol and evidence identity

Evaluation separates source identity, test selection, environment and observed outcome. The latest local evaluation uses commit 06d3790 plus the snapshot-capacity correction of 19 September, recorded under docs/evidence/risk-closure-20260919. The Flutter suite passed 104 cases with coverage enabled and the Node suite passed 17 cases. Earlier native, browser and hosted Android experiments keep their original evidence identities; they are not relabelled as executions of the updated source.

The latest local environment is Flutter 3.47.1 with Dart 3.13.1 on Windows 11, build 26200.9457, and Node 22.14.0 with built-in SQLite. The earlier Android target is Google APIs Android 16/API 36 x86_64, emulator 37.1.11, at 720 by 1280 pixels and density 240, with two cores and 2048 MB guest memory. SDK and caches are under D:/Android. Host PATH and SDK-manager license-status warnings remain documented rather than reported as a fully clean toolchain check.

Table 6.1 Results and their actual verification boundaries

| Check | Recorded outcome | Boundary and qualification |
| --- | --- | --- |
| Flutter analysis | PASS during report preparation | Static analysis, not runtime correctness |
| Flutter suite with coverage | 104 cases PASS on 19 September | Includes validation and golden checks; no coverage percentage asserted |
| Node API suite | 17 cases PASS on 19 September | Includes full 500-task snapshot, byte limits and unchanged rejected writes |
| Windows workflows | 15 cases PASS on 19 September | Six separate invocations, including real API/SQLite |
| Windows release build | PASS on 14 September | Not a clean-machine install certificate |
| Android local workflows | 15 cases PASS on 15 September | API 36 emulator; debug local API included |
| Android release | Build, install, launch and persistence PASS | Offline process restart; not physical-device HTTPS |
| iOS | NOT RUN | Scaffold only; Mac/Xcode required |
| Edge UI harness | Final 1 of 1 run PASS after corrections | Four earlier failed attempts retained; not a five-run success result |
| Android hosted gate | 9 executions PASS at 9ca2a96 | Historical API 36 emulator evidence, not the newest UI revision |

The 104-case total includes golden comparisons using checked-in baselines reviewed at 06d3790, without regeneration. The six native selections comprise four independent, three persisted, two preference-backed, one quick-create exit, four pending-capture and one online case. Windows repeated all 15 successfully on 19 September; Android retains its 15 September evidence. These are overlapping scenarios, not 30 distinct tests.

The snapshot endpoint accepts 500 records within an authenticated 8 MiB budget; other routes retain 1 MiB. Tests round-trip maximum-length notes and multibyte tags and verify rejection without mutation for stale revisions, excess records and excess bytes. CI now selects all six native suites; hosted execution remains pending.

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

Independent fixtures and meaningful assertions support internal validity. Fake failures simplify real transport behavior; golden comparisons depend on fonts and rendering; timings include overhead and unequal workloads. Browser-script corrections change the procedure, so earlier failed attempts remain available.

External validity is limited by the small coursework dataset and selected Windows host and Android emulator. The eager task list has not been stress-tested at the server's 500-record acceptance limit. No frame-time or sustained API-load study is reported. The local Android API workflow does not establish physical-device connectivity, release HTTPS operation or production signing.

Automated accessibility checks do not establish screen-reader usability, and remount does not establish process-restart persistence. Passing test counts alone cannot establish absence of defects.

The Android release check adds a stronger persistence boundary than UI remount: a task entered through Android input events remained visible after force-stop and relaunch. This does not establish an operating-system reboot or general input-method compatibility. The APK is 53,112,106 bytes; its checksum and installation commands are retained in the platform evidence package.

Remaining evidence gates are manual screen-reader and whole-page keyboard testing, clean-machine setup and Mac-based execution for the additional iOS target. Android account verification covers the debug emulator against a local API, not a release HTTPS deployment. Submission additionally requires the team's English presentation video and a confirmed contribution record. These items remain separate from document completion.
