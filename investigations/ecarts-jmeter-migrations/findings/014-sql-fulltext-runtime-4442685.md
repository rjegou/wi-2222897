# SQL Full-Text — diagnostic runtime 4442685 et patch local

Date : 2026-09-07 (Europe/Paris).

## Revue round5 — correction locale du patch diagnostic

**FACT** — la revue précédente du YAML au hash `2698D6F4EFF7FBEE88419336AB169C823196156B656FCA3DCD48633CF6EF06B6` était bloquante : le script SQL2025 contenait une accolade fermante supplémentaire et un échec de `docker ps` pouvait produire une absence apparente du conteneur.

**FACT** — correction locale appliquée sans push ni queue : suppression de l’accolade supplémentaire et contrôle de `$LASTEXITCODE` de `docker ps` dans les deux stages. Si l’inspection échoue, la sortie imprime `remaining=UNKNOWN` et émet un avertissement; elle ne conclut jamais à l’absence.

**FACT** — hash courant du YAML corrigé : `6C6FD9EC35AD02DA4B71DB8562888BB479441BCC44BED78D4B169E7DB66E21B3`. Les deux scripts PowerShell complets extraits dynamiquement du YAML passent le parseur avec zéro erreur; le parse YAML trouve les stages SQL2019/SQL2025 et `trigger: none`, `pr: none`, `schedules: []`.

**FACT** — fixtures inertes des deux stages : suppression réussie + inspection vide = absence confirmée; conteneur restant ou suppression échouée = avertissement; `docker ps` échoué = `remaining=UNKNOWN` + avertissement; échec smoke conservé et relancé après le `finally`; échec de collecte suivi du cleanup.

**UNKNOWN** — aucune exécution Docker réelle du patch corrigé; le hash n’est pas publié et aucune queue n’est autorisée dans cette tâche.

## Addendum 2026-09-08 — lecture finale et limite causale

**FACT** — la collecte live [round5](../parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-fulltext-live-4442156-round5/README.md) établit que `4442156`, `4442254` et `4442685` sont tous `completed/failed`. Dans `4442156`, les deux stages SQL échouent et les artefacts sont absents ; dans `4442685`, les deux artefacts sont disponibles.

**FACT** — les diagnostics `4442685` montrent `IsFullTextInstalled=1`, un service SQL `RUNNING`, `CatalogPopulateStatus=1`, `TablePopulateStatus=1` et une ligne `sys.dm_fts_index_population` en `status=5 / Processing normally`, puis l'échec `Full-Text population did not finish: [1]`. Le script d'artefact ne contient ni attente de stabilisation ni appel `CONTAINSTABLE`.

**UNKNOWN** — ces observations prouvent l'absence d'achèvement dans la fenêtre du probe, mais pas la cause racine (FDHOST, crawl, configuration, timing, ressources ou autre), ni l'effet d'une nouvelle image sur les 224 cas historiques Clienteling. Aucun résultat Clienteling/JMeter n'est déduit.

**Suite minimale** — sur une cible/image isolée seulement, instrumenter une attente horodatée et bornée des mêmes propriétés/DMV, l'état de `MSSQLFDLauncher`/FDHOST, un `CONTAINSTABLE` explicite, puis le cleanup. Arrêter si la cible, le commit ou l'image sont ambigus ; ne pas modifier l'image partagée.

## Verdict

**FACT** — le build Azure DevOps `4442685`, définition `14251`, exécute exactement le commit `e3b674b007071259fd74b024f6b4b48baf0a7f5d` sur `sandbox/WI-2222897-sql-fulltext`. SQL2019 et SQL2025 terminent en échec. SQL2019 émet 18 observations exit 0 puis reste à `PopulateStatus=1` pendant 90 secondes ; les logs récupérés au round suivant établissent le même timeout pour SQL2025. `CONTAINSTABLE` n’est atteint dans aucune variante.

