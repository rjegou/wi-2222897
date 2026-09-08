# Param(
#     [parameter (Mandatory = $true, HelpMessage = "Release du plugin; Exemple : master, V1, V2 ...")]
#     [string] $Release
# )


#IntegrationTestsLauncher.exe "cgddskl03955" "Y2_Plugins_SalesConditionsPOC" ATR.test.20200102_3 "-D:projectY2Core.RevisionSvn=123456" test
# -------------------------------------
Import-Module d:\CegidUtils\CegidIntegrationTests\override\CommonTargets\IntegrationTestEnvironment\Scripts\Uses\functions.ps1 -Force
Import-Module d:\CegidUtils\CegidIntegrationTests\override\CommonTargets\\IntegrationTestEnvironment\Scripts\Uses\Artifactory_fct.ps1 -Force

try {
    $xmlFileAppSetting = "\\cbr-cptx-auto\TestAutoNotifications\TestAuto.AppSettings.xml"
    # $appnode="/appSettings/ConfigTreatments/Treatments"
    #$xml=GetElement_XML "$xmlFileAppSetting" "$appnode"
    $xml = [xml](Get-Content $xmlFileAppSetting)
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription];
    $ArrayAlpha = @("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
    # --------------------------------------

    #Choix du plugin
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $message = "Exécution des tests automatique "
    $question = "Quel est le projet ? "
    $treatmentList = $xml.appSettings.ConfigTreatments.Treatments | Select-Object Treatment
    $ArrayTreatment = @()
    $i = 0
    foreach ($_treatment in $treatmentList.Treatment) {
        # uniquement les plugins
        if (($_treatment.name -ne "DashBoard") -and ($_treatment.name -ne "CrossBranch") -and ($_treatment.name -ne "Core") -and ($_treatment.name -ne "SmartProxy") -and ($_treatment.name -ne "HistoryReport")) {
            $val = "&" + $ArrayAlpha[$i] + "." + $_treatment.name
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList $val)) #0
            $i++
            $ArrayTreatment += $_treatment.name
        }
    }
    $TreatmentChoice = $Host.UI.PromptForChoice($message, $question, $choices, 0)	
    $PluginName = $ArrayTreatment[$TreatmentChoice]

    #Choix du serveur
    $message = "Exécution des tests automatique "
    $question = "Quel est le serveur "

    $hostname = $xml.SelectNodes("/appSettings/ConfigTreatments/Treatments/Treatment[@name='$PluginName']").servername
    Write-Host
    Write-Host "Exécution des tests sur le serveur : $hostname" -ForegroundColor Green
    Write-Host

    #Choix de la version du plugin
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $message = "Exécution des tests automatique "
    $question = "Quel est la version du plugin : $PluginName ? "
    $releaseList = $xml.SelectNodes("/appSettings/ConfigTreatments/Treatments/Treatment[@name='$PluginName']/Levels") | Select-Object Level
    $ArrayRelease = @()
    $i = 0
    foreach ($_version in $releaseList.Level) {
        if ($ArrayRelease.IndexOf($_version.release) -eq -1) {
            $val = "&" + $ArrayAlpha[$i] + "." + $_version.release
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList $val)) #0
            $i++
            $ArrayRelease += $_version.release
        }
    
    }
    $ReleaseChoice = $Host.UI.PromptForChoice($message, $question, $choices, 0)	
    $Release = $ArrayRelease[$ReleaseChoice]

    #Choix de la version
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $message = "Exécution des tests automatique "
    $question = "Quel est la version du projet : $PluginName ? "
    $versionList = $xml.SelectNodes("/appSettings/ConfigTreatments/Treatments/Treatment[@name='$PluginName']/Levels/Level[@release='$Release']") | Select-Object name -First 1

    $versionCore = $versionList.name
    #nom du serveur
 
    #nom du projet
    $workflow = "Y2_Plugins_{0}_{1}" -f $PluginName, $Release;

    $arguments = @();

    #Version du plugin
    # [version]$versionCore="20.0";
    $vplgFind = findPluginLastModifiedArchive -PluginName $PluginName -Repository "retail-software-staging" -CoreVersion $versionCore -returnValueType "version";
    $buildVersion = $vplgFind.Replace("Y2.Plugin.$PluginName.", "").Replace("$versionCore.", "");
    # $vplg="2.41";

    $arguments += "-D:Y2_Plugin.VersionUsed=$buildVersion";

    #version du projet
    $user = ($env:UserName).Trim();
    if ($user -eq '') {	
        $user = "MAN";
    }
    $iteration = "{2}.test.{0}-{1}" -f $buildVersion, (Get-Date -Format "yyyyMMdd_hhms"), $user;

    $argumentsSpec = @();

    $targetExe = "execute.plugin";
    executeIntegrationTest -Hostname $hostname -ProjectBuildName $workflow -BuildVersion $iteration -Parameters $arguments -targetToExecute $targetExe -argumentsSpec ($argumentsSpec -join ",");
}
catch
{
    Write-Error -Message $_.Exception
}
finally {
}