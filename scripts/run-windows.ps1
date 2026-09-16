param([string]$FlutterSdk)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'resolve-flutter.ps1')
$resolverArguments = @{}
if ($PSBoundParameters.ContainsKey('FlutterSdk')) { $resolverArguments.FlutterSdk = $FlutterSdk }
$flutterCommand = Resolve-TaskFlowFlutterCommand @resolverArguments
Push-Location (Join-Path $PSScriptRoot '..')
try {
    & $flutterCommand run -d windows
    if ($LASTEXITCODE -ne 0) { throw "Flutter exited with code $LASTEXITCODE" }
} finally {
    Pop-Location
}
