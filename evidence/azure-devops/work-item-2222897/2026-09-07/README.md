# Collecte Azure DevOps — WI 2222897 — 2026-09-07

## Portée

Collecte en lecture seule du work item `2222897` et de ses relations, demandée pour établir les postconditions restantes après le diagnostic InventoryTracking. Aucun pipeline, PR, commentaire, branche ou autre ressource distante n'a été modifié.

## Provenance

- Date de collecte : 2026-09-07, Europe/Paris.
- Système visé : Azure DevOps `https://dev.azure.com/cegid`, projet `Retail`.
- Identifiant : work item `2222897`.
- Méthodes essayées : Azure CLI avec `AZURE_DEVOPS_EXT_PAT` et profil isolé local ; API REST `/_apis/wit/workitems/2222897` et `/relations` ; `curl.exe` TLS 1.2.
- Secret : le PAT a été lu uniquement en mémoire/processus depuis le chemin autorisé. Sa valeur n'est pas présente dans cette collecte.
- Fraîcheur : aucune réponse Azure DevOps obtenue ; les fichiers JSON vides sont des sorties d'échec, pas des snapshots d'état.

## Résultat

Cette tentative locale reste bloquée (`PermissionError` sur `azureProfile.json`, installation dynamique de l’extension dans le profil isolé, puis Schannel `SEC_E_NO_CREDENTIALS`). Elle est supersédée pour les faits Azure DevOps par la collecte primaire réussie de Worker 2 : `investigations/ecarts-jmeter-migrations/evidence/azure-devops-inventorytracking-2026-09-07-worker2/`.

Cette preuve établit que `4434070` est une branche de migration (`refs/heads/InventoryTracking_Migration_AutoTest_Jmeter_On_master`), pas `refs/heads/master`. Elle localise l’échec immédiat au build des tests sur la référence `Cegid.Retail.XmlDiff` non résolue, avec quatre erreurs `CS0103`; les stages JMeter sont skipped. La raison amont de la non-résolution (package/restore/template effectivement consommé) reste `UNKNOWN`.

Le build master `4435986` réussi ne clôt pas la migration : son YAML ne déclare pas `TI_Jmeter_V26` et correspond à l’ancien pipeline build/publish/TestAutos. L’état live des PR InventoryTracking n’a pas été obtenu dans cette reprise CLI; aucune PR ne doit être déduite de l’absence de résultat local.

## Fichiers

| Fichier | Portée |
|---|---|
| `work-item-2222897.json`, `relations.json` | sorties CLI vides après échec d'extension/profil |
| `work-item-2222897-rest.json`, `relations-rest.json` | non créés : échec TLS avant réponse |
| `collection-status*.txt` | marqueurs techniques des tentatives |
| `postconditions-matrix.md` | synthèse locale des postconditions et prochaines actions, mise à jour avec la preuve Worker 2 |
| `cli-r2/` | nouvelle tentative CLI de WI/relations/PR; sorties non exploitables après installation dynamique dans profil isolé |

## Limites et reprise sûre

Une reprise doit fournir une session Azure DevOps autorisée ou une exportation JSON contenant le work item avec relations, puis collecter en lecture seule le build `4434070`, sa timeline, le premier log causal, les YAML/templates au commit exact et le build `master` le plus récent. Ne pas requalifier les lignes du bilan intermédiaire comme live sans ces preuves.
