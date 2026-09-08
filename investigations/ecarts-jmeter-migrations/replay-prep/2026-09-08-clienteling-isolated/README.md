---
type: "ReplayPreparation"
title: "Clienteling WI-2222897 — orchestrateur isolé Build + JMeter Cur/Fix"
description: "YAML et scripts reviewables, fail-closed, pour consommer des artefacts de builds exacts sans publication partagée."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/replay-prep/2026-09-08-clienteling-isolated/README.md"
timestamp: "2026-09-08"
source_system: "local-kb"
---

# Orchestrateur isolé Clienteling WI-2222897

Statut : **configuration publiée sur la branche dédiée, définition 14264 créée, aucun nouveau run après le preflight 4444892**.

## Contrat d'entrée

Le pipeline attend des IDs de runs exacts pour les artefacts API, Console, JMeter et attestation : aucune sélection `latest`, aucun wildcard. Les nupkg API/Console sont vérifiés directement par SHA-256 et DLL embarquée; le manifest migration est produit depuis les XML Clienteling du checkout et publié comme PipelineArtifact intermédiaire avant `GenerateJmx`.

Préconditions d'arrêt :

- API attendue : branche `sandbox/clienteling/api-jmeter-fixes`, commit `4c22cb2850a150161f44080815375527c4daad48` ;
- Console attendue : nupkg `2.0.42-soapnamespace.20260907`, SHA-256 `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`, avec API embarquée hashée ;
- JMX : manifeste de régénération et hashes de chaque fichier effectivement consommé ;
- cible Cur/Fix : `target-attestation.json` signé par le job de préparation, `scope=WI-2222897`, `variant` explicite, `cleanupScope` limité au run et hôtes dédiés dont le préfixe est `wi2222897-` ;
- image/JMeter : runtime téléchargé explicitement dans chaque job depuis une source fixe et vérifié par SHA-512; aucun pull/import ACR ou téléchargement JFrog n'est effectué par ce pipeline.

## Ce que fait le YAML

1. `Preflight` télécharge les artefacts par définition + ID de build précis, génère le manifest XML depuis le checkout, vérifie les hashes nupkg/DLL et l'attestation, et refuse toute destination d'écriture non attestée.
2. `Build` compile/teste la source Clienteling et publie uniquement un artefact PipelineArtifact expurgé ; aucune publication NuGet/JFrog.
3. `GenerateJmx` vérifie le hash du nupkg Console, le hash de la DLL API embarquée, puis appelle le Console candidat sur les XML source explicitement mappés ; il publie les JMX générés et leur manifeste.
4. `JMeter_Cur` et `JMeter_Fix` consomment ce lot JMX généré et hashé, téléchargent le runtime JMeter dans chaque VM fraîche, avec leur cible et configuration variant attestées, puis exécutent JMeter et publient seulement des résultats scrubbed par PipelineArtifact.
5. Aucun stage `Publish`, `Promote`, `Tag`, `Artifactory`, `JFrog`, `ACR import`, trigger aval ou schedule n'existe.

## Limites restantes

Le commit de configuration distant courant est `b790767c1cecb90d6913c8726aea532c29ea4582`. Le build API `4444962`/artefact `5037204` est prouvé, mais le candidat Console `803D...EEE55B` reste sans PipelineArtifact et l'attestation de cible live manque ; aucun nouveau run n'est donc lancé. Les hôtes, backup, image et transport des fixtures ne sont pas inventés : ils doivent être attestés avant Cur/Fix.

Fichiers :

- [`azure-pipelines.clienteling-wi2222897.yml`](azure-pipelines.clienteling-wi2222897.yml)
- [`scripts/Assert-Wi2222897ArtifactManifest.ps1`](scripts/Assert-Wi2222897ArtifactManifest.ps1)
- [`scripts/Invoke-Wi2222897JmeterVariant.ps1`](scripts/Invoke-Wi2222897JmeterVariant.ps1)
- [`scripts/Invoke-Wi2222897JmxRegeneration.ps1`](scripts/Invoke-Wi2222897JmxRegeneration.ps1)
- [`scripts/New-Wi2222897MigrationManifest.ps1`](scripts/New-Wi2222897MigrationManifest.ps1)
