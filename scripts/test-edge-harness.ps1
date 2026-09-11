param(
  [string]$Flutter = 'flutter.bat',
  [ValidateRange(1024, 65535)]
  [int]$Port = 7359,
  [ValidateRange(1, 50)]
  [int]$Repetitions = 5,
  [ValidateRange(1, 20)]
  [int]$Sessions = 1,
  [switch]$NoPub
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Test-Path (Join-Path $root 'pubspec.yaml'))) {
  throw "Repository root was not resolved safely: $root"
}
$flutterCommand = (Get-Command $Flutter -ErrorAction Stop).Source
$python = (Get-Command py.exe -ErrorAction Stop).Source
$npx = (Get-Command npx.cmd -ErrorAction Stop).Source
$runId = [guid]::NewGuid().ToString('N')
$artifacts = Join-Path $root "output/playwright/edge-sessions-$runId"
New-Item -ItemType Directory -Force $artifacts | Out-Null
$session = $null
$server = $null
$browserOpened = $false
$sessionRows = @()
$failures = @()
$dependencyArgs = @()
if ($NoPub) { $dependencyArgs += '--no-pub' }

if (Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue) {
  throw "Port $Port is already in use; choose another -Port value."
}

Push-Location $root
try {
  git rev-parse HEAD | Out-File (Join-Path $artifacts 'source.txt')
  git status --short | Out-File (Join-Path $artifacts 'source.txt') -Append
  & $flutterCommand --version 2>&1 | Tee-Object -FilePath (Join-Path $artifacts 'environment.txt')
  if ($LASTEXITCODE -ne 0) { throw 'Cannot read Flutter version.' }
  # Serve the bundled renderer locally so CDN availability cannot gate QA startup.
  & $flutterCommand build web --release --no-web-resources-cdn --target lib/browser_test_harness.dart --dart-define=TASKFLOW_BROWSER_HARNESS=true @dependencyArgs
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

  for ($index = 1; $index -le $Sessions; $index++) {
    # Unique named sessions, with no --persistent or --profile, use fresh profiles.
    $session = "tf-$($runId.Substring(0, 12))-$index"
    $started = [DateTime]::UtcNow.ToString('O')
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $problem = $null
    try {
      $browserOpened = $true # Also attempt cleanup if open partially fails.
      & $npx --yes --package '@playwright/cli@0.1.19' playwright-cli "-s=$session" open "http://127.0.0.1:$Port/?scenario=discovery" --browser msedge --headed 2>&1 |
        Tee-Object -FilePath (Join-Path $artifacts "session-$index-open.txt")
      if ($LASTEXITCODE -ne 0) { throw 'Could not open the isolated Edge session.' }
      & (Join-Path $PSScriptRoot 'browser/repeat-edge-harness.ps1') -Repetitions $Repetitions -Session $session -OutputDirectory (Join-Path $artifacts "session-$index")
    } catch {
      $problem = $_.Exception.Message
    } finally {
      & $npx --yes --package '@playwright/cli@0.1.19' playwright-cli "-s=$session" close 2>&1 |
        Tee-Object -FilePath (Join-Path $artifacts "session-$index-close.txt")
      if ($LASTEXITCODE -ne 0) {
        $problem = "$problem Browser cleanup failed."
      } else { $browserOpened = $false }
      $timer.Stop()
    }
    $sessionRows += [pscustomobject]@{
      Session = $session; StartedUtc = $started; Repetitions = $Repetitions
      SecondsIncludingLifecycle = [Math]::Round($timer.Elapsed.TotalSeconds, 3)
      Result = if ($problem) { 'FAIL' } else { 'PASS' }
      Error = $problem; Directory = "session-$index"
    }
    ConvertTo-Json -InputObject @($sessionRows) -Depth 3 | Out-File (Join-Path $artifacts 'sessions.json') -Encoding utf8
    if ($problem) { $failures += "Session $index : $problem" }
    if ($browserOpened) { break } # Do not accumulate browsers if cleanup failed.
  }
  if ($failures.Count) { throw ($failures -join [Environment]::NewLine) }
} finally {
  if ($browserOpened) {
    & $npx --yes --package '@playwright/cli@0.1.19' playwright-cli "-s=$session" close
  }
  if ($server -and -not $server.HasExited) {
    Stop-Process -Id $server.Id
    $server.WaitForExit()
  }
  Write-Output 'Restoring the default Web release build (API 127.0.0.1:8080).'
  & $flutterCommand build web --release --no-web-resources-cdn @dependencyArgs
  $restoreExitCode = $LASTEXITCODE
  Pop-Location
  Write-Output "Session evidence: $artifacts"
  if ($restoreExitCode -ne 0) {
    throw 'Default Web release restoration failed.'
  }
}
