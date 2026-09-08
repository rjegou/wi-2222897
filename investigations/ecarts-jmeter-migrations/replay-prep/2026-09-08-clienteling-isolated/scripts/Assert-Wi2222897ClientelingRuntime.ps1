[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)][ValidateSet('Cur','Fix')][string]$Variant,
    [Parameter(Mandatory)][string]$RunId,
    [Parameter(Mandatory)][string]$ContainerName,
    [Parameter(Mandatory)][string]$NetworkName,
    [Parameter(Mandatory)][string]$JmeterContainerName,
    [Parameter(Mandatory)][string]$ImageRef,
    [Parameter(Mandatory)][string]$BackupPath,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$ExpectedBackupSha256,
    [Parameter(Mandatory)][string]$DeploymentReceiptPath,
    [Parameter(Mandatory)][string]$DeploymentProbeUrl,
    [Parameter(Mandatory)][string]$MobilityProbeUrl,
    [Parameter(Mandatory)][string]$OutputRoot,
    [switch]$ConnectJmeter
)
$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
if ($RunId -notmatch '^[A-Za-z0-9._-]+$') { throw 'Unsafe RunId.' }
if ($ContainerName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$') { throw 'Container is not WI-2222897 scoped.' }
if ($NetworkName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$') { throw 'Network is not WI-2222897 scoped.' }
if ($JmeterContainerName -notmatch '^wi2222897-jmeter-(Cur|Fix)-[A-Za-z0-9._-]+$') { throw 'JMeter container is not WI-2222897 scoped.' }
if (-not (Test-Path -LiteralPath $BackupPath -PathType Leaf)) { throw 'Acquired backup is missing.' }
if (-not (Test-Path -LiteralPath $DeploymentReceiptPath -PathType Leaf)) { throw 'PlatformDeploy receipt is missing.' }
$deploymentReceipt=Get-Content -LiteralPath $DeploymentReceiptPath -Raw
if ($deploymentReceipt -notmatch 'LocalDBInContainer\s+Backup') { throw 'PlatformDeploy receipt does not prove -LocalDBInContainer Backup.' }
function D([string[]]$a) { $o=& docker @a 2>&1; if($LASTEXITCODE -ne 0){throw "docker failed: $($o -join ' ')"}; @($o) }
function Inspect([string]$f,[string]$id) { (D @('inspect','--format',$f,$id) -join "`n").Trim() }
function Sql([string]$q) {
    $old=[Environment]::GetEnvironmentVariable('SQLCMDPASSWORD','Process')
    [Environment]::SetEnvironmentVariable('SQLCMDPASSWORD',$env:WI2222897_SQL_SA_PASSWORD,'Process')
    try { $a=@('exec','--env','SQLCMDPASSWORD',$ContainerName,'sqlcmd','-S','localhost','-U','sa','-b','-W','-h','-1','-Q',$q); $o=& docker @a 2>&1; if($LASTEXITCODE -ne 0){throw 'SQL probe failed.'}; @($o) }
    finally { [Environment]::SetEnvironmentVariable('SQLCMDPASSWORD',$old,'Process') }
}
if ([string]::IsNullOrWhiteSpace($env:WI2222897_SQL_SA_PASSWORD)) { throw 'SQL secret must be process-injected; it is never accepted as a parameter.' }
D @('info','--format','{{json .ServerVersion}}') | Out-Null
$scope="WI-2222897/$Variant/$RunId"
if ((Inspect '{{index .Config.Labels "wi.scope"}}' $ContainerName) -ne $scope) { throw 'Target ownership label mismatch.' }
if ((Inspect '{{index .Config.Labels "wi.runId"}}' $ContainerName) -ne $RunId) { throw 'Target run label mismatch.' }
if ((Inspect '{{.Config.Image}}' $ContainerName) -ne $ImageRef) { throw 'Target image reference mismatch.' }
$digests=@(D @('image','inspect',$ImageRef,'--format','{{json .RepoDigests}}') | ConvertFrom-Json)
if (-not ($digests | Where-Object { $_ -eq $ImageRef })) { throw 'Target image digest is not locally proven.' }
$networkScope=Inspect '{{index .Labels "wi.scope"}}' $NetworkName
$networkRun=Inspect '{{index .Labels "wi.runId"}}' $NetworkName
if ($networkScope -ne $scope -or $networkRun -ne $RunId -or (Inspect '{{.Internal}}' $NetworkName) -ne 'true') { throw 'Network ownership/internal isolation mismatch.' }
$ports=Inspect '{{json .NetworkSettings.Ports}}' $ContainerName
if ($ports -ne '{}' -and $ports -ne 'null') { throw 'Published ports are forbidden.' }
$hash=(Get-FileHash -LiteralPath $BackupPath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($hash -ne $ExpectedBackupSha256.ToUpperInvariant()) { throw 'Consumed backup hash mismatch.' }
if ((D @('exec',$ContainerName,'powershell','-NoProfile','-Command','Start-Service W3SVC; if((Get-Service W3SVC).Status -ne "Running"){exit 21}')) -join ' ') { }
$null=Sql 'SELECT 1'
if ($DeploymentProbeUrl -notmatch '/ClientelingDeploymentService\.svc(?:$|\?)') { throw 'Deployment probe must target ClientelingDeploymentService.svc.' }
if ($MobilityProbeUrl -notmatch '/ClientelingMobilityService\.svc(?:$|\?)') { throw 'Mobility probe must target ClientelingMobilityService.svc.' }
foreach($url in @($DeploymentProbeUrl,$MobilityProbeUrl)) {
    if ($url -notmatch '^https?://[A-Za-z0-9._:-]+/[A-Za-z0-9._/~:-]+$') { throw 'Probe URL must be an explicit non-secret URL.' }
    $probe=(D @('exec',$ContainerName,'powershell','-NoProfile','-Command',"\$r=Invoke-WebRequest -UseBasicParsing -Uri '$url' -TimeoutSec 30; if(\$r.StatusCode -lt 200 -or \$r.StatusCode -ge 500){exit 22}")) -join ' '
}
if ($ConnectJmeter) {
    if ((Inspect '{{index .Config.Labels "wi.scope"}}' $JmeterContainerName) -ne $scope) { throw 'JMeter ownership label mismatch.' }
    if ($PSCmdlet.ShouldProcess($JmeterContainerName,'Connect to owned private target network')) { D @('network','connect',$NetworkName,$JmeterContainerName) | Out-Null }
}
$attached=(D @('network','inspect',$NetworkName,'--format','{{range .Containers}}{{.Name}}{{"`n"}}{{end}}')) -join "`n"
if ($attached -notmatch [regex]::Escape($ContainerName) -or $attached -notmatch [regex]::Escape($JmeterContainerName)) { throw 'JMeter is not attached to the private target network.' }
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
[ordered]@{schema='wi2222897-clienteling-runtime-attestation-1';scope='WI-2222897';variant=$Variant;runId=$RunId;image=$ImageRef;backupSha256=$hash;appHost=$ContainerName;dbHost=$ContainerName;network=$NetworkName;jmeterContainer=$JmeterContainerName;deploymentMechanism='PlatformDeploy -LocalDBInContainer Backup';deploymentProbe=$DeploymentProbeUrl;mobilityProbe=$MobilityProbeUrl;publishedPorts=@();cleanupScope=$ContainerName;status='PASS';verifiedUtc=[DateTimeOffset]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputRoot 'target-attestation.json') -Encoding UTF8
