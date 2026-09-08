# Ressources et dépollution — WI-2222897

Snapshot local : **2026-09-06**. Ce registre ne contient aucune valeur de secret.

Ajout documentaire 2026-09-08 : conserver les collectes `investigations/ecarts-jmeter-migrations/evidence/2026-09-08-inventorytracking-azdo-access-diagnosis-round2/` (réponses AzDO Python/OpenSSL, builds `4440774`/`4440884`, artefacts et résultats Cur/Fix) et `investigations/ecarts-jmeter-migrations/evidence/2026-09-08-inventorytracking-azdo-independent/` (échecs clients Schannel/CLI). Aucune ressource externe n'a été créée dans cette mise à jour.

Ajout documentaire 2026-09-08 : le plan `investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw3-plugins/PLAN-round2-safe-pipeline.md` reste indexé et à son emplacement pendant l'utilisation par son propriétaire. Toute prochaine exécution InventoryTracking doit maîtriser les effets ACR/Artifactory staging et le compteur partagé.

Ajout documentaire 2026-09-08 : conserver les deux dossiers complémentaires de reprise `investigations/ecarts-jmeter-migrations/evidence/build-4444389-inventorytracking-docker-reprise-20260908/` (provenance, manifeste et synthèse) et `investigations/ecarts-jmeter-migrations/evidence/build-4444389-inventorytracking-docker-reprise/` (extraits expurgés de timeline). Aucun secret ni artefact brut non expurgé n'y est conservé; aucune ressource externe n'a été créée ou nettoyée dans cette consolidation. Le build `4444389` est terminal/canceled; la cause de l'annulation Cur/global et l'absence du daemon Fix restent UNKNOWN.

Ajout documentaire 2026-09-08 : conserver `investigations/ecarts-jmeter-migrations/evidence/build-4444720-inventorytracking-docker-init/` et son manifeste. `4444700`/`4444703` sont des essais annulés avant JMeter (`pipelineDevMode=False`); `4444720` a Build/preflight réussis mais Cur/Fix bloqués à `Initialize containers`, sans campagne ni artefact métier. Les trois enrichissements `source-comparison.md`, `xmlDiff-minimal.patch` et `cur-fix-collection-plan.md` restent dans le lot daté 4444389 et sont séparés dans son `MANIFEST.csv`; aucune preuve antérieure n'a été réécrite.

Ajout documentaire 2026-09-08 : conserver le lot `investigations/ecarts-jmeter-migrations/evidence/build-4444720-inventorytracking-review-correction-20260908/`. Il rectifie la qualification 4444720 (initialisation non achevée pendant un téléchargement actif, panne Docker non démontrée), sépare le fait daemon absent de 4444389, et consigne la décision supervisée d'un rejeu unique sans réécriture Docker. Aucun acte distant ni nettoyage partagé n'a été effectué.

Ajout local 2026-09-07 Full-Text : conserver le patch non publié `worktrees/Pipelines_Docker_BaseImages_worker2_round9/validation/WI-2222897/sql-fulltext-hosted-build.yml` et le finding `investigations/ecarts-jmeter-migrations/findings/014-sql-fulltext-runtime-4442685.md`. Il cible uniquement la branche sandbox Full-Text et la définition 14251 ; aucune publication, queue ou ressource externe n’a été effectuée dans cette session.

Ajout local 2026-09-07 : le candidat V22 null-safe et sa preuve Worker 2 round3 sont conservés pour revue/publication autorisée ; aucun artefact distant, secret ou ressource partagée n’a été créé.

Ajout local 2026-09-07 round4 : la preuve de réconciliation `evidence/azure-devops-french-taxes-rules-v22-worker2-round4/` et le candidat `659DE...` sont conservés. L’accès Python/OpenSSL Azure DevOps est rétabli ; Schannel reste seulement un historique client-specific, sans ressource distante créée.

Ajout local 2026-09-07 round6 : conserver la collecte `evidence/azure-devops-french-taxes-rules-v22-worker1-round24/` du run `4442696` et son état partiel. Aucun cleanup distant n’a été déclenché par Worker 2 ; l’état runtime reste à vérifier par une lecture finale supervisée.

Ajout local 2026-09-07 round7 : la collecte round25 supersède l’état round24 pour `4442696` ; conserver les deux snapshots pour provenance. Le préflight a réussi et son cleanup est prouvé ; aucune ressource métier, artefact publié ou collecte supplémentaire n’a été créée.

