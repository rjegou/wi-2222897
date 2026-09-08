# Plan de correction implémentable — causes prouvées des résultats JMeter non passés

Date : 2026-09-05. Périmètre : corrections fondées sur des causes prouvées dans les preuves conservées. Ce document ne modifie aucun code, package, pipeline ou branche.

## Règle de lecture

Chaque ligne ci-dessous part d'un `FACT` observé. Lorsqu'une cause est prouvée mais que plusieurs corrections sont possibles, le choix restant est explicitement marqué comme décision à prendre. Les versions, noms de branches et numéros de build sont ceux des snapshots inventoriés ; ils ne valent pas autorisation de republier ou de rejouer. La soumission `TestAutos` n'est pas utilisée comme preuve de réussite des tests externes.

Les clones sous `sources/*-build-*` sont des snapshots de preuve, souvent détachés sur le commit du build. Ils servent à localiser et vérifier le code, mais ne sont pas les branches dans lesquelles implémenter les changements.

## Corrections prouvées

### Préparation commune aux quatre corrections AutoTest.Api

- Créer un vrai projet `Cegid.Retail.AutoTest.Api.Tests` et l'ajouter à `Cegid.Retail.AutoTest.Api.sln`. La solution ne contient actuellement que le projet de production ; `Cegid.Retail.AutoTest.Api/UnitTest.cs` contient le `TestLauncher` de production et ne doit pas recevoir les nouveaux tests.
- Les quatre méthodes ciblées sont privées. Préférer l'extraction de transformations pures dans un helper `internal` testable avec `InternalsVisibleTo`, ou les tester par le comportement public de génération. Ne pas installer durablement des tests fondés sur la réflexion.
- Après validation, incrémenter `Y2_Tools_AutoTest_Api/SolutionInfo.cs` et publier l'API seulement après autorisation.
- Dans `Y2_Tools_AutoTest_Console`, mettre à jour à la fois `Cegid.Retail.AutoTest.Console/Cegid.Retail.AutoTest.Console.csproj` et `packages.config`, puis incrémenter `SolutionInfo.cs` et publier Console seulement après autorisation.
- Dans `Migration_Jmeter_RJE_Sandbox`, mettre à jour `migration-tools/consoleWorkflowVersions.json` et remplacer `migration-tools/Cegid.Retail.AutoTest.Console.nupkg`, puis régénérer les JMX. Ne jamais corriger les JMX à la main comme solution durable.

### 1. Génération XPath Fault

- **Verdict / preuve** : `FACT` — `CleanXpath` transforme le chemin nu `/soap:Fault` en `//`, ce qui produit `TransformerException: A location step was expected` ; 75 premières fautes. Preuves : `findings/005-clienteling-v22-v23-build-4432602.md`, `findings/006-clienteling-v26-build-4432554.md`, `findings/007-clienteling-v24-build-4432652.md`, `findings/008-clienteling-v25-build-4432672.md`.
- **Dépôt / fichier / méthode** : `Y2_Tools_AutoTest_Api` — `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` — méthode `CleanXpath`.
- **Modification attendue** : préserver un XPath valide pour `/soap:Fault`, pour `/soap:Fault[...]` et pour les chemins descendants ; ne pas fabriquer un double slash lors de la normalisation. La preuve JMeter 5.6.3 montre que `//Fault` reste insuffisant pour un Fault SOAP préfixé lorsque `XPath.namespace=false`; la solution robuste doit être namespace-aware (`namespace=true`, mapping URI SOAP et XPath préfixé).
- **Tests à ajouter** : tests unitaires de ces trois formes, puis génération JMX contrôlant l'absence de `//` invalide, l'activation namespace-aware, le mapping SOAP et le XPath préfixé. Couvrir SOAP 1.1, SOAP 1.2 selon le contrat supporté, préfixes variables, absence de Fault et mauvais namespace.
- **Chaîne de packages à republier** : source `Y2_Tools_AutoTest_Api` → package `Cegid.Retail.AutoTest.Api` (la version observée est `1.1.46`, build package `4311236`) → `Y2_Tools_AutoTest_Console` / package `Cegid.Retail.AutoTest.Console` (package courant observé `2.0.42`, build `4311240`) → `Migration_Jmeter_RJE_Sandbox` → régénération des JMX.
- **Rejeu minimal** : un cas Fault dans chacun des plans Clienteling concernés, puis comparaison des JMX régénérés ; les 75 cas sont à rejouer après les autres prérequis sans les confondre avec les 224 fautes Full-Text.

