# SQL Full-Text runtime — build 4442685

Date de collecte : 2026-09-07 (Europe/Paris). Système source : Azure DevOps `cegid/Retail`, définition `14251`, dépôt `Pipelines_Docker_BaseImages`. Méthode : Azure CLI avec PAT en mémoire du processus, lecture REST de la ref, définition, build, timeline, logs et métadonnées d’artefacts. Aucun secret, payload SQL ou valeur de mot de passe n’est conservé.

## Identité et périmètre

- **FACT** — branche distante `refs/heads/sandbox/WI-2222897-sql-fulltext` : commit `e3b674b007071259fd74b024f6b4b48baf0a7f5d`.
- **FACT** — définition `14251`, `WI-2222897 SQL FullText Hosted Build Round11`, YAML `/validation/WI-2222897/sql-fulltext-hosted-build.yml`, dépôt `Pipelines_Docker_BaseImages`, `trigger/pr/schedules` désactivés.
- **FACT** — worktree local `worktrees/Pipelines_Docker_BaseImages_worker2_round9` détaché, propre, HEAD `e3b674b007071259fd74b024f6b4b48baf0a7f5d`.
- **FACT** — le probe distant au SHA cible a le SHA-256 `CB44CC181CE89E292676DF39D3591AF4D209C7977287301537CDEF684C8D911D`, identique au local. Le YAML diagnostic distant est `86E9634CA8CD6E9334A7858423DC442296D61F859F9172F3F8653F4999286C8F`, identique au local. Le YAML build distant est `09E0CC2FDCA88AB308526DA306C88760B60CB78DF783C3DECEB941348ED26224`; le fichier local de départ est différent (`D805FE7B73A4CF8EE4CBC3D50EAC39903BF13997BD993BA6D1D3794B55AEE2B7`) et n’a pas été modifié.
- **FACT** — le YAML serveur construit localement les tags `sql-fulltext-smoke:2019` et `sql-fulltext-smoke:2025`, exécute les probes, collecte les diagnostics et publie seulement deux Pipeline Artifacts. Aucune commande de push, ACR, JFrog, promotion ou tag distant n’est présente dans la projection relue.

## Queue et résultat

- **FACT** — avant lancement, définitions 14250/14251 : aucun run `inProgress` ou `notStarted`, aucun run au SHA cible.
- **FACT** — un seul run a été lancé : build `4442685`, manuel, branche ci-dessus, SHA exact cible; début `2026-09-07T19:47:43.085Z`, fin `2026-09-07T20:02:23.588Z`, résultat `failed`.
- **FACT** — timeline : SQL2019 failed (`Build and smoke-test` failed, `errorCount=1`), SQL2025 failed (`errorCount=1`); les deux tâches de publication d’artefact ont succeeded.
- **FACT** — artefacts annoncés : `sql-fulltext-2019-evidence` (79 417 octets, source `5035170`) et `sql-fulltext-2025-evidence` (81 614 octets, source `5035185`).

## Résultats Full-Text

- **FACT — SQL2019** — checkout à `e3b674b`; image `sql-fulltext-smoke:2019` taguée; le probe émet 18 observations `FULLTEXT_OBSERVATION_EXIT=0`, puis échoue avec `Full-Text population did not finish: [1]` à `2026-09-07T19:55:14.294Z`. `CONTAINSTABLE` n’est donc pas atteint.
- **FACT — SQL2025** — la stage et la tâche smoke échouent à `2026-09-07T20:02:09.587Z`; aucun log runtime SQL2025 lisible n’est retourné par l’API des logs dans cette collecte.
- **UNKNOWN** — `FULLTEXTSERVICEPROPERTY`, `CONTAINSTABLE`, statuts DMV détaillés, identité image finale SQL2025 et cause précise de son échec.
- **UNKNOWN** — cleanup effectif des conteneurs et bases. Le YAML contient `docker rm -f`, mais son effet runtime n’est pas prouvé par les logs conservés ici.

## Limites et prochaine action discriminante

Le téléchargement des deux Pipeline Artifacts a échoué côté poste avec `SEC_E_NO_CREDENTIALS`/TLS Schannel. Les métadonnées, la timeline et les logs REST restent lisibles; aucun second run n’a été lancé pour contourner ce blocage. La prochaine action discriminante est une récupération authentifiée des artefacts/logs via un chemin TLS fonctionnel, puis lecture des diagnostics SQL2019/SQL2025 et vérification explicite de `CONTAINSTABLE` et du cleanup. Aucun rejeu métier ne doit être déduit de ce build failed.

