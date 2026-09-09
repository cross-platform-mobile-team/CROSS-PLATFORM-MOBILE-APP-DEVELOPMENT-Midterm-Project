param(
  [string]$Flutter = 'flutter.bat',
  [ValidateRange(1024, 65535)]
  [int]$Port = 7359,
  [ValidateRange(1, 50)]
  [int]$Repetitions = 5
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Test-Path (Join-Path $root 'pubspec.yaml'))) {
  throw "Repository root was not resolved safely: $root"
}
$flutterCommand = (Get-Command $Flutter -ErrorAction Stop).Source
$python = (Get-Command py.exe -ErrorAction Stop).Source
$npx = (Get-Command npx.cmd -ErrorAction Stop).Source
$artifacts = Join-Path $root 'output/playwright'
New-Item -ItemType Directory -Force $artifacts | Out-Null
$session = "taskflow-harness-$PID"
$server = $null
$browserOpened = $false

if (Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue) {
  throw "Port $Port is already in use; choose another -Port value."
}

Push-Location $root
try {
  & $flutterCommand build web --release --target lib/browser_test_harness.dart --dart-define=TASKFLOW_BROWSER_HARNESS=true
  if ($LASTEXITCODE -ne 0) { throw 'Browser harness build failed.' }

  $server = Start-Process -FilePath $python -ArgumentList @(
    '-3', '-m', 'http.server', "$Port", '--bind', '127.0.0.1', '--directory', (Join-Path $root 'build/web')
  ) -WorkingDirectory $root -WindowStyle Hidden -PassThru `
    -RedirectStandardOutput (Join-Path $artifacts 'edge-harness-server-out.log') `
    -RedirectStandardError (Join-Path $artifacts 'edge-harness-server-error.log')

  $ready = $false
  $deadline = [DateTime]::UtcNow.AddSeconds(15)
  while (-not $ready -and [DateTime]::UtcNow -lt $deadline) {
    $socket = [Net.Sockets.TcpClient]::new()
    try {
      $ready = $socket.ConnectAsync('127.0.0.1', $Port).Wait(250) -and $socket.Connected
    } catch {
      $ready = $false
    } finally {
      $socket.Dispose()
    }
    if (-not $ready) { Start-Sleep -Milliseconds 100 }
  }
  if (-not $ready) { throw "Static server did not listen on 127.0.0.1:$Port." }

  & $npx --yes --package '@playwright/cli@0.1.19' playwright-cli "-s=$session" open "http://127.0.0.1:$Port/?scenario=discovery" --browser msedge --headed
  if ($LASTEXITCODE -ne 0) { throw 'Could not open the isolated Edge session.' }
  $browserOpened = $true

  & (Join-Path $PSScriptRoot 'browser/repeat-edge-harness.ps1') -Repetitions $Repetitions -Session $session
  if ($LASTEXITCODE -ne 0) { throw 'Repeated Edge harness check failed.' }
} finally {
  if ($browserOpened) {
    & $npx --yes --package '@playwright/cli@0.1.19' playwright-cli "-s=$session" close
  }
  if ($server -and -not $server.HasExited) {
    Stop-Process -Id $server.Id
    $server.WaitForExit()
  }
  Write-Output 'Restoring the default Web release build (API 127.0.0.1:8080).'
  & $flutterCommand build web --release
  $restoreExitCode = $LASTEXITCODE
  Pop-Location
  if ($restoreExitCode -ne 0) {
    throw 'Default Web release restoration failed.'
  }
}
