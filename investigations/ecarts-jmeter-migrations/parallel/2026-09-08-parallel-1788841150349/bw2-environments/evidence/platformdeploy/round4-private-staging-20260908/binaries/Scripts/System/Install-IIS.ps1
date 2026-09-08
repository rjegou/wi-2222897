# File: Install-IIS.ps1
# Script to enable and configure IIS feature
#
# 2022-03-02 : template creation

#Requires -Version 7.6
#Requires -RunAsAdministrator

Import-Module ServerManager
# WebAdministration is intentionally kept here for IIS bootstrap only (Stop-WebSite, Set-WebBinding,
# Set-WebConfigurationProperty). These cmdlets operate before any IIS site or application pool exists,
# so IISAdministration's ServerManager API cannot yet be used. All post-install IIS management
# (application pools, SSL bindings, web.config) uses IISAdministration exclusively.
Import-Module WebAdministration

# --- Ajout des composants IIS 8.0 requis
Install-WindowsFeature Web-server, Web-WebServer, Web-Common-Http, Web-Static-Content, Web-Default-Doc, Web-Http-Redirect, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Windows-Auth, Web-Asp-Net45, Web-Net-Ext45, Web-AppInit, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Scripting-Tools, Web-Mgmt-Service

Remove-WindowsFeature Web-Dir-Browsing

# --- Ajout de la partie ASP. Net 4.5
Install-WindowsFeature NET-Framework-45-ASPNET, NET-WCF-HTTP-Activation45, NET-WCF-TCP-Activation45

# --- Arret du site par défaut
Stop-WebSite -Name "Default Web Site"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -Filter "system.applicationHost/sites/site[@name='Default Web Site']" -Name "serverAutoStart" -Value $False

# --- Configuration du site par défaut sur le port TCP 81
Set-WebBinding -Name 'Default Web Site' -BindingInformation "*:80:" -PropertyName Port -Value 81

# --- Compression Dynamique reglé à 4 à la base de IIS
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/httpCompression/scheme[@name='gzip']" -Name "dynamicCompressionLevel" -Value 4

# --- Off des Logs de connexions
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/httpLogging" -Name "dontLog" -Value "True"
