---
type: "Evidence"
title: "Clienteling WI-2222897 — audit final de clôture round 12"
timestamp: "2026-09-08"
source_system: "Azure DevOps REST 7.1 read-only, Git REST, filesystem local"
freshness: "2026-09-08"
---

# Portée et méthode

Lecture REST avec le PAT uniquement en mémoire, sans queue, push, annulation,
provisionnement ou nettoyage distant. Références contrôlées : définition
`14264`, branche `sandbox/clienteling/wi2222897-isolated-replay`, builds ciblés,
timelines, artefacts et fichiers locaux.

## FACT — référence distante finale

- Définition `14264` : `WI-2222897 Clienteling Isolated Replay`, dépôt
  `Y2_Plugins_Clienteling`, YAML
  `ci/wi2222897/azure-pipelines.clienteling-wi2222897.yml`, branche par défaut
  `sandbox/clienteling/wi2222897-isolated-replay`.
- Tête Git REST relue :
  `f8858ad73df9c9eca7e438e609b6effebb677a9b`.
- Cette tête est postérieure à `b790767c...`; les affirmations antérieures du
  handoff disant que b790 est la tête ou qu’aucun run postérieur n’existe sont
  obsolètes.

## FACT — builds ciblés et stages réellement exécutés

| Build | Définition / commit | Résultat | Timeline utile | Interprétation |
|---:|---|---|---|---|
| 4444892 | 14264 / `edb02f3...` | failed | `VerifyInputs` failed; Preflight failed; Build/GenerateJmx/JMeter skipped | premier preflight `apiBuildId` manquant |
| 4445072 | 14264 / `23830d4...` | canceled | timeline HTTP 204 | annulation immédiate, aucun stage |
| 4445085 | 14264 / `13b4443...` | canceled | timeline HTTP 204 | annulation immédiate, aucun stage |
| 4445099 | 14264 / `0cf1736...` | canceled | timeline HTTP 204 | annulation immédiate, aucun stage |
| 4445292 | 14264 / `20a063b...` | canceled | diagnostic cible canceled; autres stages skipped | agent sans `docker` |
| 4445454 | 14264 / `57222c2...` | succeeded | diagnostic cible succeeded; autres stages skipped | succès du diagnostic de collecte uniquement |
| 4445464 | 14264 / `4ec1fb0...` | partiallySucceeded | diagnostic cible succeededWithIssues; autres stages skipped | erreurs `docker`/`rg`, pas campagne |
| 4445516 | 14264 / `f8858ad...` | partiallySucceeded | diagnostic cible succeededWithIssues; autres stages skipped | erreurs `docker`/`rg`, pas campagne |

**FACT** — aucun de ces runs 14264 n’a exécuté Build Clienteling, GenerateJmx
ou Cur/Fix. `succeeded` de 4445454 ne doit pas être converti en preuve de
capacité Docker ni en résultat Clienteling.

Les artefacts diagnostics créés sont PipelineArtifact-only :

- 4445292 → `wi2222897-target-diagnostic-4445292`, ID `5037705` ;
- 4445454 → `wi2222897-target-diagnostic-4445454`, ID `5037713` ;
- 4445464 → `wi2222897-target-diagnostic-4445464`, ID `5037721` ;
- 4445516 → `wi2222897-target-diagnostic-4445516`, ID `5037823`.

Les logs relus de 4445292/4445454/4445464/4445516 montrent `docker` non
reconnu sur l’agent `vm-alm-agent-02-A` ou `vm-alm-agent-02-B`; 4445464/4445516
ont aussi une erreur `rg` lors du scan. Aucun conteneur, réseau, image ou backup
Clienteling n’est prouvé comme créé par ces diagnostics.

## FACT — dépendances API/Console distinctes

- API : définition `2637`, build `4444962`, commit
  `4c22cb2850a150161f44080815375527c4daad48`, PipelineArtifact `Nuget` ID
  `5037204`, résultat succeeded.
- Console : définition `2641`, build `4445025`, commit
  `dfda5e52e637e423432023d9fb6b870e92104703`, PipelineArtifact `Nuget` ID
  `5037277`, résultat succeeded. Le nupkg réellement fourni a le SHA-256
  `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`, pas le
  candidat local SOAP `803DDBAA...EEE55B`. Il ne prouve donc pas la consommation
  du candidat Console corrigé attendu.

Ces builds sont des builds API/Console séparés, pas des campagnes Clienteling;
aucun résultat Cur/Fix ne leur est attribué.

## FACT — origine Windows 2025/Docker historique

La matrice indépendante `parallel/.../evidence/agent-comparability-round7.md`
identifie les jobs historiques `4440884` : Cur sur `Azure Pipelines 2` et Fix
sur `Azure Pipelines 3`, tous deux Windows 2025, avec pull/inspect/create Docker
réussi et digest image `ea74f21a...`. Le build `4444389` montre au contraire Fix
sur `Azure Pipelines 9`, Windows 2025, avec pipe Docker absent avant création.
Ces observations expliquent la compatibilité attendue mais ne sont pas une
attestation du job 14264.

## Ressources locales et état Git

Présence locale vérifiée : replay-prep YAML/scripts, preuves round7 à round11,
staging Console `console-4445025`, sources migration/Clienteling, diagnostics
`.work/target-diagnostic-round8`, archives `target-diagnostic-4445516.zip` et
répertoires temporaires `azcfg-*`, `artifacts`, `transport-round7`.

Ces ressources sont locales et restent dans le worktree partagé; aucun cleanup
des éléments appartenant à d’autres workers n’a été effectué. Le dépôt
documentaire est déjà dirty avec de nombreuses modifications/untracked d’autres
unités; les livrables de cette phase apparaissent eux aussi non committés. Aucun
commit ou push n’a été réalisé dans cet audit final.

## Contradictions / limites à transmettre

1. Le handoff doit remplacer la tête b790 par f8858ad et intégrer les runs
   4445292/4445454/4445464/4445516; cette preuve ne modifie pas le canonique.
2. Les statuts globaux `succeeded`/`partiallySucceeded` des diagnostics ne
   valent ni Build Clienteling, ni JMX, ni Cur/Fix.
3. Les logs prouvent l’absence de `docker` sur les agents des diagnostics; ils
   ne prouvent pas l’existence de ressources Docker résiduelles.
4. L’attestation cible, le backup/hash, le digest courant, le reçu PlatformDeploy,
   le transport du Console `803D...`, la génération/consommation JMX et les
   résultats métier Cur/Fix restent non prouvés.

**Verdict de clôture : investigation consolidée, campagnes Clienteling non
exécutées et prochaines actions clairement bloquées par les préconditions
réelles ci-dessus.**
