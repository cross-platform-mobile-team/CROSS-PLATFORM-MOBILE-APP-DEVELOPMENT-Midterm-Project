# Web / Microsoft Edge evidence - 2026-09-08

Student-review draft. These are development-machine checks, not a complete
accessibility audit, reliability measurement or final coursework submission.

## Safe sample demonstration

Select **Try sample sandbox** on the sign-in page. A fresh in-memory repository
contains three synthetic tasks. All normal task operations work in this sandbox;
exit and re-enter to reset. **Use offline demo** instead uses the existing local
preferences and deliberately does not seed or clear them. Neither mode silently
uploads tasks. The sample notice remains visible while using the sandbox.

## Reproduction environment

Flutter 3.47.1 / Dart 3.13.1, Windows 11 10.0.26200.9168, Edge 152.0.4191.66,
Node 22.14.0. CLI tooling only: `@playwright/cli@0.1.19`, resolved using npx;
no production app dependency or global installation was added.

Use an isolated temporary browser profile and a fresh ignored SQLite database.
Never point synthetic-account tests at a deployed server. From the repo root,
in a dedicated PowerShell terminal:

```powershell
$edgeData = New-Item -ItemType Directory -Path ('build/edge-' + [guid]::NewGuid())
$env:DATABASE_PATH = Join-Path $edgeData.FullName 'test.sqlite'
$env:HOST = '127.0.0.1'
$env:PORT = '8082'
$env:CORS_ORIGINS = 'http://127.0.0.1:7358'
node backend/src/server.js
```

In a second terminal (Flutter and Python available on PATH):

```powershell
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8082
python -m http.server 7358 --bind 127.0.0.1 --directory build/web
```

Use the explicit Flutter SDK path from environment.md if it is not on PATH.
Python is only a local static server, not a backend runtime dependency. Stop
only these test processes afterward and rebuild `flutter build web --release`
without the test define to restore the default API address (127.0.0.1:8080).

## Edge automation

```powershell
npx.cmd --yes --package @playwright/cli@0.1.19 playwright-cli -s=taskflow-edge open http://127.0.0.1:7358 --browser msedge --headed
npx.cmd --yes --package @playwright/cli@0.1.19 playwright-cli -s=taskflow-edge snapshot
```

Flutter initially exposes an **Enable accessibility** placeholder. In this build
it is offscreen, so normal automation clicking times out. Use the ref returned
by the current snapshot with `eval 'el => el.click()' <ref>` to enable semantics.
This automation bootstrap does **not** verify Narrator activation. Take a fresh
snapshot after navigation; never reuse stale element refs.

Choose **Try sample sandbox**, then:

```powershell
npx.cmd --yes --package @playwright/cli@0.1.19 playwright-cli -s=taskflow-edge run-code --filename scripts/browser/edge-sample-check.js
```

The snippet checks created task visibility, normalized search excluding an
unrelated task, reset after exit/re-entry, unchanged localStorage and no `/v1/`
requests during the sample flow. It is a CLI assertion snippet, not an
`integration_test` or `@playwright/test` suite. Start with fresh sample data.
The current evidence manifest records both passes and failed automation attempts;
do not infer repeatability from a single pass or add arbitrary timeout sleeps.
The final helper waits for native INPUT focus, types keyboard events, and does
not immediately Tab away. Earlier fill/Tab variants sometimes showed DOM text
without successful creation. Two final runs passed; the engine-level cause of
the earlier mismatch is not conclusively diagnosed.

## Observed online workflow

Against the isolated server, a synthetic `edge@example.test` account was used
for sign-in, create, edit, complete, confirm delete and undo. A direct API read
also checked the created record. Page reload returned to sign-in (tokens are
memory-only); signing in again restored the edited, completed record.

Raw evidence: `evidence/edge-server-check-20260908.txt`,
`evidence/edge-online-restored-20260908.txt`,
`evidence/edge-relogin-20260908.txt`. These are real observations, not a committed
full online browser runner. To repeat, create your own synthetic account on the
isolated server and follow that sequence. Keep passwords, session tokens and
recovery codes out of published screenshots/logs/traces. Do not record recovery
screens. Temporary databases, browser profiles and raw browser artifacts are ignored.

## Accessibility scope

Edge keyboard observation: Email -> Tab -> Password focus. Task tags were
incorrectly exposed as checkboxes by Chip semantics; they now expose individual
`Tag: ...` text nodes. Completion remains a real checkbox. The permanent widget
regression checks the tag label. Widget tests additionally check login/register/
recovery invalid-form guidelines, keyboard interaction and registration at 200%
text; the eight existing golden baselines were not regenerated.

Phone/wide Edge viewport screenshots demonstrate layout at 390x844 and 1280x900,
not Android execution. Full tab order, Narrator announcements, browser zoom and
account settings now have automated widget coverage, but still need the documented
manual Narrator/full-page focus check. Browser filter/sort ordering
and controlled failure/retry were added in the following dated increment. No
WCAG certification, Android/APK, CI or clean-machine result is claimed.

Reviewed images are under `evidence/screenshots/`: sample phone/wide, restored
online task, and login keyboard-focus state. They use synthetic data only.

## Deterministic browser QA harness - 2026-09-09

The installed Flutter command reports that Web devices are not supported for
integration tests. `lib/browser_test_harness.dart` therefore supplies equivalent
browser-only scenarios without modifying the default client. It throws unless
compiled with `TASKFLOW_BROWSER_HARNESS=true`, contains no API client or preference
repository, and resets fixed synthetic state by URL.

Run the complete Windows orchestration:

```powershell
.\scripts\test-edge-harness.ps1 -Flutter C:\path\to\flutter.bat -Port 7359 -Repetitions 5
```

The script checks dependencies, builds the explicit target, starts a hidden
loopback Python server, opens a named isolated Edge profile, runs role-based
assertions, closes only its own browser/server, and rebuilds normal `main.dart`.
Its setup uses bounded TCP readiness polling; the test workflow itself has no
fixed sleep. Browser output stays in ignored `output/playwright/` unless reviewed.

Evidence and interpretation: `experiments/edge-harness-stability-20260909.md`.