**Pause utilisateur après étape 28 : conserver les ressources d'essai, aucun nettoyage demandé.** Les lignes de tentatives ci-dessous gardent leur état historique ; l'état actuel et les blocages résolus sont dans [HANDOFF.md](investigations/ecarts-jmeter-migrations/HANDOFF.md). Le conflit Console encore ouvert concerne XmlDiffPatch.View, pas la disponibilité de Cegid.Retail.XmlDiff 1.0.5. Les sorties Export_Run Run_01 à Run_04 signalées manquantes ne sont pas requises par le plan.

Brouillon pipeline local : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-replay-draft/`. Aucune définition/branche distante de rejeu créée ni run lancé pour cette préparation. Conserver les copies candidates comme preuve ; préparer toute révision dans un nouveau dossier.

| Ressource | Type / emplacement | État connu | Conservation ou dépollution |
|---|---|---|---|
| Outil de migration | `worktrees/Migration_Jmeter_RJE_Sandbox/` | clone propre au commit `13144a2f...` | conserver tant que la migration est active ; supprimer localement seulement après sauvegarde/validation et demande explicite |
| Workflow JMeter | `worktrees/Y2_Tools_Jmeter_Workflow/` | clone sur `master`, `azure-pipeline.yml` modifié localement | préserver la modification ; ne pas nettoyer, restaurer ou écraser |
| Branche d'essai workflow | Azure DevOps `sandbox/tests_rje`, commit enregistré `b962f77b...` | existence/état enregistrés le 2026-09-05, non revalidés ici | après les essais et sur confirmation, supprimer la branche distante si elle n'a plus d'utilité |
| Captures pipeline 5224 | `evidence/azure-devops/pipeline-5224/` | quatre captures brutes indexées | conserver avec le WI ; remplacer uniquement par une nouvelle collecte datée, jamais silencieusement |
| Artefacts de builds et Test Runs | `investigations/ecarts-jmeter-migrations/evidence/` | collectes multi-build indexées | conserver pour la traçabilité ; toute réduction doit préserver manifestes, hashes et preuves citées |
| Paquets legacy transmis | `investigations/ecarts-jmeter-migrations/evidence/legacy/` | archives, extractions brutes et index LLM séparés | conserver les archives tant que l'intégrité des extractions est utile ; ne pas dédupliquer sans comparaison de hashes |
| Snapshots de dépôts | `investigations/ecarts-jmeter-migrations/sources/` | snapshots exacts et un clone incomplet en quarantaine | conserver comme preuves ; ne pas utiliser pour implémenter ; supprimer la quarantaine seulement après confirmation qu'aucune preuve unique n'y réside |
| Dépôts d'investigation complémentaires | `worktrees/Y2_Tools_AutoTest_Api/`, `Y2_Tools_AutoTest_Console/`, `Y2_Plugins_FrenchTaxesRules/`, `Y2_Plugins_Clienteling/`, `Pipelines_Docker_BaseImages/`, `Y2_Tools_PlatformDeploy/` | clones locaux propres sur `master`, HEAD et remotes consignés dans `worktrees/README.md` le 2026-09-06 | conserver pour inspection/correction locale ; aucune publication distante autorisée par ce clonage |
| Worktree d’essai EscapeJdbcDate | `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/`, branche locale `sandbox/rje-wi2222897-escape-jdbc-date` | basé sur `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`, seul `JmeterCodeGen.cs` modifié, aucun commit | conserver jusqu’à validation API/JMX ou demande explicite ; ne pas pousser ni publier |
| Dépendances API staging | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-dependencies/` | paquets publics nuget.org, paquets Cegid Artifactory all-nuget et références net452, collectés sans compilation | conserver comme staging isolé ; aucune copie dans les worktrees |
| Résolution de références | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-reference-resolution/` | `Expression.Blend.Sdk.WPF 1.0.1` contient l’assembly exacte `System.Windows.Interactivity` net45 ; Prism.Unity vérifié comme dépendance de package | conserver comme preuve ; utiliser seulement comme staging de compilation isolée, sans modifier le projet |
| Candidat de compilation API | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-candidate/` | MSBuild 17.14.14 sur le `.csproj` seul, sortie `1`, première erreur `CS0012 System.Runtime` | conserver le journal et les intermédiaires ; aucune sortie dans les worktrees |
| Candidat de compilation avec façades | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-candidate-facades/` | import MSBuild externe vérifié, `System.Runtime` transmis à Csc, sortie `1` sur `System.ObjectModel` | conserver comme preuve ; aucun second essai sans nouvelle instruction |
| Compilation API net452 complète | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-net452-complete/` | 51 façades du targeting pack transmises à Csc ; MSBuild sortie `0`, DLL API produite | conserver comme preuve locale ; génération JMX encore à valider |
| Harnais génération JMX API | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-jmx-date-candidate/` | API SHA-256 vérifiée, appel public direct, 6 JMX et 6/6 contrôles SQL PASS, sans JMeter/SQL/HTTP | conserver comme preuve ; comparaison originale, Console et rejeu métier restent à faire |
| Comparaison API originale/corrigée | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-jmx-date-before-after/` | original code `1` avec 4 dates ISO inversées ; corrigé code `0`, 6/6 PASS ; XML et hashes conservés | conserver comme preuve ; portée limitée à EscapeJdbcDate et six fixtures |
| Worktree Console d'essai | `worktrees/Y2_Tools_AutoTest_Console_Date_RJE/`, branche `sandbox/rje-wi2222897-console-date` | commit `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`, propre ; compilation bloquée par `Cegid.Retail.XmlDiff 1.0.5` non disponible localement | conserver jusqu'à résolution par artefact identifié ; ne pas pousser ni publier |
| Candidat compilation Console | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-console-build-date-candidate/` | MSBuild code `1`, staging privé et journal conservés ; aucun exe Console produit | conserver les intermédiaires et le manifeste ; aucun cache partagé utilisé |
| Dépendances Console alignées | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-console-dependencies-aligned/` | matrice 17 références ; API/Svn/XmlDiff alignés ; conflit `XmlDiffPatch.View` de PublicKeyToken restant | conserver jusqu'à résolution de l'identité exacte ; aucune compilation avant résolution |
| Résolution XmlDiffPatch.View | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-xmldiffpatch-view-resolution/` | artefact Console officiel 2.0.42/run 4311240 inspecté metadata-only ; aucune DLL XmlDiff livrée et aucun token exact trouvé | conserver comme preuve ; ne pas modifier la référence ni compiler avant résolution |
| Comparaison Console/API date | `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-console-jmx-date-before-after/` | deux copies isolées du runtime officiel ; seule l'API diffère, les deux exécutions retournent `-1` sans JMX | conserver les logs et fixtures ; propagation Console non validée |
| Fichier sensible JFrog | `worktrees/Migration_Jmeter_RJE_Sandbox/jfrogToken.txt` | contenu non inspecté ; chemin connu sensible | ne jamais ouvrir/copier/committer ; rotation ou suppression à traiter par le propriétaire des accès |

Ajouter ici toute branche, PR, pipeline temporaire, clone, environnement, token local, capture volumineuse ou ressource externe créée pendant une session, avec son propriétaire et sa condition de suppression.

- 2026-09-07 : profil Azure CLI temporaire rapporté par Worker 2 : `.azconfig-worker2-r2` relatif à son dossier de travail. Nettoyage non confirmé dans ce processus; ne pas supprimer à distance ni retenter sans son propriétaire.
- 2026-09-07 : profil Azure CLI temporaire de cette collecte : `evidence/azure-devops/work-item-2222897/2026-09-07/cli-r2/azcfg/` (extension Azure DevOps et journaux CLI, 1389 fichiers). Nettoyage refusé/non effectué; conserver la trace et ne pas retenter dans ce lot.

- 2026-09-07 : `investigations/ecarts-jmeter-migrations/evidence/2026-09-07-v22-replay-prereqs/` — README de collecte des prérequis V22, sans copie supplémentaire de backup/JFrog ZIP ; conserver avec l'enquête.
- 2026-09-07 : `investigations/ecarts-jmeter-migrations/evidence/2026-09-07-jfrog-v22-packaging-revalidation/` — seul `README.md` est conservé ; aucun ZIP, manifeste brut ou fichier de hashes séparé ; aucune dépollution requise.
- 2026-09-07 : `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/` — brouillon local et préflight durci ; aucune cible, branche ou ressource distante créée ; conserver jusqu'à obtention d'un ref templates approuvé et d'une attestation dédiée.

- 2026-09-07 : `C:\Users\jegour\AppData\Local\Temp\wi2222897-r7-b0e05dd2` — staging temporaire court créé et utilisé uniquement par Worker 1 pour génération Console originale/corrigée depuis XML legacy; propriétaire : cette tâche; aucun système métier; suppression ciblée après validation des preuves.
- 2026-09-07 : `C:\Users\jegour\AppData\Local\Temp\wi2222897-r8-40d79ec7` — staging temporaire court pour quatre plans legacy et deux variantes API; propriétaire : cette tâche; aucun système métier; suppression ciblée après validation des preuves.
- 2026-09-07 : staging temporaire Apache JMeter 5.6.3 créé pour acquisition officielle; aucun fichier acquis après échec TLS `SEC_E_NO_CREDENTIALS`; suppression ciblée possible. La README de collecte est conservée sous `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/`.

- 2026-09-06 : C:\temp\rje-wi2222897-20260906-console — essais locaux dédiés RJE/WI-2222897, deux runtimes et sorties. Preuves utiles copiées dans evidence/local-2026-09-06-console-quick-diagnosis. Conserver pour reprise ; nettoyage ciblé uniquement après validation, aucune purge globale.
- 2026-09-06 : C:\temp\rje-wi2222897-export-20260906-173737 — copie isolée du plan legacy Export_Run, entrées TC08–TC10 et graines `OutputFiles`; aucune exécution. Preuve : evidence/local-2026-09-06-export-run-tc08-tc10-prep.
- 2026-09-06 : la comparaison Export_Run avant/après est bloquée par les entrées manquantes `Run_01.xml`–`Run_07.xml` référencées par le plan complet. Preuve : evidence/local-2026-09-06-export-run-tc08-tc10-before-after-blocked.
- 2026-09-06 : la préparation Export_Run complète est bloquée par les graines de sortie legacy manquantes `Run_01.xml`–`Run_04.xml`. Preuve : evidence/local-2026-09-06-export-complete-blocked.
- 2026-09-06 : `C:\temp\rje-wi2222897-export-complete-20260906-175237` — deux runtimes Console isolés et sorties JMX Export_Run avant/après ; preuve `evidence/local-2026-09-06-export-complete-before-after`. Nettoyage ciblé seulement après validation.
- 2026-09-06 : préparation documentaire du rejeu métier Export_Run ; aucune nouvelle ressource démarrée ou publiée. Prérequis et blocages : evidence/local-2026-09-06-export-run-business-replay-prep.
## 2026-09-07 — tentative JMeter XPath offline

- `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/` : dossier de collecte conservé; aucune archive téléchargée, aucun secret, aucune ressource externe à dépolluer.

## 2026-09-07 — handoff manuel FrenchTaxesRules V22 (mécanisme DLL d'autorisation)

- `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-french-taxes-rules-v22-authorization-handoff/` : document reçu dans `Downloads`, copié tel que reçu ; aucune ressource externe créée, aucun secret. Conserver avec l'enquête ; ne pas le présenter comme vérifié tant que les `ExternalsToRestore.xml` et le NuGet cités n'ont pas été revérifiés indépendamment.
# 2026-09-07 — Ressources Round 3 FrenchTaxesRules V22

- Candidat complet : `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/azure-pipelines.candidate.yml`.
- Étapes inline : `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/scripts/steps-replay-variant.yml`.
- Contrôle runtime local : `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/scripts/Assert-V22LocalContainerRuntime.ps1`.
- PlatformDeploy résolu : version `5.0.86`, SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`, preuve `evidence/azure-devops-french-taxes-rules-v22-worker1-round4/`.
- Ressources encore manquantes avant queue : preuve live d'identité/cycle de vie container, mounts et cibles non partagées; aucun secret n'a été copié.
- Contrôle local positif : `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/scripts/Invoke-V22RunnerDryRun.ps1`; aucune ressource externe créée, aucune publication.
- Manifeste final : `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/MANIFEST.sha256`; scripts de comptage et collecte expurgée dans `scripts/Assert-V22CampaignCounts.ps1` et `scripts/Collect-V22ScrubbedResults.ps1`.
- Identités runtime/packages : `PACKAGE-SHA256SUMS.txt` et `V22-174-REFUS-COMPARISON.md`; image historique ACR et hashes baseline vérifiés par Worker 1 round5, aucune exécution métier.

