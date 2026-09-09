# TaskFlow QA Lab

Flutter task manager and QA lab for Topic 4: UI Automation Testing in Flutter:
Implementing End-to-End Testing (503107). Account-based REST/SQLite backend plus
an isolated offline demo. This is not yet the final coursework submission.

## Included

- Validated task creation/editing, completion/reopening and substring search.
- Notes, priority, calendar due date and normalized tags, including legacy-data defaults.
- Combined status/priority/due/tag filters and deterministic sorting.
- Delete confirmation and one-level undo of the latest deletion in the current session.
- Failed edits retain the draft; failed deletes/undo preserve retryable state.
- Local JSON persistence using SharedPreferencesAsync.
- Loading, empty, error and retry states; constrained responsive layout.
- Feature-first repository/controller/UI layers, injectable clock/ID and fake storage.
- 55 unit/widget/golden tests, including 8 phone/wide visual baselines,
  accessibility guidelines, text scaling and keyboard interaction.
- Reproducible intentional search-defect experiment with real fail/fix logs.
- Account registration/login, profile/password/recovery, session revocation and
  account deletion; server-owned per-user tasks and conflict-safe writes.
- 14 backend tests and 10 Windows integration cases: 5 real-preference workflows,
  1 real API/SQLite workflow, and 4 independent controlled-repository scenarios.
  See the current evidence manifest for results and fidelity boundaries.

## Run

Baseline: Flutter 3.47.1 and Dart 3.13.1. Keep pubspec.lock.
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

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test --coverage
flutter build web --release
```

Latest commands and results: [evidence manifest](docs/evidence/manifest.md).
The 55-case suite includes 8 goldens with a Windows-host/Flutter-3.47.1 baseline;
read [golden and accessibility setup](docs/golden-testing.md) before running on a
different host or changing images. Android remains unverified.
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
[tests](docs/test-matrix.md), and [limitations](docs/limitations.md).

Edge now has real API CRUD/undo/re-login evidence and an executable sample
isolation check. See [Web/Edge reproduction](docs/web-edge-testing.md).
Automated account-form guidelines, keyboard focus and 200% text checks complement
the existing task-screen coverage; tags expose text semantics, not checkboxes.

Next: broader browser failure/filter automation, manual screen-reader/full focus
order, repeated-run experiments, clean-machine verification and report/video.

This bootstrap was created with AI assistance for team review and understanding.
Follow instructor disclosure requirements. Platform runners come from flutter
create; application logic is original. Dependencies retain their own licenses.
