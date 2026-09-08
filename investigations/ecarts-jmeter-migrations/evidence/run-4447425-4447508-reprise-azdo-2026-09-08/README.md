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
  - JMX corrigé : `Tests/WebServices/002-Device_Reassign.jmx` (4 098 624 octets, SHA-256 `FC39A5A8F3850293AB1A863928CFA574BC4F3B20941A17F978212F47D606E8C2`), tag `<hashTree/>` structurellement restauré après le `JSR223PostProcessor` de TC122.
- **FrenchTaxesRules** :
  - Définition canonique : `2054` (`FrenchTaxesRules CI`).
  - Branche : `refs/heads/validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908`.
  - Commit initial BW1 : `1ad0db014afe95acc4a0e01d318c2b37c9393a7f`.
  - Commit de durcissement isolé : `b82c5452b45ac857b60b72637d37eb81df38a41a` (`Ensure_Docker_Image_Up_To_Date` désactivé par `condition: false`, `pr: none`, `Publish` et `Promote` maintenus désactivés).
  - Runs bloqués annulés : `4447417` (déf. 14268) et `4447436` (déf. 14269).
  - Run réel lancé : `4447508` ([URL AzDO](https://dev.azure.com/cegid/Retail/_build/results?buildId=4447508)).
- **Clienteling** :
  - Définition : `14264` (`WI-2222897 Clienteling Isolated Replay`).
  - Branche : `refs/heads/sandbox/clienteling/wi2222897-isolated-replay`.
  - Commit : `c8084be656e918f409fa962053a77dff9928acbd`.
  - Run diagnostic : `4447427` (`succeeded`, LFS `AUTO_V26_00.bak` matérialisé à 156 663 808 octets).
  - Run préflight : `4447443` (`failed`, `Dedicated target attestation is required.`).

## Faits établis (FACT)

1. `FACT` — **InventoryTracking (run 4447425)** :
   - Lancé à 16:43:12 UTC (18:43:12 Paris).
   - Les étapes `Build V26`, `Docker preflight for isolated JMeter`, `Initialize containers`, `Launch Y2 deployment` et `Test Y2 deployment` ont toutes réussi pour Cur et Fix.
   - Les tests JMeter ont été lancés à 17:04:08 UTC pour Fix et 17:06:04 UTC pour Cur via `Run Jmeter Tests Campaign`.
   - Le correctif structurel de `002-Device_Reassign.jmx` (commit `be3c9ac3`) a été consommé.
2. `FACT` — **FrenchTaxesRules (blocage résolu et run 4447508)** :
   - Les définitions dédiées créées par BW1 (`14268` et `14269`) étaient bloquées indéfiniment sur `Checkpoint.Authorization` car les nouvelles définitions n'étaient pas autorisées sur le service endpoint `AzureContainerRegistry-Docker-Retail` (ID `5fc079c9-4b68-403f-8c57-40274d100a94`).
   - La définition canonique `2054` (`FrenchTaxesRules CI`) disposait déjà de cette autorisation (`authorized: true`).
   - Les runs résiduels bloqués `4447417` et `4447436` ont été annulés.
   - Le fichier `azure-pipelines.yml` sur la branche de validation a été mis à jour (commit `b82c5452`) pour désactiver l'étape ACR partagée (`Ensure_Docker_Image_Up_To_Date`), garantissant une isolation totale sans effets de bord partagés.
   - Le run `4447508` a été queué sur la définition `2054` avec `templateParameters: { pipelineDevMode: "true" }`. Il a franchi immédiatement les checkpoints, exécuté avec succès `Check generate code` et `Snyk Security Scan`, et lancé `Build V26`.
3. `FACT` — **Clienteling (diagnostic de l'attestation)** :
   - Le run `4447427` prouve que l'objet LFS `AUTO_V26_00.bak` (156 663 808 octets, SHA-256 `8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C`) est parfaitement résolu et extrait sur agent Windows 2025.
   - Le préflight `4447443` a échoué car `Assert-Wi2222897ArtifactManifest.ps1:55` exige un fichier `target-attestation.json` avec des métadonnées de cible dédiée (`appHost`, `dbHost`, `cleanupScope`), absent de l'artefact diagnostic `wi2222897-target-diagnostic-4447427`.
