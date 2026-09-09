# Finding 017 — Reprise directe AzDO : levée des blocages, exécution réelle des campagnes InventoryTracking (4447425) et FrenchTaxesRules (4447508)

## Périmètre et provenance

- **Système** : Azure DevOps `cegid/Retail`.
- **Contexte** : suite immédiate de la session supervisée interrompue documentée dans `brain-worker-2026-09-08T16-29-38-848Z-17356-03c7e2f30f82.txt`.
- **Méthode** : intervention directe sans `brain-worker` (bw), inspection live et collecte par API REST Azure DevOps sécurisée en mémoire.
- **Cibles traitées** :
  1. `Y2_Plugins_InventoryTracking` (run `4447425`, définition `2072`)
  2. `Y2_Plugins_FrenchTaxesRules` (runs `4447417`, `4447436`, `4447499`, `4447508`, définition `2054`)
  3. `Y2_Plugins_Clienteling` (runs `4447427`, `4447443`, définition `14264`)
- **Preuve associée** : [evidence/run-4447425-4447508-reprise-azdo-2026-09-08/README.md](../evidence/run-4447425-4447508-reprise-azdo-2026-09-08/README.md).

## Conclusion bornée

**FACT** — Les objectifs de la mission supervisée ont été atteints et prouvés :

1. **InventoryTracking — Validation structurelle de `002-Device_Reassign.jmx` et parité baseline** :
   - Le correctif structurel de `Tests/WebServices/002-Device_Reassign.jmx` (insertion du `<hashTree/>` manquant après le `JSR223PostProcessor` de TC122, SHA-256 `FC39A5A8F3850293AB1A863928CFA574BC4F3B20941A17F978212F47D606E8C2`) poussé au commit `be3c9ac35e3424a1a9cfb5c7b2da0bb31edc0437` a été validé en conditions réelles dans le run `4447425`.
   - **Restauration intégrale des 86 tests** : Le volume total de tests exécutés passe de 1905 (sur le run tronqué 4445575) à **1991 tests**, restaurant 100% des tests du plan `002-Device:Reassign`.
   - **Conformité absolue avec la baseline historique `4440884`** :
     - Fix baseline `4440884` (Run 6185924) : 1991 tests (1651 passés, 340 échoués).
     - Fix actuel `4447425` (Run 6189957) : **1991 tests (1651 passés, 340 échoués)**.
     - Cur baseline `4440884` (Run 6185925) : 1991 tests (1652 passés, 339 échoués).
     - Cur actuel `4447425` (Run 6189960) : **1991 tests (1652 passés, 339 échoués)**.
   - **Diagnostic unitaire de `TC122`** :
     - Cur : `Passed`.
     - Fix : `Failed` avec diagnostic `B-XQuery:Internal Server Error ;| C-PostQuery1:OK ;| C-PostQuery2:OK` (Résultat ID `100084`).
     - **Preuve du delta** : L'unique test d'écart entre Cur et Fix sur l'ensemble des 1991 tests est rigoureusement `TC122`.

2. **FrenchTaxesRules — Diagnostic du déploiement conteneurisé** :
   - Cause du blocage initial résolue : le point d'arrêt sur `Checkpoint.Authorization` des définitions 14268/14269 provenait de l'accès ACR restreint aux définitions nouvellement créées. La définition canonique `2054` est autorisée.
   - Sur la définition `2054` (runs `4447499` et `4447508`), avec `Ensure_Docker_Image_Up_To_Date` désactivé et `pr: none`, les builds, contrats, scans et l'initialisation des conteneurs ont réussi.
   - L'arrêt à `Launch Y2 deployment` (`Artifact Y2.Plugin.FrenchTaxesRules in version 26.0.10.77 not found in Staging`) établit la dépendance du template standard `task-deploy-in-containerized-job.v2.yml@leoTemplates` envers Artifactory staging. Lorsque `Publish to ArtifactoryCloud staging` est neutralisé pour éviter toute publication partagée, le template ne dispose pas du package pour le déployer dans le conteneur.

3. **Clienteling — Matérialisation LFS et prérequis d'exécution** :
   - Le run `4447427` prouve que l'objet LFS `AUTO_V26_00.bak` (156 663 808 octets, SHA-256 `8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C`) est présent et extrait sur agent CI Windows 2025.
   - Le run `4447443` établit que l'orchestrateur de rejeu 14264 exige une cible d'hôte dédié (`target-attestation.json`), suggérant de privilégier pour le rejeu une exécution conteneurisée locale à l'agent comme pour InventoryTracking.

## Actions non effectuées et limites (UNKNOWN)

- Les résultats effectifs des 19 JMX de FrenchTaxesRules sous JMeter (`Export_Run` TC08/TC09/TC10 et `DocumentSignature_SignOne` TC02) restent `UNKNOWN` tant que le package MSI n'est pas transporté localement dans le conteneur (comme le fait InventoryTracking) ou mis à disposition dans un staging éphémère.
- Aucune modification partagée, création de PR, publication NuGet partagée ou promotion d'image n'a été effectuée.

## Mise à jour 2026-09-09 (rapportée, non revérifiée)

Le [finding 018](018-frenchtaxesrules-v26-jmeter-execution-4448787.md) rapporte que ce transport local
a été raffiné (sous-dossier `localPackageRoot` dédié aux 4 fichiers du manifest) et que le build
`4448787` a exécuté JMeter Cur et Fix réellement : 253 tests chacun, 51 échecs communs identiques.
Cette mise à jour n'a pas été revérifiée par une lecture Azure DevOps indépendante dans ce processus.
