$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
. (Join-Path $root 'scripts/resolve-flutter.ps1')
$folder = Join-Path $root "build/flutter-resolver-contract-$([guid]::NewGuid().ToString('N'))"
$explicitSdk = Join-Path $folder 'explicit SDK'
$pathSdk = Join-Path $folder 'path SDK'
$profile = Join-Path $folder 'profile'
$legacySdk = Join-Path $profile 'flutter-sdk'
$emptyPath = Join-Path $folder 'empty-bin'
$invalidSdk = Join-Path $folder 'invalid-sdk'
$fixture = Join-Path $PSScriptRoot 'fixtures/flutter-cli.bat'
foreach ($sdk in @($explicitSdk, $pathSdk, $legacySdk)) {
    New-Item -ItemType Directory -Path (Join-Path $sdk 'bin') -Force | Out-Null
    Copy-Item -LiteralPath $fixture -Destination (Join-Path $sdk 'bin/flutter.bat')
}
New-Item -ItemType Directory -Path $emptyPath, (Join-Path $invalidSdk 'bin/flutter.bat') -Force | Out-Null
$previousPath = $env:PATH
$previousProfile = $env:USERPROFILE
$previousFixtureExit = $env:TASKFLOW_FLUTTER_FIXTURE_EXIT_CODE
$previousExitCode = $global:LASTEXITCODE
$initialLocation = (Get-Location).Path

function Assert-Throws {
    param([scriptblock]$Action, [string]$Message)
    $actual = $null
    try { & $Action | Out-Null } catch { $actual = $_.Exception.Message }
    if (!$actual -or !$actual.Contains($Message)) {
        throw "Expected failure containing '$Message'; received '$actual'."
    }
}

try {
    $env:PATH = Join-Path $pathSdk 'bin'
    $env:USERPROFILE = $profile
    $env:TASKFLOW_FLUTTER_FIXTURE_EXIT_CODE = '0'
    $actual = Resolve-TaskFlowFlutterCommand -FlutterSdk $explicitSdk
    if ($actual -ne (Join-Path $explicitSdk 'bin/flutter.bat')) {
        throw 'Explicit SDK did not take precedence over PATH.'
    }
    $actual = Resolve-TaskFlowFlutterCommand
    if ($actual -ne (Join-Path $pathSdk 'bin/flutter.bat')) {
        throw 'PATH SDK did not take precedence over the legacy default.'
    }
    Assert-Throws { Resolve-TaskFlowFlutterCommand -FlutterSdk (Join-Path $folder 'missing') } 'expected bin\flutter.bat'
    Assert-Throws { Resolve-TaskFlowFlutterCommand -FlutterSdk $invalidSdk } 'expected bin\flutter.bat'
    Assert-Throws { Resolve-TaskFlowFlutterCommand -FlutterSdk '' } 'Explicit -FlutterSdk'
    Assert-Throws { Resolve-TaskFlowFlutterCommand -FlutterSdk '   ' } 'Explicit -FlutterSdk'

    # A runner must forward an explicitly invalid value before creating artifacts
    # or starting the online backend. These calls cannot invoke real Flutter.
    foreach ($runner in @('run-windows.ps1', 'test-online-windows.ps1', 'repeat-test-levels.ps1')) {
        Assert-Throws { & (Join-Path $root "scripts/$runner") -FlutterSdk $invalidSdk } 'expected bin\flutter.bat'
        Assert-Throws { & (Join-Path $root "scripts/$runner") -FlutterSdk '' } 'Explicit -FlutterSdk'
    }

    # Exercise actual invocation with spaces in the selected path and retain the
    # launcher's argument/exit-code/location behavior without building an app.
    Set-Location $folder
    $output = @(& (Join-Path $root 'scripts/run-windows.ps1'))
    if ($output -notcontains 'SYNTHETIC_FLUTTER: run -d windows') {
        throw 'Windows launcher did not invoke the PATH fixture with the expected arguments.'
    }
    if ((Get-Location).Path -ne $folder) { throw 'Windows launcher changed the caller location.' }
    $env:TASKFLOW_FLUTTER_FIXTURE_EXIT_CODE = '7'
    Assert-Throws { & (Join-Path $root 'scripts/run-windows.ps1') -FlutterSdk $explicitSdk } 'Flutter exited with code 7'
    if ((Get-Location).Path -ne $folder) { throw 'Windows launcher did not restore location after failure.' }

    $env:PATH = $emptyPath
    $actual = Resolve-TaskFlowFlutterCommand
    if ($actual -ne (Join-Path $legacySdk 'bin/flutter.bat')) {
        throw 'Legacy SDK fallback was not preserved.'
    }
    $env:USERPROFILE = Join-Path $folder 'no-profile-sdk'
    Assert-Throws { Resolve-TaskFlowFlutterCommand } 'Add its bin directory to PATH or pass -FlutterSdk'
    Write-Output 'PASS: explicit/PATH/fallback precedence, invalid SDK rejection, runner forwarding, invocation arguments, exit codes and location restoration.'
    Write-Output 'Synthetic SDK resolver contract only; no real Flutter command or app build was run.'
} finally {
    Set-Location $initialLocation
    $env:PATH = $previousPath
    $env:USERPROFILE = $previousProfile
    $env:TASKFLOW_FLUTTER_FIXTURE_EXIT_CODE = $previousFixtureExit
    $global:LASTEXITCODE = $previousExitCode
    Write-Output "Contract fixtures: $folder"
}
