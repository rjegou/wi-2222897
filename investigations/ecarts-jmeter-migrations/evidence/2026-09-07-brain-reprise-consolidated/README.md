# Consolidation dédiée — reprise WI-2222897 — 2026-09-07

Cette collecte est destinée à une fusion manuelle par le BRAIN. Elle ne modifie aucun document partagé, index canonique, worktree, pipeline, branche, package ou système distant.

## Périmètre et méthode

- Date : 2026-09-07, Europe/Paris.
- Hors périmètre : FrenchTaxesRules releases/V5/V22, déjà traité par une autre instance.
- Sources relues : collectes Worker 1/2/3 rounds 1–2, preuves SOAP/SQL/date, XmlDiff, Full-Text, endpoint Clienteling, orchestration et JTL.
- Méthode : lecture ciblée de README/provenance/manifests/JMX/JTL et vérification locale de chemins/hashes; aucune nouvelle enquête Clienteling fixtures.

## Points de lecture importants

### Round1 versus round2 JTL

**FACT** — le JTL historique de la collecte Worker 1 est `evidence/local-2026-09-07-soap-negative-jmeter56/results-fixed.jtl`, SHA-256 `FAB79862FA84CA439B0B134767284D0BAC35D44A9BCDA4F4BB7FD84780A2702D`. Il correspond au harness manuel et ne doit pas être présenté comme le rejeu round2.

**FACT** — le rejeu round2 produit un JTL distinct `results-r2-real.jtl`, SHA-256 `73D54F7ED83F4A4BF983F63CBB7C211E42C845EE7AEA0B83F40768780CFCB925`, avec JMeter 5.6.3 et les trois postconditions `FAULT_PRESENT=false`, `NO_FAULT=true`, `WRONG_NAMESPACE=true`.

### SOAP ExpectedValue=0 et négation

**FACT** — round2 fournit une fixture source hashée `1DB6BCED4D774BE60CA3C26621A19C2386B425B386C13F7099D00949492E3562`, un JMX frais hashé `836A9558C526162E6A5007D73220829C2E5B691E19AFD8709AD10661A19C47D6`, et une lecture XML montrant `ExpectedValue=0` transformé en `XPath.negate=true`, avec `XPath.namespace=true`.

**CONTRADICTION DE PROVENANCE** — les JMX round1 contrôlés dans `soap-negative-generated` et `soap-package-round14` portent `negate=false` pour leur contrôle SOAP; le harness manuel `soap-negative-jmeter56` porte `negate=true`. Ces artefacts ne partagent pas le même hash ni le même run. La relation round2 est donc acceptée comme preuve de son rejeu frais, mais ne rétro-propage pas à round1 et ne prouve pas encore la migration métier.

### SQL/date et limites d'orchestration

**FACT** — la DLL `Cegid.Retail.AutoTest.Api.dll` contrôlée par réflexion et utilisée par la collecte round2 est `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`; `EscapeJdbcDate` produit `20260907` et `FixSqlUnicodeValue` produit `SELECT N'NN''é' AS V`.

**FACT** — le JMX synthétique round2 contient `SELECT N'NN''é' AS UnicodeValue, '20260907' AS DateValue`.

**UNKNOWN** — package officiel publié/consommé, sélection par le sandbox, orchestration `step_00/step_01`, campagne par plugin réel, SQL/HTTP/backup et résultat métier. Le passage DLL→fixture→JMX n'est pas une preuve de la chaîne migration complète.

### XmlDiff et Azure DevOps

**FACT** — le correctif local XmlDiff `ef3d87034d38b88aca04c824061b140e2a29252c` restaure `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28`; restore NuGet et `ResolveAssemblyReferences` ciblé passent.

**FACT** — le build complet local échoue encore sur des assemblies Cegid absentes dans `ServiceContracts`; ce résultat est distinct de la résolution XmlDiff. Le build CI complet reste UNKNOWN.

**FACT** — l'accès Azure DevOps est rétabli pour la méthode Worker 2 en Python `requests` avec PAT en mémoire et session HTTP; la CLI/profil global et le fallback Schannel restent en échec historique. Aucun run n'est recommandé sur cette seule preuve.

### Fixtures factices versus IIS

**FACT** — la collecte Worker 3 round2 prouve onze fixtures historiques, zéro image dans le snapshot migré, aucun transport `CustomImage`/`ImageFolder` dans le template inspecté, et résout seulement une fixture factice via un chemin absolu.

**UNKNOWN** — artefact ou montage final, chemin réellement visible par IIS, propriétaire opérationnel et support métier. Cette preuve ne clôt pas le transport réel.

## Inventaire exact des documents partagés modifiés au round2 précédent

Inventaire issu du handoff Worker 3 round2; aucun de ces fichiers n'a été retouché pendant cette consolidation :

- `investigations/ecarts-jmeter-migrations/evidence/README.md`
- `investigations/ecarts-jmeter-migrations/HANDOFF.md`
- `investigations/ecarts-jmeter-migrations/findings/005-clienteling-v22-v23-build-4432602.md`
- `investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md`
- `STATUS.md`
- `JOURNAL.md`
- `RESOURCES.md`

La collecte round2 elle-même est sous `investigations/ecarts-jmeter-migrations/evidence/2026-09-07-brain-reprise-worker3/` avec `README.md`, `PROVENANCE.md`, `SHA256SUMS.txt` et `fixture-transport-check.ps1`.

## Liens et ressources de cette consolidation

Les deux fichiers de cette collecte sont `README.md` et `CONSOLIDATED_STATE.md`. Le second contient la matrice actionnable et les propositions de fusion; aucun fichier partagé n'est une dépendance nécessaire pour lire cette collecte.