### 2. Préservation de l'échappement XML interne

- **Verdict / preuve** : `FACT` — 23 requêtes Clienteling perdent un niveau d'échappement et renvoient `CBR_005_0269` ; les sources contiennent des entités déjà encodées.
- **Dépôt / fichier / méthode** : `Y2_Tools_AutoTest_Api` — `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` — méthode `RemoveSpecialCharsForXQuery`.
- **Modification attendue** : traiter l'esperluette déjà présente dans une entité avant l'écriture du XML JMX, afin que le round-trip conserve le texte interne attendu par SQL.
- **Tests à ajouter** : test de round-trip avec `&amp;lt;ClientelingParameters...&amp;gt;`, puis cas avec `CommonParameters` et apostrophe ; comparer le texte SQL après parsing XML.
- **Chaîne de packages à republier** : même chaîne API → Console → `Migration_Jmeter_RJE_Sandbox` → JMX régénérés.
- **Rejeu minimal** : un cas de chacun des quatre plans `Mobility:UpdateMobileParameters`, `Mobility:GetMobileParameters`, `ItemSearch:GetItemsFacets` et `ItemSearch:GetItems`.

### 3. Conversion des dates SQL ISO

- **Verdict / preuve** : `FACT` — `yyyy-mm-dd` est généré en année-jour-mois (`2026-04-28` → `20262804`, et mêmes inversions démontrées sur FrenchTaxesRules) ; erreurs SQL 242 sur six prérequêtes Clienteling.
- **Dépôt / fichier / méthode** : `Y2_Tools_AutoTest_Api` — `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` — méthode `EscapeJdbcDate`.
- **Modification attendue** : produire `yyyymmdd` pour les dates SQL ISO apostrophées ; conserver inchangées les valeurs qui ne sont pas au format ciblé.
- **Tests à ajouter** : test avec jour supérieur à 12, par exemple `2026-04-28`, test `2016-01-03`, test d'une valeur déjà compacte et test de non-transformation hors motif.
- **Chaîne de packages à republier** : API → Console → `Migration_Jmeter_RJE_Sandbox` → régénération et contrôle de tous les JMX, car certaines inversions restent silencieusement valides.
- **Rejeu minimal** : `CreateReceipt` TC45–TC47, `GetIdempotencyLines` TC01–TC02 et `PurgeIdempotencyLines` TC01 ; pour FrenchTaxesRules, `Export_Run` TC08–TC10 et `DocumentSignature_SignOne` TC02.

**État local du 2026-09-06 :** correctif local compilé et génération JMX validée sur six fixtures, avec comparaison API originale/corrigée dans [`evidence/local-2026-09-06-api-jmx-date-before-after/`](evidence/local-2026-09-06-api-jmx-date-before-after/). Console, Docker et rejeu métier restent `UNKNOWN`. La prochaine étape proposée est une compilation Console isolée avec un artefact API d'essai identifié, sans publication.

### 4. Littéraux SQL Unicode contenant `''`

