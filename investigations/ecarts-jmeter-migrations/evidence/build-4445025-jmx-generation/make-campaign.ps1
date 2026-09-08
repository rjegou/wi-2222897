param([Parameter(Mandatory=$true)][string]$Base,[Parameter(Mandatory=$true)][string]$Name,[Parameter(Mandatory=$true)][string]$ModelPath)
$asm=[Reflection.Assembly]::LoadFrom($ModelPath)
$ns='Cegid.Retail.AutoTest.Model'
$ct=$asm.GetType("$ns.TestCampaign")
$it=$asm.GetType("$ns.TestPlanItem")
function Set-Prop($o,[string]$n,$v){$o.GetType().GetProperty($n).SetValue($o,$v,$null)}
$c=[Activator]::CreateInstance($ct)
Set-Prop $c 'Code' $Name
Set-Prop $c 'Comment' 'WI-2222897 isolated generation'
Set-Prop $c 'Categories' ''
$items=[Activator]::CreateInstance($ct.GetProperty('TestPlanItems').PropertyType)
Set-Prop $c 'TestPlanItems' $items
$item=[Activator]::CreateInstance($it)
Set-Prop $item 'Item' ("TestPlans\$Name.xml")
$items.Add($item)
$path=Join-Path $Base "IntegratedTests\AutoTest\Data\$Name\$Name.xml"
$settings=[Xml.XmlWriterSettings]::new(); $settings.Encoding=[Text.UTF8Encoding]::new($false); $settings.Indent=$true
$writer=[Xml.XmlWriter]::Create($path,$settings)
try { $serializer=[Xml.Serialization.XmlSerializer]::new($ct); $serializer.Serialize([Xml.XmlWriter]$writer,[object]$c) } finally { $writer.Dispose() }
Write-Output $path
