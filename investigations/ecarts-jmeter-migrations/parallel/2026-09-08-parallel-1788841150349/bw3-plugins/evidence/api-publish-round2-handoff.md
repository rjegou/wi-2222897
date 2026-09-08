# Handoff vers Worker 3 — API publiée, résolution du NOT_FOUND

Collecte expurgée du 2026-09-08. Aucun secret, PAT ou contenu de variable n'est transmis.

## Requête à appliquer

Pour résoudre `NOT_FOUND`, ne pas rechercher une version flottante ni un ancien cache. Rechercher
le commit exact suivant dans Azure DevOps :

- dépôt : `Y2_Tools_AutoTest_Api` (id `60951ba6-fb32-4a61-9b7d-9df7b31d575c`) ;
- branche : `sandbox/frenchtaxesrules/api-jmeter-fixes` ;
- commit attendu : `9081ecfe7aa07f5e584073d2af1828d3ac9f7235` ;
- version candidate attendue : `1.1.47-wi2222897-api-candidate` ;
- pipeline producteur : définition `2637` ; artefact attendu : PipelineArtifact `Nuget`.

Consommer ensuite uniquement le nupkg et la DLL dont le build produit les hashes, en conservant le
nom exact de version; ne pas utiliser `latest`, Artifactory ou un package stable partagé.

## Résultat distant expurgé

- La ref existait avant push à `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.
- Push fast-forward accepté vers `9081ecfe7aa07f5e584073d2af1828d3ac9f7235`.
- `git ls-remote` relu après push : même commit.
- Aucun run 2637 actif n'était visible lors du contrôle pré-push.

## Build et contenu transmis

- Build producteur unique : `4444765`, nom `wi2222897-api-candidate-20260908.1`, résultat
  `succeeded`, sourceVersion `9081ecfe7aa07f5e584073d2af1828d3ac9f7235`.
- PipelineArtifact `Nuget`, id `5036993`, contenu copié dans
  `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-api-publish-round2/artifacts/`.
- nupkg SHA-256 :
  `296D7EAA4031138369C39986BE9F38264AF5BAB96AE0DC1D29E2380567BB864F`.
- DLL SHA-256 :
  `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.
- nuspec SHA-256 :
  `77039A72DFFCDEB2919E05FFDC62313F6F9184582476011234EE37B5995AE5F`.
- Exercice sur la DLL construite : `EscapeJdbcDate`, `FixSqlUnicodeValue`,
  `RemoveSpecialCharsForXQuery` et `CleanXpath` sont tous `PASS`; la date vérifiée est
  `2026-04-28`.

Le build a des warnings connus (compilation, absence de sources VSTest correspondant au filtre,
`NU5128`), mais aucun échec de stage. Aucun feed partagé, run JMeter ou pipeline aval n'a été lancé.
Le consommateur doit utiliser ces fichiers et la version exacte, sans `latest`.
