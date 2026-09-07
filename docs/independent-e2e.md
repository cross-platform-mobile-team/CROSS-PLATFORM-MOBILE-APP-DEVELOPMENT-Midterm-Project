# Independent native E2E scenarios

Student-review draft, implemented and run on Windows on 2026-09-07.
This increment follows Topic 4's emphasis on meaningful scenario evidence,
not additional unrelated application features.

## Reproduce

From the repository root with the pinned Flutter 3.47.1 SDK:

```powershell
& 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat' test integration_test/independent_scenarios_test.dart -d windows --reporter expanded
```

No backend, account, preference reset or demo button is needed. Each test injects
a new InMemoryTaskRepository; none modifies the user's actual task data.

| Case | Controlled input | User action and assertion |
|---|---|---|
| Compact validation | Empty repository; width 390 | Empty state, invalid submit, readable error, correction, exactly one saved task |
| Wide validation | Empty repository; width 1100 | Same workflow and assertions, no framework exception |
| Discovery | Four fixed-ID/date tasks with distinct priority/status | Padded uppercase substring, pending AND high AND normalized tag, title order Alpha/Beta, no-match state, clear restores newest order and all four tasks |
| Recovery | Fail first load; gated retry; fail first save | Error, explicit Retry, observable loading and disabled submit, empty recovery, draft retained after failed write, reload and successful save without duplication |

The discovery assertion checks both the list of user-visible titles and their
vertical order. The initial newest order differs from the requested title order,
so a no-op sorting implementation cannot satisfy the test. Filters exclude a
low-priority task and a completed task independently. Fixed dates avoid dependence
on today's date; this scenario does not claim coverage of due-date boundaries.

The recovery test uses a Completer gate, not elapsed-time sleeps. It observes a
pending frame before releasing the operation. Do not call pumpAndSettle while the
gate is closed: the progress animation intentionally keeps scheduling frames.
After release, normal bounded settling is appropriate. UI assertions are paired
with repository assertions so a visible card alone cannot mask a failed save.

## Fidelity and limits

The runner launches a native Windows Flutter application with actual widgets,
navigation, validation, rendering and controller logic. The repository is a
controlled fake, not SQLite or native preference I/O. Real preferences remain
covered by windows_workflow_test.dart; real HTTP/SQLite by online_workflow_test.dart
through scripts/test-online-windows.ps1.

Logical view sizes are 390x1600 and 1100x1600, device-pixel ratio 1, reset after
each test. These are test rendering overrides, not an Android device, a physical
window-resizing test or a second platform. The registered Flutter test input
channel avoids Windows IME interference; it does not test the real IME.

Four passing cases in one run do not establish a flakiness rate or timing
benchmark. Edit/completion and delete/undo remain combined real-storage workflows;
fully independent versions, browser E2E, manual accessibility and repeated-run
experiments remain next work. See evidence/manifest.md for genuine command output.
