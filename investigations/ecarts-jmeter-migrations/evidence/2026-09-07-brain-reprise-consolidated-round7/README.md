# Consolidation Worker 3 — Round7

Date : 2026-09-07 (Europe/Paris). Collecte destinée à une fusion manuelle par BRAIN. Aucun document canonique partagé (`HANDOFF.md`, `STATUS.md`, `RESOURCES.md`, `JOURNAL.md`) n’a été modifié.

## Provenance relue

- InventoryTracking : `evidence/2026-09-07-brain-reprise-worker1-round6/README.md` et `evidence/2026-09-07-brain-reprise-worker2-round6/README.md`.
- PlatformDeploy : `evidence/2026-09-07-brain-reprise-consolidated-round6/README.md`, `CONSOLIDATED_STATE.md`, `test-platformdeploy-differential-round6.ps1`.
- Revue indépendante du harness : `evidence/2026-09-07-brain-reprise-worker2-round6/README.md`.

## InventoryTracking — état utile, hors duplication FrenchTaxesRules

**FACT** — le commit `ef3d87034d38b88aca04c824061b140e2a29252c` résout la compilation XmlDiff dans les builds `4440774` et `4440884` : `MSB3245=0`, `CS0103=0`. Le build `4440884` a exécuté `48/48` tests d’assemblies réussis, les déploiements Cur/Fix, la préparation et les deux campagnes JMeter WebServices (32 plans chacune).

**FACT** — le contrôle aval de `4440884` remonte encore, dans Cur et Fix, `141` occurrences `SQLServerException: Incorrect syntax` et `123` différences `B-XQuery`. Les campagnes ont donc été exécutées, mais ces erreurs restent communes et non attribuées à un scénario précis.

**INFERENCE** — XmlDiff n’est plus le premier blocage technique de compilation ; la prochaine investigation doit rattacher la première erreur SQL/XML à un plan/TC et à ses paramètres avant toute attribution legacy/JMeter.

**UNKNOWN** — cause racine SQL/XML, comparabilité legacy, correction métier et réussite globale de campagne.

## PlatformDeploy — portée et lacune maintenue

**FACT** — le candidat isolé ne modifie que `init-container.ps1`; le garde propage un code enfant non nul sous `TF_BUILD` sans changer le succès. Le test round6 appelle le wrapper réel `docker-pipeline-deploy.ps1`, avec `TF_BUILD=true`, et montre `original child 7 -> exit 0` contre `corrected child 7 -> exit 1`; succès `0` et exceptions `1` restent inchangés.

**FACT** — la revue Worker 2 relève que le test ne lance pas le vrai `init-container.ps1` avant/après : il remplace son enfant par une fixture et vérifie la frontière de processus. Le candidat n’est donc pas retouché en round7 ; la lacune est documentée, non masquée.

**INFERENCE** — la cause de propagation est suffisamment établie statiquement et par différentiel inerté pour justifier une revue propriétaire, mais pas pour conclure sur MSI/IIS/SQL.

## Ressources créées par Worker 3 versus observées

Créées/conservées par cette instance :

- `evidence/2026-09-07-brain-reprise-worker3/` et `.../brain-reprise-consolidated/` : collectes antérieures round1–5 ; contenu conservé.
- `evidence/2026-09-07-brain-reprise-consolidated-round6/` : README, état consolidé et harness différentiel TF_BUILD ; staging temporaire nettoyé.
- `worktrees/Y2_Tools_PlatformDeploy_worker3_r5b/` : clone isolé avec candidat non committé.
- Le nouveau dossier round7 et ses trois documents de consolidation.

Seulement observées/reçues, non créées par Worker 3 : builds Azure DevOps `4440774`, `4440884`, `4432602`, logs/timelines Worker 1/2, tag PlatformDeploy, ZIP JFrog et son hash rapporté, définition `InventoryTracking CI`, ressources SQL/IIS/ACR.

Ressources temporaires supprimées par les scripts de test : staging du wrapper round6 ; aucun secret ni token n’a été persisté.

## Verdict de session

La mission n’est pas déclarée bloquée : InventoryTracking a une prochaine action discriminante encore faisable (isoler le premier TC SQL/XML), et PlatformDeploy a une lacune de harness précisément bornée. Les compatibilités MSI, l’archive historique et le runtime Clienteling restent des prérequis distincts.
