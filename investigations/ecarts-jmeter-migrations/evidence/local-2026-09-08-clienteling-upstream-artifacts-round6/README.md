# Transport Console / Migration / JMeter — round 6

Date : 2026-09-08, Europe/Paris. Cette preuve complète round 5 sans modifier les documents
canoniques ni les clones partagés.

## Contrat API corrigé

**FACT** : le run `4444962` de la définition `2637` est terminé `succeeded`, sur la branche
`refs/heads/sandbox/clienteling/api-jmeter-fixes`, au commit
`4c22cb2850a150161f44080815375527c4daad48`. Il expose le PipelineArtifact `Nuget` `5037204`.
Cette preuve remplace l'affirmation historique limitée au run `4444765`.

**FACT** : `4c22cb` ne modifie que `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`; `SolutionInfo.cs`
reste à `AssemblyVersion("1.1.46")`. La version 1.1.47 du contrat préparé était donc une valeur de
staging/nommage, pas une exigence fonctionnelle démontrée. Il n'est pas autorisé de remplacer en
silence la DLL API embarquée dans le candidat Console.

Relecture distante de l'artefact 5037204 : package `1.1.46`, SHA-256
`B416C52F58D5129C36540C13E9C9BA36CCB064FE5433EE3D21C8094A9E3E5AC4`; DLL embarquée SHA-256
`38E7BA8D507FB73A661DD111224DCFABBF78C22AB2ECE23BD9D2EF67ACCD2F3E`.

## Tentative de transport isolé

Le staging hors dépôt `.work/upstream-transport-round6` a été composé sans publication partagée :

- candidat Console local, package SHA-256 `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` ;
- cache Migration local, package SHA-256 `212D33F7BE8DE8AC5923E82AC7BE0A0CEECBA5A71B631337B729F37CC889BE03` ;
- aucun JMX n'a été trouvé dans les preuves éligibles pour ce staging.

**FACT** : l'upload demandé par `az pipelines runs artifact upload`, vers le run isolé `4444892`
de la définition `14264`, n'a pas atteint Azure DevOps : l'extension CLI échoue localement avant
requête avec `[Errno 13] Permission denied: C:\Users\jegour\.azure-devops\python-sdk\cache\options.json`.
Le PAT n'a pas été affiché ni persisté.

**FACT** : le candidat Console et le cache Migration ne sont présents dans aucun dépôt distant ni
PipelineArtifact connu. Un pipeline agent ne peut pas lire les chemins locaux `C:\Users\...` ou
`C:\clones\...`; les ajouter au dépôt documentaire est interdit. Le run 4444892 étant déjà terminé,
il n'offre pas une étape agent dans laquelle copier ces fichiers.

**CONCLUSION** : aucun transport PipelineArtifact Console/Migration/JMeter n'est acquis dans cette
collecte. Le mécanisme autorisé nécessite soit un agent autorisé exécutant une étape d'upload depuis
un staging contrôlé, soit un dépôt source dédié publiable contenant les fichiers/scripts nécessaires.
Ne pas lancer Cur/Fix avec ces chemins locaux et ne pas déclarer 14264 vert.

## Handoff à WORKER 3 / définition 14264

Le build API `4444962/5037204` peut être consommé après contrôle de version 1.1.46. Les entrées
Console/Migration/JMeter doivent être produites dans un vrai run PipelineArtifact, puis téléchargées
et rehashées indépendamment. Toute solution qui injecte la DLL `38E7…` dans le nupkg Console
`803D…` doit être explicitement identifiée comme une nouvelle composition et non comme le candidat
Console déjà validé.

