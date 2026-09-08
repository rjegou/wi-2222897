# Azure DevOps readback — 2026-09-08

Collecte REST authentifiée en lecture seule ; PAT non archivé. Requête ref : `_apis/git/repositories/60951ba6-fb32-4a61-9b7d-9df7b31d575c/refs?filter=heads%2Fsandbox%2Ffrenchtaxesrules%2Fapi-jmeter-fixes&$top=1000&api-version=7.1-preview.1`.

| Objet | Résultat | Limite |
|---|---|---|
| API ref | `refs/heads/sandbox/frenchtaxesrules/api-jmeter-fixes` → `9081ecfe7aa07f5e584073d2af1828d3ac9f7235` | FACT, une ref |
| Définition 2637 | AutoTest_Api CI, YAML `azure-pipelines.yml`, queue Azure Pipelines | FACT, définition partagée existante |
| Actifs 2637 | `0` | FACT, au moment de la lecture |
| Définition 2641 | AutoTest_Console CI, YAML `azure-pipelines.yml` | FACT |
| Actif 2641 | `4444888`, `inProgress`, branche Console sandbox | FACT, ressource collègue à ne pas perturber |
| Définition 2054 | FrenchTaxesRules CI, master, `/azure-pipelines.yml` | FACT, chaîne non isolée |
| Actif 2054 | `4423394`, `inProgress`, master | FACT, ne pas relancer/annuler |
| Définition 11454 | Y2_WebApps_FrenchTaxesRules_Jmeter | FACT, historique, pas V26 dédié |
| Actif 11454 | `0` | FACT |

La requête de round 2 qui omettait le préfixe `heads/` n'est pas une preuve de NOT_FOUND ; la requête corrigée ci-dessus établit la cause de la contradiction.
