REM --- Ajout des composants IIS 8.0 requis
dism /online /enable-feature /featurename:IIS-WebServerRole /featurename:IIS-WebServer /featurename:IIS-CommonHttpFeatures /featurename:IIS-StaticContent /featurename:IIS-DefaultDocument /featurename:IIS-HttpRedirect /featurename:IIS-Performance /featurename:IIS-HttpCompressionStatic /featurename:IIS-HttpCompressionDynamic /featurename:IIS-Security /featurename:IIS-RequestFiltering /featurename:IIS-WindowsAuthentication /featurename:IIS-ASPNET45 /featurename:IIS-WebServerManagementTools /featurename:IIS-ManagementScriptingTools /featurename:IIS-ManagementConsole /featurename:IIS-ManagementService /featurename:IIS-ApplicationInit /ALL

dism /online /disable-feature /featurename:IIS-DirectoryBrowsing /featurename:IIS-HttpLogging

REM --- Ajout de la partie ASP. Net 4.5
dism /online /enable-feature /featurename:IIS-NetFxExtensibility45 /featurename:IIS-ISAPIFilter /featurename:IIS-ISAPIExtensions /featurename:IIS-ASPNET45 /featurename:WCF-HTTP-Activation45 /featurename:WCF-TCP-Activation45 /ALL

REM --- Arret du site par défaut
REM ---
%windir%\System32\inetsrv\appcmd stop SITE "Default Web Site"
%windir%\System32\inetsrv\appcmd set SITE "Default Web Site" /serverautostart:false

REM --- Configuration du site par défaut sur le port TCP 81
REM ---
%windir%\System32\inetsrv\appcmd set SITE "Default Web Site" /-bindings:http/*:80
%windir%\System32\inetsrv\appcmd set SITE "Default Web Site" /+bindings.[protocol='http',bindingInformation='*:81:']

REM --- Compression Dynamique reglé à 4 à la base de IIS
REM ---
%windir%\System32\inetsrv\appcmd.exe set config -section:system.webServer/httpCompression /[name='gzip'].dynamicCompressionLevel:"4" /commit:apphost