## 2026-09-07 — Worker 3 Round 2 Clienteling

- `investigations/ecarts-jmeter-migrations/evidence/2026-09-07-brain-reprise-worker3/` : collecte et script de test local du transport des onze fixtures; le répertoire temporaire de test est supprimé par le script. Aucune ressource externe, branche, pipeline, cible ou secret créé.
- 2026-09-07 : branche Azure DevOps dédiée `codex/wi-2222897-v22-preflight-20260907`, définition 14246 et runs 4441699/4441719 créés pour préflight read-only. Aucun conteneur n'a persisté ; nettoyage job final réussi. Échec final : service connection authentifié mais pull image historique refusé. Preuve : `investigations/ecarts-jmeter-migrations/evidence/azure-devops-french-taxes-rules-v22-worker1-round7/`.
- 2026-09-07 round8 : diagnostic image corrigé : le pull 4441719 était non qualifié alors que le login visait l'ACR `AcrRetailDocker`. Patch local reviewable `replay-prep/2026-09-07-v22-preflight/image-reference-correction.local.patch`; aucune écriture distante ni queue supplémentaire.
- 2026-09-07 round9 : hostname ACR exact non résolu en lecture seule ; `AcrRetailDocker.azurecr.io` est explicitement conservé comme inférence, pas comme fait. Aucun nouveau run. Preuve `evidence/azure-devops-french-taxes-rules-v22-worker1-round9/`.
## 2026-09-07 — Audit des traces partagées `codex`

