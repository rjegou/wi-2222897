[CmdletBinding(SupportsShouldProcess=$true)]
param([Parameter(Mandatory)][ValidateSet('Cur','Fix')][string]$Variant,[Parameter(Mandatory)][string]$RunId,[Parameter(Mandatory)][string]$ContainerName,[Parameter(Mandatory)][string]$NetworkName)
$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
if($ContainerName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$' -or $NetworkName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$'){throw 'Cleanup target is not WI-2222897 scoped.'}
function D([string[]]$a){$o=& docker @a 2>&1;if($LASTEXITCODE -ne 0){throw "docker failed: $($o -join ' ')}"};@($o)}
$scope="WI-2222897/$Variant/$RunId"
if((D @('inspect','--format','{{index .Config.Labels "wi.scope"}}',$ContainerName))-join '' -ne $scope){throw 'Container ownership mismatch.'}
if((D @('inspect','--format','{{index .Labels "wi.scope"}}',$NetworkName))-join '' -ne $scope){throw 'Network ownership mismatch.'}
if($PSCmdlet.ShouldProcess($ContainerName,'Remove owned target')){D @('rm','-f',$ContainerName)|Out-Null}
if((D @('ps','-a','--filter',"name=^/$ContainerName$",'--format','{{.ID}}')).Count){throw 'Container cleanup not verified.'}
if($PSCmdlet.ShouldProcess($NetworkName,'Remove owned empty network')){D @('network','rm',$NetworkName)|Out-Null}
if((D @('network','ls','--filter',"name=^$NetworkName$",'--format','{{.Name}}')) -contains $NetworkName){throw 'Network cleanup not verified.'}
