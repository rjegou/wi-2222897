# SQL Full-Text — lecture live build 4442156 et diagnostics ciblés

Date de collecte : 2026-09-08 (Europe/Paris).

## Provenance et méthode

- Système source : Azure DevOps REST Build API, projet `Retail`, définition `14251`.
- Identifiants lus : builds `4442156`, `4442685` et `4442254` ; timelines, listes de logs et artefacts ; logs ciblés `9`, `14`, `18` ; artefacts des builds `4442685`.
- Méthode : requêtes GET read-only via Python `requests`/OpenSSL, PAT lu depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`, gardé uniquement en mémoire puis supprimé de la variable Python. Les téléchargements d’artefacts ont été lus en mémoire ; aucun secret ni artefact brut n’est copié ici.
- Fraîcheur : lecture live effectuée le 2026-09-08 ; résultats datés par Azure DevOps au 2026-09-07.
- Effets distants : aucune queue, annulation, publication, modification ou relance.

## Résultat factuel

**FACT** — le build `4442156` (`WI-2222897-SQLFullText-HostedBuild-20260907.4`, définition `14251`) est maintenant `completed` / `failed`, avec `finishTime=2026-09-07T16:58:11.4257452Z`, branche `sandbox/WI-2222897-sql-fulltext`, commit `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`.

**FACT** — sa timeline montre les stages `SQL Server 2019 Full-Text build and smoke` et `SQL Server 2025 Full-Text build and smoke` tous deux `completed` / `failed`. Les deux tâches de smoke échouent sur `Full-Text population did not finish: [1]` (logs 9 et 14). Les deux publications PipelineArtifact sont `skipped`; la liste d’artefacts est vide.

**FACT** — les images exactes construites dans `4442156` sont taguées `sql-fulltext-smoke:2019` et `sql-fulltext-smoke:2025`; les IDs d’image Docker imprimés sont respectivement `882fd03a464cc950e7012e3c1f593cc8f062e0ef0edc53583e4fffcd74594dee` et `a1864fd305bb719ac9fe82a3983f94be6b12416fb027b89d00e5825e5c455a5e`.

**FACT** — le build `4442685` (`...20260907.7`, commit `e3b674b007071259fd74b024f6b4b48baf0a7f5d`) est `completed` / `failed` à `2026-09-07T20:02:23.5877387Z`. Les deux stages échouent aussi. Les logs ciblés montrent 18 observations `FULLTEXT_OBSERVATION_EXIT=0` sur chaque variante, puis SQL2019 conserve `1 1` et SQL2025 conserve `Starting 1 0 0`; les deux finissent par `Full-Text population did not finish: [1]`. Les deux artefacts sont publiés.

**FACT** — les artefacts `4442685` sont téléchargeables :

| Artefact | Taille ZIP | SHA-256 ZIP | Fichier diagnostic | SHA-256 fichier |
|---|---:|---|---|---|
| `sql-fulltext-2019-evidence` | 11104 | `6d509ef6f21fa9adc8db2f20954cdd2376142479b4c24d242e804a6fcfba5dcd` | `sql-fulltext-2019-runtime-diagnostic.log` (78548 octets) | `82d02d5324587faecdceb312d5041a93de9305569cdd0ac8297fe72249755f25` |
| `sql-fulltext-2025-evidence` | 11798 | `1eeff8feafb3f879e5feac4856b71b1ce67269091846149430f98e460d0cfa52` | `sql-fulltext-2025-runtime-diagnostic.log` (80745 octets) | `58afba9c5305b5090cf4f1dbc706ab8c7580c4f2f736744bd0b01df3e2cadc26` |

**FACT** — le build `4442254` est également `completed` / `failed`; ses deux stages échouent, et ses artefacts existent. Il n’apporte pas de résolution : ses logs ciblés s’arrêtent également sur `Full-Text population did not finish: [1]`.

## Verdict Clienteling / 224 cas

**FACT** — le problème d’infrastructure Full-Text n’est pas résolu par les builds observés : les deux versions SQL échouent encore leur smoke de population dans `4442156` et `4442685`, et aucun `CONTAINSTABLE` réussi n’est démontré dans la collecte ciblée.

**INFERENCE** — les 224 cas Clienteling restent bloqués par cette précondition d’image SQL jusqu’à un build Full-Text dont le probe atteint une population terminée et un hit `CONTAINSTABLE`.

**UNKNOWN** — la cause runtime précise (FDHOST, crawl, configuration, timing ou autre) n’est pas isolée par ces résultats ; le statut global du pipeline ne suffit pas à la déterminer. Aucun résultat JMeter Cur/Fix n’est déduit.

## Impact sur le prochain rejeu

Ne pas lancer le rejeu Clienteling sur la base de `4442156`/`4442685`. Le prochain rejeu doit d’abord vérifier dans la timeline et les artefacts de l’image ciblée : population terminée, hit `CONTAINSTABLE`, cleanup prouvé, puis seulement consommer l’image par le workflow JMeter. Les artefacts `4442685` sont la source ciblée à conserver pour le diagnostic différentiel ; les logs bruts restent hors de cette preuve documentaire.
