[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ApiDll,
    [Parameter(Mandatory)] [string] $ConsoleExe,
    [string] $ConsoleConfig,
    [string] $DependencyDirectory,
    [string] $NuGetExe = 'nuget.exe',
    [string] $Version = '0.0.0-local',
    [string] $OutputDirectory
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[void]([System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem'))
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $root 'runs' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
if (-not $OutputDirectory.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must remain under evidence/console' }
$staging = Join-Path $root ('staging-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$tools = Join-Path $staging 'tools'
New-Item -ItemType Directory -Force -Path $tools,$OutputDirectory | Out-Null
function Require-File([string] $Path) { if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing input: $Path" }; (Resolve-Path -LiteralPath $Path).Path }
function Hash([string] $Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant() }
$api = Require-File $ApiDll; $console = Require-File $ConsoleExe
$config = if ($ConsoleConfig) { Require-File $ConsoleConfig } else { $null }
$apiHash = Hash $api; $consoleHash = Hash $console
Copy-Item -LiteralPath $api -Destination (Join-Path $tools 'Cegid.Retail.AutoTest.Api.dll')
Copy-Item -LiteralPath $console -Destination (Join-Path $tools 'Cegid.Retail.AutoTest.Console.exe')
if ($config) { Copy-Item -LiteralPath $config -Destination (Join-Path $tools 'Cegid.Retail.AutoTest.Console.exe.config') }
$dependencyFiles = @()
$dependencyRoot = $null
if ($DependencyDirectory) {
    if (-not (Test-Path -LiteralPath $DependencyDirectory -PathType Container)) { throw "Missing dependency directory: $DependencyDirectory" }
    $dependencyRoot = (Resolve-Path -LiteralPath $DependencyDirectory).Path
    $dependencyFiles = @(Get-ChildItem -LiteralPath $dependencyRoot -File -Recurse | Where-Object Extension -in '.dll','.exe','.config','.xml')
    foreach ($file in $dependencyFiles) {
        $relative = $file.FullName.Substring($dependencyRoot.Length).TrimStart('\')
        $destination = Join-Path $tools $relative
        New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $destination
    }
}
$nuspec = Join-Path $staging 'Cegid.Retail.AutoTest.Console.local.nuspec'
$configEntry = if ($config) { '<file src="tools\Cegid.Retail.AutoTest.Console.exe.config" target="tools" />' } else { '' }
$dependencyEntries = if ($dependencyFiles.Count -gt 0) { ($dependencyFiles | ForEach-Object { $relative = $_.FullName.Substring($dependencyRoot.Length).TrimStart('\'); '<file src="tools\' + $relative + '" target="tools" />' }) -join '' } else { '' }
@"
<?xml version="1.0"?><package><metadata><id>Cegid.Retail.AutoTest.Console</id><version>$Version</version><authors>local</authors><description>WI-2222897 isolated package</description></metadata><files><file src="tools\Cegid.Retail.AutoTest.Api.dll" target="tools" /><file src="tools\Cegid.Retail.AutoTest.Console.exe" target="tools" />$configEntry$dependencyEntries</files></package>
"@ | Set-Content -LiteralPath $nuspec -Encoding UTF8
& $NuGetExe pack $nuspec -BasePath $staging -OutputDirectory $OutputDirectory -NoPackageAnalysis
if ($LASTEXITCODE -ne 0) { throw "nuget pack failed: $LASTEXITCODE" }
$nupkg = Get-ChildItem -LiteralPath $OutputDirectory -Filter '*.nupkg' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $nupkg) { throw 'No nupkg produced' }
$zip = Join-Path $staging 'unzipped'; [IO.Compression.ZipFile]::ExtractToDirectory($nupkg.FullName, $zip)
$packagedApi = Join-Path $zip 'tools/Cegid.Retail.AutoTest.Api.dll'; $packagedConsole = Join-Path $zip 'tools/Cegid.Retail.AutoTest.Console.exe'
$result = [ordered]@{ ApiInputSha256=$apiHash; ApiStagedSha256=(Hash (Join-Path $tools 'Cegid.Retail.AutoTest.Api.dll')); ApiPackagedSha256=(Hash $packagedApi); ConsoleInputSha256=$consoleHash; ConsoleStagedSha256=(Hash (Join-Path $tools 'Cegid.Retail.AutoTest.Console.exe')); ConsolePackagedSha256=(Hash $packagedConsole); NupkgSha256=(Hash $nupkg.FullName); IdentityPostcondition=(($apiHash -eq (Hash $packagedApi)) -and ($consoleHash -eq (Hash $packagedConsole))); Output=$nupkg.FullName }
$result | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'last-result.json') -Encoding UTF8
$result | Format-Table -AutoSize
if (-not $result.IdentityPostcondition) { throw 'Identity postcondition failed' }
