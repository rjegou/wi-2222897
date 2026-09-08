# Azure DevOps provenance — FrenchTaxesRules V22 — Worker 1 round 3

Date : 2026-09-07 (Europe/Paris). Lecture seule ; aucun pipeline lancé.

## Provenance exacte du build historique 4429167

**FACT** — build `4429167`, définition `FrenchTaxesRules CI` id `2054`, dépôt plugin `Y2_Plugins_FrenchTaxesRules`, branche `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V5`, commit plugin `2d826b8fd19ecb4d7200f574414efb7583de8ed2`.

Le log de checkout `build 4429167 / log 51` contient `HEAD is now at 2d826b8f dereferencement`.

**FACT** — le checkout historique de `Y2_Tools_PlatformDeploy@master` est prouvé par les logs `build 4429167 / logs 231 et 227` : `HEAD is now at 93f9148 Merged PR 502124: Fix TLS handshake reset for SNI-less clients on AuthenticationServer HTTPS site`, commit complet `93f91487ee717185599555a42df3cb5d024ace89`.

**FACT** — la timeline contient des checkouts du plugin et de PlatformDeploy, mais aucun checkout identifié de `Y2_Tools_Jmeter_Workflow` ou `Pipelines_Templates` avec un `HEAD is now at` exploitable. Leur provenance exacte au run reste **UNKNOWN**. Les noms de templates et la branche `master` ne suffisent pas à produire un commit immuable.

## Image et agents

**FACT** — le log ACR `build 4429167 / log 15` résout l'image historique `y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022` vers le digest `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`. Le YAML historique utilisait un tag ; le digest a été observé par le contrôle ACR/JFrog du run.

**FACT** — la queue historique est `Azure Pipelines` id `591`. La timeline montre des workers hébergés `Azure Pipelines <n>` et privés `vm-alm-agent-02-A`, `vm-alm-agent-06-A`, `vm-alm-agent-07-A`. L'inventaire courant des agents statiques du pool hébergé répond vide ; la disponibilité future n'est pas garantie.

**INFERENCE** — pour le rejeu isolé, le digest historique `268476...` est la référence la plus comparable. Le digest du brouillon local `ea74f21a...` est une sélection de préparation non équivalente et non validée comme image historique.

## Paramètres exacts préparés pour le runner

- plugin constant : `FrenchTaxesRules 22.0.6.478` ;
- AuthenticationServer constant : `2.0.0.368` ;
- baseline Fix historique : Core `22.0.0.1011`, Common `22.0.2.300`, Identity `22.0.5.182` ;
- candidat : Core `22.0.0.2068`, Common `22.0.3.311`, Identity `22.0.6.117` ;
- backup historique disponible : `AUTO_V21_00.bak`, SHA-256 `3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2` ;
- campagnes : 232 LegacyServices + 144 WebServices = 376 tests ;
- cas préalables : `012-FrenchTaxesRules_Run.jmx`, `006-Validation_SetDocumentErrorReason.jmx`, `020-Purge_Execute.jmx` ;
- image comparable proposée : `cegid-retail-docker-production/y2-jmeter@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.

Ces valeurs ne constituent pas une autorisation de déploiement. Le backup, les cibles SQL/IIS dédiées, les templates et les secrets doivent être résolus par le runner sans journalisation.

## Moyen de lancement isolé identifié

**FACT** — le pipeline historique `2054` n'est pas isolé : il contient des étapes JFrog, publication, promotion et tag, et référence les templates externes sans ref immuable.

**INFERENCE** — le moyen sûr est une définition YAML dédiée, sur branche/commit dédié, avec `trigger: none`, `pr: none`, `schedules: []`, image par digest, templates inline ou checkouts figés par SHA, stages limités au préflight/deployment/cas discriminants/campagnes et publication uniquement en PipelineArtifact. Les étapes JFrog upload/promote, tags, notifications et déclenchements aval doivent être absentes.

**UNKNOWN / BLOQUANT** — aucune définition dédiée n'a été créée dans ce lot ; aucun commit approuvé de `Pipelines_Templates` ou `Y2_Tools_Jmeter_Workflow` n'est disponible ; la tâche locale `task-run-campaign.v1.yml` a une fuite potentielle de paramètres secrets dans ses logs selon le handoff de préparation. Le runner ne doit donc pas être mis en queue sur la définition historique.

## Authentification et nettoyage

Les appels ont utilisé `AZURE_CONFIG_DIR=.azconfig-worker1-r3` et `AZURE_DEVOPS_EXT_PAT` uniquement dans le processus. Le PAT n'est pas dans les preuves. Le répertoire temporaire de configuration a été supprimé après collecte.

