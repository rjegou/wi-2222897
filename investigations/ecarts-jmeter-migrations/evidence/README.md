# Index des preuves — enquête écarts JMeter / legacy

**Index actualisé le 2026-09-10.** Il couvre **la totalité** des 185 dossiers de preuve, ce qui n'était pas le cas de l'index précédent (74 dossiers n'y étaient pas cités).

## Comment lire ce tableau

- **Sujet** : premier titre du `README.md` du dossier. C'est l'entrée à privilégier — le *nom* du dossier reflète souvent le producteur et son numéro de tour, pas le contenu.
- **Dans le dépôt** : nombre de fichiers de la couche documentaire (README, manifestes, empreintes, CSV, JSON, scripts) réellement versionnés ici.
- **Hors dépôt** : artefacts bruts volumineux laissés à leur emplacement d'origine (logs, `.jmx`, `.jtl`, dumps XML, archives). Voir [EXTERNAL-ARTIFACTS.md](../../../EXTERNAL-ARTIFACTS.md) pour le chemin exact et la règle de conservation.

Un dossier dont la colonne « hors dépôt » est à `0` est intégralement présent ici.

## Dossiers de preuve

| Dossier | Sujet | Dans le dépôt | Hors dépôt |
|---|---|---:|---:|
| [`2026-09-07-azure-devops-inventorytracking-4434070/`](2026-09-07-azure-devops-inventorytracking-4434070/) | — | 0 | — |
| [`2026-09-07-azure-devops-inventorytracking-4434070-r1/`](2026-09-07-azure-devops-inventorytracking-4434070-r1/) | InventoryTracking master — build 4434070 — collecte r1 | 3 | — |
| [`2026-09-07-azure-devops-inventorytracking-4434070-worker1-crosscheck/`](2026-09-07-azure-devops-inventorytracking-4434070-worker1-crosscheck/) | InventoryTracking master — build 4434070 — contre-vérification worker 1 | 3 | — |
| [`2026-09-07-brain-reprise-consolidated/`](2026-09-07-brain-reprise-consolidated/) | Consolidation dédiée — reprise WI-2222897 — 2026-09-07 | 4 | — |
| [`2026-09-07-brain-reprise-consolidated-round6/`](2026-09-07-brain-reprise-consolidated-round6/) | Round6 — PlatformDeploy ZIP/local access and wrapper differential | 3 | — |
| [`2026-09-07-brain-reprise-consolidated-round7/`](2026-09-07-brain-reprise-consolidated-round7/) | Consolidation Worker 3 — Round7 | 3 | — |
| [`2026-09-07-brain-reprise-worker1/`](2026-09-07-brain-reprise-worker1/) | Reprise indépendante Worker 1 — handoff SOAP et chaîne générateur | 1 | — |
| [`2026-09-07-brain-reprise-worker1-round10/`](2026-09-07-brain-reprise-worker1-round10/) | FACT | 6 | 2 fich. / 2.4 Mo |
| [`2026-09-07-brain-reprise-worker1-round11/`](2026-09-07-brain-reprise-worker1-round11/) | FACT — reconciliation | 7 | — |
| [`2026-09-07-brain-reprise-worker1-round12/`](2026-09-07-brain-reprise-worker1-round12/) | FACT | 7 | — |
| [`2026-09-07-brain-reprise-worker1-round13/`](2026-09-07-brain-reprise-worker1-round13/) | FACT | 6 | — |
| [`2026-09-07-brain-reprise-worker1-round14/`](2026-09-07-brain-reprise-worker1-round14/) | FACT | 6 | — |
| [`2026-09-07-brain-reprise-worker1-round2/`](2026-09-07-brain-reprise-worker1-round2/) | Round 2 — validation générateur/package/JMeter | 1 | 39 fich. / 0.2 Mo |
| [`2026-09-07-brain-reprise-worker1-round3/`](2026-09-07-brain-reprise-worker1-round3/) | Collecte Worker 1 — Clienteling V22–V25 | 53 | 60 fich. / 1.8 Mo |
| [`2026-09-07-brain-reprise-worker1-round4/`](2026-09-07-brain-reprise-worker1-round4/) | Collecte Worker 1 — validation Clienteling V24/V25 | 1 | 18 fich. / 0.5 Mo |
| [`2026-09-07-brain-reprise-worker1-round5/`](2026-09-07-brain-reprise-worker1-round5/) | Collecte Worker 1 — orchestration locale Clienteling | 3 | 311 fich. / 94.3 Mo |
| [`2026-09-07-brain-reprise-worker1-round6/`](2026-09-07-brain-reprise-worker1-round6/) | InventoryTracking build 4440884 — analyse primaire read-only | 27 | — |
| [`2026-09-08-inventorytracking-azdo-access-diagnosis-round2/`](2026-09-08-inventorytracking-azdo-access-diagnosis-round2/) | InventoryTracking — validation AzDO Python/OpenSSL — builds 4440774/4440884 et résultats Cur/Fix | 22 | — |
| [`2026-09-08-inventorytracking-azdo-independent/`](2026-09-08-inventorytracking-azdo-independent/) | InventoryTracking — tentative indépendante AzDO Schannel/CLI — accès bloqué | 9 | — |
| [`local-2026-09-10-inventorytracking-legacy-trigger-matrix/`](local-2026-09-10-inventorytracking-legacy-trigger-matrix/) | InventoryTracking — matrice live YAML/runs expliquant l'absence variable de Testing Manager | 1 | — |
| [`build-4444389-inventorytracking-docker-reprise-20260908/`](build-4444389-inventorytracking-docker-reprise-20260908/) | InventoryTracking — 4444389 terminal canceled, Docker Fix/Cur et provenance de reprise | 6 | — |
| [`build-4444389-inventorytracking-docker-reprise/`](build-4444389-inventorytracking-docker-reprise/) | Extraits expurgés de timeline 4444389 — Docker Fix et annulation Cur | 1 | — |
| [`build-4444720-inventorytracking-docker-init/`](build-4444720-inventorytracking-docker-init/) | InventoryTracking — build 4444720 — preflight réussi, initialisation conteneur bloquée; 4444700/4444703 annulés avant JMeter | 2 | — |
| [`build-4444887-inventorytracking-container-replay-20260908/`](build-4444887-inventorytracking-container-replay-20260908/) | InventoryTracking — build 4444887 — conteneurs initialisés, package staging absent; Cur/Fix sans JMeter | 4 | — |
| [`build-4444887-inventorytracking-platformdeploy-review-20260908/`](build-4444887-inventorytracking-platformdeploy-review-20260908/) | Revue transport PlatformDeploy — build 4444887; contrat JFrog, package Build non transporté | 2 | — |
| [`build-5037140-inventorytracking-transport-review-20260908/`](build-5037140-inventorytracking-transport-review-20260908/) | InventoryTracking — revue transport PlatformDeploy / PipelineArtifact 5037140; patch encore absent | 2 | — |
| [`../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-pipelineartifact-5037140-round6/`](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-pipelineartifact-5037140-round6/) | PipelineArtifact 5037140 — InventoryTracking local transport; quatre fichiers hashés et contrat ArtifactItem | 1 | — |
| [`build-5037140-inventorytracking-transport-review-round8/`](build-5037140-inventorytracking-transport-review-round8/) | Revue indépendante favorable du candidat concret; tests positifs/négatifs et hashes exacts | 1 | — |
| [`build-5037140-inventorytracking-transport-round9/`](build-5037140-inventorytracking-transport-round9/) | Correction sourceBuildId/artifactName, tests de rejet et hashes du candidat relu | 1 | — |
| [`build-5037140-inventorytracking-transport-round10/`](build-5037140-inventorytracking-transport-round10/) | Push REST arrêté par VS403660 CreateBranch; hashes/tests et absence de mutation consignés | 1 | — |
| [`local-2026-09-08-inventorytracking-transport-tests-round7/`](local-2026-09-08-inventorytracking-transport-tests-round7/) | Fixtures et tests indépendants du contrat ArtifactItem; logique de sélection/validation, pas exécution conteneurisée | 4 | — |
| [`../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-candidate-round7/`](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-candidate-round7/) | Candidat transport local round7; tests locaux opérateur annoncés PASS, revue indépendante attendue | 1 | — |
| [`local-2026-09-08-inventorytracking-transport-review-round8/`](local-2026-09-08-inventorytracking-transport-review-round8/) | Revue patch transport round8; tests PASS, défaut `BuildId`/artifact identifié | 2 | — |
| [`../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-contract-round5/`](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-contract-round5/) | InventoryTracking — contrat de transport du package Build — round 5; PipelineArtifact présent, entrée locale absente | 1 | — |
| [`build-4444720-inventorytracking-review-correction-20260908/`](build-4444720-inventorytracking-review-correction-20260908/) | Complément daté — rectification 4444720 et périmètre PR InventoryTracking | 2 | — |
| [`2026-09-07-brain-reprise-worker1-round7/`](2026-09-07-brain-reprise-worker1-round7/) | Portée | 7 | — |
| [`2026-09-07-brain-reprise-worker1-round8/`](2026-09-07-brain-reprise-worker1-round8/) | Résultat | 9 | — |
| [`2026-09-07-brain-reprise-worker1-round9/`](2026-09-07-brain-reprise-worker1-round9/) | FACT | 10 | 3 fich. / 2.4 Mo |
| [`2026-09-07-brain-reprise-worker2/`](2026-09-07-brain-reprise-worker2/) | InventoryTracking — correctif XmlDiff, reprise Worker 2 | 3 | — |
| [`2026-09-07-brain-reprise-worker2-round10/`](2026-09-07-brain-reprise-worker2-round10/) | Round 10 — couverture effective des triggers Full-Text | 2 | — |
| [`2026-09-07-brain-reprise-worker2-round11/`](2026-09-07-brain-reprise-worker2-round11/) | Worker 2 — Full-Text Round 11 | 2 | — |
| [`2026-09-07-brain-reprise-worker2-round12/`](2026-09-07-brain-reprise-worker2-round12/) | Worker 2 — Full-Text probe correction and rerun | 2 | — |
| [`2026-09-07-brain-reprise-worker2-round13/`](2026-09-07-brain-reprise-worker2-round13/) | Worker 2 — Full-Text population diagnosis | 9 | — |
| [`2026-09-07-brain-reprise-worker2-round14/`](2026-09-07-brain-reprise-worker2-round14/) | Consolidated handoff — Worker 2, round 14 | 2 | — |
| [`2026-09-07-brain-reprise-worker2-round2/`](2026-09-07-brain-reprise-worker2-round2/) | InventoryTracking — reprise Worker 2 round 2 | 2 | — |
| [`2026-09-07-brain-reprise-worker2-round3/`](2026-09-07-brain-reprise-worker2-round3/) | SQL Full-Text validation — Worker 2 round 3 | 5 | — |
| [`2026-09-07-brain-reprise-worker2-round4/`](2026-09-07-brain-reprise-worker2-round4/) | WI-2222897 — SQL Full-Text — reprise worker2 round4 | 7 | — |
| [`2026-09-07-brain-reprise-worker2-round6/`](2026-09-07-brain-reprise-worker2-round6/) | WI-2222897 — Round 6 read-only cross-check | 2 | — |
| [`2026-09-07-brain-reprise-worker2-round7/`](2026-09-07-brain-reprise-worker2-round7/) | Round 7 — vérification différentielle PlatformDeploy et réconciliation InventoryTracking | 2 | — |
| [`2026-09-07-brain-reprise-worker2-round8/`](2026-09-07-brain-reprise-worker2-round8/) | Round 8 — test réel init-container.ps1 | 3 | — |
| [`2026-09-07-brain-reprise-worker2-round9/`](2026-09-07-brain-reprise-worker2-round9/) | Round 9 — Full-Text branche sandbox et arrêt avant push | 2 | — |
| [`2026-09-07-brain-reprise-worker3/`](2026-09-07-brain-reprise-worker3/) | Collecte Clienteling — reprise Worker 3 — 2026-09-07 | 4 | — |
| [`2026-09-07-clienteling-endpoint-packaging-worker2-round1/`](2026-09-07-clienteling-endpoint-packaging-worker2-round1/) | Audit Clienteling endpoints/packaging — Worker 2 round 1 | 3 | — |
| [`2026-09-07-clienteling-products-support-worker2-round2/`](2026-09-07-clienteling-products-support-worker2-round2/) | Audit borné du support Products Clienteling — Worker 2 round 2 | 3 | — |
| [`2026-09-07-clienteling-products-support-worker2-round3/`](2026-09-07-clienteling-products-support-worker2-round3/) | Audit distant Products Clienteling — Worker 2 round 3 | 3 | — |
| [`2026-09-07-inventorytracking-local-xmldiff-validation/`](2026-09-07-inventorytracking-local-xmldiff-validation/) | — | 1 | 2 fich. / 3.4 Mo |
| [`2026-09-07-inventorytracking-worker1-offline-review/`](2026-09-07-inventorytracking-worker1-offline-review/) | Revue offline worker 1 — InventoryTracking / XmlDiff | 3 | — |
| [`2026-09-07-jfrog-v22-packaging/`](2026-09-07-jfrog-v22-packaging/) | JFrog V22 — synthèse des lectures du 2026-09-07 | 1 | — |
| [`2026-09-07-jfrog-v22-packaging-revalidation/`](2026-09-07-jfrog-v22-packaging-revalidation/) | Revalidation JFrog du packaging V22 — 2026-09-07 | 1 | — |
| [`2026-09-07-sql-fulltext-build-4442685/`](2026-09-07-sql-fulltext-build-4442685/) | SQL Full-Text runtime — build 4442685 | 3 | — |
| [`2026-09-07-sql-fulltext-build-4442685-recovery-round2/`](2026-09-07-sql-fulltext-build-4442685-recovery-round2/) | Récupération logs Full-Text — 4442685 et 4442156 | 3 | — |
| [`2026-09-07-sql-fulltext-build-4442685-recovery-round3/`](2026-09-07-sql-fulltext-build-4442685-recovery-round3/) | Voies officielles de téléchargement — Full-Text 4442685 | 2 | — |
| [`2026-09-07-v22-authorization-delta-worker2-round2/`](2026-09-07-v22-authorization-delta-worker2-round2/) | FrenchTaxesRules V22 — delta d'autorisation binaire/contrat, Worker 2 round 2 | 1 | — |
| [`2026-09-07-v22-candidate-corrections-worker2-round2/`](2026-09-07-v22-candidate-corrections-worker2-round2/) | Corrections locales vérifiées — FrenchTaxesRules V22 | 1 | — |
| [`2026-09-07-v22-candidate-review-worker2-round3/`](2026-09-07-v22-candidate-review-worker2-round3/) | Revue indépendante round 3 — FrenchTaxesRules V22 | 1 | — |
| [`2026-09-07-v22-candidate-review-worker2-round3-revalidation/`](2026-09-07-v22-candidate-review-worker2-round3-revalidation/) | Revalidation round 3 — FrenchTaxesRules V22 | 1 | — |
| [`2026-09-07-v22-candidate-review-worker2-round4/`](2026-09-07-v22-candidate-review-worker2-round4/) | Revue indépendante du candidat FrenchTaxesRules V22 — Worker 2 round 4 | 1 | — |
| [`2026-09-07-v22-candidate-review-worker2-round5/`](2026-09-07-v22-candidate-review-worker2-round5/) | Revue finale du candidat V22 — Worker 2 round 5 | 1 | — |
| [`2026-09-07-v22-candidate-review-worker2-round6/`](2026-09-07-v22-candidate-review-worker2-round6/) | Revue du préflight candidat V22 — Worker 2 round 6 | 1 | — |
| [`2026-09-07-v22-host-isolation-producer-worker2-round8/`](2026-09-07-v22-host-isolation-producer-worker2-round8/) | Producteur hôte d’attestation d’isolation V22 — Worker 2 round 8 | 1 | — |
| [`2026-09-07-v22-isolation-audit-worker2-round10/`](2026-09-07-v22-isolation-audit-worker2-round10/) | Revue locale — isolation FrenchTaxesRules V22 | 1 | — |
| [`2026-09-07-v22-isolation-guard-worker2-round7/`](2026-09-07-v22-isolation-guard-worker2-round7/) | Garde-fou d’isolation V22 — Worker 2 round 7 | 1 | — |
| [`2026-09-07-v22-isolation-policy-worker2-round9/`](2026-09-07-v22-isolation-policy-worker2-round9/) | Politique d’isolation V22 — Worker 2 round 9 | 1 | — |
| [`2026-09-07-v22-isolation-review-worker2-round6/`](2026-09-07-v22-isolation-review-worker2-round6/) | Revue isolation V22 — Worker 2 round 6 | 1 | — |
| [`2026-09-07-v22-live-prereqs-worker2-round1/`](2026-09-07-v22-live-prereqs-worker2-round1/) | FrenchTaxesRules V22 — vérification des prérequis live, Worker 2 round 1 | 1 | — |
| [`2026-09-07-v22-readiness-worker2-round1/`](2026-09-07-v22-readiness-worker2-round1/) | Revue indépendante de readiness — FrenchTaxesRules V22 | 1 | — |
| [`2026-09-07-v22-replay-decision-worker2-round4/`](2026-09-07-v22-replay-decision-worker2-round4/) | Décision de rejeu V22 — revue Worker 2 round 4 | 1 | — |
| [`2026-09-07-v22-replay-decision-worker2-round5/`](2026-09-07-v22-replay-decision-worker2-round5/) | Décision V22 — validation finale du candidat local | 1 | — |
| [`2026-09-07-v22-replay-prereqs/`](2026-09-07-v22-replay-prereqs/) | Prérequis artefacts/données rejeu FrenchTaxesRules V22 — 2026-09-07 | 1 | — |
| [`2026-09-07-v22-runtime-contract-worker2-round11/`](2026-09-07-v22-runtime-contract-worker2-round11/) | Collecte ciblée — contrat runtime V22 | 1 | — |
| [`Pipelines_Templates/`](Pipelines_Templates/) | — | 1 | — |
| [`azure-devops-2026-09-07-allowedmodule-projection/`](azure-devops-2026-09-07-allowedmodule-projection/) | Preuve Azure DevOps — projection `allowedModule` (2026-09-07) | 1 | — |
| [`azure-devops-api-console-publication-access-blocker/`](azure-devops-api-console-publication-access-blocker/) | Accès publication API → Console → migration — blocage de permission | 1 | — |
| [`azure-devops-api-console-publication-worker1-round1/`](azure-devops-api-console-publication-worker1-round1/) | Publication API → Console → migration — Worker 1 round 1 — blocage d’accès | 1 | — |
| [`azure-devops-french-taxes-rules-v22-exact-yaml-44070560/`](azure-devops-french-taxes-rules-v22-exact-yaml-44070560/) | — | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round10/`](azure-devops-french-taxes-rules-v22-worker1-round10/) | Préflight ACR V22 corrigé — Worker 1 round 10 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round11/`](azure-devops-french-taxes-rules-v22-worker1-round11/) | Correction provenance préflight V22 — Worker 1 round 11 | 1 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round12/`](azure-devops-french-taxes-rules-v22-worker1-round12/) | Préflight V22 corrigé et migration de branche neutre — Worker 1 round 12 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round13/`](azure-devops-french-taxes-rules-v22-worker1-round13/) | Préflight V22 — attestation runtime round 13 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round14/`](azure-devops-french-taxes-rules-v22-worker1-round14/) | Diagnostic V22 — run 4442178 et provenance — Worker 1 round 14 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round15/`](azure-devops-french-taxes-rules-v22-worker1-round15/) | — | 1 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round16/`](azure-devops-french-taxes-rules-v22-worker1-round16/) | V22 preflight diagnostic — run 4442225 | 1 | 1 fich. / 0.0 Mo |
| [`azure-devops-french-taxes-rules-v22-worker1-round19/`](azure-devops-french-taxes-rules-v22-worker1-round19/) | V22 mount provenance diagnosis — run 4442225 | 1 | 1 fich. / 0.0 Mo |
| [`azure-devops-french-taxes-rules-v22-worker1-round2/`](azure-devops-french-taxes-rules-v22-worker1-round2/) | Azure DevOps read-only — FrenchTaxesRules V22 — Worker 1 round 2 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round20/`](azure-devops-french-taxes-rules-v22-worker1-round20/) | V22 preflight patch — scrubbed mount projection | 3 | 1 fich. / 0.0 Mo |
| [`azure-devops-french-taxes-rules-v22-worker1-round21/`](azure-devops-french-taxes-rules-v22-worker1-round21/) | V22 diagnostic patch against exact YAML | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round22/`](azure-devops-french-taxes-rules-v22-worker1-round22/) | V22 Azure DevOps TLS diagnostic | 1 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round23/`](azure-devops-french-taxes-rules-v22-worker1-round23/) | V22 Python HTTPS and Azure DevOps revalidation | 1 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round24/`](azure-devops-french-taxes-rules-v22-worker1-round24/) | V22 run 4442696 — timeout-bound follow-up | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round25/`](azure-devops-french-taxes-rules-v22-worker1-round25/) | V22 run 4442696 — final runtime preflight | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round26/`](azure-devops-french-taxes-rules-v22-worker1-round26/) | V22 mount count comparison — 44070560 vs 68f1f7a8 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round3/`](azure-devops-french-taxes-rules-v22-worker1-round3/) | Azure DevOps provenance — FrenchTaxesRules V22 — Worker 1 round 3 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round4/`](azure-devops-french-taxes-rules-v22-worker1-round4/) | V22 candidate artifacts and provenance — Worker 1 round 4 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round5/`](azure-devops-french-taxes-rules-v22-worker1-round5/) | V22 baseline packages and historical image — Worker 1 round 5 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round6/`](azure-devops-french-taxes-rules-v22-worker1-round6/) | Revue séquentielle de la préparation V22 — round 5 | 1 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round7/`](azure-devops-french-taxes-rules-v22-worker1-round7/) | Préflight runtime V22 isolé — Worker 1 round 7 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round8/`](azure-devops-french-taxes-rules-v22-worker1-round8/) | Diagnostic référence image 4441719 — Worker 1 round 8 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker1-round9/`](azure-devops-french-taxes-rules-v22-worker1-round9/) | Résolution du registry ACR — diagnostic 4441719 — Worker 1 round 9 | 2 | — |
| [`azure-devops-french-taxes-rules-v22-worker2-round3/`](azure-devops-french-taxes-rules-v22-worker2-round3/) | Worker 2 round 3 — V22 null-safe candidate | 4 | 1 fich. / 0.0 Mo |
| [`azure-devops-french-taxes-rules-v22-worker2-round4/`](azure-devops-french-taxes-rules-v22-worker2-round4/) | Worker 2 round 4 — V22 hash reconciliation | 2 | — |
| [`azure-devops-inventorytracking-2026-09-07-worker2/`](azure-devops-inventorytracking-2026-09-07-worker2/) | Collecte Azure DevOps — InventoryTracking/master — worker 2 | 3 | — |
| [`azure-devops-inventorytracking-2026-09-07-worker2-round2/`](azure-devops-inventorytracking-2026-09-07-worker2-round2/) | InventoryTracking XmlDiff — collecte worker 2, round 2 | 4 | — |
| [`azure-devops-inventorytracking-4434070-blocked/`](azure-devops-inventorytracking-4434070-blocked/) | InventoryTracking master — build 4434070 — collecte bornée | 2 | — |
| [`build-4426342/`](build-4426342/) | — | 0 | 585 fich. / 46.8 Mo |
| [`build-4429167/`](build-4429167/) | — | 0 | 798 fich. / 92.6 Mo |
| [`build-4429629/`](build-4429629/) | — | 0 | 618 fich. / 53.4 Mo |
| [`build-4432510/`](build-4432510/) | — | 0 | 546 fich. / 34.5 Mo |
| [`build-4432554/`](build-4432554/) | — | 0 | 4031 fich. / 257.1 Mo |
| [`build-4432602/`](build-4432602/) | — | 0 | 3842 fich. / 290.9 Mo |
| [`build-4432652/`](build-4432652/) | — | 0 | 3818 fich. / 251.3 Mo |
| [`build-4432672/`](build-4432672/) | — | 0 | 4027 fich. / 256.8 Mo |
| [`fulltext/`](fulltext/) | — | 1 | — |
| [`legacy/`](legacy/) | Preuves legacy collectées | 956 | 16031 fich. / 1188.5 Mo |
| [`legacy-build-4427434/`](legacy-build-4427434/) | — | 1 | 1 fich. / 0.7 Mo |
| [`legacy-build-4429170/`](legacy-build-4429170/) | — | 24 | 10 fich. / 0.0 Mo |
| [`legacy-build-4429632/`](legacy-build-4429632/) | — | 7 | 1 fich. / 0.1 Mo |
| [`legacy-build-4432288/`](legacy-build-4432288/) | — | 8 | 1 fich. / 0.7 Mo |
| [`legacy-build-4432320/`](legacy-build-4432320/) | — | 6 | 1 fich. / 0.7 Mo |
| [`legacy-build-4432365/`](legacy-build-4432365/) | — | 6 | 1 fich. / 0.7 Mo |
| [`legacy-build-4432395/`](legacy-build-4432395/) | — | 1 | 2 fich. / 1.4 Mo |
| [`legacy-build-4432556/`](legacy-build-4432556/) | — | 11 | 1 fich. / 0.0 Mo |
| [`legacy-build-4432608/`](legacy-build-4432608/) | — | 22 | 6 fich. / 0.0 Mo |
| [`legacy-build-4432653/`](legacy-build-4432653/) | — | 11 | 1 fich. / 0.0 Mo |
| [`legacy-build-4432675/`](legacy-build-4432675/) | — | 11 | 1 fich. / 0.0 Mo |
| [`legacy-build-4436133/`](legacy-build-4436133/) | — | 1 | 1 fich. / 0.7 Mo |
| [`local-2026-09-06-api-build-candidate/`](local-2026-09-06-api-build-candidate/) | Compilation API corrigée — candidat local | 3 | 17 fich. / 0.7 Mo |
| [`local-2026-09-06-api-build-candidate-facades/`](local-2026-09-06-api-build-candidate-facades/) | Compilation API avec façades net452 | 3 | 19 fich. / 0.7 Mo |
| [`local-2026-09-06-api-build-dependencies/`](local-2026-09-06-api-build-dependencies/) | Dépendances API — collecte isolée | 2 | 398 fich. / 132.1 Mo |
| [`local-2026-09-06-api-build-net452-complete/`](local-2026-09-06-api-build-net452-complete/) | Compilation API — façades net452 complètes | 7 | 153 fich. / 4.9 Mo |
| [`local-2026-09-06-api-jmx-date-before-after/`](local-2026-09-06-api-jmx-date-before-after/) | Comparaison API originale / corrigée — EscapeJdbcDate | 14 | 190 fich. / 6.2 Mo |
| [`local-2026-09-06-api-jmx-date-candidate/`](local-2026-09-06-api-jmx-date-candidate/) | Génération JMX — fixtures EscapeJdbcDate | 5 | 26 fich. / 1.0 Mo |
| [`local-2026-09-06-console-build-date-candidate/`](local-2026-09-06-console-build-date-candidate/) | Candidat de compilation Console — EscapeJdbcDate | 4 | 77 fich. / 2.2 Mo |
| [`local-2026-09-06-console-dependencies-aligned/`](local-2026-09-06-console-dependencies-aligned/) | Dépendances Console alignées — vérification sans compilation | 4 | 142 fich. / 7.0 Mo |
| [`local-2026-09-06-console-jmx-date-before-after/`](local-2026-09-06-console-jmx-date-before-after/) | Console officielle — comparaison API originale/corrigée | 10 | 48 fich. / 1.7 Mo |
| [`local-2026-09-06-console-quick-diagnosis/`](local-2026-09-06-console-quick-diagnosis/) | Diagnostic rapide Console — 2026-09-06 | 15 | 66 fich. / 1.2 Mo |
| [`local-2026-09-06-escape-jdbc-date/`](local-2026-09-06-escape-jdbc-date/) | Reproduction locale — EscapeJdbcDate — 2026-09-06 | 4 | — |
| [`local-2026-09-06-escape-jdbc-date-applied/`](local-2026-09-06-escape-jdbc-date-applied/) | Correctif local appliqué — EscapeJdbcDate — 2026-09-06 | 10 | — |
| [`local-2026-09-06-escape-jdbc-date-candidate/`](local-2026-09-06-escape-jdbc-date-candidate/) | Candidat local — EscapeJdbcDate — 2026-09-06 | 6 | — |
| [`local-2026-09-06-export-complete-before-after/`](local-2026-09-06-export-complete-before-after/) | Export_Run complet — comparaison avant/après — 2026-09-06 | 4 | 8 fich. / 0.7 Mo |
| [`local-2026-09-06-export-complete-blocked/`](local-2026-09-06-export-complete-blocked/) | Préparation Export_Run complète — blocage — 2026-09-06 | 2 | — |
| [`local-2026-09-06-export-run-business-replay-prep/`](local-2026-09-06-export-run-business-replay-prep/) | Préparation du rejeu métier Export_Run TC08–TC10 — 2026-09-06 | 1 | — |
| [`local-2026-09-06-export-run-tc08-tc10-before-after-blocked/`](local-2026-09-06-export-run-tc08-tc10-before-after-blocked/) | Export_Run avant/après — blocage de complétude — 2026-09-06 | 2 | — |
| [`local-2026-09-06-export-run-tc08-tc10-prep/`](local-2026-09-06-export-run-tc08-tc10-prep/) | Préparation Export_Run TC08–TC10 — 2026-09-06 | 2 | — |
| [`local-2026-09-06-reference-resolution/`](local-2026-09-06-reference-resolution/) | Résolution des références — preuve isolée | 2 | 314 fich. / 14.7 Mo |
| [`local-2026-09-06-v26-fix-4432510-identification/`](local-2026-09-06-v26-fix-4432510-identification/) | Build 4432510 — image, backup et entrée JMX | 1 | — |
| [`local-2026-09-06-v26-fix-4432510-image-data/`](local-2026-09-06-v26-fix-4432510-image-data/) | Build 4432510 — sélection image et données initiales | 1 | — |
| [`local-2026-09-06-v26-fix-jmx-consumption-review/`](local-2026-09-06-v26-fix-jmx-consumption-review/) | Chaîne de consommation JMX Export_Run — revue locale | 1 | — |
| [`local-2026-09-06-v26-fix-jmx-xpath-reproduction/`](local-2026-09-06-v26-fix-jmx-xpath-reproduction/) | Reproduction locale de la sélection XPath du runner | 2 | — |
| [`local-2026-09-06-v26-fix-replay-draft/`](local-2026-09-06-v26-fix-replay-draft/) | Brouillon local de pipeline isolé — WI-2222897 | 11 | 1 fich. / 0.0 Mo |
| [`local-2026-09-06-v26-fix-replay-plan/`](local-2026-09-06-v26-fix-replay-plan/) | Plan de rejeu isolé — FrenchTaxesRules V26 Fix | 1 | — |
| [`local-2026-09-06-v26-fix-replay-prereqs/`](local-2026-09-06-v26-fix-replay-prereqs/) | Prérequis du rejeu FrenchTaxesRules V26 Fix | 1 | — |
| [`local-2026-09-06-v26-fix-replay-review/`](local-2026-09-06-v26-fix-replay-review/) | Revue documentaire du brouillon V26 Fix — WI-2222897 | 1 | — |
| [`local-2026-09-06-xmldiffpatch-view-resolution/`](local-2026-09-06-xmldiffpatch-view-resolution/) | Résolution XmlDiffPatch.View — artefact Console officiel | 2 | 5 fich. / 0.2 Mo |
| [`local-2026-09-07-allowedmodule-scope-audit/`](local-2026-09-07-allowedmodule-scope-audit/) | Audit local des scopes `allowedModule` — FrenchTaxesRules V22 | 1 | — |
| [`local-2026-09-07-api-build-fix-sql-unicode/`](local-2026-09-07-api-build-fix-sql-unicode/) | — | 4 | 24 fich. / 1.5 Mo |
| [`local-2026-09-07-api-jmx-unicode/`](local-2026-09-07-api-jmx-unicode/) | Génération intégrée JMX — FixSqlUnicodeValue | 3 | 52 fich. / 2.1 Mo |
| [`local-2026-09-07-cleanxpath/`](local-2026-09-07-cleanxpath/) | CleanXpath — validation locale | 6 | 24 fich. / 1.5 Mo |
| [`local-2026-09-07-cleanxpath-integrated/`](local-2026-09-07-cleanxpath-integrated/) | — | 0 | 27 fich. / 1.0 Mo |
| [`local-2026-09-07-clienteling-endpoint-metadata-round10/`](local-2026-09-07-clienteling-endpoint-metadata-round10/) | Clienteling endpoint metadata correction — 2026-09-07 | 2 | 2 fich. / 0.0 Mo |
| [`local-2026-09-07-clienteling-endpoint-metadata-round11/`](local-2026-09-07-clienteling-endpoint-metadata-round11/) | Clienteling endpoint JMX generation — 2026-09-07 | 2 | 7 fich. / 0.3 Mo |
| [`local-2026-09-07-console-package-migration-isolated/`](local-2026-09-07-console-package-migration-isolated/) | Console package -> migration isolée | 1 | 32 fich. / 1.4 Mo |
| [`local-2026-09-07-fix-sql-unicode/`](local-2026-09-07-fix-sql-unicode/) | FixSqlUnicodeValue — validation offline | 3 | — |
| [`local-2026-09-07-four-plans-integrated/`](local-2026-09-07-four-plans-integrated/) | Quatre plans legacy — génération Console intégrée | 1 | 10 fich. / 12.2 Mo |
| [`local-2026-09-07-french-taxes-rules-v22-authorization-handoff/`](local-2026-09-07-french-taxes-rules-v22-authorization-handoff/) | Handoff manuel — piste framework d'autorisation FrenchTaxesRules V22 | 2 | — |
| [`local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/`](local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/) | Handoff manuel — correctif XmlDiff InventoryTracking et run Azure DevOps réel revendiqué | 3 | — |
| [`local-2026-09-07-jmeter-5-6-3-xpath-offline/`](local-2026-09-07-jmeter-5-6-3-xpath-offline/) | Vérification JMeter 5.6.3 — XPathAssertion offline | 7 | 6 fich. / 86.4 Mo |
| [`local-2026-09-07-migration-chain-isolated-round9/`](local-2026-09-07-migration-chain-isolated-round9/) | Chaîne de génération migration isolée — Round 9 | 2 | 1 fich. / 0.0 Mo |
| [`local-2026-09-07-package-fixsqlunicode-postcondition/`](local-2026-09-07-package-fixsqlunicode-postcondition/) | Postcondition FixSqlUnicodeValue dans l'API package — 2026-09-07 | 1 | 2 fich. / 0.0 Mo |
| [`local-2026-09-07-remove-special-chars/`](local-2026-09-07-remove-special-chars/) | RemoveSpecialCharsForXQuery — validation locale | 5 | 24 fich. / 1.5 Mo |
| [`local-2026-09-07-soap-namespace-aware-round13/`](local-2026-09-07-soap-namespace-aware-round13/) | Lot local — correctif générateur SOAP namespace-aware | 7 | 47 fich. / 1.6 Mo |
| [`local-2026-09-07-soap-negative-generated/`](local-2026-09-07-soap-negative-generated/) | — | 3 | 39 fich. / 1.0 Mo |
| [`local-2026-09-07-soap-negative-jmeter56/`](local-2026-09-07-soap-negative-jmeter56/) | — | 2 | 5 fich. / 0.0 Mo |
| [`local-2026-09-07-soap-package-round14/`](local-2026-09-07-soap-package-round14/) | — | 3 | 128 fich. / 6.2 Mo |
| [`local-2026-09-07-soap-xpath-negative-validation-handoff/`](local-2026-09-07-soap-xpath-negative-validation-handoff/) | Handoff manuel — validation positive/négative SOAP XPath + packaging | 3 | — |
| [`local-2026-09-07-sql-fulltext-build-4442254/`](local-2026-09-07-sql-fulltext-build-4442254/) | — | 0 | — |
| [`local-2026-09-07-sql-fulltext-patch-review-round5/`](local-2026-09-07-sql-fulltext-patch-review-round5/) | Revue locale du patch diagnostic Full-Text — round5 | 3 | — |
| [`local-2026-09-07-sql-fulltext-round12/`](local-2026-09-07-sql-fulltext-round12/) | SQL Full-Text preparation — 2026-09-07 | 2 | — |
| [`local-2026-09-07-sql-fulltext-round15/`](local-2026-09-07-sql-fulltext-round15/) | SQL Full-Text — reprise round15 (2026-09-07) | 1 | — |
| [`local-2026-09-07-sql-fulltext-round2-terminal-2026-09-07/`](local-2026-09-07-sql-fulltext-round2-terminal-2026-09-07/) | SQL Full-Text — terminal build 4442156 (2026-09-07) | 1 | — |
| [`local-2026-09-07-sql-fulltext-round3-terminal-4442254/`](local-2026-09-07-sql-fulltext-round3-terminal-4442254/) | SQL Full-Text — diagnostic terminal round3 (2026-09-07) | 1 | — |
| [`local-2026-09-07-sql-fulltext-round4-artifact-retrieval/`](local-2026-09-07-sql-fulltext-round4-artifact-retrieval/) | SQL Full-Text — artefact retrieval round4 (2026-09-07) | 1 | — |
| [`local-2026-09-07-v26-fix-export-run-contract/`](local-2026-09-07-v26-fix-export-run-contract/) | Contrat offline Export_Run vers JMX corrigé | 3 | 2 fich. / 0.4 Mo |
| [`local-2026-09-07-v26-fix-replay-draft-hardened/`](local-2026-09-07-v26-fix-replay-draft-hardened/) | Brouillon local de pipeline isolé — WI-2222897 | 14 | 7 fich. / 1.4 Mo |
| [`local-2026-09-07-worker1-french-taxes-rules-v22-authorization/`](local-2026-09-07-worker1-french-taxes-rules-v22-authorization/) | Collecte Worker 1 — FrenchTaxesRules V22 autorisation / DLL | 18 | 232 fich. / 63.0 Mo |
| [`local-2026-09-07-xpath-engine-semantics/`](local-2026-09-07-xpath-engine-semantics/) | Sémantique XPath — contrôle local | 1 | 2 fich. / 0.0 Mo |
| [`manifests/`](manifests/) | — | 0 | — |
| [`packages-current/`](packages-current/) | — | 0 | 2 fich. / 0.5 Mo |
| [`packages-extracted/`](packages-extracted/) | — | 0 | 50 fich. / 1.9 Mo |
| [`run-4447425-4447508-reprise-azdo-2026-09-08/`](run-4447425-4447508-reprise-azdo-2026-09-08/) | Reprise directe Azure DevOps — InventoryTracking, FrenchTaxesRules et Clienteling | 7 | — |
| [`local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/`](local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/) | Audit BW3 et leçons FrenchTaxesRules V26 — exécution JMeter réelle rapportée (build 4448787) | 4 | — |
| [`local-2026-09-09-clienteling-v26-generatejmx-testcampaign/`](local-2026-09-09-clienteling-v26-generatejmx-testcampaign/) | Clienteling V26 — GenerateJmx débloqué (Product.Version, BuildPlatform, OutputFiles, TestCampaign) | 3 | — |
| [`local-2026-09-09-attestation-campagne-round4/`](local-2026-09-09-attestation-campagne-round4/) | Attestation de campagne round 4 (4 builds) et gabarit de transport local — collecteur bw hors dépôt | 21 | 4 fich. / 7.4 Mo |
| [`local-2026-09-09-frenchtaxesrules-v26-synthese-technique/`](local-2026-09-09-frenchtaxesrules-v26-synthese-technique/) | Synthèse technique FrenchTaxesRules V26 — run 4452790 et correctifs rapportés | 1 | source Downloads |
| [`local-2026-09-09-clienteling-v26-replay/`](local-2026-09-09-clienteling-v26-replay/) | Synthèse technique Clienteling V26 — replay jusqu'au téléchargement JFrog, run 4452826 | 2 | — |
| [`local-2026-09-10-frenchtaxesrules-v22-v23-validation/`](local-2026-09-10-frenchtaxesrules-v22-v23-validation/) | Synthèse technique FrenchTaxesRules V22/V23 — validation de packaging rapportée et blocage V23 avant JMeter | 1 | — |
| [`local-2026-09-11-frenchtaxesrules-legacy-log-recovery/`](local-2026-09-11-frenchtaxesrules-legacy-log-recovery/) | FrenchTaxesRules — récupération des logs Legacy du run 4459782, exécution MSTest rapportée non démarrée | 2 | — |
| [`local-2026-09-11-legacy-jfrog-cross-vm-symptom/`](local-2026-09-11-legacy-jfrog-cross-vm-symptom/) | Complément de portée — symptôme JFrog Legacy rapporté sur PG2 et PG3, script commun `Artifactory_fct.ps1` | 1 | — |

