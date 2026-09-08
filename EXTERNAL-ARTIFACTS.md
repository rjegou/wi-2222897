---
type: "Reference"
title: "WI-2222897 — Artefacts restés hors du dépôt"
description: "Ce qui n'est pas versionné ici : clones Git, snapshots de dépôts, artefacts bruts. Emplacement exact, poids, et comment le reconstituer."
resource: "WI-2222897/EXTERNAL-ARTIFACTS.md"
tags: ["jmeter", "testauto", "migration", "artefacts"]
timestamp: "2026-09-08"
source_system: "local-kb"
---

# Artefacts restés hors du dépôt

**Établi le 2026-09-08.** Ce dépôt versionne la **couche documentaire** du WI : Markdown, index,
manifestes, empreintes, scripts, patches — environ 60 Mo. Le workspace d'origine pesait environ
8,6 Go. Ce fichier dit où est le reste, ce qu'il vaut, et comment le reconstituer.

Emplacement du workspace d'origine :

```
C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897
```

## Vue d'ensemble — nettoyage exécuté le 2026-09-08

Le dossier OneDrive d'origine est passé de **8,6 Go à 72 Mo**. Trois emplacements se partagent
désormais le contenu :

| Emplacement | Poids | Contenu |
|---|---:|---|
| `C:/clones/wi-2222897` | 151 Mo | ce dépôt : couche documentaire versionnée |
| `C:/clones/wi-2222897-evidence` | 3,1 Go | artefacts bruts de preuve, hors OneDrive, arborescence conservée |
| dossier OneDrive d'origine | 72 Mo | résidu documentaire, plus la référence — voir `LISEZ-MOI-DEPLACE.md` |

Détail de ce qui a été fait :

| Catégorie | Poids | Action réalisée |
|---|---:|---|
| Clones Git et worktrees | 1,7 Go | **supprimés** ; travail non committé sauvé dans [`patches/`](patches/README.md) |
| Snapshots de dépôts (`sources/`) | 1,9 Go | **supprimés** ; commits de reconstitution en section 2 |
| Artefacts bruts de preuve | 3,1 Go | **déplacés** vers `C:/clones/wi-2222897-evidence` |
| Clones et copies des sessions parallèles | 2,0 Go | **supprimés** ou déplacés vers `…-evidence/_parallel/` |
| Profils Azure CLI, traces d'orchestration, clone égaré | ~370 Mo | **supprimés**, sauf 5 coquilles vides bloquées par ACL (section 5) |

Chemin du dossier d'origine : `…/missions/delivery-acceleration/context/WI-2222897` sous
`OneDrive - CEGID/Documents/repertoireTravailRon`.

## 1. Clones Git et worktrees — supprimés le 2026-09-08

Les treize clones qui étaient sous `worktrees/` ont été supprimés. **Tout le travail non committé avait été extrait au préalable** dans
[`patches/`](patches/README.md) le 2026-09-08 : les quatre corrections du générateur JMX, le correctif
Full-Text, les cinq métadonnées Clienteling, la propagation d'erreur PlatformDeploy et la modification
utilisateur du workflow JMeter. Vérifié worktree par worktree ; six étaient sales, les autres propres.

| Clone | Dépôt d'origine |
|---|---|
| `Migration_Jmeter_RJE_Sandbox` | `Migration_Jmeter_RJE_Sandbox` |
| `Y2_Tools_Jmeter_Workflow` | `Y2_Tools_Jmeter_Workflow` |
| `Y2_Tools_AutoTest_Api`, `…_EscapeJdbcDate_RJE` | `Y2_Tools_AutoTest_Api` |
| `Y2_Tools_AutoTest_Console`, `…_Date_RJE` | `Y2_Tools_AutoTest_Console` |
| `Y2_Plugins_Clienteling` | `Y2_Plugins_Clienteling` |
| `Y2_Plugins_FrenchTaxesRules` | `Y2_Plugins_FrenchTaxesRules` |
| `InventoryTracking_Migration_AutoTest_Jmeter_On_master_worker2` | `Y2_Plugins_InventoryTracking` |
| `Pipelines_Docker_BaseImages`, `…_worker2_round9` | `Pipelines_Docker_BaseImages` |
| `Y2_Tools_PlatformDeploy`, `…_worker3_r5b` | `Y2_Tools_PlatformDeploy` |

