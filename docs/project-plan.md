# Implementation milestones

## Upgrade B1 edit slice - 2026-09-12

Implemented dirty edit dismissal, raw invalid date protection and pending-save
guard tests. Five isolated widget cases and the persisted edit/remount scenario
cover the slice. See upgrade-b1.md. Next: quick-create exit guard and B2; C-G
remain planned. No report changes.

## Upgrade roadmap - package A, 2026-09-12

User authorized stepwise implementation and publication to main-test.
Package A establishes docs/current-verified-state.md, reconciles historical
counts and commit/CI evidence, and refreshes local checks without changing app
code. See docs/upgrade-roadmap.md for acceptance and bounded B-G follow-up.
Stop at the phase boundary for team review; next implementation is B (draft safety).

## Bug audit - 2026-09-12

Inspect storage/controller, account concurrency, validation and UI lifecycles.
Reproduce confirmed failures with deterministic tests, then patch and run the
full Flutter/API/native/Edge gates. Preserve genuine fail/pass logs; do not
regenerate goldens to suppress regressions. No report or push in this request.

Confirmed/fixed: unknown snapshot overwrite, late logout clearing a newer
session, and invalid password after token refresh incorrectly signing out.
Six regression cases added; 72 Flutter tests and 14 backend tests pass.
Final platform/build gates and boundaries are recorded in evidence/manifest.md.

## Color studio refinement

Continue the existing uncommitted UI work: violet/mint/peach palette, decorative
geometric header and semantic priority surfaces. Preserve labels, contracts and
48-pixel targets. Review actual/expected golden images before replacement;
run accessibility, full tests and native gates. No publication/report work.

Result: 66 Flutter cases, 14 backend cases, 10 Windows cases and Web/Windows
builds PASS. Edge initially stalled on CDN renderer startup; bundled renderer
build then passed two repetitions. Original failed logs retained. Android and
manual Narrator remain NOT RUN. See color-studio-ui.md and evidence/manifest.md.

## UI refresh - 2026-09-11

User requested a comprehensive modern UI refresh, not report work or publication.
Plan: shared accessible visual tokens/components; responsive task workspace and
status navigation; cohesive auth/settings/dialog surfaces; preserve repository,
API, stable interaction labels and keyboard behavior. Review intentional golden
diffs before updating baselines, then run widget/accessibility/golden/native and
Edge checks plus release builds. No new runtime package, SDK or fabricated data.

Result: implemented and visually reviewed. Format/analyze, 66 Flutter tests
(11 goldens), 14 API tests, 10 Windows cases, Edge harness and Web/Windows release
builds PASS. Android/local APK and manual screen-reader checks remain NOT RUN.
No commit/push or report work performed. See evidence/manifest.md.

## Dedicated loading widget tests - 2026-09-10

Add isolated widget coverage for initial loading at compact/wide widths, delayed
load failure and gated Retry, and pending save/double-submit prevention. Use
Completer gates, not sleeps; assert progress semantics, disabled submission,
draft preservation, final data/empty state and restored controls. Do not change
app code or golden baselines. Verify focused tests plus full Flutter suite.

Result: focused 4/4 PASS; format/analyze PASS; full suite and coverage each PASS
61 cases with 8 unchanged goldens. Native/platform builds were not rerun for
this test-only change. See evidence/manifest.md for dated verification scope.

## Completed increment: Android CI and APK artifact - 2026-09-09

Add pinned GitHub Actions jobs for Windows quality gates, Android debug/release
APK creation, checksums and 9 Android API 36 workflow executions. Acceptance
requires every job to pass, both APKs plus `SHA256SUMS.txt` to upload, and exact
run evidence to be indexed without implying physical-device/manual-install scope.