## Total

184 dossiers, dont 69 contiennent des artefacts bruts restés hors du dépôt (2946.7 Mo au total). Les
deux dossiers `local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/` et
`local-2026-09-09-clienteling-v26-generatejmx-testcampaign/`, créés après la régénération de cet index
du 2026-09-08, n'y avaient encore jamais été listés ; ajoutés ici avec `local-2026-09-09-attestation-campagne-round4/`.

## Dossiers à retitrer (43)

Le `README.md` de ces dossiers ne commence pas par un titre décrivant le sujet (titre absent, ou premier titre réduit à `FACT`). Le contenu n'est pas en cause : seul le titre manque, ce qui les rend invisibles à toute recherche par sujet. Corriger le premier titre du README suffit, sans renommer le dossier.

- [`2026-09-07-azure-devops-inventorytracking-4434070/`](2026-09-07-azure-devops-inventorytracking-4434070/) — titre actuel : `—`
- [`2026-09-07-brain-reprise-worker1-round10/`](2026-09-07-brain-reprise-worker1-round10/) — titre actuel : `FACT`
- [`2026-09-07-brain-reprise-worker1-round11/`](2026-09-07-brain-reprise-worker1-round11/) — titre actuel : `FACT — reconciliation`
- [`2026-09-07-brain-reprise-worker1-round12/`](2026-09-07-brain-reprise-worker1-round12/) — titre actuel : `FACT`
- [`2026-09-07-brain-reprise-worker1-round13/`](2026-09-07-brain-reprise-worker1-round13/) — titre actuel : `FACT`
- [`2026-09-07-brain-reprise-worker1-round14/`](2026-09-07-brain-reprise-worker1-round14/) — titre actuel : `FACT`
- [`2026-09-07-brain-reprise-worker1-round7/`](2026-09-07-brain-reprise-worker1-round7/) — titre actuel : `Portée`
- [`2026-09-07-brain-reprise-worker1-round8/`](2026-09-07-brain-reprise-worker1-round8/) — titre actuel : `Résultat`
- [`2026-09-07-brain-reprise-worker1-round9/`](2026-09-07-brain-reprise-worker1-round9/) — titre actuel : `FACT`
- [`2026-09-07-inventorytracking-local-xmldiff-validation/`](2026-09-07-inventorytracking-local-xmldiff-validation/) — titre actuel : `—`
- [`Pipelines_Templates/`](Pipelines_Templates/) — titre actuel : `—`
- [`azure-devops-french-taxes-rules-v22-exact-yaml-44070560/`](azure-devops-french-taxes-rules-v22-exact-yaml-44070560/) — titre actuel : `—`
- [`azure-devops-french-taxes-rules-v22-worker1-round15/`](azure-devops-french-taxes-rules-v22-worker1-round15/) — titre actuel : `—`
- [`build-4426342/`](build-4426342/) — titre actuel : `—`
- [`build-4429167/`](build-4429167/) — titre actuel : `—`
- [`build-4429629/`](build-4429629/) — titre actuel : `—`
- [`build-4432510/`](build-4432510/) — titre actuel : `—`
- [`build-4432554/`](build-4432554/) — titre actuel : `—`
- [`build-4432602/`](build-4432602/) — titre actuel : `—`
- [`build-4432652/`](build-4432652/) — titre actuel : `—`
- [`build-4432672/`](build-4432672/) — titre actuel : `—`
- [`fulltext/`](fulltext/) — titre actuel : `—`
- [`legacy-build-4427434/`](legacy-build-4427434/) — titre actuel : `—`
- [`legacy-build-4429170/`](legacy-build-4429170/) — titre actuel : `—`
- [`legacy-build-4429632/`](legacy-build-4429632/) — titre actuel : `—`
- [`legacy-build-4432288/`](legacy-build-4432288/) — titre actuel : `—`
- [`legacy-build-4432320/`](legacy-build-4432320/) — titre actuel : `—`
- [`legacy-build-4432365/`](legacy-build-4432365/) — titre actuel : `—`
- [`legacy-build-4432395/`](legacy-build-4432395/) — titre actuel : `—`
- [`legacy-build-4432556/`](legacy-build-4432556/) — titre actuel : `—`
- [`legacy-build-4432608/`](legacy-build-4432608/) — titre actuel : `—`
- [`legacy-build-4432653/`](legacy-build-4432653/) — titre actuel : `—`
- [`legacy-build-4432675/`](legacy-build-4432675/) — titre actuel : `—`
- [`legacy-build-4436133/`](legacy-build-4436133/) — titre actuel : `—`
- [`local-2026-09-07-api-build-fix-sql-unicode/`](local-2026-09-07-api-build-fix-sql-unicode/) — titre actuel : `—`
- [`local-2026-09-07-cleanxpath-integrated/`](local-2026-09-07-cleanxpath-integrated/) — titre actuel : `—`
- [`local-2026-09-07-soap-negative-generated/`](local-2026-09-07-soap-negative-generated/) — titre actuel : `—`
- [`local-2026-09-07-soap-negative-jmeter56/`](local-2026-09-07-soap-negative-jmeter56/) — titre actuel : `—`
- [`local-2026-09-07-soap-package-round14/`](local-2026-09-07-soap-package-round14/) — titre actuel : `—`
- [`local-2026-09-07-sql-fulltext-build-4442254/`](local-2026-09-07-sql-fulltext-build-4442254/) — titre actuel : `—`
- [`manifests/`](manifests/) — titre actuel : `—`
- [`packages-current/`](packages-current/) — titre actuel : `—`
- [`packages-extracted/`](packages-extracted/) — titre actuel : `—`

