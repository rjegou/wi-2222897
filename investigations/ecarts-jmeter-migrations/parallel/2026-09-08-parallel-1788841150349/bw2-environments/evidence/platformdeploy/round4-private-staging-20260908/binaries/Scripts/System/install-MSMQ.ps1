# File: install-MSMQ.ps1
# Script to enable and configure MSMQ feature
#
# 2022-03-02 : template creation

#Requires -Version 7.6
#Requires -RunAsAdministrator

function InstallMSMQFeaturesOnServer()
{
    # Import du module ServerManager.
    Import-Module servermanager
    # ajout des features MSMQ necessaire au fonctionnement du ReportService
    Add-WindowsFeature MSMQ, MSMQ-Services, MSMQ-Server, MSMQ-Multicasting
    if (IsInDomain)
    {
        Add-WindowsFeature MSMQ-Directory
        Add-WindowsFeature MSMQ-Routing
    }
    else
    {
        Write-Warning "computer is not in domain :MSMQ-Directory, MSMQ-Routing cannot be installed"
    }
}

function IsInDomain
{
    if ((Get-CimInstance win32_computersystem).partofdomain -eq $true)
    {
        return $true
    }
    else
    {
        return $false
    }
}

InstallMSMQFeaturesOnServer