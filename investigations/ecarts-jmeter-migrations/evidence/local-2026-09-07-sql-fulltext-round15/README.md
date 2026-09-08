# SQL Full-Text — reprise round15 (2026-09-07)

## Périmètre et provenance

- Date de collecte : 2026-09-07, Europe/Paris.
- Source locale : `worktrees/Pipelines_Docker_BaseImages`.
- Scope : uniquement SQL Full-Text 2019/2025; FrenchTaxesRules releases/V5/V22 et les documents partagés sont hors périmètre.
- Méthodes : lecture des index/README de collecte, inspection Git en lecture avec `-c safe.directory` limité à la commande, inspection des Dockerfiles/YAML et contrôles locaux Docker.
- Aucun secret n’a été affiché, copié ou persisté.

## État Git et modifications préexistantes

`git -C worktrees/Pipelines_Docker_BaseImages status --short --branch` a d’abord été exécuté comme demandé et a retourné `fatal: detected dubious ownership`.
La même lecture avec une exception `safe.directory` limitée à la commande donne :

```text
## master...origin/master
 M Images/SqlExpress/2019/dockerfile
 M Images/SqlExpress/2025/dockerfile
 M Images/SqlExpress/tests.yml
```

FACT — les trois modifications locales sont toujours présentes; aucune n’a été modifiée par cette collecte.

Empreintes SHA-256 de l’état observé :

| fichier | SHA-256 |
|---|---|
| `Images/SqlExpress/2019/dockerfile` | `B8198C2A1B032564C2AD7CAC75FEE30F2822A4A05D4E0CE8F1D09FD2278C2234` |
| `Images/SqlExpress/2025/dockerfile` | `016EAE89BECC02487CEAA8970296EAEF67871AD0792D01DDFD7D4D9F9D775999` |
| `Images/SqlExpress/tests.yml` | `24ABA90EB8D81BEBE5701EC27FB4DC7B1C8B15746C54018EFBA2CE624B7CF367` |

## Test discriminant déjà lancé

FACT — la collecte récente `2026-09-07-brain-reprise-worker2-round14` indique que le build dédié `4442156`, définition `14251`, branche `sandbox/WI-2222897-sql-fulltext`, était encore `inProgress` pour ses stages SQL 2019 et SQL 2025 au dernier point observé. Il utilise le diagnostic qui collecte le service/process SQL, `FULLTEXTSERVICEPROPERTY`, les statuts de catalogue/table, fragments, DMV de population et la fin d’ERRORLOG avant suppression du conteneur.

FACT — le build antérieur `4442121` a construit les deux images et obtenu `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')=1`, mais les catalogues sont restés à `PopulateStatus=1` pendant 90 secondes; aucun `CONTAINSTABLE` n’a été atteint. La prochaine preuve utile est donc le résultat terminal et les artefacts diagnostics de `4442156`, pas un nouveau harness.

## Isolation et moyens locaux

FACT — les YAML dédiés relus dans les collectes antérieures sont build/test-only : aucune publication d’image, feed, promotion, tag, déploiement ou modification de définition partagée.

FACT — Docker local est indisponible : `docker info` retourne l’absence du pipe `//./pipe/docker_engine`; la lecture de `C:\Users\jegour\.docker\config.json` est également refusée. Aucun build ou conteneur local n’a donc été lancé.

UNKNOWN — le statut terminal et les artefacts de `4442156` n’ont pas pu être relus dans cette session : l’appel REST avec le PAT local a échoué sur la connexion SSL/authentification, et l’accès navigateur Azure DevOps a été refusé par la politique de sécurité. Ces échecs ne prouvent ni succès ni échec du build.

## Verdict et postconditions

FACT — aucune installation SQL, acquisition média 2019 Advanced, build Docker, publication distante ou promotion n’a été effectuée par cette collecte; aucun fichier partagé (`HANDOFF.md`, `STATUS.md`, `RESOURCES.md`, `JOURNAL.md`) n’a été modifié.

INFERENCE — le prochain test discriminant déjà en cours est suffisant pour distinguer installation moteur (`FULLTEXTSERVICEPROPERTY=1`) et blocage de population; il faut attendre sa clôture avant toute correction supplémentaire.

UNKNOWN — disponibilité fonctionnelle du catalogue Clienteling et de la fonction produit restent non prouvées, même si l’installation Full-Text est confirmée.

Postcondition locale : nouvelle collecte evidence-only créée; aucune modification du worktree ou d’un système externe.
