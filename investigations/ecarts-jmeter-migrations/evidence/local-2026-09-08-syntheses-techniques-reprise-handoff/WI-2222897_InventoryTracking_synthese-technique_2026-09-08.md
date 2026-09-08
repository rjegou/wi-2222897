---
type: "Technical Handoff"
title: "WI-2222897 — InventoryTracking — Synthèse technique au 2026-09-08"
description: "État technique consolidé de l'investigation InventoryTracking, résultats obtenus, conclusions confirmées, fausses pistes écartées et leçons utiles."
timestamp: "2026-09-08"
tags: ["WI-2222897", "InventoryTracking", "JMeter", "Azure DevOps", "migration", "diagnostic"]
---

# WI-2222897 — InventoryTracking — Synthèse technique

## 1. Objectif de l'investigation

Poursuivre la migration d'InventoryTracking vers les tests JMeter et obtenir une validation exploitable de la branche V26, en particulier :

- exécuter réellement Build + JMeter Cur/Fix ;
- vérifier que le nouveau transport local du package fonctionne ;
- comparer Cur et Fix ;
- expliquer les écarts restants ;
- ne créer une PR finale que lorsque la validation est suffisamment fiable.

La branche d'investigation utilisée est :

`validation/WI-2222897-inventorytracking-isolated-20260908`

Commit actuellement testé :

`95aede774dcc45ba7e69abe163e6be410ae0c496`

Pipeline :

`InventoryTracking CI` — ID `2072`

Run principal analysé :

`4445575`

---

## 2. Correctifs et préparations réalisés avant l'analyse JMeter

### 2.1 Correctif de build InventoryTracking

La migration supprimait `WebServices.Tests`, mais ce projet portait encore indirectement les dépendances utilisées par `Services.Tests` :

- `Cegid.Retail.XmlDiff 1.0.0`
- `XMLDiffPatch 1.0.8.28`

Le correctif candidat redéclare ces dépendances dans le projet qui les utilise encore.

Commit de référence :

`ef3d87034d38b88aca04c824061b140e2a29252c`

Ce correctif a permis d'atteindre un build réellement exécutable jusqu'aux campagnes JMeter.

---

### 2.2 Remplacement du transport Artifactory staging par un transport local

Le problème historique du run `4444887` était le suivant :

- Docker Cur/Fix démarrait correctement ;
- le package InventoryTracking n'était pas retrouvé dans le staging Artifactory.

Un transport local basé sur `PipelineArtifact + manifest` a donc été mis en place.

Les contrôles ajoutés lient explicitement le package à :

- `sourceBuildId`
- `artifactName`
- nom du package
- version
- hash attendu

Les tests locaux du transport ont couvert :

- chemin nominal ;
- mauvaise version ;
- mauvais build source ;
- mauvais nom d'artifact ;
- mauvais hash ;
- fichier dupliqué ;
- fichier inattendu à la racine ;
- manifest absent.

Tous ces tests locaux sont passés.

---

### 2.3 PlatformDeploy

Branche de travail :

`sandbox/WI-2222897-inventorytracking-local-transport`

Commit poussé par REST AzDO :

`a490cd537a1671030141248e7b9a66d31a456485`

Push ID :

`5135960`

Les fichiers distants ont été re-téléchargés après le push et leurs SHA-256 vérifiés.

---

### 2.4 Fallback embarqué dans InventoryTracking

La branche de validation contient également un fallback local directement embarqué sous :

`/.pipeline/inventorytracking-transport/`

avec notamment :

- `docker-pipeline-deploy.ps1`
- `docker-pipeline-deploy-ps7.ps1`
- `Scripts/download-packages.ps1`
- `Scripts/prepare-local-inventorytracking-package.ps1`
- `task-deploy-in-containerized-job.v2.yml`

Le pipeline utilise ce template local.

Important : ce fallback est un mécanisme d'investigation. Il ne doit pas être repris tel quel dans une PR finale sans revue.

---

## 3. Résultat du run 4445575

Run :

`4445575`

Commit :

`95aede774dcc45ba7e69abe163e6be410ae0c496`

Résultat global :

`partiallySucceeded`

Stages/jobs importants :