**FACT** — `e3b674b` ne change que `fulltext-probe.ps1` et retire le `docker info` exécuté depuis le conteneur. Le parsing et la durée/assertion du probe restent inchangés : propriété Full-Text à `1`, population à `0` sous 90 secondes, puis au moins un hit `CONTAINSTABLE`.

**UNKNOWN** — la première cause parmi démarrage/timing SQL, service `MSSQLFDLauncher`, processus `fdhost`, crawl/word breaker, configuration ou espace disque. `IsFullTextInstalled=1` ne suffit pas à départager ces hypothèses.

**UNKNOWN** — cleanup runtime effectif et contenu des artefacts, les téléchargements étant bloqués par TLS Schannel. Aucun résultat Clienteling ou JMeter n’est déduit.

## Patch local reviewable

Le seul fichier modifié est :

`worktrees/Pipelines_Docker_BaseImages_worker2_round9/validation/WI-2222897/sql-fulltext-hosted-build.yml`

Le patch ne modifie ni Dockerfile ni probe. Dans les deux stages SQL, il :

- imprime une borne `FULLTEXT_DIAGNOSTIC_BEGIN/END` dans la console ;
- collecte sans valeur secrète la propriété `IsFullTextInstalled`, `LoadOSResources`, `VerifySignature`, l’état du catalogue/table, `sys.fulltext_indexes`, `sys.dm_fts_index_population`, `sys.dm_fts_active_catalogs`, `sys.dm_fts_fdhosts`, `sys.dm_fts_outstanding_batches` et `sys.dm_fts_population_ranges` ;
- collecte services/processus FDHOST et SQL, espace disque et uniquement les lignes ciblées Full-Text/crawl/7609 des journaux, tronquées à 400 caractères ;
- capture les erreurs de diagnostic et de logs en avertissement afin de ne pas remplacer l’échec smoke ;
- exécute `docker rm -f`, imprime `FULLTEXT_CLEANUP`, les codes de suppression/inspection et le résultat du filtre `docker ps -a` ; une inspection échouée reste `UNKNOWN` ;
- conserve la publication de PipelineArtifact uniquement ; aucune commande push, JFrog, promotion, tag ou cible partagée n’est ajoutée.

## Validation locale

**HISTORIQUE supersédé** — avant la revue round5, le worktree était détaché sur `e3b674b` et le diff alors observé comptait 89 lignes ajoutées et 22 supprimées. Cette version ne validait pas l’accolade SQL2025 ni l’échec de `docker ps`.

**FACT** — la validation round5 extrait les scripts complets jusqu’à leur dernière ligne; les deux passent le parseur PowerShell avec zéro erreur. Les fixtures de cleanup couvrent absence confirmée, conteneur restant, suppression échouée, `docker ps` échoué et conservation de l’échec smoke; aucune occurrence de push, JFrog, Artifactory, promotion ou tag source n’est ajoutée.

**UNKNOWN** — exécution Docker réelle du patch, car aucune queue ni moteur Docker local n’a été utilisé dans cette tâche.

## Conditions d’une prochaine queue unique

La branche existante `sandbox/WI-2222897-sql-fulltext` et la définition dédiée `14251` sont les seules cibles proposées. Une queue doit rester manuelle, sans trigger/PR/schedule, conserver 90 secondes, ne modifier aucun Dockerfile, ne publier qu’un PipelineArtifact, et vérifier dans la console les deux lignes `FULLTEXT_CLEANUP` avec absence du conteneur. Elle ne doit pas être lancée dans cette tâche.

Le diagnostic Microsoft recommande la gestion de `MSSQLFDLauncher` et les DMV d’activité Full-Text ([documentation Microsoft](https://learn.microsoft.com/en-us/sql/relational-databases/search/manage-and-monitor-full-text-search-for-a-server-instance?view=sql-server-ver17)). La population complète par défaut et les journaux `SQLFT*.LOG` sont documentés dans [Populate Full-Text Indexes](https://learn.microsoft.com/en-us/sql/relational-databases/search/populate-full-text-indexes?view=sql-server-ver15).
