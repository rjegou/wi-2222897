& "$PSScriptRoot/child-exit.ps1"
$deploymentExitCode = $LASTEXITCODE
if ($deploymentExitCode -ne 0) {
    throw "Deployment failed with exit code $deploymentExitCode"
}
