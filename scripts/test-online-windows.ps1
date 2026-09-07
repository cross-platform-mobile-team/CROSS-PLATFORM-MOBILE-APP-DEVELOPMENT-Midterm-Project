param(
    [string]$FlutterSdk = "$env:USERPROFILE\flutter-sdk",
    [string]$NodeExecutable = 'node',
    [int]$Port = 8081
)
$ErrorActionPreference = 'Stop'
if ($Port -lt 1 -or $Port -gt 65535) { throw 'Port must be 1-65535.' }
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$flutterCommand = Join-Path $FlutterSdk 'bin\flutter.bat'
if (!(Test-Path -LiteralPath $flutterCommand)) { throw 'Flutter SDK not found.' }
$nodeCommand = (Get-Command $NodeExecutable -ErrorAction Stop).Source
$probe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
try { $probe.Start() } finally { $probe.Stop() }
$testFolder = Join-Path $projectPath "build\online-e2e-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $testFolder | Out-Null
$previousPort = $env:PORT
$previousHost = $env:HOST
$previousDb = $env:DATABASE_PATH
$serverProcess = $null
Push-Location $projectPath
try {
    $env:PORT = "$Port"
    $env:HOST = '127.0.0.1'
    $env:DATABASE_PATH = Join-Path $testFolder 'test.sqlite'
    $serverProcess = Start-Process -FilePath $nodeCommand -ArgumentList 'src/server.js' -WorkingDirectory (Join-Path $projectPath 'backend') -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $testFolder 'server.log') -RedirectStandardError (Join-Path $testFolder 'server-error.log')
    $ready = $false
    $deadline = [DateTime]::UtcNow.AddSeconds(20)
    while ([DateTime]::UtcNow -lt $deadline) {
        if ($serverProcess.HasExited) { throw 'Test backend exited. Inspect the server-error.log in the test folder.' }
        try {
            $health = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/health" -TimeoutSec 1
            if ($health.status -eq 'ok') { $ready = $true; break }
        } catch { }
        Start-Sleep -Milliseconds 100
    }
    if (!$ready) { throw 'Test backend did not become healthy within 20 seconds.' }
    & $flutterCommand test integration_test/online_workflow_test.dart -d windows "--dart-define=API_BASE_URL=http://127.0.0.1:$Port" --reporter expanded
    if ($LASTEXITCODE -ne 0) { throw "Online integration test failed with code $LASTEXITCODE" }
} finally {
    # Stop only the exact child started by this script, never another user's server.
    if ($null -ne $serverProcess -and !$serverProcess.HasExited) { Stop-Process -Id $serverProcess.Id }
    $env:PORT = $previousPort
    $env:HOST = $previousHost
    $env:DATABASE_PATH = $previousDb
    Pop-Location
    Write-Output "Isolated test database and logs: $testFolder"
}
