# Préflight runtime V22 isolé — Worker 1 round 7

Date : 2026-09-07. Lot exécuté seul, sans rejeu métier. Aucun checkout du dépôt, restauration de base, package deployment, appel métier, publication ou nettoyage partagé.

## Support dédié et validation

- Branche dédiée créée dans `Y2_Plugins_FrenchTaxesRules` : `refs/heads/codex/wi-2222897-v22-preflight-20260907`, base code `2d826b8fd19ecb4d7200f574414efb7583de8ed2`.
- YAML dédié : `/azure-pipelines.wi2222897-v22-preflight.yml`.
- Commit initial YAML : `0636ad652d3fa0d5dfe34287fca95c985a7d633e`.
- Commit corrigé (gestion non fatale du cache Docker absent et hash conditionnel des sorties) : `5036e501ba797ab7efc861add60b111a40ff8141`.
- Hash local du YAML corrigé : `25CCD6EB2CAA58B8E593120587E95095488D67A4525BCCDE6177167EC352FAAE`.
- Définition dédiée : pipeline `14246`, nom `WI-2222897 V22 Runtime Preflight 20260907`, dossier `\\Y2\\Plugins`, queue `Azure Pipelines` `591`, dépôt `Y2_Plugins_FrenchTaxesRules`.
- Preview serveur du commit corrigé : HTTP 200, YAML final hash `26441A1A1A850C41AD754C05C62B5008E31045C14C09B8282034A28BF6844102`, `checkout:none` compilé en tâche `repository: none`, trigger/pr désactivés, image historique conservée.

La définition historique `2054` et ses triggers n'ont pas été modifiés. La définition dédiée possède `triggers: []` et le YAML `trigger: none`, `pr: none`, `schedules: []`.

## Contenu et bornes du préflight

Le YAML est entièrement inline et utilise l’image exacte `cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.

Le job `windows-latest` est borné à 10 minutes, avec annulation à 1 minute. Il collecte uniquement OS hôte, version Docker, identité/OS/architecture/layers de l’image, identité/labels/état du conteneur, mounts et réseaux. Aucun mount n'est ajouté par `docker create`; les mounts en lecture/écriture ou hors chemins standards sont séparés dans `dangerousMounts`. Le conteneur créé porte les labels WI/run et est supprimé dans `finally`; aucune image partagée n'est supprimée. Les sorties sont agent-temp uniquement et aucun artifact n'est publié.

## Exécutions réelles

### Run 4441699 — échec de script corrigé ensuite

Source commit `0636ad652d3fa0d5dfe34287fca95c985a7d633e`, définition `14246`. Docker login réussi ; checkout skipped. Le script traitait le stderr normal de `docker image inspect` sur cache absent comme une erreur PowerShell (`No such image`), avant tout pull. Aucun conteneur ni output n'a été créé.

### Run 4441719 — blocage externe final

Source commit `5036e501ba797ab7efc861add60b111a40ff8141`, définition `14246`. Preview/queue HTTP 200. Timeline : Docker login `succeeded`, checkout `skipped`, inspection `failed`, job `failed`, nettoyage final `succeeded`.

Le log d'inspection `7` donne exactement : `pull access denied for cegid-retail-docker-production/y2-jmeter, repository does not exist or may require 'docker login': denied: requested access to the resource is denied`. Le service connection utilisé est `AzureContainerRegistry-Docker-Retail`, endpoint ACR `AcrRetailDocker`; son login réussit, mais le pull du repository historique est refusé. Le log `8` confirme seulement l'absence d'output : `No preflight output was produced.`

## Verdicts

- **Préflight distant sans écriture métier : FAIL/BLOCKED par accès image.** La chaîne dédiée, les triggers, checkout:none, bornes et nettoyage sont vérifiés serveur et par timeline. La preuve runtime OS/image/conteneur/mount/réseau n'est pas obtenue, car l'agent ne peut pas tirer l'image malgré le login du service connection.
- **Rejeu métier : NOT RUN.** Aucun stage de restauration, déploiement, JMeter ou appel métier n'était présent dans ce YAML et aucun autre pipeline n'a été lancé.

Décision nécessaire : fournir/autoriser une source d'image lisible par le service connection (ou un service connection explicitement autorisé au repository historique) avant tout nouveau préflight. Aucun contournement TLS, secret ou permission partagée n'a été tenté.
