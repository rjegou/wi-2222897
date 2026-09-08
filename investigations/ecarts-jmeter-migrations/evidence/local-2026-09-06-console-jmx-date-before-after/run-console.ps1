param(
    [Parameter(Mandatory=$true)][string]$Runtime,
    [Parameter(Mandatory=$true)][string]$Campaign,
    [Parameter(Mandatory=$true)][string]$Output,
    [Parameter(Mandatory=$true)][string]$Stdout,
    [Parameter(Mandatory=$true)][string]$Stderr
)
$ErrorActionPreference = 'Stop'
$campaignName = [IO.Path]::GetFileNameWithoutExtension($Campaign)
New-Item -ItemType Directory -Force -Path (Join-Path $Output ("IntegratedTests\Workflow\..\AutoTest\Data\$campaignName\TestPlans\OutputFiles")) | Out-Null
Push-Location $Runtime
try {
    $campaignArg = '..\fixtures\campaign.xml'
    $outputArg = '..\' + [IO.Path]::GetFileName($Output)
    & '.\Cegid.Retail.AutoTest.Console.exe' ("--tstj=$campaignArg") ("--dstFolder=$outputArg") 1> $Stdout 2> $Stderr
    exit $LASTEXITCODE
}
finally { Pop-Location }
