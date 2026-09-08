---
type: "Evidence"
title: "Clienteling WI-2222897 — contrat 14264 révisé Round 7"
timestamp: "2026-09-08"
source_system: "Azure DevOps REST Python requests, Git REST push, local validation"
freshness: "2026-09-08"
---

# Corrections finales du contrat 14264

## FACT — commit distant

La branche `sandbox/clienteling/wi2222897-isolated-replay` contient le commit
`b790767c1cecb90d6913c8726aea532c29ea4582`. Le changement reste limité aux
fichiers de configuration/scripts `ci/wi2222897/` et conserve les garde-fous
`trigger: none`, `pr: none`, `schedules: []`, PipelineArtifact-only et aucune
publication/promotion/tag/trigger aval.

La relecture Git REST confirme les corrections suivantes :

- plus de `migrationBuildId`, `migrationDefinitionId` ou artefact JMX amont ;
- génération du manifest migration depuis les deux XML du checkout, puis
  publication et consommation par `GenerateJmx` ;
- plus de defaults de définition partagée 2641/5224 ;
- téléchargement du runtime Apache JMeter 5.6.3 dans chaque job Cur/Fix avec
  vérification SHA-512 fixe
  `387FADCA903EE0AA30E3F2115FDFEDB3898B102E6B9FE7CC3942703094BD2E65B235DF2B0C6D0D3248E74C9A7950A36E42625FD74425368342C12E40B016307` ;
- preflight vérifiant directement les packages/DLL API et Console, car le
  PipelineArtifact API réel `5037204` ne contient pas de manifest générique.

Le YAML local correspondant se parse avec PyYAML : stages `Preflight`, `Build`,
`GenerateJmx`, `JMeter`; 15 paramètres. `git diff --check` passe.

## FACT — préparation locale

`New-Wi2222897MigrationManifest.ps1` a été exécuté sur le checkout Clienteling
avec les deux XML ciblés et retourne `PASS`, deux fichiers et le commit source
`edb02f3466f218a57f64856aaba2a7f47908830b`. Hashes :

- `Deployment_ResetFTSCustomer.xml` :
  `159E8980A95A75731BDEFB187A41EE2775AA6618DAD8D10B057455242ECFEE41` ;
- `Mobility_GetClientelingParameters.xml` :
  `F2025EF2F446BAA0F1E2F92E4E8B5F86E032E93A74800FB7292A724F0DF6A1FB`.

## FACT — limites restantes

Le build API exact `4444962`, artefact `5037204`, est prouvé et peut alimenter
`apiBuildId`. Le build Console `4445025`/artefact `5037277` est rejeté : son
package `2.0.43-wi2222897-console-candidate` a le SHA-256
`796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`, différent
du candidat SOAP requis `803DDBAA...EEE55B`. Il ne faut pas réutiliser ce build.

Le candidat Console `803D...EEE55B` reste local. La tentative de le publier dans
le run terminé `4444892` avec ArtifactTool, en cache AzDO temporaire, échoue
localement avant requête avec `SEC_E_NO_CREDENTIALS`; la lecture REST Python
fonctionne, donc ce n'est pas un refus distant de droit. Aucun artefact n'a été
créé par cette tentative.

L'attestation de cible Cur/Fix (hôtes dédiés, image/digest, backup, réseau et
cleanup) n'existe toujours pas dans les preuves live. Elle reste obligatoire et
n'a pas été fabriquée.

## Verdict

**BLOCKED — un seul transport critique et l'attestation environnement restent
à fournir.** Le défaut de dépendance JMX amont et l'acquisition artificielle de
JMeter ont été supprimés sans affaiblir la provenance. Aucun run 14264 avec un
stage utile n'a abouti; les runs intermédiaires observés sont annulés et le
commit courant n'a pas été lancé. Une nouvelle queue échouerait encore sur
`consoleBuildId`/artefact Console ou sur l'attestation cible. Les définitions
2065 et 5224 n'ont pas été lancées.

## Relecture REST fraîche — branche dédiée

**FACT** — le 2026-09-08, Git REST a relu le YAML de la branche
`sandbox/clienteling/wi2222897-isolated-replay` avec le commit
`b790767c1cecb90d6913c8726aea532c29ea4582` (HTTP 200). Le contenu distant
contient les stages `Preflight`, `Build`, `GenerateJmx` et `JMeter`, l'URL fixe
JMeter 5.6.3 et `New-Wi2222897MigrationManifest.ps1`.

**FACT** — cette relecture ne trouve ni `migrationBuildId`, ni `jmeterArtifact`,
ni chemin documentaire local `investigations/ecarts-jmeter-migrations` dans le
YAML. La preuve porte sur la configuration distante, pas sur une exécution.

## Runs observés après publication de la configuration

**FACT** — la lecture REST de la définition `14264` retourne le YAML attendu,
le dépôt `Y2_Plugins_Clienteling` et la branche par défaut dédiée. La liste des
runs retourne `4445072`, `4445085` et `4445099`, tous `completed/canceled`, sur
les commits intermédiaires `23830d4`, `13b4443` et `0cf1736`; le dernier commit
`b790767c` n'a pas de run dans cette liste. Le run `4444892` reste
`completed/failed` au preflight.

**UNKNOWN** — la raison opérationnelle exacte de ces trois annulations n'est pas
établie par la seule liste des builds. Elles ne constituent aucune preuve de
Build, GenerateJmx ou JMeter réussi et ne justifient pas une conclusion métier.
