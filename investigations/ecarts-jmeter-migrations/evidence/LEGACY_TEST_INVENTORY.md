# Inventaire des tests legacy — collectes des 2026-09-05 et 2026-09-06

## Règle d'interprétation

Un TRX MSTest est une preuve de tests legacy et ne doit pas être écarté parce qu'il ne contient pas de campagne JMeter. La comparabilité se décide au niveau du contrat testé, des entrées, des sorties et de l'environnement, pas au nom du framework.

Les fichiers `*.trx` ont été téléchargés depuis les attachments Azure DevOps indiqués par l'API Test Runs. Les réponses `build.json`, `timeline.json`, `test-runs.json`, les détails de Test Run, les attachments et `SHA256SUMS.txt` sont conservés dans chaque dossier `evidence/legacy-build-<BuildId>/`.

Les deux TRX aval ajoutés le 2026-09-06 proviennent directement des rapports publiés de Y2-TSTAUTOXXPG2, et non des attachments des Test Runs Azure DevOps. Ils sont conservés sans modification sous `../evidence/legacy/raw/missing-supplement/PublishedReports/`.

## Scénarios V26 JMeter non passés retrouvés dans les TRX legacy aval

### FrenchTaxesRules master — Fix SQL 26.0.10.25

Le TRX contient 253 `UnitTestResult` : 252 `Passed` et 1 `Failed`. Les six identifiants plan/TestCase non passés sous JMeter Fix dans le build 4432510 sont tous présents.

| Plan/TestCase | Résultat legacy | Résultat JMeter | Verdict borné |
|---|---|---|---|
| `Export_Run` TC08 | `Passed` | non passé | UNKNOWN — plugin `26.0.10.25` contre `26.0.10.75`, backup/hôte non rapprochés |
| `Export_Run` TC09 | `Passed` | non passé, cascade de TC08 | UNKNOWN — même identifiant, mais état préalable et environnement non comparables |
| `Export_Run` TC10 | `Passed` | non passé, cascade de TC08 | UNKNOWN — même identifiant, mais état préalable et environnement non comparables |
| `FrenchTaxesRules_Run` TC22 | `Failed`, `Expected 2 / Actual 1`, DAEMON | non passé, même postcondition retourne `1` au lieu de `2` | FACT — même échec observable en legacy ; cause fonctionnelle UNKNOWN ; pas un cas legacy vert/JMeter rouge |
| `Validation_ValidateClosingsV2` TC99 | `Passed` | non passé, HTTP 500 / `CBR_062_0005` | UNKNOWN — contrat, package et environnement non suffisamment rapprochés |
| `Validation_ValidateDocuments` TC99 | `Passed` | non passé, HTTP 500 / `CBR_062_0005` | UNKNOWN — contrat, package et environnement non suffisamment rapprochés |

Preuve exacte : `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544_Y2_Plugin_Fix_sql.trx`, SHA-256 `25768CC10F28BB74E1A7893F813D6D97F12C8FBA956D8B3338BF223EEDD7BA4B`. Le XML d'exécution frère `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544.xml` établit Fix, SQL, plugin `26.0.10.25`, Core Fix `26.0.0.1762` et le filtre MSTest `!BDD` appliqué aux conteneurs orderedtest.

### Clienteling master — Fix SQL 26.0.10.18

Le TRX contient 2 131 `UnitTestResult` : 2 130 `Passed` et 1 `Failed`. Après normalisation réversible de `NNN-Domaine:Opération / TC NN` vers `Domaine_Opération / Test_NN`, les 485 couples plan/TestCase non passés sous JMeter Fix dans le build 4432554 sont retrouvés sans manque : 484 passent en legacy et seul `SaleAndSellers_CreateReceipt` TC32 échoue.

