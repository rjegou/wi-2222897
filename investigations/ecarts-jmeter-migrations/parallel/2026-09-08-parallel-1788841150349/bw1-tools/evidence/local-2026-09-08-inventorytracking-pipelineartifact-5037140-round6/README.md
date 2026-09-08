# PipelineArtifact 5037140 — InventoryTracking local transport

Date de collecte: 2026-09-08 (Europe/Paris). Source: Azure DevOps `cegid/Retail`, run `4444887`, artifact `26.0.7.83_Software`, artifact ID `5037140`, taille déclarée 1,705,531 octets. Méthode: Azure DevOps CLI/REST avec le PAT chargé uniquement dans le processus courant; aucune valeur secrète n'est reproduite. Fraîcheur: collecte live de ce round.

## FACT — contenu et empreintes

L'archive contient une racine `26.0.7.83_Software` et exactement quatre fichiers:

| chemin relatif | octets | SHA-256 |
|---|---:|---|
| `E_IIS_SERVER_RETAIL_INVENTORYTRACKING.MSI` | 893952 | `3698C2BF67A61132B1AD878386AFF36C0F6845D31246031ACF767145D3115736` |
| `E_IIS_SERVER_RETAIL_INVENTORYTRACKING.XML` | 3236 | `AE9A5D4A5A118117E957B65FD2010F00A0EE93616640B4271B6B63B34A57D0EB` |
| `TASKSCHEDULER_RETAIL_INVENTORYTRACKING.MSI` | 806912 | `5A2084B4368E89346529290FD4FB87DE1AB0558C2BF514FB44369B80C906B308` |
| `TASKSCHEDULER_RETAIL_INVENTORYTRACKING.XML` | 1431 | `A62A31EB4B733F7BA255194070919014AEC37718B386EFF1DC9D58B97F2A2EE1` |

Les deux XML déclarent respectivement les IDs produit `IIS_SERVER_RETAIL_INVENTORYTRACKING_26.0` et `INVENTORYTRACKING_TASKSCHEDULER_ADDON_RETAIL_26.0`, et la version `26.0.7.83`. Ils ne constituent pas le manifeste `downloadedPackages.json`; ce sont les métadonnées de chaque MSI.

## FACT — contrat PlatformDeploy consommé

À `Y2_Tools_PlatformDeploy` commit `93f91487ee717185599555a42df3cb5d024ace89`, `download-packages.ps1` invoque le JFrog CLI avec `download packagelist ... -di <folder>/downloadedPackages.json`. Le modèle C# `PackageDownloaderService` sérialise une liste d'`ArtifactItem` camelCase; les champs attendus sont `uri`, `filename`, `name`, `version`. L'expansion crée un dossier `<downloadedPackagesFolder>\<ArtifactItem.Name>` et y extrait le ZIP. `install-packages.ps1` parcourt les mêmes noms de package depuis le `.cy2px` et installe les MSI présents dans ce dossier.

La pipeline `4444887` avait donc bien produit le package Build mais PlatformDeploy ne pouvait pas le résoudre via `retail-software-staging`. L'artefact PipelineArtifact est un transport séparé, sans publication feed/JFrog.

## INFERENCE — contrat expérimental minimal proposé

Une variante explicitement opt-in doit:

1. télécharger `26.0.7.83_Software` dans chaque job Cur/Fix;
2. produire sur cet agent un manifeste local contenant le nom exact `Y2.Plugin.InventoryTracking`, la version exacte `26.0.7.83`, l'identité de l'artefact et la liste des quatre chemins/hashes ci-dessus;
3. vérifier que le manifeste est unique, que les quatre fichiers attendus sont présents sans doublon et que chaque SHA-256 concorde;
4. retirer uniquement le plugin exact d'une copie temporaire du `.cy2px` pour la résolution JFrog des dépendances existantes, puis copier le package vérifié sous `downloadedPackagesFolder\Y2.Plugin.InventoryTracking`;
5. conserver le chemin normal inchangé quand l'option locale est absente, et refuser tout nom/version/manifest/path incompatible.

Cette proposition n'est pas encore un paramètre PlatformDeploy supporté en production. Elle doit rester dans une branche expérimentale revue avant push.

## UNKNOWN / limites

- Le contenu de l'archive prouve le package local et ses hashes, pas encore l'exécution du helper dans un container ni un rejeu Cur/Fix.
- `downloadedPackages.json` historique n'était pas présent dans les logs du run 4444887 car les deux déploiements ont échoué avant sa production; son schéma est établi statiquement par le code C# exact ci-dessus.
- Aucun feed, dépôt JFrog partagé, service Docker ou agent partagé n'a été modifié.
