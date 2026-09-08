# BW2 environments — Full-Text et propagation image

Date de collecte : 2026-09-08 (Europe/Paris). Périmètre exclusif : `Pipelines_Docker_BaseImages`, `Y2_Tools_Jmeter_Workflow`, `Y2_Tools_PlatformDeploy`, propagation déclarative des images.

## Index

- [RESULT.md](RESULT.md) : faits, hypothèses, tests et limites.
- [CORRECTIONS.md](CORRECTIONS.md) : matrice exhaustive du périmètre.
- [INTEGRATION.md](INTEGRATION.md) : propositions destinées au lanceur, sans modification commune.
- [RESOURCES.md](RESOURCES.md) : ressources et nettoyage.
- [evidence/fulltext/](evidence/fulltext/) : hashes et résultat du test local.
- [evidence/platformdeploy/](evidence/platformdeploy/) : revue PlatformDeploy, patch local et harness de propagation des retours.

Les sources communes et les worktrees historiques sont en lecture seule. Un clone indépendant PlatformDeploy est conservé sous `worktrees/platformdeploy/`; son patch local et sa provenance sont documentés dans `evidence/platformdeploy/`.
