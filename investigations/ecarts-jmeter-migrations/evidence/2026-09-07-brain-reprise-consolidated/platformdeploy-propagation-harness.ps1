$ErrorActionPreference = 'Stop'

function Invoke-FakeMsi([int]$exitCode) {
    # Inert model of install-y2msi.ps1: only 0 and 3010 are accepted.
    if (@(0, 3010) -contains $exitCode) { return 0 }
    return 1
}

function Invoke-FakeInstallPackages([int[]]$exitCodes) {
    $nbErr = 0
    foreach ($code in $exitCodes) { $nbErr += Invoke-FakeMsi $code }
    [pscustomobject]@{ nbErr = $nbErr; throws = ($nbErr -gt 0) }
}

function Invoke-FakeInitContainer([int]$deployExitCode, [bool]$tfBuild) {
    # Inert model of init-container.ps1: in TF_BUILD it does not inspect the
    # child deploy exit code after the call, so the wrapper reaches normal end.
    if ($tfBuild) { return [pscustomobject]@{ childExitCode = $deployExitCode; wrapperExitCode = 0; propagated = $false } }
    return [pscustomobject]@{ childExitCode = $deployExitCode; wrapperExitCode = $deployExitCode; propagated = ($deployExitCode -ne 0) }
}

[pscustomobject]@{
    msiCase1603 = Invoke-FakeInstallPackages @(0, 1603, 0)
    msiCase3010 = Invoke-FakeInstallPackages @(0, 3010, 0)
    tfBuildWrapperCase = Invoke-FakeInitContainer 1 $true
    nonPipelineWrapperCase = Invoke-FakeInitContainer 1 $false
} | ConvertTo-Json -Depth 4 -Compress
