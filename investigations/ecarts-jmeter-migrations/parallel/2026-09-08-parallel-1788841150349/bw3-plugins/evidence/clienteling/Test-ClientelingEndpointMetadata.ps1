param(
    [Parameter(Mandatory)] [string] $SourceRepo,
    [Parameter(Mandatory)] [string] $CandidateRoot
)

$ErrorActionPreference = 'Stop'
$cases = @(
    @{ Relative = 'IntegratedTests/AutoTest/Data/WebServices/TestPlans/Deployment_ResetFTSCustomer.xml'; Old = 'DeploymentService.svc'; New = 'ClientelingDeploymentService.svc' },
    @{ Relative = 'IntegratedTests/AutoTest/Data/WebServices/TestPlans/Deployment_UpdateFTSCatalog.xml'; Old = 'DeploymentService.svc'; New = 'ClientelingDeploymentService.svc' },
    @{ Relative = 'IntegratedTests/AutoTest/Data/WebServices/TestPlans/Deployment_UpdateFTSCustomer.xml'; Old = 'DeploymentService.svc'; New = 'ClientelingDeploymentService.svc' },
    @{ Relative = 'IntegratedTests/AutoTest/Data/WebServices/TestPlans/Mobility_GetClientelingParameters.xml'; Old = 'MobilityService.svc'; New = 'ClientelingMobilityService.svc' },
    @{ Relative = 'IntegratedTests/AutoTest/Data/WebServices/TestPlans/Mobility_UpdateClientelingParameters.xml'; Old = 'MobilityService.svc'; New = 'ClientelingMobilityService.svc' }
)

function Read-HeadContent([string] $relative) {
    $text = & git -c safe.directory='*' -C $SourceRepo show ("HEAD:" + ($relative -replace '\\','/'))
    if ($LASTEXITCODE -ne 0) { throw "git show failed for $relative" }
    return ($text -join [Environment]::NewLine)
}

$results = foreach ($case in $cases) {
    $path = Join-Path $CandidateRoot ($case.Relative -replace '/', '\')
    if (!(Test-Path -LiteralPath $path)) { throw "missing candidate $path" }
    $beforeText = Read-HeadContent $case.Relative
    $afterText = Get-Content -Raw -LiteralPath $path
    [xml]$before = $beforeText
    [xml]$after = $afterText
    $beforeValue = [string]$before.TestPlan.WebService
    $afterValue = [string]$after.TestPlan.WebService
    if ($beforeValue -ne $case.Old) { throw "$($case.Relative): baseline endpoint is '$beforeValue', expected '$($case.Old)'" }
    if ($afterValue -ne $case.New) { throw "$($case.Relative): candidate endpoint is '$afterValue', expected '$($case.New)'" }
    [pscustomobject]@{ Relative = $case.Relative; Before = $beforeValue; After = $afterValue; XmlParse = 'valid' }
}

$results | ConvertTo-Json -Compress
Write-Output 'PASS: five endpoint metadata transitions are discriminated and XML remains parseable.'
