# UI/UX audit implementation — 11 October 2026

Agent-assisted engineering notes for student review. Implements the supplied
`UIUX-audit-TaskFlow.md` (10 October), in its four ordered increments.
No commit, push, report or real account data mutation is authorized by this work.
Pre-existing registration confirmation and recovery-code copy changes are retained.

## Plan and traceability

| Audit | Implementation | Verification |
|---|---|---|
| 1, 2, 5, 7, 11 | Compact header/create, visible status and removable conditions, separate search/filter reset, compact metadata/notes, empty actions | uiux_layout_test; existing draft/keyboard/semantics tests; reviewed golden differences |
| 3, 4 | Operation labels, hidden-add feedback, retained edit draft, explicit reload/compare/apply, deleted-task recreation | uiux_recovery_test with controlled HTTP responses and pending future; pending_capture_test |
| 6, 8, 9 | Injected calendar clock, friendly labels, local/sample descriptions, local session times, dirty account exit, password visibility | uiux_layout_test date boundaries; uiux_account_test; account accessibility regressions |
| 10 | Isolated 100/500 records with long notes, Windows profile search/filter/scroll | integration_test/uiux_performance_test.dart; completed eager/lazy profile measurements below |

## Evidence and outstanding checks

Working logs are in ignored `build/uiux-*.log`; initial failures are retained.
Golden review sheets are `build/uiux-review-0.png` through `-3.png`, with expected
and difference sheets `build/uiux-diff-0.png` through `-3.png`.
13 changed baselines were visually reviewed; the two edit-dialog baselines did
not change. Comparison tolerance is unchanged. Two additional audit baselines cover the 390x844 screen and retained-draft comparison. Final verification and limitations are indexed in [the evidence record](evidence/uiux-audit-20261011/README.md).

Tests with fake HTTP are not real-server/native evidence. Logical viewport and
keyboard-inset tests do not establish hardware keyboard or Android behavior.
Narrator/TalkBack/VoiceOver and iOS remain unverified. Android is not connected.
Do not infer FPS from widget-test durations. The first attempted profile command
(`flutter test --profile`) was rejected by this SDK; the corrected runner uses
`flutter drive --profile` with the integration-test driver.

## Windows profile measurement

Both complete 100/500-task runs passed using `flutter drive --driver=test_driver/uiux_performance_driver.dart --target=integration_test/uiux_performance_test.dart -d windows --profile --no-pub`.
Windows 11 10.0.26200.9457; Intel Core i7-12700H; RTX 4050 Laptop / Iris Xe present (active renderer GPU not established); Flutter 3.47.0/Dart 3.13.0. Runtime logical viewport 1265.6 x 682.4. Synthetic in-memory records only, 1900-character notes, priority/status mixtures; no preferences or API. Four search changes, three status changes, eight scroll flings per dataset. One completed run per strategy, with no concurrent test/build workload during the measured action windows.

The eager baseline is the compact UI from increments 1–3 before replacing its list. The final list uses `CustomScrollView`/`SliverList`; the header is retained, task keys have a child-index callback, semantics retain ordinal keys, expanded notes/focused actions request keep-alive.

| Tasks / action | Eager frames | Lazy frames | Eager mean build ms | Lazy mean build ms | Eager worst build ms | Lazy worst build ms |
|---|---:|---:|---:|---:|---:|---:|
| 100 / search | 10 | 10 | 20.443 | 4.91 | 143.07 | 25.648 |
| 100 / filter | 14 | 14 | 14.458 | 2.673 | 88.786 | 11.058 |
| 100 / scroll | 444 | 455 | 6.716 | 0.371 | 25.865 | 4.144 |
| 500 / search | 11 | 10 | 179.163 | 6.511 | 1277.035 | 22.88 |
| 500 / filter | 5 | 14 | 420.933 | 3.346 | 1017.531 | 15.785 |
| 500 / scroll | 432 | 455 | 37.278 | 0.38 | 106.898 | 5.536 |

These are engine FrameTiming build measurements from profile mode, not widget-test duration or FPS. Action/sample counts differ because frame scheduling changes with work. This exploratory single-host comparison supports lazy construction for large lists; it is not a universal speedup or absence-of-jank claim. Some lazy search frames still exceed 16.67 ms. Full raw build/raster/GC arrays are in [profile-metrics.json](evidence/uiux-audit-20261011/profile-metrics.json). Initial runner mistakes (`flutter test --profile`, then an incorrect completed-status locator) remain in separate logs and are not PASS evidence.

## Follow-up: Android loopback fix

The later [Android build follow-up](android-loopback-fix-20261011.md) resolves the APK blocker using a scoped Java TCP fallback and records actual emulator verification. The original results below are retained as the earlier audit snapshot. Full manual screen-reader and iOS verification remain separate.

## Final verification

- 133 Flutter unit/widget/golden cases PASS, including five controlled online recovery scenarios. Recreation reserves one task ID per open dialog; after a lost response, reloading finds the committed replacement and offers Close rather than another insert.
- Format and static analysis PASS. 17 backend cases PASS. Browser script syntax checks PASS; browser interaction runners were not rerun on this host.
- 15 Windows native cases PASS in separate invocations, including isolated real API/SQLite online lifecycle. The online case is rerun after the final recovery identity fix; other native cases precede that narrowly scoped fix.
- Web release build PASS. Android APK build remains blocked by Java/Gradle `Unable to establish loopback connection` (`Invalid argument: connect`). Installed JDK 17, JDK 21 and Android Studio JBR 25 reproduce it; a process-scoped short socket directory did not fix it. No SDK installation or global environment change was made.
- No current Android/iOS native run or manual screen-reader verification. Windows profile timing does not establish mobile performance. No commit/push.

Before/after goldens, review sheets, successful checks and failed attempts are retained in the evidence directory. Before images are extracted from Git HEAD, while after images are the reviewed current baselines. These are deterministic Flutter renders, not device screenshots. The supplied audit is the scope source; the missing original course PDF was not reconstructed.