- **Verdict / preuve** : `FACT` — la regex actuelle de `FixSqlUnicodeValue` ne gère pas une apostrophe SQL doublée et place `N` au milieu du littéral ; `ItemSearch:Keywords` TC02 échoue en SQL 102.
- **Dépôt / fichier / méthode** : `Y2_Tools_AutoTest_Api` — `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` — méthode `FixSqlUnicodeValue`.
- **Modification attendue** : remplacer la regex par un parcours de littéraux SQL qui accepte `''` à l'intérieur d'un littéral et ajoute le préfixe Unicode au bon début.
- **Tests à ajouter** : littéral Unicode simple, littéral Unicode avec `''`, littéral ASCII avec `''`, et chaîne hors littéral ; vérifier le SQL résultant et le JMX produit.
- **Chaîne de packages à republier** : API → Console → `Migration_Jmeter_RJE_Sandbox` → JMX régénérés.
- **Rejeu minimal** : `ItemSearch:Keywords` TC02, puis un cas SQL Unicode équivalent dans la campagne Clienteling.

**État local du 2026-09-07 :** implémentation réalisée dans le worktree d'essai `Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE` : parcours des littéraux SQL, prise en charge de `''`, commentaires et identifiants délimités, préfixe `N` au début et conservation d'un préfixe existant. Compilation net452 isolée réussie avec les façades stagingées; neuf vecteurs durables et génération JMX intégrée `ItemSearch:Keywords` TC02 validés. Preuves : `evidence/local-2026-09-07-fix-sql-unicode/` et `evidence/local-2026-09-07-api-jmx-unicode/`. La chaîne API→Console→migration et le rejeu métier restent `UNKNOWN`.

**CleanXpath — état local 2026-09-07 :** correction appliquée et compilée; `/soap:Fault` devient `//Fault` au lieu de `//`. Les contrôles production et sélections SOAP synthétiques passent. La source legacy `ItemSearch_Keywords.xml` est retrouvée dans l'archive indexée, mais la génération intégrée complète depuis cette XML n'est pas encore prouvée; l'ancien JMX utilisé par le harness Unicode était déjà transformé. Preuve : `evidence/local-2026-09-07-cleanxpath/`.

**CleanXpath — conséquence JMeter 5.6.3 :** la correction `/soap:Fault` → `//Fault` est syntaxique, mais le moteur réel ne matche pas un Fault SOAP préfixé avec `namespace=false`. Le générateur doit donc être traité séparément pour produire, sur les Fault SOAP, `namespace=true`, un mapping URI et un XPath préfixé. SOAP 1.1/1.2 et les autres XPath restent à inventorier avant modification globale. Preuves : `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/` et `findings/012-jmeter-5-6-3-xpath-namespace.md`.

**RemoveSpecialCharsForXQuery — état local 2026-09-07 :** `&` est échappée avant `<`, `>` et apostrophes. Compilation et quatre tests de comportement public passent, avec non-régression CleanXpath/Unicode. La régénération source→JMX des quatre plans et le round-trip XML parsé restent UNKNOWN. Preuve : `evidence/local-2026-09-07-remove-special-chars/`.

### 5. SQL Full-Text

- **Verdict / preuve** : `FACT` — 224 cas échouent avec l'absence de SQL Full-Text / SQL 7609 dans les conteneurs ; `dbo.CLIENTELING_REMOVENONNUMERIC` est également absente dans deux cas. Preuves : `findings/005-clienteling-v22-v23-build-4432602.md`, `findings/006-clienteling-v26-build-4432554.md`, `findings/007-clienteling-v24-build-4432652.md`, `findings/008-clienteling-v25-build-4432672.md`.
- **Dépôt propriétaire / fichiers** : `Pipelines_Docker_BaseImages` — `/Images/SqlExpress/2019/dockerfile`, `/Images/SqlExpress/2025/dockerfile` et `/Images/SqlExpress/tests.yml`. Les deux Dockerfiles installent actuellement uniquement `/FEATURES=SQLENGINE`.
- **Dépôt consommateur** : `Y2_Tools_Jmeter_Workflow` — `Docker/Y2-JMeter/dockerfile` hérite de l'image `sqlexpress` sélectionnée ; `azure-pipeline.yml` porte les tags 2019 et 2025. Ce dépôt ne doit pas réimplémenter l'installation Full-Text sauf décision explicite de changement de responsabilité.
- **Modification attendue** : adapter le média et les options d'installation des images SQL 2019 et 2025 afin que Full-Text soit réellement disponible. Ne pas supposer qu'ajouter un nom de feature suffit si le média téléchargé ne la contient pas. Initialiser ensuite le catalogue attendu côté Clienteling.
- **Tests à ajouter** : compléter `/Images/SqlExpress/tests.yml` avec un smoke test bloquant vérifiant `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') = 1`, puis vérifier le catalogue. Contrôler séparément `dbo.CLIENTELING_REMOVENONNUMERIC` après l'initialisation produit ; sa modification reste conditionnée à la preuve que l'initialisation correcte ne la crée pas.
- **Chaîne à republier** : images SQL de base 2019/2025 → images `y2-jmeter` consommatrices → campagnes JMeter. Les packages plugin restent inchangés pour l'installation de Full-Text.
- **Rejeu minimal** : les cinq plans `ItemSearch:GetItems`, `Crm:SearchCustomers`, `ItemSearch:GetItemsFacets`, `Crm:GetDuplicateCustomers`, `Common:CommonSearchByReference`, puis `UpsertFTSCustomer` TC02.

