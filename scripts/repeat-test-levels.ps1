param(
    [string]$FlutterSdk = "$env:USERPROFILE\flutter-sdk",
    [ValidateRange(2, 20)][int]$Repetitions = 3
)
$ErrorActionPreference = 'Stop'
$flutter = Join-Path $FlutterSdk 'bin\flutter.bat'
if (!(Test-Path -LiteralPath $flutter)) { throw 'Flutter SDK not found.' }
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$folder = Join-Path $project "build\test-levels-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $folder | Out-Null
$cases = @(
    @{ Level = 'unit'; Target = 'test/unit/task_controller_test.dart'; Extra = @() },
    @{ Level = 'widget'; Target = 'test/widget/search_regression_test.dart'; Extra = @() },
    @{ Level = 'golden'; Target = 'test/golden/task_screen_golden_test.dart'; Extra = @() },
    @{ Level = 'native'; Target = 'integration_test/independent_scenarios_test.dart'; Extra = @('-d', 'windows') }
)
$rows = @()
Push-Location $project
try {
    & $flutter --version 2>&1 | Tee-Object -FilePath (Join-Path $folder 'environment.txt')
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read Flutter version.' }
    git rev-parse HEAD | Out-File (Join-Path $folder 'source.txt')
    git status --short | Out-File (Join-Path $folder 'source.txt') -Append
    for ($round = 1; $round -le $Repetitions; $round++) {
        # Rotate execution order to reduce systematic first/last ordering effects.
        for ($offset = 0; $offset -lt $cases.Count; $offset++) {
            $case = $cases[($round - 1 + $offset) % $cases.Count]
            $arguments = @('test', $case.Target, '--no-pub', '--reporter', 'expanded') + $case.Extra
            $log = "$($case.Level)-$round.txt"
            $command = "flutter $($arguments -join ' ')"
            Write-Output "Round $round : $command"
            $started = [DateTime]::UtcNow.ToString('o')
            $timer = [Diagnostics.Stopwatch]::StartNew()
            & $flutter @arguments 2>&1 | Tee-Object -FilePath (Join-Path $folder $log)
            $code = $LASTEXITCODE
            $timer.Stop()
            $rows += [pscustomobject]@{
                Round = $round; Level = $case.Level; StartedUtc = $started
                Seconds = [Math]::Round($timer.Elapsed.TotalSeconds, 3)
                ExitCode = $code; Command = $command; Log = $log
            }
            $rows | ConvertTo-Json -Depth 3 | Out-File (Join-Path $folder 'results.json') -Encoding utf8
        }
    }
    $rows | Format-Table Round, Level, Seconds, ExitCode
    if (@($rows | Where-Object ExitCode -ne 0).Count) {
        throw 'One or more repetitions failed; inspect results.json and raw logs.'
    }
} finally {
    Pop-Location
    Write-Output "Experiment output: $folder"
}
