$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$configure = Join-Path $projectRoot 'scripts/use-android-d.ps1'
$fixtureRoot = Join-Path $projectRoot "build/android-environment-contract-$([guid]::NewGuid().ToString('N'))"
$validRoot = Join-Path $fixtureRoot 'Android tools'
$validJava = Join-Path $fixtureRoot 'Java tools'
New-Item -ItemType Directory -Path (Join-Path $validRoot 'sdk'), (Join-Path $validJava 'bin') -Force | Out-Null
# Only path existence is required; this fixture must never execute Java.
New-Item -ItemType File -Path (Join-Path $validJava 'bin/java.exe') | Out-Null
$variableNames = @('ANDROID_HOME', 'ANDROID_SDK_ROOT', 'ANDROID_USER_HOME', 'ANDROID_AVD_HOME', 'GRADLE_USER_HOME', 'PUB_CACHE', 'JAVA_HOME')
$savedEnvironment = @{}
foreach ($name in $variableNames) {
    $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}

function Assert-RejectedWithoutChanges {
    param([string]$Root, [string]$JavaPath)
    foreach ($name in $variableNames) {
        [Environment]::SetEnvironmentVariable($name, "original-$name", 'Process')
    }
    $caught = $false
    try { . $configure -AndroidRoot $Root -JavaHomePath $JavaPath } catch { $caught = $true }
    if (-not $caught) { throw 'Invalid toolchain paths were accepted.' }
    foreach ($name in $variableNames) {
        if ([Environment]::GetEnvironmentVariable($name, 'Process') -ne "original-$name") {
            throw "Rejected configuration changed $name in the caller's environment."
        }
    }
}

try {
    Assert-RejectedWithoutChanges -Root $validRoot -JavaPath (Join-Path $fixtureRoot 'missing-jdk')
    Assert-RejectedWithoutChanges -Root (Join-Path $fixtureRoot 'missing-sdk') -JavaPath $validJava
    Assert-RejectedWithoutChanges -Root '' -JavaPath $validJava
    $fakeSdk = Join-Path $fixtureRoot 'sdk-is-file'
    New-Item -ItemType Directory -Path $fakeSdk | Out-Null
    New-Item -ItemType File -Path (Join-Path $fakeSdk 'sdk') | Out-Null
    Assert-RejectedWithoutChanges -Root $fakeSdk -JavaPath $validJava
    . $configure -AndroidRoot $validRoot -JavaHomePath $validJava
    $expected = @{
        ANDROID_HOME = Join-Path $validRoot 'sdk'
        ANDROID_SDK_ROOT = Join-Path $validRoot 'sdk'
        ANDROID_USER_HOME = Join-Path $validRoot 'user'
        ANDROID_AVD_HOME = Join-Path $validRoot 'avd'
        GRADLE_USER_HOME = Join-Path $validRoot 'gradle'
        PUB_CACHE = Join-Path $validRoot 'pub-cache'
        JAVA_HOME = $validJava
    }
    foreach ($name in $variableNames) {
        if ([Environment]::GetEnvironmentVariable($name, 'Process') -ne $expected[$name]) {
            throw "Valid explicit configuration did not set $name correctly."
        }
    }
    if (Test-Path -LiteralPath (Join-Path $validRoot 'avd')) {
        throw 'Configuration unexpectedly created an emulator directory.'
    }
    Write-Output 'PASS: invalid JDK, missing/empty SDK roots and SDK files preserve the caller environment; valid paths with spaces configure all seven variables without creating emulator data.'
    Write-Output 'Synthetic path contract only; no SDK, Java or emulator was executed.'
} finally {
    foreach ($name in $variableNames) {
        [Environment]::SetEnvironmentVariable($name, $savedEnvironment[$name], 'Process')
    }
}
