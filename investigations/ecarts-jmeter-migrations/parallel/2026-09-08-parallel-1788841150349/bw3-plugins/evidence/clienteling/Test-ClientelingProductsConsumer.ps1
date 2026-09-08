param(
    [Parameter(Mandatory)] [string] $SourceWebServices,
    [Parameter(Mandatory)] [string] $CandidateManifest
)
$ErrorActionPreference = 'Stop'
$manifest = Get-Content -Raw -LiteralPath $CandidateManifest
$match = [regex]::Match($manifest, '%SRCPATH%\\Products\\ClientelingProductsService\.svc')
if (!$match.Success) { throw 'candidate manifest does not consume Products SVC' }
$sourceSvc = Join-Path $SourceWebServices 'Products\ClientelingProductsService.svc'
if (!(Test-Path -LiteralPath $sourceSvc)) { throw 'manifest consumer has no source producer file' }
$missing = Join-Path $SourceWebServices 'Products\__missing__.svc'
if (Test-Path -LiteralPath $missing) { throw 'negative source path unexpectedly exists' }
Write-Output '{"manifestConsumer":"Products/ClientelingProductsService.svc","sourceProducer":"present","negativeMissingPath":"rejected"}'
Write-Output 'PASS: manifest consumer resolves to the source SVC and the negative missing-path case is rejected.'
