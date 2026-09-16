function Resolve-TaskFlowFlutterCommand {
    param([string]$FlutterSdk)

    # An explicit SDK is authoritative: a typo must not silently select another SDK.
    if ($PSBoundParameters.ContainsKey('FlutterSdk')) {
        if ([string]::IsNullOrWhiteSpace($FlutterSdk)) {
            throw 'Explicit -FlutterSdk must name a Flutter SDK directory.'
        }
        $command = Join-Path $FlutterSdk 'bin\flutter.bat'
        if (!(Test-Path -LiteralPath $command -PathType Leaf)) {
            throw "Flutter SDK not found at '$FlutterSdk'; expected bin\flutter.bat."
        }
        return (Resolve-Path -LiteralPath $command).Path
    }

    $pathCommand = Get-Command flutter.bat -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($pathCommand) { return $pathCommand.Source }

    # Preserve the original default for hosts where Flutter is not on PATH.
    if (![string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $legacyCommand = Join-Path $env:USERPROFILE 'flutter-sdk\bin\flutter.bat'
        if (Test-Path -LiteralPath $legacyCommand -PathType Leaf) {
            return (Resolve-Path -LiteralPath $legacyCommand).Path
        }
    }
    throw 'Flutter SDK not found. Add its bin directory to PATH or pass -FlutterSdk with your SDK directory.'
}
