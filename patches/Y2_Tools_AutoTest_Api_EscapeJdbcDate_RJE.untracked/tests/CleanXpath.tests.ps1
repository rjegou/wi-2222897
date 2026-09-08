param([Parameter(Mandatory=$true)][string]$AssemblyPath)
$ErrorActionPreference = 'Stop'
[Reflection.Assembly]::LoadFrom((Resolve-Path $AssemblyPath)) | Out-Null
$cases = @(
  @{ Name='/soap:Fault'; Input='/soap:Fault'; Expected='//Fault' },
  @{ Name='Fault predicate'; Input='/soap:Fault[ @code = "E" ]'; Expected='//Fault[@code = &quot;E&quot; ]' },
  @{ Name='Fault descendant'; Input='/soap:Envelope/soap:Body/soap:Fault'; Expected='//soap:Envelope/soap:Body/Fault' },
  @{ Name='non-Fault absolute'; Input='/soap:Envelope/soap:Body/soap:Response'; Expected='//soap:Envelope/soap:Body/soap:Response' },
  @{ Name='non-Fault descendant'; Input='//soap:Response/soap:Result'; Expected='//soap:Response/soap:Result' }
)
foreach($case in $cases) {
  $actual = [Cegid.Retail.AutoTest.Api.JmeterCodeGen]::CleanXpath($case.Input)
  if($actual -cne $case.Expected) { throw "$($case.Name): expected [$($case.Expected)] got [$actual]" }
  "PASS $($case.Name): $actual"
}

# Validate the corrected paths against SOAP-shaped XML without a business HTTP call.
$doc = New-Object System.Xml.XmlDocument
$doc.LoadXml('<soap:Envelope xmlns:soap="urn:soap"><soap:Body><soap:Fault code="E"><soap:Detail /></soap:Fault><soap:Response><soap:Result /></soap:Response></soap:Body></soap:Envelope>')
$ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
$ns.AddNamespace('soap','urn:soap')
if($doc.SelectNodes('//soap:Fault',$ns).Count -ne 1) { throw 'SOAP Fault selection failed' }
if($doc.SelectNodes('//soap:Response/soap:Result',$ns).Count -ne 1) { throw 'non-Fault selection failed' }
'PASS synthetic SOAP namespace selections'