| Plan normalisé | TestCases JMeter non passés | Résultat legacy Fix SQL 26.0.10.18 |
|---|---|---|
| `ClientStorage_GetClientData` | `TC 01, 07` | `Passed` pour tous |
| `ClientStorage_SaveClientData` | `TC 01-02, 07` | `Passed` pour tous |
| `Common_CommonSearchByReference` | `TC 28-37` | `Passed` pour tous |
| `Common_GetCities` | `TC 02-03` | `Passed` pour tous |
| `Common_GetFreeTableValues` | `TC 02` | `Passed` |
| `Common_GetRegionsByCountryId` | `TC 05` | `Passed` |
| `Common_ValidateBusinessRules` | `TC 25, 28` | `Passed` pour tous |
| `Crm_CreateLoyaltyCard` | `TC 11` | `Passed` |
| `Crm_GetCustomerValuesForSaleDocumentType` | `TC 03, 06, 08-09, 11` | `Passed` pour tous |
| `Crm_GetDuplicateCustomers` | `TC 01-10, 12-15` | `Passed` pour tous |
| `Crm_SearchCustomers` | `TC 01, 03-16, 18-31, 33-34, 36-63` | `Passed` pour tous |
| `Crm_UpdateAddress` | `TC 03-13, 16` | `Passed` pour tous |
| `Deployment_ResetFTSCustomer` | `TC 01` | `Passed` |
| `Deployment_UpdateFTSCatalog` | `TC 01` | `Passed` |
| `Deployment_UpdateFTSCustomer` | `TC 01` | `Passed` |
| `Deployment_UpsertFTSCustomer` | `TC 01-02` | `Passed` pour tous |
| `Image_GetClassificationNodeImage` | `TC 11` | `Passed` |
| `Image_GetCustomerImage` | `TC 07` | `Passed` |
| `Image_GetItemImage` | `TC 03, 12` | `Passed` pour tous |
| `Image_GetItemImages` | `TC 07` | `Passed` |
| `Image_GetItemListImage` | `TC 11` | `Passed` |
| `Image_GetSerialNumberImage` | `TC 01-02, 06-11` | `Passed` pour tous |
| `Image_UpdateCustomerImage` | `TC 04-05` | `Passed` pour tous |
| `Item_GetTaxRefundData` | `TC 08` | `Passed` |
| `ItemSearch_GetItems` | `TC 06, 08-09, 11-15, 18, 38-39, 51, 53-56, 59-62, 65-78, 81-83, 91, 97-99, 101-102, 104-106, 111-145, 147-172, 179-186, 194-197` | `Passed` pour tous |
| `ItemSearch_GetItemsFacets` | `TC 05, 10-23, 25-30, 34, 37-39, 41-46` | `Passed` pour tous |
| `ItemSearch_Keywords` | `TC 02` | `Passed` |
| `Mobility_ExistsDevice` | `TC 03` | `Passed` |
| `Mobility_GetCashRegisterCPOSDevices` | `TC 01, 03-31, 34-42` | `Passed` pour tous |
| `Mobility_GetClientelingParameters` | `TC 01-08` | `Passed` pour tous |
| `Mobility_GetCPOSDevices` | `TC 01-16` | `Passed` pour tous |
| `Mobility_GetMobileParameters` | `TC 01-15, 18-19` | `Passed` pour tous |
| `Mobility_GetSaleDocumentTypeParameters` | `TC 02, 04-05` | `Passed` pour tous |
| `Mobility_UpdateCashDrawerOpenCounter` | `TC 02` | `Passed` |
| `Mobility_UpdateClientelingParameters` | `TC 01-02` | `Passed` pour tous |
| `Mobility_UpdateDeviceCashRegister` | `TC 04` | `Passed` |
| `Mobility_UpdateDeviceId` | `TC 02-04` | `Passed` pour tous |
| `Mobility_UpdateDeviceReferenceCashRegister` | `TC 02-04` | `Passed` pour tous |
| `Mobility_UpdateMobileParameters` | `TC 01-02, 11-12, 14-18, 20-21, 24-28, 32` | `Passed` pour tous |
| `Products_GetItemsV2` | `TC 01-07, 09-11` | `Passed` pour tous |
| `SaleAndSellers_CreateReceipt` | `TC 32, 45-47` | TC32 `Failed` ; TC45-47 `Passed` |
| `SaleAndSellers_GetFiscalDataForReceipt` | `TC 01-04, 06-08, 11-29, 32-41, 44-61, 65, 71-72, 76, 80` | `Passed` pour tous |
| `SaleAndSellers_GetHeaderList` | `TC 03` | `Passed` |
| `SaleAndSellers_GetIdempotencyLines` | `TC 01-02` | `Passed` pour tous |
| `SaleAndSellers_PurgeIdempotencyLines` | `TC 01` | `Passed` |
| `SaleAndSellers_UpdateCustomerForReceipt` | `TC 02-03, 05-07, 10` | `Passed` pour tous |
| `SaleAndSellers_UpdateFiscalDataForReceipt` | `TC 09` | `Passed` |
| `SaleAndSellers_UpdateHeader` | `TC 01` | `Passed` |
| `SaleAndSellers_UpdateTaxRefundDataForReceipt` | `TC 02-03, 10-11` | `Passed` pour tous |