### 6. Endpoints et packaging Clienteling

- **Verdict / preuve** : `FACT` — les métadonnées ciblent `DeploymentService.svc` au lieu de `ClientelingDeploymentService.svc` (3 cas), `MobilityService.svc` au lieu de `ClientelingMobilityService.svc` (10 cas), et `ClientelingProductsService.svc` est absent des manifests MSI des versions concernées (9 à 10 cas selon version).
- **Dépôt / fichiers de scénarios** : dépôt plugin Clienteling, dans la source canonique antérieure au déréférencement, sous `IntegratedTests/AutoTest/Data/WebServices/TestPlans/` : `Deployment_ResetFTSCustomer.xml`, `Deployment_UpdateFTSCatalog.xml`, `Deployment_UpdateFTSCustomer.xml`, `Mobility_GetClientelingParameters.xml` et `Mobility_UpdateClientelingParameters.xml`. Ces fichiers sont visibles dans le parent des commits de migration, mais ne sont plus présents au `HEAD` des snapshots migrés.
- **Dépôt / manifests Products** : `Kits/V22/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml` à `Kits/V26/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml`, selon la branche de version.
- **Modification attendue** : corriger dans la branche canonique les cinq attributs `WebService` vers les noms installés, puis régénérer. Pour Products, ajouter le service au MSI si le contrat le supporte, sinon retirer explicitement les cas des versions non supportées. Cette décision Products doit être tracée avant modification.
- **Tests à ajouter** : validation statique source/JMX/manifest ; smoke HTTP d'un endpoint Deployment et d'un endpoint Mobility par version ; test d'installation vérifiant la présence de Products avant d'activer ses cas.
- **Chaîne de packages à republier** : sources/config Clienteling → package MSI et manifest du plugin → déploiement Y2 → régénération des JMX via API/Console déjà corrigées → campagne JMeter.
- **Rejeu minimal** : un cas Deployment, un cas Mobility, puis tous les cas `Products:GetItemsV2` seulement si le service est déclaré supporté et installé.

### 7. Chemins et fixtures d'images Clienteling

**FACT — instruction utilisateur du 2026-09-08** : résoudre par investigation technique le
propriétaire du transport et le chemin accessible depuis IIS (décision 4). L'investigation reste
à effectuer ; ne plus présenter ce sujet comme un arbitrage PO préalable.

