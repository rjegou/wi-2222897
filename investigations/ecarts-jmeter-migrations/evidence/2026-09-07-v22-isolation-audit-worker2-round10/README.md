# Revue locale — isolation FrenchTaxesRules V22

Date : 2026-09-07 (Europe/Paris)
Statut : revue locale inertée, aucun lancement ni mutation distante.

## Périmètre et sources

- Handoff : `investigations/ecarts-jmeter-migrations/HANDOFF.md`, Round16, run `4442225`.
- Candidat : `replay-prep/2026-09-07-v22-isolated/azure-pipelines.candidate.yml`.
- Orchestration : `replay-prep/2026-09-07-v22-isolated/scripts/steps-replay-variant.yml`.
- Policy : `replay-prep/2026-09-07-v22-isolated/V22-ISOLATION-POLICY.json`.
- Producteur hôte : `scripts/Write-V22HostIsolationAttestation.ps1`.
- Validateur : `scripts/Assert-V22IsolationAttestation.ps1`.
- Preuve runtime : `evidence/azure-devops-french-taxes-rules-v22-worker1-round16/README.md`.

## Vérifications exécutées

1. `Test-V22IsolationAttestation.ps1` avec fixtures inertes : cas conforme, mount non autorisé et forme JSON tableau rejetés. Résultat : PASS.
2. `Test-V22HostIsolationProducer.ps1` avec un `docker.cmd` inerte et racines d’agent synthétiques : le cas conforme écrit une attestation; le cas pipe Docker est refusé. Le test lui-même échoue sur son contrôle de message attendu : le producteur émet `Host mount does not match policy` avant `Forbidden shared mount`.
3. Analyse syntaxique PowerShell de tous les `.ps1` du dossier : 15/15 PASS.
4. Relecture statique de la policy, du producteur, du validateur, des steps et du YAML candidat.

## Constats qualifiés

### FACT

- `4442225` est terminé en échec sur `mounts` uniquement selon la whitelist conservée : `count=1;dangerous=1`; digest attendu, OS, architecture, target-scope, réseaux et ports passent; cleanup `containerPresentAfterRemove=False`.
- Le producteur lie explicitement `Agent.ContainerMapping.<resource>.id` à `Agent.ContainerId`, inspecte ce même ID, vérifie l’état running, le repository digest et le hostname, puis appelle le validateur avant de déplacer l’attestation vers la sortie.
- Le validateur lie `runId`, `jobName`, `jobId`, `scopeId`, image digest et destination SQL/IIS au contexte attendu; il vérifie les mounts, réseaux et ports contre la policy.
- Le YAML candidat séquence `Preflight`, `FixHistorical`, puis `FixCandidate`; chaque job métier appelle le producteur hôte avant l’assertion fail-closed, puis avant download, restauration/déploiement, SQL/IIS et JMeter.
- Le préflight manuel représente réellement les deux variantes dans le YAML : `FixHistorical` installe `Core 22.0.0.1011 / Common 22.0.2.300 / Identity 22.0.5.182`; `FixCandidate` installe `22.0.0.2068 / 22.0.3.311 / 22.0.6.117`. Les deux gardent le plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, image et backup attendus.

### DEFECT DEMONTRÉ

- Le contrat d’attestation ne contient ni champ de création/collecte, ni contrôle `LastWriteTime`, âge maximal ou correspondance avec l’instant du job. La freshness de l’attestation et de la policy est donc non contrôlée.
- Le producteur écrit sous `$(Agent.TempDirectory)` dans une étape `target: host`, exporte seulement un chemin par variable de tâche, puis le validateur s’exécute dans le conteneur. Aucun contrôle ne prouve que le chemin hôte est visible dans le conteneur, que le fichier relu est le même octet pour octet, ni que son transport ne passe pas par un mount partagé non autorisé. La liaison hôte→conteneur reste donc non prouvée.
- Le cas négatif du test producteur est incohérent avec le producteur : un mount `\\.\pipe\docker_engine` est rejeté par l’absence de correspondance policy avant d’atteindre le message `Forbidden shared mount` attendu. Le test ne constitue pas une validation verte de ce garde-fou.
- La policy autorise `job-work` en écriture, `agent-tools` en écriture et `agent-externals` en lecture seule. Ces mounts peuvent être nécessaires au fonctionnement de l’agent, mais le contrat ne prouve pas que `agent-tools`/`externals` sont dédiés au job ni qu’aucune écriture partagée ne peut atteindre un autre job. La possibilité d’écritures partagées demeure UNKNOWN, même si les cibles SQL/IIS sont liées au hostname du job.

