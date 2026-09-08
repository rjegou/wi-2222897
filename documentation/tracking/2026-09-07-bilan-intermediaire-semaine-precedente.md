# Bilan intermédiaire — semaine précédente

## Provenance et portée

- **Date de réception/intégration :** 2026-09-07.
- **Source :** bilan fourni directement par l'utilisateur.
- **Date exacte des observations :** non fournie ; le libellé « semaine dernière » est conservé sans inventer de date de run.
- **Systèmes source déclarés :** Azure DevOps Builds et Pull Requests, TestAutos legacy (`Y2-TSTAUTOXXPG2` / `Y2-TSTAUTOXXPG3`), équipe Nova/Core.
- **Statut de fraîcheur :** snapshot rapporté, à revalider en lecture seule avant toute décision actuelle.
- **Portée :** inventaire intermédiaire des couples dépôt/branche/version, nombre de tests, état, VM legacy, équipe, maximum d'échecs et lien/commentaire JMeter.

Les états, nombres d'échecs et états de PR ci-dessous sont des **FACTS rapportés dans le bilan reçu**, pas une vérification live effectuée pendant cette intégration. La réussite ou l'échec métier des tests, la cause des jobs en échec et la comparabilité legacy/JMeter restent **UNKNOWN** lorsqu'elles ne sont pas prouvées par des artefacts inspectés.

## Lignes reçues

| Nom | Branches | Versions | Nb TC | State | Vm Tests Legacy | Team | Max fails | Jmeter / lien / commentaire |
|---|---|---:|---:|---|---|---|---:|---|
| Y2_Plugins_FrenchTaxesRules | master | 26 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova | 4 | legacyServices : 4 fails ; webservices : 2 fails. [Build 4426342](https://dev.azure.com/cegid/Retail/_build/results?buildId=4426342&view=results) |
| Y2_Plugins_FrenchTaxesRules | releases/V1 | 13 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova |  | PR en cours : [505942](https://dev.azure.com/cegid/Retail/_git/Y2_Plugins_FrenchTaxesRules/pullrequest/505942) |
| Y2_Plugins_FrenchTaxesRules | releases/V2 | 14 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova |  | PR en cours : [505951](https://dev.azure.com/cegid/Retail/_git/Y2_Plugins_FrenchTaxesRules/pullrequest/505951) |
| Y2_Plugins_FrenchTaxesRules | releases/V3 | 18-19 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova |  | PR en cours : [505958](https://dev.azure.com/cegid/Retail/_git/Y2_Plugins_FrenchTaxesRules/pullrequest/505958) |
| Y2_Plugins_FrenchTaxesRules | releases/V4 | 20 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova |  | PR en cours : [505964](https://dev.azure.com/cegid/Retail/_git/Y2_Plugins_FrenchTaxesRules/pullrequest/505964) |
| Y2_Plugins_FrenchTaxesRules | releases/V5 | 21-23 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova | 138 | V22 : cur 0 fail, fix 138 fails ; V23 : cur 0 fail, fix : job en échec sur `InitializeContainers`. [Build 4429167](https://dev.azure.com/cegid/Retail/_build/results?buildId=4429167&view=results) |
| Y2_Plugins_FrenchTaxesRules | releases/V6 | 24 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova |  | PR en cours : [505832](https://dev.azure.com/cegid/Retail/_git/Y2_Plugins_FrenchTaxesRules/pullrequest/505832) |
| Y2_Plugins_FrenchTaxesRules | releases/V7 | 25 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova | 90 | fix : 42 fails ; cur : 90 fails. [Build 4429629](https://dev.azure.com/cegid/Retail/_build/results?buildId=4429629&view=results) |
| Y2_Plugins_InventoryTracking | master | 26 |  | InProgress | Y2-TSTAUTOXXPG3 | Core |  | Build en échec : [4434070](https://dev.azure.com/cegid/Retail/_build/results?buildId=4434070&view=results) |
| Y2_Plugins_InventoryTracking | releases/V1 | 14 |  | InProgress | Y2-TSTAUTOXXPG3 | Core |  | Aucun build lancé sur cette branche tant que les builds en échec des branches des versions > V21 ne sont pas élucidés. |
| Y2_Plugins_InventoryTracking | releases/V2 | 18-19 |  | InProgress | Y2-TSTAUTOXXPG3 | Core |  | Aucun build lancé sur cette branche tant que les builds en échec des branches des versions > V21 ne sont pas élucidés. |
| Y2_Plugins_InventoryTracking | releases/V3 | 20 |  | InProgress | Y2-TSTAUTOXXPG3 | Core |  | Aucun build lancé sur cette branche tant que les builds en échec des branches des versions > V21 ne sont pas élucidés. |
| Y2_Plugins_InventoryTracking | releases/V4 | 21 |  | InProgress | Y2-TSTAUTOXXPG3 | Core |  | Aucun build lancé sur cette branche tant que les builds en échec des branches des versions > V21 ne sont pas élucidés. |
| Y2_Plugins_InventoryTracking | releases/V5 | 22-23 |  | InProgress | Y2-TSTAUTOXXPG3 | Core |  | Build en échec : [4432364](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432364&view=results) |
| Y2_Plugins_InventoryTracking | releases/V6 | 24-25 |  | InProgress | Y2-TSTAUTOXXPG3 | Core |  | Build en échec : [4432476](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432476&view=results) |
| Y2_Plugins_Clienteling | master | 26 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova | 485 | 485 fails (fix et cur). [Build 4432554](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432554&view=results) |
| Y2_Plugins_Clienteling | releases/V6 | 21-23 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova | 383 | V22 : cur 383 fails ; fix : job en échec sur `Test Y2 deployment`. V23 : cur 388 fails ; fix : job en échec sur `Test Y2 deployment`. [Build 4432602](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432602&view=results) |
| Y2_Plugins_Clienteling | releases/V7 | 24 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova | 380 | 380 fails (fix et cur). [Build 4432652](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432652&view=results) |
| Y2_Plugins_Clienteling | releases/V8 | 25 |  | InProgress | Y2-TSTAUTOXXPG2 | Nova | 482 | 482 fails (fix et cur). [Build 4432672](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432672&view=results) |

## Limites de réutilisation

- Les colonnes `Nb TC` n'étaient pas renseignées dans le bilan reçu ; les cellules sont laissées vides.
- `Max fails` est conservé tel que fourni et n'est pas recalculé à partir des commentaires.
- « PR en cours », « build en échec », `cur`, `fix` et `InProgress` ne sont pas reclassés sans relecture live des objets Azure DevOps associés.
- Ce snapshot complète les précédentes investigations ; il ne remplace pas les preuves détaillées ni la matrice legacy/JMeter.
