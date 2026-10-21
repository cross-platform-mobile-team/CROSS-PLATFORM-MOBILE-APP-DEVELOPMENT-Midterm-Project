# Historical engineering records

Consolidated on 21 October 2026 to reduce standalone Markdown files. Each
section preserves a dated record, its qualifications and assistance disclosure.
Its commands and local paths describe that historical checkout. Current setup
belongs in the project README; original logs remain under docs/evidence.
No result is relabelled as a new execution.

## Record index

- [docs/automation-audit-20260922.md](#automation-audit-20260922)
- [docs/color-motion-ui-20260921.md](#color-motion-ui-20260921)
- [docs/risk-closure-20260919.md](#risk-closure-20260919)
- [docs/project-progress-20260915.md](#project-progress-20260915)
- [docs/platform-audit-20260914.md](#platform-audit-20260914)
- [docs/ui-spacing-20260912.md](#ui-spacing-20260912)
- [docs/bug-audit-20260912.md](#bug-audit-20260912)
- [docs/ui-refresh-20260911.md](#ui-refresh-20260911)
- [docs/project-review-20260909.md](#project-review-20260909)
- [docs/project-review-20260907.md](#project-review-20260907)
- [docs/upgrade-b1.md](#upgrade-b1)
- [docs/quick-create-exit.md](#quick-create-exit)
- [docs/minimal-desktop-ui.md](#minimal-desktop-ui)
- [docs/color-studio-ui.md](#color-studio-ui)
- [docs/GITHUB-CLEANUP-REVIEW.md](#github-cleanup-review)

<a id="automation-audit-20260922"></a>

Original path: `docs/automation-audit-20260922.md`

## Automation audit and publication — 22 September 2026

The user authorized finishing or improving automation, fixing detected defects,
and publishing verified changes to main-test. This includes the previously
local color/motion UI. No claim of universal bug freedom or a guaranteed grade.

### Acceptance plan

1. Review existing unit, widget, golden, native and browser scope against Topic 4.
2. Extend motion regressions for parent rebuild/draft identity and runtime
   reduced-motion preference changes, without weakening existing assertions.
3. Run format, analyze, full Flutter coverage, API and script contracts; rerun
   Edge in isolated sessions and native workflows. Preserve unsuccessful logs.
4. Review source/evidence/ignore rules, commit and push main-test without force;
   compare local and remote SHA. Distinguish hosted CI from local results.

### Scope boundaries

The core testing levels and intentional-defect experiment already exist.
Passing the selected scenarios is not proof that every possible input or device
is correct. iOS requires macOS/Xcode and remains unverified on this Windows-only
host. Manual Narrator, physical devices and frame-time profiling are separate
acceptance activities, not inferred from automated semantics or build success.

Results are indexed in evidence/automation-audit-20260922/README.md.

### Findings and resolution

Two accessibility regressions were found in the UI refresh: decorative Focus
merged labels, and keyed task reordering left Web semantics order/positions
stale relative to the canvas. Keep includeSemantics:false on the observer,
explicit card semantics containers and ordinal sort keys. Browser tests also
now tolerate only the exact focused/unfocused title labels and wait for selected
dropdown values and the exact ordered task set. They retain all functional
assertions. Failed attempts and emulator crashes remain in the evidence index.

The post-fix Flutter suite has 110 passing cases. Final browser verification
passed four repetitions across two independent Edge sessions. Android's 15
cases passed on the existing API 36 emulator with host rendering; headless
renderer crashes were diagnosed from Windows events and are not hidden.
Windows also passed all 15 post-fix native cases. Format/analyze, 17 API cases
and Windows/Web/APK release builds passed; final APK completion was verified on
24 September. This closes the scoped local automation audit, not manual or iOS
acceptance, nor a claim that every possible bug has been excluded.

### Required automation coverage map

| Requirement | Implementation / evidence |
|---|---|
| Business rules and persistence | test/unit, task controller/metadata/CRUD/API tests |
| Validation, loading/error/empty and recovery | test/widget, independent native scenarios, Edge harness |
| Visual regressions at phone/wide sizes | 15 reviewed golden baselines, full Flutter suite |
| Create, search/AND filters/sort, edit/complete, delete/undo | independent_scenarios, persisted_scenarios, windows_workflow |
| Drafts and asynchronous save safety | quick_create_exit, pending_capture, widget draft tests |
| Genuine defect detection | intentional_defect baseline/fail/fix logs plus this audit's semantics regression |
| Native and browser execution | dated Windows/Android logs and Edge repetitions, not generated platform folders |

This map describes coverage of the specified scenario groups, not a percentage
of all possible behaviors. Manual acceptance and unsupported hardware cannot
be marked complete by adding more automated test cases.

<a id="color-motion-ui-20260921"></a>

Original path: `docs/color-motion-ui-20260921.md`

## Color and motion UI refresh

User request: a more colorful, modern interface with smooth transitions.
Baseline b4479e3; implementation only, no push or report changes authorized.

### Plan and acceptance

1. Add shared iris/mint/peach surfaces and bounded motion tokens with no package.
2. Refresh sidebar, greeting/progress, quick capture, cards and shared panels.
   Keep existing visible labels, keys, keyboard actions and repository contracts.
3. Test reduced motion, finite settling, hover/focus, draft retention and compact
   layouts. Run the full suite; inspect intentional golden differences before
   accepting replacement baselines. Never hide a functional failure with them.
4. Build native and Web outputs and retain actual verification results.

No continuous decorative animations, blur filters, timers, automatic focus
changes or duplicated outgoing forms. Reduced-motion users get immediate state
changes. Color supplements status/priority text rather than replacing it.
Animation duration is a design choice, not measured frame-rate improvement.

### Implemented design

- Iris canvas, lavender/mint sidebar, iris-to-peach greeting, gradient mark.
- Completion/focus pills and a finite 360ms progress transition.
- A single 320ms fade/8px entrance for the greeting; ordinary rebuilds keep it.
- 200ms surface border/shadow hover and keyboard-focus feedback. No scaling of
  editable content and no added keyboard traversal stop.
- Rose high-priority, blue low-priority, warm normal and mint completed cards;
  existing labels and completed strikethrough remain the semantic indicators.
- Shared surfaces bring the same treatment to account and error panels.

### Review and regression work

Initial behavior checks exposed a Flutter assertion: decorated task tiles had
no local Material for ink. Added transparent Material inside the surface.
Visual review then caught content clipped by rounded corners because padding
was outside that Material. Padding now belongs inside it. Original outputs are
retained rather than relabelled as passing runs.

The phone CRUD test initially tapped an offscreen Edit action after the taller
greeting. It now scrolls that existing control into view before tapping, without
weakening its invalid-save/retry/delete/undo assertions. All 92 unit/widget cases
passed. Fifteen golden differences were reviewed before explicit regeneration;
the final full coverage invocation passed 107 cases. No baseline was changed to
hide a behavioral failure. Golden fixtures are synthetic, not physical-device
or manual screen-reader evidence.

Raw results: docs/evidence/color-motion-20260921. Report editions remain a dated
record of the previous implementation; they were not regenerated for this UI.

Native persisted scenarios exposed an old Card-type ancestor finder after the
surface refactor. It now scopes actions through the stable task-card key while
still finding the visible task title. Full-record persistence, unrelated-task,
cancel and undo assertions are unchanged; the original failed run is retained.

22 September continuation completed the pending gates: final format/analyze,
15 Windows native cases, 17 API cases and Windows/Web/Android release builds
PASS. Web was rebuilt with bundled resources; its earlier incomplete attempt
remains recorded. No new Edge/Android interaction or frame-time measurement
was performed. The changes remain local and the report remains untouched.

<a id="risk-closure-20260919"></a>

Original path: `docs/risk-closure-20260919.md`

## Risk closure on 19 September 2026

Publication continuation, 20 September: the user authorized completing checks
and pushing this increment to main-test. Windows, Web and Android release builds
all completed successfully. Hosted CI must still be verified for the published
SHA; local passing runs do not establish hosted success.

Scope: resolve the reviewed engineering and evidence risks, excluding video work.
The team confirmed that only a Windows computer is available. No new platform,
service, SDK installation, publication or production-readiness claim is implied.

### Changes and verification

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

### Windows acceptance still requiring a person

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

### Clean setup and publication boundary

After an explicitly requested push, inspect the new hosted workflow for that
exact SHA. Its Windows/Android jobs are fresh-runner automated evidence, not a
human clean-machine install test. Download the complete Windows Release folder
or APK, verify checksums, install/launch, create a synthetic task, terminate and
restart the app, and verify persistence on an available independent environment.
Do not install Windows Sandbox, a VM, or paid services without separate approval.

No video was created or edited. Contribution allocation and signatures still
require both students' confirmation. The earlier 80% estimate remains a dated
planning estimate; this change is not a new grade or 100% readiness claim.

<a id="project-progress-20260915"></a>

Original path: `docs/project-progress-20260915.md`

## Verification and completion estimate — 15 September 2026

### Scope and conclusion

Reviewed task/controller/filter/edit flows, API authentication and revision-checked
writes, platform configuration and the available test/submission evidence.
The repeat Flutter run passed 100 cases; the repeat Node run passed 14 cases.
No additional reproducible application defect was identified by these checks.
This is not proof that all possible bugs are absent, a penetration test, or a
new manual review of every screen on every platform.

The platform increment resolves the observed Android build blockers through
same-drive Pub/Gradle caches and normal release plugin-registry refresh. Debug
HTTP is restricted to the local development hosts; release policy is unchanged.
Original failed runs remain available alongside successful reruns.

### Risk and evidence summary

| Risk | Evidence and result | Boundary |
| --- | --- | --- |
| Draft loss / duplicate pending submit | 100 Flutter cases include four pending-capture regressions | No guarantee for every input method |
| Layout, validation, loading/error/empty | Widget and 15 unchanged golden baselines PASS | Manual screen-reader / whole-page focus audit pending |
| Account isolation, token rotation, stale writes, persistence | 14 Node API cases PASS | Local backend, not production security certification |
| Native CRUD / recovery / API workflow | Android 15 PASS on 15 September; Windows 15 PASS on 14 September | Separate invocations; not fresh Windows reruns today |
| Runnable Android artifact | Release build/install/cold launch/process-restart persistence PASS | Emulator, coursework signing; no physical-device HTTPS claim |
| iOS | Scaffold and validation instructions present | Build/run NOT RUN: Mac/Xcode required |
| Browser | Existing dated Edge evidence retained | Not rerun in this review |

Raw platform logs and commands: [14 September](../evidence/platform-audit-20260914)
and [15 September](../evidence/platform-audit-20260915/README.md).
The additional Flutter repeat log is local at
`build/review-20260915-flutter.txt`; earlier full passing logs are versioned.
The additional Node run passed 14/14 in the task terminal. These repeats do not
replace or alter the original dated evidence.

### Progress: approximately 80% of submission readiness

This is an internal planning estimate, **not a grade prediction, code coverage
percentage, or official rubric scoring**. Weights below measure deliverable
readiness; optional upgrades and production hosting are not mandatory scope.

| Workstream | Weight | Completed credit | Remaining acceptance work |
| --- | ---: | ---: | --- |
| Core app and authorized local backend | 20 | 19 | Final acceptance on clean setup |
| Automated testing and authentic defect evidence | 25 | 24 | Final submission-version evidence consistency |
| Required two-platform demonstration | 10 | 10 | Android and Windows build/run evidence exists |
| UX and accessibility | 10 | 7 | Screen reader, full keyboard traversal, manual input review |
| Reproducible packaging and setup | 10 | 6 | Clean-machine reproduction and final release package |
| English report | 15 | 12 | Synchronize latest platform evidence; team metadata/final review |
| Video and presentation | 5 | 0 | No completed video/presentation supplied in repository |
| Contributions, oral readiness and final checklist | 5 | 2 | Confirm real individual contributions and rehearse |
| **Total** | **100** | **80** | **Not submission-ready yet** |

Engineering implementation and automated verification are approximately **95%**
of their planned scope (43/45 across the first two rows, rounded). Overall
submission readiness is lower because video and final acceptance cannot be
substituted with passing tests. Missing usable video remains a critical demo
submission gate. iOS is an additional user-requested target, not a reason to
claim the required Android/Windows pair is missing; iOS remains unverified.

### Next required actions

1. Run documented manual accessibility and clean-machine setup protocols.
2. Update report claims to the latest dated evidence without claiming iOS PASS.
3. Have both members confirm metadata, actual contributions and oral understanding.
4. Record the English video (at most 20 minutes), involving both members.
5. Package source and runnable artifacts; verify final links/checksums and CI
   for the final revision. Local results do not establish a new hosted CI PASS.

User authorized committing and pushing this verified increment to `main-test`.

<a id="platform-audit-20260914"></a>

Original path: `docs/platform-audit-20260914.md`

## Platform audit — 14 September 2026

Baseline: d0b145d. User requests bug review and Android/iOS/Windows execution;
Android SDK/emulator installation on D: is authorized. No publication requested.

### Plan and acceptance criteria

1. Recheck tools; keep Android SDK, AVD and build caches on D: where configurable.
2. Run Flutter/API checks and independent Windows native suites; preserve failures.
3. Build/install/launch Android and run isolated integration scenarios on an AVD.
4. Add missing iOS scaffold; inspect plugin/network configuration. Actual iOS
   build and simulator execution require macOS/Xcode and must remain NOT RUN here.
5. Fix reproduced issues with regressions, then record exact verified boundaries.

Passing selected tests is not proof of absence of every possible bug.
Evidence directory: docs/evidence/platform-audit-20260914/.

### Verified before 15 September continuation

- Flutter suite with coverage: PASS, 100 cases; backend: PASS, 14 cases.
- Windows: PASS, 15 case executions across independent (4), persisted (3),
  lifecycle (2), draft exit (1), online (1), pending capture (4).
- Windows release build and static analysis: PASS.
- Android API 36 emulator booted; no TaskFlow Android pass was recorded yet.
- Android release attempts failed first on the SDK 23 NDK wrapper, then Kotlin
  cross-drive caching, then stale incremental storage. All logs remain intact.
- NDK 28.2.13676358 installed explicitly; packages resolved with enforce-lockfile
  into D:/Android/pub-cache, without dependency version changes.
- iOS runner added, but build/install/E2E remain NOT RUN without macOS/Xcode.

### 15 September recovery

With no Java build process remaining, moved only the generated plugin Kotlin
cache from build/shared_preferences_android/kotlin to
build/kotlin-cache-before-recovery-20260915. This is recoverable; report assets,
other build artifacts and user data were not cleared. Fresh logs are under
docs/evidence/platform-audit-20260915/. Emulator restarted from the existing D: AVD.

Release initially failed on a stale generated integration-test registration
with --no-pub. A normal flutter build apk --release refreshed the registration
and passed. APK installation, cold launch and process-restart persistence were
verified visually on API 36. All 15 Android native cases passed across six
separate invocations, including the real API/SQLite case over the debug-only
10.0.2.2 HTTP configuration. See the 15 September evidence README for commands,
SHA256, screenshots, raw logs and boundaries. The release artifact was restored
after testing and the emulator stopped to free memory. iOS remains NOT RUN.

Final 15 September gates: 100 Flutter cases with coverage, 14 API cases,
static analysis and full-project formatting PASS. No golden replacements or
dependency upgrades. Neither these tests nor the platform smoke checks prove
absence of every possible bug. Physical Android, full IME/VoiceOver/Narrator,
release HTTPS account deployment and iOS execution remain separate gates.

<a id="ui-spacing-20260912"></a>

Original path: `docs/ui-spacing-20260912.md`

## UI spacing, clipping and edit rebuild audit

Initially user requested UI fixes only; the subsequent continuation request
authorized publication to main-test after checks. Base abbc203; no report, dependency
or SDK changes. This is an agent-assisted engineering record for student review.

### Confirmed defects and fixes

The three new form_layout_test.dart cases all failed before the fix. The raw
before.txt records adjacent fields with no gap and enlarged dropdown RenderFlex
overflows. Edit/metadata/filter fields now have 20px gaps. Dropdowns expand to
available width with intrinsic item height rather than a dense fixed row.

Visual inspection exposed top floating-label clipping and long truncated labels
at 200% text. Dialog scroll padding now protects labels; date/tag instructions
sit below short labels. Edit titles wrap across up to three lines, preserving
Done-to-save. Lower fields scroll while dialog actions remain accessible.

Dirty listeners rebuild the Edit parent only when the dirty boolean changes,
not every cursor movement/keystroke. A test verifies metadata widget identity
and stable position during same-height typing. This is not an FPS benchmark
or proof that every source of jank has been eliminated.

### Verification

Three layout tests and four new dialog goldens cover 390px, text 100%/200%,
spacing, dropdown opening and typing stability. All four final golden images
were visually reviewed; eleven existing baselines were not changed. Initial
images revealed clipping, fixed before final image review. No actual Android
device run is implied by the pinned golden rendering variant.

Full Flutter coverage invocation passes 84 cases. See evidence/manifest.md for
native, Edge and build results; logs are under evidence/ui-spacing-20260912/.
The final layout-only rerun includes an extra identity assertion added after
the full coverage run; it does not add another case.

### Limits

No frame-time profiling, Narrator, clean-machine setup or local Android run
(SDK absent). The browser harness is a general regression gate, not visual
evidence for every modified dialog. B1 quick-create exit protection and B2
remain separate roadmap work. Publication is authorized by the follow-up request.

<a id="bug-audit-20260912"></a>

Original path: `docs/bug-audit-20260912.md`

## Bug audit - 2026-09-12

Starting point: published Color Studio revision ebc8309; clean working tree.
User authorized inspection, testing and fixes, not another push or report.

### Confirmed defects and fixes

1. **Unknown task snapshot could overwrite stored records.** A controller starts
   with an empty in-memory list. Add could save that list without a successful
   load, including after an initial load failure. A failed reload also allowed
   mutation of a stale snapshot. `_loaded` now gates every mutation, is cleared
   before reload and becomes true only after successful load. Explicit Retry
   remains required; blocked saves preserve drafts and the original load error.
   Calls after disposal are rejected. No automatic deletion or recovery of
   already-corrupt data is attempted.
2. **Late logout cleared a newer session.** `logout` previously cleared session
   state unconditionally in `finally`, even when the old request was rejected
   because session generation changed. Cleanup now belongs only to the captured
   generation. Logout still clears its own session on network failure.
3. **Wrong password after token refresh signed the user out.** The second HTTP
   401 was treated as expired authentication without inspecting its error code.
   Both initial and retried responses now distinguish `unauthorized` from
   `invalid_password`. A genuine expired/revoked session still clears normally.

### Reproduction and regression coverage

- `test/unit/snapshot_safety_test.dart`: unloaded write, failed initial load,
  failed reload with edit/delete/toggle/undo attempts, successful reload recovery.
- `test/unit/session_race_test.dart`: controlled late logout and expired-token
  refresh followed by incorrect current password. Mock HTTP only; no real account.
- `test/widget/failed_load_safety_test.dart`: saved record survives a blocked
  add, draft survives failure/retry, and successful reload permits appending.

`regression-before.txt` records four genuine failing cases before the first two
fixes; `refresh-before.txt` records the third bug. `regression-after.txt` covers
the initial five regressions, before adding the sixth refresh case. Final full
suite logs include all six. Existing direct-controller unit fixtures now call
load before writing; the failed-write fixture sets its failure after loading,
so it still tests a failed write rather than accidentally testing failed load.

No golden baseline changed. No backend schema, credential format, dependency,
SDK, stored user data, report or remote Git state changed in this audit.

### Inspection scope and limitations

Read controller/repositories/domain validation/filtering, API-client request and
session logic, account gateway/forms, task form/dialog callbacks, backend routing,
validation/authentication/transaction code and workflow configuration. Existing
tests exercise access isolation, optimistic conflicts, backend validation, UI
states, keyboard/semantics and responsive cases. See the evidence manifest for
actual final gate results, rather than treating inspection as proof.

This is a bounded regression audit, not proof that all bugs are eliminated or a
penetration/security certification. Android is NOT RUN locally (SDK absent),
as are physical-device, manual Narrator and clean-machine release installation.
At audit capture, past CI evidence did not verify the then-uncommitted fixes.
Publication follow-up: fixes became 0753db1 and its hosted jobs succeeded;
see current-verified-state.md. This does not change the original raw logs. Large-list
performance and multiple independent offline writers remain outside the claimed
verification; use account-mode revision checks for supported multi-writer flows.

<a id="ui-refresh-20260911"></a>

Original path: `docs/ui-refresh-20260911.md`

## UI refresh - engineering notes, 2026-09-11

User-requested interface redesign. This is not report preparation. No backend
contract, stored data, dependency, credential policy or search rule changed.

### Design and implementation

- `lib/core/theme/app_theme.dart`: shared indigo/ink palette, light canvas, white
  outlined surfaces, typography, 48-pixel actions, rounded inputs/dialogs and
  accessible error/helper styles. Text styles copy the platform's base styles
  so font families remain intact. No network fonts or new runtime packages.
- `ui_components.dart`: brand mark, separately exposed section headings, surface
  panels, illustrated empty/error states and responsive authentication layout.
- Task workspace: status navigation rail at widths >=1100 and normal text scale;
  compact single-column layout otherwise. Wide composer places Add beside the
  title. Existing search/filter/sort, metadata, undo and retry labels remain.
  Sidebar status selection preserves the other current filters and never writes
  tasks. Priority uses text plus color; completion remains a real checkbox.
- Authentication: split desktop introduction/form, single form panel on smaller
  screens or large text. Sign-in/register/recovery and isolated offline/sample
  modes retain their existing behavior.
- Settings: separate profile, password, session and deletion panels. Existing
  field focus nodes, ordered traversal, live errors and credential controls stay.
- Edit/filter dialogs inherit the theme; edit content has a bounded readable
  width while remaining scrollable. Delete actions are visually distinguished.

The small coursework collection is rendered in a single scrollable column, so
grouped form/card descendants remain available consistently to semantics and
focus traversal. This eagerly lays out task cards; it is not a large-list
virtualization or performance improvement. Large datasets would require a
separate measured lazy-list/pagination design. No performance claim is made.

### Test and visual review

Two new widget cases cover desktop status filtering without storage mutation and
the large-text single-column fallback. Existing assertions remain, including the
four standalone loading cases and the permanent substring-search regression.
The Retry widget test now scrolls the taller error panel into view before tapping.
The account accessibility test settles the helper/error animation before checking
contrast, while still asserting keyboard focus and both validation messages.

Initial checks caught a Material ancestor issue for rail tiles, merged card
semantics, unreadable test-font fallback and an intermediate helper-text fade.
These were corrected rather than suppressing assertions. Development logs are
retained under `evidence/ui-refresh-20260911/`; they are not final passing gates.

All eight changed task screenshots were inspected: empty, populated, validation
and error at 390x960 / 1280x900. Compared the old wide populated screenshot and
its masked diff; the new rail, composer, fonts, badges, spacing and surfaces are
intentional. Existing fixtures/sizes/comparator are unchanged. Lower cards may
require scrolling, especially on phones; behavior/large-text tests cover that.

After visual review, explicitly regenerated only the task golden file. Added
and inspected sign-in goldens at 390x1100 / 1280x1000 and settings at 900x1600.
The settings screenshot uses mocked HTTP and a synthetic account/session, not a
real account. There are now 11 golden cases; no comparison tolerance introduced.
New baselines live in `test/golden/baselines/`. Generated failure images stay
ignored; a representative original and diff are retained with the evidence.

### Boundaries

See the latest evidence manifest for executed gates. Windows/Edge runs do not
prove Android, physical keyboard/IME or Narrator behavior. The local Android SDK
is still absent. Previous Android CI results belong to previous source commits;
they are not a PASS for this redesigned UI. Manual full-page assistive-technology
review, clean-machine release testing and a hosted run of this revision remain.

<a id="project-review-20260909"></a>

Original path: `docs/project-review-20260909.md`

## Full project review and next development increment - 2026-09-09

This is an engineering and rubric-gap review, not a score prediction, security
certification or claim that the coursework is ready to submit. The original
13-page course brief, repository instructions and implementation prompt were
read before code changes. Topic 4 and the scoring tables were also visually
checked from rendered PDF pages.

Baseline for the accessibility audit was clean `main-test` commit `4f8166f`.
The tracked repository contained 254 files: 39 Dart, 10 JavaScript and 19 Markdown
files, plus Flutter platform runners, reviewed golden images and raw evidence. No
tracked build cache, SQLite database, token, private key or generated release
directory was found.

### Continuation update: Android and CI

Later on 2026-09-09, authorized work installed/configured the Android toolchain,
prepared an Android 16/API 36 AVD, and added `.github/workflows/quality.yml`.
GitHub Actions
[#2](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886)
at `9ca2a96` passed Windows quality gates, debug/release APK builds, checksum
artifact upload, and 9 offline/controlled Android workflow executions. The
artifact is `taskflow-android-apks`; see `docs/evidence/android-ci-20260909.md`.

This closes the initial CI/APK/API 36 emulator gap below. It does not close
manual APK installation/launch, physical-device, Android online-mode, production
signing, clean-machine or manual accessibility gaps.

### Baseline system audit for the accessibility increment

| Area | Verified implementation | Honest boundary |
|---|---|---|
| Flutter product | Offline and account task workflows, metadata, deterministic discovery, responsive task UI and recoverable states | Small task collection; one-level session undo; no offline/online merge |
| Architecture | Immutable domain state, repository interface, local/remote/fake implementations, controller, injected clock/ID | Constructor injection is intentionally small-scale; no need for a larger state package yet |
| Backend | Local Node HTTP + SQLite, auth/session/recovery/profile/account actions, ownership, validation and optimistic revisions | No hosted service, SMTP/MFA, distributed operation or production security audit |
| Unit/widget/golden | 57 cases after this increment, including 8 unchanged Windows-host baselines | Test counts are not coverage quality or a reliability percentage |
| Native E2E | 10 Windows cases: 5 real-preference, 4 controlled fake and 1 real API/SQLite | UI remount is not an OS/process restart; physical keyboard/IME is not injected typing |
| Browser | Real Edge online lifecycle/sample evidence and a gated deterministic failure/discovery harness | Flutter runner rejects direct Web `integration_test`; harness is not the shipped entrypoint |
| Accessibility | Task and account entry/settings guidelines, semantics, keyboard actions, focus recovery and 200% text checks | Narrator and complete release-build focus order remain NOT RUN |
| Evidence | Environment, raw logs, eight goldens, Edge screenshots, fail/fix patches, test matrix and manifest | CI, clean-machine install and broader-host stability evidence remain absent |
| Submission | Reproducible source/README and local Windows Release build | Android APK, official report/template, video, metadata and verified member contributions remain absent |

### Increment selected from the audit

The highest-value local gap that did not require installing tools or inventing
course metadata was the signed-in account settings accessibility path. The screen
previously relied on default traversal and had no dedicated widget tests.

This increment adds:

- semantic section headings for the account, profile, security and sessions;
- explicit ordered traversal within profile and password form groups;
- autofill hints and IME Next/Done actions;
- focus recovery to display name, current password or new password after invalid
  actions, including safe account deletion without a password;
- stable keys for the three tested actions; and
- two isolated tests covering headings, validation semantics, keyboard order,
  guideline checks and 200% text on a narrow viewport.

The client/server API and credential-storage policy are unchanged. Invalid test
actions do not issue an HTTP mutation.

### Verification result

| Gate | Result |
|---|---|
| Focused account-settings widget test | PASS, 2 |
| Dart format / Flutter analyze | PASS / PASS |
| Flutter unit/widget/golden suite | PASS, 57; 8 existing goldens unchanged |
| Flutter coverage invocation | PASS, 57 |
| Backend syntax/API | PASS; 14 API cases |
| Windows native suites | PASS; 2 + 4 + 3 + 1 = 10 cases |
| Windows Release / Web Release | PASS / PASS |
| Edge harness smoke | PASS once; default Web build restored |
| Android/APK at this increment | NOT RUN; Android SDK was absent on that host |
| Narrator/full physical focus order | NOT RUN; protocol prepared |

Exact commands and raw files are indexed in `docs/evidence/manifest.md`.

### Prioritized next work

1. Execute `docs/accessibility-testing.md` with Narrator and a physical keyboard
   on the actual release build; retain the observed focus order and failures.
2. Test README/setup and the complete Windows Release directory on a clean Windows
   machine, including the required Visual C++ runtime and local backend startup.
3. Manually install and launch the Android artifact on a clean host or physical
   device. Use an externally reachable HTTPS backend for a separate Android
   account-mode test; emulator localhost is not the Windows host.
4. Configure a private production signing key only if store-ready distribution is
   required; never commit the keystore or credentials.
5. Start the evidence-backed English report outline, diagrams, comparison table
   and oral question bank, but do not finalize administrative pages before the
   official template, instructor and two/three-member details are supplied.

Agent-assisted changes require student review and understanding before submission,
consistent with the course brief's academic-integrity and oral-examination rules.

<a id="project-review-20260907"></a>

Original path: `docs/project-review-20260907.md`

## Project review and next increment - 2026-09-07

Agent-assisted engineering review for student verification. Baseline: 62190d8 on
main-test, clean working tree before this increment. This is a functional/scope
review, not a penetration test, line-by-line security certification or final
coursework assessment. Generated build caches and binary assets are not treated
as application source; accepted golden images remain unchanged.

### Current system and evidence boundaries

| Area | Implementation/evidence | Remaining boundary |
|---|---|---|
| Flutter task flow | Immutable task/metadata, repository abstraction, controller writes before state publication, form/filter/dialog UI | Small collection, one-level session undo; no automatic conflict merge |
| Offline storage | SharedPreferencesAsync JSON, separately injected keys in native tests | No encrypted database, cross-process transaction or local backup service |
| Accounts/client | Account gateway, memory-only tokens, serialized refresh, remote revision invalidation after failed writes | Re-login after restart; no silent offline upload |
| Backend | Node HTTP, SQLite transactions, ownership, scrypt, rotating sessions, recovery, validation, backup, OpenAPI | Single process, no public deployment/SMTP/MFA/operational security audit |
| Unit/widget/golden | 49 cases with 8 controlled baselines; permanent substring-search regression | Account accessibility/manual screen-reader coverage still incomplete |
| Native E2E before this change | Two combined real-preference workflows, four fake-repository scenarios, one real API workflow | Independent create/edit/delete persistence scenarios were missing |
| Platform configuration | Windows runner, Web entry/manifest, Android runner and Internet permission | Android SDK absent; release signing still uses template debug configuration, not store-ready |
| Evidence and delivery | Raw logs, authentic fail/fix patches, reproducible run/backup scripts, local Release artifact | No online browser E2E, clean-machine install, CI or repeated-run study claim |
| Coursework | Prompt, requirements traceability, test matrix and architecture notes | Official metadata/templates, researched report, video, oral material and verified contributions remain |

Environment was rechecked with flutter --version, dart --version, flutter doctor -v
and flutter devices: Flutter 3.47.1, Dart 3.13.1, Windows 10.0.26200.9168,
Chrome 149.0.7827.201, Edge 152.0.4191.66. Windows C++ toolchain is usable; SDK PATH
warnings and absent Android SDK remain. No tooling was installed or SDK modified.

### Implemented next step

Added integration_test/persisted_scenarios_test.dart with three independent cases:

1. Fresh empty native storage -> valid create -> saved record -> fresh repository
   and UI remount show the same complete record.
2. Fixed seeded record -> edit title/notes -> complete -> fresh repository/remount;
   compare the full expected record so identity, creation time, priority, date and
   tags cannot silently disappear.
3. Target plus unaffected record -> cancel delete (no data change) -> confirm delete
   (only target removed) -> undo (full target restored once) -> remount. Check the
   unaffected record before/after and preserve the target's completed state.

Only three dedicated keys under taskflow.integration.persisted.* are removed
before/after tests. Production taskflow.tasks.v1 and other application preferences
are untouched. Each case supplies its own initial state and does not rely on any
other test. Helpers interact through visible controls and existing bounded settling.

These tests use actual native preference I/O, not the controlled in-memory fake.
Repository recreation and widget remount are not a process restart or OS reboot.
The test input channel is registered; physical keyboard/IME behavior is not claimed.
The seven required workflow categories now have independently reset coverage
across the persisted and controlled suites, but not on every claimed platform.
That distinction prevents declaring the whole project ready for submission.

### Next priorities

1. Web/Edge online workflow evidence with isolated test data, then a stable demo
   data entry point that cannot overwrite real tasks implicitly.
2. Manual keyboard/focus/screen-reader checks plus account form accessibility.
3. Repeated-run experiment and pinned CI; report raw outcomes, not inferred rates.
4. Clean-machine setup/release launch and authorized Android tooling if required.
5. Research/report/video/oral materials after official template/team details.

Exact PASS/FAIL/NOT RUN gates are indexed in evidence/manifest.md. Source and test
changes in this increment are local; previous Git publication is not standing
authorization to push subsequent changes.

Observed runner limitation: passing two integration files in one Flutter invocation
completed the first suite (2 cases), then failed to obtain a debug connection for
the second app. The second suite passed alone (4 cases) without source changes.
No app assertion failed in that combined run; the underlying launch failure has
not been proven. Preserve the failed output and use separate suite invocations;
do not increase timeouts or describe this as a measured stability result.

<a id="upgrade-b1"></a>

Original path: `docs/upgrade-b1.md`

## Upgrade B1: edit-draft protection

2026-09-12; base c57407a, changes authorized for main-test. Agent-assisted
engineering notes for student review, not the coursework report.

### Implemented slice

- Cancel, Escape and Navigator back request confirmation only when edit inputs
  differ from their initial values. Reverting inputs removes the dirty state.
- Continue editing preserves inputs; Discard closes without calling save.
- Compare raw metadata inputs, including an invalid date that cannot yet become
  a TaskDetails calendar value. Normalized model values alone would miss it.
- While saving, dismissal and duplicate save remain disabled. The nested
  confirmation is guarded against repeated opening; its safe action gets focus.
- Drafts stay in widget memory. No preferences, API schema, packages or golden
  baselines changed. Closing a tab/process is not protected by this slice.

### Tests and evidence

`test/widget/edit_draft_test.dart` has five isolated cases: reverted title,
continue/discard with a save spy, invalid-date back/Escape, pending save with
a completer gate, and 390-pixel/200% text confirmation.

The persisted edit scenario now attempts Cancel, verifies storage is unchanged,
continues editing, saves and remounts a fresh repository/UI while preserving
metadata. This is the existing scenario extended, not an extra E2E case.

The first targeted run exposed missing Escape handling with the non-dismissible
route. CallbackShortcuts now explicitly routes Escape through requestClose.
The successful four-case rerun is draft-tests.txt; the fifth large-text case
was added later. coverage.txt is the intermediate 76-case run; final results
are indexed separately in evidence/manifest.md. Do not relabel preliminary logs.

### Boundaries / next slice

This completes the edit-dialog portion of B1 only. Quick-create workspace-exit
protection and B2 collapsed-field validation/focus auditing remain next.
Native tests cover persistence, not OS restart or IME. Edge's existing harness
checks regressions, not the new confirmation specifically. Narrator, clean-host
setup and local Android (SDK absent) remain unverified. Hosted CI for c57407a
or earlier does not prove this source revision. No report/video work performed.

<a id="quick-create-exit"></a>

Original path: `docs/quick-create-exit.md`

## Quick-create exit protection

2026-09-12, implemented after UI-spacing commit 4913c2d. User authorized
stepwise implementation, verification and publication to main-test.

### B1 slice and contract

TaskScreen exposes an exitActions builder with an asynchronous confirmExit
callback. AccountGateway's offline Return to sign in and Exit sample sandbox
buttons await it before removing the workspace. Ordinary actions stay separate.

- Empty/whitespace-only title with pristine metadata exits without a prompt.
- Nonempty title or changed metadata, including invalid raw dates, prompts
  Continue editing / Discard and leave. Confirmation dismissal means keep.
- No save is triggered by either exit decision. Kept drafts retain their fields;
  discarded drafts disappear with the old workspace and do not reappear later.
- In-flight repository work blocks exit with an explanatory message. Saving
  successfully resets the metadata dirty flag along with the existing form.
- Duplicate exit requests cannot open multiple confirmations. Async callbacks
  check mounted before removing a workspace. Credentials are not stored.

Only these two explicit destructive workspace switches are guarded. Account
settings push preserves the underlying workspace, so it does not ask to discard.
Account revocation/sign-out still clears the account normally; this change must
not block security invalidation or transfer drafts to another user. Browser-tab
close, process kill, system back/app exit and session recovery are not claimed.

### Verification design

Eight independent widget cases use fresh repositories and a no-network API
client: keep/discard, blank exit and metadata-only invalid-date exit in both
modes; a completer-controlled save verifies exit blocking and clean exit after
successful save. A new independent Windows case uses only the dedicated
`taskflow.integration.quick-create-exit.v1` preference key, removes it before
and after the test, and compares the saved record before/after discard and
workspace re-entry. No general preferences clear is permitted. Re-entry is not
a process restart. The local native total is now 11 across five invocations.

The eighth widget case protects metadata across an unrelated search rebuild.
Review found mutable draftDetails was reused as the form's initial baseline.
Editing metadata, searching, changing metadata and reverting that last edit
could clear dirty state even though the draft was not empty. The form revision
now always starts from empty metadata; the fields retain their own draft state.
rebuild-reproduction.txt captures the genuine pre-fix failure. rebuild-before.txt
is an earlier non-triggering test attempt, not a failure. Final coverage includes
the corrected regression; earlier 91-case logs precede this fix.

The first targeted attempt failed to compile because a fixture reused the fake
repository's gate field name. widget.txt preserves it. The renamed fixture
passed seven cases in widget-rerun.txt; this is a fixture correction, not a
fabricated product-defect experiment. Final commands/results are in the manifest.

The first independent native regression suite passed but discovery took
unusually long (the next case started at 01:31 after discovery at 00:05).
The final run of the same unchanged scenario ends at 00:13 after the metadata
baseline correction. Keep both logs; app source differs, so this is not a
controlled timing comparison. Do not infer a root cause or general stability
rate from either run. No timeout increase was made.

The final windows_workflow_test invocation later stalled in its metadata case
without an assertion result. At 20:56:53 local time its test-owned Debug process
10316 was responsive but the last progress marker remained 00:06 (last log write
20:54:36). Only that exact repository Debug process was stopped; the runner then
returned exit 1. windows_workflow_test-final.txt preserves the interrupted run.
workflow-rerun.txt is a separate rerun with unchanged source, not a relabelled
PASS. Root cause remains unconfirmed; --timeout 90s was not treated as proof of
a wall-clock process bound. No timeout increase or user-process cleanup occurred.

### Remaining work

B2 collapsed-field validation, visible invalid-field focus and boundary review
are next. The new native case is verified locally on Windows only; current CI
includes its widget counterparts through flutter test but does not invoke this
new native file. No Android/manual Narrator/OS-exit claim, no report work.

<a id="minimal-desktop-ui"></a>

Original path: `docs/minimal-desktop-ui.md`

## TaskFlow minimal desktop UI — 2026-09-13

User-requested UI refactor, not a new product/backend scope or report increment.
Changes are local; this request does not publish a new commit.

### Design and implementation

- Off-white `#F8FAFC` canvas, white cards, `#E2E8F0` borders, indigo `#4F46E5`.
  Quick capture uses a diffuse 3% black shadow. Existing Roboto/Material icons;
  no network font, additional dependency, copied artwork or SDK upgrade.
- `SidebarNavigation`: actual all/pending/completed counts, selected and hover
  states, Local/Account/Sample identification and existing workspace actions.
  Sample mode explicitly says session-only. There is no invented sync service.
- `TaskHeader`: semantic heading and actual completed/total progress, separate
  from repository-loading indicators. The visible product name is TaskFlow.
- `QuickTaskInput`: inline desktop capture, Enter submit, working calendar and
  priority shortcuts, visible selected metadata, retained optional detail fields.
  Both controls update the same validated draft used by persistence.
- `EmptyStateWidget`: centered line icon, readable empty/no-match messages.
- Search supports Ctrl+K and Command+K within the active workspace. Sort is a
  pill popup menu; advanced combined filters retain the accessible existing
  dialog (rather than compressing its five fields into a small popup).
- Sidebar switches off below 1100 logical pixels or at large text. Capture
  stacks below 700 available pixels or at large text. The canvas has a stable
  key: title and invalid raw dates survive resize. The sidebar scrolls in short
  windows; floating pending-operation notices avoid its bottom actions.
- Material controls supply hover, focus and press feedback. No measured FPS,
  zero-jank, large-list scalability or screen-reader claim is made.

### Regression protection

`test/widget/minimal_workspace_test.dart` covers search shortcuts, quick
priority/date persistence and reset, sorting while retaining status filters,
actual completion counts, resize draft preservation and 200% text layout.
Existing CRUD, loading/retry, validation, edit and quick-create exit guards stay
in force. Do not reset the metadata baseline to mutable draft values.

Fifteen golden baselines were intentionally reviewed and replaced because of
the requested design tokens, branding and workspace layout. Phone/wide empty,
populated, validation/error, auth/account and 1x/2x dialogs were inspected.
Golden Android rendering variants are not Android-device execution.

### Evidence

Raw logs: `docs/evidence/minimal-ui-20260913/`.
`coverage-verified.txt`: 96 PASS (including 15 golden cases), no tap warnings.
`analyze.txt`: PASS. `backend.txt`: 14 PASS.
`native-independent.txt`: 4 PASS; `native-persisted.txt`: 3 PASS;
`native-exit.txt`: 1 PASS. Later gate results are indexed in the manifest.
`native-workflow.txt`: 2 PASS; `native-online.txt`: 1 PASS; Windows Release and
default Web release builds PASS. `edge-verified.txt`: corrected-script 1/1 PASS.

The first Edge run (`edge.txt`) genuinely failed: its readiness selector still
expected the retired app-bar heading. `scripts/browser/edge-harness-check.js`
now waits for the actual semantic workspace greeting; scenario assertions were
not removed. Three subsequent attempts exposed a second stale assumption:
Flutter's focused input name includes the new visible hint after a newline.
`edge-focus-diagnostic.txt` records the actual focused INPUT name and unchanged
validation description. The typing helper now verifies its exact first-line
label, then types through the keyboard into that verified active input. It keeps
bounded waits, readable diagnostics and the existing validation/order assertions.
Every attempt is recorded separately, not substituted for a failure.
Earlier coverage logs include test-target warnings; final tests tap the menu
item itself and ensure workspace exit actions are visible.

### Boundaries

Windows and Edge checks apply only to this host and recorded runs. Local Android
APK/E2E are NOT RUN: Android SDK is absent. No new hosted CI result is claimed.
Manual Narrator, clean-machine setup and release installation remain outstanding.
This slice does not complete roadmap B2–G or deferred report/video work.

<a id="color-studio-ui"></a>

Original path: `docs/color-studio-ui.md`

## Color studio UI refinement

Continues the uncommitted UI refresh at the user's request. No new packages,
backend changes, publication or report work. Palette: violet actions, lavender
canvas accents, mint completion surfaces, peach high-priority task surfaces,
amber medium-priority badges and teal low-priority badges. Explicit priority
and completion labels remain; color is supplementary, never the only signal.

`StudioHeader` paints original simple geometric shapes behind text, excluded
from semantics and clipped to its own bounds. It adds no animation, timer or
focus target. Its height follows text, including large text. Shared section
icons have padded lavender tiles; the authentication panel uses a dark
violet-to-teal gradient with a warm yellow icon. No third-party artwork.

Reviewed all 11 actual golden images, the previous wide populated baseline
and its masked diff before explicitly regenerating baselines. Fixtures, fonts,
sizes and comparator tolerances are unchanged. The header increases vertical
space, so lower tasks require scrolling. Existing compact/large-text, keyboard,
loading and CRUD assertions remain intact. Golden images are test renders,
not physical Android evidence or screen-reader evidence.

Raw checks: `evidence/color-studio/`; final status in the evidence manifest.
The first persisted-suite invocation stalled in dependency download before any
test ran; its pub subprocess was stopped and the raw log retained. The unchanged
suite passed with `--no-pub`. Optional `-NoPub` switches on the Edge and online
Windows scripts reuse installed dependencies; default dependency resolution is
unchanged. Use only after a successful pub get with the matching lockfile.

Edge bootstrap investigation: three runs stopped before any workflow assertions.
The diagnostic run recorded an empty semantics tree and an outstanding external
CanvasKit WASM request at the 30-second boundary, with no failed request event.
This supports a renderer-loading stall, not a proven CSS/layout failure or a
general CDN outage. The harness script now builds both QA and restored default
Web entrypoints with `--no-web-resources-cdn` (supported by the installed SDK),
serving bundled CanvasKit from the local server. This is not a claim of fully
offline Web startup: fallback fonts may still use external resources.
Failure diagnostics track pending/failed requests for synthetic QA pages only;
listeners are removed after every repetition. Existing workflow assertions and
timeouts are unchanged.
Earlier UI-refresh logs remain historical and are not relabelled. The latest
baseline files now show this palette; the preceding wide baseline and diff are
preserved in this increment's evidence folder. No uniqueness claim against all
other products is implied by an original in-repository design.

<a id="github-cleanup-review"></a>

Original path: `docs/GITHUB-CLEANUP-REVIEW.md`

## Dọn repository trước khi nộp

Đã thực hiện ngày 21/10/2026 theo yêu cầu của người dùng, trên nhánh `main-test` sau a153046. Người dùng đã yêu cầu commit/push báo cáo, dự án và phần dọn repo bằng tên Git của mình. Báo cáo, ảnh và kịch bản từ các lượt trước được đưa vào cùng phạm vi xuất bản; thông tin hỗ trợ AI vẫn được giữ minh bạch.

Lượt xuất bản bổ sung gom 35 bản sao evidence giống hệt nội dung, tiết kiệm 210,385 bytes; mọi tên cũ được ánh xạ tới file gốc giữ lại tại [aliases.json](../evidence/aliases.json), với SHA-256 và kích thước. Đây là bước sau kiểm tra bảo toàn 673 file ở lượt trước. [Kiểm tra xuất bản](../evidence/publication-20261021/README.md) xác minh lại toàn bộ payload gốc qua bảng ánh xạ.

### Nên loại khỏi Git và thêm ignore nếu bị đưa vào

**Đã hoàn tất.** Kiểm tra danh sách tracked không tìm thấy file cache, service state, SDK-local properties, database riêng hoặc binary release thuộc nhóm đề xuất. Vì vậy không có source nào trong nhóm này cần gỡ khỏi index; các file phát sinh trên máy được giữ để tiếp tục chạy dự án.

| File/thư mục | Đã xử lý |
| --- | --- |
| `outputs/taskflow-running-services.json` | Thêm ignore chính xác; file cục bộ không còn xuất hiện trong `git status` |
| `build-apk.log`, `android-build-host.*.log` | Đã được `*.log` bỏ qua; bổ sung ngoại lệ cho log gốc trong `docs/evidence/` và `docs/report/evidence/` |
| `build/`, `.dart_tool/`, `.flutter-plugins-dependencies`, `coverage/` | Giữ ignore đã có; không xóa cache hoặc công cụ render trên máy |
| `android/local.properties` | Giữ ignore ở Android và khai báo rõ tại root; không đưa đường dẫn SDK riêng vào Git |
| `backend/data/`, `backend/backups/`, `.env`, database SQLite của backend | Giữ ignore hiện có; bảo vệ `.env.example` để tái tạo cấu hình |
| `backend/node_modules/`, `node_modules/` | Giữ ignore backend, thêm ignore dependency cục bộ ở root |
| `tmp/`, `temp/`, `output/qa/`, `output/previews/` | Giữ ignore cho sản phẩm trung gian |
| IDE state, `__pycache__/`, file khóa `~$*.docx` | Giữ ignore hiện có |

Không sửa lịch sử Git hoặc thu hồi credential trong lượt này. Các phép kiểm tra trên xác nhận quy tắc đường dẫn và trạng thái tracked, không phải chứng nhận đã quét mọi secret trong toàn bộ lịch sử.

### Có thể gọn lại sau khi nhóm duyệt

**Đã hoàn tất theo yêu cầu triển khai hiện tại.** Word và PDF xuất từ Word là cặp báo cáo chính; nguồn LaTeX vẫn được giữ.

| Mục | Kết quả |
| --- | --- |
| Prompt triển khai ở root | Đã chuyển vào docs/process trong lượt dọn trước. Sau đó người dùng yêu cầu loại cả prompt và AGENTS.md khỏi bản làm việc; hướng dẫn sử dụng hiện nằm trong README của dự án |
| PDF LaTeX cũ | Xóa `output/pdf/taskflow-report.pdf` khỏi bản làm việc, bỏ liên kết nộp bài tới file này và thêm ignore để bản biên dịch tùy chọn không bị commit lại |
| Log chuẩn bị báo cáo cũ | Thêm [phân loại historical và nguồn gốc](../report/evidence/README.md) tại đường dẫn đang được báo cáo tham chiếu; giữ nguyên năm file log/probe |
| Audit và ghi chép theo ngày | Thêm [mục lục 16 ghi chép](README.md), liên kết từ README và evidence manifest; giữ vị trí gốc để không làm hỏng trích dẫn |

PDF cũ có bản sao cục bộ tại `build/repo-cleanup-20261021/taskflow-report-latex-historical.pdf`, thuộc thư mục đã ignore. Bản sao có 456,477 bytes, SHA-256 `6caea44d873c1b05de4455f32bf0fdc282e3f35fffeb3553d05aa7f14dc5a2f4`. Việc xóa ở bản làm việc sẽ được GitHub phản ánh khi commit/push được duyệt; phiên bản cũ vẫn có trong lịch sử Git.

### Kiểm tra đã thực hiện

- 21 đường dẫn mẫu của file tạm, dependency, dữ liệu riêng và PDF LaTeX tùy chọn được ignore đúng.
- 9 đường dẫn cần giữ, gồm log evidence mới, `.env.example`, lockfiles, báo cáo chính và golden baseline, không bị ignore.
- 38 liên kết trong ba index mới trỏ tới file tồn tại.
- 673 file bằng chứng trước lượt dọn giữ nguyên SHA-256; chỉ `docs/evidence/manifest.md` được thêm mục điều hướng. README phân loại historical là file mới.
- `git diff --check` PASS. Không đổi mã ứng dụng hoặc test; không chạy lại Flutter/API suite cho thay đổi tài liệu và ignore.

Kết quả kiểm tra cục bộ: `build/repo-cleanup-20261021/validation.json` (ignored).

### Nên giữ

- `pubspec.lock`, `backend/package-lock.json`, platform scaffold, build/test scripts và CI workflow.
- `.metadata`, `.gitattributes`, cấu hình mẫu và tài liệu tái tạo. Khuyến nghị giữ AGENTS.md ở bản ghi trước đã được thay thế bởi yêu cầu xóa trực tiếp của người dùng.
- Golden baselines, report assets, font licences, nguồn báo cáo và cặp Word/PDF matching.
- Toàn bộ log FAIL/PASS gốc và intentional-defect package; không xóa log theo đuôi file.
- Manual-test script, kịch bản demo và hồ sơ đóng góp đã được nhóm xác nhận.

APK/ZIP release nên phân phối qua GitHub Releases hoặc artifact CI có checksum. Chưa tạo release hoặc upload binary.

### Phạm vi commit sau khi duyệt

Bao gồm cập nhật báo cáo/ảnh/kịch bản từ các lượt trước, sửa LaTeX và thay đổi dọn repo. Prompt được chuyển vị trí và PDF LaTeX cũ được loại khỏi bộ nộp; service state vẫn ở máy và được ignore. Identity được xác minh là `Long-D176 <523k0014@student.tdtu.edu.vn>`. Giữ nguyên cả hai đồng tác giả trong báo cáo. Xem commit thực tế bằng `git log -1` và trạng thái nhánh remote sau push.
