# Round 18 — analyse hors ligne Full-Text 4442222

Collecte dédiée, continuation de round16. Source locale du probe au commit `afe602c397ab7a8c18a731be2652435dac81c806`; diagnostics SQL2025 de l'artefact `sql-fulltext-2025-evidence` du build `4442222`; analyse REST/artefact read-only. Aucun secret, payload ou script contenant des paramètres sensibles n'est conservé.

## Chronologie reconstituée — SQL2025

FACT : image `sql-fulltext-smoke:2025` taguée à `17:22:55.5607717Z`; service `MSSQL$DOCKERSQLEXPR` et processus `sqlservr` présents; service SQL prêt avant la création de la base.

FACT : le probe vérifie `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')`, puis exécute en une commande `sqlcmd` la suppression éventuelle de `FullTextSmoke`, sa création, la création de `dbo.Documents`, l'insertion de 2 lignes, la création du catalogue et la création de l'index (`fulltext-probe.ps1:14-20`). Chaque appel est une commande séparée et contrôlée par `sqlcmd -b`; aucune instruction `BEGIN TRANSACTION`/`COMMIT` n'est présente.

FACT : la création de l'index déclenche la population; le probe ne l'appelle pas de nouveau. Il attend 5 secondes entre les lectures de `FULLTEXTCATALOGPROPERTY(...,'PopulateStatus')`, pendant au plus 90 secondes (`fulltext-probe.ps1:21-28`). Il n'atteint `CONTAINSTABLE` qu'après un statut catalogue égal à 0 (`:29-32`).

FACT : diagnostic : daemon Full-Text V2 démarré; `sys.fulltext_index_fragments` contient une ligne, `status=0`, `row_count=1`, `data_size=0`; `sys.dm_fts_index_population` indique `population_type_description=FULL`, `status=5` (`Processing normally`), `completed_range_count=1`, `outstanding_batch_count=0`, `worker_count=0`, début `17:23:13.227`.

FACT : ERRORLOG ne montre pas d'erreur Full-Text; il montre des démarrages du daemon et de la base, puis des redémarrages de `FullTextSmoke` pendant l'attente. Le diagnostic ne contient aucun résultat `CONTAINSTABLE`.

## Interprétation contrôlée

- FACT : aucune transaction ouverte ni relance de population n'est démontrée dans le probe.
- FACT : le statut `5` de `sys.dm_fts_index_population` est `Processing normally`; il ne doit pas être confondu avec le `PopulateStatus` du catalogue. La documentation Microsoft indique que `PopulateStatus` du catalogue vaut `0=Idle` et `1=Full population in progress`, et recommande généralement la propriété table correspondante.
- INFERENCE : attendre `FULLTEXTCATALOGPROPERTY(...,'PopulateStatus')=0` est cohérent avec le contrat historique, mais l'absence de progression vers l'état idle en 90 secondes n'établit pas un blocage moteur. Le probe ne collecte pas de progression intermédiaire, donc la cause des redémarrages et du statut non terminal reste indéterminée.
- UNKNOWN : valeur exploitable de `TableFullTextPopulateStatus` dans ce run (seul l'en-tête a été projeté); cause des redémarrages; résultat fonctionnel `CONTAINSTABLE`.

## SQL2019 et comparabilité

FACT : SQL2019 de 4442222 échoue avant le conteneur avec l'absence du daemon Docker (`npipe:////./pipe/docker_engine`). L'artefact est vide malgré publisher succeeded. INFERENCE : cet incident agent ne prouve pas une incompatibilité SQL2019 globale; les runs hosted antérieurs avaient atteint le runtime SQL2019.

## Décision

Aucune correction d'image ou de probe n'est démontrée comme justifiée par ces seules observations. Le défaut prouvé est l'absence d'observations de progression dans la boucle d'attente. Une prochaine évolution minimale, si nécessaire, serait d'ajouter une projection bornée du statut catalogue + table + DMV à chaque intervalle et un préflight Docker explicite avant le build; elle ne doit pas masquer l'échec ni augmenter arbitrairement le délai. `CONTAINSTABLE` reste une postcondition non satisfaite.

## Références Microsoft (consultées le 2026-09-07)

- [FULLTEXTCATALOGPROPERTY (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/functions/fulltextcatalogproperty-transact-sql?view=sql-server-ver17) : valeurs de `PopulateStatus` et recommandation de vérifier la propriété table.
- [sys.dm_fts_index_population (Transact-SQL)](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-fts-index-population-transact-sql?view=sql-server-ver17) : `status=5` signifie `Processing normally`.
- [OBJECTPROPERTYEX (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/functions/objectpropertyex-transact-sql?view=sql-server-ver17) : définition de `TableFullTextPopulateStatus`.
