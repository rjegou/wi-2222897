# V22 baseline packages and historical image — Worker 1 round 5

Date : 2026-09-07. Collecte read-only. Le token JFrog a été lu en mémoire depuis `C:\Users\jegour\OneDrive - CEGID\Documents\jfrogToken.txt`, transmis au processus Python `requests` avec validation TLS activée, puis non conservé ni affiché. Aucun pipeline, job distant, déploiement, publication, restauration ou nettoyage partagé n'a été lancé.

## Packages baseline exacts

Pour chaque chemin historique du run `4429167`, la métadonnée JFrog a répondu HTTP 200, puis le ZIP a été lu directement en flux sans écriture disque. Le nombre d'octets et le SHA-256 calculé concordent avec la métadonnée serveur.

| composant | chemin exact | octets | SHA-256 serveur | SHA-256 flux |
|---|---|---:|---|---|
| Y2.Core `22.0.0.1011` | `retail-software-production/Y2.Core/22.0/Y2.Core.22.0.0.1011.zip` | 414687259 | `7BAB5C985D7060EBF6F8084D96A3BA7967C5B5C70387F20BDCCC9F1635310573` | identique |
| Y2.Core.Common `22.0.2.300` | `retail-software-production/Y2.Core.Common/2.300/Y2.Core.Common.22.0.2.300.zip` | 6415287 | `037D7C7ACC5F5C1F948CE2383177A1C31390BE74976B04C4DA31EFBD89D70CAD` | identique |
| Y2.Plugin.Identity `22.0.5.182` | `retail-software-production/IdentityPlugin/5.182/Y2.Plugin.Identity.22.0.5.182.zip` | 3029289 | `23AE1D0CFD54B34024A6312AF818AEE6CB504CF54909A69BDE672B4B11AB59FF` | identique |

**FACT** — les identifiants baseline et leurs empreintes sont donc maintenant résolus pour un rejeu immuable. Cela ne prouve pas encore la compatibilité runtime ni le résultat JMeter.

## Image historique ACR/JFrog

Chemin manifest authentifié : `all-docker/y2-jmeter/sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022/manifest.json`.

**FACT** — `GET /api/storage/.../manifest.json` répond HTTP 200, taille 6838 octets, SHA-256 serveur `2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`. Le GET direct du manifest répond HTTP 200, taille 6838 octets, avec schema Docker v2 et media type `application/vnd.docker.distribution.manifest.v2+json`. Le digest JFrog correspond exactement au digest historique observé dans le log ACR du build `4429167`, log `15`.

La vérification locale a donc réussi avec TLS validé ; aucun préflight distant n'a été créé, car il n'était plus nécessaire. La présence du manifest prouve la disponibilité de l'identité image ; elle ne prouve pas la compatibilité de l'agent ou l'exécution d'un conteneur Windows.

## Classification

- **FACT** : trois ZIP baseline disponibles, HTTP 200, hash serveur = hash du flux.
- **FACT** : manifest image historique disponible, HTTP 200, digest exact `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.
- **UNKNOWN** : compatibilité de l'image avec l'agent choisi, démarrage effectif du conteneur et résultat métier/JMeter.