- **Verdict / preuve** : `FACT` — `CustomImageLocation` reste littéralement `${tests.folder}\\${CustomImageFolder}` et les images présentes dans l'historique ne sont plus dans le snapshot migré ; 8 cas `Image:GetSerialNumberImage` échouent avec `CBR_005_0344`.
- **Dépôt / fichiers** : dépôt plugin Clienteling — `Tests/Config/v22-*.cy2px` à `v26-*.cy2px` pour le périmètre exécuté et `IntegratedTests/Workflow/config_PLG/GetItemImage` dans les parents des commits de migration. V21 porte également le placeholder, mais son comportement n'est pas validé par un run puisqu'il était skipped.
- **Décision préalable** : choisir le chemin canonique visible par IIS dans le conteneur et identifier le mécanisme propriétaire qui copiera ou montera les onze images. Ce mécanisme exact n'est pas établi dans les preuves actuelles et reste `UNKNOWN`.
- **Modification attendue après décision** : remplacer le placeholder non supporté, restaurer les images dans l'artefact ou le montage retenu et ajouter une vérification de présence avant les tests.
- **Tests à ajouter** : test de résolution de configuration dans le conteneur, contrôle que chaque fichier image attendu existe, puis smoke `Image:GetSerialNumberImage`.
- **Chaîne à confirmer** : sources/config et fixtures Clienteling → package de test ou artefact de campagne → image ou montage de test. Ne pas annoncer cette chaîne comme implémentable tant que le propriétaire de la copie ou du montage n'est pas identifié.
- **Rejeu minimal** : les 8 cas `Image:GetSerialNumberImage` après vérification indépendante des fichiers et du chemin effectif.

**État vérifié le 2026-09-07 (Worker 3 Round 2)** : le test local [fixture-transport-check.ps1](evidence/2026-09-07-brain-reprise-worker3/fixture-transport-check.ps1) compte onze fixtures historiques, zéro image dans le snapshot migré, aucune copie `CustomImage`/`ImageFolder` dans le template PlatformDeploy, et démontre seulement qu'un chemin absolu factice résout. Le propriétaire du transport et le chemin IIS final restent `UNKNOWN`; aucune modification de code, manifeste ou pipeline n'est autorisée sur cette preuve seule.

### 8. Piles Fix incompatibles

- **Verdict / preuve** : `FACT` — les MSI Fix V22/V23 ne satisfont pas les minima annoncés ; installations en erreur 1603 puis contrôle de santé en connexions refusées. Preuve : `findings/005-clienteling-v22-v23-build-4432602.md`, sections `Déploiements Fix — incompatibilités de versions prouvées`.
- **Dépôt / fichiers de configuration** : dépôt plugin Clienteling — `Tests/Config/v22-fix.cy2px` et `Tests/Config/v23-fix.cy2px`. Les contraintes sont annoncées par les MSI et observées dans leurs logs d'installation.
- **Décision de compatibilité** : choisir une combinaison existante et officiellement supportée qui respecte les minima MSI, puis relever les `selectVersion`. Ne republier des MSI compatibles que si aucune combinaison supportée n'existe et après décision des propriétaires produits.
- **Propagation des erreurs à vérifier** : le master actuel de `Y2_Tools_PlatformDeploy`, commit `93f91487ee717185599555a42df3cb5d024ace89`, cumule déjà les retours MSI dans `Src/Powershell/Code/Scripts/install-packages.ps1` et lève une erreur lorsque `$nbErr -gt 0` aux lignes 247–250. Ne pas ajouter un garde-fou identique.
- **Investigation préalable** : identifier la version exacte de PlatformDeploy consommée par le build 4432602. Si elle précède ce garde-fou, mettre à jour le consommateur ; si elle le contient, localiser le chemin qui absorbe encore l'erreur et corriger ce point précis.
- **Tests à ajouter** : test de résolution de la pile contre les prérequis MSI ; installation propre de chaque MSI ; test de propagation d'un retour MSI non nul dans le chemin réellement utilisé ; health check worker/IIS/token.
- **Chaîne à appliquer** : configuration Fix compatible → déploiement avec la version PlatformDeploy identifiée → contrôle de santé → seulement ensuite artefacts de campagne JMeter. Ne republier les MSI que si la décision de compatibilité l'exige.
- **Rejeu minimal** : contrôle de santé V22 Fix et V23 Fix seuls ; après succès, un cas JMeter par version, puis la campagne complète.

