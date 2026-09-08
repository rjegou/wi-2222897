param(
    [Parameter(Mandatory)] [string] $SourceBase,
    [Parameter(Mandatory)] [string] $CandidateRoot
)
$ErrorActionPreference = 'Stop'

$versions = @(
    @{ Name = 'V22'; Snapshot = 'Y2_Plugins_Clienteling-v6-build-4432602'; Manifest = 'Kits/V22/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml' },
    @{ Name = 'V23'; Snapshot = 'Y2_Plugins_Clienteling-v6-build-4432602'; Manifest = 'Kits/V23/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml' },
    @{ Name = 'V24'; Snapshot = 'Y2_Plugins_Clienteling-v7-build-4432652'; Manifest = 'Kits/V24/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml' },
    @{ Name = 'V25'; Snapshot = 'Y2_Plugins_Clienteling-v8-build-4432672'; Manifest = 'Kits/V25/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml' },
    @{ Name = 'V26'; Snapshot = 'Y2_Plugins_Clienteling-master-build-4432554-exact'; Manifest = 'Kits/V26/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml' }
)

$results = foreach ($v in $versions) {
    $baseline = Join-Path (Join-Path $SourceBase $v.Snapshot) ($v.Manifest -replace '/', '\')
    $text = Get-Content -Raw -LiteralPath $baseline
    $svc = 'Products\ClientelingProductsService.svc'
    $sourceSvc = Join-Path (Join-Path $SourceBase $v.Snapshot) ('Cegid.Retail.Clienteling.WebServices\' + $svc)
    if ($text -match [regex]::Escape('ClientelingProductsService.svc')) { throw "$($v.Name): baseline MSI already contains Products unexpectedly" }
    if (!(Test-Path -LiteralPath $sourceSvc)) { throw "$($v.Name): source Products SVC missing" }
    if ($v.Name -eq 'V26') {
        $candidate = Join-Path $CandidateRoot ($v.Manifest -replace '/', '\')
        $candidateText = Get-Content -Raw -LiteralPath $candidate
        if ($candidateText -notmatch [regex]::Escape('%SRCPATH%\Products\ClientelingProductsService.svc')) { throw 'V26 candidate does not package Products SVC' }
        [pscustomobject]@{ Version = $v.Name; BaselineManifest = 'absent'; SourceService = 'present'; CandidateManifest = 'present' }
    } else {
        [pscustomobject]@{ Version = $v.Name; BaselineManifest = 'absent'; SourceService = 'present'; CandidateManifest = 'not patched' }
    }
}
$results | ConvertTo-Json -Compress
Write-Output 'PASS: Products service exists in all five source snapshots; all five baseline MSI manifests omit it; V26 candidate adds the exact SVC path.'
