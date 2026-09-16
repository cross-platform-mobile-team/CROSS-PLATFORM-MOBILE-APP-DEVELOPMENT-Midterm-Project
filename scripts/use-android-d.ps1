# Dot-source this file before Android build/run commands on this Windows host.
param(
    [ValidateNotNullOrEmpty()][string]$AndroidRoot = 'D:/Android',
    [ValidateNotNullOrEmpty()][string]$JavaHomePath = 'C:/Program Files/Java/jdk-21'
)
# Resolve and validate everything before changing the caller's environment.
# A failed dot-source must not leave an existing working toolchain half replaced.
$taskflowAndroidRoot = (Resolve-Path -LiteralPath $AndroidRoot -ErrorAction Stop).ProviderPath
$taskflowJavaRoot = (Resolve-Path -LiteralPath $JavaHomePath -ErrorAction Stop).ProviderPath
$taskflowSdk = Join-Path $taskflowAndroidRoot 'sdk' -ErrorAction Stop
$taskflowJava = Join-Path $taskflowJavaRoot 'bin/java.exe' -ErrorAction Stop
if (!(Test-Path -LiteralPath $taskflowSdk -PathType Container)) {
    throw "Android SDK directory not found: $taskflowSdk. Pass -AndroidRoot for this host."
}
if (!(Test-Path -LiteralPath $taskflowJava -PathType Leaf)) {
    throw "JDK executable not found: $taskflowJava. Pass -JavaHomePath for this host."
}
$taskflowAndroidEnvironment = @{
    ANDROID_HOME = $taskflowSdk
    ANDROID_SDK_ROOT = $taskflowSdk
    ANDROID_USER_HOME = Join-Path $taskflowAndroidRoot 'user'
    ANDROID_AVD_HOME = Join-Path $taskflowAndroidRoot 'avd'
    GRADLE_USER_HOME = Join-Path $taskflowAndroidRoot 'gradle'
    PUB_CACHE = Join-Path $taskflowAndroidRoot 'pub-cache'
    JAVA_HOME = $taskflowJavaRoot
}
# These affect this PowerShell session and its children, not global PATH.
foreach ($taskflowVariable in $taskflowAndroidEnvironment.Keys) {
    [Environment]::SetEnvironmentVariable($taskflowVariable, $taskflowAndroidEnvironment[$taskflowVariable], 'Process')
}
