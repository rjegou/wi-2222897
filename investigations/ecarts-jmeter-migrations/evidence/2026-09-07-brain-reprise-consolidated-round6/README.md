# Round6 — PlatformDeploy ZIP/local access and wrapper differential

Date de collecte : 2026-09-07 (Europe/Paris). Collecte locale et read-only côté Azure DevOps/JFrog ; aucun MSI, déploiement, queue, publication ou push.

## Provenance

- Run Azure DevOps concerné : `4432602`, PlatformDeploy résolu dans les logs en `5.0.86`.
- Tag source relu précédemment : `refs/tags/V5.0.86` → commit `93f91487ee717185599555a42df3cb5d024ace89`.
- Collecte authentifiée existante relue : `investigations/ecarts-jmeter-migrations/evidence/azure-devops-french-taxes-rules-v22-worker1-round4/README.md`.
- Candidat isolé : `worktrees/Y2_Tools_PlatformDeploy_worker3_r5b`, détaché sur `93f91487...`, avec uniquement `Src/Powershell/Code/Scripts/init-container.ps1` modifié.

## ZIP : disponibilité locale

**FACT** — la collecte authentifiée existante rapporte pour `PlatformDeploy.5.0.86.zip` le SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`, taille `7,566,674` octets, et `lastModified=2026-08-18T14:24:42.963Z`.

**FACT** — aucune copie locale de `PlatformDeploy.5.0.86.zip` n’est présente sous `investigations/ecarts-jmeter-migrations/evidence` à cette collecte (`LOCAL_ZIP_COUNT=0`). Le hash ci-dessus est donc repris de la collecte authentifiée ; il n’est pas recalculé ici. L’acquisition anonyme n’est pas répétée (elle avait répondu HTTP 401).

**UNKNOWN** — égalité entre cette archive historisée et l’archive effectivement consommée par le run `4432602`, car le ZIP historique n’est pas localement disponible pour comparaison binaire.

## Test différentiel TF_BUILD

Le script `test-platformdeploy-differential-round6.ps1` appelle le vrai `docker-pipeline-deploy.ps1` du worktree source dans un staging temporaire. Son enfant est une fixture inerte qui reproduit uniquement la frontière de propagation de `init-container.ps1` ; aucun Docker, MSI, IIS ou SQL n’est lancé. `TF_BUILD=true` est injecté dans chaque processus.

Résultat observé :

```text
original   child 0      -> 0  (pass)
original   child 7      -> 0  (pass: absorption historique)
original   child throw  -> 1  (pass: exception non masquée)
corrected  child 0      -> 0  (pass)
corrected  child 7      -> 1  (pass: propagation)
corrected  child throw  -> 1  (pass: exception non masquée)
allPassed=true
```

**FACT** — le différentiel confirme le postcondition du garde candidat : sous `TF_BUILD=true`, un code enfant non nul devient un statut final non nul, tandis que le succès reste inchangé et l’exception reste non nulle. **LIMITATION** — la fixture isole la frontière de code ; elle ne constitue pas une validation de compatibilité MSI ni une exécution complète d’`init-container.ps1`.

## Ressources observées versus créées

| Catégorie | Ressource | État |
|---|---|---|
| Observée | collecte authentifiée ZIP et hash `625EEC...` | existante, relue, non modifiée |
| Observée | source tag `V5.0.86` / commit `93f91487...` | existante, relue |
| Observée | `worktrees/Y2_Tools_PlatformDeploy_worker3_r5b` | existante, candidat isolé conservé |
| Créée | `test-platformdeploy-differential-round6.ps1` | nouvelle preuve, staging nettoyé par le script |
| Non conservée | copie temporaire du wrapper et fixtures | supprimée en `finally` |
| Absente | ZIP local `PlatformDeploy.5.0.86.zip` | non disponible, hash non recalculé |

## Verdict

- **FACT** : le défaut de propagation du code enfant est démontré et le candidat isolé le corrige localement.
- **INFERENCE** : cette correction explique la divergence « installation apparente réussie » / erreur MSI et permettrait au pipeline de s’arrêter plus tôt ; elle ne rend pas les MSI compatibles.
- **UNKNOWN** : archive historique exacte du run `4432602`, cause de chaque MSI 1603, et résultat health-check après correction.
