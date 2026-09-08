# Contrat d’attestation hôte → consommateur

Date de collecte : 2026-09-08 (Europe/Paris). Périmètre : proposition locale BW2, sans Docker, SQL, IIS, Azure DevOps, publication ou ressource partagée.

## Provenance

- Source historique relue : `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/scripts/` et son contrat V22 ; les fichiers sources communs n’ont pas été modifiés.
- Candidat propre : `../../worktrees/attestation/AttestationContract.ps1`.
- Test propre : `Test-AttestationContract.ps1`.
- Exécution : PowerShell 7, fixture JSON synthétique et répertoire de preuve sous cette racine exclusive.

## Résultat

**FACT** — le producteur exige le mapping de la ressource et l’ID inspecté exact, l’état running, le digest, l’OS, le run/job/tentative, l’hôte et l’endpoint exclusif avant écriture atomique de l’attestation.

**FACT** — le consommateur refuse absence, JSON invalide/tableau, provenance non hôte, divergence run/job/tentative/conteneur/OS/digest/hôte/endpoint, timestamp périmé ou futur, mount partagé, port publié et réseau hors préfixe `job-`.

**FACT** — `Test-AttestationContract.ps1` retourne `exit=0` le 2026-09-08. Les cas valid, absent, stale, different-container et cleanup possédé sont exercés. Le cleanup supprime uniquement les enfants d’un répertoire portant le marqueur propriétaire attendu ; un fichier voisin non possédé est conservé.

**INFERENCE** — ce contrat fournit un point d’arrêt avant restauration/déploiement et une base de transport producteur→consommateur pour un futur job dédié.

**UNKNOWN** — aucun run réel n’établit que `Agent.ContainerMapping` est disponible sur l’agent cible, que l’ID hôte atteint le même job conteneur, que l’attestation est visible octet pour octet dans le conteneur, ou que l’OS/digest/mounts/réseaux/ports/endpoints correspondent réellement. Aucun résultat de migration n’est démontré.

## Reproduction

```powershell
$root = '...\bw2-environments'
pwsh -NoLogo -NoProfile -NonInteractive -File "$root\evidence\attestation\Test-AttestationContract.ps1" `
  -ContractPath "$root\worktrees\attestation\AttestationContract.ps1" `
  -EvidenceRoot "$root\evidence\attestation"
```

Le chemin `...` est un placeholder documentaire, pas une commande exécutée avec un chemin ambigu.
