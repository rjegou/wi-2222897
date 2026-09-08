[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)][string]$ContainerName,
    [Parameter(Mandatory)][string]$NetworkName,
    [Parameter(Mandatory)][string]$RunId
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($ContainerName -notmatch '^wi2222897-(Cur|Fix)-[A-Za-z0-9._-]+$' -or $NetworkName -notmatch '^wi2222897-[A-Za-z0-9._-]+$') { throw 'Cleanup target is not WI-2222897 scoped.' }
$scope = & docker inspect --format '{{index .Config.Labels "wi.scope"}}' $ContainerName 2>$null
$labelRun = & docker inspect --format '{{index .Config.Labels "wi.runId"}}' $ContainerName 2>$null
if ($LASTEXITCODE -ne 0 -or $scope -notmatch '^WI-2222897/(Cur|Fix)/' -or ($labelRun -join '') -ne $RunId) { throw 'Refusing cleanup: ownership labels do not match this run.' }
& docker rm -f $ContainerName | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Container removal failed.' }
$remaining = & docker ps -a --filter "name=^/$ContainerName$" --format '{{.ID}}' 2>$null
if ($LASTEXITCODE -ne 0 -or -not [string]::IsNullOrWhiteSpace(($remaining -join ''))) { throw 'Container cleanup could not be verified.' }
$networkUsers = & docker network inspect $NetworkName --format '{{range .Containers}}{{.Name}}{{"`n"}}{{end}}' 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($networkUsers -join ''))) { throw 'Network still has attached containers; refusing network deletion.' }
& docker network rm $NetworkName | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Network removal failed.' }
if ((& docker network ls --filter "name=^$NetworkName$" --format '{{.Name}}' 2>$null) -contains $NetworkName) { throw 'Network cleanup could not be verified.' }
Write-Host "PASS: cleanup verified; container=$ContainerName; network=$NetworkName; run=$RunId"
