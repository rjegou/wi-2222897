---
type: "Evidence"
title: "Clienteling WI-2222897 — contrat 14264 et artefacts amont Round 6"
timestamp: "2026-09-08"
source_system: "Azure DevOps REST Python requests, local PowerShell validation"
freshness: "2026-09-08"
---

# Revalidation et configuration 14264

## Authentification

**FACT** — la méthode WORKER 1 est reproductible : Python `requests.Session()`
avec `auth=('', token)` lu en mémoire retourne HTTP 200 sur l'API Build Azure
DevOps. Le PAT n'est pas écrit dans cette preuve. Les précédents échecs
PowerShell/CLI sont donc des erreurs locales TLS/SSPI ou de profil/cache, pas un
refus distant `VS403660`.

**FACT** — l'upload `az pipelines runs artifact upload` borné vers le run
`4444892`, après déplacement du cache CLI vers `.work`, échoue encore dans
ArtifactTool avec `System.Security.Authentication.AuthenticationException` /
`SEC_E_NO_CREDENTIALS` avant la publication. Aucun artefact n'a été créé par
cette tentative.

## Artefacts API et Console réellement relus

**FACT** — le build API exact est `4444962`, définition `2637`, branche
`sandbox/clienteling/api-jmeter-fixes`, commit
`4c22cb2850a150161f44080815375527c4daad48`, résultat `succeeded`, artefact
PipelineArtifact `Nuget` `5037204`. Relecture du package :

- package `Cegid.Retail.AutoTest.Api.1.1.46.nupkg`, SHA-256
  `B416C52F58D5129C36540C13E9C9BA36CCB064FE5433EE3D21C8094A9E3E5AC4` ;
- DLL API embarquée SHA-256
  `38E7BA8D507FB73A661DD111224DCFABBF78C22AB2ECE23BD9D2EF67ACCD2F3E` ;
- l'artefact réel ne contient pas de `manifest.json` générique.

Le preflight a donc été corrigé pour vérifier directement le nupkg/DLL API par
hash et conserver l'association build/branche/commit fournie par
`DownloadPipelineArtifact`, sans imposer un manifest artificiel absent de
l'artefact réel.

**FACT** — le build Console `4445025` / artefact `5037277` est terminé
`succeeded`, mais produit `Cegid.Retail.AutoTest.Console.2.0.43-wi2222897-console-candidate.nupkg`,
SHA-256 `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`.
Il ne correspond pas au candidat requis `803D...EEE55B`; il est rejeté. Sa
timeline prouve `Artifactory NuGet restore=succeeded`, `NuGet pack=succeeded`,
`Publish artifact ...=succeeded` et `Artifactory Generic Upload=skipped`.
Ce run n'est donc pas une preuve de transport du candidat SOAP local.

## Contrat 14264 publié

**FACT** — la branche dédiée contient maintenant le commit
`0cf1736787def6d4fe2788b73cafdd8777768730`, relu par l'API Git, avec :

- suppression de la dépendance obligatoire à un artefact migration/JMX amont ;
- génération du manifest migration depuis les deux XML Clienteling présents
  dans le checkout, puis publication PipelineArtifact intermédiaire ;
- téléchargement de ce manifest par `GenerateJmx`, qui reste le producteur des
  JMX ;
- téléchargement explicite de l'outil JMeter dans chaque job Cur/Fix ;
- chemins scripts corrigés vers `ci/wi2222897/scripts`, présents dans le dépôt
  exécuté ;
- defaults partagés `2641`/`5224` supprimés, IDs exacts désormais obligatoires.

Le script local `New-Wi2222897MigrationManifest.ps1` a été exécuté avec les
deux XML réels : `Deployment_ResetFTSCustomer.xml` SHA-256
`159E8980A95A75731BDEFB187A41EE2775AA6618DAD8D10B057455242ECFEE41` et
`Mobility_GetClientelingParameters.xml` SHA-256
`F2025EF2F446BAA0F1E2F92E4E8B5F86E032E93A74800FB7292A724F0DF6A1FB`.
Sortie : `PASS`, deux fichiers, commit source `edb02f...`.

## État d'exécution

Le dernier run 14264 est toujours `4444892`, échoué au preflight avec
`Required input is missing: apiBuildId`. Aucun nouveau run n'a été lancé après
la correction, car les préconditions restantes ne sont pas toutes prouvées :

- le candidat Console `803DDBAA...EEE55B` reste uniquement local ;
- aucun PipelineArtifact JMeter exact contenant `jmeter.bat` n'est identifié ;
- aucune attestation de cible Cur/Fix live, hôtes dédiés, image/digest, backup,
  endpoints et cleanup n'est disponible.

Le build `4444962/5037204` peut être passé comme `apiBuildId`, mais ne rend pas
le candidat Console compatible et ne constitue pas une preuve de JMX ou de
campagne.

## Verdict

**BLOCKED — préconditions externes restantes, sans refus distant de droits.**
La configuration 14264 est plus exécutable et ne demande plus un artefact JMX
que `GenerateJmx` doit produire. Il manque toutefois un transport PipelineArtifact
isolé du nupkg Console et une attestation de cible réelle. Relancer maintenant
échouerait encore sur une entrée connue manquante ; aucun lancement de 2065 ou
5224 n'a été effectué.
