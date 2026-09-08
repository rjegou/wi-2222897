$ErrorActionPreference='Stop'
$runtime=Join-Path $PSScriptRoot 'runtime'
$src=@"
using System;
class Diagnostic {
 static int Main(string[] args) {
  try { new Cegid.Retail.AutoTest.Console.Launcher().ExecuteTest(args); return 0; }
  catch(Exception ex) { System.Console.WriteLine(ex.ToString()); return 1; }
  finally { foreach(var a in AppDomain.CurrentDomain.GetAssemblies()) if(a.GetName().Name=="Cegid.Retail.AutoTest.Api") System.Console.WriteLine("LOADED_API="+a.Location); }
 }
}
"@
Set-Location $runtime
$src | Set-Content '.\Diagnostic.cs'
& C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /target:exe /out:diagnostic.exe /reference:Cegid.Retail.AutoTest.Console.exe Diagnostic.cs
if ($LASTEXITCODE -ne 0) { throw 'Diagnostic compilation failed' }
Copy-Item -LiteralPath (Join-Path $runtime 'Cegid.Retail.AutoTest.Console.exe.config') -Destination (Join-Path $runtime 'diagnostic.exe.config')
Set-Location $runtime
& '.\diagnostic.exe' "--tstj=$(Join-Path $PSScriptRoot 'fixtures/campaign.xml')" "--dstFolder=$(Join-Path $PSScriptRoot 'output')" 2>&1 | Tee-Object (Join-Path $PSScriptRoot 'diagnostic-exe.log')
"Exit=$LASTEXITCODE"


