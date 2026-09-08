[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $CandidatePath,
    [Parameter(Mandatory)] [string] $ArtifactDirectory,
    [string] $SourceCommit = '4c22cb2850a150161f44080815375527c4daad48'
)

$ErrorActionPreference = 'Stop'
$expectedPackageHash = '803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B'
$expectedVersion = '2.0.42-soapnamespace.20260907'
# Candidate API DLL hash verified by extracting the 803D... package; keep this exact 64-hex value.
$expectedApiHash = '57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B'
$expectedConsoleHash = '82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F'

if (-not (Test-Path -LiteralPath $CandidatePath -PathType Leaf)) {
    throw "Candidate nupkg not found: $CandidatePath"
}
New-Item -ItemType Directory -Force -Path $ArtifactDirectory | Out-Null

$packageHash = (Get-FileHash -LiteralPath $CandidatePath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($packageHash -ne $expectedPackageHash) { throw "Unexpected package SHA-256: $packageHash" }

$work = Join-Path ([IO.Path]::GetTempPath()) ('wi2222897-console-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::ExtractToDirectory($CandidatePath, $work)
    $nuspec = Get-ChildItem -LiteralPath $work -Filter '*.nuspec' -File | Select-Object -First 1
    if (-not $nuspec) { throw 'Nuspec missing from candidate package' }
    [xml]$manifest = Get-Content -LiteralPath $nuspec.FullName -Raw
    $version = $manifest.package.metadata.version
    if ($version -ne $expectedVersion) { throw "Unexpected nuspec version: $version" }

    $api = Join-Path $work 'tools/Cegid.Retail.AutoTest.Api.dll'
    $console = Join-Path $work 'tools/Cegid.Retail.AutoTest.Console.exe'
    $apiHash = (Get-FileHash -LiteralPath $api -Algorithm SHA256).Hash.ToUpperInvariant()
    $consoleHash = (Get-FileHash -LiteralPath $console -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($apiHash -ne $expectedApiHash) { throw "Unexpected API DLL SHA-256: $apiHash" }
    if ($consoleHash -ne $expectedConsoleHash) { throw "Unexpected Console EXE SHA-256: $consoleHash" }

    $target = Join-Path $ArtifactDirectory (Split-Path $CandidatePath -Leaf)
    Copy-Item -LiteralPath $CandidatePath -Destination $target -Force
    [pscustomobject]@{
        sourceCommit = $SourceCommit
        packagePath = $target
        packageVersion = $version
        packageSha256 = $packageHash
        apiDllSha256 = $apiHash
        consoleExeSha256 = $consoleHash
        publication = 'PipelineArtifact-only'
        sharedFeedPublication = $false
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ArtifactDirectory 'console-candidate-manifest.json') -Encoding UTF8
}
finally {
    if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force }
}
