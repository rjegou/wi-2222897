# Patches — travail non committé extrait des clones

**Extrait le 2026-09-08.** Ces patches sont la sauvegarde du travail qui n'existait **que** sous forme
de modifications non committées dans les clones Git locaux, hors de tout dépôt versionné. Ils
représentent les corrections effectives de la mission : sans eux, supprimer les clones détruisait le
travail.

Chaque `.patch` porte en en-tête le worktree d'origine, sa branche et son `HEAD` de référence.
Un dossier `<nom>.untracked/` accompagne le patch quand des fichiers non suivis devaient être
conservés — un `git diff` ne les contient pas.

## Contenu

| Patch | Dépôt cible | Objet | Cas concernés |
|---|---|---|---:|
| `Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch` + `.untracked/` | `Y2_Tools_AutoTest_Api` | les **4 corrections du générateur JMX** dans `JmeterCodeGen.cs` : `EscapeJdbcDate`, `FixSqlUnicodeValue`, `RemoveSpecialCharsForXQuery`, `CleanXpath`. Le `.untracked/` contient les 3 fichiers de tests PowerShell associés | 105 |
| `Pipelines_Docker_BaseImages.patch` | `Pipelines_Docker_BaseImages` | activation Full-Text dans les Dockerfiles SQL 2019 et 2025, et contrôle dans `tests.yml` | 224 |
| `Pipelines_Docker_BaseImages_worker2_round9.patch` | `Pipelines_Docker_BaseImages` | patch de **diagnostic** Full-Text (`sql-fulltext-hosted-build.yml`) : DMV, crawl, FDHOST, espace disque, cleanup vérifié. Jamais publié ni exécuté | — |
| `Y2_Plugins_Clienteling.patch` | `Y2_Plugins_Clienteling` | correction des 5 attributs `WebService` des TestPlans Deployment et Mobility | 13 |
| `Y2_Tools_PlatformDeploy_worker3_r5b.patch` | `Y2_Tools_PlatformDeploy` | propagation du code de retour de `deploy.ps1` dans `init-container.ps1` | — |
| `Y2_Tools_Jmeter_Workflow.patch` | `Y2_Tools_Jmeter_Workflow` | **modification appartenant à l'utilisateur** dans `azure-pipeline.yml`, signalée « à préserver » depuis le 2026-09-06 | — |

## Réappliquer un patch

```sh
git clone <url-du-depot> <cible>
cd <cible>
git checkout <HEAD indiqué dans l'en-tête du patch>
git apply ../patches/<nom>.patch
# puis, si un dossier .untracked/ existe, recopier son contenu à la racine du clone
```

L'en-tête de chaque patch rappelle le `HEAD` exact sur lequel le diff a été calculé. Appliquer sur un
autre commit peut échouer ou produire un résultat faux : vérifier le `HEAD` avant.

## Statut de ces corrections

Aucune n'est committée, poussée, packagée ni publiée. Elles sont **validées localement** (compilation
et tests unitaires ou de comportement selon le cas) et **non validées métier** : aucun rejeu de
campagne JMeter ne les a exercées. La publication de la chaîne API → Console → outil de migration est
la [décision 5](../decisions/README.md).

## Ce qui n'a pas été conservé

Le worktree `Y2_Plugins_FrenchTaxesRules` présentait 621 fichiers modifiés et 237 fichiers non suivis.
Inspection faite, il s'agit du **résidu d'un checkout interrompu** le 2026-09-07 (mélange de `master`
et d'une branche de migration), pas d'un travail délibéré — ce que `STATUS.md` signalait déjà. Le
contenu est intégralement restaurable depuis Azure DevOps ; le patch de 6,9 Mo n'a donc pas été
versionné.

Une exception : le fichier non suivi `azure-pipelines.wi2222897-v22-preflight.yml` a été conservé sous
[`../investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-preflight-yaml-retrouve/`](../investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-preflight-yaml-retrouve/).
Son SHA-256 est `d1b53e1f2a6e7ed5c2b0450a957ac9693d4295064190fe035a69a977523646f4`, soit exactement le
hash `D1B53E1F…` que `STATUS.md` mentionnait comme « YAML local non suivi qui ne peut pas être relié
cryptographiquement au commit ». Il est désormais versionné et retrouvable.
