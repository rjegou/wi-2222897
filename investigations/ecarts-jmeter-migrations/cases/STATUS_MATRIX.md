# Matrice de suivi des investigations

Les valeurs de la colonne Observation utilisateur proviennent de la capture du 2026-09-05. Elles ne deviennent des faits qu'après lecture des runs et artefacts Azure DevOps.

| Plugin | Branche | Versions | Build | Commit du build | Observation utilisateur | Vérification courante | Statut | Prochaine preuve |
|---|---|---|---:|---|---|---|---|---|
| FrenchTaxesRules | master | 26 | 4426342 | 358fe9507e0eb1a4601437ec0c9db6bf197015cc | LegacyServices 4 ; WebServices 2 | Runs : 4 Legacy + 2 Web dans Cur comme Fix ; mêmes six clés que 4432510 ; 19/19 JMX byte-identiques | TERMINE, CAUSES REPRODUITES | appliquer le correctif et les rejeux de findings/001 et findings/009 ; ne pas conclure à une régression legacy sans baseline comparable |
| FrenchTaxesRules | releases/V5 | 21-23 | 4429167 | 2d826b8fd19ecb4d7200f574414efb7583de8ed2 | V22 Cur 0/Fix 138 ; V23 Cur 0/Fix InitializeContainers | V21 skipped ; V22 Cur 0, Fix 174 = 138 Legacy + 36 Web ; V23 Cur 0, Fix aucun run (Docker) | TERMINE, SOUS-COMPTAGE CAPTURE | corriger les droits V22 Fix et rejouer V23 Fix sur un agent Docker sain |
| FrenchTaxesRules | investigation/wi-2222897-v22-preflight-20260907 | V22 runtime preflight | 4442696 | 68f1f7a8e575e79cf3098cafcd16e10b22237ada | Préflight borné réussi | Image/OS/arch/target/mounts/networks/ports PASS ; mounts 0, dangerous 0 ; containerPresentAfterRemove=False ; Config.Volumes/ID complet non persistés | PRÉFLIGHT RÉUSSI, ISOLATION FUTURE UNKNOWN | conserver UNKNOWN historique/futurs jobs ; aucune campagne métier déduite |
| FrenchTaxesRules | releases/V7 | 25 | 4429629 | 657a61cd6d6d08cac698517309077202c43a29f8 | Fix 42 ; Cur 90 | Runs et artefacts : Fix 90 ; Cur 42 ; 132/132 cas groupés | TERMINE, LIBELLES CAPTURE INVERSES | exécuter les rejeux discriminants de findings/003 pour séparer les UNKNOWN produit/scénario |
| Clienteling | master | 26 | 4432554 | 1bcb509c38c31d337fcc5419c7b89d61a19fbe3a | 485 en Cur et Fix | Runs 6180736/6180750 : 2 118 tests, 1 633 passés, 485 non passés chacun ; 485/485 cas couverts | TERMINE, DEUX RUNS IDENTIQUES PAR CAUSE | corriger FTS, les défauts API et les métadonnées/fixtures ; exécuter les rejeux discriminants de findings/006 |
| Clienteling | releases/V6 | 21-23 | 4432602 | 8744999cabb6cea993db49a2d2bf741ae2dd5454 | V22 Cur 383/Fix déploiement ; V23 Cur 388/Fix déploiement | V21 skipped ; V22 Cur 383, V23 Cur 388, tous couverts ; Fix sans run par incompatibilités MSI | TERMINE, DEUX TOTAUX REELS | corriger l'image FTS, les trois défauts API, les métadonnées/fixtures Clienteling et relever les minima Fix ; rejouer les tests discriminants de findings/005 |
| Clienteling | releases/V7 | 24 | 4432652 | a3b9c933ddeaaf1846785ea6bc044e4bf4a083bb | 380 en Cur et Fix | Runs 6180729/6180751 : 2 118 tests, 1 738 passés, 380 non passés chacun ; 380/380 cas couverts | TERMINE, DEUX RUNS IDENTIQUES PAR CAUSE | corriger FTS, les défauts API et les métadonnées/fixtures ; exécuter les rejeux discriminants de findings/007 sans conclure à un écart legacy |
| Clienteling | releases/V8 | 25 | 4432672 | 8f1088fb5f0d54fc7bb17caf351b98edcaa67706 | 482 en Cur et Fix | Runs 6180806/6180903 : 2 118 tests, 1 636 passés, 482 non passés chacun ; 482/482 cas couverts | TERMINE, DEUX RUNS IDENTIQUES PAR CAUSE | corriger FTS, les défauts API et les métadonnées/fixtures ; exécuter les rejeux discriminants de findings/008 sans conclure à un écart legacy |
| InventoryTracking | migration branch `InventoryTracking_Migration_AutoTest_Jmeter_On_master` | 26 | 4434070 | 4de185bb132cfbfb50643b6b53d6feb85508f4e2 | Build V26 échoue sur XmlDiff ; stages JMeter skipped | XmlDiff non résolu après suppression de WebServices.Tests/packages.config ; cause immédiate FACT, mécanisme restore/package/template UNKNOWN | DIAGNOSTIC PARTIEL | valider localement une restauration/référence minimale puis relire PR et décider d'un run dédié |

