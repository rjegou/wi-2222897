# Revue indépendante du transport PipelineArtifact InventoryTracking — round 8

Date: 2026-09-08 Europe/Paris. Aucun acte Azure DevOps distant. Le clone PlatformDeploy verrouillé a été laissé intact: aucun `index.lock` supprimé et aucun processus tué. Revue du dossier indépendant `.work/transport-round7` contre les blobs PlatformDeploy commit `93f91487ee717185599555a42df3cb5d024ace89`.

## FACT — vérifications exécutées

Le test réel `test-local-transport.ps1` a exécuté `prepare-local-inventorytracking-package.ps1` avec la fixture extraite de l’artefact Build `5037140` et ses quatre hashes. Résultats observés:

`normal-path-static PASS`; `positive PASS`; `wrong-version PASS`; `wrong-hash PASS`; `duplicate-file PASS`; `unexpected-root-file PASS`; `missing-manifest PASS`; `ALL CASES PASS`.

Le cas positif vérifie aussi la sortie JSON réellement produite par le helper: `packageName=Y2.Plugin.InventoryTracking`, `packageVersion=26.0.7.83`, `artifactId=5037140`, quatre fichiers; le dossier de sortie contient les quatre fichiers sous `Y2.Plugin.InventoryTracking`. Les scripts PowerShell candidats passent `[scriptblock]::Create(...)`. Les contrôles statiques YAML confirment le téléchargement de `$(componentVersion)_Software` dans chaque job Cur/Fix, la génération du manifeste/hash sur l’agent, et l’absence de `retail-software-staging`.

## FACT — inspection du chemin complet

- `download-packages.ps1` active le mode local uniquement si les quatre paramètres sont présents; sans eux, `effectiveDeployConfig` reste le fichier d’origine et la commande JFrog normale reste inchangée.
- En mode local, une copie XML temporaire retire exactement un nœud `Y2.Plugin.InventoryTracking` et exige que `selectVersion` égale la version fournie; les dépendances restantes sont donc conservées pour la résolution existante.
- Le helper refuse nom, version, manifeste, chemins, fichiers absents, doublons, hash incorrect, fichier inattendu et destination déjà existante; il copie ensuite les quatre fichiers vers le dossier `name` attendu.
- Le manifeste `downloadedPackages.json` reçoit un `ArtifactItem` camelCase avec `uri`, `filename`, `name`, `version`; l’URI porte l’identité PipelineArtifact du Build courant. Le helper vérifie les hashes avant cette insertion.
- Les wrappers PS5/PS7 propagent les quatre paramètres jusqu’au script réel; les erreurs du helper atteignent le `catch` du wrapper et `Exit 1`.
- Le YAML exclut la nouvelle branche de l’ensure ACR et de la publication staging. Promote/Tag restent limités master/release. Aucun fallback plugin partagé n’est ajouté.

## Empreintes exactes du candidat relu

| fichier | SHA-256 |
|---|---|
| `prepare-local-inventorytracking-package.ps1` | `38844E08CE3B1D859620879DC097A95F84EF0518BF1848B09607E9B395A2C7A6` |
| `download-packages.ps1` | `035821A0AC32F93B0C8BCC96B1088E6014DDCD83F6760A1857FE385015238BDF` |
| `docker-pipeline-deploy.ps1` | `43AB3D34BF771823B937ACED3C9682E3CEC0199E19E87A1EB4F3418BA91F7C79` |
| `docker-pipeline-deploy-ps7.ps1` | `FE794156E51600329F6CDE79CBDA65229BCA50AFEB68E723017D2EBCE7F16BC4` |
| `task-deploy-in-containerized-job.v2.yml` | `FA2DD884133E4FD86C33992AA9C9435788DF474F98978A33D377F0A83F47F17A` |
| `inventorytracking.azure-pipelines.yml` | `453ED3CEF173D035D244FF007A896ADBDAF2F0E7584E2828E7A938A652DE5ACF` |
| `test-local-transport.ps1` | `3E3EE67B3C54FEF1D246A9CD50ECA7A80A231DEEFFEB0C05CA9ADAF3D424A36B` |

## AVIS FINAL DE REVUE

**Favorable sous réserve de validation Azure DevOps** pour pousser ce diff sur les branches isolées et lancer un seul Build + Cur/Fix. Les corrections appliquées pendant cette revue sont limitées au rejet explicite des fichiers inattendus dans la racine PipelineArtifact et à l’assertion de la sortie `ArtifactItem` réelle; elles sont couvertes par les résultats ci-dessus.

## LIMITES

UNKNOWN: le YAML n’est pas encore compilé/exécuté avec cette branche PlatformDeploy; aucun résultat runtime Cur/Fix/JMeter/TC122 n’existe encore. L’ID 5037140 reste une fixture historique; le prochain Build doit recalculer ses propres hashes et son identité `Build.BuildId`, sans version codée en dur dans le pipeline.
