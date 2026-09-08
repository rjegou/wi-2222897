[CmdletBinding()]
param([string]$OutputPath = (Join-Path $PSScriptRoot 'round5-adapter-test-result.json'))

$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot '..\..\worktrees\fulltext\Invoke-FullTextSqlStage.ps1'
$cases = [ordered]@{}

function New-Adapter([System.Collections.Generic.List[string]]$Events, [hashtable]$Options) {
    $o = $Options
    $a = @{
        ReadAttestation = { $Events.Add('attestation'); [pscustomobject]@{ Exclusive=$true; ImageDigest=('sha256:' + ('a' * 64)); Mounts=@(); Networks=@(); Ports=@(); Endpoints=@() } }.GetNewClosure()
        BuildSqlImage = { $Events.Add('build-image') }.GetNewClosure()
        GetSqlImageIdentity = { $Events.Add('image-identity'); [pscustomobject]@{ Id=('sha256:' + ('a' * 64)); RepoDigest=('example/sql@sha256:' + ('b' * 64)) } }.GetNewClosure()
        CreateNeutralContainer = { $Events.Add('create-neutral-container') }.GetNewClosure()
        InspectContainerIsolation = { $Events.Add('inspect-container'); [pscustomobject]@{ Mounts=0; PublishedPorts=0; NetworkMode='none' } }.GetNewClosure()
        StartSqlServices = { $Events.Add('start-sql'); if ($o.StartSqlError) { throw 'start-sql-failed' } }.GetNewClosure()
        CollectDiagnostics = { param($Phase) $Events.Add("diagnostic-$Phase"); if ($o.DiagnosticError) { throw 'diagnostic-failed' } }.GetNewClosure()
        RunContainstableProbe = { param($Timeout) $Events.Add("probe-$Timeout"); if ($o.ProbeError) { throw $o.ProbeError } }.GetNewClosure()
        CleanupContainer = { $Events.Add('cleanup'); if ($o.CleanupError) { throw 'cleanup-failed' } }.GetNewClosure()
        VerifyCleanup = { $Events.Add('verify-cleanup'); if ($o.VerifyError) { throw 'verify-failed' }; $null }.GetNewClosure()
    }
    return $a
}

function Run-Case([string]$Name, [hashtable]$Options, [bool]$ExpectFailure, [string]$ExpectedError, [string[]]$ExpectedPrefix) {
    $events = [System.Collections.Generic.List[string]]::new(); $errorText = $null
    try { & $runner -Adapter (New-Adapter $events $Options) -PopulationTimeoutSeconds 90 } catch { $errorText = $_.Exception.Message }
    $errorOk = ($ExpectFailure -and $errorText -like "*$ExpectedError*") -or ((-not $ExpectFailure) -and $null -eq $errorText)
    $orderOk = (($events | Select-Object -First $ExpectedPrefix.Count) -join '|') -eq ($ExpectedPrefix -join '|')
    $cases[$Name] = [pscustomobject]@{ passed=($errorOk -and $orderOk); error=$errorText; events=@($events); orderOk=$orderOk }
}

Run-Case 'success' @{} $false '' @('attestation','build-image','image-identity','create-neutral-container','inspect-container','start-sql','diagnostic-before-probe','probe-90')
Run-Case 'attestation-refused' @{} $true 'ATTESTATION_BLOCKED' @('attestation')
Run-Case 'probe-timeout-primary-preserved' @{ ProbeError='Full-Text population did not finish: [1]'; DiagnosticError=$true; CleanupError=$true } $true 'Full-Text population did not finish' @('attestation','build-image','image-identity','create-neutral-container','inspect-container','start-sql','diagnostic-before-probe','probe-90')
Run-Case 'start-sql-refused' @{ StartSqlError=$true; CleanupError=$true } $true 'start-sql-failed' @('attestation','build-image','image-identity','create-neutral-container','inspect-container','start-sql','diagnostic-finally','cleanup')

$allPass = @($cases.Values | Where-Object { -not $_.passed }).Count -eq 0
[pscustomobject]@{ allPass=$allPass; populationTimeoutSeconds=90; cases=$cases } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Get-Content -LiteralPath $OutputPath -Raw
if (-not $allPass) { exit 1 }
