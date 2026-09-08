# File: docker-pipeline-deploy.ps1
# PS5.1-safe entry point for containerized deployment.
#
# V2 packages (deprecated) rely on live WebAdministration objects whose methods are lost
# when the module is loaded via the PS7 WinPS compatibility shim. Running the deployment
# script in PS5.1 avoids the shim entirely.
#
# V4+ packages require PS7 because their scripts use 'using module' and #Requires -Version 7.4.
# This wrapper detects the caller's PS version: if PS5.1, it re-invokes the real PS7 script
# (docker-pipeline-deploy-ps7.ps1) via pwsh.exe; if already PS7+, it dot-sources it directly.
#
# The pipeline template must NOT set pwsh:true on the step that calls this script.
#
# To do: remove the PS5 bootstrap block (and this file) once lastV2 is no longer in use.
#       At that point, rename docker-pipeline-deploy-ps7.ps1 back to docker-pipeline-deploy.ps1.
#
# 2022-02-02 : file creation
# 2025      : added PS5/PS7 bootstrap for V2 backward compatibility

param (
    [string]$deployConfig = "",
    [string]$RetailJfrogApiKey = $(throw "RetailJfrogApiKey is mandatory."),
    [string]$LocalDBInContainer = "None",
    [switch]$verbose
)

$ps7Script = Join-Path $PSScriptRoot "docker-pipeline-deploy-ps7.ps1"

if ($PSVersionTable.PSVersion.Major -lt 7)
{
    # Running under PS5.1 (called from a pipeline task without pwsh:true).
    # Re-invoke the PS7 script with pwsh.exe so that V4 modules load correctly.
    $pwshExe = Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"
    if (-not (Test-Path $pwshExe))
    {
        throw "PowerShell 7 is required for V4+ deployments but was not found at '$pwshExe'."
    }

    $argList = @(
        "-NoLogo", "-NonInteractive", "-ExecutionPolicy", "Unrestricted",
        "-File", "`"$ps7Script`"",
        "-RetailJfrogApiKey", "`"$RetailJfrogApiKey`""
    )
    if ($deployConfig)      { $argList += "-deployConfig",      "`"$deployConfig`"" }
    if ($LocalDBInContainer){ $argList += "-LocalDBInContainer", "`"$LocalDBInContainer`"" }
    if ($verbose)           { $argList += "-verbose" }

    & $pwshExe @argList
    exit $LASTEXITCODE
}
else
{
    # Already running under PS7+: dot-source the real script in the current session.
    . $ps7Script @PSBoundParameters
}
