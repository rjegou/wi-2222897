---
type: "Evidence"
title: "Clienteling WI-2222897 — contrôle des entrées du pipeline isolé Round 5"
description: "Revalidation du run 14264, des artefacts candidats et des dépendances inter-stages; aucune relance faute d'entrées exactes et d'accès AzDO live."
timestamp: "2026-09-08"
source_system: "local evidence plus attempted Azure DevOps readback"
freshness: "2026-09-08"
---

# Pipeline 14264 — verdict de relance

## Provenance et sécurité

Le pipeline concerné est `WI-2222897 Clienteling Isolated Replay`, définition
`14264`, branche `sandbox/clienteling/wi2222897-isolated-replay`, configuration
`edb02f3466f218a57f64856aaba2a7f47908830b`. La preuve Round 4 établit que les
triggers sont désactivés (`trigger: none`, `pr: none`, `schedules: []`) et que
la configuration ne contient pas de publication NuGet/JFrog, promotion, tag,
import ACR ou trigger aval. Aucun YAML, définition, artefact partagé, branche ou
run n'a été modifié dans cette collecte.

Le PAT n'est pas copié dans la preuve. Les tentatives d'accès live REST et CLI
ont été faites en mémoire puis nettoyées; REST a répondu une erreur
d'authentification/TLS et la CLI a rencontré le profil Azure global inaccessible.

## FACT — run 4444892

Le run manuel `4444892`, source commit
`edb02f3466f218a57f64856aaba2a7f47908830b`, a échoué le 2026-09-08 au job
`VerifyInputs` avec :

```text
Required input is missing: apiBuildId
PowerShell exited with code '1'.
```

Il n'a donc pas exécuté Build Clienteling, GenerateJmx, JMeter Cur ou JMeter
Fix. Aucun résultat métier ou artefact de ces stages ne doit être déduit de cet
échec.

## FACT — build API disponible mais inutilisable

Le build API candidat documenté `4444765` a réussi et a produit un artefact
PipelineArtifact `Nuget`, mais son `sourceVersion` est
`9081ecfe7aa07f5e584073d2af1828d3ac9f7235`, avec version
`1.1.47-wi2222897-api-candidate`. Le contrat du pipeline Clienteling exige le
commit API `4c22cb2850a150161f44080815375527c4daad48`. Ce build ne peut donc pas
être passé comme `apiBuildId` : ce serait une violation directe du preflight.

Le commit `4c22cb...` est une ref API distante précédemment relue, mais aucun
build exact de cette ref n'est présent dans les preuves disponibles. L'ID
`4444765` est explicitement rejeté, pas réutilisé par approximation.

## FACT — candidat Console et autres entrées manquantes

Le candidat Console local vérifié est version
`2.0.42-soapnamespace.20260907`, package SHA-256
`803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`, API DLL
embarquée `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`.
Il est local, pas un artefact `Nuget` d'un `consoleBuildId` prouvé.

Les entrées suivantes restent absentes ou non prouvées :

- `apiBuildId` produisant réellement le commit `4c22cb...` ;
- `consoleBuildId` dont l'artefact contient le package `803D...EEE55B` ;
- `migrationBuildId` et `migrationDefinitionId` fournissant un
  `manifest.json` WI-2222897 avec chaque `jmxPath`, `sourceXml` et les XML
  présents ;
- `jmeterArtifactBuildId` fournissant effectivement `jmeter.bat` sans
  dépendre d'une publication JFrog/ACR partagée ;
- `target-attestation.json` avec hôtes dédiés et `cleanupScope` isolé pour
  chaque variante Cur/Fix.

## FACT — dépendance entre stages

La configuration attendue par le run ne doit pas traiter le JMX généré comme
une entrée amont : `GenerateJmx` produit l'artefact JMX à partir du nupkg
Console, du manifest de migration et des XML sources, puis les jobs Cur/Fix
consomment cet artefact de la génération courante. L'entrée migration reste le
manifest/XML source; l'artefact JMeter est l'outil contenant `jmeter.bat`.

La présence d'un artefact nommé `wi2222897-jmx` dans une définition JMeter
partagée ne constitue pas une preuve de contenu ni d'isolation. La définition
5224 documentée contient des publications JFrog/ACR et des stages aval; elle ne
doit pas être relancée comme substitut isolé.

## Verdict et suite autorisée

**BLOCKED — relance non autorisée techniquement à ce stade.** Le seul échec
exploitable est l'entrée manquante `apiBuildId`; l'ajout de `4444765` serait
incorrect car le commit ne correspond pas. Il faut d'abord produire ou
identifier le build exact du commit `4c22cb...`, puis prouver les quatre
artefacts/attestations restants. Après rétablissement d'un accès AzDO live et
vérification de ces IDs, une unique relance de `14264` pourra être suivie
jusqu'au premier échec exploitable; `2065` et `5224` ne doivent pas être
utilisées.
