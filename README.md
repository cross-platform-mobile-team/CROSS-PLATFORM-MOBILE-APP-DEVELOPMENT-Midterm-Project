# TaskFlow QA Lab

Desktop UI refresh: [minimal TaskFlow workspace](docs/minimal-desktop-ui.md).
The sidebar shows real task counts; quick capture supports Enter, date/priority
shortcuts, and Ctrl+K / Command+K focuses search. Sort uses a popup; the advanced
filter dialog remains available. Compact and large-text layouts retain drafts.

Flutter task manager and QA lab for Topic 4: UI Automation Testing in Flutter:
Implementing End-to-End Testing (503107). Account-based REST/SQLite backend plus
an isolated offline demo. This is not yet the final coursework submission.

## Verified state and upgrade plan

[Quick-create exit protection](docs/quick-create-exit.md) asks before discarding
drafts when leaving offline/sample workspaces and prevents exit during saves.
Run its native scenario separately:
`flutter test integration_test/quick_create_exit_test.dart -d windows`.

[UI spacing fixes](docs/ui-spacing-20260912.md) improve field gaps, large-text
dropdowns and floating labels, and avoid redundant Edit form rebuilds.
No measured FPS improvement is claimed.

[B1 edit-draft protection](docs/upgrade-b1.md) adds explicit Continue editing /
Discard on dirty Cancel, Escape or Back, while blocking dismissal during save.
Quick-create exit protection and B2 validation improvements remain planned.

See [current verified state](docs/current-verified-state.md) for SHA-specific
local/hosted results and remaining gates, and [upgrade roadmap](docs/upgrade-roadmap.md)
for the bounded A-G plan. Package A updates evidence/documentation only;
remaining form protection and conflict-recovery upgrades are still next steps.

## Included

- Validated task creation/editing, completion/reopening and substring search.
- Notes, priority, calendar due date and normalized tags, including legacy-data defaults.
- Combined status/priority/due/tag filters and deterministic sorting.
- Delete confirmation and one-level undo of the latest deletion in the current session.
- Failed edits retain the draft; failed deletes/undo preserve retryable state.
- Local JSON persistence using SharedPreferencesAsync.
- Loading, empty, error and retry states; constrained responsive layout.
- Feature-first repository/controller/UI layers, injectable clock/ID and fake storage.
- Shared modern indigo theme, responsive status navigation, task cards and
  cohesive sign-in/settings panels. See [UI review](docs/ui-refresh-20260911.md).
- Latest [color studio refinement](docs/color-studio-ui.md): violet actions,
  mint/peach task surfaces and original geometric header with readable labels.

- 92 unit/widget/golden tests, including 15 task/auth/settings/dialog visual baselines,
  accessibility guidelines, text scaling, keyboard interaction and signed-in
  account-settings validation/focus coverage.
- [Bug audit](docs/bug-audit-20260912.md): snapshot-load safety and session-race
  regressions. Controller consumers must successfully load before mutations.
- Reproducible intentional search-defect experiment with real fail/fix logs.
- Account registration/login, profile/password/recovery, session revocation and
  account deletion; server-owned per-user tasks and conflict-safe writes.
- 14 backend tests and 10 Windows integration case executions pass for the UI refresh.
  Historical Android API 36 evidence has 9 case executions, not a run of this UI.
  That Android gate repeats the 4 controlled-repository, 3
  persisted-preference and 2 preference-backed workflows; the online API/SQLite
  workflow remains Windows-only. See the evidence manifest for fidelity boundaries.

## Run

For a Web build with locally served renderer assets, use
`flutter build web --release --no-web-resources-cdn`. Serve the complete
`build/web` directory, including `canvaskit/`. The Edge QA script uses this flag
for its test build and default-app restoration. This alone does not establish
fully offline Web support. `-NoPub` on the Edge/online test scripts is optional
and requires already-resolved dependencies matching `pubspec.lock`.

Recorded golden/evidence baseline and the D:/flutter host: Flutter 3.47.1 and
Dart 3.13.1. The other development host and CI use Flutter 3.47.0 / Dart 3.13.0; `pubspec.yaml`
intentionally permits Dart 3.13.0. Keep `pubspec.lock`, and do not regenerate
goldens solely because the SDK changes.
After installing Flutter and adding its bin directory to PATH:

```sh
git clone --branch main-test https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project.git
cd CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project
flutter pub get
flutter run -d chrome --web-port 7357
```

For account mode, first start the API in a separate terminal from repository root:

```powershell
.\scripts\run-backend.ps1
```

