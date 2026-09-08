# Test discriminant minimal — SQL Full-Text

Statut : préparation documentaire uniquement, aucune queue ni modification distante.

## Question

Le `PopulateStatus=1` observé dans les probes `4442685` est-il seulement transitoire dans la
fenêtre de 90 secondes, ou persiste-t-il avec une cause runtime identifiable ? Ce test ne doit
pas mesurer Clienteling et ne permet pas, à lui seul, de reclasser les 224 cas historiques.

## Contrat borné

1. Utiliser une image et un commit explicitement isolés, avec les hashes relevés avant démarrage.
2. Construire et démarrer le conteneur SQL sans modifier Dockerfile ou image partagée.
3. Après création de `FullTextSmoke`, relever à `t=0`, puis toutes les 5 secondes pendant 120 s :
   `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')`, `FULLTEXTCATALOGPROPERTY(...,'PopulateStatus')`,
   `OBJECTPROPERTYEX(...,'TableFullTextPopulateStatus')`, `sys.dm_fts_index_population`,
   `sys.dm_fts_active_catalogs`, `sys.dm_fts_fdhosts`, l'état du service `MSSQLFDLauncher` et
   les processus `fdhost`.
4. Après le passage à l'état terminé, exécuter une requête `CONTAINSTABLE` connue et enregistrer
   le nombre de lignes, le code SQL et l'horodatage. Une absence de hit est un échec du probe,
   pas une preuve de cause racine.
5. Capturer les logs ciblés SQL/Full-Text et les timestamps sans secret, puis exécuter le cleanup.
   L'absence du conteneur après suppression doit être prouvée ; sinon le résultat est `UNKNOWN`.

## Interprétation

- `status=0` + hit `CONTAINSTABLE` + cleanup confirmé : précondition Full-Text de l'image démontrée ;
  une campagne Clienteling distincte reste nécessaire.
- timeout avec `status=5`, FDHOST/DMV/service stables : blocage runtime reproduit, cause précise encore
  `UNKNOWN` ; ne pas modifier le consommateur JMeter au hasard.
- exception SQL, service absent ou cleanup non prouvé : diagnostic incomplet, conserver `UNKNOWN`.

## Assertions issues des artefacts existants

`4442685` établit `IsFullTextInstalled=1`, SQL `RUNNING`, `CatalogPopulateStatus=1`,
`TablePopulateStatus=1`, et `sys.dm_fts_index_population.status=5 / Processing normally`,
`range_count=1`, `completed_range_count=1`, `outstanding_batch_count=0`. Le script artefact
ne contient ni boucle d'attente ni `CONTAINSTABLE`; ces absences sont précisément les écarts
à combler par le test minimal.

## Script prêt pour Worker 2

Le script exécutable est [Invoke-FullTextBoundedDiagnostic.ps1](Invoke-FullTextBoundedDiagnostic.ps1).
Il ne prend jamais le mot de passe en argument : le processus appelant doit fournir
`MSSQL_SA_PASSWORD` dans son environnement ; le script le transmet au conteneur par variable
d'environnement et retire sa variable temporaire `SQLCMDPASSWORD` en `finally`. Il crée un nom et
un label uniques `wi-2222897.fulltext-diagnostic`, et ne supprime qu'un conteneur dont le label
correspond exactement à cette exécution.

Contrat d'appel :

```powershell
$env:MSSQL_SA_PASSWORD = '<injecté par le processus appelant, jamais journalisé>'
& .\Invoke-FullTextBoundedDiagnostic.ps1 `
  -Image '<image isolée hashée>' `
  -SetupQuery '<SQL exact de création/peuplement FullTextSmoke>' `
  -ContainstableQuery "SELECT COUNT_BIG(*) FROM CONTAINSTABLE(dbo.Documents, *, 'probe')" `
  -OutputPath '<dossier de preuve dédié>\fulltext-diagnostic.jsonl'
Remove-Item Env:MSSQL_SA_PASSWORD -ErrorAction SilentlyContinue
```

`SetupQuery` et `ContainstableQuery` doivent être fournis par Worker 2 selon le schéma exact de
l'image ; le script n'invente ni table, ni colonne, ni fixture. Le parse PowerShell local est
validé avec zéro erreur (193 lignes, SHA-256 `CEF3F0B5C324C258E08D87F06777C622E9456E4EF728A653BB9A374ED32C2A20`).
