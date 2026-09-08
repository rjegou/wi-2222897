# Revalidation JFrog du packaging V22 — 2026-09-07

## Périmètre et méthode

Collecte strictement en lecture seule le 2026-09-07 sur `https://cegid.jfrog.io/artifactory`.
Le jeton a été lu en mémoire depuis `C:\Users\jegour\OneDrive - CEGID\Documents\jfrogToken.txt`, utilisé dans un header Bearer, puis écarté de la variable du script. Sa valeur n'est pas reproduite ici.

Requêtes utilisées :

- `GET /api/system/ping` (connectivité/authentification) ;
- `GET /retail-software-production/y2-distrib/22.0/22.0.23/ArtifactsToDownload.json` ;
- `GET /api/storage/retail-software-production/<chemin>` pour les métadonnées et checksums ;
- `GET /api/storage/retail-software-production/<chemin>?properties` pour les propriétés de build ;
- `GET` direct de chaque ZIP, en flux de 1 MiB, avec SHA-256 calculé en mémoire. Aucun ZIP n'a été écrit sur disque.

L'exécution PowerShell/curl a rencontré localement `SEC_E_NO_CREDENTIALS` dans Schannel ; la même lecture via Python `requests` a répondu HTTP 200. Cette différence d'outil n'affecte pas les réponses JFrog obtenues par Python.

## Manifeste

URL exacte : `https://cegid.jfrog.io/artifactory/retail-software-production/y2-distrib/22.0/22.0.23/ArtifactsToDownload.json`.

FACT — HTTP 200, 5448 octets, checksum serveur SHA-256 `4874EFCC106A3FD5C69661655227BD9C204998A87E681BA2FB4335FD923727F0`.

FACT — les entrées du manifeste déclarent : Core `22.0.0.2068`, Common `22.0.3.311`, Identity `22.0.6.117`, FrenchTaxesRules `22.0.6.379`. Il déclare aussi `Y2.Core.AuthenticationServer` `1.0.1.429` avec `OnPremOnly=true`; cela ne fournit pas le AuthenticationServer `2.0.0.368` à conserver pour l'essai demandé.

UNKNOWN — le fichier n'est pas du JSON strict : il contient des propriétés `_commentaire` non citées. Il est lisible comme texte de configuration, mais un parseur JSON strict le refuse.

## ZIP candidats

Les checksums annoncés par JFrog et ceux calculés sur le contenu téléchargé sont identiques.

| Composant | URL directe exacte | Taille serveur / flux | SHA-256 JFrog | SHA-256 calculé | Propriétés de build |
|---|---|---:|---|---|---|
| Y2.Core 22.0.0.2068 | `https://cegid.jfrog.io/artifactory/retail-software-production/Y2.Core/22.0/Y2.Core.22.0.0.2068.zip` | 417167428 / 417167428 | `1AC0BF6084F0AB62B38C2DC15BC72A7D3B57EEC6661FCF03F056322611144B7C` | identique | `Y2_Core CI`, build `22.0.0.2068` |
| Y2.Core.Common 22.0.3.311 | `https://cegid.jfrog.io/artifactory/retail-software-production/Y2.Core.Common/3.311/Y2.Core.Common.22.0.3.311.zip` | 32019299 / 32019299 | `540E96AE56B912F1F27DD17865B76E342D72024B46CE5994F5CF9B7FC7A590D2` | identique | `Common CI`, build `3.311` |
| Y2.Plugin.Identity 22.0.6.117 | `https://cegid.jfrog.io/artifactory/retail-software-production/IdentityPlugin/6.117/Y2.Plugin.Identity.22.0.6.117.zip` | 3410969 / 3410969 | `7F4426E5DB4DD94B040BD39B8EB2A3485FD9387BCEC667DD9663A35E840A96CF` | identique | `Identity CI`, build `6.117` |

Les checksums SHA-1/MD5 annoncés par JFrog ont également été relevés dans la sortie de métadonnées, mais le contrôle de concordance retenu ici est SHA-256 :

- Core : SHA-1 `20f76e5ca04babbb1f9d9b9f6244899a26502071`, MD5 `5c5a9b2dfa79b5af9af51304d7c922f7` ;
- Common : SHA-1 `5cdf8dad41d1b7395ae7eabcb7045a6fa2183661`, MD5 `3a25b479a3636b3efd29383a2cddbac0` ;
- Identity : SHA-1 `d936293d8bbc7d2533528218045e8878a240639a`, MD5 `a7309f040ab21127b4fd1f307420a90b`.

## Dépendances et portée

FACT — le manifeste est un inventaire de composants/version et ne déclare pas de graphe de dépendances entre ces trois ZIP. Les propriétés JFrog exposent les builds producteurs, pas les dépendances d'installation.

INFERENCE — les trois ZIP sont consommables comme candidats individuels pour Core/Common/Identity, sous réserve des règles de déploiement et de compatibilité de la cible.

UNKNOWN — aucune compatibilité avec FrenchTaxesRules `22.0.6.478` n'est démontrée par ce packaging : le manifeste contient FrenchTaxesRules `22.0.6.379`. Aucun essai d'installation ou test métier n'a été lancé pendant cette collecte.

