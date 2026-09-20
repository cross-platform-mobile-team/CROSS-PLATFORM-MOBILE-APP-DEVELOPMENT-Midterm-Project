# Risk closure on 19 September 2026

Publication continuation, 20 September: the user authorized completing checks
and pushing this increment to main-test. Windows, Web and Android release builds
all completed successfully. Hosted CI must still be verified for the published
SHA; local passing runs do not establish hosted success.

Scope: resolve the reviewed engineering and evidence risks, excluding video work.
The team confirmed that only a Windows computer is available. No new platform,
service, SDK installation, publication or production-readiness claim is implied.

## Changes and verification

| Reviewed risk | Action | Status |
| --- | --- | --- |
| Checkout behind remote | Fast-forwarded eight commits from 04105d6 to 06d3790 | Resolved locally |
| Valid large snapshot rejected at 1 MiB | Authenticated snapshot PUT has an 8 MiB budget; other routes retain 1 MiB; 500-record count and revision checks remain | Regression reproduced before fix; 17 API cases PASS after fix |
| Missing native CI selections | Windows job runs all six selections; Android adds capture/exit and isolated API workflow; Node pinned to 22.14.0 | Configured; hosted execution NOT RUN until publication |
| Report and source evidence drift | Updated shared report source, Word and LaTeX results to 104 Flutter / 17 API; dated native evidence stays separate | Updated locally; see report QA |
| Current Windows behavior | All six independent invocations repeated | 15 cases PASS |
| Updated backend on Android | Existing API 36 emulator, debug build/install, isolated real API/SQLite | Online account lifecycle and optimistic conflict case PASS |
| Manual accessibility | Existing automated semantics, validation, focus and golden checks pass; manual acceptance checklist below | Narrator and full traversal NOT RUN |
| Clean-machine reproducibility | Setup scripts have synthetic path/failure contracts; CI uses hosted runners | No independent clean-machine execution in this increment |
| iOS / physical Android | Neither is available; retained Android emulator and Windows evidence cover the required pair | Additional targets remain unverified, not release claims |

The new API tests use an isolated database and synthetic account. A 500-record
payload includes 2,000-character notes encoded as six-byte JSON escapes and
multibyte tags. Successful round-trip, stale revision rejection, 501-record
rejection, over-budget rejection and unauthenticated access are asserted.
Rejected writes must leave the stored collection unchanged. This is a functional
capacity regression, not a throughput benchmark or UI performance measurement.

## Windows acceptance still requiring a person

No installation is necessary. Use Windows Narrator (Win+Ctrl+Enter), synthetic
data and the sample workspace. Do not use personal accounts or real task data.
Record date, source revision, Windows version, action and observed result.

1. Open the app with only the keyboard. Traverse account entry, sample entry,
   sidebar, quick capture, metadata controls, search, filters and sorting with
   Tab and Shift+Tab. Check visible focus, sensible order and no keyboard trap.
2. Submit an empty title. Confirm that focus returns to the title and Narrator
   identifies its label and validation. Correct it and create one task.
3. Open/edit that task, change metadata, press Escape and verify the unsaved
   changes confirmation. Continue editing, then save. Confirm the task identity
   and values remain intact.
4. Open/close filters, search for a missing task, clear filters, complete a task,
   delete with confirmation and undo. Check labels, status announcements and
   focus restoration; screen-reader speech must be observed, not inferred.
5. Resize from wide desktop to narrow layout and repeat at 200% text scaling.
   Confirm readable errors, reachable actions and no clipped content.
6. Exit Narrator using the same shortcut. Record PASS/FAIL per action; include
   actual missing announcements or focus losses. Do not mark the whole protocol
   PASS from the existing widget tests.

The desktop automation runtime failed to initialize before interacting with the
app in this session. This is a tooling limitation, not evidence of an app defect
or successful manual accessibility acceptance.

## Clean setup and publication boundary

After an explicitly requested push, inspect the new hosted workflow for that
exact SHA. Its Windows/Android jobs are fresh-runner automated evidence, not a
human clean-machine install test. Download the complete Windows Release folder
or APK, verify checksums, install/launch, create a synthetic task, terminate and
restart the app, and verify persistence on an available independent environment.
Do not install Windows Sandbox, a VM, or paid services without separate approval.

No video was created or edited. Contribution allocation and signatures still
require both students' confirmation. The earlier 80% estimate remains a dated
planning estimate; this change is not a new grade or 100% readiness claim.