Node 22.14.0 is installed on the development machine. Full configuration, API
contract, account/recovery instructions, tests and backup procedure:
[backend/README.md](backend/README.md). The default API is http://127.0.0.1:8080.
Override it at build/run time with `--dart-define=API_BASE_URL=https://your-api-origin`.
No hosted server is supplied or claimed. Alternatively select **Use offline demo**
on the sign-in screen to use the original app without any server/account.

For a repeatable presentation, choose **Try sample sandbox**: three synthetic
tasks load in memory. Create/edit/delete freely; exit and re-enter to reset.
This mode neither overwrites offline tasks nor calls the account API. Changes
are intentionally discarded, including after a page refresh.

Development branch: `main-test` (Edge/sample/accessibility milestone 2026-09-08). The remote default remains
`main`; use the explicit clone branch above for this milestone. The repository
has moved from Long-D176 to cross-platform-mobile-team.

On the original Windows machine Flutter is installed outside PATH:

```powershell
& 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat' run -d chrome --web-port 7357
```

Enter a title and select Add task. Select a checkbox to complete/reopen a task.
Expand **Task details (optional)** for notes, priority, due date and comma-separated
tags. Use **Edit** to change all fields. Due dates use YYYY-MM-DD; clear the field
to remove a date. Notes allow 2000 characters; up to 10 tags of 24 characters each.
Tags are trimmed, lowercased, deduplicated and sorted. Existing saved tasks receive
empty notes/tags, medium priority and no date without discarding their old fields.

Delete opens a confirmation dialog; Undo delete restores
the latest deleted task, including its completion status. Undo lasts until another
successful deletion or until the app session ends. Search matches title, notes and tags.
**Filter and sort** combines filters with AND; exact tag matching is case-insensitive.
Overdue means before today's local calendar date and not completed. Today/upcoming
include completed tasks unless a status filter excludes them. Due-date sorting puts
undated tasks last; priority sorting puts high first; ties use ascending task ID.
**Clear filters** also resets search and sorting.
Offline demo needs no account; initial storage is empty. Account mode starts with
separate empty server data. Offline tasks are never uploaded automatically.
Web storage belongs to the browser origin: retain the same port between sessions.
Preferences are for small non-critical demo data and do not guarantee durability.

## Verify

### Android and CI status - 2026-09-09

