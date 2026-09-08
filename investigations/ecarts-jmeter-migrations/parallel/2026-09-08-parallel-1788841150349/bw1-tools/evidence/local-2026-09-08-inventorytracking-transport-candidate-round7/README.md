# Candidate transport local InventoryTracking — round 7

Date: 2026-09-08 Europe/Paris. Source blobs: `Y2_Tools_PlatformDeploy` commit `93f91487ee717185599555a42df3cb5d024ace89`, fetched read-only via Azure DevOps Git Items API. Le clone source verrouillé n'a pas été modifié, son `index.lock` n'a pas été supprimé et aucun processus n'a été tué.

## FACT — candidate indépendant

Le dossier de travail reviewable est `.work/transport-round7/` (hors `evidence/`). Il contient:

- `prepare-local-inventorytracking-package.ps1`: opt-in strict; exige le package exact `Y2.Plugin.InventoryTracking`, la version fournie par le Build courant, un manifeste local unique, exactement les deux MSI/deux XML, et vérifie chaque SHA-256 avant copie sous le dossier `name`.
- `download-packages.ps1`: copie temporaire du `.cy2px` et retrait du seul nœud InventoryTracking; les dépendances restantes sont résolues par le mécanisme JFrog inchangé; ajout d'un `ArtifactItem` camelCase local dans `downloadedPackages.json`; mode normal inchangé quand les paramètres sont vides.
- `docker-pipeline-deploy.ps1` et `docker-pipeline-deploy-ps7.ps1`: propagation explicite des quatre paramètres sans réécriture Docker.
- `task-deploy-in-containerized-job.v2.yml`: paramètres expérimentaux opt-in, valeurs par défaut vides.
- `inventorytracking.azure-pipelines.yml`: téléchargement de l'artefact Software du Build courant dans chaque job Cur/Fix, génération du manifeste/hash sur l'agent, référence de branche PlatformDeploy dédiée, et exclusion de la publication staging/ACR sur cette branche.

Empreintes SHA-256 des fichiers candidats:

| fichier | SHA-256 |
|---|---|
| `prepare-local-inventorytracking-package.ps1` | `38844E08CE3B1D859620879DC097A95F84EF0518BF1848B09607E9B395A2C7A6` |
| `download-packages.ps1` | `035821A0AC32F93B0C8BCC96B1088E6014DDCD83F6760A1857FE385015238BDF` |
| `docker-pipeline-deploy.ps1` | `43AB3D34BF771823B937ACED3C9682E3CEC0199E19E87A1EB4F3418BA91F7C79` |
| `docker-pipeline-deploy-ps7.ps1` | `FE794156E51600329F6CDE79CBDA65229BCA50AFEB68E723017D2EBCE7F16BC4` |
| `task-deploy-in-containerized-job.v2.yml` | `FA2DD884133E4FD86C33992AA9C9435788DF474F98978A33D377F0A83F47F17A` |
| `inventorytracking.azure-pipelines.yml` | `453ED3CEF173D035D244FF007A896ADBDAF2F0E7584E2828E7A938A652DE5ACF` |
| `test-local-transport.ps1` | `3E3EE67B3C54FEF1D246A9CD50ECA7A80A231DEEFFEB0C05CA9ADAF3D424A36B` |

## FACT — tests

`test-local-transport.ps1` a utilisé la fixture réelle de l'artefact 5037140, avec ses quatre hashes et le JSON `ArtifactItem` produit par le helper. Résultats: `normal-path-static PASS`, `positive PASS`, `wrong-version PASS`, `wrong-hash PASS`, `duplicate-file PASS`, `unexpected-root-file PASS`, `missing-manifest PASS`, `ALL CASES PASS`. Les cinq scripts PowerShell candidats passent aussi `[scriptblock]::Create(...)`. Les garde-fous statiques du YAML passent: téléchargement Software présent, manifeste local présent, aucune référence `retail-software-staging` dans le candidat; la branche candidate exclut aussi l'ensure ACR et la publication staging.

## UNKNOWN / revue requise

- Le YAML n'a pas encore été compilé par Azure DevOps et le helper n'a pas encore été exécuté dans un container PlatformDeploy réel.
- La référence de branche `validation/WI-2222897-inventorytracking-local-transport-20260908` doit être créée par REST après revue worker 2; aucun push n'a été fait.
- L'ID `5037140` est la fixture historique; le prochain run doit utiliser l'identité du Build courant (`Build.BuildId` + nom d'artefact) et recalculer ses hashes, sans figer `26.0.7.83` dans le pipeline.
