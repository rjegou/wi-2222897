# Handoff Worker 2 — Console 2.0.43 build 4444888

Le vrai candidat est le commit `7d0667c90db1eca8e18e94f8fb4b572f9a9ee8e8`, exécuté par le
build `4444888` au sourceVersion `202f8a6a22784786ed90d417f24626e0381bc07e`.

Contrat API : build `2637/4444765`, commit
`9081ecfe7aa07f5e584073d2af1828d3ac9f7235`, version
`1.1.47-wi2222897-api-candidate`, nupkg SHA-256
`296D7EAA4031138369C39986BE9F38264AF5BAB96AE0DC1D29E2380567BB864F`, DLL SHA-256
`A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.

Défaut démontré : `Download exact API candidate PipelineArtifact` réussit, mais l'étape suivante
échoue avec `Resolve-Path` sur `D:\a\1\s\Cegid.Retail.AutoTest.Api.1.1.47-wi2222897-api-candidate.nupkg`.
Le nupkg est donc téléchargé dans un emplacement différent de celui supposé par le script, ou le
script exécuté ne correspond pas au chemin attendu. Corriger la recherche (récursive et manifeste
du répertoire cible), conserver les deux contrôles de hash, puis faire relire le YAML avant l'unique
relance autorisée.

État réel : build failed; compilation, VSTest, pack et PipelineArtifact Console skipped; aucun
artefact Console n'existe. Snyk et lecture Key Vault ont exécuté; aucun upload Artifactory,
BuildInfo, Promote, tag, TestAutos ou JMeter n'a été observé.

## Mise à jour — build corrigé 4445025

Le correctif de chemin a été intégré sur `dfda5e52e637e423432023d9fb6b870e92104703` puis le
build `4445025` a réussi. Il n'est pas nécessaire de relancer 2641 dans ce lot.

Artifact exact : PipelineArtifact `Nuget`, id `5037277`, package
`Cegid.Retail.AutoTest.Console.2.0.43-wi2222897-console-candidate.nupkg`, SHA-256
`796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`. Le package dépend de
`Cegid.Retail.AutoTest.Api` `1.1.47-wi2222897-api-candidate` et son entrée API embarquée vérifie
`A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.

Chemin local récupérable :
`C:\clones\wi-2222897\.work\console-4445025\x\Nuget\Cegid.Retail.AutoTest.Console.2.0.43-wi2222897-console-candidate.nupkg`.
Staging migration isolé :
`C:\clones\wi-2222897\.work\migration-candidate-4445025\migration-tools\Cegid.Retail.AutoTest.Console.nupkg`.
Le staging source n'a pas été modifié. VSTest n'a trouvé aucun assembly de test; aucun JMeter,
TestAutos, upload partagé, Promote ou feed partagé n'est prouvé. Worker 3 peut consommer le nupkg
avec ces hashes et produire les JMX dans son staging, sans utiliser le package historique 2.0.42.
