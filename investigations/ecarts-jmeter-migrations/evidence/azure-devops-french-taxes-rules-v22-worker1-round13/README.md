# Préflight V22 — attestation runtime round 13

Date : 2026-09-07. Collecte lecture seule du run existant ; aucune nouvelle queue.

## Provenance

- Définition : `14246`, `WI-2222897 V22 Runtime Preflight 20260907`.
- Branche : `refs/heads/investigation/wi-2222897-v22-preflight-20260907`.
- Commit exécuté : `a2a442c98f05b2e57d02a98fd7228967ee4104df`.
- YAML : `/azure-pipelines.wi2222897-v22-preflight.yml`.

## Résultat

Run `4442152` : `failed`, terminé `2026-09-07T16:49:43.354666+00:00`.

Timeline : Initialize succeeded ; checkout skipped ; authentification registry succeeded ; inspection runtime failed ; hash des sorties succeeded ; post-job checkout et Finalize Job succeeded.

## Faits directs

**FACT** — le log d’inspection contient `Digest: sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb` et confirme le téléchargement de l’image qualifiée.

**FACT** — le log contient `V22_PREFLIGHT_CLEANUP containerPresentAfterRemove=False`, donc le contrôle de présence après suppression a réussi.

**FACT** — le log contient ensuite `Runtime isolation whitelist assertion failed.` ; la tâche d’inspection retourne le code 1.

**UNKNOWN** — la sous-assertion fautive parmi `dangerousMounts`, réseaux interdits, bindings de ports et `targetScopeValid`, car leurs valeurs ne sont pas imprimées avant le test global. Les JSON détaillés restent uniquement dans Agent.TempDirectory et ne sont pas publiés.

**LIMITATION** — le digest et le cleanup sont prouvés ; les valeurs détaillées OS, architecture, ID/labels du conteneur, mounts, réseaux et ports ne le sont pas individuellement. Le préflight ne contient aucun SQL, déploiement, appel métier ou stage de rejeu.

## Définition

La définition relue après correction conserve `defaultBranch=refs/heads/investigation/wi-2222897-v22-preflight-20260907` et le YAML `/azure-pipelines.wi2222897-v22-preflight.yml`. Aucun run actif n’a été modifié ou relancé.