FACT — le TC32 legacy exécute la même requête de postcondition que le JMX, sur `MCHPSUTILISATDATA` avec `MUD_IDCHAMP='2'`, `MUD_VALCHAMP='20160906 15:20:56'` et `MUD_ENTITEMCD='DOC'`, attend `1` et reçoit `0`. Le JMX exact est `../sources/Y2_Plugins_Clienteling-master-build-4432554-exact/Tests/WebServices/113-SaleAndSellers_CreateReceipt.jmx` ; le CSV JMeter exact est sous `build-4432554/_extracted/v26-Fix_WebServices_TestLogs-Attempt#1/`.

Preuve TRX exacte : `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_Clienteling_master_26.0.test.10.18-20260804_031847_Y2_Plugin_Fix_sql.trx`, SHA-256 `3C8F65A14AED6D5980ADA723198A532EFAD4510ED4DFC7FEFC53E2B47FE56D56`. Le XML d'exécution frère `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_Clienteling_master_26.0.test.10.18-20260804_031847.xml` établit Fix, SQL, plugin `26.0.10.18`, Core Fix `26.0.0.1762` et le filtre MSTest `!BDD` appliqué aux conteneurs orderedtest.

Verdict global Clienteling V26 : FACT — les 485 cas ont une issue legacy connue dans cette exécution. INFERENCE — les 484 couples legacy `Passed` / JMeter non passé sont des cibles prioritaires de comparaison. UNKNOWN — ils ne sont pas encore des régressions JMeter démontrées, car le plugin JMeter est `26.0.10.23` et l'équivalence du backup, du déploiement et des autres dépendances n'est pas établie.

## Captures de release récupérées sur la VM

| Branche legacy | Fichiers utiles | Résultat réellement observé |
|---|---|---|
| FrenchTaxesRules V5 | `../evidence/legacy/raw/primary-package-extracted/files/C/Users/SvcTestAutoRetail/AppData/Roaming/CegidIntegrationTests/Y2_Plugins_FrenchTaxesRules_V5_test.6.473-20260807_083330.xml` et `../evidence/legacy/raw/primary-package-extracted/files/C/Users/SvcTestAutoRetail/AppData/Roaming/CegidIntegrationTests/Y2_Plugins_FrenchTaxesRules_V5_test.6.480-20260904_073359.xml` | FACT — arrêt avant MSTest : dossier projet V5 absent ; zéro scénario exécuté |
| FrenchTaxesRules V7 | `../evidence/legacy/raw/primary-package-extracted/files/C/Users/SvcTestAutoRetail/AppData/Roaming/CegidIntegrationTests/Y2_Plugins_FrenchTaxesRules_V7_test.9.17-20260806_09321.xml`, puis les fichiers frères `Y2_Plugins_FrenchTaxesRules_V7_test.9.19-20260806_121948.xml` et `Y2_Plugins_FrenchTaxesRules_V7_test.9.20-20260808_08028.xml` | FACT — arrêt avant MSTest : dossier projet V7 absent ; zéro scénario exécuté |
| Clienteling V6 | index `../evidence/legacy/curated/03_CLIENTELING/V6.md` | FACT — aucun rapport d'exécution collecté ; UNKNOWN — aucun résultat de scénario |
| Clienteling V7 | `../evidence/legacy/raw/primary-package-extracted/files/C/Users/SvcTestAutoRetail/AppData/Roaming/CegidIntegrationTests/Y2_Plugins_Clienteling_V7_test.7.317-20260811_075054.xml`, puis les fichiers frères `Y2_Plugins_Clienteling_V7_test.7.319-20260815_075937.xml`, `Y2_Plugins_Clienteling_V7_test.7.321-20260822_074257.xml`, `Y2_Plugins_Clienteling_V7_test.7.323-20260829_07425.xml` et `Y2_Plugins_Clienteling_V7_test.7.328-20260905_074137.xml` | FACT — fichiers de zéro octet ; UNKNOWN — aucune exécution lisible |
| Clienteling V8 | `../evidence/legacy/raw/primary-package-extracted/files/C/Users/SvcTestAutoRetail/AppData/Roaming/CegidIntegrationTests/Y2_Plugins_Clienteling_V8_test.9.12-20260804_034556.xml`, puis les fichiers frères `Y2_Plugins_Clienteling_V8_test.9.13-20260808_074418.xml` et `Y2_Plugins_Clienteling_V8_test.9.18-20260815_074327.xml` | FACT — arrêt avant MSTest : dossier projet V8 absent ; zéro scénario exécuté |

