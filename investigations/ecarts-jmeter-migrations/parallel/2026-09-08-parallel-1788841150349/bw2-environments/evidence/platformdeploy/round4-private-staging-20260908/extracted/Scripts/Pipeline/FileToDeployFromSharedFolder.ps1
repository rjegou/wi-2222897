#Get file to upload from shared folder
# Used on azure-deploy-pipeline.yml

#Requires -Version 7.6

param (
    [Parameter(Mandatory = $true)]
    [string]
    $SharedFolder # Path containing the edployment fi to upload
)

if ( $TRUE -eq (Test-Path -Path "$SharedFolder") )
{
    $files = Get-ChildItem -Path "$SharedFolder" -Filter *.cy2px
    if (($NULL -eq $files))
    {
        $msg = "Folder $SharedFolder doesn't contain .cy2px files"
        Write-Host "##[error] $msg"
        throw $msg
    }
    if ($files.count -gt 1)
    {
        $msg = "Folder $SharedFolder contain more than one .cy2px file"
        Write-Host "##[error] $msg"
        throw $msg
    }
    return $files[0]
}
else
{
    $msg = "Folder $SharedFolder not found !"
    Write-Host "[error] $msg"
    throw $msg
}
