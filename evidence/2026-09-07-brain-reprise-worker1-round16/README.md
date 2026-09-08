# Round 16 — Full-Text build 4442222

Collecte dédiée le 2026-09-07, suite de `evidence/2026-09-07-brain-reprise-worker1-round15/`. Azure DevOps REST read-only pour le suivi et les logs; artefacts pipeline téléchargés en mémoire puis projetés sans payload, secret ni configuration sensible conservés. Aucun nouveau run après 4442222.

## Provenance et intégrité

- Définition `14251`, build `4442222`, build number `WI-2222897-SQLFullText-HostedBuild-20260907.5`.
- Branche `refs/heads/sandbox/WI-2222897-sql-fulltext`, commit `afe602c397ab7a8c18a731be2652435dac81c806`.
- Queue `2026-09-07T17:10:49Z`; démarrage `17:10:54.5510009Z`; fin `17:25:08.8765199Z`; résultat terminal `failed`.
- Publisher SQL2019 : log 10 `succeeded`, mais 0 fichier traité et artefact de taille 0.
- Publisher SQL2025 : log 15 `succeeded`, 2 fichiers traités; artefact annoncé taille 83312 octets. Projection artefact : noms uniquement `sql-fulltext-2025-runtime-diagnostic.log` et `.ps1`; le script n'est pas conservé.

## Résultats par variante

### SQL2019 — FACT

Le build Docker échoue avant création du conteneur : `failed to connect to the docker API ... npipe:////./pipe/docker_engine ... The system cannot find the file specified`, puis `SQL 2019 Docker build failed` à `17:11:11.1542286Z`. Le publisher `always()` s'exécute mais traite 0 fichier. Aucun service/processus/DMV/ERRORLOG runtime SQL2019 n'est donc disponible; `CONTAINSTABLE` n'est pas exécuté.

### SQL2025 — FACT

La compilation et le tag de l'image réussissent (`sql-fulltext-smoke:2025`). Le service `MSSQL$DOCKERSQLEXPR` est observé `Running`; le processus `sqlservr` est présent. Le contexte `FullTextSmoke` est atteint. Le probe échoue à `17:24:48.5494613Z` avec `Full-Text population did not finish: [1]`; la tâche smoke échoue ensuite à `17:24:54.9787175Z`.

Le diagnostic publié contient les observations suivantes, projetées sans données métier :

- `FULLTEXTSERVICEPROPERTY` et les propriétés catalog/table ont produit leurs en-têtes, sans valeur non vide visible dans la projection.
- `sys.fulltext_index_fragments` retourne une ligne avec `status` 0, `row_count` 1 et `data_size` 0.
- `sys.dm_fts_index_population` retourne une ligne pour la table/catalogue, `population_type_description` `FULL`, `status` 5 (`Processing normally`), `completed_range_count` 1, `outstanding_batch_count` 0, `worker_count` 0 et heure de début `2026-09-07 17:23:13.227`.
- ERRORLOG : service/processus démarrent; le filtre Full-Text daemon V2 démarre avec succès. Aucun message d'erreur Full-Text discriminant n'est présent dans la projection. Le log montre plusieurs redémarrages de `FullTextSmoke` pendant l'attente, mais ne prouve pas à lui seul la cause de ces redémarrages.

Le diagnostic ne contient pas de résultat `CONTAINSTABLE`, car le probe lève avant cette assertion.

## Verdict FACT / INFERENCE / UNKNOWN

- FACT : `condition: always()` a permis l'exécution des publishers après échec; SQL2025 a effectivement produit et publié 2 fichiers.
- FACT : SQL2019 est bloqué par le daemon Docker indisponible sur l'agent, avant le runtime SQL.
- FACT : SQL2025 a un service SQL en fonctionnement, un processus `sqlservr`, un daemon Full-Text V2 démarré et une DMV indiquant `Processing normally`, mais le probe n'obtient pas l'état terminal attendu dans son délai.
- INFERENCE : le défaut de collecte initial est corrigé; le prochain obstacle est désormais la progression/attente de la population SQL2025, pas la publication.
- UNKNOWN : pourquoi la population ne passe pas à l'état attendu; les redémarrages observés sont un signal à corréler avec le probe/contenerisation, pas une cause démontrée.
- UNKNOWN : SQL2019 reste non comparable au runtime SQL2025 sur ce run, car Docker est indisponible avant création du conteneur.

## Limite et prochaine action

Ne pas modifier l'image ni augmenter le timeout sur ce seul signal. Examiner le script du probe et la séquence d'attente pour expliquer le statut DMV 5 et les redémarrages observés; ensuite seulement un changement minimal et un rejeu ciblé seraient justifiés. La postcondition `CONTAINSTABLE` n'est pas satisfaite.
