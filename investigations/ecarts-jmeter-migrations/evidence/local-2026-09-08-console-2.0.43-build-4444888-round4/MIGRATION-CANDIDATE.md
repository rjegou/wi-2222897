# Candidat migration Console 2.0.43

Date de collecte : 2026-09-08 Europe/Paris. Source : artifact Azure DevOps 4445025 / PipelineArtifact
5037277, puis copie vers un staging distinct. Aucun secret n'est inclus.

FACT : le fichier de staging est
`C:\clones\wi-2222897\.work\migration-candidate-4445025\migration-tools\Cegid.Retail.AutoTest.Console.nupkg`.
SHA-256 : `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`.
Version nuspec : `2.0.43-wi2222897-console-candidate`. Dépendance API :
`1.1.47-wi2222897-api-candidate`. DLL API embarquée :
`A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.

FACT : la source `C:\clones\wi-2222897\.work\migration-current-source` n'a pas été modifiée.
Le script `checkPackage.ps1` attend un `packages.config` de migration qui n'est pas présent dans
ce snapshot; son exécution n'est donc pas déclarée comme installation complète.

UNKNOWN : génération des JMX depuis la campagne FrenchTaxesRules, manifeste final et exécution
JMeter. `Write-Wi2222897JmxManifest.ps1` exige exactement 32 JMX et aucun lot de 32 JMX issu de ce
package n'a été produit dans ce lot. Ce fichier est un handoff d'artefact, pas une preuve de test.
