param
(
    [string]$configfile = $(throw "-configfile is required."),
    [string]$applicationplatform = $(throw "-applicationplatform is required."),
	[string]$filetype = $null,
	[string]$taskserver = $null
)

if (-Not $taskserver)
{
	$taskserver = "localhost"
}

# Ce fichier gère pour l'instant la mise à jour de configuration ERP pour le bilan de santé de la ferme (report/task):
# 'farmhealth' : Mise à jour des chemins de lecture de santé des hubs TaskScheduler et ReportService dans un fichier cegid.erp.services.cegidconfig (Section cegid.erp.services/legacyHost/health).
Write-Host "Configuration file : $configfile"
Write-Host "Configuration file type : $filetype"
Write-Host "Application platform : $applicationplatform"
Write-Host "Task server : $taskserver"

# Support de la spécification des fichiers de configuration à traiter par caractère wildcard ('*.exe.config' par exemple).
foreach ($selectConfigFile in (Get-Item "$configfile"))
{
	$document = [xml](Get-Content "$($selectConfigFile.FullName)")

	if ($filetype -eq 'farmhealth')
	{
        # Dans la balise de health déjà présente
		$health = $document.SelectSingleNode("configuration/cegid.erp.services/legacyHost/health")
        if ($health)
        {
            # suppression des legacyHost/health/TaskScheduler et des legacyHost/health/ReportService
            $health.RemoveAll()

            # Création de la configuration d'accès à l'uri HTTP de surveillance du task scheduler
            $task = $document.CreateElement("taskScheduler")
            $task.SetAttribute("protocol","Http")
            $child = $health.AppendChild($task)
            $hub = $document.CreateElement("remoteHubs")
            $child = $task.AppendChild($hub)
            $add = $document.CreateElement("add")
            $add.SetAttribute("location", "http://$($taskserver):8097/$applicationplatform/TaskScheduler")
            $child = $hub.AppendChild($add)

            # Création de la configuration d'accès à l'uri HTTP de surveillance du report service
            $report = $document.CreateElement("reportService")
            $report.SetAttribute("protocol","Http")
            $child = $health.AppendChild($report)
            $hub = $document.CreateElement("remoteHubs")
            $child = $report.AppendChild($hub)
            $add = $document.CreateElement("add")
            $add.SetAttribute("location", "http://$($taskserver):8097/$applicationplatform/ReportService")
            $child = $hub.AppendChild($add)
        }
	}

    # Enregistrement du fichier XML modifié
	$document.Save("$($selectConfigFile.FullName)")
}