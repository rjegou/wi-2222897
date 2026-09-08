# Revue des sources et intégration

Date : 2026-09-08. Aucun système externe exécuté.

## Sources exactes

- Copie indépendante `worktrees/attestation/y2wf`, HEAD `4db2dcdab647249de3cdc27eadaf15a158b3a26a`.
- Template réel ciblé : `y2wf/PipelineTemplates/task-run-campaign.v1.yml`, SHA-256 `3B4044C54A3F39086A356FD5BDDB0405781911D4423CA89E133E2AC3A6B6B9B1`.
- Candidat V26 retrouvé dans l’index historique : `evidence/local-2026-09-07-v26-fix-replay-draft-hardened/templates/task-deploy-in-containerized-job.candidate.yml`, SHA-256 `FE575F4E46CBFCA5750195ABED24EC89874A8A0DE369B476A4C150E95757E8CB`.
- Candidat V26 campagne : `evidence/local-2026-09-07-v26-fix-replay-draft-hardened/templates/task-run-campaign.candidate.yml`, SHA-256 `96D5B6016C575B5DA68F23DCA9CFD0D30F59F01C04FE5181945EBFB4941043B7`.

## Verdict

**FACT** — le template V26 de déploiement possède des conditions de cleanup (`succeededOrFailed`) mais aucune preuve d’appel au consommateur d’attestation hôte dans les lignes inspectées. Le template campagne V26 lance JMeter mais ne contient pas ce garde-fou.

**FACT** — le runner V22 exact (`replay-prep/2026-09-07-v22-isolated/scripts/steps-replay-variant.yml`) possède déjà le producteur sur `target: host`, le consommateur avant déploiement et `condition: always()` pour cleanup; le candidat local indépendant apporte le contrat et l’adaptateur sans modifier la source historique.

**INFERENCE** — le diff applicable consiste à importer les deux scripts candidats dans le dépôt propriétaire puis à appeler le producteur dans l’étape hôte et le consommateur avant toute étape métier; les paramètres build/job/tentative, digest, OS, endpoint et policy doivent être liés par variables explicites.

**UNKNOWN** — aucun runner V26 exécutable avec ce contrat n’a été intégré ou testé; aucune preuve ne permet d’affirmer que les mounts système d’un job managed sont sûrs ou exclusivement possédés. Le cleanup ne doit pas supprimer le conteneur managed actif.
