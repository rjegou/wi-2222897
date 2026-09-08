# Diagnostic V22 — run 4442178 et provenance — Worker 1 round 14

Date : 2026-09-07. Collecte lecture seule après le résultat final ; aucun nouveau run.

## Run et sous-verdicts

Run `4442178`, définition `14246`, branche `refs/heads/investigation/wi-2222897-v22-preflight-20260907`, commit `2fd2830b4656ea836a20f12642649ff8d7057278`.

Résultat : `failed`, terminé `2026-09-07T17:06:44.425093+00:00`.

Timeline : Initialize `succeeded`; checkout `skipped`; authentification registry `succeeded`; inspection runtime `failed`; hash des sorties `succeeded`; post-job checkout et Finalize Job `succeeded`.

**FACT** — log 7 : digest acquis `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.

**FACT** — log 7 : `V22_PREFLIGHT_CLEANUP containerPresentAfterRemove=False`.

**FACT** — log 7 : `Runtime isolation whitelist assertion failed.`

**UNKNOWN** — les valeurs individuelles de `dangerousMounts`, réseaux interdits, bindings de ports et `targetScopeValid` ne sont pas imprimées avant l’assertion globale. Aucun lien causal supplémentaire n’est déduit entre le bug null reproduit offline et l’échec runtime ; le correctif null-port a été exécuté mais l’assertion reste en échec.

## Définition et tête

La définition relue garde `defaultBranch=refs/heads/investigation/wi-2222897-v22-preflight-20260907` et `/azure-pipelines.wi2222897-v22-preflight.yml`. La tête de cette branche est `2fd2830b4656ea836a20f12642649ff8d7057278`.

## Commits créés pour cette mission

| commit | parent | auteur/committer | date UTC | message |
|---|---|---|---|---|
| `5036e501ba797ab7efc861add60b111a40ff8141` | précédent historique | Ronan JEGOU / Ronan JEGOU | 2026-09-07T14:55:59Z | Fix read-only preflight cache miss handling |
| `cd632126c17f3ac95c8a29b079d0e243fa538e54` | `5036e501…` | rjegou / rjegou | 2026-09-07T16:18:06Z | Fix V22 preflight registry image reference |
| `a2a442c98f05b2e57d02a98fd7228967ee4104df` | `cd632126…` | rjegou / rjegou | 2026-09-07T16:39:05Z | Record V22 runtime isolation attestation |
| `2fd2830b4656ea836a20f12642649ff8d7057278` | `a2a442c9…` | rjegou / rjegou | 2026-09-07T16:55:18Z | Handle empty runtime port bindings |

Les messages, noms de branche et définition relus ne contiennent pas le terme interdit dans les éléments créés par cette reprise.

## Limites

Le préflight n’exécute aucun SQL, déploiement, appel métier ou rejeu. Le digest et le cleanup sont prouvés ; OS exact, architecture, labels/scope, mounts, réseaux et ports restent non prouvés individuellement. Le worktree endommagé n’a pas été modifié.
