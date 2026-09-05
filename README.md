# TaskFlow QA Lab

Flutter bootstrap for Topic 4: UI Automation Testing in Flutter: Implementing
End-to-End Testing (503107). This is a starting project, not the final submission.

## Included

- Validated task creation, completion/reopening and substring search.
- Local JSON persistence using SharedPreferencesAsync.
- Loading, empty, error and retry states; constrained responsive layout.
- Feature-first repository/controller/UI layers, injectable clock/ID and fake storage.
- Seven unit/widget tests, including phone and wide layouts.

## Run

Baseline: Flutter 3.47.1 and Dart 3.13.1. Keep pubspec.lock.
After installing Flutter and adding its bin directory to PATH:

```sh
git clone https://github.com/Long-D176/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project.git
cd CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project
flutter pub get
flutter run -d chrome --web-port 7357
```

On the original Windows machine Flutter is installed outside PATH:

```powershell
& 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat' run -d chrome --web-port 7357
```

Enter a title and select Add task. Select a checkbox to complete/reopen a task.
Search matches any part of a title. No account is needed; initial storage is empty.
Web storage belongs to the browser origin: retain the same port between sessions.
Preferences are for small non-critical demo data and do not guarantee durability.

## Verify

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test --coverage
flutter build web --release
```

Local analysis, seven unit/widget tests, Web compilation, Windows release build
and one Windows integration test passed. Android remains unverified.

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
Native test output: [Windows evidence](docs/evidence/windows-integration.txt).

## Continue development

Read [AGENTS.md](AGENTS.md), [implementation prompt](PROJECT_IMPLEMENTATION_PROMPT.md),
[plan](docs/project-plan.md), [traceability](docs/requirements-traceability.md),
[tests](docs/test-matrix.md), and [limitations](docs/limitations.md).

Next: edit/delete/undo, task metadata, advanced filters, goldens, native E2E,
defect experiment, platform evidence and report/video.

This bootstrap was created with AI assistance for team review and understanding.
Follow instructor disclosure requirements. Platform runners come from flutter
create; application logic is original. Dependencies retain their own licenses.