Ces captures ne sont ni les mêmes itérations ni les mêmes packages que les soumissions `TestAutos` associées aux builds candidats. Elles établissent ce qui s'est réellement passé dans les fichiers récupérés, pas le résultat des corrélations restées inaccessibles.

## FrenchTaxesRules V26 — builds 4432288, 4432320 et 4432365

Chaque build possède un Test Run de 522 tests, tous passés. Les 522 tests sont répartis dans les assemblies MSTest `Model.Tests`, `SaftFileAnalysis.Tests`, `Security.Tests` et `Services.Tests`.

Les trois TRX contiennent les deux tests suivants :

| Test legacy | Entrée observée | Sortie `StdOut` observée | Assertion du test | Rapport avec JMeter |
|---|---|---|---|---|
| `JsonWriteTest1` | `./Files/Export_NF525.json` | 2 transactions en erreur sur 33 ; 33 clôtures en erreur sur 38 ; 1 événement ; signature `VALID` ; écriture de `Export_NF525.json.error-descriptions.txt` | Le fichier de description existe après `ExecAnalysis` | Recouvrement fonctionnel sur l'analyse NF525, mais aucune requête HTTP, réponse API, écriture DB ou assertion de TC JMeter n'est vérifiée |
| `XmlWriteTest1` | `./Files/SAFT.XML` | 2 133 transactions en erreur sur 74 640 ; 210 clôtures en erreur et 2 715 erreurs ; 42 erreurs de paramètres ; signature `NOT VALID` ; écriture de `SAFT.XML.error-descriptions.txt` | Le fichier de description existe après `ExecAnalysis` | Recouvrement fonctionnel sur l'analyse SAFT, mais pas d'équivalence démontrée avec un TestCase JMeter précis |

Les `StdOut` sont identiques entre les trois builds. Les fichiers d'entrée sont des fixtures embarquées dans l'assembly `SaftFileAnalysis.Tests`; ils ne sont pas présents comme attachments du Test Run. Les deux fichiers `.error-descriptions.txt` sont mentionnés dans `StdOut` mais ne sont pas attachés, donc leur contenu n'est pas une preuve disponible.

