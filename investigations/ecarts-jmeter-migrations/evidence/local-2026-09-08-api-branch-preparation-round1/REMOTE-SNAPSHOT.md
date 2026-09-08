# Snapshot distant borné

Collecte : 2026-09-08. Commandes read-only exécutées avec `az` et un PAT injecté uniquement
dans `AZURE_DEVOPS_EXT_PAT` pour le processus courant.

```text
az repos show --repository Y2_Tools_AutoTest_Api --org https://dev.azure.com/cegid --project Retail
az repos ref list --repository Y2_Tools_AutoTest_Api --project Retail \
  --filter heads/sandbox/frenchtaxesrules/api-jmeter-fixes
az pipelines build definition show --id 2637 --project Retail --org https://dev.azure.com/cegid
az pipelines build definition show --id 2641 --project Retail --org https://dev.azure.com/cegid
az pipelines runs list --pipeline 2637 --project Retail --top 10
az pipelines runs list --pipeline 11454 --project Retail --top 10
az repos policy list --repository 60951ba6-fb32-4a61-9b7d-9df7b31d575c \
  --branch sandbox/frenchtaxesrules/api-jmeter-fixes --project Retail
```

Résultats bornés :

- dépôt `Y2_Tools_AutoTest_Api` : `isDisabled=false`, branche par défaut `master`;
- branche demandée : présente, `objectId=220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`;
- définitions pertinentes : `AutoTest_Api CI` (`2637`), `AutoTest_Console CI` (`2641`),
  `Y2_WebApps_FrenchTaxesRules_Jmeter` (`11454`), toutes `queueStatus=enabled`;
- runs API visibles : dernier relevé `4311236`, `succeeded`, `master`, schedule, 2026-08-01;
- runs FrenchTaxesRules JMeter visibles : `4426188` à `4426188`, `failed`, `master`, schedule,
  2026-09-03;
- aucune queue, mutation, publication, commentaire, vote ou tag exécuté par cette collecte.

La lecture du YAML de branche via `az devops invoke` a confirmé `commitId=220de3d...` et le
contenu décrit dans `README.md`.
