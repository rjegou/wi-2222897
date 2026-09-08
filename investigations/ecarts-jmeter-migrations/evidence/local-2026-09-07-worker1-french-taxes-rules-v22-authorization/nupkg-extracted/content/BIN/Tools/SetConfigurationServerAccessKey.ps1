param ([string]$configfile = $(throw "-configfile is required."), [string]$accesskeyfile = $(throw "-accesskey is required."), [string]$hubname = $null)

function Concat-XmlNodes {
param (
    [xml] $doc = $(throw "doc is a required parameter"),
    [string] $xpath = $(throw "xpath is a required parameter"),
    [string] $value = $(throw "value is a required parameter")
)    
    $nodes = $doc.SelectNodes($xpath)
    Write-Host "xpath: $xpath"
    Write-Host "nodes: $nodes" 
    foreach ($node in $nodes)
    {
        Write-Host "node: $node"
        if ($node -ne $null)
        {
            if ($node.NodeType -eq "Element")
            {
                $node.InnerXml += $value
            }
            else
            {
                $node.Value += $value
            }
        }
    }
}

Write-Host "Configuration file : $configfile"
Write-Host "Access Key file: $accesskeyfile"

$document = [xml](Get-Content "$configfile")
$accesskey = Get-Content $accesskeyfile

Write-Host "Access key content: $accesskeycontent"

if (!$hubname)
{
    Write-Host "Hub name : <all>"
    Concat-XmlNodes $document -xpath "configuration/cegid.framework.services/hubs/hub/@rootConfigPath" -value "&accessToken=$accesskey"
}
else
{
    Write-Host "Hub name : $hubname"
    Update-XmlNodes $document -xpath "configuration/cegid.framework.services/hubs/hub[@name=""$hubname""]/@rootConfigPath" -value "&accessToken=$accesskey"
}

$document.Save("$configfile")