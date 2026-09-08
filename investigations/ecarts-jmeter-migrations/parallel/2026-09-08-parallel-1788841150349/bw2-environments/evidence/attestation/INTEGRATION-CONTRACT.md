# Intégration proposée V22/V26

Date : 2026-09-08. Candidat local uniquement.

Le script `worktrees/attestation/V22AttestationPipelineAdapter.ps1` est l’adaptateur hôte. Il lit `AGENT_CONTAINERMAPPING` sur l’étape `target: host`, extrait exclusivement `v22Jmeter.id`, inspecte cet ID exact avec Docker, puis appelle le producteur du contrat. Il publie seulement `V22IsolationContainerId` par logging command non secret. Le consommateur doit recevoir ce même ID et appeler `Assert-HostAttestation` avant tout download, restore, deploy, SQL, IIS ou JMeter.

Le cleanup doit être placé dans `finally`/`condition: always()` et ne supprimer que le répertoire marqué par le propriétaire de la tentative. Toute absence ou divergence du marqueur est un refus, jamais un fallback.

**FACT** — le point d’intégration historique `Y2_Tools_Jmeter_Workflow/PipelineTemplates/task-run-campaign.v1.yml` prépare puis exécute JMeter, mais ne prouve pas la présence d’une attestation hôte ni d’un binding `Agent.ContainerMapping`.

**UNKNOWN** — la disponibilité réelle de `AGENT_CONTAINERMAPPING`, le format du JSON sur l’agent, le mapping de la ressource vers le conteneur exact, et la visibilité du fichier dans le conteneur n’ont pas été exécutés ce round.

Le test `Test-V22AttestationPipelineAdapter.ps1` invoque réellement les fonctions de l’adaptateur avec une inspection synthétique, et couvre aussi le mode `manual`, où l’identité explicite du conteneur est requise sans exiger `AGENT_CONTAINERMAPPING`. Résultat : `exit=0` le 2026-09-08. Hash adaptateur final : `4C9C626690F64ED488FE0CFC60142D167C5296704F9F5A260379169B98C77FB0`.

Une copie Git indépendante a finalement été créée sous `worktrees/attestation/y2wf` avec `--no-checkout`, `--no-hardlinks`, `core.longpaths=true` limité à la commande et restauration ciblée de `PipelineTemplates/task-run-campaign.v1.yml`. HEAD source/copie : `4db2dcdab647249de3cdc27eadaf15a158b3a26a`. Le dépôt source reste inchangé, avec sa modification locale `azure-pipeline.yml` préservée. Le runner V26 exact n’est pas présent dans cette copie et son intégration reste UNKNOWN/non réalisée.
