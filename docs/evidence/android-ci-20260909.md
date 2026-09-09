# Android and GitHub Actions evidence - 2026-09-09

## Provenance

- Repository: `cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project`
- Branch: `main-test`
- Workflow: `.github/workflows/quality.yml`, `Quality and Android`
- Successful source commit: `9ca2a96b7148520d8696ed3336e3da2f8cdd68fe`
- Run: [#2 / 34377270886](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34377270886)
- Observed status: `completed / success`, 2026-09-09 16:31:32Z to 16:45:53Z

The values below were read from the public GitHub Actions run, jobs and artifacts
API after completion. The linked run retains GitHub's authoritative logs. This
file is a reviewed index, not a fabricated transcript.

## Successful jobs

| Job | GitHub job ID | Observed result | UTC interval |
|---|---:|---|---|
| Windows quality gates | `102553266114` | PASS | 16:32:01-16:38:30 |
| Android APKs | `102553265848` | PASS | 16:32:01-16:38:46 |
| Android E2E (API 36) | `102555630662` | PASS | 16:38:48-16:45:52 |

The Windows job passed environment capture, dependency resolution, formatting,
analysis, 57 Flutter tests, backend syntax plus 14 Node tests, Web release, and
Windows release. The Android build job passed SDK component installation, debug
APK, release APK, checksum generation, and artifact upload.

The Android E2E job used a Google APIs x86_64 Android 16/API 36 emulator and ran
these commands sequentially; shell fail-fast behavior means job success requires
all three commands to return zero:

```sh
flutter test integration_test/independent_scenarios_test.dart -d emulator-5554
flutter test integration_test/persisted_scenarios_test.dart -d emulator-5554
flutter test integration_test/windows_workflow_test.dart -d emulator-5554
```

Those files contain 4, 3 and 2 cases respectively: 9 Android case executions.
The real API/SQLite online workflow was not run on Android because emulator
`127.0.0.1` is not the Windows host and no hosted HTTPS backend is supplied.

## Artifact

- Name: `taskflow-android-apks`
- Artifact ID: `10114650196`
- Compressed bundle size reported by GitHub: `98,096,376` bytes
- Created: `2026-09-09T16:38:18Z`
- Expires: `2026-09-23T16:38:11Z`
- Contents configured and successfully uploaded: `app-debug.apk`,
  `app-release.apk`, and `SHA256SUMS.txt`

Download the artifact from the successful run page while signed in to GitHub.
The checksum file travels with the APKs; its hash values are not copied here
because the unauthenticated artifact-download endpoint returned HTTP 401.

## Retained first-run failure

[Run #1 / 34376768204](https://github.com/cross-platform-mobile-team/CROSS-PLATFORM-MOBILE-APP-DEVELOPMENT-Midterm-Project/actions/runs/34376768204)
at commit `60689a2` ended `cancelled` after the Android build job could not find a
bare `sdkmanager` executable (exit 127). Commit `9ca2a96` used the SDK root's
explicit command-line-tools path and upgraded pinned action releases. The
replacement push superseded the remaining first-run work. This was CI setup
failure/fix evidence, not an application test failure.

## Boundaries

This evidence establishes hosted Android compilation and automated API 36 emulator
execution. It does not establish a physical-device run, manual release-APK
installation/launch, Android account-mode connectivity, screen-reader output,
clean-machine reproduction, or Play Store signing. The current release variant
uses the debug signing configuration.
