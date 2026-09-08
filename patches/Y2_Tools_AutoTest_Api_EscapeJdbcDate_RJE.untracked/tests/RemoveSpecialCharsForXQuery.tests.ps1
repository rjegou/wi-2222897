param([Parameter(Mandatory=$true)][string]$AssemblyPath)
$ErrorActionPreference = 'Stop'
[Reflection.Assembly]::LoadFrom((Resolve-Path $AssemblyPath)) | Out-Null
$cases = @(
  @{ Name='preencoded ampersand entity'; Input='&amp;lt;ClientelingParameters&amp;gt;'; Expected='&amp;amp;lt;ClientelingParameters&amp;amp;gt;' },
  @{ Name='plain XML'; Input='<ClientelingParameters>'; Expected='&lt;ClientelingParameters&gt;' },
  @{ Name='CommonParameters apostrophe'; Input="&amp;lt;CommonParameters name='x'&amp;gt;"; Expected='&amp;amp;lt;CommonParameters name=&apos;x&apos;&amp;amp;gt;' },
  @{ Name='already escaped ampersand'; Input='A &amp; B'; Expected='A &amp;amp; B' }
)
foreach($case in $cases) {
  $actual=[Cegid.Retail.AutoTest.Api.JmeterCodeGen]::RemoveSpecialCharsForXQuery($case.Input)
  if($actual -cne $case.Expected){throw "$($case.Name): expected [$($case.Expected)] got [$actual]"}
  "PASS $($case.Name)"
}
