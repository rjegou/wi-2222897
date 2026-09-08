[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)][ValidateSet('Cur','Fix')][string]$Variant,
    [Parameter(Mandatory)][string]$RunId,
    [Parameter(Mandatory)][string]$PlatformDeployScript,
    [Parameter(Mandatory)][string]$DeployConfig,
    [Parameter(Mandatory)][string]$BackupPath,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$ExpectedBackupSha256,
    [Parameter(Mandatory)][string]$ContainerName,
    [Parameter(Mandatory)][string]$NetworkName,
    [Parameter(Mandatory)][string]$DataRoot,
    [Parameter(Mandatory)][string]$OutputRoot,
    [switch]$Provision
)
$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
if(-not $Provision){throw 'Refusing PlatformDeploy and Docker writes: pass -Provision only in the authorized isolated job.'}
if($RunId -notmatch '^[A-Za-z0-9._-]+$' -or $ContainerName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$' -or $NetworkName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$'){throw 'Unsafe WI-2222897 identifiers.'}
foreach($p in @($PlatformDeployScript,$DeployConfig,$BackupPath)){if(-not(Test-Path -LiteralPath $p -PathType Leaf)){throw "Required deployment input is missing: $p"}}
$backupHash=(Get-FileHash -LiteralPath $BackupPath -Algorithm SHA256).Hash.ToUpperInvariant();if($backupHash -ne $ExpectedBackupSha256.ToUpperInvariant()){throw 'Backup hash mismatch before deployment.'}
$deployText=Get-Content -LiteralPath $PlatformDeployScript -Raw;if($deployText -notmatch 'LocalDBInContainer'){throw 'PlatformDeploy script does not contain the established LocalDBInContainer mechanism.'}
function D([string[]]$a){$o=& docker @a 2>&1;if($LASTEXITCODE -ne 0){throw "docker failed: $($o -join ' ')"};@($o)}
function I([string]$f,[string]$id){(D @('inspect','--format',$f,$id)-join "`n").Trim()}
$scope="WI-2222897/$Variant/$RunId";New-Item -ItemType Directory -Path $OutputRoot -Force|Out-Null
D @('info','--format','{{json .ServerVersion}}')|Out-Null
$existing=& docker network ls --filter "name=^$NetworkName$" --format '{{.Name}}' 2>$null;if($existing -contains $NetworkName){throw 'Refusing a pre-existing network; ownership cannot be established.'}
if($PSCmdlet.ShouldProcess($PlatformDeployScript,'Run PlatformDeploy with LocalDBInContainer Backup')){
    $raw=& $PlatformDeployScript -deployConfig $DeployConfig -LocalDBInContainer Backup 2>&1;$exit=$LASTEXITCODE
    if($exit -ne 0){throw 'PlatformDeploy failed; raw output intentionally not persisted.'}
    $rawText=($raw -join "`n") -replace '(?i)(password|token|secret|authorization)\s*[:=]\s*[^\s,;]+','$1=<redacted>'
    [ordered]@{schema='wi2222897-platformdeploy-receipt-1';scope='WI-2222897';variant=$Variant;runId=$RunId;mechanism='PlatformDeploy -LocalDBInContainer Backup';backupPath=(Split-Path -Leaf $BackupPath);backupSha256=$backupHash;container=$ContainerName;network=$NetworkName;outputSummaryHash=(Get-FileHash -InputStream ([IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($rawText))) -Algorithm SHA256).Hash.ToUpperInvariant();status='PASS';createdUtc=[DateTimeOffset]::UtcNow.ToString('o')}|ConvertTo-Json -Depth 8|Set-Content -LiteralPath (Join-Path $OutputRoot 'deployment-receipt.json') -Encoding UTF8
}
if((I '{{index .Config.Labels "wi.scope"}}' $ContainerName)-ne $scope -or (I '{{index .Config.Labels "wi.runId"}}' $ContainerName)-ne $RunId){throw 'PlatformDeploy target labels do not prove run ownership.'}
if((I '{{index .Labels "wi.scope"}}' $NetworkName)-ne $scope -or (I '{{index .Labels "wi.runId"}}' $NetworkName)-ne $RunId -or (I '{{.Internal}}' $NetworkName)-ne 'true'){throw 'PlatformDeploy network is not owned/internal.'}
if($PSCmdlet.ShouldProcess($ContainerName,'Create and verify DataRoot inside target')){D @('exec',$ContainerName,'powershell','-NoProfile','-Command',"New-Item -ItemType Directory -Force -Path '$DataRoot' | Out-Null; if(-not(Test-Path -LiteralPath '$DataRoot')){exit 23}")|Out-Null}
