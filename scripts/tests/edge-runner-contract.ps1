$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$folder = Join-Path $root "output/playwright/runner-contract-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $folder | Out-Null
$previousCases = $env:TASKFLOW_RUNNER_CASES
$previousCounter = $env:TASKFLOW_RUNNER_COUNTER
$runner = Join-Path $root 'scripts/browser/repeat-edge-harness.ps1'
$fixture = Join-Path $PSScriptRoot 'fixtures/harness-cli.ps1'
try {
  $env:TASKFLOW_RUNNER_CASES = 'pass,missing,nonzero,pass'
  $env:TASKFLOW_RUNNER_COUNTER = Join-Path $folder 'mixed-counter.txt'
  $mixed = Join-Path $folder 'mixed'
  $threw = $false
  try { & $runner -Repetitions 4 -Cli $fixture -OutputDirectory $mixed } catch { $threw = $true }
  if (-not $threw) { throw 'Runner accepted failed assertions or nonzero CLI exit.' }
  $rows = @(Get-Content (Join-Path $mixed 'results.json') -Raw | ConvertFrom-Json)
  if ($rows.Count -ne 4 -or ($rows.Result -join ',') -ne 'PASS,FAIL,FAIL,PASS') {
    throw 'Runner did not preserve all outcomes and continue after failure.'
  }
  if ($rows[2].ExitCode -ne 7) { throw 'Original CLI failure exit code was lost.' }
  foreach ($row in $rows) {
    if (-not (Test-Path (Join-Path $mixed $row.Log))) { throw 'Raw output missing.' }
  }
  $before = (Get-FileHash (Join-Path $mixed 'results.json')).Hash
  $threw = $false
  try { & $runner -Repetitions 1 -Cli $fixture -OutputDirectory $mixed } catch { $threw = $true }
  if (-not $threw -or (Get-FileHash (Join-Path $mixed 'results.json')).Hash -ne $before) {
    throw 'Existing evidence can be overwritten.'
  }
  $env:TASKFLOW_RUNNER_CASES = 'pass,pass'
  $env:TASKFLOW_RUNNER_COUNTER = Join-Path $folder 'success-counter.txt'
  $success = Join-Path $folder 'success'
  $output = @(& $runner -Repetitions 2 -Cli $fixture -OutputDirectory $success)
  $rows = @(Get-Content (Join-Path $success 'results.json') -Raw | ConvertFrom-Json)
  if ($rows.Count -ne 2 -or @($rows | Where-Object Result -ne 'PASS').Count) {
    throw 'Successful repetitions were not accepted.'
  }
  $expectedMedian = [Math]::Round(($rows[0].Seconds + $rows[1].Seconds) / 2, 3)
  if ($output -notcontains "Median seconds: $expectedMedian") { throw 'Even-count median is incorrect.' }
  Write-Output 'PASS: mixed outcomes, raw logs, continuation, exit codes, no overwrite, successful run and even median.'
  Write-Output 'Synthetic runner contract only; not Flutter or browser application evidence.'
} finally {
  $env:TASKFLOW_RUNNER_CASES = $previousCases
  $env:TASKFLOW_RUNNER_COUNTER = $previousCounter
  Write-Output "Contract artifacts: $folder"
}
