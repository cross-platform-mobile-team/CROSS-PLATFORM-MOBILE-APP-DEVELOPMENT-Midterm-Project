param(
  [ValidateRange(1, 50)]
  [int]$Repetitions = 5,
  [string]$Session = 'taskflow-harness',
  [string]$OutputDirectory,
  [string]$Cli = 'npx.cmd'
)

$ErrorActionPreference = 'Stop'
$npx = (Get-Command $Cli -ErrorAction Stop).Source
$scriptPath = Join-Path $PSScriptRoot 'edge-harness-check.js'
$rows = @()
if (-not $OutputDirectory) {
  $OutputDirectory = Join-Path $PSScriptRoot "../../output/playwright/repeat-$([guid]::NewGuid().ToString('N'))"
}
# Refuse reuse so a later run cannot replace earlier evidence.
if (Test-Path -LiteralPath $OutputDirectory) { throw 'OutputDirectory must not already exist.' }
New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
Write-Output "Raw results: $OutputDirectory"

Write-Output 'TaskFlow Edge harness repeated-run experiment'
Write-Output "Started UTC: $([DateTime]::UtcNow.ToString('O'))"
Write-Output "CLI package: @playwright/cli@0.1.19"
Write-Output "Session: $Session"
Write-Output "Repetitions: $Repetitions"

for ($iteration = 1; $iteration -le $Repetitions; $iteration++) {
  $started = [DateTime]::UtcNow.ToString('O')
  $timer = [Diagnostics.Stopwatch]::StartNew()
  $result = @(
    & $npx --yes --package '@playwright/cli@0.1.19' playwright-cli "-s=$Session" run-code --filename $scriptPath 2>&1
  )
  $exitCode = $LASTEXITCODE
  $timer.Stop()
  $text = $result -join [Environment]::NewLine
  $passed = $exitCode -eq 0 -and $text.Contains('"result":"PASS"')
  $log = "run-$iteration.txt"
  $text | Out-File (Join-Path $OutputDirectory $log) -Encoding utf8
  $rows += [pscustomobject]@{
    Run = $iteration
    Result = if ($passed) { 'PASS' } else { 'FAIL' }
    Seconds = [Math]::Round($timer.Elapsed.TotalSeconds, 3)
    StartedUtc = $started
    ExitCode = $exitCode
    Session = $Session
    Log = $log
    Command = "@playwright/cli@0.1.19 playwright-cli -s=$Session run-code --filename $scriptPath"
  }
  ConvertTo-Json -InputObject @($rows) -Depth 3 | Out-File (Join-Path $OutputDirectory 'results.json') -Encoding utf8
  if (-not $passed) {
    Write-Output $text
    Write-Output "Edge harness run $iteration failed with exit code $exitCode; retaining result and continuing."
  }
}

$rows | Format-Table -AutoSize
$values = @($rows.Seconds | Sort-Object)
$mean = ($values | Measure-Object -Average).Average
$midpoint = [int][Math]::Floor($values.Count / 2)
$middle = if ($values.Count % 2) { $values[$midpoint] } else {
  ($values[$midpoint - 1] + $values[$midpoint]) / 2
}
Write-Output "Passed: $($rows.Where({ $_.Result -eq 'PASS' }).Count)/$Repetitions"
Write-Output "Mean seconds: $([Math]::Round($mean, 3))"
Write-Output "Median seconds: $([Math]::Round($middle, 3))"
Write-Output "Min seconds: $($values[0])"
Write-Output "Max seconds: $($values[-1])"
Write-Output 'Scope: one Edge version, one Windows host, one open isolated browser session.'
if (@($rows | Where-Object Result -eq 'FAIL').Count) {
  throw 'One or more Edge repetitions failed; inspect retained results.json and raw logs.'
}
