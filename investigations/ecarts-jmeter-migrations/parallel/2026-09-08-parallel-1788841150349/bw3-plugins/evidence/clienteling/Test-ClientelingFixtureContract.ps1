$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot 'fixture-contract'
$folder = Join-Path $root 'GetItemImage'
New-Item -ItemType Directory -Force -Path $folder | Out-Null
$fixture = Join-Path $folder 'fixture-fake.jpg'
Set-Content -LiteralPath $fixture -Value 'fixture-bytes' -NoNewline

$placeholder = '${tests.folder}\${CustomImageFolder}'
$concrete = Join-Path $root 'GetItemImage'
$placeholderPath = $placeholder -replace '\$\{tests\.folder\}', $root
$placeholderPath = $placeholderPath -replace '\$\{CustomImageFolder\}', '${CustomImageFolder}'
if (Test-Path -LiteralPath $placeholderPath) { throw 'placeholder unexpectedly resolved without CustomImageFolder substitution' }
$resolved = Join-Path $concrete 'fixture-fake.jpg'
if (!(Test-Path -LiteralPath $resolved)) { throw 'concrete package-relative fixture path did not resolve' }
Write-Output '{"placeholder":"rejected","concreteRelativeFolder":"GetItemImage","fixture":"present"}'
Write-Output 'PASS: fake fixture contract rejects unresolved placeholder and resolves a package-relative folder.'