Tous sous `https://dev.azure.com/cegid/Retail/_git/<nom>`. `WI-2222897-v26-fix-replay-draft-round4`
n'a aucun remote : c'est un brouillon local, dont le contenu documentaire est déjà versionné ici.

Deux points à connaître avant de recloner :

- `Y2_Tools_Jmeter_Workflow` portait une modification **appartenant à l'utilisateur** dans
  `azure-pipeline.yml`. Elle est dans `patches/Y2_Tools_Jmeter_Workflow.patch`. À réappliquer si le
  clone est refait.
- `Y2_Plugins_FrenchTaxesRules` était **pollué** par un checkout interrompu du 2026-09-07 (621 fichiers
  modifiés, 237 non suivis) et sa lecture Git échouait sur `dubious ownership`. Ne pas le restaurer :
  recloner proprement. Le seul fichier unique qu'il contenait est conservé ici, voir
  [`patches/README.md`](patches/README.md).

## 2. Snapshots de dépôts — supprimés le 2026-09-08

`investigations/ecarts-jmeter-migrations/sources/` a été supprimé. Il contenait des copies exactes de dépôts au commit
d'un build, servant de preuve de code. Chaque snapshot est reconstituable par `git clone` puis
`git checkout <commit>` :

| Snapshot | Dépôt | Commit |
|---|---|---|
| `Y2_Plugins_FrenchTaxesRules-master-build-4426342` | `Y2_Plugins_FrenchTaxesRules` | `358fe9507e0eb1a4601437ec0c9db6bf197015cc` |
| `Y2_Plugins_FrenchTaxesRules-v5-build-4429167` | `Y2_Plugins_FrenchTaxesRules` | `2d826b8fd19ecb4d7200f574414efb7583de8ed2` |
| `Y2_Plugins_FrenchTaxesRules-v7-build-4429629` | `Y2_Plugins_FrenchTaxesRules` | `657a61cd6d6d08cac698517309077202c43a29f8` |
| `Y2_Plugins_Clienteling-master-build-4432554-exact` | `Y2_Plugins_Clienteling` | `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a` |
| `Y2_Plugins_Clienteling-v6-build-4432602` | `Y2_Plugins_Clienteling` | `8744999cabb6cea993db49a2d2bf741ae2dd5454` |
| `Y2_Plugins_Clienteling-v7-build-4432652` | `Y2_Plugins_Clienteling` | `a3b9c933ddeaaf1846785ea6bc044e4bf4a083bb` |
| `Y2_Plugins_Clienteling-v8-build-4432672` | `Y2_Plugins_Clienteling` | `8f1088fb5f0d54fc7bb17caf351b98edcaa67706` |
| `Y2_Tools_AutoTest_Api`, `Y2_Tools_AutoTest_Console` | idem | `master` au 2026-09-06 |

Les commits sont également repris dans la
[matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md), qui reste la
source à citer.

`sources/quarantine/` contenait un clone incomplet, et `sources/archives/` des archives. Vérifier
qu'aucune preuve unique n'y réside avant suppression — c'était déjà la réserve inscrite dans
`RESOURCES.md`.

## 3. Artefacts bruts de preuve — déplacés hors OneDrive le 2026-09-08

