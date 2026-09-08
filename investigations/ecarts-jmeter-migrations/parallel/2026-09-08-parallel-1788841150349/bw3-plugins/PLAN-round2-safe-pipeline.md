# Plan de revue — InventoryTracking Build + JMeter isolés

Date : 2026-09-08 (Europe/Paris)

## Périmètre et état vérifié

- Branche cible : `refs/heads/validation/WI-2222897-inventorytracking-xmldiff`.
- Commit : `ef3d87034d38b88aca04c824061b140e2a29252c`, parent `4de185bb...`.
- Définition : `2072` (`InventoryTracking CI`).
- Le correctif ne touche que `Services.Tests.csproj` et son `packages.config`.
- Les DLL locales vérifiées correspondent exactement aux références : `Cegid.Retail.XmlDiff` 1.0.0.0 / token `3ea389785c619660` et `XmlDiffPatch` 1.0.8.28 / token `b03f5f7f11d50a3a`.
- Le clone privé documenté par `bw3-plugins/README.md` n'est plus présent à `bw3-plugins/worktrees/inventorytracking`; aucun clone n'est recréé. La ref distante, elle, est actuellement retrouvée par REST et pointe sur ce commit.

## Consommateurs et collisions

Le YAML InventoryTracking consomme directement :

1. l'artefact de pipeline `$(componentVersion)_nuget` via `download: current` dans chaque job JMeter ;
2. l'image ACR `cegid-retail-docker-production/y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025` via le conteneur `acr_y2jmeter_test` ;
3. les fichiers `Tests/Config/v26-cur.cy2px`, `v26-fix.cy2px`, `Tests/Backups/AUTO_V26_00.bak` et les 32 JMX WebServices.

Le job `Publish` est séparé de l'artefact de pipeline : il pousse vers Artifactory staging sous `InventoryTrackingPlugin/<VersionMajor>.<VersionMinorRevision>`. Le job `Ensure_Docker_Image_Up_To_Date` peut, si l'image manque, importer l'image source JFrog production vers l'ACR partagé `AcrRetailDocker`. Ce sont deux effets externes distincts.

Sur une branche `validation/*` avec `pipelineDevMode=true`, la condition actuelle active ces deux jobs et les stages JMeter. `Promote` ne passe pas la condition master/release : pas de promotion JFrog ni de tag de source. Une collision de version staging reste néanmoins possible car `VersionMinorRevision` est une counter YAML partagée au niveau du pipeline.

## Diff minimal proposé, limité à la branche de validation

Le premier brouillon à paramètre par défaut `true` est rejeté : il laisse une option de publication accidentelle. Le patch reviewable doit être appliqué uniquement au YAML de la branche dédiée et ne doit ajouter aucun paramètre réutilisable.

Dans `azure-pipelines.yml`, compléter les conditions de `Ensure_Docker_Image_Up_To_Date` et du job `Publish` par une exclusion littérale de la branche :

```diff
- condition: and(succeeded(), eq(variables.isMasterOrReleaseOrDevMode, true))
+ condition: and(succeeded(), eq(variables.isMasterOrReleaseOrDevMode, true), not(eq(variables['Build.SourceBranch'], 'refs/heads/validation/WI-2222897-inventorytracking-xmldiff')))
```

Le patch ne modifie ni Build, ni l'artefact `$(componentVersion)_nuget`, ni les jobs JMeter. Il ne change pas les pipelines habituels : après fusion sur `master` ou une branche release, la condition littérale de validation est fausse. `Promote` et `Tag_Sources` sont déjà empêchés sur la branche `validation/*` par leur condition master/release.

Le run utilise `pipelineDevMode=true`, `versionsToTest=['26']`, `typesToTest=['Cur','Fix']`, `campaignsToTest=['WebServices']`. L'artefact `$(componentVersion)_nuget` reste produit par `Nuget\\nuget-build-publish.v1.yml` et consommé par `download: current`; il ne faut pas désactiver cette publication de pipeline.

## Précondition ACR indispensable

Avant d'appliquer l'exclusion `Ensure`, vérifier en lecture seule que l'image exacte existe déjà dans `AcrRetailDocker`. Si elle n'existe pas, le run sans import échouera au démarrage du conteneur ; il faut alors arrêter le run, ou accepter séparément l'import ACR borné. Le build `4440884` a prouvé rétrospectivement que l'image était consommable, mais pas qu'elle est encore présente aujourd'hui.

## Provenance REST du build et des templates

Collecte du 2026-09-08 par Python `requests` avec OpenSSL, PAT lu en mémoire depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`, jamais affiché ni persisté.

- `GET .../_apis/git/repositories/Y2_Plugins_InventoryTracking/refs?filter=heads/validation/WI-2222897-inventorytracking-xmldiff` : une ref, objet `ef3d87034d38b88aca04c824061b140e2a29252c`.
- `GET .../_apis/git/repositories/Y2_Plugins_InventoryTracking/commits/ef3d87034d38b88aca04c824061b140e2a29252c` : parent `4de185bb132cfbfb50643b6b53d6feb85508f4e2`.
- `GET .../_apis/git/repositories/Y2_Plugins_InventoryTracking/items?path=/azure-pipelines.yml&versionDescriptor.version=ef3d8703...&includeContent=true` : YAML récupéré, objet `ad26adf4a2dee62274d90e3506e0bf1629a46c84`; les trois ressources templates n'ont pas de propriété `ref`.
- `GET .../_apis/build/builds/4440884` : `partiallySucceeded`, sourceVersion `ef3d8703...`, définition `2072`.
- Les logs de checkout de 4440884 prouvent `Y2_Tools_PlatformDeploy@master` au commit `93f91487ee717185599555a42df3cb5d024ace89`. Aucun checkout/version exact de `Pipelines_Templates` ou `Y2_Tools_Jmeter_Workflow` n'est exposé par les logs consultés; leurs versions consommées restent `UNKNOWN`. Le YAML ne contient aucun `ref` pour ces trois ressources : un patch durable devrait les épingler explicitement, mais ce serait un changement fonctionnel distinct de l'isolation de ce run.

## Critères de vérification

- Build V26 : absence de `MSB3245`/`CS0103` XmlDiff dans le log de compilation ; présence de l'artefact pipeline `26.0.<pluginVersion>_nuget`.
- JMeter : stages `TI_Jmeter_V26_Cur` et `TI_Jmeter_V26_Fix` réellement exécutés, avec artefacts de logs et résultats pour chaque variante.
- Aucun job `Publish` ni `Ensure` exécuté sur la branche littérale de validation ; aucun stage `Promote`/tag.
- Les erreurs métier Cur/Fix restent à qualifier à partir des résultats bruts, pas du seul statut global.

## Inconnues et risque restant

- Les templates externes effectivement résolus (`Pipelines_Templates`, `Y2_Tools_Jmeter_Workflow`, `Y2_Tools_PlatformDeploy`) ne sont pas accessibles dans l'environnement courant ; leur version consommée et leurs éventuels effets `finally` restent `UNKNOWN`.
- L'existence actuelle de l'image ACR et la collision de la counter `VersionMinorRevision` restent `UNKNOWN`.
- Le build complet local n'est pas une preuve : le targeting pack .NET Framework 4.8 et des assemblies Cegid manquent sur le poste.
- Aucun pipeline, push, publication ou modification du workflow utilisateur n'est effectué dans ce lot.