## Règle de nommage pour la suite

La baseline Legacy locale `FrenchTaxesRules/master` 10.95 / build `4462232` est archivée dans
[`evidence/legacy/Y2_Plugins_FrenchTaxesRules/master/10.95-build-4462232/`](legacy/Y2_Plugins_FrenchTaxesRules/master/10.95-build-4462232/).
Elle contient les TRX Fix/Current, la trace complète du workflow, le contexte du run, un manifeste
et les empreintes SHA-256 ; voir [finding 026](../findings/026-frenchtaxesrules-legacy-baseline-4462232.md).

- [`local-2026-09-08-api-console-review-round3/`](local-2026-09-08-api-console-review-round3/) — Revue indépendante API→Console FrenchTaxesRules; API 4444765 confirmée, candidat Console rejeté car DLL API embarquée historique; 1 | —
- [`local-2026-09-08-console-2.0.43-build-4444888-round4/`](local-2026-09-08-console-2.0.43-build-4444888-round4/) — Revue du diff Console réel, correction puis réussite 4445025, nupkg/API embarquée rehashés; migration/JMX restent UNKNOWN; 3 | —
- [`build-4445025-jmx-generation/`](build-4445025-jmx-generation/) — Génération réelle Console 2.0.43 : Export_Run, DocumentSignature et périmètre source 19/19 code 0; manifeste strict 19/32; handoff V26; 19 | —
- [`local-2026-09-08-frenchtaxesrules-round7/`](local-2026-09-08-frenchtaxesrules-round7/) — Inventaire nominatif 19/19, origine prouvée du compteur fixe 32, métadonnées historiques backup/config et préflight V26 non lancé faute de références runtime résolues ; 2 | —
- [`local-2026-09-08-frenchtaxesrules-v26-preflight-round8/`](local-2026-09-08-frenchtaxesrules-v26-preflight-round8/) — YAML V26 publié sur définition dédiée 14265, build 4445476 : login/pull/digest OK, timeout Docker avant attestation et cleanup non prouvé ; 2 | —
- [`local-2026-09-08-clienteling-isolated-pipeline-round7/`](local-2026-09-08-clienteling-isolated-pipeline-round7/) — Contrat distant 14264 au commit b790767c, API 4444962/5037204, JMeter fixe; Console 803D et attestation cible manquants; 1 | —
- [`local-2026-09-08-clienteling-target-preflight-round8/`](local-2026-09-08-clienteling-target-preflight-round8/) — Diagnostic d’acquisition image/backup, restauration SQL et attestation Cur/Fix; agent local sans daemon Docker; 2 | —
- [`local-2026-09-08-clienteling-target-review-round9/`](local-2026-09-08-clienteling-target-review-round9/) — Revue indépendante : réseau/JMeter non raccordés, restauration SQL non suffisante, risque secret/ownership et préconditions Azure DevOps; 1 | —
- [`local-2026-09-08-clienteling-target-review-round10/`](local-2026-09-08-clienteling-target-review-round10/) — Scripts replay-prep corrigés pour probes Clienteling, raccordement JMeter privé et cleanup ownership; parse + tests négatifs; 1 | —
- [`local-2026-09-08-clienteling-target-review-round11/`](local-2026-09-08-clienteling-target-review-round11/) — Complétude YAML/PlatformDeploy : producteurs reçus, DataRoot, runtime et sidecar JMeter ajoutés au contrat sans queue; préconditions réelles manquantes; 1 | —
- [`local-2026-09-08-clienteling-14264-agent-diagnostic-round9/`](local-2026-09-08-clienteling-14264-agent-diagnostic-round9/) — Diagnostic distant borné du run 4445464/artefact 5037721 : agent privé identifié, Docker absent et aucun backup `.bak` sous le checkout; Build/Cur/Fix non lancés; 2 | —
- [`local-2026-09-08-clienteling-14264-agent-diagnostic-round10/`](local-2026-09-08-clienteling-14264-agent-diagnostic-round10/) — Diagnostic demandé sur 02-B : Docker absent actuellement; 4440884 prouve Docker/API 1.55 et image V26 sur 02-A à la date historique; source backup actuelle UNKNOWN; 2 | —
- [`local-2026-09-08-clienteling-14264-initialization-comparison-round11/`](local-2026-09-08-clienteling-14264-initialization-comparison-round11/) — Comparaison précise : Docker appartient aux jobs hébergés windows-2025 JMeter (queue 591), pas au job privé direct du diagnostic (queue 665); image/digest historiques prouvés, backup distinct UNKNOWN; 2 | —
- [`local-2026-09-08-syntheses-techniques-reprise-handoff/`](local-2026-09-08-syntheses-techniques-reprise-handoff/) — Trois synthèses techniques de pause reçues hors processus et rangées telles que reçues, avec empreintes : préflight V26 4446410 et branche de validation FrenchTaxesRules, run InventoryTracking 4445575 et perte de `002-Device:Reassign`, agent windows-2025 4446303 et backup Clienteling V26 absent de l'arbre Git. **Non revérifiées** : ouvrent les findings 015 et 016; 4 | —
- [`run-4447425-4447508-reprise-azdo-2026-09-08/`](run-4447425-4447508-reprise-azdo-2026-09-08/) — Reprise directe AzDO sans bw : exécution réelle InventoryTracking (run 4447425), résolution blocage Checkpoint.Authorization et exécution réelle FrenchTaxesRules (run 4447508), diagnostic attestation Clienteling; 1 | —
- [`local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/`](local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/) — Deux documents reçus rapportant l'audit BW3 (validateur, collecte LIVE) et l'exécution JMeter Cur/Fix réelle rapportée de FrenchTaxesRules V26 (build 4448787, 51 échecs communs); rapporté, non revérifié; 4 | —
- [`local-2026-09-09-clienteling-v26-generatejmx-testcampaign/`](local-2026-09-09-clienteling-v26-generatejmx-testcampaign/) — Document reçu rapportant le déblocage de GenerateJmx Clienteling V26 (Product.Version, BuildPlatform, OutputFiles, TestCampaign), aucun JMeter Cur/Fix revendiqué; rapporté, non revérifié; 3 | —
- [`local-2026-09-09-attestation-campagne-round4/`](local-2026-09-09-attestation-campagne-round4/) — Copie de la couche documentaire d'un collecteur bw round 4 (re-collecte fraîche des 4 builds 4447425/4440884/4445575/4432554, JMX Git haché au sourceVersion, cleanup requalifié UNKNOWN) et d'un gabarit candidat de transport local dérivé des findings 017/018; empreintes SHA-256 confrontées avec succès; rapporté, non revérifié; 21 | 4 fich. / 7.4 Mo
- [`local-2026-09-09-clienteling-v26-replay/`](local-2026-09-09-clienteling-v26-replay/) — Synthèse reçue rapportant la progression du replay Clienteling 14264 jusqu'au téléchargement de packages PlatformDeploy/JFrog (dernier run 4452826), sans JMeter Cur/Fix; rapporté, non revérifié; 2 | —
- [`local-2026-09-11-frenchtaxesrules-legacy-log-recovery/`](local-2026-09-11-frenchtaxesrules-legacy-log-recovery/) — Fiche reçue rapportant le run Legacy FrenchTaxesRules `4459782` arrêté dans `executeWorkflowPlugin`, sans TRX ou `.mstest.log`; hypothèse `Invoke-WebRequest` sans `-UseBasicParsing`; rapporté, non revérifié; 2 | —
- [`local-2026-09-11-legacy-jfrog-cross-vm-symptom/`](local-2026-09-11-legacy-jfrog-cross-vm-symptom/) — Complément utilisateur rapportant le même symptôme sur `Y2-TSTAUTOXXPG3` avec InventoryTracking V5 et un `Artifactory_fct.ps1` de SHA-256 identique à PG2; cause transversale et suspect PowerShell restent des inférences non revérifiées; 1 | —

