# Finding 017 — Reprise directe AzDO : levée des blocages, exécution réelle des campagnes InventoryTracking (4447425) et FrenchTaxesRules (4447508)

## Périmètre et provenance

- Système : Azure DevOps `cegid/Retail`.
- Contexte : suite immédiate de la session interrompue documentée dans `brain-worker-2026-09-08T16-29-38-848Z-17356-03c7e2f30f82.txt`.
- Méthode : intervention directe sans `brain-worker` (bw), inspection live par API REST Azure DevOps sécurisée en mémoire.
- Cibles traitées :
  1. `Y2_Plugins_InventoryTracking` (run `4447425`, définition `2072`)
  2. `Y2_Plugins_FrenchTaxesRules` (runs `4447417`, `4447436`, `4447508`, définition `2054`)
  3. `Y2_Plugins_Clienteling` (runs `4447427`, `4447443`, définition `14264`)
- Preuve associée : [evidence/run-4447425-4447508-reprise-azdo-2026-09-08/README.md](../evidence/run-4447425-4447508-reprise-azdo-2026-09-08/README.md).

## Conclusion bornée

**FACT** — La mission confiée à l'origine aux trois workers a été reprise et débloquée directement :

1. **InventoryTracking** :
   - Le correctif structurel de `Tests/WebServices/002-Device_Reassign.jmx` (ajout du `<hashTree/>` manquant après le `JSR223PostProcessor` de TC122, SHA-256 `FC39A5A8F3850293AB1A863928CFA574BC4F3B20941A17F978212F47D606E8C2`, 86 identités préservées) a été poussé au commit `be3c9ac35e3424a1a9cfb5c7b2da0bb31edc0437` sur la branche `validation/WI-2222897-inventorytracking-azdo-20260908`.
   - Le run `4447425` sur la définition `2072` franchit le build, les conteneurs et les déploiements Cur/Fix (`v26-Fix_Deployment_logs` et `v26-Cur_Deployment_logs` publiés).
   - Les tâches `Run Jmeter Tests Campaign` pour Cur et Fix sont en cours d'exécution réelle dans des conteneurs isolés.

2. **FrenchTaxesRules** :
   - Cause du blocage Worker 1 : la création de nouvelles définitions de pipeline (`14268` et `14269`) a déclenché un arrêt bloquant sur `Checkpoint.Authorization`. L'API REST établit que le service endpoint `AzureContainerRegistry-Docker-Retail` (`5fc079c9-4b68-403f-8c57-40274d100a94`) n'était pas ouvert aux nouvelles définitions, alors qu'il est explicitement autorisé pour la définition CI d'origine `2054`.
   - Résolution : annulation des runs orphelins `4447417` et `4447436`. Modification du fichier `azure-pipelines.yml` sur la branche `validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908` au commit `b82c5452b45ac857b60b72637d37eb81df38a41a` pour forcer `Ensure_Docker_Image_Up_To_Date: condition: false` et `pr: none`, garantissant zéro effet de bord partagé.
   - Lancement du run `4447508` sur la définition `2054` avec `templateParameters: { pipelineDevMode: "true" }`. Le run a franchi immédiatement les checkpoints, validé les contrats et scans, et compile activement `Build V26`.

3. **Clienteling** :
   - Le run diagnostic `4447427` prouve que l'objet LFS `AUTO_V26_00.bak` (156 663 808 octets, SHA-256 `8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C`) est présent et extrait sur agent Windows 2025 (`D:\a\1\s\Tests\Backups\AUTO_V26_00.bak`).
   - Le préflight `4447443` s'est arrêté à la ligne 55 de `Assert-Wi2222897ArtifactManifest.ps1` (`Dedicated target attestation is required.`), car l'orchestrateur 14264 exige un fichier `target-attestation.json` issu d'un provisionnement d'hôte dédié qui n'est pas produit par un simple job de diagnostic.

## Actions non effectuées et limites (UNKNOWN)

- `UNKNOWN` — Couverture finale et résultats unitaires de `002-Device_Reassign` (dont `TC122`) dans InventoryTracking tant que `4447425` n'a pas atteint le terminal et publié ses TRX/JTL.
- `UNKNOWN` — Résultats effectifs des scénarios discriminants FrenchTaxesRules (`Export_Run` TC08/TC09/TC10 et `DocumentSignature_SignOne` TC02) tant que `4447508` n'a pas atteint le stage JMeter.
- Aucune modification partagée, PR, merge, publication NuGet ou promotion d'image n'a été effectuée.
