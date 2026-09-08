# Audit transitif du candidat V26

## Références du candidat round 2

Le fichier `local-2026-09-08-v26-isolated-pipeline-round2/azure-pipelines.v26-isolated.candidate.yml` contient 18 références `template:`. Les références sont quatre groupes répétés, mais aucun des chemins `replay-assets/templates/` n'est présent sous le dossier de preuve ou dans un clone local. Verdict : **UNKNOWN**, chaîne non exécutable.

## Lot local hardened réutilisable

Les fichiers suivants ont été relus et hashés ; ils restent immuables :

| Fichier | SHA-256 | Provenance / verdict |
|---|---|---|
| `templates/task-deploy-in-containerized-job.candidate.yml` | `FE575F4E46CBFCA5750195ABED24EC89874A8A0DE369B476A4C150E95757E8CB` | copie locale, téléchargement + déploiement ; cible à attester |
| `templates/task-run-campaign.candidate.yml` | `96D5B6016C575B5DA68F23DCA9CFD0D30F59F01C04FE5181945EBFB4941043B7` | copie locale, JTL/JUnit ; pas de résultat métier |
| `templates/task-install-y2-test-tools.source.yml` | `0EFDD58D08E9342A01C58106AE5C5B113BCBA96394E714E695B6BD6DCB110857` | source workflow, dépend d'un template transitif non fourni |
| `templates/docker-pipeline-deploy.source.ps1` | `A92E7CF05F79868F11ABEAC6D72867AC021D3E319309A0A8B9D25B6815673C44` | source PlatformDeploy |
| `templates/docker-pipeline-deploy-ps7.source.ps1` | `79980805D74A6F09EA6B1D0914099F4FE2C1240C7692D7FE066946F0C80B961C` | source PlatformDeploy |

La présence de `JFrogGenericArtifacts@1` dans le template de déploiement prouve un téléchargement de dépendance, mais ne prouve ni la version PlatformDeploy résolue ni l'absence d'effets sur l'infrastructure. Aucun upload staging, promotion, tag ou TestAutos n'est accepté dans la chaîne isolée.