### UNKNOWN

- La source et la destination du mount observé dans `4442225` ne sont pas dans la preuve conservée; son caractère réellement partagé n’est pas démontré.
- La disponibilité runtime de `Agent.ContainerMapping`, `Agent.ContainerId`, Docker CLI sur l’hôte, les racines agent et la visibilité de `Agent.TempDirectory` dans chaque job métier n’est pas prouvée par les essais locaux.
- Aucun résultat métier, succès de restauration, déploiement, SQL/IIS ou campagne JMeter n’est revendiqué.

## Corrections proposées avant toute queue

1. Ajouter à l’attestation `createdUtc` (et éventuellement hash de policy) et faire refuser toute attestation absente, future, périmée ou non contemporaine du run; contrôler aussi la fraîcheur de la policy.
2. Transporter l’attestation par un mécanisme explicitement supporté par Azure Pipelines entre `target: host` et le conteneur, puis vérifier dans le conteneur le hash SHA-256 du fichier et son chemin résolu; refuser tout fallback via un mount non prouvé.
3. Aligner le test producteur sur le contrat réel, ou modifier le producteur pour tester le motif forbidden avant le motif allowlist, puis exécuter les deux branches négatives.
4. Fournir une preuve runtime par job de la liste complète source/destination/mode des mounts, de l’identité du conteneur et de l’absence d’écriture hors répertoire job; traiter `agent-tools` et `agent-externals` comme dépendances agent explicitement bornées ou les remplacer par des copies job-locales.
5. Ne permettre download, restauration, déploiement, SQL/IIS, opérations discriminantes ou campagnes qu’après ces preuves, séparément dans `FixHistorical` et `FixCandidate`.

## Verdict

`NOT READY` pour un rejeu métier. La préparation distingue correctement les deux jobs et ferme la chaîne avant les actions métier, mais la fraîcheur, le transport de l’attestation et le caractère non partagé des mounts agent ne sont pas prouvés. Le run `4442225` reste un échec de whitelist mounts à provenance incomplète; aucune extrapolation métier n’est faite.

## Round 2 — corrections locales du contrat d’attestation

Modifications limitées à `replay-prep/2026-09-07-v22-isolated/` :

- ajout de `collectedUtc`, `attemptId` et `ExpectedContainerId` au contrat producteur/validateur;
- fenêtre de fraîcheur par défaut de 900 secondes, avec tolérance future de 60 secondes;
- liaison explicite run/job/tentative/conteneur dans les deux étapes du YAML (`SYSTEM_JOBATTEMPT`, `AGENT_CONTAINERID`);
- tests ajoutés pour attestation périmée, future, autre tentative, autre conteneur, fichier absent et cas valide;
- cas pipe Docker du test producteur aligné sur le message de rejet réellement émis;
- `MANIFEST.sha256` recalculé après modification.

Résultats : `Test-V22IsolationAttestation.ps1` PASS; `Test-V22HostIsolationProducer.ps1` PASS avec `docker.cmd` inerte; analyse syntaxique PowerShell `syntax_errors=0`. Ces résultats sont locaux et substitués : ils ne prouvent toujours ni le transport runtime hôte→conteneur, ni l’absence de mounts partagés, ni un rejeu métier.