- `worktrees/Y2_Plugins_FrenchTaxesRules/` : worktree laissé avec de nombreuses modifications/suppressions après l’échec du checkout dédié round11, selon `investigations/ecarts-jmeter-migrations/evidence/azure-devops-french-taxes-rules-v22-worker1-round11/README.md`. Ne pas nettoyer ni restaurer; propriétaire et état Git détaillé restent à vérifier.
- Branche AzDO partagée `refs/heads/codex/wi-2222897-v22-preflight-20260907`, définition `14246`, runs `4441699`, `4441719`, `4442003` : éléments historiques à conserver pour provenance. La correction de branche est attribuée à Worker 1; aucune action distante par Worker 3.
- Lecture live des autres surfaces (PR, autres refs, messages de commit, entités Azure/JFrog) : UNKNOWN dans ce processus; CLI bloquée par le profil global et aucune configuration globale n’a été modifiée.
## 2026-09-07 — Résultat live du renommage V22

- Branche historique `refs/heads/codex/wi-2222897-v22-preflight-20260907` : absente côté serveur après suppression vérifiée; ne pas recréer sans autorisation.
- Branche neutre exécutée : `refs/heads/investigation/wi-2222897-v22-preflight-20260907`, commit `cd632126c17f3ac95c8a29b079d0e243fa538e54`; définition 14246 conservée et run `4442120` réussi en préflight read-only.
- `cd632126...` est documenté comme commit utilisé par `4442120`, sans preuve qu’il soit encore la tête actuelle; `a2a442c98f05b2e57d02a98fd7228967ee4104df` est établi par round13 comme commit exécuté par `4442152`. Auteur/message et tête postérieure restent UNKNOWN.
- Résidu à traiter par le propriétaire : `repository.defaultBranch` de la définition 14246 pointe encore vers l’ancienne ref supprimée. La cible neutre `sandbox/WI-2222897-v22-preflight-20260907` est absente selon l’audit live; aucune modification n’est effectuée ici.
- `4442120` n’a pas publié les détails runtime et n’a exécuté aucun rejeu métier. Les ressources temporaires Agent.TempDirectory ont été nettoyées par le job selon la preuve, sans artefact publié; le worktree local pollué round11 reste inchangé.
## 2026-09-07 — Round13 : isolation runtime non satisfaite

