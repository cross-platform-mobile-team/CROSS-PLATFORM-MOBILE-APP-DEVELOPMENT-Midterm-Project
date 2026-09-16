$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$workflow = Get-Content -LiteralPath (Join-Path $projectRoot '.github/workflows/quality.yml')
$stepIndex = [Array]::IndexOf($workflow, '      - name: Backend syntax and tests')
if ($stepIndex -lt 0) { throw 'Backend workflow step is missing.' }
$runIndex = $stepIndex + 1
while ($runIndex -lt $workflow.Count -and $workflow[$runIndex] -ne '        run: |') { $runIndex++ }
if ($runIndex -ge $workflow.Count) { throw 'Backend run block is missing.' }
$body = @()
for ($line = $runIndex + 1; $line -lt $workflow.Count; $line++) {
    if ($workflow[$line] -notmatch '^          ') { break }
    $body += $workflow[$line].Substring(10)
}
$run = [scriptblock]::Create($body -join [Environment]::NewLine)
$originalLocation = (Get-Location).Path
$originalExitCode = $global:LASTEXITCODE
$failures = @()

# Exercise the actual workflow commands without running Node or creating a DB.
function node {
    $script:backendCiInvocation++
    $global:LASTEXITCODE = if ($script:backendCiInvocation -eq $script:backendCiFailAt) { 7 } else { 0 }
}

try {
    foreach ($failAt in @(1, 4, 7, 8, 0)) {
        Set-Location $projectRoot
        $script:backendCiInvocation = 0
        $script:backendCiFailAt = $failAt
        $global:LASTEXITCODE = 0
        $errorMessage = $null
        try {
            & $run
            # GitHub's pwsh wrapper also checks the final native exit code.
            if ($LASTEXITCODE -ne 0) { throw "Workflow ended with code $LASTEXITCODE" }
        } catch { $errorMessage = $_.Exception.Message }
        if ($failAt -eq 0) {
            if ($errorMessage -or $script:backendCiInvocation -ne 8) {
                $failures += 'Valid syntax and tests did not complete all eight commands.'
            }
        } elseif (!$errorMessage -or !$errorMessage.Contains('code 7') -or $script:backendCiInvocation -ne $failAt) {
            $failures += "Failure at command $failAt was not reported immediately with code 7 (ran $script:backendCiInvocation commands)."
        }
        if ((Get-Location).Path -ne $projectRoot) { $failures += "Failure at command $failAt leaked the backend working directory." }
    }
    if ($failures.Count) { throw ($failures -join [Environment]::NewLine) }
    Write-Output 'PASS: the real backend CI block stops on first/middle/last syntax failures and failing tests; preserves code 7 and working directory; valid run completes all eight commands.'
    Write-Output 'Synthetic workflow contract only; not a hosted CI result or application test.'
} finally {
    Set-Location $originalLocation
    $global:LASTEXITCODE = $originalExitCode
}
