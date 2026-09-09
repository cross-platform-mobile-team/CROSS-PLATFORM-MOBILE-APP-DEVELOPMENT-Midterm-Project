# Edge harness repeated-run experiment - 2026-09-09

Student-review draft. This is a small controlled experiment, not a universal
browser reliability benchmark.

## Question and hypothesis

Can the same deterministic Edge workflow complete repeatedly without sleeps,
state leakage or assertion failures? Hypothesis: all five consecutive runs in
one isolated Edge session will pass, with reset-by-URL keeping each scenario
independent from the prior run.

## Method and controls

- Host: Windows 11 10.0.26200.9168.
- Browser: Microsoft Edge 152.0.4191.66, isolated Playwright profile.
- Flutter/Dart: 3.47.1 / 3.13.1; JavaScript Web release build.
- Driver: `@playwright/cli@0.1.19` via npx, no global install.
- Harness: `lib/browser_test_harness.dart`, explicitly compiled with
  `TASKFLOW_BROWSER_HARNESS=true` and served only on loopback.
- Data: fixed synthetic tasks; in-memory repository; no API, preferences,
  credentials or user data.
- Repetitions: five, sequentially in one open browser session.
- Timing: PowerShell Stopwatch around each complete CLI invocation. This includes
  navigation, semantics activation and assertions, but excludes build/browser
  startup and teardown.
- Synchronization: role/label locators and observable conditions only; no fixed
  sleeps in the browser workflow.

Each run checks controlled load failure/Retry, accessible blank-title validation,
controlled save failure, draft preservation, successful retry, normalized search,
pending AND high AND exact normalized tag filtering, exact title order, no-match
state and Clear restoring newest order.

Command after opening the isolated harness browser:

```powershell
.\scripts\browser\repeat-edge-harness.ps1 -Repetitions 5
```

The complete clean orchestration, including build, loopback server, isolated
browser, cleanup and restoration of the normal Web build, is:

```powershell
.\scripts\test-edge-harness.ps1 -Flutter C:\path\to\flutter.bat -Repetitions 5
```

## Observed result

| Run | Result | Seconds |
|---:|:---:|---:|
| 1 | PASS | 7.900 |
| 2 | PASS | 7.461 |
| 3 | PASS | 8.024 |
| 4 | PASS | 7.202 |
| 5 | PASS | 7.326 |

Passed: 5/5. Mean 7.583 s; median 7.461 s; min 7.202 s; max 8.024 s.
Raw output: `../evidence/browser-harness-repeat5-20260909.txt`.

A separate one-repetition smoke of the final complete orchestration script also
PASSed and restored the normal Web build. Its 9.240 s inner workflow is not added
to the five-run series because setup conditions differed. Raw output:
`../evidence/browser-harness-orchestrated-final-20260909.txt`. An earlier 8.578 s
orchestration smoke preceded the final port/restore exit-code safeguards and is
retained as development evidence, not combined with the experiment.

## Interpretation and limitations

No failure occurred in this five-run sample. This supports repeatability for the
specified workflow on this host/session only; it does not establish a population
failure rate, long-duration stability or cross-version reliability. Five runs are
too few for a strong statistical conclusion, and warm browser/cache state is a
confounder. The test does not cover network/backend behavior, physical keyboard/
IME, Narrator, Android, another machine or concurrent browser tabs.

Earlier development runs failed because of the CLI script itself: unavailable
`URL` global, semantics activation before the button appeared, duplicate live
announcement locators, asynchronous validation attributes and whitespace in raw
ARIA labels. Those failures are retained in the evidence manifest. Fixes used
observable readiness, exact accessible roles and normalized ARIA whitespace; no
application assertion was removed and no wait duration was inflated.
