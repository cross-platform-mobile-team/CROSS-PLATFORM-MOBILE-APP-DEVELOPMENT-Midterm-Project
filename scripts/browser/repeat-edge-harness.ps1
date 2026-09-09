param(
  [ValidateRange(1, 50)]
  [int]$Repetitions = 5,
  [string]$Session = 'taskflow-harness'
)

$ErrorActionPreference = 'Stop'
$npx = (Get-Command npx.cmd -ErrorAction Stop).Source
$scriptPath = Join-Path $PSScriptRoot 'edge-harness-check.js'
$rows = @()

Write-Output 'TaskFlow Edge harness repeated-run experiment'
Write-Output "Started UTC: $([DateTime]::UtcNow.ToString('O'))"
Write-Output "CLI package: @playwright/cli@0.1.19"
Write-Output "Session: $Session"
Write-Output "Repetitions: $Repetitions"

for ($iteration = 1; $iteration -le $Repetitions; $iteration++) {
  $timer = [Diagnostics.Stopwatch]::StartNew()
  $result = @(
    & $npx --yes --package '@playwright/cli@0.1.19' playwright-cli "-s=$Session" run-code --filename $scriptPath 2>&1
  )
  $exitCode = $LASTEXITCODE
  $timer.Stop()
  $text = $result -join [Environment]::NewLine
  $passed = $exitCode -eq 0 -and $text.Contains('"result":"PASS"')
  $rows += [pscustomobject]@{
    Run = $iteration
    Result = if ($passed) { 'PASS' } else { 'FAIL' }
    Seconds = [Math]::Round($timer.Elapsed.TotalSeconds, 3)
  }
  if (-not $passed) {
    $rows | Format-Table -AutoSize
    Write-Output $text
    throw "Edge harness run $iteration failed with exit code $exitCode."
  }
}

$rows | Format-Table -AutoSize
$values = @($rows.Seconds | Sort-Object)
$mean = ($values | Measure-Object -Average).Average
$middle = $values[[Math]::Floor($values.Count / 2)]
Write-Output "Passed: $($rows.Where({ $_.Result -eq 'PASS' }).Count)/$Repetitions"
Write-Output "Mean seconds: $([Math]::Round($mean, 3))"
Write-Output "Median seconds: $([Math]::Round($middle, 3))"
Write-Output "Min seconds: $($values[0])"
Write-Output "Max seconds: $($values[-1])"
Write-Output 'Scope: one Edge version, one Windows host, one open isolated browser session.'
