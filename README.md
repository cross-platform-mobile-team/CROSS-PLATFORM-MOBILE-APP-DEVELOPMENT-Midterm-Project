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

Local analysis, seven tests with coverage, and Web compilation passed. Android and
Windows runners are generated but not verified: install Android SDK/device tools
or Visual Studio Desktop development with C++ before native builds/tests.

## Continue development

Read [AGENTS.md](AGENTS.md), [implementation prompt](PROJECT_IMPLEMENTATION_PROMPT.md),
[plan](docs/project-plan.md), [traceability](docs/requirements-traceability.md),
[tests](docs/test-matrix.md), and [limitations](docs/limitations.md).

Next: edit/delete/undo, task metadata, advanced filters, goldens, native E2E,
defect experiment, platform evidence and report/video.

This bootstrap was created with AI assistance for team review and understanding.
Follow instructor disclosure requirements. Platform runners come from flutter
create; application logic is original. Dependencies retain their own licenses.
