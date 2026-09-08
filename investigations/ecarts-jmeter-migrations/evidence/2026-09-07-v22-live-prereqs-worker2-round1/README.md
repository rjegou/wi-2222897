# FrenchTaxesRules V22 — vérification des prérequis live, Worker 2 round 1

Date de collecte : 2026-09-07
Système source : Azure DevOps `https://dev.azure.com/cegid/Retail` (tentative live), fichiers locaux du WI-2222897 et worktrees locaux.
Méthode : lecture seule des index/handoff, inspection ciblée des YAML/scripts, `git status` avec `safe.directory` local au processus, tentative REST avec le PAT du chemin documenté et tentative CLI avec configuration temporaire.
Statut de fraîcheur : collecte de ce processus, mais lecture Azure DevOps non obtenue.

## Résultats FACT

- Le worktree `Y2_Tools_Jmeter_Workflow` est `master...origin/master` avec une modification locale utilisateur dans `azure-pipeline.yml`; le worktree `Migration_Jmeter_RJE_Sandbox` est propre. Aucun worktree n'a été modifié.
- Le commit local du workflow est `4db2dcdab647249de3cdc27eadaf15a158b3a26a`. L'arbre local `PipelineTemplates` est `40a5f274c6e1241f9f24ccc3d83c5cd2e691b44a`; cela ne prouve pas le commit du dépôt Azure `Pipelines_Templates`.
- Le candidat `replay-prep/2026-09-07-v22-isolated/azure-pipelines.candidate.yml` a `trigger: none`, `pr: none`, `schedules: []`, et désactive publication, import ACR, promotion, tags et aval. Il contient toutefois `TEMPLATES_COMMIT_REQUIRED`, des variables d'hôtes non résolues et un job Replay qui s'arrête volontairement avant déploiement/tests.
- Le candidat exige : plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, image digestée `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`, backup SHA-256 `3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2`, 376 tests, attestation JSON SQL/IIS non partagée et restauration séparée par variante.
- Le snapshot historique ne contient qu'`AUTO_V21_00.bak`; le hash est celui indiqué ci-dessus. Aucun `backupName` live n'a été résolu.
- Le script runtime exige un conteneur Docker courant, en état `running`, au digest exact, avec labels de périmètre/run éphémère, endpoints SQL/IIS concordants et processus `sqlservr` et IIS observables. Docker n'est pas disponible dans cette collecte.

## Accès live et limites

- Appel REST Azure DevOps avec le PAT lu en mémoire depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt` : `Authentication failed, see inner exception.` Aucun token n'a été affiché ni conservé dans la preuve.
- Azure CLI sans configuration dédiée : `PermissionError` sur `C:\Users\jegour\.azure\azureProfile.json` avant lecture.
- Une tentative CLI avec `AZURE_CONFIG_DIR` temporaire n'a fourni aucune lecture exploitable; les processus Azure CLI résiduels identifiés ont été arrêtés et le dossier temporaire supprimé. Les autres processus Python présents n'ont pas été attribués à cette collecte et n'ont pas été touchés.

## Décision

**INFERENCE** — le rejeu V22 ne peut pas être lancé de façon démontrablement sûre dans ce lot. Le YAML fail-closed bloque déjà sur le commit immuable des templates, et les ressources runtime/backupName/cibles dédiées ne sont pas prouvées live.

**UNKNOWN** — définition Azure DevOps à utiliser, commit approuvé de `Pipelines_Templates`, disponibilité/compatibilité de l'agent et de l'image, `backupName` effectivement injecté, restauration SQL, cibles SQL/IIS dédiées, et capacité à atteindre `jmeter.bat -n -t`.

Paramètres candidats conservés pour une future revue humaine : variantes `FixHistorical` (`Core 22.0.0.1011`, `Common 22.0.2.300`, `Identity 22.0.5.182`) puis `Candidate` (`Core 22.0.0.2068`, `Common 22.0.3.311`, `Identity 22.0.6.117`), plugin/AuthenticationServer/image/backup hashés ci-dessus, 376 tests et trois JMX discriminants documentés dans la collecte précédente.

Aucune queue, définition, branche, pipeline, restauration, déploiement, publication ou écriture distante n'a été effectuée.
