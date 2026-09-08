[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)][ValidateSet('Cur','Fix')][string]$Variant,
    [Parameter(Mandatory)][string]$RunId,
    [Parameter(Mandatory)][string]$ImageRef,
    [Parameter(Mandatory)][string]$BackupPath,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$ExpectedBackupSha256,
    [Parameter(Mandatory)][string]$RestoreReceiptPath,
    [Parameter(Mandatory)][string]$OutputRoot,
    [string]$NetworkName = "wi2222897-$Variant-$RunId",
    [switch]$Provision
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $Provision) { throw 'Refusing target writes: pass -Provision only from the authorized isolated job.' }
if ($RunId -notmatch '^[A-Za-z0-9._-]+$') { throw 'RunId contains unsafe characters.' }
if ($ImageRef -notmatch '@sha256:[0-9a-fA-F]{64}$') { throw 'ImageRef must be digest-pinned.' }
if ($NetworkName -notmatch '^wi2222897-[A-Za-z0-9._-]+$') { throw 'NetworkName is not WI-2222897 scoped.' }
if (-not (Test-Path -LiteralPath $BackupPath -PathType Leaf)) { throw "Backup is missing: $BackupPath" }
if (-not (Test-Path -LiteralPath $RestoreReceiptPath -PathType Leaf)) { throw "Restore receipt is missing: $RestoreReceiptPath" }
$restoreReceipt = Get-Content -LiteralPath $RestoreReceiptPath -Raw | ConvertFrom-Json
if ($restoreReceipt.scope -ne 'WI-2222897' -or $restoreReceipt.runId -ne $RunId -or $restoreReceipt.variant -ne $Variant -or $restoreReceipt.status -ne 'PASS') { throw 'Restore receipt is not for this isolated run/variant or is not successful.' }
$actualBackup = (Get-FileHash -LiteralPath $BackupPath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($actualBackup -ne $ExpectedBackupSha256.ToUpperInvariant()) { throw "Backup SHA-256 mismatch: expected $ExpectedBackupSha256, got $actualBackup." }

function Invoke-Docker([string[]]$Arguments) {
    $output = & docker @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "docker $($Arguments -join ' ') failed: $($output -join ' ')" }
    @($output)
}
function Inspect([string]$Format, [string]$Id) {
    $value = & docker inspect --format $Format $Id 2>$null
    if ($LASTEXITCODE -ne 0) { throw "docker inspect failed for $Id" }
    (($value -join "`n").Trim())
}

# Read-only identity check before any container/network write.
$repoDigests = @(Invoke-Docker @('image','inspect',$ImageRef,'--format','{{json .RepoDigests}}') | ConvertFrom-Json)
if (-not ($repoDigests | Where-Object { $_ -eq $ImageRef })) { throw "Local image does not prove the requested digest: $ImageRef" }

$scope = "WI-2222897/$Variant/$RunId"
$containerName = "wi2222897-$Variant-$RunId"
$labels = @('--label',"wi.scope=$scope",'--label','wi.ephemeral=true',"--label","wi.runId=$RunId",'--label',"wi.cleanup=$containerName")
$existing = & docker ps -a --filter "name=^/$containerName$" --format '{{.ID}}' 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($existing -join ''))) { throw "Target container already exists: $containerName" }
$networkExisting = & docker network ls --filter "name=^$NetworkName$" --format '{{.Name}}' 2>$null
if ($LASTEXITCODE -ne 0) { throw 'docker network inspection failed.' }
if (@($networkExisting | Where-Object { $_ -eq $NetworkName }).Count -eq 0) {
    Invoke-Docker (@('network','create','--internal') + $labels + @($NetworkName)) | Out-Null
}

$mount = "type=bind,source=$BackupPath,target=C:\wi2222897\backup,readonly"
$createArgs = @('create','--name',$containerName,'--network',$NetworkName) + $labels + @('--mount',$mount,$ImageRef)
Invoke-Docker $createArgs | Out-Null
try {
    Invoke-Docker @('start',$containerName) | Out-Null
    $id = Inspect '{{.Id}}' $containerName
    $state = Inspect '{{.State.Status}}' $containerName
    $actualImage = Inspect '{{.Config.Image}}' $containerName
    $scopeActual = Inspect '{{index .Config.Labels "wi.scope"}}' $containerName
    $ephemeral = Inspect '{{index .Config.Labels "wi.ephemeral"}}' $containerName
    $runActual = Inspect '{{index .Config.Labels "wi.runId"}}' $containerName
    if ($state -ne 'running' -or $actualImage -ne $ImageRef -or $scopeActual -ne $scope -or $ephemeral -ne 'true' -or $runActual -ne $RunId) { throw 'Target inspection did not match the requested isolated contract.' }
    $inspectJson = Invoke-Docker @('inspect',$containerName) | Out-String
    New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    $inspectPath = Join-Path $OutputRoot 'target-docker-inspect.json'
    $inspectJson | Set-Content -LiteralPath $inspectPath -Encoding UTF8
    [ordered]@{
        schema='wi2222897-target-attestation-1'; producer='isolated-job'; scope='WI-2222897'; variant=$Variant
        runId=$RunId; containerId=$id; containerName=$containerName; image=$ImageRef
        backupPath=(Split-Path -Leaf $BackupPath); backupSha256=$actualBackup
        network=$NetworkName; appHost=$containerName; dbHost=$containerName
        cleanupScope=$containerName; inspectedUtc=[DateTimeOffset]::UtcNow.ToString('o')
        inspectPath=(Split-Path -Leaf $inspectPath); restoreReceipt=(Split-Path -Leaf $RestoreReceiptPath); restore='PASS'
    } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputRoot 'target-attestation.json') -Encoding UTF8
    Write-Host "PASS: isolated target created and inspected; variant=$Variant; container=$id; image=$ImageRef; backupSha256=$actualBackup"
}
catch {
    & docker rm -f $containerName 2>$null | Out-Null
    throw
}