- `Build` : succeeded
- `Build V26` : succeeded
- `Docker preflight for isolated JMeter` : succeeded
- `Verify Docker daemon before JMeter` : succeeded
- `TI Jmeter V26-Cur` : succeededWithIssues
- `TI Jmeter V26-Fix` : succeededWithIssues
- `TI JMeter V26` : succeededWithIssues
- `Promote` : skipped

Le pipeline a donc bien traversé :

**Build → Docker preflight → JMeter Cur → JMeter Fix**

Le transport local est suffisamment fonctionnel pour permettre une vraie exécution JMeter.

---

## 4. Origine exacte du `succeededWithIssues`

Les tâches de préparation et d'exécution JMeter sont passées :

Cur :

- `Prepare Jmeter Campaign Run ... Cur` : succeeded
- `Run Jmeter Tests Campaign ... Cur` : succeeded

Fix :

- `Prepare Jmeter Campaign Run ... Fix` : succeeded
- `Run Jmeter Tests Campaign ... Fix` : succeeded

Les seules tâches en `succeededWithIssues` sont les `PublishTestResults`.

Runs publiés :

### Cur

Run ID :

`6188849`

Résultats :

- Total : `1905`
- Passed : `1591`
- Non passed / unanalyzed : `314`

### Fix

Run ID :

`6188843`

Résultats :

- Total : `1905`
- Passed : `1591`
- Non passed / unanalyzed : `314`

Le `succeededWithIssues` du pipeline correspond donc à la présence de résultats de test non passés, pas à un échec du lancement JMeter ou du transport.

---

## 5. Comparaison Cur / Fix sur 4445575

Comparaison des 314 tests non passés :

- Cur failed unique : `314`
- Fix failed unique : `314`
- Common failures : `314`
- Only Cur : `0`
- Only Fix : `0`

Conclusion :

**aucune différence Cur/Fix n'est observée parmi les 1905 tests effectivement exécutés.**

À ce stade, le Fix n'introduit donc aucune régression visible par rapport au Cur sur ce périmètre.

Important : cette conclusion ne suffisait pas à valider le run, car le nombre total de tests était inférieur à la baseline précédente.

---

## 6. Baseline confirmée : run 4440884

Le run `4440884` a été revalidé directement via les Test Runs Azure DevOps.

### Cur

Run ID :

`6185925`

Résultats :

- Total : `1991`
- Passed : `1652`
- Non passed : `339`

### Fix

Run ID :

`6185924`

Résultats :

- Total : `1991`
- Passed : `1651`
- Non passed : `340`

Il existe donc bien un delta historique d'un seul test entre Cur et Fix dans ce run.

La différence de couverture entre les deux runs est :

`1991 - 1905 = 86 tests`

---

## 7. Localisation précise des 86 tests absents

Comparaison du run Cur `6185925` de `4440884` avec le run Cur `6188849` de `4445575` :

- Old Cur unique : `1991`
- New Cur unique : `1905`
- Missing : `86`
- Added : `0`

Les 86 tests absents appartiennent tous à un seul plan :

`002-Device:Reassign`

Le fameux `TC122`, qui constituait le seul delta Cur/Fix connu sur `4440884`, fait partie de ces 86 tests absents.

Conclusion :

**l'absence de TC122 dans 4445575 ne signifie pas que le problème est résolu ; la campagne entière `002-Device:Reassign` n'a pas produit de résultats.**

---

## 8. Cause technique de la disparition de `002-Device:Reassign`

Le fichier est bien présent dans le dépôt :

`/Tests/WebServices/002-Device_Reassign.jmx`

Le runner tente bien de l'exécuter dans `4445575` :

`Launch test Plan '002-Device_Reassign'`

Commande utilisée :

`C:\Tools\jmeter\bin\jmeter.bat -n -t ...\002-Device_Reassign.jmx ...`

Mais JMeter échoue avant l'exécution des 86 tests.

Erreur confirmée :

`java.lang.IllegalArgumentException: Problem loading XML`

Cause :

`ClassCastException: org.apache.jmeter.protocol.http.control.HeaderManager cannot be cast to org.apache.jorphan.collections.HashTree`

Informations JMeter :

- version : `5.6.3`
- chemin XML :
  `/jmeterTestPlan/hashTree/hashTree/hashTree[19]/hashTree[6]/HeaderManager`
- ligne :
  `8522`

Le runner continue ensuite avec le plan suivant :

`003-Device_Connect`

C'est pourquoi :

