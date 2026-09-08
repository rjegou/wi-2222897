param(
  [string]$SourceRoot = "$(Build.SourcesDirectory)\Y2_Plugins_FrenchTaxesRules",
  [string]$ResultRoot = "$(Build.SourcesDirectory)\Y2_Plugins_FrenchTaxesRules\Tests\Results\Y2.Plugin.FrenchTaxesRules-ExportRunOnly-v26-Fix",
  [string]$DeployArchive = "$(Agent.TempDirectory)\Deploy\Y2-Deployment-Logs.zip",
  [string]$Staging = "$(Build.ArtifactStagingDirectory)\rje-evidence"
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $Staging | Out-Null
$explicit = @(
  @{ Source = "$SourceRoot\Tests\LegacyServices\010-Export_Run.jmx"; Relative = 'jmx\010-Export_Run.jmx' },
  @{ Source = "$SourceRoot\Tests\ExportRunOnly.xml"; Relative = 'campaign\ExportRunOnly.xml' },
  @{ Source = "$ResultRoot\ExportRunOnly-results.xml"; Relative = 'results\ExportRunOnly-results.xml' },
  @{ Source = "$ResultRoot\010-Export_Run\010-Export_Run-results.jtl"; Relative = 'results\010-Export_Run-results.jtl' },
  @{ Source = "$ResultRoot\010-Export_Run\jmeter.log"; Relative = 'results\010-Export_Run-jmeter.log' },
  @{ Source = "$ResultRoot\010-Export_Run\010-Export_Run.xml"; Relative = 'results\010-Export_Run-detail.xml' },
  @{ Source = "$(Build.ArtifactStagingDirectory)\deployment-archive-files.txt"; Relative = 'deployment\archive-files.txt' },
  @{ Source = "$(Build.ArtifactStagingDirectory)\backup.sha256"; Relative = 'manifest\backup.sha256' },
  @{ Source = "$(Build.ArtifactStagingDirectory)\resolved-targets.txt"; Relative = 'manifest\resolved-targets.txt' },
  @{ Source = "$(Build.ArtifactStagingDirectory)\references-consumed.txt"; Relative = 'manifest\references-consumed.txt' }
)
$manifest = @()
if (Test-Path -LiteralPath $DeployArchive -PathType Leaf) {
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip = [IO.Compression.ZipFile]::OpenRead($DeployArchive)
  try { $zip.Entries.FullName | Sort-Object | Set-Content -LiteralPath "$(Build.ArtifactStagingDirectory)\deployment-archive-files.txt" -Encoding UTF8 }
  finally { $zip.Dispose() }
}
foreach ($item in $explicit) {
  $destination = Join-Path $Staging $item.Relative
  if (Test-Path -LiteralPath $item.Source -PathType Leaf) {
    New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null
    Copy-Item -LiteralPath $item.Source -Destination $destination -Force
    $hash = (Get-FileHash -LiteralPath $item.Source -Algorithm SHA256).Hash
    $manifest += "$($item.Relative)`t$hash"
  } else {
    $manifest += "MISSING`t$($item.Relative)"
  }
}
$manifest | Set-Content -LiteralPath (Join-Path $Staging 'manifest\files.tsv') -Encoding UTF8
