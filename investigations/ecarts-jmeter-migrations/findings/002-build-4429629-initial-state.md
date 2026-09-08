# FrenchTaxesRules releases/V7 V25 — état initial du build 4429629

> État initial désormais complété par [003-french-taxes-rules-v25-build-4429629.md](003-french-taxes-rules-v25-build-4429629.md), qui couvre les 132 échecs publiés.

## Faits Azure DevOps

- Définition : FrenchTaxesRules CI.
- Branche du build : FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V7.
- Commit du build : 657a61cd6d6d08cac698517309077202c43a29f8.
- Paramètres : V25, Cur et Fix, campagnes LegacyServices et WebServices, pipelineDevMode=true.
- Résultat : partiallySucceeded ; le stage Build est succeeded et TI JMeter V25 est succeededWithIssues.

## Résultats publiés

| Run | Nom | Total | Passed | Failed |
|---:|---|---:|---:|---:|
| 6178258 | LegacyServices-v25-Fix | 185 | 136 | 49 |
| 6178260 | WebServices-v25-Fix | 65 | 24 | 41 |
| 6178259 | LegacyServices-v25-Cur | 185 | 155 | 30 |
| 6178261 | WebServices-v25-Cur | 65 | 53 | 12 |

Totaux Azure : Fix 90, Cur 42.

## Conflit résolu

La capture utilisateur indique Fix 42 et Cur 90. Les noms des quatre runs Azure, les compteurs détaillés et les quatre CSV d'erreurs indiquent l'inverse. Les artefacts confirment donc que la capture a inversé les libellés : Fix 90, Cur 42.

## Dérive de branche

Le clone local sources/Y2_Plugins_FrenchTaxesRules-v7-build-4429629 est détaché sur 657a61cd, donc fidèle au build. La branche distante pointe désormais vers 54e9227cd2d7cd7a84d8068dfff0ece6102dfa28.

Le seul commit postérieur constaté est Updated azure-pipelines.yml. Il remplace la boucle paramétrée versionsToTest par un stage V25 explicite. Aucun nouveau build de la branche n'a été trouvé après 4429629. Cette modification n'est donc pas une preuve de correction des 132 échecs.

## Résultat de l'étape suivante

Les six artefacts demandés et les deux artefacts de déploiement ont été téléchargés et extraits. Les copies LegacyServices présentes dans les artefacts WebServices sont byte-identiques et ont été exclues. Les quatre CSV uniques totalisent 132 TestCases en échec, tous classés dans la fiche 003.