## Comparaison avec les Test Runs legacy

La collecte du 2026-09-05 est détaillée dans `LEGACY_COMPARISON_MATRIX.md` et `../evidence/LEGACY_TEST_INVENTORY.md`. Les TRX MSTest ont été analysés comme des tests legacy : `JsonWriteTest1` et `XmlWriteTest1` de FrenchTaxesRules exécutent une analyse métier sur des fixtures et génèrent des rapports. Ils ne démontrent toutefois pas une équivalence cas à cas avec les plans JMeter HTTP/DB. Les TRX Clienteling collectés ce jour-là sont vides (zéro résultat), ce qui ne prouve pas une désactivation.

Mise à jour du 2026-09-06 : les preuves aval récupérées directement sur Y2-TSTAUTOXXPG2 complètent, sans les remplacer, les Test Runs Azure DevOps ci-dessus.

| Périmètre | Exécution legacy réellement prouvée | Impact sur le verdict |
|---|---|---|
| FrenchTaxesRules master V26 Fix SQL | plugin `26.0.10.25`, 253 scénarios élémentaires : 252 `Passed`, TC22 `Failed` ; les 6 cas JMeter non passés sont tous retrouvés | TC22 échoue aussi en legacy avec `Expected 2 / Actual 1` ; les 5 autres restent `UNKNOWN — comparabilité insuffisante`, pas régression JMeter démontrée |
| Clienteling master V26 Fix SQL | plugin `26.0.10.18`, 2 131 scénarios élémentaires : 2 130 `Passed`, CreateReceipt TC32 `Failed` ; les 485 cas JMeter non passés sont tous retrouvés | TC32 échoue aussi en legacy sur la même postcondition ; les 484 autres restent `UNKNOWN — comparabilité insuffisante` avec JMeter `26.0.10.23` |
| FrenchTaxesRules V5/V7 | captures récupérées arrêtées avant MSTest, dossier projet absent | aucun scénario legacy comparable établi pour V21-V25 |
| Clienteling V6/V7/V8 | V6 sans rapport, V7 avec XML de zéro octet, V8 arrêté avant MSTest | aucun scénario legacy comparable établi pour V22-V25 |

Preuves et listes exactes : `../evidence/legacy/curated/00_START_HERE.md`, `LEGACY_COMPARISON_MATRIX.md` et `../evidence/LEGACY_TEST_INVENTORY.md`.

## Référence analysée hors capture

| Plugin | Branche | Build | Commit | Résultat utile |
|---|---|---:|---|---|
| FrenchTaxesRules | master | 4432510 | f80bc731571b2b5ed8a67da171b288873de428a6 | 4 échecs LegacyServices et 2 WebServices dans Cur comme Fix ; causes détaillées dans findings/001-french-taxes-rules-v26.md |
