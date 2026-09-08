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

## Vue d'ensemble

| Catégorie | Poids | Reconstituable ? | Verdict |
|---|---:|---|---|
| Clones Git et worktrees | 1,7 Go | oui, `git clone` depuis `cegid/Retail` | supprimable, le travail est dans [`patches/`](patches/README.md) |
| Snapshots de dépôts (`sources/`) | 1,9 Go | oui, `git clone` + `checkout <commit>` | supprimable, commits notés ci-dessous |
| Artefacts bruts de preuve | 2,9 Go | partiellement, selon la rétention Azure DevOps | **à décider** — voir la mise en garde |
| Sorties des sessions parallèles | 2,1 Go | non pour les preuves, oui pour les clones qu'elles contiennent | tri nécessaire |

## 1. Clones Git et worktrees — supprimables

Treize clones sous `worktrees/`. **Tout le travail non committé a été extrait** dans
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

## 2. Snapshots de dépôts — supprimables

`investigations/ecarts-jmeter-migrations/sources/` contenait des copies exactes de dépôts au commit
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

## 3. Artefacts bruts de preuve — à décider, ne pas supprimer à l'aveugle

Environ 2,9 Go répartis sur 68 des 178 dossiers de preuve : logs de run, `.jmx`, `.jtl`, dumps XML de
réponses, archives `.zip` d'artefacts de build, backups. Le détail dossier par dossier, avec le poids
resté dehors, est dans
[l'index des preuves](investigations/ecarts-jmeter-migrations/evidence/README.md).

**Mise en garde.** Ces fichiers sont des artefacts téléchargés depuis Azure DevOps pour des builds de
début septembre 2026. Ils sont soumis à la rétention Azure DevOps : passé ce délai, ils ne sont plus
téléchargeables. Or plusieurs `findings/` s'appuient sur eux avec des empreintes précises, et
l'ensemble du diagnostic causal — les 485 cas Clienteling classés, les 174 refus V22, les 6 échecs
FrenchTaxesRules — a été établi à partir de ces artefacts.

Ce qui est conservé ici et suffit à relire le raisonnement : les `README.md` de provenance, les
`MANIFEST.csv`, les `SHA256SUMS.txt`, les CSV d'erreurs, les timelines JSON et les `findings/`.
Ce qui disparaîtrait : la capacité de **re-vérifier** une conclusion contestée sur la donnée brute.

Trois options, par ordre de prudence :

1. déplacer les 2,9 Go hors OneDrive, par exemple `C:\clones\wi-2222897-evidence\`, en conservant
   l'arborescence pour que l'index reste exact ;
2. archiver en un `.7z`/`.zip` unique hors OneDrive, avec son empreinte notée ici ;
3. supprimer, en acceptant que les verdicts deviennent non re-vérifiables sur la donnée brute.

Les gros contributeurs, si l'on veut cibler : les deux `serilog_authserver_*.log` du build 4432554
pèsent 38,8 Mo chacun, la collecte `2026-09-07-brain-reprise-worker1-round5` 94,3 Mo, les dossiers
`_extracted/` des builds `4426342`, `4429167`, `4432510`, `4432554`, `4432602`, `4432652` et `4432672`
l'essentiel du reste.

## 4. Sorties des sessions parallèles — tri nécessaire

`investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-.../` pesait 2,1 Go pour trois
sessions BW1, BW2 et BW3. Leur couche documentaire — `MISSION.md`, `RESULT.md`, `CORRECTIONS.md`,
`INTEGRATION.md`, `RESOURCES.md` et les README de preuve — est versionnée ici. Le poids venait de :

- clones Git complets sous `bw*/worktrees/` → reclonables ;
- copies d'arborescences source sous `bw*/reports/` → reclonables ;
- une distribution Apache JMeter 5.6.3 décompressée avec sa javadoc → retéléchargeable, SHA-512 déjà
  vérifié et noté dans la collecte correspondante ;
- des DLL et exécutables de harnais de compilation → reconstructibles.

Aucun de ces quatre postes n'est une preuve unique.

## 5. Éléments à supprimer sans réserve

Présents dans le workspace d'origine, non versionnés ici, sans valeur de preuve :

- six profils Azure CLI jetables à la racine : `.az-cli-4434070`, `.az-cli-worker1-r2`,
  `.azcfg-v22-read10`, `.azcli-worker1`, `.azconfig-worker2-r3`, `.tmp-az-fulltext-round2` ;
- deux profils Azure CLI déposés par erreur dans les preuves :
  `evidence/azure-devops/work-item-2222897/2026-09-07/cli-r2/azcfg/` et
  `parallel/.../bw3-plugins/evidence/frenchtaxesrules/.azure-config/` ;
- `git-askpass-worker2-r3.cmd` et `.ps1` — helpers d'identifiants, à supprimer, pas à conserver ;
- `.v22-isolated-publish/` — clone égaré de 152 Mo, dont un `SAFT.XML` de 77,6 Mo ;
- `.v22-preview-body.json` — corps de requête temporaire ;
- `.brain-worker-archives/` et `.brain-worker-control/` — traces d'orchestration.

## 6. Points de sécurité relevés au passage

Deux constats faits pendant le tri, aucun introduit par ce travail :

- `worktrees/Migration_Jmeter_RJE_Sandbox/jfrogToken.txt` est un fichier de jeton en clair. Il n'a été
  ni ouvert ni copié. Sa rotation ou sa suppression appartient au propriétaire des accès.
- `Generate_CSharp_Tablet.cmd` du dépôt `Y2_Plugins_InventoryTracking` contient un mot de passe de base
  de données en dur (`SET DBPassword=…`). C'est **préexistant dans le dépôt Cegid**, pas une fuite
  créée ici. Les copies rencontrées sous `parallel/` ont été explicitement exclues de ce dépôt. À
  signaler au propriétaire du dépôt.
