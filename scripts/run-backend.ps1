param(
    [string]$NodeExecutable = 'node',
    [int]$Port = 8080
)
$ErrorActionPreference = 'Stop'
if ($Port -lt 1 -or $Port -gt 65535) { throw 'Port must be 1-65535.' }
$taskflowPreviousPort = $env:PORT
Push-Location (Join-Path $PSScriptRoot '..\backend')
try {
    $env:PORT = "$Port"
    & $NodeExecutable --env-file-if-exists=.env src/server.js
    if ($LASTEXITCODE -ne 0) { throw "Backend exited with code $LASTEXITCODE" }
} finally {
    $env:PORT = $taskflowPreviousPort
    Pop-Location
}