- Définition 14246 : `defaultBranch` courant relu sur `refs/heads/investigation/wi-2222897-v22-preflight-20260907`; l’ancien résidu `codex/...` est historique et ne doit plus être traité comme actif.
- Run `4442152` / commit `a2a442c98f05b2e57d02a98fd7228967ee4104df` : digest téléchargé, `containerPresentAfterRemove=False`, puis échec de l’assertion globale d’isolation. Aucun rejeu métier; détails JSON runtime non conservés.
- `cd632126...` reste un commit antérieur; ne pas le présenter comme tête courante. Le worktree endommagé round11 reste inchangé et non nettoyé.
## 2026-09-07 — Round14 : isolation et garde-fou hôte

- Tête neutre active relue : `refs/heads/investigation/wi-2222897-v22-preflight-20260907` → `2fd2830b4656ea836a20f12642649ff8d7057278`.
- Run `4442178` : digest téléchargé, cleanup `containerPresentAfterRemove=False`, puis échec de l’assertion globale d’isolation; aucun rejeu métier.
- Garde-fou local : `evidence/2026-09-07-v22-isolation-guard-worker2-round7/README.md`; attestation/politique doivent être produites par l’hôte. Aucun producteur hôte ni fichier d’attestation n’a été ajouté; worktree endommagé conservé.
- Commits du préflight et messages/auteurs sont documentés dans la preuve `azure-devops-french-taxes-rules-v22-worker1-round14`; les mentions historiques `codex` restent conservées.

