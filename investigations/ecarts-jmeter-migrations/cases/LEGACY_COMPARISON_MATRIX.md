# Matrice de comparaison legacy ↔ JMeter

Collectes Azure DevOps du 2026-09-05 et preuves aval récupérées sur Y2-TSTAUTOXXPG2 le 2026-09-06. Un `UnitTestResult` MSTest est une preuve d'exécution legacy. **La question de cette matrice est l'écart entre les deux chemins : un test case qui échoue aussi en legacy avec la même postcondition ou la même signature est un échec commun et ne met pas l'outil de migration en cause.** Un nom de scénario et un résultat identiques ne suffisent pas à qualifier une régression si le package, le backup, le payload/assertion ou l'environnement diffèrent ; inversement, un écart de migration exige une différence propre à JMeter démontrée à contrat comparable.

## Master V26 — correspondance scénario par scénario

| Plugin | Variante legacy | Package legacy | Plan/TestCase | Résultat legacy | Résultat JMeter Fix | Comparabilité | Verdict | Preuve |
|---|---|---|---|---|---|---|---|---|
| FrenchTaxesRules | Fix SQL | `26.0.10.25` | `Export_Run` TC08 | `Passed` | non passé, build 4432510 | Même identifiant et description ; plugin JMeter `26.0.10.75`, backup/hôte non rapprochés | UNKNOWN — pas de régression JMeter démontrée | TRX local Fix, `UnitTestResult` `Export_Run/Test_08` ; CSV `build-4432510/.../v26-Fix_LegacyServices...-errors.csv` |
| FrenchTaxesRules | Fix SQL | `26.0.10.25` | `Export_Run` TC09 | `Passed` | non passé, cascade de TC08 | Même identifiant ; ordre/donnée résiduelle JMeter, package et backup différents | UNKNOWN — pas de régression JMeter démontrée | même TRX, `Export_Run/Test_09` ; finding 001 |
| FrenchTaxesRules | Fix SQL | `26.0.10.25` | `Export_Run` TC10 | `Passed` | non passé, cascade de TC08 | Même identifiant ; ordre/donnée résiduelle JMeter, package et backup différents | UNKNOWN — pas de régression JMeter démontrée | même TRX, `Export_Run/Test_10` ; finding 001 |
| FrenchTaxesRules | Fix SQL | `26.0.10.25` | `FrenchTaxesRules_Run` TC22 | `Failed`, `Expected 2 / Actual 1`, DAEMON | non passé, C-PostQuery1 retourne `1` au lieu de `2` | Même scénario, même postcondition et même signature ; package et backup différents | FACT — échec aussi observé en legacy ; cause fonctionnelle UNKNOWN ; pas un cas legacy vert/JMeter rouge | même TRX, `FrenchTaxesRules_Run/Test_22`; JMX `../sources/Y2_Plugins_FrenchTaxesRules/Tests/LegacyServices/009-FrenchTaxesRules_Run.jmx` |
| FrenchTaxesRules | Fix SQL | `26.0.10.25` | `Validation_ValidateClosingsV2` TC99 | `Passed` | non passé, HTTP 500 / `CBR_062_0005` | Même identifiant/description « Pour debug » ; comportement, package et environnement non rapprochés | UNKNOWN — pas de régression JMeter démontrée | même TRX, `Validation_ValidateClosingsV2/Test_99` ; finding 001 |
| FrenchTaxesRules | Fix SQL | `26.0.10.25` | `Validation_ValidateDocuments` TC99 | `Passed` | non passé, HTTP 500 / `CBR_062_0005` | Même identifiant/description « Pour debug » ; comportement, package et environnement non rapprochés | UNKNOWN — pas de régression JMeter démontrée | même TRX, `Validation_ValidateDocuments/Test_99` ; finding 001 |
| Clienteling | Fix SQL | `26.0.10.18` | 485 couples plan/TestCase non passés sous JMeter | 484 `Passed`, 1 `Failed` | 485 non passés, build 4432554 | 485/485 identifiants retrouvés ; Core Fix `26.0.0.1762` commun ; plugin JMeter `26.0.10.23`, backup et hôte différents | UNKNOWN pour les 484 legacy verts ; exception ci-dessous | TRX local Fix ; inventaire exhaustif compact dans `../evidence/LEGACY_TEST_INVENTORY.md` |
| Clienteling | Fix SQL | `26.0.10.18` | `SaleAndSellers_CreateReceipt` TC32 | `Failed`, `Expected 1 / Actual 0`, « check champ utilisateur 2 » | non passé, même requête `MCHPSUTILISATDATA` et `0` au lieu de `1` | Même scénario, requête, assertion et signature ; package et backup différents | FACT — échec aussi observé en legacy ; cause fonctionnelle UNKNOWN ; pas un cas legacy vert/JMeter rouge | même TRX, `SaleAndSellers_CreateReceipt/Test_32`; JMX `../sources/Y2_Plugins_Clienteling-master-build-4432554-exact/Tests/WebServices/113-SaleAndSellers_CreateReceipt.jmx` |

