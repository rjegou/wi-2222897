# Reprise directe Azure DevOps — InventoryTracking, FrenchTaxesRules et Clienteling

Date : 2026-09-08 Europe/Paris.  
Exécution directe sans sollicitation de `brain-worker` (bw), conformément à la mission d'archive `brain-worker-2026-09-08T16-29-38-848Z-17356-03c7e2f30f82.txt`.

## Provenance et identifiants

- **Système** : Azure DevOps `cegid/Retail`.
- **Authentification** : PAT en mémoire depuis le chemin sécurisé de l'utilisateur, `X-TFS-FedAuthRedirect: Suppress`. Aucun secret stocké, journalisé ou persisté.
- **InventoryTracking** :
  - Définition : `2072` (`InventoryTracking CI`).
  - Branche : `refs/heads/validation/WI-2222897-inventorytracking-azdo-20260908`.
  - Commit : `be3c9ac35e3424a1a9cfb5c7b2da0bb31edc0437`.
  - Run : `4447425` ([URL AzDO](https://dev.azure.com/cegid/Retail/_build/results?buildId=4447425)).
  - Statut : `completed` / `partiallySucceeded` (17:55:05 UTC).
  - JMX corrigé : `Tests/WebServices/002-Device_Reassign.jmx` (4 098 624 octets, SHA-256 `FC39A5A8F3850293AB1A863928CFA574BC4F3B20941A17F978212F47D606E8C2`), tag `<hashTree/>` structurellement restauré après le `JSR223PostProcessor` de TC122.
- **FrenchTaxesRules** :
  - Définition canonique : `2054` (`FrenchTaxesRules CI`).
  - Branche : `refs/heads/validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908`.
  - Commit initial BW1 : `1ad0db014afe95acc4a0e01d318c2b37c9393a7f`.
  - Commit de durcissement isolé : `b82c5452b45ac857b60b72637d37eb81df38a41a` (`Ensure_Docker_Image_Up_To_Date` désactivé par `condition: false`, `pr: none`, `Publish` et `Promote` maintenus désactivés).
  - Runs bloqués annulés : `4447417` (déf. 14268) et `4447436` (déf. 14269).
  - Runs réels exécutés : `4447499` et `4447508` ([URL AzDO 4447508](https://dev.azure.com/cegid/Retail/_build/results?buildId=4447508)).
  - Statut : `completed` / `failed` (arrêt à `Launch Y2 deployment`).
- **Clienteling** :
  - Définition : `14264` (`WI-2222897 Clienteling Isolated Replay`).
  - Branche : `refs/heads/sandbox/clienteling/wi2222897-isolated-replay`.
  - Commit : `c8084be656e918f409fa962053a77dff9928acbd`.
  - Run diagnostic : `4447427` (`succeeded`, LFS `AUTO_V26_00.bak` matérialisé à 156 663 808 octets).
  - Run préflight : `4447443` (`failed`, `Dedicated target attestation is required.`).

## Faits établis (FACT)

1. `FACT` — **InventoryTracking (run 4447425)** :
   - Lancé à 16:43:12 UTC, achevé à 17:55:05 UTC.
   - Les étapes `Build V26`, `Docker preflight for isolated JMeter`, `Initialize containers`, `Launch Y2 deployment` et `Test Y2 deployment` ont toutes réussi pour Cur et Fix.
   - **Campagne JMeter Fix (Test Run 6189957)** :
     - Durée : 38m26s (17:04:08 à 17:42:34 UTC).
     - **Volume total : exactement 1991 tests** (1651 Passed, 340 Failed).
     - **Restauration des 86 tests perdus de `002-Device:Reassign`** : 63 Passed, 23 Failed.
     - **Test `TC122`** : exécuté, résultat `Failed` (`B-XQuery:Internal Server Error ;| C-PostQuery1:OK ;| C-PostQuery2:OK`).
   - **Campagne JMeter Cur (Test Run 6189960)** :
     - Durée : 47m21s (17:06:04 à 17:53:25 UTC).
     - **Volume total : exactement 1991 tests** (1652 Passed, 339 Failed).
     - **Restauration des 86 tests perdus de `002-Device:Reassign`** : 64 Passed, 22 Failed.
     - **Test `TC122`** : exécuté, résultat `Passed`.
   - **Comparaison bit-à-bit avec la baseline historique `4440884`** :
     - Fix baseline `4440884` (Run 6185924) : 1991 tests, 1651 Passed, 340 Failed.
     - Fix actuel `4447425` (Run 6189957) : 1991 tests, 1651 Passed, 340 Failed.
     - Cur baseline `4440884` (Run 6185925) : 1991 tests, 1652 Passed, 339 Failed.
     - Cur actuel `4447425` (Run 6189960) : 1991 tests, 1652 Passed, 339 Failed.
     - **Parité absolue 100% avec la baseline**.
     - L'unique delta entre Cur et Fix sur les 1991 tests est rigoureusement `TC122`.
   - **Artefacts de log publiés** :
     - `v26-Fix_WebServices_TestLogs-Attempt#1` (ID `5040181`)
     - `v26-Cur_WebServices_TestLogs-Attempt#1` (ID `5040214`)
     - `v26-Fix_Deployment_logs` (ID `5040062`)
     - `v26-Cur_Deployment_logs` (ID `5040073`)

2. `FACT` — **FrenchTaxesRules (runs 4447499 et 4447508)** :
   - Les définitions dédiées créées par BW1 (`14268` et `14269`) étaient bloquées indéfiniment sur `Checkpoint.Authorization` car le service endpoint ACR `AzureContainerRegistry-Docker-Retail` (`5fc079c9-4b68-403f-8c57-40274d100a94`) n'y était pas autorisé, alors qu'il l'est sur la définition CI `2054`.
   - Sur la définition `2054`, avec la branche durcie au commit `b82c5452` (`Ensure_Docker_Image_Up_To_Date: condition: false`, `pr: none`), les checkpoints et étapes pré-déploiement ont réussi.
   - Les conteneurs ont été initialisés avec succès.
   - L'étape `Launch Y2 deployment` a échoué avec l'erreur :  
     `[error] Artifact Y2.Plugin.FrenchTaxesRules in version 26.0.10.77 not found in Staging`.
   - Cause racine : Le template standard `task-deploy-in-containerized-job.v2.yml@leoTemplates` télécharge le package MSI depuis Artifactory staging (`retail-software-staging`). Worker 1 avait forcé `condition: false` sur le job `Publish to ArtifactoryCloud staging`. En l'absence du module de transport local (tel qu'implémenté dans InventoryTracking pour copier les MSI depuis les PipelineArtifacts du build), `PlatformDeploy` ne trouve pas le package.

3. `FACT` — **Clienteling (diagnostic LFS et préflight)** :
   - Le run `4447427` prouve que l'objet LFS `AUTO_V26_00.bak` (156 663 808 octets, SHA-256 `8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C`) est parfaitement résolu et extrait sur agent Windows 2025.
   - Le préflight `4447443` a échoué car `Assert-Wi2222897ArtifactManifest.ps1:55` exige un fichier `target-attestation.json` avec des métadonnées d'hôte dédié (`appHost`, `dbHost`, `cleanupScope`).
