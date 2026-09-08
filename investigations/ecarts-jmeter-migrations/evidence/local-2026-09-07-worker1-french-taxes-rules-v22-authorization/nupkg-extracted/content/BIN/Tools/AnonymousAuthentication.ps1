# **************************************************************************************************************************************
# *** OUTILS
# **************************************************************************************************************************************

Function ElevateIfNot($commandDefinition, $commandArguments)
{
    $currentWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent() 
    $windowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($currentWindowsID)   
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    if (-not $windowsPrincipal.IsInRole($adminRole))    
    {
		foreach ($commandArgument in $commandArguments)
		{
			$commandArgumentString = $commandArgumentString + " " + $commandArgument;
		}
        $newProcess = new-object System.Diagnostics.ProcessStartInfo "powershell";
        $newProcess.Arguments = " -File " + $commandDefinition + " " + $commandArgumentString;
        $newProcess.Verb = "runas";
        [System.Diagnostics.Process]::Start($newProcess);
        Exit;
    }
}

# **************************************************************************************************************************************
# *** SCRIPT PRINCIPAL
# **************************************************************************************************************************************

# Elévation de privilège.
ElevateIfNot $myInvocation.MyCommand.Definition $args

# Import du module IIS.
Import-Module WebAdministration

$site = $args[0];
$application = $args[1];
Write-Host "Web site : '$site'";
Write-Host "Web application : '$application'";

# On active l'authentification anonyme sur le site.
$siteLocation = $site + "/" + $application;
Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/anonymousAuthentication -name enabled -value $true -PSPath IIS:\ -Location $siteLocation