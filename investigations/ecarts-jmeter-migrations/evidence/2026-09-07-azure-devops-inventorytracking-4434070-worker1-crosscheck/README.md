# InventoryTracking master — build 4434070 — contre-vérification worker 1

## Provenance

- Date : 2026-09-07 (Europe/Paris).
- Source ciblée : Azure DevOps `https://dev.azure.com/cegid`, projet `Retail`, build `4434070`.
- Collecte comparée : `../azure-devops-inventorytracking-2026-09-07-worker2/README.md` et `MANIFEST.csv`.
- Méthode worker 2 reprise sans secret : PAT lu en mémoire depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`, variable `AZURE_DEVOPS_EXT_PAT`, puis `az pipelines` / `az devops invoke`; aucune valeur de secret transmise en argument ou écrite.
- Portée worker 1 : lecture seule; aucun lancement, aucune écriture distante, aucun code modifié.

## Vérification indépendante

### FACT — méthode reprise, résultat non reproductible dans ce processus

Worker 1 a tenté `az devops invoke --area build --resource builds` sur `buildId=4434070`, avec `AZURE_DEVOPS_EXT_PAT` en mémoire et `AZURE_CONFIG_DIR` temporaire. Le processus n’a fourni aucune sortie exploitable avant son délai d’exécution. Une tentative REST .NET indépendante échoue avant HTTP pendant TLS Schannel avec : `Aucune information d’identification n’est disponible dans le package de sécurité`.

### FACT — profils temporaires inspectés sans contenu sensible

Les profils suivants ont été examinés uniquement par inventaire de fichiers, noms, tailles et modes :

- `C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897\.az-cli-4434070`
- `C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897\.az-cli-worker1-r2`

Aucun fichier de ces profils n’a été ouvert. Leur suppression native ciblée a été refusée par la politique d’exécution; ils sont signalés comme ressources temporaires à dépolluer.

### FACT — résultats rapportés par worker 2, non nouvellement prouvés ici

La collecte worker 2 rapporte : build `4434070` en échec sur la branche `InventoryTracking_Migration_AutoTest_Jmeter_On_master`, commit `4de185bb132cfbfb50643b6b53d6feb85508f4e2`; log 51 avec `MSB3245` sur `Cegid.Retail.XmlDiff`, puis quatre `CS0103` sur `XmlDiff` aux lignes 88, 159, 219 et 293; stages `TI Jmeter V26-Cur` et `TI Jmeter V26-Fix` ignorés. Elle rapporte également le master `4435986` réussi et le build `4402750` échoué sur `ManualValidation`.

Ces éléments restent **FACT de provenance worker 2**, mais **UNKNOWN pour la contre-vérification worker 1**, car les réponses primaires (métadonnées, timeline et log 51) ne sont pas présentes dans la collecte worker 2 et n’ont pas pu être relues indépendamment.

## Qualification

- **UNKNOWN** : preuve locale réexaminable des métadonnées, de la timeline complète, des extraits numérotés du log 51 et des logs de restauration; aucun contenu primaire n’a été obtenu.
- **INFERENCE conditionnelle** : si le contenu rapporté du log 51 est exact, `MSB3245` est la cause immédiate de non-résolution de `Cegid.Retail.XmlDiff`, et les quatre `CS0103` sont des conséquences de compilation dans le fichier de test. La cause racine de l’absence de résolution reste **UNKNOWN** (référence projet, package/restore ou template dépendance).
- Le succès de `Ensure_Docker_Image_Up_To_Date` rapporté par worker 2 ne permet pas d’attribuer le fail à l’image ACR.

## Limites et suite

La collecte ne copie aucun log, YAML ou réponse distante, car aucun flux primaire n’a été obtenu et les logs peuvent contenir des secrets. Pour fermer la contre-vérification, fournir les fichiers primaires exportés par worker 2 ou une session CLI fonctionnelle permettant de collecter log 51 avec numéros de lignes et les logs de restauration pertinents.