## Round 4 — PlatformDeploy 4432602

**FACT live Azure DevOps** — build `4432602` a répondu HTTP 200 : build number `6.695`, résultat `failed`, branche `refs/heads/Clienteling_Migration_AutoTest_Jmeter_On_releases/V6`, commit plugin `8744999cabb6cea993db49a2d2bf741ae2dd5454`, définition `2065` `Clienteling CI`. La timeline contient 398 records.

**FACT résolution lastV5** — le log `215` (`Search Artefact version on JFrog`) recherche `retail-software-production/Y2.Tools.PlatformDeploy/PlatformDeploy.5.*`, retourne `retail-software-production/Y2.Tools.PlatformDeploy/PlatformDeploy.5.0.86.zip` et écrit `foundPlatformDeployVersion=5.0.86`. Le log `243` télécharge cette archive; le log `244` l'extrait avec 7-Zip. Le log de checkout `214` montre le tag `V5.0.86`; la lecture Azure Repos confirme `refs/tags/V5.0.86` → objet `93f91487ee717185599555a42df3cb5d024ace89`, identique au `master` local propre. Cette correspondance autorise l'inspection des scripts au commit exact; aucun hash binaire ZIP n'est conservé.

**FACT premier retour MSI** — dans V22 Fix (`log 248`), le premier retour 1603 visible est `WORKER_PROCESS_RETAIL_LOYALTYENGINE.MSI` à `10:57:19.579`; suivent TaxEngine puis Clienteling. Dans V23 Fix (`log 255`), le premier est `E_IIS_SERVER_RETAIL_Technical.MSI` à `10:57:47.695`; suivent Technical WorkerProcess et TaxEngine. Les deux logs terminent par `Errors found during package installation` et une exception PowerShell.

**FACT propagation statique au tag exact** — `install-y2msi.ps1` accepte seulement `0`/`3010`, retourne `1` sinon; `install-packages.ps1` additionne `$nbErr` puis lève l'exception si `$nbErr -gt 0`. En revanche `init-container.ps1` appelle `deploy.ps1` sans tester `$LASTEXITCODE` lorsque `TF_BUILD` est vrai; le test de `$LASTEXITCODE` est dans la branche locale `TF_BUILD -ne $TRUE`. **INFERENCE causale forte** — en pipeline, l'exception peut être visible dans le log du conteneur sans devenir un code de sortie non nul du wrapper, ce qui explique `Launch Y2 deployment` timeline `succeeded` malgré les 1603; le health check échoue ensuite par connexions refusées (`log 318`, V23 Fix).

**FACT harness inerte** — `platformdeploy-propagation-harness.ps1` simule uniquement les codes, sans MSI/SQL/IIS : `[0,1603,0]` donne `nbErr=1, throws=true`; `[0,3010,0]` donne `nbErr=0, throws=false`; avec `TF_BUILD=true`, un enfant code `1` donne wrapper `0` et `propagated=false`, contre wrapper `1` hors pipeline. Hash : `B8B1DAC438F038E9663A6AF26424B661555352739CF0E9792AA7FE261AA127A8`.

**UNKNOWN conservés** — hash binaire ZIP, provenance BuildId/commit de publication JFrog, contenu éventuel différent du tag source, et correction officielle à appliquer. Aucun MSI n'a été installé localement et aucune cible n'a été touchée.

## Round 5 — archive JFrog et correctif isolé

**FACT** — une tentative directe sans secret vers `https://cegid.jfrog.io/artifactory/retail-software-production/Y2.Tools.PlatformDeploy/PlatformDeploy.5.0.86.zip` répond HTTP `401`; aucun token n'a été ouvert, affiché ou persisté. La collecte authentifiée existante du 2026-09-07 documente le même chemin en HTTP `200`, 7 566 674 octets, SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`, `lastModified=2026-08-18T14:24:42.963Z` et SHA-1 `f01fb95807ae6e962e95b0adea44b6074ed1a0af`. Le binaire n'est pas conservé dans cette collecte.

**DISTINCTION d'identité** — l'archive actuellement disponible au chemin JFrog est identifiée par son hash et sa date de métadonnée; l'archive historiquement consommée par 4432602 est identifiée par les logs 215/243/244 et le tag source V5.0.86, mais l'égalité binaire historique↔actuelle n'est pas prouvée par le build. Les scripts inspectés sont ceux du tag `93f91487...`, pas une extraction locale du ZIP historique.

**FACT correctif isolé** — clone `worktrees/Y2_Tools_PlatformDeploy_worker3_r5b`, commit `93f91487...`, état initial propre. `init-container.ps1` ajoute immédiatement après `& .\deploy.ps1` la capture de `$LASTEXITCODE` et un `throw` si non nul. Hash post-correctif : `1F44AE664B207AFB0A94151A603BFE9F794FF6589B0BA4CCC52D47DFDE50758E`. `git diff --check` passe; aucun commit/push.

**FACT tests processus** — `test-platformdeploy-wrapper-process.ps1` (`89A49301CAA4FB46EE8B1734501288F1DF25D9FC86FECAE08CDB54BB75961629`) appelle le wrapper réel avec un enfant inerte : avant garde absente, après garde présente; enfant code `0` → processus `0`, enfant code `7` → processus `7`, exception enfant → processus `1` avec message synthétique observé. Le test crée puis nettoie son staging temporaire. Cela valide la propagation de processus du wrapper; cela ne valide ni MSI, ni Docker, ni déploiement.

**LIMITATION** — le correctif est un candidat local de propagation de code et ne résout pas les incompatibilités MSI/minima V22/V23. Une revue propriétaire et un test CI dédié restent nécessaires avant toute intégration.