Preuves de rapprochement conservées : source locale `sources/Y2_Plugins_FrenchTaxesRules-v7-build-4429629/Cegid.Retail.FrenchTaxesRules.SaftFileAnalysis.Tests/ReportGenerationUnitTests.cs` (appels `ExecAnalysis` et assertions d'existence) ; plans JMeter `sources/Y2_Plugins_FrenchTaxesRules/Tests/LegacyServices/010-Export_Run.jmx` ; résultats du build JMeter `4432510` sous `evidence/build-4432510/_extracted/v26-Cur_LegacyServices_TestLogs-Attempt#1/.../010-Export_Run/010-Export_Run-results.xml` et `.jtl`. La recherche des deux noms de fixtures dans les sources/plans et artefacts JMeter n'a pas démontré leur utilisation par JMeter.

Verdict : preuve legacy fonctionnelle réelle pour le sous-système d'analyse de rapports ; `UNKNOWN — non comparable` pour une conclusion de régression ou d'écart sur les cas JMeter migrés, faute de correspondance démontrée entre le contrat de ces tests et un plan/TestCase JMeter.

## Recherche ciblée des scénarios FrenchTaxesRules

FACT — une recherche read-only a interrogé les Test Runs de 61 runs publiés appartenant aux 100 derniers builds de la définition `FrenchTaxesRules CI` (`2054`), en limitant le périmètre aux branches `master` et `releases/V*`. Les résultats Test Run ont été inspectés sur les noms `Export_Run` et `DocumentSignature_SignOne` ; aucun résultat correspondant n'a été trouvé.

La recherche inclut notamment les builds `4436133` (commit `07a42172bebc65d17093e166ac08de22e4fe7248`, run `6182739`), `4432395` (commit `07a42172bebc65d17093e166ac08de22e4fe7248`, runs `6180138` et `6180388`), `4432288` (commit `07a42172bebc65d17093e166ac08de22e4fe7248`, run `6180090`) et `4427434` (commit `07a42172bebc65d17093e166ac08de22e4fe7248`, run `6176642`). Les TRX téléchargés pour ces runs ne contiennent aucun de ces deux scénarios.

FACT — dans le code généré disponible au commit du build `4429629` (`657a61cd6d6d08cac698517309077202c43a29f8`), les classes exactes `AutoTest/Export/Export_Run.g.cs` et `AutoTest/DocumentSignature/DocumentSignature_SignOne.g.cs` portent des méthodes MSTest avec `[TestCategory("BDD")]`, appellent `LegacyDispatcherService` et utilisent les fixtures `InputFiles\\Export\\Run_*.xml` et `InputFiles\\DocumentSignature\\SignOne_*.xml`. Ce sont les sources exactes des scénarios, mais pas une exécution publiée retrouvée.

FACT — le YAML exact conservé pour le build legacy `4432288`, commit `07a42172bebc65d17093e166ac08de22e4fe7248`, génère les méthodes `WebServices` et `LegacyServices`, transmet `testsFilterCriteria: "testcategory!=bdd & testcategory!=suspended"` à `Build\\dotNet-build.v1.yml@azoTemplates`, puis définit le job `TestAutos` avec `IntegrationTests\\launch-testsAutos.v2.yml@azoTemplates`.

Verdict `Export_Run` : `FACT — aucune exécution publiée trouvée dans le périmètre vérifié` ; le workflow externe reste non couvert par cette recherche de résultats.

Verdict `DocumentSignature_SignOne` : `FACT — aucune exécution publiée trouvée dans le périmètre vérifié` ; le workflow externe reste non couvert par cette recherche de résultats.

## FrenchTaxesRules V25 — build 4429632 et V21-V23 — build 4429170

Le Test Run `6178203` du build `4429632` contient 82 tests, tous passés, dans huit classes/assemblies de tests. Le TRX ne fournit pas de correspondance démontrée avec les cas JMeter V25 de `4429629`.

Le build `4429170` possède dix Test Runs (`6177841`, `6177842`, `6177850`, `6177939`, `6177942`, `6178026`, `6178097`, `6178115`, `6178124`, `6178156`). Chaque run contient 2 tests passés, soit 20 résultats au total, tous dans `SaftFileAnalysis.Tests`. Cette activité est une preuve de tests legacy exécutés, mais les TRX et leurs sorties ne démontrent pas l'équivalence avec les campagnes JMeter V21/V22/V23 du build `4429167`.

Verdict : `UNKNOWN — non comparable` au niveau des cas JMeter, avec preuve conservée ; ne pas reformuler cela comme « aucun test legacy ».

## Clienteling — builds 4432556, 4432608, 4432653 et 4432675

Les Test Runs ont bien été recherchés et les TRX attachés ont été téléchargés. Le build master `4432556` a le run `6180391`; V6 `4432608` a six runs (`6180431`, `6180433`, `6180435`, `6180482`, `6180483`, `6180484`); V7 `4432653` a le run `6180481`; V8 `4432675` a le run `6180515`.

Chaque TRX contient zéro `UnitTestResult` et les compteurs du TRX sont à zéro. La timeline montre néanmoins des étapes de build/lancement ; cette observation ne prouve ni une désactivation des tests ni l'absence d'un autre mécanisme d'exécution.

### Explication observée des TRX vides

- FACT — `4432556`, log `45` : le filtre `TestCategory!=BDD` est passé à VSTest ; le log indique ensuite `No test matches`, une sortie `vstest.console.exe` avec code `0`, `No Result Found to Publish` et `Publishing test results: 0`, puis crée le Test Run `6180391`.
- FACT — `4432653`, log `45` : même séquence (`TestCategory!=BDD`, aucun test correspondant, code `0`, aucun résultat à publier), puis Test Run `6180481`.
- FACT — `4432675`, log `45` : même séquence, puis Test Run `6180515`.
- FACT — `4432608`, logs `230`, `231` et `233` : même séquence, puis Test Runs `6180482`, `6180483` et `6180484` respectivement.
- FACT — les tâches de lancement externes ont été observées comme réussies : `4432556` log `94` retourne le workflow `226`, `4432653` log `101` retourne `227`, et `4432675` log `102` retourne `228`. Cela prouve la soumission de la demande, pas l'exécution ni le succès des tests sur l'environnement cible.
- FACT — les autres Test Runs de `4432608` (`6180431`, `6180433`, `6180435`) sont publiés avec zéro résultat, mais aucun des trois logs VSTest ci-dessus ne les identifie directement ; leur cause exacte reste `UNKNOWN`.
- INFERENCE — le mécanisme le mieux étayé pour les TRX vides est un désalignement entre les tests disponibles/catégorisés et le filtre d'exclusion `BDD`.
- UNKNOWN — l'intention de cette exclusion, l'exécution effective des workflows externes et le statut historique de chaque test ne sont pas établis. Il ne faut donc pas conclure que les tests étaient désactivés.

Verdict : `UNKNOWN — non comparable` faute de résultats legacy exploitables par cas ; cette conclusion ne signifie ni « aucun test n'a été lancé », ni « tests désactivés », et ne permet pas de conclure à une régression Clienteling.

## Clienteling — YAML et code aux commits exacts

FACT — les YAML exacts des builds `4432556` (`0c0fd26533e46b13e029276f90b5c085c1804012`), `4432608` (`1b29b27aa3d899a39d2628f849b6643340de6a31`), `4432653` (`1abc22e57cf1c04557b146a42bfd1b822221c2b6`) et `4432675` (`78902d855738d3736b4338aa835e7ef95829afbf`) génèrent des méthodes depuis `Data\\WebServices\\WebServices.xml`, compilent les assemblies `**\\Cegid.Retail.$(plugin.Name)*.Tests.dll` hors `*TestAdapter.dll`, et définissent un job `TestAutos (on Premise)` dépendant de `Publish` qui appelle `IntegrationTests\\launch-testsAutos.v2.yml@azoTemplates` sur un agent privé.

FACT — pour les Test Runs vides, les logs VSTest montrent explicitement le filtre `TestCategory!=BDD` appliqué aux assemblies `Model.Tests`, `Services.Tests` et `WebServices.Tests`, puis `No test matches`. Les TRX correspondants sont `6180391` (4432556), `6180481` (4432653), `6180515` (4432675) et `6180431`, `6180433`, `6180435`, `6180482`, `6180483`, `6180484` (4432608).

FACT — la timeline indique `TestAutos (on Premise)` skipped pour `4432608`, mais succeeded pour `4432556`, `4432653` et `4432675`; les logs de lancement associés sont `94`/workflow `226`, `101`/workflow `227` et `102`/workflow `228`.

FACT — les projets de tests présents dans les snapshots Clienteling exacts ne contiennent pas de déclarations `[TestCategory]` ou `[TestMethod]` inspectables ; les méthodes générées sont produites dans l'espace de travail du pipeline à partir de `WebServices.xml` et ne constituent pas une preuve de résultat publiée.

Verdict Clienteling : `FACT — aucune exécution publiée trouvée dans le périmètre vérifié` pour les TRX contenant zéro résultat ; `UNKNOWN — workflow externe ou preuve inaccessible` pour l'exécution effective de `TestAutos` et pour l'intention du filtre. La mention `TestCategory!=BDD` identifie le filtre observé, mais ne prouve pas que les tests étaient désactivés.

## Trace aval de `TestAutos`

Le template exact conservé dans `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml` est un lanceur asynchrone. Il exécute un POST `text/xml` vers `http://<hostname>:8181/integrationlauncher`, avec l'action SOAP `StartWorkflowAsync` et un payload contenant `workflow`, `iteration` et `arguments`. L'itération est construite sous la forme `test.<buildNumber>-<timestamp>`. Le template journalise la réponse immédiate, mais ne contient aucun polling, endpoint de statut, téléchargement de logs ou récupération de résultats.

| Build | Timeline / log | Cible et corrélation observées | Verdict aval |
|---:|---|---|---|
| FrenchTaxesRules `4432288` | `timeline.json`; log `137` | `Y2-TSTAUTOXXPG2`; workflow `Y2_Plugins_FrenchTaxesRules_master`; itération `test.10.70-20260904_095921`; `StartWorkflowAsyncResult=162` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| FrenchTaxesRules `4429632` | `timeline.json`; log `108` | `Y2-TSTAUTOXXPG2`; workflow `Y2_Plugins_FrenchTaxesRules_V7`; itération `test.9.25-20260903_041353`; `StartWorkflowAsyncResult=66` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| FrenchTaxesRules `4432320` | `timeline.json` | Aucun record `TestAutos`/`launch-testsAutos` trouvé dans la timeline conservée | FACT — aucune soumission `TestAutos` publiée dans la timeline vérifiée ; UNKNOWN — autre mécanisme éventuel |
| FrenchTaxesRules `4432365` | `timeline.json` | Aucun record `TestAutos`/`launch-testsAutos` trouvé dans la timeline conservée | FACT — aucune soumission `TestAutos` publiée dans la timeline vérifiée ; UNKNOWN — autre mécanisme éventuel |
| FrenchTaxesRules `4429170` | `timeline.json` | Phase `TestAutos (on Premise)` skipped | FACT — étape `TestAutos` skipped ; UNKNOWN — autre exécution aval éventuelle |
| Clienteling `4432556` | `timeline.json`; log `94` | `Y2-TSTAUTOXXPG2`; workflow `Y2_Plugins_Clienteling_master`; itération `test.10.24-20260904_103346`; `StartWorkflowAsyncResult=226` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| Clienteling `4432608` | `timeline.json` | Phase `TestAutos (on Premise)` skipped ; aucun identifiant de soumission | FACT — étape skipped ; UNKNOWN — autre exécution aval éventuelle |
| Clienteling `4432653` | `timeline.json`; log `101` | `Y2-TSTAUTOXXPG2`; workflow `Y2_Plugins_Clienteling_V7`; itération `test.7.326-20260904_105812`; `StartWorkflowAsyncResult=227` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| Clienteling `4432675` | `timeline.json`; log `102` | `Y2-TSTAUTOXXPG2`; workflow `Y2_Plugins_Clienteling_V8`; itération `test.9.22-20260904_11827`; `StartWorkflowAsyncResult=228` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |

FACT — la recherche des corrélations `162`, `66`, `226`, `227`, `228` et des itérations exactes dans les logs/preuves déjà inventoriés ne retrouve aucun statut final, log de workflow, TRX aval ou résultat de test supplémentaire.

FACT — la résolution DNS locale de `Y2-TSTAUTOXXPG2` réussit, mais l'accès GET au endpoint `:8181/integrationlauncher` ne fournit pas de lecture exploitable (`unavailable_or_no_read_endpoint`).

UNKNOWN — l'autorisation ou l'interface nécessaire pour interroger le système `IntegrationTestsLauncherService`/`Y2-TSTAUTOXXPG2` et retrouver l'état des workflows `162`, `66`, `226`, `227` et `228` n'est pas disponible. La recherche s'arrête ici ; aucune conclusion d'exécution ou de succès des tests n'est tirée.
