---
type: "Evidence"
title: "Clienteling WI-2222897 — orchestrateur isolé reviewable Round 3"
description: "Commit API revalidé et YAML/scripts concrets préparés ; création de définition et queue arrêtées devant un blocage d'accès réel."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-isolated-pipeline-round3/README.md"
timestamp: "2026-09-08"
source_system: "Azure DevOps REST API + validation locale"
---

# Clienteling WI-2222897 — orchestrateur isolé reviewable Round 3

## Provenance

- Référence Azure DevOps relue indépendamment le 2026-09-08 avec le PAT utilisateur en mémoire de processus :
  `4c22cb2850a150161f44080815375527c4daad48 refs/heads/sandbox/clienteling/api-jmeter-fixes` dans `Y2_Tools_AutoTest_Api`.
- La preuve Worker 1 établit que ce commit contient uniquement le delta corrigé de `JmeterCodeGen.cs`, basé sur `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`, sans publication de feed, PR, tag ni queue.
- Aucun secret, PAT, package privé ou contenu de credential n'est copié dans cette preuve.
- Aucun pipeline, définition, branche, feed, image, tag ou run n'a été créé/modifié par cette collecte.

## Livrables concrets

Dossier reviewable : [`replay-prep/2026-09-08-clienteling-isolated/`](../../replay-prep/2026-09-08-clienteling-isolated/)

| Fichier | Rôle | Contrôle |
|---|---|---|
| `azure-pipelines.clienteling-wi2222897.yml` | `trigger: none`, `pr: none`, `schedules: []`; stages `Preflight`, `Build`, `GenerateJmx`, `JMeter` Cur/Fix | SHA-256 `81E3D3605854F56FF01405E0C6FDCA4E06372EAC703883B2720DB9FFEABE99ED` |
| `scripts/Assert-Wi2222897ArtifactManifest.ps1` | exige les builds exacts, manifests, SHA-256 API/Console/migration et attestation de cibles dédiées | parse PowerShell OK |
| `scripts/Invoke-Wi2222897JmxRegeneration.ps1` | vérifie le nupkg Console et la DLL API embarquée, puis génère les JMX depuis les XML mappés | parse PowerShell OK |
| `scripts/Invoke-Wi2222897JmeterVariant.ps1` | vérifie le manifeste JMX et lance JMeter séparément pour Cur/Fix, avec sortie par artefact PipelineArtifact | parse PowerShell OK |

Le YAML ne contient aucun `Artifactory`, `JFrog`, `az acr import`, `Promote`, `git tag` ou `git push`. Les seules sorties externes prévues sont des `PipelineArtifact` de manifests et résultats scrubbed.

## Transport candidat API/Console/migration

- API : `apiDefinitionId=2637`, branche et commit exacts ci-dessus ; le run doit fournir un artefact `Nuget` avec `manifest.json`.
- Console : `consoleDefinitionId=2641`, run exact fourni au lancement ; le nupkg attendu est par défaut `2.0.42-soapnamespace.20260907`, SHA-256 `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`.
- DLL API embarquée attendue : SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B`.
- Migration : `migrationDefinitionId` et `migrationBuildId` obligatoires ; son manifeste doit mapper chaque `jmxPath` vers un `sourceXml` et rester dans le périmètre `WI-2222897`.
- Target : `target-attestation.json` obligatoire ; les hôtes applicatif/DB et `cleanupScope` doivent commencer par `wi2222897-`. L'absence d'attestation arrête le preflight avant JMeter.

## Validation exécutée

**FACT** — les trois scripts PowerShell ont été parsés par `System.Management.Automation.Language.Parser` sans erreur.

**FACT** — `git diff --check` passe sur le dossier de préparation.

**FACT** — les garde-fous textuels `trigger: none`, `pr: none`, `schedules: []` sont présents et les tokens de publication/promotion/import/tag interdits sont absents du YAML.

**FACT** — aucun build API actif concurrent n'était présent lors du contrôle final.

## Nouveau blocage précis

**FACT** — le YAML est seulement local : il n'est pas présent dans une branche du dépôt `Y2_Plugins_Clienteling` et aucune définition Azure DevOps ne le référence.

**FACT** — les refs Clienteling relues ne fournissent aucune branche dédiée WI-2222897 ; la branche historique `Clienteling_Migration_AutoTest_Jmeter_On_master` n'est pas modifiée.

**FACT** — la création de branche candidate antérieure a reçu `VS403660` (`CreateBranch`, identité `rjegou@cegid.com`). Aucun contournement ou élargissement de permission n'a été tenté.

**VERDICT** — ne pas lancer `2065 — Clienteling CI` : son YAML live conserve staging Artifactory, téléchargement JFrog, contrôle/import ACR, Promote et Tag. Ne pas créer une définition pointant sur ce YAML pour simuler l'isolation.

La prochaine action nécessitant autorité externe est concrète : fournir une branche Clienteling dédiée préexistante contenant ce YAML, ou accorder temporairement la permission de création de branche au périmètre exact. Ensuite seulement relire le commit, créer une définition manuelle sans triggers et fournir les quatre IDs de builds/artefacts exigés avant queue.

