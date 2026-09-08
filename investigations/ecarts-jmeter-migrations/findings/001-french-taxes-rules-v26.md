# FrenchTaxesRules V26 — résultats établis

## Périmètre

Build détaillé : 4432510, commit f80bc731571b2b5ed8a67da171b288873de428a6, V26 Cur/Fix, LegacyServices/WebServices.

Le handoff historique complet reste `../../../archive/handoffs/french-taxes-rules-v26-handoff-2026-09-05.md`. Cette fiche ne conserve que les verdicts nécessaires à la reprise multi-branches.

## Verdicts

| Sujet | Verdict | Résumé |
|---|---|---|
| Export TC08 | FACT | inversion mois/jour des dates SQL ISO apostrophées par AutoTest.Api |
| Export TC09/TC10 | FACT | cascades causées par la donnée résiduelle de TC08 |
| ExpectedValue=-1 | FACT, hypothèse réfutée | absence de contrôle du rowcount, pas acceptation d'une erreur SQL |
| TC99 | FACT sur JMeter ; UNKNOWN sur l'écart legacy | Code 99 reste actif ; deux cas de debug obtiennent HTTP 500 sous JMeter, tandis que les deux Test_99 correspondants sont `Passed` dans le TRX legacy Fix 26.0.10.25 ; packages et environnement non suffisamment comparables |
| TC22 | FACT sur le résultat legacy et JMeter | le même scénario et la même postcondition DAEMON échouent en legacy Fix 26.0.10.25 et sous JMeter avec `Expected 2 / Actual 1` ; cause fonctionnelle toujours UNKNOWN, mais ce n'est plus un cas legacy vert/JMeter rouge |
| Baseline legacy V26 | FACT sur 6/6 scénarios ; UNKNOWN sur la régression | les six identifiants JMeter non passés sont exécutés dans le TRX legacy aval : 5 `Passed`, 1 `Failed` ; plugin, backup et hôte diffèrent |

## Preuve legacy aval récupérée le 2026-09-06

Le fichier `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544_Y2_Plugin_Fix_sql.trx` contient 253 scénarios élémentaires : 252 `Passed` et un `Failed`. Les compteurs globaux du TRX incluent 21 conteneurs `orderedtest` et ne doivent pas être additionnés aux `UnitTestResult`.

Le rapprochement exact des six cas non passés du build 4432510 donne :

- FACT — `Export_Run` TC08, TC09 et TC10 sont `Passed` ;
- FACT — `Validation_ValidateClosingsV2` TC99 et `Validation_ValidateDocuments` TC99 sont `Passed` ;
- FACT — `FrenchTaxesRules_Run` TC22 est `Failed` avec `Assert.AreEqual failed. Expected:<2>. Actual:<1>. DAEMON`. Le JMX et le CSV 4432510 montrent la même attente `2` et le même résultat `1` sur la postcondition DAEMON.

Le XML frère `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544.xml` établit une exécution Fix SQL avec FrenchTaxesRules `26.0.10.25` et Core Fix `26.0.0.1762`. JMeter 4432510 utilise FrenchTaxesRules `26.0.10.75` dans un conteneur et l'équivalence du backup n'est pas démontrée. Les cinq couples legacy `Passed` / JMeter non passé restent donc `UNKNOWN — comparabilité insuffisante`, et non des régressions JMeter conclues.

## Preuve binaire complémentaire du 2026-09-05

La méthode privée EscapeJdbcDate a été invoquée directement par réflexion sur les DLL réellement empaquetées.

Résultat commun aux packages Console 2.0.41 et 2.0.42 :

| Entrée | Sortie binaire |
|---|---|
| '2015-12-01' | '20150112' |
| '2016-01-03' | '20160301' |
| 2016-02-01 | '20160201' |
| '20160103' | inchangée |

Le package courant 2.0.42 n'est donc pas un correctif.

## Portée supplémentaire dans le plugin

Les Query des plans legacy contiennent 12 occurrences de dates ISO apostrophées, réparties sur deux plans et six valeurs distinctes. Les transformations sémantiquement erronées concernent :

- DocumentSignature_SignOne TC02 : 2025-10-07 devient 20250710, deux colonnes dans une même insertion ; le cas passe car il ne contrôle pas cette date ;
- Export_Run TC08 : 2015-12-01 devient 20150112 ; 2016-01-03 devient 20160301 ;
- Export_Run TC09 : 2016-02-01 devient 20160102.

Les valeurs dont mois et jour sont égaux ne changent pas visuellement mais passent par la même règle fautive.

## Pièges de lecture des builds

- Les runs 4432320 et 4432365 sont verts mais le stage TI JMeter V26 est skipped ; seul le build applicatif est prouvé.
- Les artefacts WebServices de 4432510 embarquent une duplication byte-identique des 90 fichiers LegacyServices. Dédupliquer par chemin logique et hash avant comptage.