## 2026-09-08 — Ressources des trois BW paralleles
Lot : investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/README.md. Trois orchestrateurs PID 18468/6100/22320; controle et archives habituels a la racine du WI. Chaque instance tient son RESOURCES.md exclusif. Aucun nettoyage des ressources historiques ni modification de leurs sessions. Les anciennes mentions running seules ne sont pas une preuve de processus actif.

## 2026-09-08 — Worker 1 round 4 — candidat / Full-Text

- Candidat local conservé : `C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710`; hashes dans le rapport round3 du sous-dossier worker.
- Full-Text : snapshots `4442156`/`4442685` relus; aucun artefact brut nouveau copié. `4442156` reste sans état final dans la preuve disponible; téléchargement `4442685` bloqué par redirection/ticket, sans secret transmis.
- Processus : PID orchestrateurs `18468/6100/22320` absents de `Get-Process`; relation parent/enfant refusée par `Get-CimInstance`. Aucun arrêt effectué; nettoyage des descendants non attribuables UNKNOWN.

## 2026-09-08 — Worker 2 — reprise FrenchTaxesRules

- Tentative de clone propre : `worktrees/frenchtaxesrules-wi2222897/`; Git exit 128, aucun répertoire
  de clone créé. Aucun nettoyage externe requis.
- Aucun package, branche, définition, pipeline, artefact, conteneur, image, feed ou PR créé dans cette
  reprise. Aucun secret lu ou copié.
- Les fichiers non suivis et modifications d'autres workers observés par `git status` ont été préservés.
- Le profil Azure CLI global est resté inchangé ; la tentative d'accès a échoué sur les permissions du
  profil local. Toute reprise doit réutiliser un profil temporaire autorisé et le supprimer après preuve.

## 2026-09-08 — API FrenchTaxesRules publiée et revue Console

- Preuve API build `4444765` et artefacts hashés : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-api-publish-round2/`.
- Revue indépendante et handoff Worker 2 : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-api-console-review-round3/` et dossier parallèle associé.
- Le candidat Console local embarque l'API historique `1.1.46.0`; ne pas le présenter comme chaîne corrigée avant remplacement par la DLL API `A7D3…` et rehash.
- Ressource temporaire de publication API : `C:\Users\jegour\AppData\Local\Temp\wi2222897-api-publish-r2`; conserver jusqu'à confirmation de transmission, puis dépollution ciblée uniquement.

## 2026-09-08 — InventoryTracking 4444887 : décision de transport

- Preuve primaire conservée sous `investigations/ecarts-jmeter-migrations/evidence/build-4444887-inventorytracking-container-replay-20260908/`; lecture terminal live du run `4444887`, sans collecte redondante.
- Le package InventoryTracking attendu n'est pas présent dans `retail-software-staging` car la publication de la branche isolée est neutralisée. PlatformDeploy échoue avant JMeter; aucune conclusion fonctionnelle/plugin ne doit en être tirée.
- Suite autorisée à préparer : transport par artefact privilégié strictement isolé, sans réactivation du staging partagé, promotion ou tag. Aucun système distant n'a été modifié dans cette consolidation.

## 2026-09-08 — InventoryTracking : contrat transport round5

- Preuves conservées et indexées sans recopie : `investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-contract-round5/` et `investigations/ecarts-jmeter-migrations/evidence/build-4444887-inventorytracking-platformdeploy-review-20260908/`.
- Ressource Build attestée : PipelineArtifact `26.0.7.83_Software`, ID `5037140`, taille déclarée `1 705 531` octets. Le contrat actuel reste JFrog-only; l'entrée locale du plugin n'existe pas dans ce contrat.
- Décision supervisée : substitution locale expérimentale du seul plugin via PipelineArtifact, à implémenter/tester sans staging partagé. Aucun nouveau secret, service connection, feed, publication ou ressource distante créé; les chemins temporaires des preuves existantes restent inchangés.

## 2026-09-08 — InventoryTracking : round6 artefact et préparation

