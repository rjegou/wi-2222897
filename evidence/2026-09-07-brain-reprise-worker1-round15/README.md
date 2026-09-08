# Round 15 — Full-Text 4442156

Collecte dédiée, sans modification canonique, sans queue/push/publication distante et sans nouveau run.

## Commandes/provenance

- REST GET build, timeline, logs 9/14/18 et artifacts pour `Retail/_apis/build/builds/4442156`, API 7.1, TLS vérifié, PAT lu en mémoire seulement.
- `rg -n -C 3 'publish:|condition:|finally|runtime-diagnostic' worktrees/Pipelines_Docker_BaseImages_worker2_round9/validation/WI-2222897/sql-fulltext-hosted-build.yml`.
- `Get-FileHash .../sql-fulltext-hosted-build.yml -Algorithm SHA256`.
- `git -C worktrees/Pipelines_Docker_BaseImages_worker2_round9 status --short --branch` : checkout isolé `HEAD (no branch)`; aucune écriture.

## Verdict

FACT : compilation/image et démarrage/probe de population sont passés jusqu'au même échec `[1]` pour SQL2019 et SQL2025.

FACT : diagnostics préparés dans `finally`, mais leurs publishers sont skipped; aucun artefact n'est disponible.

INFERENCE : le premier obstacle exploitable est la condition de publication, avant toute attribution à SQL Server ou Full-Text.

UNKNOWN : cause moteur et comparabilité fonctionnelle; `CONTAINSTABLE` n'a pas été exécuté après population.

## Prochaine action

Patch minimal des deux publishers en `condition: always()`, puis rejeu unique après autorisation opérationnelle; lire service/processus/DMV/fragments/ERRORLOG et vérifier `CONTAINSTABLE`. Ne pas augmenter le timeout ni changer l'image avant cette observation discriminante.