- la tâche globale `Run Jmeter Tests Campaign` reste `succeeded` ;
- la campagne `002-Device_Reassign` ne publie aucun résultat ;
- `PublishTestResults` ne voit que 1905 tests ;
- le défaut de couverture pourrait facilement passer inaperçu si on ne compare que les compteurs globaux.

---

## 9. Fausses pistes écartées

### 9.1 Le fichier JMX n'est pas absent

Le `.jmx` est présent dans le commit actuel.

Donc la disparition des 86 tests ne vient pas d'une suppression du fichier.

---

### 9.2 Le plan est bien sélectionné et lancé

Les logs montrent explicitement :

`Launch test Plan '002-Device_Reassign'`

La sélection de campagne n'est donc pas la cause.

---

### 9.3 Le Prepare n'explique pas la différence

Les paramètres principaux de `Prepare Jmeter Campaign Run` sont identiques entre `4440884` et `4445575` :

- même `relativCampaign`
- même dossier de résultats
- même `FOLDER_ID`

---

### 9.4 OS / image agent identiques

Les deux runs ont tourné sur des workers différents :

- `4440884` : `Azure Pipelines 2`
- `4445575` : `Azure Pipelines 18`

Mais les deux utilisent :

- image : `windows-2025`
- version d'image : `20260830.247.1`

Le simple changement de worker ne constitue donc pas une explication suffisante.

---

## 10. Correction importante d'une conclusion intermédiaire

Une première comparaison du JMX avait conclu à tort :

`Same JMX = True`

Cette comparaison était basée sur le champ JSON `content` renvoyé par l'API Git et n'était pas suffisamment fiable pour un fichier de plusieurs Mo.

Une seconde vérification a téléchargé les **octets réels** du fichier depuis Azure DevOps pour chacun des deux commits.

### Ancien commit

Commit :

`ef3d87034d38b88aca04c824061b140e2a29252c`

Fichier :

`002-Device_Reassign.jmx`

Taille :

`4 097 371 octets`

SHA-256 :

`39E6036031D1AD30304405D3E08DA159DA89B94F0E1ADC7B4BB6A5C14CFBE59E`

### Nouveau commit

Commit :

`95aede774dcc45ba7e69abe163e6be410ae0c496`

Taille :

`4 098 601 octets`

SHA-256 :

`A59C06A49C64306F674143D4C4FAED73C234CD15047C0913BA47944C1CE313BA`

Conclusion :

**les deux fichiers JMX ne sont pas identiques.**

C'est le dernier résultat obtenu avant la pause et il change fortement l'orientation du diagnostic.

La piste prioritaire à la reprise n'est donc plus une différence d'environnement JMeter, mais :

**identifier précisément ce qui a changé dans `002-Device_Reassign.jmx` entre `ef3d8703...` et `95aede77...`, notamment autour de la structure `HeaderManager` signalée ligne 8522.**

---

## 11. Hypothèse de travail prioritaire à la reprise

Le nouveau JMX contient probablement une modification structurelle incompatible avec le modèle arbre attendu par JMeter 5.6.3.

Le message :

`HeaderManager cannot be cast to HashTree`

est typique d'une incohérence dans l'alternance attendue des éléments JMeter et de leurs `<hashTree>` associés.

La prochaine investigation doit donc être extrêmement ciblée :

1. télécharger les deux versions réelles de `002-Device_Reassign.jmx` ;
2. comparer uniquement la zone autour de la ligne ~8522 du nouveau fichier ;
3. identifier le premier changement structurel autour du `HeaderManager` fautif ;
4. remonter au commit ou au script ayant produit cette différence ;
5. déterminer si cette modification provient :
   - d'une régénération du JMX ;
   - d'un patch automatique ;
   - du fallback de transport ;
   - d'un autre commit d'investigation.

Ne pas relancer un pipeline complet avant d'avoir compris cette différence.

---

## 12. Leçons techniques utiles

### Toujours vérifier la couverture avant de comparer Cur/Fix

Deux côtés peuvent afficher exactement les mêmes compteurs d'échecs tout en ayant perdu une campagne entière.

Ici :

- Cur = 314 non-passés
- Fix = 314 non-passés
- mêmes 314 tests

Cela semblait excellent.

Mais les deux côtés avaient perdu 86 tests.

Le bon ordre d'analyse est donc :

1. total attendu ;
2. total réellement publié ;
3. périmètre commun ;
4. seulement ensuite comparaison Cur/Fix.