## Correctif durable attendu

## Validation locale ciblée du 2026-09-06

**FACT — correctif local compilé et génération JMX validée sur six fixtures.** La comparaison avec l'API originale démontre quatre inversions `yyyy-mm-dd` dans `EscapeJdbcDate` et deux témoins inchangés. Preuve avant/après : [`evidence/local-2026-09-06-api-jmx-date-before-after/`](../evidence/local-2026-09-06-api-jmx-date-before-after/), avec API originale code `1`, API corrigée code `0`, hashes, JMX et résultats conservés.

Cette preuve couvre l'API et l'appel public de génération sur fixtures locales uniquement. **UNKNOWN** : propagation dans Console, packaging/publication, image Docker et rejeu métier.

## Identités d'exécution vérifiées le 2026-09-07

**FACT — preuve JMeter directe du build 4432510.** L'artefact
`../evidence/build-4432510/_extracted/v26-Fix_LegacyServices_TestLogs-Attempt#1/Y2.Plugin.FrenchTaxesRules-LegacyServices-v26-Fix/009-FrenchTaxesRules_Run/009-FrenchTaxesRules_Run-results.xml`
annonce 542 tests et 1 échec. Le JTL frère identifie précisément `009-FrenchTaxesRules:Run - TC 22 - C-PostQuery1` :
`responseCode=200`, `responseMessage=OK`, `success=false`, `failureMessage=Test failed: variable(resultC-PostQuery1) expected to contain /=2/`.
La campagne a donc réellement exécuté TC22 ; ce n'est pas seulement une soumission ou un artefact de pipeline.

**FACT — environnement JMeter observé.** Le `jmeter.log` du même dossier établit JMeter `5.6.3`, Java `21.0.5`,
Windows Server 2022, hôte `bb8b9ffa2057`; le RunLogs Fix établit l'installation FrenchTaxesRules `26.0.10.75`,
SQL Server 2025 Express `17.0.1000.7` et la restauration de la base `AUTO_V26_00` depuis
`C:\__w\_temp\Deploy\docker\data\AUTO_V26_00.bak`. Les paramètres.properties ont été inspectés uniquement par
leurs noms de clés : les valeurs, notamment mots de passe et identifiants, n'ont pas été affichées.

**FACT — environnement legacy observé.** Le TRX exact porte `computerName=Y2-TSTAUTOXXPG2` et son en-tête nomme
`SvcTestAutoRetail@Y2-TSTAUTOXXPG2`; le XML d'exécution établit le plugin `26.0.10.25`, Fix SQL et Core Fix
`26.0.0.1762`. Le TRX donne TC22 `Failed`, `Expected:<2>. Actual:<1>. DAEMON`.

**UNKNOWN — comparabilité résiduelle.** Le hash et le contenu exact du backup legacy ne sont pas disponibles, les
valeurs effectives du payload/paramètres ne sont pas comparées, et les environnements JMeter et legacy sont distincts
(hôtes et piles SQL différents). Ces nouvelles identités renforcent le constat d'un échec JMeter réellement exécuté,
mais ne prouvent toujours pas une cause commune ni une régression de migration.

1. corriger l'ordre des groupes dans Y2_Tools_AutoTest_Api et ajouter des tests ;
2. incrémenter et publier l'API ;
3. mettre à jour Console vers cette API, incrémenter et publier Console ;
4. remplacer le package et versionConsole dans Migration_Jmeter_RJE_Sandbox ;
5. régénérer les JMX ;
6. comparer tous les JMX, puis rejouer Export TC08/09/10 sur base propre et DocumentSignature TC02.

La décision sur TC22 et les deux TC99 appartient aux propriétaires fonctionnels des scénarios.

## Préparation du rejeu métier Export_Run — 2026-09-06

**FACT — génération Console validée sur `Export_Run`** : le plan complet produit un JMX original et un JMX corrigé, Console code `0` dans les deux cas ; les différences sont limitées aux dates attendues. Preuve : [`evidence/local-2026-09-06-export-complete-before-after/`](../evidence/local-2026-09-06-export-complete-before-after/).

**UNKNOWN — réussite métier** : aucun JMeter, SQL, HTTP, backup ou environnement Y2 n'a été exécuté. Le rejeu doit restaurer un backup dédié, déployer une pile produit explicitement choisie et exécuter TC08 puis TC09 puis TC10 avec leurs prérequêtes et assertions réelles. La voie locale n'est pas prête : le worktree ne fournit ni `Tests/Config` ni backup. La définition Azure DevOps `2054 — FrenchTaxesRules CI` est identifiée par les preuves, mais son YAML comporte Publish/Promote/Tag et TestAutos sur `Y2-TSTAUTOXXPG2`; elle ne peut pas être utilisée comme espace isolé sans définition/paramétrage sandbox vérifié.
