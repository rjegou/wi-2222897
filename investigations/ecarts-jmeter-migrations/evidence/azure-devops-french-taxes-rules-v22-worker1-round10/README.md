# Préflight ACR V22 corrigé — Worker 1 round 10

Date : 2026-09-07. Collecte lecture seule après l’unique run autorisé. Aucun rejeu, restauration SQL, déploiement de package, publication, modification de droits ou ressource partagée.

## Périmètre et autorisation

- Définition : `14246`, `WI-2222897 V22 Runtime Preflight 20260907`.
- Dépôt : `Y2_Plugins_FrenchTaxesRules`.
- Branche : `refs/heads/codex/wi-2222897-v22-preflight-20260907`.
- Service connection : `AzureContainerRegistry-Docker-Retail`.
- L’action de queue était explicitement limitée à ce préflight runtime et à cette branche/définition par la délégation Worker 1.

## Adresse d’image

**FACT — preuve rapportée par l’utilisateur (2026-09-07)** : le `loginServer` exact d’AcrRetailDocker est `acrretaildocker-e2c3eugzbee2habm.azurecr.io`.

**FACT — preuve primaire non sensible** : la lecture Azure DevOps du service connection ID `5fc079c9-4b68-403f-8c57-40274d100a94` retourne `registrytype=ACR`, `registryId=/subscriptions/8cb20e30-a975-4c7c-ae4e-90b90e600c5c/resourceGroups/retail-acr/providers/Microsoft.ContainerRegistry/registries/AcrRetailDocker` et `azureSpnPermissions` avec `provisioned=true`. Le champ `loginServer` n’est pas retourné par cette API.

**FACT local** : le candidat `replay-prep/2026-09-07-v22-isolated/azure-pipelines.candidate.yml` a été corrigé pour utiliser :

`acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`

Le tag complet et le digest complet sont conservés dans les deux références `image` du candidat. `MANIFEST.sha256` a été recalculé pour le fichier candidat.

## Run unique

Run `4442003`, soumis via Azure CLI le 2026-09-07 sur la branche et la définition ci-dessus. Source version : `5036e501ba797ab7efc861add60b111a40ff8141`. Résultat final : `failed`, terminé `2026-09-07T15:48:08.428318+00:00`.

Timeline : authentification registry `succeeded`, checkout `skipped`, inspection image `failed`, nettoyage/finalisation `succeeded`. Log 7 : `docker pull` a reçu la référence non qualifiée `cegid-retail-docker-production/y2-jmeter...` et a retourné `pull access denied ... repository does not exist or may require 'docker login'`. Aucun conteneur, mount, réseau, OS/image runtime ou appel métier n’a donc été prouvé.

## Limite et verdict

**FACT** : le run a utilisé le commit distant `5036e501…`, antérieur à la correction locale du candidat ; le commit exécuté ne portait donc pas le hostname confirmé.

**UNKNOWN** : acquisition ACR avec le hostname exact, compatibilité OS/agent, identité/cycle de vie du conteneur, mounts/réseau et cleanup runtime. Le cleanup/finalize Azure Pipelines a réussi, mais il ne prouve pas le cleanup d’un conteneur jamais créé.

**VERDICT** : préflight bloqué au premier obstacle d’image ; rejeu métier `NOT RUN`. Aucun second run ne doit être lancé dans ce lot.
