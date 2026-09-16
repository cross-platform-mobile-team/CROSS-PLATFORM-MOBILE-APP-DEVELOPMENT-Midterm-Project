# System fixes and verification 16 September 2026

Baseline: `04105d6`. Verified implementation: `bba02cd`, including the five
fix commits below. Tests were run on the same source before/after committing;
the following documentation increment does not change executable code.

## Changes and failure evidence

| Commit | Observed problem | Fix and regression |
| --- | --- | --- |
| `467efe7` | A rejected Android configuration had already overwritten the caller's environment | Validate SDK/JDK paths before setting any environment variables; `scripts/tests/android-environment-contract.ps1` |
| `d12d1d1` | Windows runners required a specific user-profile SDK folder although Flutter was installed on PATH | Resolve explicit SDK, then PATH, then the legacy default; reject an invalid explicit selection; `scripts/tests/flutter-resolver-contract.ps1` |
| `ca919cb` | API accepted nonexistent calendar days and JavaScript normalized them into a different date | Validate the written calendar date before timezone conversion; HTTP tests verify rejection leaves records/revision unchanged and valid leap days/offsets still work |
| `00e3145` | Collapsing invalid optional details hid the error; Edit did not focus the first invalid field | Expand details and focus/scroll to the invalid field; three widget cases cover compact/wide create and Edit with no premature writes |
| `bba02cd` | A failed backend syntax command could be masked by a later successful command in CI | Check every native exit code immediately and restore the working directory after tests; contract exercises the actual YAML run block |

The `*-before.txt` files are genuine expected failures. Android's original
helper was replayed in an isolated ignored directory with the new contract.
The backend replay used the original validation file (Git blob
`185d9c149fa8423e1d7322560fda1982ef5fc559`) and the new HTTP regression.
Form and CI baselines were run before their production changes. Original output,
including whitespace and stack traces, is retained. Synthetic runner/CI tests
do not represent actual application execution or a hosted CI run.

## Local checks

Commands are from the repository root unless noted. `--no-pub` runs follow a
successful dependency resolution with the existing lockfile.

| Command or scope | Result | Raw output |
| --- | --- | --- |
| `dart format --output=none --set-exit-if-changed .` | PASS, 60 files unchanged | [format.txt](format.txt) |
| `flutter analyze --no-pub` | PASS | [analyze.txt](analyze.txt) |
| `flutter test --no-pub --coverage --reporter expanded` | PASS, 103 cases, all 15 golden baselines unchanged | [flutter-suite.txt](flutter-suite.txt) |
| Focused form regression | FAIL before, PASS 3/3 after | [before](form-validation-before.txt), [after](form-validation-after.txt) |
| Seven backend `node --check` targets and `node --test --test-concurrency=1 backend/test/api.test.js` | PASS, 15 API cases | [backend-suite.txt](backend-suite.txt) |
| Focused invalid-createdAt HTTP regression | FAIL before, PASS after | [before](backend-timestamp-before.txt), [after](backend-timestamp-after.txt) |
| `flutter test integration_test/persisted_scenarios_test.dart -d windows --no-pub --reporter expanded` | PASS, 3 native cases | [windows-persisted.txt](windows-persisted.txt) |
| `scripts/test-online-windows.ps1 -NoPub` | PASS, 1 native API/SQLite case, SDK resolved from PATH | [windows-online.txt](windows-online.txt) |
| `flutter build windows --release --no-pub` | PASS | [windows-release.txt](windows-release.txt) |
| `flutter build web --release --no-web-resources-cdn --no-pub` | PASS, compilation only | [web-release.txt](web-release.txt) |
| `scripts/tests/android-environment-contract.ps1` | FAIL before, PASS after | [before](android-environment-before.txt), [after](android-environment-after.txt) |
| `scripts/tests/flutter-resolver-contract.ps1` | PASS | [flutter-resolver.txt](flutter-resolver.txt) |
| `scripts/tests/backend-ci-contract.ps1` | FAIL before, PASS after | [before](backend-ci-before.txt), [after](backend-ci-after.txt) |

Environment: Flutter 3.47.0, Dart 3.13.0, Windows 11 10.0.26200.9445,
Node 24.19.0, PowerShell 7.6.5. Exact paths, toolchain/device output and source
identity are in [environment.txt](environment.txt). The 103-case run includes
the three new form cases; repetitions are not additional unique tests. No
coverage percentage is inferred from the successful coverage invocation.

## Boundaries and remaining work

Only the persisted and online native suites were rerun for this change: four
Windows case executions. The other native suites and the Android 15-case
milestone retain their original 14–15 September evidence; they are not reruns
of these fixes. No emulator was connected during this review. The C: SDK has
platform 37.0 but lacks the platform 36 required by this Flutter SDK, so a new
local Android APK/build/install is NOT RUN. Android license status is unknown.
No SDK installation, golden replacement, history rewrite or modification of
previous evidence was performed.

The changed CI block passed local synthetic checks; a hosted result must be
checked against the pushed SHA. The existing Word/PDF report remains tied to
`3e4f733` and its 100 Flutter / 14 API measurements. It has not been re-exported
as part of these system fixes. Video, team contribution confirmation, manual
screen-reader checks and clean-machine submission acceptance remain open.