Environ 2,9 Go répartis sur 68 des 178 dossiers de preuve : logs de run, `.jmx`, `.jtl`, dumps XML de
réponses, archives `.zip` d'artefacts de build, backups. Le détail dossier par dossier, avec le poids
resté dehors, est dans
[l'index des preuves](investigations/ecarts-jmeter-migrations/evidence/README.md).

**Décision retenue** : déplacement hors OneDrive plutôt que suppression, pour conserver la capacité
de re-vérifier une conclusion contestée sur la donnée brute. Ces artefacts viennent de builds de début
septembre 2026 et sont soumis à la rétention Azure DevOps : passé ce délai, ils ne sont plus
téléchargeables, et tout le diagnostic causal — les 485 cas Clienteling classés, les 174 refus V22, les
6 échecs FrenchTaxesRules — a été établi à partir d'eux.

**Emplacement** : `C:/clones/wi-2222897-evidence/`, arborescence identique à celle de
`investigations/ecarts-jmeter-migrations/evidence/`, plus un sous-dossier `_parallel/` pour les
binaires des sessions parallèles. La correspondance avec l'index du dépôt reste donc directe : pour un
dossier de preuve donné, remplacer le préfixe du chemin par celui de l'archive.

Ce que ce dépôt conserve et qui suffit à relire le raisonnement : les `README.md` de provenance, les
`MANIFEST.csv`, les `SHA256SUMS.txt`, les CSV d'erreurs de moins de 512 Ko, les timelines JSON et les
`findings/`. Les 25 fichiers documentaires qui dépassaient 512 Ko — surtout des CSV d'erreurs de 4 à
6 Mo — ont rejoint l'archive pour ne rester orphelins nulle part.

Cette archive n'est **pas** versionnée et n'est **pas** sauvegardée par OneDrive. Si elle compte,
prévoir une sauvegarde propre.

## 4. Sorties des sessions parallèles — traitées le 2026-09-08

`investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-.../` pesait 2,1 Go pour trois
sessions BW1, BW2 et BW3. Les clones et les copies d'arborescences ont été supprimés, les binaires déplacés vers `…-evidence/_parallel/`. Leur couche documentaire — `MISSION.md`, `RESULT.md`, `CORRECTIONS.md`,
`INTEGRATION.md`, `RESOURCES.md` et les README de preuve — est versionnée ici. Le poids venait de :

- clones Git complets sous `bw*/worktrees/` → reclonables ;
- copies d'arborescences source sous `bw*/reports/` → reclonables ;
- une distribution Apache JMeter 5.6.3 décompressée avec sa javadoc → retéléchargeable, SHA-512 déjà
  vérifié et noté dans la collecte correspondante ;
- des DLL et exécutables de harnais de compilation → reconstructibles.

Aucun de ces quatre postes n'est une preuve unique.

## 5. Éléments supprimés sans réserve

Supprimés du workspace d'origine le 2026-09-08, sans valeur de preuve :

- six profils Azure CLI jetables à la racine : `.az-cli-4434070`, `.az-cli-worker1-r2`,
  `.azcfg-v22-read10`, `.azcli-worker1`, `.azconfig-worker2-r3`, `.tmp-az-fulltext-round2` ;
- deux profils Azure CLI déposés par erreur dans les preuves :
  `evidence/azure-devops/work-item-2222897/2026-09-07/cli-r2/azcfg/` et
  `parallel/.../bw3-plugins/evidence/frenchtaxesrules/.azure-config/` ;
- `git-askpass-worker2-r3.cmd` et `.ps1` — helpers d'identifiants, à supprimer, pas à conserver ;
- `.v22-isolated-publish/` — clone égaré de 152 Mo, dont un `SAFT.XML` de 77,6 Mo ;
- `.v22-preview-body.json` — corps de requête temporaire ;
- `.brain-worker-archives/` et `.brain-worker-control/` — traces d'orchestration.

**Restent à supprimer, blocage technique.** Cinq coquilles de profils Azure CLI, 8 Ko chacune, dont le
sous-dossier `cliextensions/azure-devops/azext_devops` refuse l'accès : `Get-Acl` lui-même échoue en
« opération non autorisée ». `takeown` et `icacls` sans élévation n'y suffisent pas. Depuis un terminal
**administrateur**, en se plaçant dans le dossier WI :

```powershell
takeown /f . /r /d O
icacls . /grant "$($env:USERNAME):(OI)(CI)F" /t
Remove-Item .az-cli-4434070, .az-cli-worker1-r2, .azcli-worker1, .azconfig-worker2-r3, .tmp-az-fulltext-round2 -Recurse -Force
```

Le même blocage touche `parallel/.../bw3-plugins/reports/inventorytracking/azcfg/` et
`evidence/azure-devops/work-item-2222897/2026-09-07/.azcfg/`. Aucun de ces dossiers ne contient de
preuve : ce sont des caches d'extension `az`.

## 6. Points de sécurité relevés au passage

Deux constats faits pendant le tri, aucun introduit par ce travail :

- `worktrees/Migration_Jmeter_RJE_Sandbox/jfrogToken.txt` est un fichier de jeton en clair. Il n'a été
  ni ouvert ni copié. Sa rotation ou sa suppression appartient au propriétaire des accès.
- `Generate_CSharp_Tablet.cmd` du dépôt `Y2_Plugins_InventoryTracking` contient un mot de passe de base
  de données en dur (`SET DBPassword=…`). C'est **préexistant dans le dépôt Cegid**, pas une fuite
  créée ici. Les copies rencontrées sous `parallel/` ont été explicitement exclues de ce dépôt. À
  signaler au propriétaire du dépôt.
