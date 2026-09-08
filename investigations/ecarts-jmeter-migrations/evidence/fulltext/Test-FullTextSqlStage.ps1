[CmdletBinding()]
param([string]$OutputPath = (Join-Path $PSScriptRoot 'round5-adapter-test-result.json'))

$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot '..\..\worktrees\fulltext\Invoke-FullTextSqlStage.ps1'
$cases = [ordered]@{}

function New-Adapter([System.Collections.Generic.List[string]]$Events, [hashtable]$Options) {
    return @{
        ReadAttestation = { $Events.Add('attestation'); [pscustomobject]@{ Exclusive = $true; ImageDigest = 'sha256:' + ('a' * 64); Mounts=@(); Networks=@(); Ports=@(); Endpoints=@() } }
        BuildSqlImage = { $Events.Add('build-image') }
        GetSqlImageIdentity = { $Events.Add('image-identity'); [pscustomobject]@{ Id='sha256:' + ('a' * 64); RepoDigest='example/sql@sha256:' + ('b' * 64) } }
        CreateNeutralContainer = { $Events.Add('create-neutral-container') }
        InspectContainerIsolation = { $Events.Add('inspect-container'); [pscustomobject]@{ Mounts=0; PublishedPorts=0; NetworkMode='none' } }
        StartSqlServices = { $Events.Add('start-sql'); if ($Options.StartSqlError) { throw 'start-sql-failed' } }
        CollectDiagnostics = { param($Phase) $Events.Add("diagnostic-$Phase"); if ($Options.DiagnosticError) { throw 'diagnostic-failed' } }
        RunContainstableProbe = { param($Timeout) $Events.Add("probe-$Timeout"); if ($Options.ProbeError) { throw $Options.ProbeError } }
        CleanupContainer = { $Events.Add('cleanup'); if ($Options.CleanupError) { throw 'cleanup-failed' } }
        VerifyCleanup = { $Events.Add('verify-cleanup'); if ($Options.VerifyError) { throw 'verify-failed' }; return $null }
    }
}

function Run-Case([string]$Name, [hashtable]$Options, [bool]$ExpectFailure, [string]$ExpectedError, [string[]]$ExpectedPrefix) {
    $events = [System.Collections.Generic.List[string]]::new(); $adapter = New-Adapter $events $Options; $errorText = $null
    try { & $runner -Adapter $adapter -PopulationTimeoutSeconds 90 } catch { $errorText = $_.Exception.Message }
    $failedAsExpected = ($ExpectFailure -and $errorText -like "*$ExpectedError*") -or ((-not $ExpectFailure) -and $null -eq $errorText)
    $prefix = ($events | Select-Object -First $ExpectedPrefix.Count) -join '|'
    $orderOk = $prefix -eq ($ExpectedPrefix -join '|')
    $cases[$Name] = [pscustomobject]@{ passed = ($failedAsExpected -and $orderOk); error = $errorText; events = @($events); expectedPrefix = $ExpectedPrefix; orderOk = $orderOk }
}

Run-Case 'success' @{} $false '' @('attestation','build-image','image-identity','create-neutral-container','inspect-container','start-sql','diagnostic-before-probe','probe-90')
Run-Case 'attestation-refused' @{ StartSqlError = $false } $true 'ATTESTATION_BLOCKED' @('attestation')
Run-Case 'probe-timeout-primary-preserved' @{ ProbeError = 'Full-Text population did not finish: [1]'; DiagnosticError = $true; CleanupError = $true } $true 'Full-Text population did not finish' @('attestation','build-image','image-identity','create-neutral-container','inspect-container','start-sql','diagnostic-before-probe','probe-90')
Run-Case 'start-sql-refused' @{ StartSqlError = $true; CleanupError = $true } $true 'start-sql-failed' @('attestation','build-image','image-identity','create-neutral-container','inspect-container','start-sql','diagnostic-finally','cleanup')

$allPass = @($cases.Values | Where-Object { -not $_.passed }).Count -eq 0
$report = [pscustomobject]@{ allPass = $allPass; populationTimeoutSeconds = 90; cases = $cases }
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Get-Content -LiteralPath $OutputPath -Raw
if (-not $allPass) { exit 1 }
