param([Parameter(Mandatory=$true)][string]$Root)
$ErrorActionPreference = 'Stop'
$modelPath = Join-Path $Root 'runtime-original\Cegid.Retail.AutoTest.Model.dll'
$model = [Reflection.Assembly]::LoadFrom($modelPath)
$ns = 'Cegid.Retail.AutoTest.Model'
$campaignType = $model.GetType("$ns.TestCampaign")
$itemType = $model.GetType("$ns.TestPlanItem")
$planType = $model.GetType("$ns.DtoLegacyServiceTestPlan")
$basePlanType = $model.GetType("$ns.TestPlan")
$caseType = $model.GetType("$ns.TestCase")
$controlType = $model.GetType("$ns.Control")

function Set-Property($Object, [string]$Name, $Value) {
    $Object.GetType().GetProperty($Name).SetValue($Object, $Value, $null)
}
function Write-Xml($Object, $Type, [string]$Path) {
    $serializer = [Xml.Serialization.XmlSerializer]::new($Type)
    $settings = [Xml.XmlWriterSettings]::new()
    $settings.Encoding = [Text.UTF8Encoding]::new($false)
    $settings.Indent = $true
    $writer = [Xml.XmlWriter]::Create($Path, $settings)
    try { $serializer.Serialize($writer, $Object) } finally { $writer.Dispose() }
}

$fixture = Join-Path $Root 'fixtures'
$plansDir = Join-Path $fixture 'TestPlans'
New-Item -ItemType Directory -Force -Path $plansDir | Out-Null
Set-Content -LiteralPath (Join-Path $fixture 'input.xml') -Value '<Root />' -Encoding UTF8
$queries = @(
    "SELECT '2026-04-28'",
    "SELECT '2026-04-05'",
    "SELECT '2024-02-29'",
    "SELECT '2026-04-28','2024-02-29'",
    "SELECT '20260428'",
    "SELECT '2026/04/28'"
)
$campaign = [Activator]::CreateInstance($campaignType)
Set-Property $campaign 'Code' 'ConsoleDate'
Set-Property $campaign 'Comment' 'Local-only six EscapeJdbcDate fixtures'
Set-Property $campaign 'Categories' ''
$items = [Activator]::CreateInstance($campaignType.GetProperty('TestPlanItems').PropertyType)
Set-Property $campaign 'TestPlanItems' $items
for($i=0; $i -lt $queries.Count; $i++) {
    $n = $i + 1
    $plan = [Activator]::CreateInstance($planType)
    Set-Property $plan 'WebService' 'LegacyDispatcherService.svc'
    Set-Property $plan 'Action' 'LocalOnly'
    Set-Property $plan 'DatabaseId' 'LOCAL_ONLY'
    Set-Property $plan 'Code' ("DATE_{0:00}" -f $n)
    Set-Property $plan 'RootPath' $fixture
    Set-Property $plan 'IsSelected' $true
    $testCases = [Activator]::CreateInstance($planType.GetProperty('TestCases').PropertyType)
    Set-Property $plan 'TestCases' $testCases
    $testCase = [Activator]::CreateInstance($caseType)
    Set-Property $testCase 'Id' ([Guid]::NewGuid())
    Set-Property $testCase 'Code' ("TC_DATE_{0:00}" -f $n)
    Set-Property $testCase 'Label' ("Date fixture {0:00}" -f $n)
    Set-Property $testCase 'Input' 'input.xml'
    Set-Property $testCase 'IsSelected' $true
    Set-Property $testCase 'IsValidated' $true
    Set-Property $testCase 'Owner' 'local-fixture'
    Set-Property $testCase 'OwnerTestPlan' $plan
    $preQueries = [Activator]::CreateInstance($caseType.GetProperty('PreDataQueries').PropertyType)
    Set-Property $testCase 'PreDataQueries' $preQueries
    $control = [Activator]::CreateInstance($controlType)
    Set-Property $control 'Id' ([Guid]::NewGuid())
    Set-Property $control 'Label' 'date prequery'
    Set-Property $control 'Query' $queries[$i]
    Set-Property $control 'IsValidated' $true
    Set-Property $control 'ExpectedValue' ([int]-1)
    Set-Property $control 'SqlExpectedValue' ''
    Set-Property $control 'OwnerTestCase' $testCase
    $preQueries.Add($control)
    $testCases.Add($testCase)
    $relative = "TestPlans\plan{0:00}.xml" -f $n
    $items.Add(([Activator]::CreateInstance($itemType)))
    Set-Property $items[$items.Count-1] 'Item' $relative
    Write-Xml $plan $basePlanType (Join-Path $plansDir ("plan{0:00}.xml" -f $n))
}
Write-Xml $campaign $campaignType (Join-Path $fixture 'campaign.xml')