### 9. Autorisations FrenchTaxesRules V22 Fix

- **Verdict / preuve** : `FACT` — le build 4429167 publie 174 cas non passés en V22 Fix, soit 138 LegacyServices et 36 WebServices. Les acquisitions de jeton réussissent, mais les appels sont refusés avec `CBP50101` / `FailedAuthentication` et le droit `allowedModule` attendu n'est pas projeté.
- **Premier dépôt / fichier** : dépôt plugin FrenchTaxesRules — `Tests/Config/v22-fix.cy2px`, qui épingle notamment Core, Common, Identity et Technical. Le snapshot exact est `sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167` ; il reste une preuve, pas une branche de modification.
- **FACT — décision utilisateur du 2026-09-08** : relever les versions minimales de la configuration V22 Fix (décision 2). Identifier une combinaison compatible et disponible avant édition ; les numéros exacts et le résultat du rejeu restent `UNKNOWN`. Aucun correctif Identity/Core n'est choisi par cet arbitrage.
- **Tests à ajouter** : vérifier l'acquisition du jeton, inventorier la présence du droit `allowedModule/FrenchTaxesRules`, puis confirmer l'absence de `CBP50101` sur un appel Legacy et deux appels Web représentatifs.
- **Chaîne à appliquer** : configuration V22 Fix et validation de compatibilité → déploiement propre → contrôle du jeton et des droits → rejeu JMeter ciblé. Ne pas supprimer les attributs d'autorisation du code généré pour masquer le défaut.
- **Rejeu minimal** : un cas `FrenchTaxesRules:Run`, un cas `SetDocumentErrorReason` et un cas `Purge:Execute`.

## Prérequis opérationnel de rejeu

- **FrenchTaxesRules V23 Fix** : le build 4429167 n'a exécuté aucun test V23 Fix, car `Initialize containers` a échoué lorsque le moteur Docker n'a pas répondu. Ce point est un blocage d'agent/infrastructure, pas un correctif produit ou JMeter.
- Avant tout rejeu V23 Fix autorisé, vérifier indépendamment `docker version` sur l'agent retenu. Ne pas attribuer à V23 Fix les causes observées sur V22 ou sur les variantes Cur tant que JMeter n'a pas démarré.

## Ne pas corriger sans preuve

Les éléments suivants restent `UNKNOWN` ou nécessitent une décision fonctionnelle. Ils ne doivent pas entraîner une modification de code, d'attendu ou de fixture sur la seule base des résultats JMeter ou d'une baseline legacy insuffisamment comparable :

- réponses métier HTTP 200 différentes des fichiers attendus et assertions Clienteling : les identifiants correspondants passent dans le TRX legacy Fix `26.0.10.18`, mais JMeter utilise `26.0.10.23` et le backup/environnement n'est pas rapproché ;
- `TC22` FrenchTaxesRules et `SaleAndSellers_CreateReceipt` TC32 Clienteling : les mêmes postconditions échouent déjà dans les TRX legacy récupérés ; rechercher une cause commune scénario/produit/données, pas un correctif JMeter par défaut ;
- les deux `TC99` FrenchTaxesRules : ils passent en legacy Fix `26.0.10.25` et échouent sous JMeter `26.0.10.75`, mais le contrat complet et l'environnement ne sont pas suffisamment comparables ;
- collisions de données `MCAISSEDEVICE.MKD_CLE1`, dont l'artefact prouve la collision mais pas la responsabilité du scénario ou du backup ;
- différences `DailyRegisterClosing`, fixtures de clôture, lignes PIEDBASE et autres écarts sans baseline legacy comparable ;
- les deux fautes métier résiduelles (`GetHeaderList` TC03 et `UpdateHeader` TC01), toutes deux `Passed` dans le TRX legacy `26.0.10.18`, mais dont les transitions/valeurs et la comparabilité restent à valider ;
- tout résultat des corrélations exactes `TestAutos` `162`, `66`, `226`, `227`, `228` : elles prouvent une soumission acceptée uniquement. Les TRX aval récupérés le 2026-09-06 sont des exécutions indépendantes, avec d'autres dates/itérations, et ne ferment pas ces corrélations.

