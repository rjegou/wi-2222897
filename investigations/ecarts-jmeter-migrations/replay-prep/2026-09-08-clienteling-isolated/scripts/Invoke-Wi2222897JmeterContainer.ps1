[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)][ValidateSet('Cur','Fix')][string]$Variant,
    [Parameter(Mandatory)][string]$RunId,
    [Parameter(Mandatory)][string]$NetworkName,
    [Parameter(Mandatory)][string]$TargetContainerName,
    [Parameter(Mandatory)][string]$JmeterContainerName,
    [Parameter(Mandatory)][string]$JmeterImageRef,
    [Parameter(Mandatory)][string]$JmxRoot,
    [Parameter(Mandatory)][string]$JmeterRoot,
    [Parameter(Mandatory)][string]$OutputRoot,
    [switch]$Run
)
$ErrorActionPreference='Stop';Set-StrictMode -Version Latest
if($RunId -notmatch '^[A-Za-z0-9._-]+$' -or $NetworkName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$' -or $TargetContainerName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$' -or $JmeterContainerName -notmatch '^wi2222897-jmeter-(Cur|Fix)-[A-Za-z0-9._-]+$'){throw 'Unsafe WI-2222897 identifiers.'}
foreach($p in @($JmxRoot,$JmeterRoot)){if(-not(Test-Path -LiteralPath $p -PathType Container)){throw "JMeter input root missing: $p"}}
function D([string[]]$a){$o=& docker @a 2>&1;if($LASTEXITCODE -ne 0){throw "docker failed: $($o -join ' ')"};@($o)}
function I([string]$f,[string]$id){(D @('inspect','--format',$f,$id)-join "`n").Trim()}
$scope="WI-2222897/$Variant/$RunId";D @('info','--format','{{json .ServerVersion}}')|Out-Null
if((I '{{index .Labels "wi.scope"}}' $NetworkName)-ne $scope -or (I '{{.Internal}}' $NetworkName)-ne 'true'){throw 'Target network is not owned/internal.'}
if((I '{{index .Config.Labels "wi.scope"}}' $TargetContainerName)-ne $scope){throw 'Target container ownership mismatch.'}
$existing=& docker ps -a --filter "name=^/$JmeterContainerName$" --format '{{.ID}}' 2>$null;if($existing){throw 'JMeter container name already exists.'}
$jmxMount="${JmxRoot}:C:\wi2222897\jmx:ro";$jmeterMount="${JmeterRoot}:C:\wi2222897\jmeter:ro";$outMount="${OutputRoot}:C:\wi2222897\out"
$labels=@('--label',"wi.scope=$scope",'--label','wi.ephemeral=true','--label',"wi.runId=$RunId")
$args=@('create','--name',$JmeterContainerName,'--network',$NetworkName)+$labels+@('--mount',"type=bind,source=$JmxRoot,target=C:\wi2222897\jmx,readonly",'--mount',"type=bind,source=$JmeterRoot,target=C:\wi2222897\jmeter,readonly",'--mount',"type=bind,source=$OutputRoot,target=C:\wi2222897\out",$JmeterImageRef,'powershell','-NoProfile','-Command','Get-ChildItem C:\wi2222897\jmx -Filter *.jmx | ForEach-Object { & C:\wi2222897\jmeter\bin\jmeter.bat -n -t $_.FullName -l (Join-Path C:\wi2222897\out ($_.BaseName+".jtl")) }')
if(-not $Run){Write-Output 'DRY CONTRACT: JMeter sidecar would be created on the owned internal network; no Docker write performed.';return}
if($PSCmdlet.ShouldProcess($JmeterContainerName,'Create and run JMeter sidecar on private network')){D $args|Out-Null;D @('start',$JmeterContainerName)|Out-Null}