Le TRX FrenchTaxesRules contient 253 scénarios élémentaires (252 `Passed`, 1 `Failed`) ; le TRX Clienteling en contient 2 131 (2 130 `Passed`, 1 `Failed`). Les compteurs globaux plus élevés incluent les conteneurs `orderedtest` et ne doivent pas être additionnés aux `UnitTestResult`.

Preuves TRX exactes :

- `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544_Y2_Plugin_Fix_sql.trx` ;
- `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_Clienteling_master_26.0.test.10.18-20260804_031847_Y2_Plugin_Fix_sql.trx`.

## Branches de release — exécution réellement prouvée

| Plugin / branche | Captures locales | Ce qui a réellement été exécuté | Verdict pour les JMeter visés |
|---|---|---|---|
| FrenchTaxesRules V5 | `test.6.473`, `test.6.480` | Workflow démarré, puis arrêt avant MSTest : dossier `override\Y2_Plugins_FrenchTaxesRules_V5` absent ; zéro scénario exécuté | UNKNOWN — aucune baseline V21-V23 comparable |
| FrenchTaxesRules V7 | `test.9.17`, `.19`, `.20` | Workflow démarré, puis même arrêt avant MSTest ; zéro scénario exécuté | UNKNOWN — aucune baseline V25 comparable ; ces captures ne sont pas l'itération `.25` corrélée au build 4429632 |
| Clienteling V6 | aucun rapport d'exécution dans l'index | Configurations/fixtures seulement ; aucune exécution prouvée | UNKNOWN — aucune baseline V22-V23 comparable |
| Clienteling V7 | `test.7.317`, `.319`, `.321`, `.323`, `.328` | Cinq fichiers XML présents mais vides (zéro octet) ; aucun scénario ni résultat lisible | UNKNOWN — aucune baseline V24 comparable ; aucune preuve pour l'itération `.326` |
| Clienteling V8 | `test.9.12`, `.13`, `.18` | Workflow démarré, puis arrêt avant MSTest : dossier `override\Y2_Plugins_Clienteling_V8` absent ; zéro scénario exécuté | UNKNOWN — aucune baseline V25 comparable ; ces captures ne sont pas l'itération `.22` corrélée au build 4432675 |

Les anciens Test Runs restent utiles : FrenchTaxesRules `4429632/6178203` contient 82 tests passés et `4429170` vingt tests passés, mais sans correspondance démontrée avec les scénarios JMeter. Les TRX VSTest Clienteling des builds `4432556`, `4432608`, `4432653` et `4432675` restent vides. Ces constats amont ne contredisent pas le TRX aval master V26 récupéré : ils portent sur des mécanismes et des itérations différents.

## Conclusion