## Ordre d'implémentation et garde-fous

1. Créer le projet de tests API, corriger et tester les quatre transformations sans modifier les JMX générés à la main.
2. Corriger les images SQL de base 2019/2025 et bloquer leur publication si le smoke test Full-Text échoue.
3. Après autorisation, republier API puis Console, mettre à jour le package de migration et régénérer tous les JMX.
4. Corriger les cinq métadonnées Clienteling ; prendre la décision Products et identifier le mécanisme de transport des fixtures avant de modifier manifests ou chemins d'images.
5. Choisir des piles Fix compatibles et identifier la version PlatformDeploy réellement utilisée avant toute modification de propagation des erreurs.
6. Appliquer la décision utilisateur : identifier puis relever les minima de configuration FrenchTaxesRules V22 Fix ; vérifier les droits et rejouer les cas discriminants.
7. Pour tout rejeu autorisé, vérifier d'abord les prérequis d'infrastructure, conserver les artefacts et exécuter les scénarios minimaux avant les campagnes complètes.
8. Ne rouvrir les questions `UNKNOWN` que lorsqu'une preuve nouvelle ou une décision fonctionnelle est disponible.

## Préparation du rejeu métier Export_Run — 2026-09-06

- **FACT** : la génération Console du plan complet `Export_Run` est validée avant/après, avec code `0` pour l'API originale et corrigée ; preuve `evidence/local-2026-09-06-export-complete-before-after/`.
- **UNKNOWN** : cette preuve ne couvre ni SQL, JMeter, HTTP, backup, services Y2/Authentication ni réussite des assertions métier. TC08 doit précéder TC09 puis TC10 dans une base dédiée, car les deux derniers dépendent de l'état laissé par TC08.
- **Voie recommandée** : environnement local dédié lorsque le backup, la pile V26 exacte, `cy2px`, SQL Server 2019, pilote JDBC, JMeter et services sont fournis. La définition `2054 — FrenchTaxesRules CI` et les runs historiques `4426342/6175734-6175735` sont des références, pas une autorisation de relance ; son YAML contient Publish/Promote/Tag et TestAutos sur `Y2-TSTAUTOXXPG2`.
- **Prochain essai** : définir une cible sandbox explicite, restaurer le backup Fix dédié, épingler les artefacts, puis exécuter uniquement TC08→TC09→TC10 et vérifier prérequêtes, réponses XML, contrôles post/final et nettoyage. Comparer ensuite à une seconde cible originale équivalente.

## Preuves principales

- `findings/001-french-taxes-rules-v26.md`
- `findings/004-french-taxes-rules-v21-v23-build-4429167.md`
- `findings/005-clienteling-v22-v23-build-4432602.md`
- `findings/006-clienteling-v26-build-4432554.md`
- `findings/007-clienteling-v24-build-4432652.md`
- `findings/008-clienteling-v25-build-4432672.md`
- `sources/Y2_Tools_AutoTest_Api/Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`
- dépôt `Pipelines_Docker_BaseImages`, fichiers `/Images/SqlExpress/2019/dockerfile`, `/Images/SqlExpress/2025/dockerfile` et `/Images/SqlExpress/tests.yml`, relus sur master le 2026-09-05 ;
- dépôt `Y2_Tools_PlatformDeploy`, fichier `/Src/Powershell/Code/Scripts/install-packages.ps1`, relu au commit master `93f91487ee717185599555a42df3cb5d024ace89` le 2026-09-05 ;
- `sources/Y2_Plugins_Clienteling-master-build-4432554-exact/Tests/Config/v26-cur.cy2px`
- `sources/Y2_Plugins_Clienteling-master-build-4432554-exact/Tests/Config/v26-fix.cy2px`
- `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml`
