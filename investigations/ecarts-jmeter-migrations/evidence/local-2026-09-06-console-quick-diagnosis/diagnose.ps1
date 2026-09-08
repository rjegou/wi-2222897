$ErrorActionPreference='Stop'
$root=$PSScriptRoot
Set-Location (Join-Path $root 'runtime')
$out=Join-Path $root 'output'
New-Item -ItemType Directory -Force -Path (Join-Path $out 'IntegratedTests/Workflow'),(Join-Path $out 'IntegratedTests/AutoTest/Data/campaign/TestPlans/OutputFiles') | Out-Null
try {
 [void][Reflection.Assembly]::LoadFrom((Join-Path $root 'runtime/Cegid.Retail.AutoTest.Console.exe'))
 $launcher=New-Object Cegid.Retail.AutoTest.Console.Launcher
 $launcher.ExecuteTest([string[]]@("--tstj=$(Join-Path $root 'fixtures/campaign.xml')","--dstFolder=$out"))
 'SUCCESS'
} catch { $_.Exception.ToString() | Set-Content (Join-Path $root 'exception.txt'); Get-Content (Join-Path $root 'exception.txt') }
[AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {$_.GetName().Name -eq 'Cegid.Retail.AutoTest.Api'} | ForEach-Object { $_.Location; (Get-FileHash -LiteralPath $_.Location -Algorithm SHA256).Hash }
