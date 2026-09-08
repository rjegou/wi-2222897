# Garde-fou d’isolation V22 — Worker 2 round 7

Date : 2026-09-07. Modification locale uniquement ; aucun socket Docker, privilège, agent partagé, réseau ou système distant modifié.

## Correction

Le candidat appelle désormais `Assert-V22IsolationAttestation.ps1` avant le contrôle readiness et avant téléchargement/hash PlatformDeploy ou écriture SQL/IIS. Le garde-fou exige deux fichiers fournis par un producteur hôte autorisé : une attestation et une politique explicite. Il refuse les chemins absents/non résolus, JSON null/tableau, provenance non hôte, run/job différents, image différente, scope différent, containerId mal formé, destinations SQL/IIS divergentes, mounts supplémentaires ou non autorisés, networks divergents et ports non autorisés.

Les valeurs attendues conservées sont l’image ACR confirmée et le digest confirmé. Aucune attestation hôte n’a été inventée ou ajoutée au candidat ; les variables `V22IsolationAttestationPath` et `V22IsolationPolicyPath` restent à fournir par l’architecture d’exécution. En leur absence, le job s’arrête avant PlatformDeploy.

## Ordre effectif

Dans `scripts/steps-replay-variant.yml` : configuration temporaire sous `Agent.TempDirectory`, garde-fou attestation hôte, readiness locale SQL/IIS, attestation baseline pour `FixCandidate`, téléchargement/hash/déploiement, vérification packages, campagnes et cleanup. La configuration temporaire n’est pas une écriture SQL/IIS ; aucune écriture cible ne précède les garde-fous.

## Tests

- `Test-V22IsolationAttestation.ps1` : PowerShell 7 et Windows PowerShell 5.1 PASS. Fixture matching host/container/image/mounts/networks/ports acceptée ; mount divergent refusé ; document JSON tableau refusé.
- `Test-V22ReplayFailureModes.ps1` : PASS.
- `Invoke-V22RunnerDryRun.ps1` : PASS, 32 JMX, 3 opérations discriminantes, 232 + 144, aucune exécution métier.
- Manifeste SHA-256 et syntaxe PowerShell : PASS.

## Limite et plan runtime

Un job conteneur ne peut pas déduire de façon fiable depuis l’intérieur l’ID hôte, les mounts, le réseau et le scope du conteneur qui l’exécute. Le pipeline actuel ne fournit pas ces fichiers. Le plan compatible sans privilège supplémentaire est : produire avant l’étape métier, depuis le mécanisme hôte déjà autorisé, une attestation JSON et une politique JSON dans un chemin partagé explicitement documenté ; transmettre leurs chemins au job ; laisser ce garde-fou refuser toute absence ou divergence ; conserver les données brutes hors publication. Tant que ce producteur hôte et le partage de chemins ne sont pas établis, l’isolation runtime reste UNKNOWN et aucun rejeu ne doit progresser au-delà du garde-fou.
