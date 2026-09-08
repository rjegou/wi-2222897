param
(
    [string]$configfile = $(throw "-configfile is required."),
    [string]$applicationplatform = $(throw "-applicationplatform is required."),
	[string]$platformcomponent = $(throw "-platformcomponent is required."),
	[string]$filetype = $null
)

# Ce fichier gère pour l'instant la mise à jour de configuration FRAMEWORK pour le bilan de santé de la ferme (report ou task):
# 'monitoring' : Mise à jour du protocole, du port et du chemin utilisés pour l'écoute du service de health
Write-Host "Configuration file : $configfile"
Write-Host "Configuration file type : $filetype"
Write-Host "Application platform : $applicationplatform"
Write-Host "Platform component : $platformcomponent"

# Support de la spécification des fichiers de configuration à traiter par caractère wildcard ('*.exe.config' par exemple).
foreach ($selectConfigFile in (Get-Item "$configfile"))
{
	$document = [xml](Get-Content "$($selectConfigFile.FullName)")
    if ($document)
    {
    	if ($filetype -eq 'monitoring')
	    {
            # Dans la balise de health déjà présente: modification du protocole, du port et du chemin
		    $health = $document.SelectSingleNode("configuration/cegid.framework.services/monitoring/remote")
		    if ($health)
		    {
                $health.SetAttribute("protocol","Http")
                $health.SetAttribute("port","8097")
                $health.SetAttribute("path","$applicationplatform/$platformcomponent")
            }
	    }

        # Enregistrement du fichier XML modifié
	    $document.Save("$($selectConfigFile.FullName)")
    }
}