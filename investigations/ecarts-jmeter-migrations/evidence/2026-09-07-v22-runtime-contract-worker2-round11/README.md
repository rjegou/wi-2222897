# Collecte ciblée — contrat runtime V22

Date : 2026-09-07 (Europe/Paris). Collecte locale et documentaire; aucune queue, mutation distante ou action métier.

## Sources et méthode

- YAML et scripts locaux : `replay-prep/2026-09-07-v22-isolated/`.
- Documentation officielle Microsoft Learn relue le 2026-09-07 : [variables prédéfinies Azure Pipelines](https://learn.microsoft.com/fr-fr/azure/devops/pipelines/build/variables?view=azure-devops) et [target YAML](https://learn.microsoft.com/fr-fr/azure/devops/pipelines/yaml-schema/target?view=azure-pipelines).
- Tests locaux avec fixtures et `docker.cmd` substitués; aucune fixture n’est traitée comme preuve runtime.

## Résultats

**FACT documentaire** — Microsoft documente `Agent.ContainerMapping` comme mappage des noms de ressources YAML vers leurs ID Docker runtime. Microsoft documente aussi `System.JobAttempt`, exposée comme `SYSTEM_JOBATTEMPT`. La même page documente `Build.ContainerId` comme ID de conteneur d’un artefact, distinct du conteneur d’un job.

**UNKNOWN runtime** — `AGENT_CONTAINERID` n’est pas établi par la documentation officielle relue et aucun run Azure Pipelines nouveau n’a été exécuté dans ce lot. Sa disponibilité ne peut donc pas être revendiquée.

**Correction locale** — l’étape hôte dérive désormais `mappedId` depuis `AGENT_CONTAINERMAPPING.v22Jmeter.id`, le producteur vérifie la forme et l’égalité avec ce mapping, puis publie `V22IsolationContainerId` par logging command. L’étape dans le conteneur valide ce même ID transmis, au lieu de dépendre de `AGENT_CONTAINERID`. `SYSTEM_JOBATTEMPT` reste utilisé pour la tentative.

**FACT d’ordre** — le producteur hôte et l’assertion d’attestation restent avant download, restauration/déploiement, SQL/IIS et JMeter. La variable de chemin d’attestation est toutefois toujours transportée par la mécanique Azure Pipelines; sa visibilité effective et l’identité octet-pour-octet du fichier dans le conteneur restent UNKNOWN.

## Tests discriminants

- `Test-V22IsolationAttestation.ps1` : cas valide, périmé, futur, autre tentative, autre conteneur, autre run, autre job et fichier absent — PASS.
- `Test-V22HostIsolationProducer.ps1` avec `docker.cmd` inerte — PASS; égalité mapping/ID et mount interdit vérifiées localement.
- Analyse syntaxique PowerShell de `replay-prep/2026-09-07-v22-isolated/scripts` — 0 erreur.
- `MANIFEST.sha256` du replay-prep recalculé et vérifié après édition.

## Limites et verdict

Le contrat local ne peut pas prouver que l’agent Azure fournit réellement les variables au runtime ni que `Agent.ContainerMapping` et l’ID utilisé par le job sont identiques sur un run réel sans collecte hôte autorisée. Les mounts partagés et le transport hôte→conteneur demeurent UNKNOWN. Verdict : garde-fou local amélioré, rejeu métier toujours NOT READY.

## Complément round 3

La documentation officielle ne permet pas d’établir `AGENT_CONTAINERID`; le YAML ne l’utilise plus. L’étape hôte extrait `v22Jmeter.id` de `AGENT_CONTAINERMAPPING`, vérifie cet ID avec Docker et publie `V22IsolationContainerId` pour l’étape conteneur. Les contrôles de dry-run résiduels ont été alignés sur ce contrat.

Tests après correction : `Test-V22IsolationAttestation.ps1` PASS (valide, périmée, future, autre tentative, autre conteneur, autre run, autre job, absent); `Test-V22HostIsolationProducer.ps1` PASS; `Test-V22ReplayFailureModes.ps1` PASS; syntaxe PowerShell 0 erreur; manifeste replay-prep vérifié sans erreur.

Limite inchangée : aucun run Azure réel n’a confirmé la disponibilité de `AGENT_CONTAINERMAPPING`, la propagation de `V22IsolationContainerId` ou la visibilité de l’attestation entre hôte et conteneur. Les mounts partagés et tout résultat métier restent UNKNOWN.
