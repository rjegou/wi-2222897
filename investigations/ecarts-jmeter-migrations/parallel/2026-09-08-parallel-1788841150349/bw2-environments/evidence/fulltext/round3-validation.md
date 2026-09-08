# Round 3 — validation du candidat instrumenté

Date : 2026-09-08 (Europe/Paris).

## Candidate state

- Le candidat round 2 était principalement un garde-fou d'attestation. Il contient désormais `fulltext-diagnostic.ps1` dans `worktrees/fulltext/` et l'étape SQL2019 le copie/exécute avant le probe.
- `fulltext-diagnostic.ps1` couvre services `MSSQLFDLauncher`/SQL, processus `fdhost`/`fdlauncher`/`sqlservr`, `sc.exe query`, espace disque, propriétés Full-Text, catalogue/table, index/crawl, `sys.dm_fts_index_population`, catalogues actifs, FD hosts, batches, ranges, wordbreakers/filters/protocol handlers et extraits ciblés SQLFT/ERRORLOG.
- Le diagnostic utilise `sqlcmd -E` pour ne placer aucun mot de passe dans les arguments du sous-processus. Il n'a pas été exécuté; l'identité Windows effective dans l'image reste à vérifier avant une queue.
- Le stage SQL2025 reste volontairement une binding gate fail-closed jusqu'à attestation producteur; aucune SQL2025 n'est donc revendiquée.

## Tests réellement exécutés

- Parse PowerShell `fulltext-diagnostic.ps1` : `PASS`.
- Parse YAML `fulltext-runner-candidate.yml` avec PyYAML : `PASS`, `trigger=none`, `pr=none`, `schedules=[]`, stages `SQL2019,SQL2025`.
- Scan statique du diagnostic : mots-clés FDLauncher/fdhost, DMVs, wordbreaker, SQLFT/ERRORLOG et espace présents.
- Scan statique des nouveaux scripts : aucune occurrence de `-P`, `sa_password` ou argument de secret.
- Aucun Docker, SQL, IIS, queue, branche, définition ou publication exécuté/créé.

## Empreintes

| Fichier | SHA-256 |
|---|---|
| `worktrees/fulltext/fulltext-diagnostic.ps1` | `3FF80C104F152FF9DB3E4545D9F76D827334DACCEB3DDE51C00BD64866B9F947` |
| `worktrees/fulltext/fulltext-runner-candidate.yml` | `B222E2C60AC78DF7ED0ABF2F02E610BD4B0DEBE3288508D3AA637C336D16D434` |
| `worktrees/fulltext/fulltext-attestation-gate.ps1` | `5CA9A5F1753A62F9B0880ABA1C79C3D851495D51F70B829F6E6E1D188A5A5AC7` |

## Digest SQL → y2-jmeter

Le Dockerfile Full-Text est construit avec un tag de base (`REPO` + `BASETAG`), puis le workflow Y2-JMeter relaie un tag `baseImageTag` et retague l'image Y2-JMeter. La preuve locale ne relie pas un digest de build SQL à un digest consommé par Y2-JMeter. Le candidat doit donc capturer l'ID/digest de l'image locale après build, conserver ce manifeste dans le PipelineArtifact, puis comparer la référence de base résolue au job Y2-JMeter; aucune publication de registry n'est nécessaire pour établir ce contrat, mais une preuve de provenance de build est indispensable.
