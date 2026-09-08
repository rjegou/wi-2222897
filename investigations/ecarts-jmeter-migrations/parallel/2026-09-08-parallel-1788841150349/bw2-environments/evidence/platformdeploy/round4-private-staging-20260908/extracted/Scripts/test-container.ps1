# File: test-container.ps1
# PS5.1-safe entry point for containerized deployment tests.
#
# See docker-pipeline-deploy.ps1 for the rationale: V2 test scripts use Invoke-Sqlcmd
# (SqlServer/SQLPS module) which is not auto-imported in PS7, and returned objects are
# deserialized through the WinPS compat shim, losing their methods. Running in PS5.1
# avoids the shim entirely.
#
# V4+ test scripts require PS7 (using module / #Requires -Version 7.4). This wrapper
# detects the caller's PS version and re-invokes test-container-ps7.ps1 via pwsh.exe
# when needed, or dot-sources it directly if already in PS7+.
#
# The pipeline template must NOT set pwsh:true on the step that calls this script.
#
# To do: remove the PS5 bootstrap block (and this file) once lastV2 is no longer in use.
#       At that point, rename test-container-ps7.ps1 back to test-container.ps1.
#
# 2022-02-02 : file creation
# 2025      : added PS5/PS7 bootstrap for V2 backward compatibility

param (
    [string]$coreVersion  = $(throw "coreVersion is a required parameter"),
    [string]$dockerCy2px  = $(throw "dockerCy2px is a required parameter"),
    [switch]$verbose
)

$ps7Script = Join-Path $PSScriptRoot "test-container-ps7.ps1"

if ($PSVersionTable.PSVersion.Major -lt 7)
{
    # Running under PS5.1: re-invoke the PS7 script with pwsh.exe.
    $pwshExe = Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"
    if (-not (Test-Path $pwshExe))
    {
        throw "PowerShell 7 is required for V4+ tests but was not found at '$pwshExe'."
    }

    $argList = @(
        "-NoLogo", "-NonInteractive", "-ExecutionPolicy", "Unrestricted",
        "-File", "`"$ps7Script`"",
        "-coreVersion",  "`"$coreVersion`"",
        "-dockerCy2px",  "`"$dockerCy2px`""
    )
    if ($verbose) { $argList += "-verbose" }

    & $pwshExe @argList
    exit $LASTEXITCODE
}
else
{
    # Already in PS7+: dot-source the real script in the current session.
    . $ps7Script @PSBoundParameters
}