Les preuves de vérification locale du candidat Console et de l'état Full-Text round4
sont indexées dans le dossier de travail parallèle : [candidat Console](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-console-candidate-round3/README.md), [état Full-Text round4](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-fulltext-state-round4/README.md) et [lecture live Full-Text round5](../parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-fulltext-live-4442156-round5/README.md).

La précondition JMeter et le contrat d'attestation cible de la reprise Clienteling sont
documentés dans [la collecte locale round5](../parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-jmeter-preconditions-round5/README.md) : JMeter 5.6.3 réel et hashé localement; Round7 vérifie son téléchargement direct dans Cur/Fix, tandis que les cibles restent à attester.

Les contrats opératoires destinés à Worker 1 et Worker 2 sont joints dans cette
collecte : [transport JMeter](../parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-jmeter-preconditions-round5/WORKER1-HANDOFF-JMETER.md) et [cible éphémère](../parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-jmeter-preconditions-round5/WORKER2-HANDOFF-TARGET.md).

Le nom d'un nouveau dossier de preuve dit **le sujet et l'objet observé**, jamais son producteur :
`build-<id>-<sujet>/`, `run-<id>-<sujet>/`, `<repo>-<branche>-build-<id>/` ou `local-YYYY-MM-DD-<sujet>/`.
Le producteur, la date, la méthode et les limites vont dans le `README.md` interne, pas dans le nom du dossier. Les dossiers `…-worker<N>-round<M>` ci-dessus sont conservés sous leur nom historique : les renommer casserait les liens cités par les `findings/`.