---

### Un `Run Jmeter Tests Campaign = succeeded` ne garantit pas que tous les JMX ont tourné

Le runner continue après un échec individuel de chargement d'un plan.

Ici :

`002-Device_Reassign` retourne `errorlevel=1`

puis le script continue avec :

`003-Device_Connect`

Le job reste néanmoins vert au niveau de la tâche d'exécution.

Il faut donc surveiller :

- plans annoncés ;
- plans réellement chargés ;
- nombre de tests publiés ;
- erreurs `NonGUIDriver`;
- variations brutales de couverture.

---

### `PublishTestResults = succeededWithIssues` est ici un signal fonctionnel, pas un problème de publication

Les 1905 résultats sont correctement publiés.

Le jaune vient de :

`There are one or more test failures detected in result files`

Ce n'est pas une panne Azure DevOps.

---

### Les `unanalyzedTests` sont essentiels dans cette chaîne JMeter

Les cas non passés apparaissent dans les compteurs Azure DevOps comme `unanalyzedTests`.

Ne regarder que `failedTests` peut masquer les vrais volumes de tests non passés.

---

### Comparer les identités de tests, pas seulement les nombres

Deux runs avec le même nombre d'échecs peuvent échouer sur des tests différents.

La comparaison par noms de tests a permis d'établir que les 314 non-passés de Cur et Fix étaient exactement les mêmes.

---

### Lorsqu'un total baisse, chercher d'abord un groupe entier disparu

Au lieu d'inspecter 86 tests un par un, le regroupement par préfixe a montré immédiatement :

`86 | 002-Device:Reassign`

Cette approche est beaucoup plus efficace.

---

### Toujours différencier "absent du dépôt", "non sélectionné", "non lancé" et "lancé mais non chargé"

Pour `002-Device_Reassign`, les étapes ont été éliminées successivement :

- présent dans Git : oui ;
- sélectionné : oui ;
- lancé : oui ;
- chargé par JMeter : non.

Cette décomposition évite de corriger la mauvaise couche.

---

### Ne jamais valider l'égalité de gros fichiers via un champ API ambigu

La première vérification de contenu a produit un faux positif.

Pour comparer réellement deux fichiers :

- télécharger les octets ;
- comparer la taille ;
- calculer SHA-256.

Cette méthode a révélé une différence réelle de `1230 octets`.

---

### Un environnement agent identique doit être vérifié au niveau de la version d'image

Le nom `windows-2025` seul ne suffit pas.

Ici les deux runs avaient aussi la même version :

`20260830.247.1`

Cela a permis d'écarter raisonnablement une mise à jour d'image entre les deux exécutions.

---

### Garder les sorties d'investigation très ciblées

Les premiers probes Azure DevOps produisaient trop de données.

La méthode efficace a été ensuite :

- une seule question par probe ;
- quelques lignes de sortie ;
- fichier TXT temporaire ;
- ouverture automatique dans Notepad ;
- pas de dump complet de timeline ou de logs.

Cette convention doit être conservée pour la suite.

---

## 13. État à la pause

### Confirmé

- le build InventoryTracking fonctionne ;
- le transport local fonctionne suffisamment pour exécuter les campagnes ;
- Docker preflight est vert ;
- Cur et Fix publient chacun 1905 résultats ;
- leurs 314 tests non passés sont exactement identiques ;
- aucune régression Cur/Fix n'est visible parmi les tests exécutés ;
- 86 tests manquent par rapport à la baseline ;
- les 86 appartiennent tous à `002-Device:Reassign` ;
- le JMX est bien lancé ;
- JMeter 5.6.3 échoue à le charger avec une erreur `HeaderManager -> HashTree` ;
- ancien et nouveau JMX sont réellement différents.

### Non résolu

- quelle modification exacte du JMX provoque l'erreur ;
- quel commit/script a produit cette modification ;
- si la correction doit porter sur le JMX généré, le générateur ou un patch de migration ;
- le statut final du TC122 une fois la campagne restaurée ;
- la décision de PR finale.

### Action prioritaire à la reprise

**Comparer les deux versions réelles de `002-Device_Reassign.jmx` autour de la zone fautive et identifier le changement structurel introduit entre `ef3d8703...` et `95aede77...`.**

Ne pas relancer `4445575` ou un nouveau pipeline avant cette analyse.
