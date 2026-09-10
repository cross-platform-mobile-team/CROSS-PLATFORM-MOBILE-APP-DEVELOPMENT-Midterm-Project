# Fresh Edge sessions: engineering verification, 2026-09-10

The user deferred report preparation. These are development verification notes,
not a coursework report or a claim of general browser reliability.

## Reproduce

```powershell
.\scripts\test-edge-harness.ps1 -Flutter C:\Users\LENOVO\flutter-sdk\bin\flutter.bat -Sessions 3 -Repetitions 2
.\scripts\tests\edge-runner-contract.ps1
```

Question: does the existing validation/discovery/retry workflow still pass after
closing Edge and opening a new non-persistent named session? Expected outcome:
the synthetic scenarios reset and all assertions pass in each session.

Controls: one Windows 11 host (10.0.26200.9168), Edge 152.0.4191.66, Flutter
3.47.1/Dart 3.13.1 and pinned Playwright CLI 0.1.19. Same Web harness build and
loopback server; no credentials, API or preferences. Each scenario resets by
navigation; every session is opened without `--persistent` or `--profile`, then
closed before the next. Browser-open logs retain distinct PIDs. This does not
clear OS, SDK, disk or network caches, nor establish a fresh operating system.

The browser assertion script is unchanged. Each run checks load retry, accessible
blank-title validation, save failure, retained draft, successful retry, normalized
search, AND filters, exact tag normalization, exact title order, no-match and
clear/reset. These are repeated observations, not six new independent test cases.

## Recorded results

| Fresh session | Workflow 1 (s) | Workflow 2 (s) | Session including open/close (s) | Result |
|---|---:|---:|---:|---|
| 1 | 7.606 | 6.836 | 19.940 | 2/2 PASS |
| 2 | 7.547 | 7.238 | 19.766 | 2/2 PASS |
| 3 | 7.936 | 6.806 | 19.650 | 2/2 PASS |

Six CLI invocations passed. Workflow mean: 7.328 s; range: 6.806-7.936 s.
Workflow duration includes the CLI call, navigation and assertions, but excludes
browser startup/close and the shared build/server lifecycle. Session duration
includes both workflows and browser lifecycle, not the shared build. Do not mix
these metrics with full Flutter command timing or infer a population flakiness
rate from this small, one-host sample. Background host load was not controlled.

Raw per-invocation output and commands: `session-1/`, `session-2/`, `session-3/`.
`sessions.json` records timestamps/lifecycle results; open/close logs confirm the
three browser lifecycles. `source.txt` records the parent source and in-progress
runner changes; the publication commit contains the final runner. The complete
orchestration log records harness compilation, PASS results, cleanup and restored
default `lib/main.dart` Web Release build. No golden image or Flutter app code
was changed.

`runner-contract-20260910.txt` is explicitly synthetic: success, absent PASS
marker with exit 0, PASS marker with exit 7, then success. It checks preservation
of all four outcomes, eventual failure, raw logs, overwrite refusal, successful
completion and even-count median. It is NOT browser evidence or the course's
intentional application defect. Genuine defect evidence remains in
[intentional_defect](../intentional_defect/README.md).

Remaining: another host/browser version, clean-machine setup, manual Narrator and
whole-page keyboard audit. Android/APK is NOT RUN on this local host because its
SDK is absent. During publication, three existing upstream commits were discovered
and retained: they document successful Windows/Android CI at `9ca2a96`, separate
from this local Edge run; see [Android CI evidence](../android-ci-20260909.md).
No report, video or official metadata was added in this increment.

## Native interruption retained

The first separate persisted-suite command stopped producing output after its
first case name (last output at approximately 11:32:48 UTC). It was interrupted
with Ctrl+C after remaining unchanged for over a minute; the shell returned 1.
`native-persisted_scenarios_test.txt` preserves that incomplete output. No root
cause was established and this attempt is not counted as PASS.

The unchanged suite was rerun alone with `--timeout 90s` (a diagnostic bound,
not a timeout increase). All three cases passed in about ten seconds after
build/launch; see `native-persisted-retry.txt`. This does not prove the original
stall is fixed or that native tests are universally stable. Prior two suites
passed 2 and 4 cases respectively. Retain both outcomes when presenting evidence.

## Synchronization boundary

Before pushing, the local work was rebased onto upstream ef45561, preserving its
three CI/Android commits. Upstream changed documentation, CI and the minimum Dart
constraint to 3.13.0; application/backend/test code and package versions were
unchanged. Local dependency resolution and the runner contract were rechecked
after synchronization. The Windows CI job now invokes the synthetic contract as
well; that hosted execution must be checked independently after push.
