# CONSOLIDATED_STATE — Round6

Date : 2026-09-07. Document de fusion destiné à BRAIN ; aucun document canonique partagé n’a été modifié.

## Mise à jour round5/round6

La collecte authentifiée existante rapporte `PlatformDeploy.5.0.86.zip` avec SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`. Le fichier n’est pas présent localement dans les preuves (`LOCAL_ZIP_COUNT=0`) : hash observé, non recalculé ici. L’identité source reste le tag `V5.0.86` / commit `93f91487...`; l’égalité binaire entre tag, archive actuelle et archive historique du run `4432602` demeure **UNKNOWN**.

Le candidat isolé `worktrees/Y2_Tools_PlatformDeploy_worker3_r5b/Src/Powershell/Code/Scripts/init-container.ps1` contient uniquement le garde qui capture immédiatement `$LASTEXITCODE` après `deploy.ps1` et lève sur code non nul. Aucun commit ni push.

## Test discriminant

`test-platformdeploy-differential-round6.ps1` appelle le wrapper réel `docker-pipeline-deploy.ps1` avec `TF_BUILD=true` et des enfants inertes 0, 7 et exception :

| Variante | enfant 0 | enfant 7 | exception |
|---|---:|---:|---:|
| originale | 0 | 0 (absorption) | 1 |
| corrigée | 0 | 1 (propagation) | 1 |

Tous les cas passent (`allPassed=true`). La preuve porte sur la propagation de processus, pas sur MSI/IIS/SQL.

## Ressources et blocages

- Observées : collecte ZIP authentifiée, tag/commit source, worktree isolé candidat.
- Créées : script de test round6 et cette collecte ; staging temporaire supprimé automatiquement.
- Blocage précis : ZIP historique non disponible localement ; pas de recalcul ni de comparaison binaire possible.
- UNKNOWN conservés : cause des MSI 1603, compatibilité des packages, validation health-check après correction.

## Prochaine action utile

Faire relire le candidat par le propriétaire PlatformDeploy puis exécuter une validation CI dédiée et isolée, avec artefact/hash capturé et logs d’installation/health-check. Ne pas présenter ce garde comme une résolution des incompatibilités MSI.
