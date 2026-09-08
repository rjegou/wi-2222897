param(
    [string]$Root = $PSScriptRoot,
    [string]$ExpectedSha256 = 'C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C'
)
$campaign = Join-Path $Root 'campaigns\ExportRunOnly.xml'
[xml]$xml = Get-Content -LiteralPath $campaign -Raw
$nodes = @(Select-Xml -Xml $xml -XPath '//TestCampaign/TestPlanItem')
if ($nodes.Count -ne 1) { throw "Expected exactly one campaign item; got $($nodes.Count)" }
$resolved = Join-Path (Join-Path $Root 'payload\Tests') $nodes[0].Node.item
if ([IO.Path]::GetExtension($resolved) -ne '.jmx') { throw "Resolved item is not JMX: $resolved" }
if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) { throw "JMX absent: $resolved" }
$hash = (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash
if ($hash -ne $ExpectedSha256) { throw "Unexpected JMX hash: $hash" }
$jmx = [xml](Get-Content -LiteralPath $resolved -Raw)
$samplers = @($jmx.SelectNodes("//*[local-name()='JDBCSampler']")).Count
if ($samplers -ne 86) { throw "Unexpected XML JDBCSampler count: $samplers" }
"PASS nodes=$($nodes.Count) resolved=$resolved sha256=$hash JDBCSampler=$samplers"
