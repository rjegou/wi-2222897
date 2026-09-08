# Diagnostic référence image 4441719 — Worker 1 round 8

Date : 2026-09-07. Lecture seule ; aucune queue, branche, définition, service connection ou permission modifiée.

## Comparaison exacte

| source | référence observée |
|---|---|
| YAML préflight local, `azure-pipelines.preflight.yml:7` | `cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb` |
| build `4429167`, log 15 | repository logique `***-retail-docker-production/y2-jmeter`, tag `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`, digest `sha256:268476...` |
| manifest JFrog round5 | host `cegid.jfrog.io`, repo `all-docker/y2-jmeter`, tag `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`, Docker-Content-Digest `sha256:268476...` |
| pull réellement tenté par 4441719, log 7 | exactement la chaîne YAML non qualifiée : `cegid-retail-docker-production/y2-jmeter` |

Le suffixe tag et le digest concordent caractère par caractère entre YAML, log ACR/JFrog et manifest. Le chemin logique ACR du run (`cegid-retail-docker-production/y2-jmeter`) concorde aussi avec le YAML. Le chemin JFrog est différent par conception (`all-docker/y2-jmeter`) et a été vérifié HTTP 200 avec le même digest ; ce n'est pas une preuve que le nom JFrog doit être utilisé comme repository ACR.

## Registry du login versus registry du pull

**FACT** — la métadonnée non sensible du service connection `AzureContainerRegistry-Docker-Retail` indique l'endpoint ACR resource ID `.../registries/AcrRetailDocker`. Le hostname ACR conventionnel correspondant est `acrretaildocker.azurecr.io` (**INFERENCE de nommage**, non imprimée directement par le log). Le log 4441719:6 confirme seulement que la tâche `Docker@2` login réussit ; elle n'imprime ni credential ni hostname.

**FACT de syntaxe Docker** — la référence effectivement passée à `docker pull` ne contient aucun hostname (`cegid-retail-docker-production/...`). Elle est donc résolue par Docker comme une référence de registre par défaut, distincte de l'ACR auquel la tâche login s'est authentifiée. Le message `pull access denied ... repository does not exist or may require 'docker login'` ne permettait pas, seul, de conclure à un manque de droits ACR ; la divergence login/pull explique l'ambiguïté.

## Correction locale préparée

Le fichier `replay-prep/2026-09-07-v22-preflight/image-reference-correction.local.patch` prépare uniquement la variable image avec le hostname ACR inféré :

`acrretaildocker.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`

Cette correction est reviewable mais n'a pas été poussée, ne modifie aucune définition et n'a pas été mise en queue. Le hostname exact doit être confirmé par le propriétaire ACR/service connection avant usage.

## Vérification de manifest et limite

**FACT** — avec le token JFrog existant et TLS vérifié, `GET https://cegid.jfrog.io/artifactory/api/docker/all-docker/v2/y2-jmeter/manifests/sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022` répond HTTP 200, media type Docker manifest v2, 6838 octets, header `Docker-Content-Digest: sha256:268476...`. Le manifest round5 via `/api/storage` répondait également HTTP 200 avec le même SHA-256.

**UNKNOWN restant** — le hostname ACR `acrretaildocker.azurecr.io` n'est pas lisible depuis ce poste (résolution/connexion réseau locale échouée) et aucun nouveau job n'a été lancé. La correction de qualification du pull est démontrée ; le hostname exact, l'accès ACR effectif et la compatibilité runtime doivent être vérifiés lors d'une future queue explicitement approuvée.

## Pourquoi deux runs

Le lot demandait un unique préflight opérationnel. Le premier run `4441699` a été lancé après preview et a révélé un défaut de robustesse du script avant l'acquisition : stderr `No such image` était traité comme erreur terminale. Le second `4441719` a été lancé uniquement après correction locale de ce défaut, sur la même définition et branche dédiées, afin d'atteindre le contrôle d'image réel. Aucun troisième run n'a été lancé ; la correction d'adresse est maintenant préparée localement sans nouvelle queue.
