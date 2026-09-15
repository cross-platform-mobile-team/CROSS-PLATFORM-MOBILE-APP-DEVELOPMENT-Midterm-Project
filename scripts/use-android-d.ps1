# Dot-source this file before Android build/run commands on this Windows host.
param(
    [string]$AndroidRoot = 'D:/Android',
    [string]$JavaHomePath = 'C:/Program Files/Java/jdk-21'
)
$env:ANDROID_HOME = Join-Path $AndroidRoot 'sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:ANDROID_USER_HOME = Join-Path $AndroidRoot 'user'
$env:ANDROID_AVD_HOME = Join-Path $AndroidRoot 'avd'
$env:GRADLE_USER_HOME = Join-Path $AndroidRoot 'gradle'
$env:PUB_CACHE = Join-Path $AndroidRoot 'pub-cache'
$env:JAVA_HOME = $JavaHomePath
# These affect this PowerShell session and its children, not global PATH.
if (!(Test-Path (Join-Path $env:JAVA_HOME 'bin/java.exe'))) { throw 'JDK not found.' }
if (!(Test-Path $env:ANDROID_HOME)) { throw 'Android SDK directory not found.' }
