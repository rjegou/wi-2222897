# FrenchTaxesRules API — publication candidate round 2

Date : 2026-09-08, Europe/Paris. Périmètre : dépôt `Y2_Tools_AutoTest_Api`, branche utilisateur
`sandbox/frenchtaxesrules/api-jmeter-fixes`. Aucun feed partagé, tag, PR, promotion ou pipeline
aval n'a été créé.

## Provenance et commit

- Ref avant édition relue dans Azure DevOps :
  `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.
- `git status --short --branch` du clone exact avant édition : branche sandbox suivie par son
  remote, propre.
- Patch API appliqué sans conflit depuis
  `patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch`.
- Commit local puis distant : `9081ecfe7aa07f5e584073d2af1828d3ac9f7235`.
- Auteur : `Ronan JEGOU <rjegou@cegid.com>`.
- Push : fast-forward `220de3d..9081ecf`; lecture `git ls-remote` confirme le même HEAD.
- Diff exact conservé dans `api-candidate.diff`, SHA-256
  `9811EBB174003E879060F4D650D842C5CEB0131653D52FDAFD3758D01EBF6392`.

## Contenu publié

`Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` contient les quatre corrections : date SQL ISO,
littéraux Unicode SQL avec `''`, échappement XQuery/XML et assertion SOAP Fault namespace-aware.

`azure-pipelines.yml` est limité à un build candidat :

- nom `wi2222897-api-candidate-*` ;
- `trigger: none`, `pr: none`, schedules supprimés ;
- version explicite `1.1.47-wi2222897-api-candidate` ;
- `PublishPipelineArtifact` conservé sans condition, artefact `Nuget` ;
- upload Artifactory, BuildInfo, promotion et stage aval supprimés ;
- le seul template transitif est Snyk, relu au commit
  `acf748eb49b901f9e54b69565e371d6d9ca4dc21`; il ne publie aucun package ni ne déclenche TestAutos.

`git diff --check` passe sur le commit publié. Aucun secret n'est présent dans le diff; le PAT est
resté une variable de processus et n'est pas archivé.

## Build et artefact réellement produits

- Contrôle avant push : ref distante `220de3d...`, aucun run actif de la définition 2637 ; push
  uniquement vers la branche utilisateur.
- Run unique de la définition `2637` : build `4444765`, nom
  `wi2222897-api-candidate-20260908.1`, sourceVersion exact `9081ecfe...`, résultat `succeeded`.
- Stage `Build`, job `Build` et job `Snyk Security Scan` terminés avec succès. Les tâches NuGet
  pack et `PublishPipelineArtifact` ont réussi ; l'artifact `Nuget` porte l'identifiant `5036993`
  et la taille distante observée est 60464 octets.
- Le contenu récupéré est conservé dans `artifacts/`. Hashes SHA-256 : nupkg
  `296D7EAA4031138369C39986BE9F38264AF5BAB96AE0DC1D29E2380567BB864F`, DLL
  `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`, nuspec
  `77039A72DFFCDEB2919E05FFDC62313F6F9184582476011234EE37B5995AE5F`, archive de collecte
  `5039A1D0DF576341D6C489914C148FA6CBCB010691C4C4C1DF0A561104C25016`.
- Le `.nuspec` confirme la version candidate `1.1.47-wi2222897-api-candidate`. Les quatre
  corrections ont été invoquées sur la DLL réellement extraite du nupkg ; résultats détaillés dans
  `binary-exercise.txt`, tous `PASS`, y compris `EscapeJdbcDate` sur `2026-04-28`.
- Les journaux et la timeline sont archivés dans `log-23.json`, `log-29.json`, `log-30.json`,
  `logs-index.json` et `timeline.json`.

## Limites

Le build a produit 92 warnings de compilation, dont une référence `System.Windows.Interactivity`
non résolue, sans erreur. Le job VSTest a signalé qu'aucune DLL de test ne correspondait au filtre,
et NuGet a émis `NU5128` sur les groupes de dépendances du nuspec ; ce sont des warnings à traiter
séparément, pas des succès de tests JMeter. Aucun run JMeter ou pipeline aval n'a été lancé ici.
La consommation downstream par Worker 2 reste donc `UNKNOWN` jusqu'à preuve dans son environnement.
