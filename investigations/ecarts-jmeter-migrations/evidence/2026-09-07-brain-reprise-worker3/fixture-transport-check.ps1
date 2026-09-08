$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$legacyFixtureRoot = Join-Path $root '..\legacy\raw\missing-supplement\Workflow\Y2_Plugins_Clienteling_V6\config_PLG\GetItemImage'
$sourceConfig = Join-Path $root '..\..\sources\Y2_Plugins_Clienteling-v6-build-4432602\Tests\Config\v22-fix.cy2px'
$sourceSnapshotRoot = Join-Path $root '..\..\sources\Y2_Plugins_Clienteling-v6-build-4432602'
$template = Join-Path $root '..\..\..\..\worktrees\Y2_Tools_PlatformDeploy\Src\PipelineTemplates\task-deploy-in-containerized-job.v2.yml'

$tempRoot = Join-Path $env:TEMP ('wi2222897-clienteling-fixture-check-' + [guid]::NewGuid().ToString('N'))
try {
    $fixtureDir = Join-Path $tempRoot 'GetItemImage'
    New-Item -ItemType Directory -Path $fixtureDir -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $fixtureDir 'fixture.jpg') -Value 'fake-fixture' -NoNewline

    [xml]$configXml = Get-Content -LiteralPath $sourceConfig -Raw
    $customImage = $configXml.SelectSingleNode('//AppSetting[@key="CustomImageLocation"]')
    if ($null -eq $customImage) { throw 'CustomImageLocation not found' }
    $literalValue = [string]$customImage.value
    $resolvedValue = Join-Path $fixtureDir 'fixture.jpg'

    $legacyFixtureCount = @(Get-ChildItem -LiteralPath $legacyFixtureRoot -File | Where-Object { $_.Extension -in '.jpg','.jpeg','.png','.gif','.bmp' }).Count
    $sourceSnapshotImageCount = @(Get-ChildItem -LiteralPath $sourceSnapshotRoot -Recurse -File | Where-Object { $_.Extension -in '.jpg','.jpeg','.png','.gif','.bmp' }).Count
    $pipelineCustomImageCopyCount = ([regex]::Matches((Get-Content -LiteralPath $template -Raw), 'CustomImage|ImageFolder', [Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
    $placeholderExistsAsPath = Test-Path -LiteralPath $literalValue
    $resolvedFixtureExists = Test-Path -LiteralPath $resolvedValue

    [pscustomobject]@{
        customImageLocation = $literalValue
        legacyFixtureCount = $legacyFixtureCount
        sourceSnapshotImageCount = $sourceSnapshotImageCount
        pipelineCustomImageCopyCount = $pipelineCustomImageCopyCount
        placeholderExistsAsPath = $placeholderExistsAsPath
        resolvedFixtureExists = $resolvedFixtureExists
        discriminant = 'absolute fixture path resolves; literal placeholder does not'
    } | ConvertTo-Json -Compress
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
