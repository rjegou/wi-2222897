# Revue du préflight candidat V22 — Worker 2 round 6

Date : 2026-09-07 (Europe/Paris). Lecture seule; aucun pipeline, branche, définition, job distant ou runner produit n'a été modifié.

## Vérifications

- **FACT** — `MANIFEST.sha256` contient 11 entrées et les 11 hashes correspondent aux fichiers présents du candidat. Il couvre YAML, README, JMX manifest et scripts; le manifeste lui-même n'est pas auto-hashé.
- **FACT** — `azure-pipelines.candidate.yml:23-34` sépare maintenant le checkout `self` (branche portant les scripts), `pluginSource` au commit `2d826b8...`, `jmeterTools` au commit `4db2dcd...` et `platformDeploy` au commit `93f91487...`; `:51-56` utilise explicitement `pluginSource` pour le backup/JMX. Le défaut de chemin du round 5 est corrigé sous réserve que la branche self soit effectivement créée.
- **FACT** — PlatformDeploy `5.0.86` et son SHA-256 sont présents (`:10-11`); l’image YAML est maintenant l'image historique digestée `sqlexpress2019...@sha256:268476...` (`:14`, `:20`). Worker 1 rapporte un manifest JFrog HTTP 200 pour ce digest, mais la compatibilité agent/container n'est pas exécutée.
- **FACT** — le dry-run réel retourne `Preflight OK` avec `descriptors=2`, `jmx=32`, `hashes=32`, `legacy=232`, `web=144`, `total=376`; le test des modes d'échec retourne `FAILURE-MODES PASS`.

## Défauts restants

1. **Dry-run incohérent avec le YAML.** `scripts/Invoke-V22RunnerDryRun.ps1:13` conserve l'image candidate `sqlexpress2025...@sha256:ea74f21...`, tandis que le YAML final utilise l'image historique `sqlexpress2019...@sha256:268476...`. Le dry-run ne compare pas la valeur hardcodée à l'image du YAML (`:24-27` vérifie seulement un motif digest); il peut donc réussir malgré un mismatch de l'image cible.
2. **Préflight distant encore non exécutable sans branche self.** Le YAML suppose à `:43-59` que `$(Build.SourcesDirectory)\investigations\...` existe dans le checkout self. La branche/définition dédiée n'a pas été créée ni relue; cette postcondition reste UNKNOWN.
3. **Secret encore écrit localement.** `scripts/steps-replay-variant.yml:64` écrit `USERNAME`/`PASSWORD` dans `parameters.properties`. L'ACL restreinte (`:65-70`) réduit l'accès, mais ne prouve pas l'absence de fuite dans les erreurs de tâche, dumps ou fichiers temporaires. La clé JFrog est maintenant fournie par environnement (`:48-56`), sans `-verbose`, mais elle reste transmise à un script via argument (`:50`) et nécessite un contrôle de scrub des logs.
4. **Isolation runtime incomplète.** `Assert-V22LocalContainerRuntime.ps1:10-26` vérifie seulement variables, hostname, processus et listeners du job; il ne vérifie pas l'ID/digest réellement chargé, mounts, réseaux, cycle de vie ni absence de ressources partagées. Le script historique `Assert-V22RuntimeIsolation.ps1` n'est pas appelé par le candidat (`README.md:33`).
5. **Aucun résultat expurgé.** Le dry-run et le test des modes d'échec utilisent des substituts inertes et nettoient leurs temporaires; aucun résultat JMeter, code HTTP, assertion, hash d'assembly chargé ou comptage d'un run réel n'est disponible. `Collect-V22ScrubbedResults.ps1` n'a pas été alimenté par un replay.

## Verdict séparé

- **Préflight distant sans écriture : NON PRÊT.** La structure et les hashes sont améliorés, mais la branche self/définition n'existe pas, l'agent Windows/container n'est pas validé, les mounts/réseaux/cycle de vie ne sont pas inspectés et le dry-run n'est pas cohérent avec l'image finale.
- **Rejeu métier : NON PRÊT.** Aucun appel PlatformDeploy, restauration SQL/IIS, JMeter, résultat baseline/candidat ou sortie expurgée n'a été produit.

## Risque de création

Le YAML contient `trigger: none`, `pr: none`, `schedules: []` (`:2-4`), ce qui réduit le risque automatique. Cela ne prouve pas l'absence de triggers hérités de la définition, de policies de branche, de ressources container ou de pipelines aval. La création de branche/définition reste donc hors périmètre tant qu'une revue favorable explicite du contenu final et une lecture des effets de définition ne sont pas disponibles.

Défauts restants transmis à Worker 3; aucun runner ou fichier global partagé n'a été modifié.
