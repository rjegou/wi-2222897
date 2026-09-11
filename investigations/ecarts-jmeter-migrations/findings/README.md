# Conclusions d'investigation

Chaque fichier numéroté porte une conclusion bornée par un build ou un sujet. Lire la matrice avant de choisir une fiche.

| Fiche | Périmètre |
|---|---|
| [001-french-taxes-rules-v26.md](001-french-taxes-rules-v26.md) | causes détaillées FrenchTaxesRules V26 |
| [002-build-4429629-initial-state.md](002-build-4429629-initial-state.md) | état initial et contradictions du build 4429629 |
| [003-french-taxes-rules-v25-build-4429629.md](003-french-taxes-rules-v25-build-4429629.md) | FrenchTaxesRules V25 |
| [004-french-taxes-rules-v21-v23-build-4429167.md](004-french-taxes-rules-v21-v23-build-4429167.md) | FrenchTaxesRules V21 à V23 |
| [005-clienteling-v22-v23-build-4432602.md](005-clienteling-v22-v23-build-4432602.md) | Clienteling V22/V23 |
| [006-clienteling-v26-build-4432554.md](006-clienteling-v26-build-4432554.md) | Clienteling V26 |
| [007-clienteling-v24-build-4432652.md](007-clienteling-v24-build-4432652.md) | Clienteling V24 |
| [008-clienteling-v25-build-4432672.md](008-clienteling-v25-build-4432672.md) | Clienteling V25 |
| [009-french-taxes-rules-v26-build-4426342.md](009-french-taxes-rules-v26-build-4426342.md) | reproduction FrenchTaxesRules V26 |
| [010-v26-fix-replay-draft-review.md](010-v26-fix-replay-draft-review.md) | revue documentaire du brouillon pipeline V26 Fix |
| [011-v26-fix-jmx-consumption.md](011-v26-fix-jmx-consumption.md) | chaîne de consommation JMX Export_Run |
| [012-jmeter-5-6-3-xpath-namespace.md](012-jmeter-5-6-3-xpath-namespace.md) | sémantique réelle XPathAssertion et impact CleanXpath |
| [013-inventorytracking-xmlDiff-migration-build-4434070.md](013-inventorytracking-xmlDiff-migration-build-4434070.md) | InventoryTracking migration 4434070 et dépendance XmlDiff |
| [014-sql-fulltext-runtime-4442685.md](014-sql-fulltext-runtime-4442685.md) | diagnostic runtime SQL Full-Text 4442685 |
| [015-inventorytracking-002-device-reassign-jmx-load-4445575.md](015-inventorytracking-002-device-reassign-jmx-load-4445575.md) | InventoryTracking 4445575 — campagne `002-Device:Reassign` lancée mais non chargée par JMeter, 86 tests de couverture perdus |
| [016-clienteling-v26-backup-lfs-absent.md](016-clienteling-v26-backup-lfs-absent.md) | Clienteling V26 — backup `AUTO_V26_00.bak` absent de l'arbre Git actuel, agent `windows-2025` Docker-compatible et valeurs PlatformDeploy résolues |
| [017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md](017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md) | Reprise directe AzDO — déblocage et exécution réelle des campagnes InventoryTracking (4447425) et FrenchTaxesRules (4447508), diagnostic attestation Clienteling |
| [018-frenchtaxesrules-v26-jmeter-execution-4448787.md](018-frenchtaxesrules-v26-jmeter-execution-4448787.md) | FrenchTaxesRules V26 — exécution JMeter réelle rapportée (build 4448787) : 253 tests Cur/Fix, 51 échecs communs identiques ; `rapporté, non revérifié` |
| [019-clienteling-v26-generatejmx-testcampaign-outputfiles.md](019-clienteling-v26-generatejmx-testcampaign-outputfiles.md) | Clienteling V26 — `GenerateJmx` débloqué (Product.Version, BuildPlatform), OutputFiles/InputFiles manquants du manifeste de migration, Console `--tstj` exigeant un `TestCampaign` et non un `TestPlan` ; aucun JMeter Cur/Fix encore atteint ; `rapporté, non revérifié` |
| [020-attestation-campagne-round4-transport-local-candidat.md](020-attestation-campagne-round4-transport-local-candidat.md) | Re-collecte round 4 des builds 4447425/4440884/4445575/4432554 (comptes Cur/Fix, JMX Git au sourceVersion, cleanup requalifié `UNKNOWN`) et gabarit candidat de transport local de package dérivé des findings 017/018 ; `rapporté, non revérifié` |
| [021-frenchtaxesrules-v26-run-4452790-cy2px.md](021-frenchtaxesrules-v26-run-4452790-cy2px.md) | FrenchTaxesRules V26 — tags Docker et frontières `Step_04` rapportés ; run 4452790 bloqué avant JMeter sur `*.cy2px` ; `rapporté, non revérifié` |
| [022-clienteling-v26-replay-jfrog-download-4452826.md](022-clienteling-v26-replay-jfrog-download-4452826.md) | Clienteling V26 — replay 14264 rapporté jusqu'au téléchargement JFrog ; run 4452826 bloqué dans `download-packages.ps1`, aucun JMeter Cur/Fix ; `rapporté, non revérifié` |
| [023-frenchtaxesrules-v22-v23-packaging-validation-20260910.md](023-frenchtaxesrules-v22-v23-packaging-validation-20260910.md) | FrenchTaxesRules V22/V23 — combinaison V22 rapportée validée, blocage V23 avant JMeter et test Identity discriminant ; `rapporté, non revérifié` |
| [024-inventorytracking-legacy-tests-branch-routing.md](024-inventorytracking-legacy-tests-branch-routing.md) | InventoryTracking — Testing Manager/TestAutos limité au YAML historique `master`/`releases/*`; YAML de migration séparé, JMeter conditionnel |
| [025-frenchtaxesrules-legacy-log-recovery-4459782.md](025-frenchtaxesrules-legacy-log-recovery-4459782.md) | FrenchTaxesRules — run Legacy `4459782` rapporté arrêté avant MSTest, avec symptôme analogue rapporté sur InventoryTracking PG3 ; hypothèse JFrog/PowerShell |
| [026-frenchtaxesrules-legacy-baseline-4462232.md](026-frenchtaxesrules-legacy-baseline-4462232.md) | FrenchTaxesRules master — baseline Legacy locale 10.95 / build 4462232 : 274 compteurs TRX, 1/44 échecs élémentaires Fix/Current |

Pour ajouter une fiche, utiliser le prochain numéro, citer les preuves exactes, distinguer `FACT/INFERENCE/UNKNOWN`, identifier la première faute causale, préciser le propriétaire probable ou inconnu et définir un rejeu discriminant.