- Preuves indexées sans recopie : `investigations/ecarts-jmeter-migrations/evidence/build-5037140-inventorytracking-transport-review-20260908/` et `investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-pipelineartifact-5037140-round6/`.
- Ressource inspectée : PipelineArtifact `5037140`, quatre fichiers (deux MSI/deux XML), hashes et version `26.0.7.83`; contrat `ArtifactItem` rattaché au commit `93f91487ee717185599555a42df3cb5d024ace89`.
- Contraintes séparées : verrou actif du clone PlatformDeploy d'une part, `.git` documentaire en lecture seule d'autre part. Ne toucher à aucun verrou; la préparation indépendante dans un dossier inscriptible reste possible en principe, sans preuve de patch encore disponible.
- Décision : préparer puis publier via REST sur branche dédiée après revue. Aucun nouveau secret, artefact distant, branche, run ou publication créé dans cette consolidation.

## 2026-09-08 — InventoryTracking : candidat transport round7

- Candidat local conservé dans `.work/transport-round7/`; preuves indexées sans recopie dans `evidence/local-2026-09-08-inventorytracking-transport-tests-round7/` et `parallel/.../bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-candidate-round7/`.
- Les tests indépendants du contrat et les tests locaux du candidat sont documentés séparément. Les tests opérateur sont annoncés PASS, mais aucune exécution dans un conteneur PlatformDeploy réel n'est prouvée.
- Revue indépendante des hashes, commits et runs opérateur encore attendus. Aucun nouveau secret, branche, run, publication ou ressource distante créé.

## 2026-09-08 — InventoryTracking : revues transport round8