GitHub Actions [run #2](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886)
for commit `9ca2a96` passed all three jobs. The pinned Flutter 3.47.0/JDK 17
workflow runs format, analysis, 57 Flutter tests, 14 backend tests, Web/Windows
release builds, debug/release APK builds, and 9 isolated workflows on an Android
16/API 36 Google APIs emulator. Artifact `taskflow-android-apks` contains both
APKs and `SHA256SUMS.txt`; GitHub retains it for 14 days, through 2026-09-23.

The current Windows host has SDK `C:\Android\sdk`, NDK `28.2.13676358`, and AVD
`taskflow_api36`. Equivalent local commands, with an emulator running as
`emulator-5554`, are:

```powershell
flutter build apk --debug
flutter build apk --release
flutter test integration_test/independent_scenarios_test.dart -d emulator-5554
flutter test integration_test/persisted_scenarios_test.dart -d emulator-5554
flutter test integration_test/windows_workflow_test.dart -d emulator-5554
```

The CI result establishes hosted emulator execution, not a physical-device test,
manual release-APK installation, Android account-mode connectivity, or Play Store
signing. The current release configuration still uses the debug signing key.

To measure repeated local test commands across unit, widget, golden and Windows
integration levels (three fresh processes per suite, existing SDK required):

```powershell
.\scripts\repeat-test-levels.ps1 -FlutterSdk C:\path\to\flutter -Repetitions 3
```

Run `flutter pub get` first. Raw logs and `results.json` go to a unique directory
under ignored `build/`. Any failed repetition makes the script fail. These suites
have different workloads; see [experiment interpretation](docs/experiments/test-levels-20260909.md).

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test --coverage
flutter build web --release
```

Latest commands and results: [evidence manifest](docs/evidence/manifest.md).
The 61-case suite includes 8 goldens with a Windows-host/Flutter-3.47.1 baseline;
read [golden and accessibility setup](docs/golden-testing.md) before running on a
different host or changing images. Android API 36 now has the separate hosted CI
evidence described above; golden images still are not Android-device screenshots.
Reproduce the [intentional defect](docs/evidence/intentional_defect/README.md)
in a disposable checkout; keep the corrected source in normal development.

## Windows desktop

Windows toolchain: Visual Studio Build Tools 2022 17.14.39 with C++ workload,
CMake and Windows SDK 10.0.26100. Installed locally at D:/VSBuildTools2022.

```powershell
.\scripts\run-windows.ps1
# Or with Flutter on PATH:
flutter run -d windows
flutter test integration_test/windows_workflow_test.dart -d windows
flutter test integration_test/independent_scenarios_test.dart -d windows --reporter expanded
flutter test integration_test/persisted_scenarios_test.dart -d windows --reporter expanded
.\scripts\test-online-windows.ps1
flutter build windows --release
```

Launch `build/windows/x64/runner/Release/taskflow_qa_lab.exe`. Distribute the entire
Release directory, including flutter_windows.dll and data, not just the executable.
The local archive `build/TaskFlow-Windows-x64-20260908.zip` contains the
backend-enabled Release directory. Start the API separately for account mode.
Its SHA-256 on this machine is
`FCA4227B9E292C5E0E70C7A4E6AC65C4C00A6A3D77CDC957AC10FB3E29AD3FB7`.
Other machines may need the Microsoft Visual C++ x64 Redistributable; the archive
has not been installed/tested on a clean Windows machine.
Native online test output: [Windows account/API evidence](docs/evidence/backend-online-windows-20260907.txt).
Automated native typing uses Flutter's registered test text-input channel; Windows
IME behavior itself is not covered. Rendering and preference storage remain native.

### Independent E2E scenarios

[Scenario guide](docs/independent-e2e.md) explains fixtures and expected results.
The new suite starts from a fresh in-memory repository per case: empty/invalid
submit/correction at 390 and 1100 logical-pixel widths, seeded substring search
with combined status/priority/tag filters and exact sort order, then controlled
load/write failure with explicit Retry and draft preservation. Viewport overrides
are not evidence of Android execution or physically resizing a Windows window.
These complement, rather than replace, the real-storage and real-network suites.

Run each native suite in its own Flutter command as shown above. A combined
multi-file invocation failed at the second app's debug connection on this host;
the affected suite passed separately. The original failure is retained in the
evidence manifest; this is not a claim that the runner failure is fully diagnosed.

The persisted suite independently checks fresh create, edit/complete and
cancel/delete/undo with native storage, full metadata comparison and UI remount.
It clears only its own test keys, never your offline tasks. See the
[project review and next priorities](docs/project-review-20260907.md).

## Continue development

Read [AGENTS.md](AGENTS.md), [implementation prompt](PROJECT_IMPLEMENTATION_PROMPT.md),
[plan](docs/project-plan.md), [traceability](docs/requirements-traceability.md),
[tests](docs/test-matrix.md), [latest full review](docs/project-review-20260909.md),
and [limitations](docs/limitations.md).

Edge now has real API CRUD/undo/re-login evidence and an executable sample
isolation check. See [Web/Edge reproduction](docs/web-edge-testing.md).
Automated account-form guidelines, keyboard focus and 200% text checks complement
the existing task-screen coverage; tags expose text semantics, not checkboxes.

For deterministic browser failures and discovery checks, use the dedicated QA
harness. It is excluded from the normal entrypoint and requires an explicit flag:

```powershell
.\scripts\test-edge-harness.ps1 -Flutter C:\path\to\flutter.bat -Repetitions 5
```

The script builds synthetic in-memory scenarios, runs Edge, cleans up its own
server/browser and restores the default Web build. See the
[five-run experiment](docs/experiments/edge-harness-stability-20260909.md).

To test across fresh Edge sessions instead of only repeating in one browser:

```powershell
.\scripts\test-edge-harness.ps1 -Flutter C:\path\to\flutter.bat -Sessions 3 -Repetitions 2
.\scripts\tests\edge-runner-contract.ps1
```

Each named session is opened without a persistent profile and closed before the
next. Raw CLI output and JSON results are retained under a unique
`output/playwright/edge-sessions-<id>/` folder, even when assertions fail.
`Seconds` in each session measures the workflow CLI invocation;
`SecondsIncludingLifecycle` also includes browser open/close. Neither includes
the shared Web build. A failed repetition fails the overall run; the contract
test checks this with a synthetic CLI, not the app. Existing output directories
cannot be reused. No personal browser tabs, API accounts or offline tasks are used.
Recorded six-run result: [fresh-session verification](docs/evidence/edge-sessions-20260910/README.md).

The [accessibility protocol](docs/accessibility-testing.md) documents automated
account entry/settings coverage and the still-NOT-RUN manual Narrator/full focus
order pass. Next: execute that manual pass, perform a clean-machine/manual APK
reproduction, configure production Android signing if required, and prepare the
next engineering increment. Report/video work is deferred at the user's request.

This bootstrap was created with AI assistance for team review and understanding.
Follow instructor disclosure requirements. Platform runners come from flutter
create; application logic is original. Dependencies retain their own licenses.
