param([string]$FlutterSdk = "$env:USERPROFILE\flutter-sdk")
$ErrorActionPreference = 'Stop'
$flutterCommand = Join-Path $FlutterSdk 'bin\flutter.bat'
if (!(Test-Path -LiteralPath $flutterCommand)) {
    throw 'Flutter SDK not found. Pass -FlutterSdk with your SDK directory.'
}
Push-Location (Join-Path $PSScriptRoot '..')
try {
    & $flutterCommand run -d windows
    if ($LASTEXITCODE -ne 0) { throw "Flutter exited with code $LASTEXITCODE" }
} finally {
    Pop-Location
}
