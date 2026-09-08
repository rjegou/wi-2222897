# Provenance détaillée

| Élément | Identifiant / chemin | Portée | Statut |
|---|---|---|---|
| Build analysé | Azure DevOps `4432602` | Clienteling V22/V23 | snapshot local, non revalidé live |
| YAML source | `sources/Y2_Plugins_Clienteling-v6-build-4432602/azure-pipelines.yml` lignes 88-90, 311 | repo externe + sélection `lastV5` | FACT local |
| Template PlatformDeploy | `worktrees/Y2_Tools_PlatformDeploy/Src/PipelineTemplates/task-deploy-in-containerized-job.v2.yml` lignes 80-116 | recherche `PlatformDeploy.5.*`, extraction et contrôle de gamme | FACT local; checkout propre |
| Propagation MSI | `worktrees/Y2_Tools_PlatformDeploy/Src/Powershell/Code/Scripts/Lib/install-y2msi.ps1` lignes 86-97; `install-packages.ps1` lignes 247-250 | code attendu des MSI et exception agrégée | FACT statique; raccord au build UNKNOWN |
| MSI V22/V23 | `evidence/build-4432602/_extracted/v22-Fix_Deployment_logs...`, `v23-Fix_Deployment_logs...` | retours 1603 et versions produit | FACT daté du snapshot |
| Packages téléchargés | `downloadedPackages.json` dans les quatre dossiers Cur/Fix | versions Y2, sans PlatformDeploy | FACT local |
| Accès distant | API REST Azure DevOps, 2026-09-07 | lecture build/timeline tentée, échec authentification | UNKNOWN distant |
| Test transport fixtures | `fixture-transport-check.ps1`, exécuté localement le 2026-09-07 | onze fixtures historiques, snapshot, placeholder et résolution factice | FACT local; IIS final UNKNOWN |