- Preuves indexées : `investigations/ecarts-jmeter-migrations/evidence/build-5037140-inventorytracking-transport-review-round8/` et `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-inventorytracking-transport-review-round8/`.
- Tests locaux du transport PASS; mécanisme favorable sous réserve. Correction requise avant run : distinguer `sourceBuildId=Build.BuildId` de `artifactName=$(componentVersion)_Software` et vérifier les hashes des quatre fichiers MSI/XML effectivement transportés.
- Aucun hash d’archive exigé. Commits, revue corrigée et run restent à venir; aucune ressource distante créée ou modifiée.
- Checkout Console réel : `C:\clones\wi-2222897\.work\console-source`, branche `sandbox/frenchtaxesrules/console-api-artifact`, diff `7d0667c…`; conserver pour revue du correctif et ne pas modifier sans nouveau lot.
- Preuve build Console `4444888` : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-console-2.0.43-build-4444888-round4/`; aucun artefact Console produit, ne pas lancer de relance identique.
- Build Console corrigé `4445025` : PipelineArtifact `5037277`, nupkg `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`, récupérable sous `C:\clones\wi-2222897\.work\console-4445025\x\Nuget\`; staging migration isolé sous `C:\clones\wi-2222897\.work\migration-candidate-4445025\`. Ne pas modifier le snapshot source; JMX/manifeste/rejeu restent à produire.
- Génération JMX réelle `4445025` : preuve `investigations/ecarts-jmeter-migrations/evidence/build-4445025-jmx-generation/`, staging source `C:\clones\wi-2222897\.work\frenchtaxes-source-07a42172`, sorties générées `C:\clones\wi-2222897\.work\jfull\Tests`. 19 JMX code 0; manifeste exige 32 et échoue explicitement. Conserver pour revue des 13 plans manquants; aucun JMeter exécuté.

## 2026-09-08 — 14264 Round 7 — ressources et blocage courant

- Configuration dédiée publiée et relue sur la branche `sandbox/clienteling/wi2222897-isolated-replay`, commit `b790767c1cecb90d6913c8726aea532c29ea4582`; aucune queue nouvelle après `4444892`.
- API réelle disponible : build `4444962`, PipelineArtifact `5037204`. Le nupkg Console local `803D...` n'a pas été transporté; le build Console `4445025/5037277` est une variante distincte et ne doit pas être injecté.
- Le runtime JMeter 5.6.3 est acquis localement et hashé; aucune cible Cur/Fix live, image/digest, backup, réseau ou cleanup dédié n'est attesté. Les ressources temporaires `.work` restent à conserver jusqu'à décision de dépollution ciblée.
- La tentative ArtifactTool vers le run terminé `4444892` a échoué localement sur `SEC_E_NO_CREDENTIALS` avant requête; aucun artefact distant n'a été créé et aucun credential global n'a été modifié.
- Lecture live des runs 14264 : `4445072`, `4445085`, `4445099` sont `completed/canceled` sur les commits intermédiaires; aucun résultat Build/JMX/JMeter n'en est déduit. Le commit courant `b790767c` n'a pas de run observé.
- Diagnostic cible round8 : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-target-preflight-round8/Invoke-Wi2222897TargetPreflight.ps1`; aucune image, permission, donnée ou ressource externe créée. Le script doit être exécuté uniquement par le responsable 14264 dans un agent Docker-compatible.
- Revue cible round9 : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-target-review-round9/README.md`; le script round8 est à corriger avant usage distant. Aucun job, YAML, image, permission ou donnée partagé modifié.
- Scripts runtime round10 : `replay-prep/2026-09-08-clienteling-isolated/scripts/Assert-Wi2222897ClientelingRuntime.ps1` et `Remove-Wi2222897OwnedTarget.ps1`; parse et tests négatifs locaux PASS, aucune ressource externe créée.
- Contrat producteurs round11 : `Invoke-Wi2222897PlatformDeploy.ps1` et `Invoke-Wi2222897JmeterContainer.ps1`; aucun chemin PlatformDeploy/config ou digest JMeter réel fourni, aucun lancement effectué.
- **FrenchTaxesRules round7** — `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-frenchtaxesrules-round7/` : inventaire nominatif 19/19, origine du compteur 32, métadonnées backup/config et limites du préflight V26 ; ne pas télécharger/restaurer le backup sans cible runtime résolue.
- **FrenchTaxesRules round8** — `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-frenchtaxesrules-v26-preflight-round8/` : YAML publié, définition 14265, build 4445476 ; digest vérifié mais timeout avant attestation et cleanup non prouvé ; vérifier uniquement le conteneur `wi2222897-frenchtaxesrules-v26-preflight-4445476`.

## 2026-09-08 — Clôture documentaire Clienteling 14264

- Point d’entrée : `STATUS.md`, section « Clôture documentaire — reprise future Clienteling 14264 »,
  puis `investigations/ecarts-jmeter-migrations/HANDOFF.md`.
- Preuves déterminantes : `evidence/local-2026-09-08-clienteling-14264-initialization-comparison-round11/`,
  `evidence/local-2026-09-08-clienteling-14264-agent-diagnostic-round10/` et `...round9/`.
- À conserver : scripts `replay-prep/2026-09-08-clienteling-isolated/`, artefacts `.work` et preuves
  immuables jusqu’à dépollution ciblée; ne pas réimporter les binaires.
- État terminal : aucun nouveau run/push/provisionnement après la demande de clôture; les postconditions
  Build/GenerateJmx/Cur/Fix Clienteling restent non prouvées.

## 2026-09-08 — Rangement des trois synthèses techniques de pause

- Sources reçues : `C:\Users\jegour\Downloads\WI-2222897_FrenchTaxesRules_V26_synthese_technique_2026-09-08.md`,
  `…_InventoryTracking_synthese-technique_2026-09-08.md` et `…_Clienteling_JMeter_synthese_technique_2026-09-08.md`.
  Copiées sans modification dans
  `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-syntheses-techniques-reprise-handoff/`
  avec leurs SHA-256. Les originaux de `Downloads` peuvent être supprimés par l'utilisateur : le dépôt
  en porte désormais la copie de référence.
- Aucune ressource distante n'a été créée, lue, relancée ou nettoyée dans ce rangement ; aucun secret
  n'est consigné.
- Ressources distantes **rapportées par ces documents et non revérifiées**, à connaître avant toute
  action : branche `sandbox/frenchtaxesrules/v26-preflight-20260908` (définition dédiée `14265`,
  build `4446410`) ; branche
  `validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908` (HEAD `c9a7c6fe…`, push
  `5136500`) ; branche `sandbox/WI-2222897-inventorytracking-local-transport` (commit `a490cd53…`,
  push `5135960`) ; branche `validation/WI-2222897-inventorytracking-isolated-20260908` (commit
  `95aede77…`, run `4445575`) ; branche `sandbox/clienteling/wi2222897-isolated-replay` (commit
  `c20755d8…`, run `4446303`).
- **Action de dépollution encore due, inchangée** : vérifier et supprimer uniquement le conteneur
  labellisé `wi2222897-frenchtaxesrules-v26-preflight-4445476`. Le cleanup vert du préflight `4446410`
  porte sur son propre conteneur et ne dit rien de celui-ci.
- À conserver en l'état : le jeu canonique des 19 JMX sous
  `evidence/build-4445025-jmx-generation/generated-jmx` et le jeu local `.work\jfull\Tests`, rapportés
  identiques (19 de chaque côté, 0 différence). Ne pas régénérer sans contradiction factuelle nouvelle.
- Ne pas télécharger ni republier le backup Clienteling V26 (`156 663 808` o) dans Git classique : la
  piste retenue est le pointeur Git LFS, sous réserve que l'objet historique soit encore disponible.
