# Windows OpenJDK workaround for AF_UNIX connect failures in PipeImpl.
# Usage: & ./scripts/with-java-tcp-fallback.ps1 { flutter build apk --release }
# This file must be invoked, not dot-sourced. No global environment is changed.
param([Parameter(Mandatory)][scriptblock]$Command)
$ErrorActionPreference = 'Stop'
$taskflowRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskflowBuild = Join-Path $taskflowRoot 'build'
New-Item -ItemType Directory -Path $taskflowBuild -Force | Out-Null
$taskflowSentinel = Join-Path $taskflowBuild 'java-tcp-fallback.marker'
# A file cannot contain a socket. The JDK catches the bind failure and uses TCP.
# A missing directory could later be created, so use an explicit file sentinel.
if (!(Test-Path -LiteralPath $taskflowSentinel)) {
    Set-Content -LiteralPath $taskflowSentinel -Value 'TaskFlow Java TCP fallback sentinel.'
}
if (!(Test-Path -LiteralPath $taskflowSentinel -PathType Leaf)) {
    throw "Expected a file sentinel: $taskflowSentinel"
}
$taskflowPreviousOptions = $env:JAVA_TOOL_OPTIONS
try {
    # Keep a missing SDK component explicit rather than installing it during build.
    $env:JAVA_TOOL_OPTIONS = (($taskflowPreviousOptions + ' -Dorg.gradle.project.android.builder.sdkDownload=false -Djdk.net.unixdomain.tmpdir="' + $taskflowSentinel + '"').Trim())
    & $Command
    $taskflowResult = $LASTEXITCODE
} finally {
    $env:JAVA_TOOL_OPTIONS = $taskflowPreviousOptions
}
if ($null -ne $taskflowResult) { exit $taskflowResult }
