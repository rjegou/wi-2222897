# Revue du vrai candidat Console 2.0.43 — build 4444888

Date : 2026-09-08, Europe/Paris. Source : checkout local conservé sous
`C:\clones\wi-2222897\.work\console-source` et lectures REST Azure DevOps effectuées avec un
PAT en mémoire de processus uniquement. Aucun nouveau build, push, publication ou run aval n'a été
lancé dans cette revue.

## Provenance source et diff réel

FACT : le checkout `console-source` est sur la branche
`sandbox/frenchtaxesrules/console-api-artifact`, propre, et contient le commit
`7d0667c90db1eca8e18e94f8fb4b572f9a9ee8e8` (« prepare isolated Console candidate »). Le build
`4444888` a exécuté la révision `202f8a6a22784786ed90d417f24626e0381bc07e`, qui porte le même
changement logique (4 fichiers modifiés).

Le diff réel :

- `packages.config` remplace API `1.1.46` par `1.1.47-wi2222897-api-candidate` ;
- le `.csproj` pointe vers `packages\Cegid.Retail.AutoTest.Api.1.1.47-wi2222897-api-candidate` ;
- `SolutionInfo.cs` passe Console en `2.0.43` ;
- `azure-pipelines.yml` épingle API build `4444765`, nupkg `296D7EAA...` et DLL `A7D3BB84...`.

## YAML exact et effets attendus

FACT : le YAML au commit exécuté contient `trigger: none` et `pr: none`, télécharge le
PipelineArtifact `Nuget` de la définition API `2637`/build `$(ApiBuildId)=4444765`, vérifie le hash
du nupkg puis le hash DLL attendu `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.
Il restaure ensuite le package Console avec `ArtifactoryNuGet`, lance Snyk, build/test, pack et
`PublishPipelineArtifact`. Upload Generic Artifactory, BuildInfo et stage Promote ont `condition:
'false'`; le signing reste limité à master/releases. Le template Snyk est le commit
`acf748eb49b901f9e54b69565e371d6d9ca4dc21`.

FACT : ces garde-fous empêchent la publication/promotion feed dans la timeline observée. Ils ne
suppriment pas les lectures transitives : Snyk s'est exécuté et la tâche Azure Key Vault
`cegid-codesigning` a lu ses secrets de service au démarrage; Artifactory restore a été évalué
mais skipped après l'échec précédent.

## Résultat réel 4444888

FACT : build `4444888`, définition `2641`, branche
`sandbox/frenchtaxesrules/console-api-artifact`, sourceVersion
`202f8a6a22784786ed90d417f24626e0381bc07e`, build number
`wi2222897-console-20260908.1`, état `completed/failed`, terminé à
`2026-09-08T10:04:45.124578Z`. L'API PipelineArtifact a été téléchargée avec succès (log 17).

FACT : l'étape `Install exact API candidate from PipelineArtifact` échoue (log 21) avant la
compilation. Le log montre une recherche de
`D:\a\1\s\Cegid.Retail.AutoTest.Api.1.1.47-wi2222897-api-candidate.nupkg` qui n'existe pas;
la tâche échoue avec PowerShell code 1. La compilation, VSTest, NuGet pack, manifeste de
provenance et PublishPipelineArtifact sont `skipped`; la liste REST des artifacts du build est
vide. Aucun nupkg/DLL Console 2.0.43 n'est donc disponible.

FACT : les stages Build et Promote sont respectivement `failed` et `skipped`. Aucun upload
Artifactory, BuildInfo, promotion, tag, TestAutos ou run JMeter n'est prouvé. Snyk a réussi, mais
ce succès ne vaut ni build Console ni test métier.

## Conclusion et limites

CONCLUSION : le diff Console 2.0.43 résout bien la dépendance déclarative vers la version API
candidate et fixe les hashes contractuels; le build réel n'a pas franchi l'installation de
l'artefact API. Le défaut à corriger est borné à la résolution du chemin produit par
`DownloadPipelineArtifact` (le YAML doit rechercher récursivement/au chemin effectivement fourni,
avec contrôle de présence avant `Get-FileHash`). Ne pas relancer un build identique avant correction.

UNKNOWN : compilation Console avec API A7D3…, hash/présence du nupkg Console, résolution de toutes
les dépendances, package migration, JMX effectivement consommés et résultat FrenchTaxesRules.

## Résultat frais : build corrigé 4445025

FACT : après correction bornée du chemin, le commit distant `dfda5e52e637e423432023d9fb6b870e92104703`
sur `sandbox/frenchtaxesrules/console-api-artifact` a produit le build `4445025`,
`wi2222897-console-20260908.7`, `completed/succeeded`. Aucun autre build n'a été lancé dans cette
revue, et aucun run concurrent n'était actif lors du contrôle.

FACT : l'artifact PipelineArtifact `Nuget` id `5037277` contient
`Cegid.Retail.AutoTest.Console.2.0.43-wi2222897-console-candidate.nupkg`, 299201 octets,
SHA-256 `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`. Le nuspec porte la
version `2.0.43-wi2222897-console-candidate` et dépend de
`Cegid.Retail.AutoTest.Api` `1.1.47-wi2222897-api-candidate`.

FACT : l'entrée embarquée `tools/Cegid.Retail.AutoTest.Api.dll` a le SHA-256 attendu
`A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`; l'exécutable Console a le
SHA-256 `AB4BBB596409B3A60107905E82577E9BC42C55467A8E602B7194DD2D8CE9B2AF`. La provenance
embarque aussi API build `4444765`, nupkg API `296D7EAA...864F` et DLL API `A7D3...9021E`.

FACT : les étapes téléchargement/installation API, restauration, VSBuild, pack et
PublishPipelineArtifact ont réussi. VSBuild a émis trois avertissements connus; VSTest a réussi
la tâche mais n'a trouvé aucun assembly de test correspondant, ce qui ne constitue pas une preuve
de test VSTest ou métier. Upload Generic Artifactory, BuildInfo, Promote, signing, TestAutos et
JMeter sont restés absents ou désactivés.

FACT : le package a été copié dans un staging de migration isolé, sans modifier la source
`.work/migration-current-source` :
`C:\clones\wi-2222897\.work\migration-candidate-4445025\migration-tools\Cegid.Retail.AutoTest.Console.nupkg`.
Ce fichier a le même hash et le même nuspec. La génération des JMX n'est pas déclarée ici : le
staging ne contient pas les 32 JMX attendus par `Write-Wi2222897JmxManifest.ps1`, et aucun
rejeu FrenchTaxesRules n'a été lancé.

Conclusion : le défaut de chemin de 4444888 est corrigé et la chaîne API embarquée est prouvée
dans le nupkg Console. La consommation par l'outil de migration, la génération JMX complète et
le résultat JMeter/métier restent UNKNOWN.
