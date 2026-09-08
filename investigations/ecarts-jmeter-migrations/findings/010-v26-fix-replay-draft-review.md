# Revue critique du brouillon pipeline V26 Fix

Date : 2026-09-06. **FACT** — la revue locale des sept contrôles est dans [la preuve dédiée](../evidence/local-2026-09-06-v26-fix-replay-review/README.md). Le brouillon désactive les triggers déclaratifs et limite sa publication à un PipelineArtifact, mais ne démontre pas le JMX corrigé consommé, le commit checkouté, les identités chargées, l’agent LTSC2025 ni l’isolation SQL/IIS.

**FACT** — le garde-fou SQL/IIS est postérieur à l’écriture (`azure-pipelines.candidate.yml:43-77`; `templates/task-deploy-in-containerized-job.candidate.yml:173-202`). **FACT** — les propriétés JMeter sont écrites et affichées avec `PASSWORD`/`DB_PASSWORD` (`templates/task-run-campaign.candidate.yml:90-107`) et l’archive de déploiement est copiée sans inspection (`scripts/stage-evidence.ps1:16-31`).

**INFERENCE** — compléter le brouillon sans ces corrections pourrait écrire sur une cible ambiguë et publier des secrets. **UNKNOWN** — aucune exécution métier ne permet de conclure sur un résultat JMeter/Legacy.

Décision : **bloquer** et réaliser les préparatifs listés dans la preuve. Aucun succès métier n’est déclaré.
