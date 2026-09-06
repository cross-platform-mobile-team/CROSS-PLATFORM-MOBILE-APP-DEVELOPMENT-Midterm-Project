# TaskFlow QA Lab

Flutter bootstrap for Topic 4: UI Automation Testing in Flutter: Implementing
End-to-End Testing (503107). This is a starting project, not the final submission.

## Included

- Validated task creation/editing, completion/reopening and substring search.
- Notes, priority, calendar due date and normalized tags, including legacy-data defaults.
- Combined status/priority/due/tag filters and deterministic sorting.
- Delete confirmation and one-level undo of the latest deletion in the current session.
- Failed edits retain the draft; failed deletes/undo preserve retryable state.
- Local JSON persistence using SharedPreferencesAsync.
- Loading, empty, error and retry states; constrained responsive layout.
- Feature-first repository/controller/UI layers, injectable clock/ID and fake storage.
- 39 unit/widget/golden tests, including 8 phone/wide visual baselines,
  accessibility guidelines, text scaling and keyboard interaction.
- Reproducible intentional search-defect experiment with real fail/fix logs.

## Run

Baseline: Flutter 3.47.1 and Dart 3.13.1. Keep pubspec.lock.
After installing Flutter and adding its bin directory to PATH:

```sh
git clone --branch main-test https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project.git
cd CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project
flutter pub get
flutter run -d chrome --web-port 7357
```

Development branch: `main-test` (published 2026-09-06). The remote default remains
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
No account is needed; initial storage is empty.
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
The 39-case suite includes 8 goldens with a Windows-host/Flutter-3.47.1 baseline;
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
flutter build windows --release
```

Launch `build/windows/x64/runner/Release/taskflow_qa_lab.exe`. Distribute the entire
Release directory, including flutter_windows.dll and data, not just the executable.
The local archive `build/TaskFlow-Windows-x64.zip` contains this directory's contents.
Other machines may need the Microsoft Visual C++ x64 Redistributable; the archive
has only been launched on the development machine, not a clean Windows machine.
Native test output: [Windows evidence](docs/evidence/quality-windows-20260906.txt).
Automated native typing uses Flutter's registered test text-input channel; Windows
IME behavior itself is not covered. Rendering and preference storage remain native.

## Continue development

Read [AGENTS.md](AGENTS.md), [implementation prompt](PROJECT_IMPLEMENTATION_PROMPT.md),
[plan](docs/project-plan.md), [traceability](docs/requirements-traceability.md),
[tests](docs/test-matrix.md), and [limitations](docs/limitations.md).

Next: independent native E2E scenarios, browser automation, manual accessibility,
repeated-run experiments, clean-machine verification and report/video.

This bootstrap was created with AI assistance for team review and understanding.
Follow instructor disclosure requirements. Platform runners come from flutter
create; application logic is original. Dependencies retain their own licenses.