FACT — les preuves aval établissent maintenant le résultat legacy des 491 cas V26 JMeter non passés : 489 passent dans les TRX legacy, deux échouent déjà avec la même postcondition. Pour ces deux cas, l'échec commun écarte l'hypothèse d'un défaut de migration sur la base des preuves actuelles et impose une recherche de cause commune. INFERENCE — les 489 différences justifient des tests de comparabilité ciblés, en priorité sur les familles encore `UNKNOWN`, mais ne sont pas encore des régressions de migration. UNKNOWN — aucune n'atteint encore le seuil `CANDIDAT ÉCART DE MIGRATION`, faute de package et de backup identiques et d'environnement suffisamment rapproché. Pour les releases, aucune capture branch-specific n'établit une exécution de scénario comparable.

## Trace `TestAutos` — verdict par build

| Plugin | Build / commit | Soumission observée | Résultat aval | Preuve exacte |
|---|---|---|---|---|
| FrenchTaxesRules | `4432288` / `07a42172bebc65d17093e166ac08de22e4fe7248` | workflow `Y2_Plugins_FrenchTaxesRules_master`, corrélation `162`, log `137` | UNKNOWN — workflow externe ou preuve inaccessible | `evidence/legacy-build-4432288/logs/build-log-137.txt`, `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml` |
| FrenchTaxesRules | `4429632` / `4fdc84f70c869293711201416e195d1a36984472` | workflow `Y2_Plugins_FrenchTaxesRules_V7`, corrélation `66`, log `108` | UNKNOWN — workflow externe ou preuve inaccessible | `evidence/legacy-build-4429632/logs/build-log-108.txt`, `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml` |
| FrenchTaxesRules | `4432320` / commit conservé dans `build.json` | aucune soumission `TestAutos` dans la timeline conservée | FACT — aucune soumission publiée dans la timeline vérifiée ; UNKNOWN — autre mécanisme éventuel | `evidence/legacy-build-4432320/timeline.json` |
| FrenchTaxesRules | `4432365` / commit conservé dans `build.json` | aucune soumission `TestAutos` dans la timeline conservée | FACT — aucune soumission publiée dans la timeline vérifiée ; UNKNOWN — autre mécanisme éventuel | `evidence/legacy-build-4432365/timeline.json` |
| FrenchTaxesRules | `4429170` / `1a34bcd2dc5d47a871ad330d82aff661934098bd` | phase `TestAutos` skipped | FACT — étape skipped ; UNKNOWN — autre exécution aval éventuelle | `evidence/legacy-build-4429170/timeline.json` |
| Clienteling | `4432556` / `0c0fd26533e46b13e029276f90b5c085c1804012` | workflow `Y2_Plugins_Clienteling_master`, corrélation `226`, log `94` | UNKNOWN — workflow externe ou preuve inaccessible | `evidence/legacy-build-4432556/logs/build-log-94.txt`, `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml` |
| Clienteling | `4432608` / `1b29b27aa3d899a39d2628f849b6643340de6a31` | phase `TestAutos` skipped ; aucun identifiant | FACT — étape skipped ; UNKNOWN — autre exécution aval éventuelle | `evidence/legacy-build-4432608/timeline.json` |
| Clienteling | `4432653` / `1abc22e57cf1c04557b146a42bfd1b822221c2b6` | workflow `Y2_Plugins_Clienteling_V7`, corrélation `227`, log `101` | UNKNOWN — workflow externe ou preuve inaccessible | `evidence/legacy-build-4432653/logs/build-log-101.txt`, `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml` |
| Clienteling | `4432675` / `78902d855738d3736b4338aa835e7ef95829afbf` | workflow `Y2_Plugins_Clienteling_V8`, corrélation `228`, log `102` | UNKNOWN — workflow externe ou preuve inaccessible | `evidence/legacy-build-4432675/logs/build-log-102.txt`, `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml` |

Le template ne prévoit aucun mécanisme de récupération aval. La recherche des corrélations et l'accès read-only au système `Y2-TSTAUTOXXPG2:8181/integrationlauncher` n'ont fourni aucun statut final, log ou résultat supplémentaire.
