# Synthetic CLI adapter for the runner contract test. Never launches a browser.
$sequence = $env:TASKFLOW_RUNNER_CASES.Split(',')
$counter = $env:TASKFLOW_RUNNER_COUNTER
$index = if (Test-Path -LiteralPath $counter) { [int](Get-Content $counter) } else { 0 }
($index + 1) | Set-Content $counter
switch ($sequence[$index]) {
  'pass' { Write-Output '{"result":"PASS"}'; $global:LASTEXITCODE = 0 }
  'missing' { Write-Output 'Synthetic missing assertion result'; $global:LASTEXITCODE = 0 }
  'nonzero' { Write-Output '{"result":"PASS"}'; $global:LASTEXITCODE = 7 }
  default { throw 'Unexpected synthetic runner case.' }
}