Result: complete. Initial commit `60689a2` produced a superseded run whose Android
SDK executable lookup failed. Commit `9ca2a96` corrected the lookup and pinned
current action releases. Run
[#2](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886)
passed Windows quality, Android APK and Android E2E jobs. Artifact
`taskflow-android-apks` contains debug/release APKs and checksums with 14-day
retention. Manual APK installation/launch, a physical device, Android online mode,
production signing, clean-machine setup and manual accessibility remain.

## Current increment: fresh Edge sessions - 2026-09-10

User deferred report work. Extend the existing deterministic Edge runner across
fresh named browser sessions, retaining raw output, timestamps, exit codes and
separate workflow/lifecycle durations. Do not change the shipped app or baseline
images. Acceptance: three fresh sessions with two workflow repetitions each;
every failure retained and propagated; no replacement of earlier artifacts;
synthetic runner tests cover failure handling and even-count median; default Web
build restored. This is one-host evidence, not a clean-machine or Narrator pass.

Result: three fresh sessions / six workflow invocations PASS, with raw per-run
logs and browser lifecycle records. Synthetic runner contracts PASS. See
evidence/edge-sessions-20260910/README.md; final gate results are in the manifest.

## Completed increment: repeated test-level experiment - 2026-09-09

Run three separate Flutter processes per level (unit, widget, golden, Windows
integration), rotating level order across rounds. Capture raw output, exact
commands, exit codes, UTC start times and total process durations in a fresh
ignored directory. Acceptance: preserve every failure, return nonzero if any
case fails, retain unchanged goldens, publish a reviewed result with limitations.
The selected suites have different scopes; timings must not be treated as equal
workload benchmarks or compared directly with browser assertion-only durations.

Result: 12/12 real invocations PASS. Synthetic runner contract check confirms
nonzero failure propagation and preservation of all eight failure records.
Reviewed results: experiments/test-levels-20260909.md. Existing full quality-gate
logs cover unchanged app/backend code. User authorized publication to main-test.

## Current increment: account-settings accessibility - 2026-09-09

Audit the repository and rubric after the Edge harness milestone, then close the
remaining automated accessibility gap in the signed-in account settings screen.
Add semantic section headings, deterministic traversal within profile/password
forms, IME Next/Done behavior, autofill hints and focus recovery for invalid
profile, password and account-deletion actions. Cover narrow layout, 200% text,
semantics and accessibility guidelines with isolated widget tests.

Acceptance: no backend contract change; invalid actions make no HTTP request;
focus returns to the first invalid field; keyboard traversal follows the visible
form order; 390-pixel layout stays usable at 200% text; existing tests and goldens
remain green. Manual Narrator and whole-page physical keyboard checks remain
explicitly NOT RUN and have a reproducible protocol in accessibility-testing.md.

Result: acceptance checks PASS. The focused file passes 2 cases; the full Flutter
suite and coverage invocation pass 57 cases with all 8 existing goldens unchanged.
Backend 14/14, Windows 10/10, Windows/Web Release and one Edge harness smoke pass.
Android had not yet run in that increment, and manual assistive-technology checks
remain NOT RUN. Exact raw output is indexed in evidence/manifest.md; the later
Android CI result is recorded at the top of this file.

## Current increment: reproducible Edge harness - 2026-09-09

Flutter 3.47.1 reports that Web devices are not supported for integration tests.
Add a deliberately gated Web-only QA entrypoint backed only by deterministic
in-memory repositories, then drive it with the pinned Edge CLI. Cover blank-title
validation, controlled initial-load failure and Retry, controlled save failure,
draft preservation/retry, seeded search/filter/sort and exact order. The normal
main.dart build must not include this harness, preferences or an API client.

Acceptance: `flutter test ... -d edge` limitation retained as real output; harness
requires `TASKFLOW_BROWSER_HARNESS=true`; scenarios reset by URL; no sleeps,
credentials, network or persisted data; browser assertions return PASS; default
Web build restored after evidence; full local gates remain green. The initial
implementation request did not authorize publication; the user explicitly
authorized commit and push after reviewing the completed increment.

Result: complete Edge assertions PASS. Five consecutive same-session repetitions
PASS (mean 7.583 s, range 7.202-8.024 s); a separate full-orchestration smoke PASS
and restored the default build. These are bounded results, not a general failure
rate. Next: manual Narrator/full focus-order evidence and clean-machine/CI work.
The later increment above completed the initial hosted CI gate; the manual and
clean-machine work still remains.

## Current increment: safe samples, Edge and accessibility

Add an explicit ephemeral sample sandbox isolated from offline preferences and
online accounts. Verify no backend requests or offline mutations, reset by leaving
and re-entering. Expand account form guidelines, keyboard and 200% text tests.
Run Edge against a local isolated API and Web build, exercise account/task and
sample flows, retain readable evidence without credentials. Re-run quality gates,
update documentation and push this and the preceding local increment to main-test.

Result (2026-09-08): 55 Flutter, 14 API and 10 native Windows cases pass; eight
goldens unchanged. Edge online lifecycle/re-login and sample isolation checks
have evidence. See web-edge-testing.md and evidence/manifest.md. Next bounded
increment: automate browser filtered ordering/controlled retry, then manual
screen-reader/full keyboard audit and repeated-run timing/stability study.

## Previous increment: independent persisted lifecycle

Review the source, configuration and existing test/evidence boundaries, then add
three independently reset Windows real-preference scenarios: fresh create,
edit/complete/reload, and cancel/delete/undo/reload. Each uses its own test-only
storage key and verifies both UI and full saved data, including unaffected tasks.
Run the narrow suite followed by all local quality gates. Update the evidence,
README and AGENTS snapshot. That earlier request did not authorize another Git
push; the current explicit push request now includes this local increment.

Acceptance: no dependency on another test's creation steps; editing preserves
ID/createdAt and metadata; deletion cancellation is a no-op; confirmation removes
only the selected record; undo restores the entire record exactly once; repository
recreation and UI remount show the saved result. Never clear production preferences.

Result: all three new native cases pass. Full local checks pass with separate
native invocations: 49 Flutter, 14 API, 10 Windows cases; format/analyze and both
Windows/Web Release builds pass. The combined-file native runner failure is
preserved in evidence/manifest.md with successful standalone reruns. No production
code, golden baselines, SDK, secrets or user task data were changed in this increment.

Previous increment (2026-09-07): add independent native E2E discovery/recovery and
compact/wide validation scenarios, verify them and the existing quality gates,
update README/AGENTS and publish the backend plus this increment on `main-test`.
Acceptance: fresh state per scenario, exact filtered order, observable loading,
failed writes retain drafts/data, and explicit Retry recovers without duplication.
The full coursework specification remains the roadmap, not a claim of completion.

Acceptance verified: 4 independent native cases pass; format/analyze, 49 Flutter
tests (plain and coverage), 14 API tests, 2 native preference workflows, 1 native
online workflow and Windows/Web release builds pass. Android remains NOT RUN.
Evidence: docs/evidence/manifest.md. Next: independent edit/delete workflows,
browser evidence, stable demo-data entry, accessibility and repeated-run studies.

1. Verify SDK and repository. Preserve existing instructions.
2. Implement a first slice: validated title, local persistence, list, completion,
   search, loading and recoverable errors. Use repository injection and a clock/ID seam.
3. Verify domain/controller/widget behavior, analyze and build Web.
4. Commit the bootstrap and push to the user's repository.
5. Continue the testing case study, platform evidence, report and presentation.

Data model for bootstrap: immutable ID, title, createdAt and completed status.
Storage writes must succeed before publishing new state. Failed loads retain stored
data; retries read again. Test fakes isolate storage and can fail the next operation.

2026-09-06 milestone: title editing, delete confirmation and one-level session undo.
Acceptance: validation and write-failure recovery, preserved task fields, no concurrent
mutations, phone/wide widget flows and a persisted native Windows workflow.

2026-09-06 metadata milestone: notes (2000 characters), priority, calendar date,
normalized tags (10 x 24 characters), combined filters, deterministic sorting and
legacy JSON defaults. Acceptance includes validation, immutable tags, date boundaries,
preservation through edit/toggle/undo, phone/wide forms and native persistence.

2026-09-06 verification milestone: eight reviewed golden baselines, four automated
accessibility guideline states, keyboard/text-scale checks, stronger error text,
and controlled substring-search defect with genuine baseline/fail/fix-pass logs.
Acceptance: no golden updates in normal tests, corrected production search,
39 local tests and two Windows workflows passing; format/analyze and release builds.

Next after persisted lifecycle: browser automation, manual accessibility, demo seed entry point,
timing/stability methodology and pinned CI. Then clean-machine reproduction and
research/report/video/oral materials after official/team information is supplied.

2026-09-07 backend milestone: local Node/SQLite API; registration, opaque rotating
sessions, recovery codes, profile/password/account actions; isolated task CRUD,
discovery, statistics, revision-checked snapshots; Flutter gateway and remote
repository. API reference, backup utility and setup scripts included. Acceptance:
API/client tests and real Windows online workflow demonstrate ownership and stale
write rejection while old offline tests/goldens continue to pass. See backend-plan.md
and the latest evidence manifest for the exact current checks and limitations.
