# FrenchTaxesRules master V26 — rapprochement du build 4426342

Date de l'analyse : 2026-09-05.

## Verdict

Le build `4426342`, commit `358fe9507e0eb1a4601437ec0c9db6bf197015cc`, reproduit les six cas non passés déjà expliqués sur le build `4432510` : quatre en LegacyServices et deux en WebServices, dans Cur comme dans Fix.

Les conclusions causales de `001-french-taxes-rules-v26.md` sont applicables à ces six cas parce que :

- leurs clés `plan | TestCase | opération` correspondent exactement entre les deux builds ;
- les 19 fichiers JMeter des commits `358fe950` et `f80bc731` ont tous le même blob Git ;
- les erreurs Legacy ont les mêmes champs `OpError` et `XmlResError` ;
- les deux erreurs Web sont encore des réponses HTTP 500 portant le code métier `CBR_062_0005`.

Cette reproduction ne rend pas les environnements identiques. Le plugin FrenchTaxesRules du build `4426342` est `26.0.10.67`, contre `26.0.10.75` observé dans les journaux du build `4432510`. Les valeurs SQL et les identifiants propres aux exécutions diffèrent aussi.

## Résultats Azure DevOps

| Variante | Campagne | Run | Total | Passed | Non passés |
|---|---|---:|---:|---:|---:|
| Fix | LegacyServices | 6175734 | 187 | 183 | 4 |
| Cur | LegacyServices | 6175735 | 187 | 183 | 4 |
| Fix | WebServices | 6175746 | 66 | 64 | 2 |
| Cur | WebServices | 6175748 | 66 | 64 | 2 |

Azure renseigne ces cas dans `unanalyzedTests`. Le run unitaire `6175398`, sans échec, n'appartient pas aux campagnes JMeter et est exclu.

## Correspondance des six cas

| Campagne | Plan | Cas | Première opération en faute | Cause reprise | Niveau de preuve |
|---|---|---|---|---|---|
| LegacyServices | 009-FrenchTaxesRules:Run | TC 22 | C-PostQuery1 | sélection indéterministe ou scénario obsolète | INFERENCE FORTE |
| LegacyServices | 010-Export:Run | TC 08 | C-PostQuery1 | dates SQL ISO inversées par AutoTest.Api | FACT |
| LegacyServices | 010-Export:Run | TC 09 | A-PreQuery3 | doublon laissé par TC08 | FACT, cascade |
| LegacyServices | 010-Export:Run | TC 10 | C-PostQuery2 | ligne résiduelle laissée par TC08 | FACT, cascade |
| WebServices | 003-Validation:ValidateClosingsV2 | TC 99 | B-XQuery | HTTP 500 / `CBR_062_0005`, contrat à décider | FACT sur le symptôme ; cause produit/scénario UNKNOWN |
| WebServices | 004-Validation:ValidateDocuments | TC 99 | B-XQuery | HTTP 500 / `CBR_062_0005`, contrat à décider | FACT sur le symptôme ; cause produit/scénario UNKNOWN |

Le code `99` n'est pas une règle de skip : ces deux cas ont réellement été exécutés. Le rapprochement ne relève pas le niveau de preuve de TC22 ni des TC99 ; il confirme seulement leur reproduction sur un autre build.

## Comparaison des sources

Les commits `358fe950` et `f80bc731` n'ont pas de merge-base dans le clone local : le second est un commit racine de migration. Une comparaison par ascendance aurait donc été trompeuse.

La comparaison par contenu donne 19 plans `.jmx` dans chaque commit, 19 blobs identiques et zéro différence. Cela inclut :

- `Tests/LegacyServices/009-FrenchTaxesRules_Run.jmx` ;
- `Tests/LegacyServices/010-Export_Run.jmx` ;
- `Tests/WebServices/003-Validation_ValidateClosingsV2.jmx` ;
- `Tests/WebServices/004-Validation_ValidateDocuments.jmx`.

Le snapshot exact de `358fe950` est exporté sans métadonnées Git sous `sources/Y2_Plugins_FrenchTaxesRules-master-build-4426342`. Son archive SHA-256 est `69895545DE8D47F710D22069E99AEE01C3AD13B78427E5A7C1F0CFACCFEB2EB2` ; les 19 JMX extraits ont été reverifiés contre leurs blobs Git.

## Limite legacy

La preuve aval récupérée le 2026-09-06 contient les six scénarios exacts de ce build dans `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544_Y2_Plugin_Fix_sql.trx` : Export TC08-10 et les deux Validation TC99 sont `Passed`; `FrenchTaxesRules_Run` TC22 est `Failed` avec la même postcondition DAEMON, `Expected 2 / Actual 1`.

FACT — TC22 n'est plus un cas legacy vert/JMeter rouge. UNKNOWN — les cinq autres différences ne suffisent pas à qualifier une régression JMeter : le legacy utilise FrenchTaxesRules `26.0.10.25`, ce build JMeter `26.0.10.67`, et ni le backup ni l'environnement VM/conteneur ne sont démontrés équivalents. Le run Azure `4432288/6180090` de 522 tests reste une preuve distincte sur les tests de composants ; il ne doit pas être confondu avec ce TRX aval d'intégration.

## Intégrité et suite

- Les huit artefacts utiles sont conservés et extraits sous `evidence/build-4426342`.
- Les artefacts WebServices contiennent chacun une copie des 90 fichiers LegacyServices ; elle est byte-identique à l'artefact LegacyServices correspondant et a été exclue du comptage.
- Le package `26.0.10.67` est confirmé par les deux journaux de déploiement Cur/Fix.
- Aucune réponse d'authentification brute n'est reproduite dans cette fiche.

La suite est celle de la fiche `001` : corriger et tester `EscapeJdbcDate`, republier API puis Console, régénérer les JMX et rejouer Export TC08/09/10 sur base propre. TC22 et les deux TC99 demandent une décision fonctionnelle séparée.
