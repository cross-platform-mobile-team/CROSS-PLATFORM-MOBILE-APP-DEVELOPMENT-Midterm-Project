# Repeated Flutter test commands - 2026-09-09

Agent-assisted experimental notes for student review.

## Question and hypothesis

How much feedback time do the selected existing test commands require, and do
they complete across three fresh invocations? Hypothesis: all selected suites
pass on the fixed host, and native build/launch overhead makes its command slower.
This is an observation of this project's commands with different workloads.

## Method

- Windows 11 10.0.26200.9168; Flutter 3.47.1 / Dart 3.13.1;
  Visual Studio Build Tools 2022 17.14.39.
- Three rounds, one command at a time. Order rotates by one level each round.
- Each command starts a fresh Flutter process. SDK/build caches remain warm.
- `--no-pub` excludes dependency resolution; run `flutter pub get` beforehand.
- Stopwatch surrounds command startup, output capture, compilation, app launch,
  assertions and exit. It does not measure assertion execution alone.
- Unit: four controller/domain cases, deterministic clock/ID and fake repository.
- Widget: one permanent middle-word search regression with two synthetic tasks.
- Golden: eight fixed images, vendored fonts, exact comparison; no baseline update.
- Native: four independent Windows validation/discovery/retry cases, fake storage,
  test text-input channel and logical viewport overrides.
- No account credentials, network API or production preferences are used.
- Source: parent commit 4f8166f plus the account-settings changes published with
  this experiment. Raw source.txt records the pre-publication worktree status.

Reproduce from repository root:

```powershell
.\scripts\repeat-test-levels.ps1 -FlutterSdk C:\Users\LENOVO\flutter-sdk -Repetitions 3
```

Output directory is unique under `build/`. `results.json` contains commands,
UTC start timestamps, durations, exit codes and raw log filenames. Completed
results are written after every run. Any nonzero test exit causes the final script
to fail, while ordinary test failures remain available for inspection.

## Results

All 12 real invocations passed. Times are seconds for the whole command.

| Selected suite | Round 1 | Round 2 | Round 3 | Mean | Result |
|---|---:|---:|---:|---:|---|
| Unit (4 cases) | 4.707 | 4.360 | 5.499 | 4.855 | 3/3 PASS |
| Widget (1 case) | 6.111 | 6.436 | 6.733 | 6.427 | 3/3 PASS |
| Golden (8 cases) | 8.857 | 8.074 | 7.113 | 8.015 | 3/3 PASS |
| Windows (4 cases) | 41.812 | 40.525 | 38.814 | 40.384 | 3/3 PASS |

Raw records: [results.json](../evidence/test-levels-20260909/results.json), with
all 12 logs, environment and source status in the same directory. None of the
golden baselines changed. Native command duration includes approximately 20-22
seconds of build output plus launch and workflow execution; the logs expose those
components. The expected command-level overhead difference appeared in this sample.

The script's failure handling was separately checked using an ignored synthetic
batch runner returning exit code 7: all eight requested records were retained and
the PowerShell process exited nonzero. That contract check is not Flutter app
evidence and is excluded from the table above and the intentional-defect study.

## Interpretation boundaries

Three passes cannot establish a population flakiness rate. The sample shares one
host, toolchain and caches. Rotation is partial with three rounds/four levels;
background host load is uncontrolled and there is no cold-start baseline.
Do not calculate a per-test speed ranking from unequal suites, or compare these
numbers directly with the earlier Edge command that excludes build/startup.

The unit suite checks state and rules without rendered UI; the widget case checks
visible search behavior; goldens check selected pixels; native cases add actual
Windows app rendering/launch with controlled storage. Maintenance differs too:
unit failures localize rules, widget locators depend on visible UI, goldens depend
on rendering environment, and native failures can involve toolchain/launch.
These are conclusions about the inspected fixtures, not measurements of all
possible tests at each level. CI, other hosts, manual Narrator and clean-machine
setup remain separate work.
