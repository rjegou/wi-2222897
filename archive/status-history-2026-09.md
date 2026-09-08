# Historique d'état — WI-2222897 — septembre 2026

Sections datées extraites de `STATUS.md` le 2026-09-08, **verbatim et sans perte**, triées de la
plus récente à la plus ancienne. `STATUS.md` ne conserve désormais que l'état courant.

Ce fichier est une trace de provenance. Il n'est **pas** une source d'état courant : plusieurs
sections y sont explicitement supersédées par une autre. En cas de contradiction, `STATUS.md`,
la matrice de statut et les `findings/` datent et l'emportent.

Le vocabulaire « worker » / « round » qui apparaît dans les titres désigne les processus
d'investigation parallèles qui ont produit ces constats. Il identifie un producteur, pas un sujet.

---

## 2026-09-08 — Synthèse de reporting produite pour la page OneNote

**FACT** — une synthèse destinée à la page OneNote de suivi de la PBI est produite dans [reporting/2026-09-08-synthese-onenote-pbi.md](../reporting/2026-09-08-synthese-onenote-pbi.md), déplacée depuis `documentation/context/` lors de la mise en dépôt du 2026-09-08. Elle consolide, sans preuve nouvelle, l'état déjà établi : reclassement causal des échecs, corrections de lecture du tableau de suivi, causes localisées, décisions attendues et leçons retenues.

**FACT** — aucune action distante, aucun pipeline, aucune modification de code, de preuve ou de matrice dans cette session. Aucun verdict n'est changé : ce document est un livrable de communication, pas une source de vérité nouvelle.

**Portée** — le contenu reste soumis à la politique de fraîcheur des sections datées ci-dessous ; les états Azure DevOps qu'il cite sont des snapshots à revalider avant toute décision engageante.


## 2026-09-08 — Missions BW paralleles en cours

[Prompts et suivi](../investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/README.md) : BW1 outils/generation, BW2 environnements/deploiement, BW3 plugins/comparaison metier. Trois processus verifies actifs; maximum 12 rounds chacun. Aucun succes de migration deduit de leur lancement. Sorties exclusives par instance, consolidation commune reservee au lanceur.
## 2026-09-07 — Worker 2 round3 — patch diagnostic Full-Text local

**FACT** — `4442685` est terminal `failed` au commit `e3b674b...`; SQL2019 et SQL2025 atteignent `PopulateStatus=1` puis expirent à 90 secondes. `CONTAINSTABLE` n’est pas atteint. Voir [finding Full-Text 014](../investigations/ecarts-jmeter-migrations/findings/014-sql-fulltext-runtime-4442685.md).

**FACT** — patch local reviewable dans `worktrees/Pipelines_Docker_BaseImages_worker2_round9/validation/WI-2222897/sql-fulltext-hosted-build.yml` : diagnostics FDHOST/`fdhost`, DMV Full-Text, crawl/error ciblés, espace disque, console et cleanup vérifié, sans changement Dockerfile/probe ni publication externe. Parse PowerShell et `git diff --check` passent.

**UNKNOWN** — cause moteur/service/crawl/configuration et cleanup runtime tant que le patch n’est pas exécuté. Aucun lien démontré vers la réussite JMeter ou les 224 cas Clienteling. Aucune queue ni publication effectuée.

## 2026-09-07 — Worker 2 round7 — 4442696 préflight borné réussi

**FACT** — le run unique `4442696` est `completed/succeeded` au commit `68f1f7a8e575e79cf3098cafcd16e10b22237ada`, YAML `659DE89E...`. Image digest, OS, architecture, target-scope, mounts, réseaux, ports et attestation sont PASS ; `mounts=count=0;dangerous=0`, `containerState=created`, cleanup `containerPresentAfterRemove=False`.

**FACT** — checkout skipped, aucun métier ni artefact publié. Cette section supersède l’état round24 `inProgress/timeout`.

**UNKNOWN** — `Config.Volumes`, ID complet, provenance du mount historique `4442225` et couverture des futurs jobs `Agent.ContainerMapping`. La reproduction locale Worker 1 du faux comptage null n’est pas une preuve du runtime historique et ne change pas ces UNKNOWN.

## 2026-09-07 — Worker 2 round6 — run 4442696 partiellement observé

**FACT** — run unique `4442696`, définition `14246`, commit `68f1f7a8e575e79cf3098cafcd16e10b22237ada`, YAML `659DE89E...`. `Initialize job` et login registry réussis, checkout skipped, inspection runtime inProgress à 0 %, hash final pending.

**FACT** — au snapshot `20:08 UTC`, le run dépassait le timeout YAML de 10 minutes ; aucun stage métier, artefact publié ou second run n’est prouvé. Les logs expurgés ne donnent ni `Config.Volumes`, ni mounts, ni sous-verdicts, ni `containerPresentAfterRemove`.

**UNKNOWN** — origine et cycle de vie du mount, identité du conteneur, cleanup et partage hôte. Le timeout/cancelTimeout statique ne prouve pas l’exécution du `finally`; le cleanup reste non confirmé. Ce préflight ne couvre pas les futurs jobs `Agent.ContainerMapping` et ne produit aucun résultat métier.

## 2026-09-07 — Worker 2 round4 — écart de hash réconcilié

**FACT** — le résultat `0D2D781CF054CD4644C46552AB610544282D4CDD805EDCE9D197F66C151A0D5B` est la source exacte `DB8ED1...` avec seulement le filtre null. Il manque les 15 lignes normalisées de projection `Config.Volumes`/mounts du candidat `659DE89E...`. L’écart est fonctionnel, pas un effet d’encodage ou de fins de ligne.

**FACT** — le candidat réellement testé reste `replay-prep/2026-09-07-v22-round21-review/azure-pipelines.wi2222897-v22-preflight.null-safe.yml`, hash `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`; les deux tests locaux passent.

**FACT** — Python/OpenSSL a relu Azure DevOps avec HTTP 200, la branche neutre et la définition `14246`; aucun run actif. Schannel n’est plus un blocage global de lecture Azure DevOps, sans effacer ses échecs client-specific historiques.

## 2026-09-07 — Worker 2 round3 — candidat V22 null-safe matérialisé

**FACT** — le YAML exact `44070560...` est vérifié par SHA-256 `DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A`. Le candidat initial round21 est rejeté car un `Mounts` null devenait un élément projeté.

**FACT** — le candidat corrigé `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-round21-review/azure-pipelines.wi2222897-v22-preflight.null-safe.yml` est matérialisé et hashé `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`. Syntaxe, null/multiple mounts, masquage, whitelist, timeout, collecte préalable et cleanup sont validés localement.

**FACT** — l’autorisation utilisateur actuelle supersède l’ancien UNKNOWN documentaire sur la publication du patch diagnostic et le diagnostic borné `14246`; aucun push, queue, Docker ou métier n’a été réalisé par Worker 2.

**UNKNOWN** — valeurs runtime réelles et transport Azure restent non confirmés. Schannel/TLS est un blocage observé dans un test d’accès Worker 1, pas une impossibilité définitive.

## 2026-09-07 — Clôture V22 round4 — patch diagnostic non publié

**FACT** — le patch local round20 est testé sur fixtures inertes et conserve `Config.Volumes`/mounts expurgés (`name`, `type`, `source`, `destination`, `rw`) sans assouplir la whitelist.

**UNKNOWN bloquant** — le commit exact `44070560...` de `4442225` n’est pas présent dans les objets Git locaux; le YAML local non suivi hashé `D1B53E1F...` ne peut pas être relié cryptographiquement au commit. L’authentification REST précédente a échoué. Les mounts runtime et le transport via `Agent.ContainerMapping` restent non confirmés sur un run réel.

**SUITE humaine unique** — rétablir la lecture authentifiée du YAML exact, puis autoriser explicitement la publication du diagnostic mounts/`Config.Volumes` et une queue read-only de `14246`, sans métier, whitelist inchangée, artefact non publié et cleanup borné. Aucun secret ne doit être transmis dans la conversation.

## 2026-09-07 — État courant round20 — autorisation et suite V22

**FACT** — la preuve round10 contient le texte exact : « L’action de queue était explicitement limitée à ce préflight runtime et à cette branche/définition par la délégation Worker 1. » Cette autorisation ponctuelle concernait la queue du préflight dédié `14246`; elle ne couvre ni publication de patch, ni nouvelle queue, ni rejeu métier.

**FACT** — round19 établit que le YAML n’ajoute aucun `--mount`, `-v`, `volumes` ou `docker run` externe, tandis que `4442225` observe `mounts=count=1;dangerous=1`. La source/destination/type/RW du mount et `Config.Volumes` ne sont pas conservés.

**VERDICT** — patch diagnostic : préparation locale possible, publication distante non autorisée par les textes retrouvés. Nouvelle queue `14246` : non couverte par l’autorisation ponctuelle consommée; le texte manquant est une autorisation explicite d’un nouveau préflight read-only borné. Rejeu métier : interdit tant que l’attestation d’isolation hôte, la provenance du mount et la couverture des futurs jobs ne sont pas prouvées.

**Contradictions résolues** — le début historique de ce fichier mentionne encore round14/`4442178`; il est supersédé par HANDOFF round16 et la preuve round19 pour l’état V22. Pour l’hostname ACR, round9 conserve l’ancien nom court comme inférence; round10 rapporte le nom exact par l’utilisateur et round12 le retrouve dans YAML/preview serveur. Round12 est la preuve de configuration à privilégier.

## 2026-09-07 — État courant round14 — isolation toujours bloquante

**FACT** — `4442178` a échoué sur la même assertion globale `Runtime isolation whitelist assertion failed.` malgré le correctif null-port. Digest attendu téléchargé et cleanup `containerPresentAfterRemove=False` réussis.

**UNKNOWN bloquant** — sous-cause parmi `dangerousMounts`, réseaux, ports et `targetScopeValid`; le défaut null offline n’explique pas à lui seul l’échec. Aucun rejeu métier.

**FACT** — la tête active neutre est `2fd2830b...`. Les quatre commits du préflight sont audités par API avec auteurs/messages; aucun ne contient `codex`. Les anciennes mentions `codex` restent des traces historiques conservées.

**FACT local / UNKNOWN runtime** — le garde-fou `Assert-V22IsolationAttestation.ps1` exige une attestation et une politique produites par l’hôte avant toute action métier, mais aucun producteur hôte n’est fourni. Aucun run métier n’est autorisé ou exécuté.

## 2026-09-07 — État courant supersédant — 4442152 et defaultBranch neutre

**FACT** — la preuve primaire round13 relit `defaultBranch=refs/heads/investigation/wi-2222897-v22-preflight-20260907`; l’ancien constat `defaultBranch` pointant vers `codex/...` est historique et supersédé.

**FACT** — `4442152` a exécuté le commit `a2a442c98f05b2e57d02a98fd7228967ee4104df` sur la branche neutre. Digest attendu téléchargé et cleanup `containerPresentAfterRemove=False` réussi.

**BLOCAGE FACT / UNKNOWN** — l’inspection échoue sur l’assertion globale `Runtime isolation whitelist assertion failed.`; la sous-cause exacte reste UNKNOWN parmi mounts, réseaux, ports et `targetScopeValid`. Aucun rejeu métier n’a eu lieu.

**FACT limité** — `4442120` est conservé comme succès antérieur d’acquisition/préflight, sans preuve d’isolation. `cd632126...` n’est pas la tête à citer pour `4442152`. Auteurs/messages de commits restent à vérifier; les traces historiques `codex` sont conservées.

## 2026-09-07 — Audit live finalisé et préflight neutre 4442120

**FACT** — la branche partagée `refs/heads/codex/wi-2222897-v22-preflight-20260907` a été supprimée côté serveur. La branche neutre `refs/heads/investigation/wi-2222897-v22-preflight-20260907` porte le commit `cd632126c17f3ac95c8a29b079d0e243fa538e54`, parent `5036e501...`; aucune réécriture d’historique n’est rapportée.

**Portée** — `cd632126...` est le commit utilisé/relu pour `4442120`, pas une preuve de tête actuelle après ce run. Le constat historique d’absence du SHA `a2a442c98f05b2e57d02a98fd7228967ee4104df` est supersédé par la preuve primaire round13, qui l’identifie comme commit exécuté par `4442152`.

**FACT** — définition `14246` active et nommée `WI-2222897 V22 Runtime Preflight 20260907`; aucun PR associé, aucune ref `codex` active et aucun run actif dans la fenêtre live interrogée. **Résidu modifiable** : `repository.defaultBranch` pointe encore vers l’ancienne ref `codex/...` supprimée.

**UNKNOWN ciblé** — auteur/message du commit `cd632126...` non présents dans les preuves relues. Aucun élément créé Azure Portal/JFrog n’est identifié dans le périmètre; seule l’utilisation du service connection/ACR existant est prouvée, sans audit global.

**FACT limité** — run `4442120` réussi après preview du commit corrigé : référence ACR complète, login, inspection host/image/container/mounts/network, hashes et finalisation réussis. Les détails runtime n’ont pas été publiés; aucun rejeu métier ni stage métier n’a été exécuté.

**SUITE** — ne pas corriger `defaultBranch` vers une cible supposée. La branche `sandbox/WI-2222897-v22-preflight-20260907` est absente; il faut une cible neutre existante ou une autorisation explicite de recréation. Les éléments historiques et les preuves locales round3 restent conservés et séparés de la validation runtime.

## 2026-09-07 — Audit borné des traces partagées `codex`

**FACT** — la preuve round11 identifie la branche partagée `refs/heads/codex/wi-2222897-v22-preflight-20260907`, dépôt `Y2_Plugins_FrenchTaxesRules`, SHA `5036e501...`, consommée par la définition `14246`. Les occurrences documentaires sont conservées comme historique de provenance.

**FACT** — les runs V22 indexés sont `4441699`, `4441719` et `4442003`; aucun build/log ne sera supprimé. La correction complète du hostname ACR n’est pas publiée sur le SHA exécuté.

**FACT / conflit local** — `worktrees/Y2_Plugins_FrenchTaxesRules` est signalé modifié par l’échec du checkout round11. La lecture Git locale est bloquée par `dubious ownership`; aucune restauration, nettoyage ou modification de configuration globale n’a été faite.

**UNKNOWN** — PR, messages de commit, autres branches/définitions/runs, et éventuelles traces Azure/JFrog hors des éléments indexés n’ont pas été vérifiés live dans ce processus. La CLI est bloquée par le profil global; ne pas interpréter cet échec comme une absence de traces.

**Règle active** — toute nouvelle branche, définition, commit, PR ou entité partagée doit avoir un nom/message neutre, sans `codex`. Worker 3 n’a effectué aucune correction distante; la correction de la branche signalée reste attribuée à Worker 1.

## 2026-09-07 — Reprise documentaire Round 2 — confirmation ACR et portée du run 4442003

**FACT rapporté par l’utilisateur** — `AcrRetailDocker` expose le `loginServer` exact `acrretaildocker-e2c3ugzbee2habm.azurecr.io`.

**FACT rapporté et indexé** — le digest historique `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb` est présent dans `cegid-retail-docker-production/y2-jmeter` sous le tag `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`, selon la vérification Azure CLI rapportée et la collecte [round10](../investigations/ecarts-jmeter-migrations/evidence/azure-devops-french-taxes-rules-v22-worker1-round10/README.md).

**FACT** — `4442003` a exécuté l’ancien commit `5036e501...`; son `docker pull` est resté non qualifié et a échoué avant création de conteneur. Ce run n’intégrait pas la correction locale du hostname.

**INFERENCE / UNKNOWN** — `4442003` ne constitue donc pas une conclusion négative sur le hostname confirmé ni sur les droits ACR. Restent à prouver l’acquisition avec la référence complète, le runtime/isolation, la consommation des packages et le résultat métier. La readiness Worker 2 round1 conserve ses constats de secret et de comparaison sous vérification; aucune conclusion anticipée n’est ajoutée.

**Suite documentaire** — reprendre dans [HANDOFF.md](../investigations/ecarts-jmeter-migrations/HANDOFF.md), section « Reprise documentaire Round 2 », avec les critères d’arrêt et de preuve détaillés. Aucun lancement distant, candidat ou dépôt n’a été modifié dans cette reprise.

## 2026-09-07 — Candidat FrenchTaxesRules V22 complet, fail-closed

**FACT** — le pipeline local `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/azure-pipelines.candidate.yml` est structuré avec image digestée, commits JMeter/PlatformDeploy/plugin, restauration/déploiement inline, stages Fix historique puis candidat, trois opérations discriminantes, campagnes 376 tests, aucune publication d'artefact et nettoyage borné.

**FACT** — le contrôle local vérifie la disponibilité SQL Server/IIS et ports 1433/80, sans prétendre prouver l'isolation du container, ses mounts ou l'absence de ressources partagées; aucun secret n'est affiché par les étapes inline. Les scripts PowerShell du runner passent l'analyse syntaxique locale.

**FACT** — PlatformDeploy `5.0.86` et son ZIP SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295` sont établis par la collecte Worker 1 round4 et renseignés dans le YAML.

**UNKNOWN bloquant** — identité/cycle de vie réel du container, mounts, cibles partagées et compatibilité agent restent non prouvés; aucun pipeline lancé. Le verdict métier des 174 refus reste UNKNOWN.

**FACT — validation locale positive/inertée** : le préflight accepte l'image complète `registry:tag@sha256` et vérifie le snapshot V22 (`jmx=32`, `hashes=32`, `legacy=232`, `web=144`, `total=376`, `no writes performed`). Le dry-run confirme l'ordre baseline historique → 3 opérations → campagne 376. Les digest/hash invalides sont refusés avant écriture. Aucun résultat métier n'est revendiqué.

**FACT — corrections round5** : PlatformDeploy 5.0.86/hash exact intégrés; checkout plugin séparé et épinglé; `-verbose` supprimé; clé JFrog hors arguments de sous-processus, paramètres ACL-restreints et non collectés; collecte expurgée et assertion 232+144 ajoutées. Le manifeste de fichiers est `replay-prep/2026-09-07-v22-isolated/MANIFEST.sha256`.

**FACT — round6 Worker 1** : les hashes des trois ZIP baseline (`7BAB...0573`, `037D...0CAD`, `23AE...59FF`) et le digest ACR historique `sha256:268476...4da9cb` sont intégrés dans `PACKAGE-SHA256SUMS.txt` et le YAML. La comparaison des 174 refus par scénario/signature est dans `V22-174-REFUS-COMPARISON.md`.

**FACT — tests substitués** : `Test-V22ReplayFailureModes.ps1` passe pour échec baseline, échec candidat/cleanup et nombre incorrect. Aucun rejeu métier ni preuve d'isolation runtime n'est revendiqué.

## 2026-09-07 — Revalidation primaire InventoryTracking migration

**FACT** — la collecte Worker 2 round2 supersède explicitement l'ancien blocage global d'accès Azure DevOps pour les seuls faits couverts par cette collecte : `4434070` est le build de `InventoryTracking_Migration_AutoTest_Jmeter_On_master` au commit `4de185bb...`, pas un run direct de `refs/heads/master`. Preuve : [collecte primaire](../investigations/ecarts-jmeter-migrations/evidence/azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md).

**FACT** — `Ensure_Docker_Image_Up_To_Date` et les contrôles image/ACR passent; `Build V26` échoue dans VSBuild log 51 avec `MSB3245` sur `Cegid.Retail.XmlDiff`, puis quatre `CS0103`. Les stages `TI JMeter V26`, Cur et Fix sont skipped.

**INFERENCE** — la cause immédiate est l'acquisition/résolution manquante de XmlDiff après suppression du `WebServices.Tests/packages.config`, qui portait `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28`, tandis que `Services.Tests` conserve la référence Y2Core.

**UNKNOWN** — mécanisme exact package/restore/template, correctif validé, PR de migration, lecture live du WI/relations, campagnes JMeter et livrables Excel/notification. Le master `4435986` réussi ne valide pas la migration : son YAML ne déclare pas `TI_Jmeter_V26`.

L'ancien bloc `Vérification finale du blocage InventoryTracking 4434070` ci-dessous est conservé comme historique des échecs TLS/navigateur de ce processus, mais ne décrit plus l'état global des preuves Azure DevOps.

## Clôture documentaire CleanXpath — 2026-09-07

**FACT** — la collecte offline JMeter 5.6.3 est terminée : ZIP officiel conservé, SHA-512 `MATCH`, runtime et harnesses XPath exécutés avec code `0`. La collecte canonique est [indexée ici](../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/README.md).

**FACT** — avec `namespace=false`, `//Fault` ne matche pas un Fault SOAP préfixé ; avec `namespace=true`, mapping SOAP et `//soap:Fault`, les préfixes variables du même URI matchent et le mauvais namespace testé est rejeté.

**INFERENCE** — `CleanXpath` supprime le XPath invalide `//`, mais `//Fault` ne suffit pas pour la sémantique SOAP des JMX actuels. Le générateur doit être étudié pour une configuration namespace-aware ciblée. **UNKNOWN** — SOAP 1.2, propagation package/migration, régénération complète et rejeu métier. L’investigation métier n’est pas déclarée terminée.

Complément ciblé **2026-09-07 — packaging V22 / conseil de Ludo** : [finding 004](../investigations/ecarts-jmeter-migrations/findings/004-french-taxes-rules-v21-v23-build-4429167.md) complétée. **FACT** : manifeste et ZIP 22.0.23 retrouvés en production JFrog, trio Core/Common/Identity disponible ; les journaux MSI du build 4429167 prouvent aussi l'installation historique des versions Cur/Fix avec statut `0`. **UNKNOWN** : consommation effective des binaires, catalogue/projection `allowedModule` et correction des 174 refus FrenchTaxesRules V22 Fix ; aucun correctif ni rejeu réalisé. Prochaine validation proposée : avant/après isolé avec plugin et AuthenticationServer constants, trois opérations puis 376 tests. Ce sujet est distinct du rejeu V26 en pause ci-dessous. [Collecte datée](../investigations/ecarts-jmeter-migrations/evidence/2026-09-07-jfrog-v22-packaging/README.md).

Complément ciblé **2026-09-07 — handoff manuel, mécanisme DLL d'autorisation** (non revérifié) : le trio candidat ci-dessus restaurerait, via `ExternalsToRestore.xml`, le même NuGet `FWK-CEGID-NET-FULL 12.9.185` que Current V22 — donc la même DLL `Cegid.Erp.Services.Implementation 12.9.185.17` — contre `12.9.153.1506` chargée par le Fix historique. **UNKNOWN inchangé** : correction réelle des 174 échecs, non démontrée sans le replay isolé. [Détail](../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-french-taxes-rules-v22-authorization-handoff/README.md).

Snapshot local : **2026-09-06**. Revalider les états Azure DevOps, branches, builds, packages et environnements avant toute action distante ou conclusion actuelle.

## 2026-09-07 — Prérequis artefacts rejeu FrenchTaxesRules V22

**FACT** — le snapshot exact du build 4429167 ne contient qu'un backup `AUTO_V21_00.bak` (SHA-256 `3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2`, 150515712 octets). Le YAML transmet `Tests/Backups` et utilise `DB_NAME=$(backupName)`, mais la valeur de groupe n'est pas disponible ; ne pas présupposer un backup V22.

**FACT** — les manifests sélectionnent 12 JMX LegacyServices et 20 WebServices, dont les trois cas minimaux identifiés. **UNKNOWN** — backupName résolu, restauration, substitutions finales SQL/IIS et cible dédiée. Aucun lancement, restauration ou mutation externe.

La collecte est [indexée ici](../investigations/ecarts-jmeter-migrations/evidence/2026-09-07-v22-replay-prereqs/README.md). Le dossier JFrog revalidation contient seulement son README de synthèse ; les ZIP et hashes séparés ne sont pas conservés.

**Complément** — le brouillon local [replay-prep/2026-09-07-v22-isolated/](../investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/) a été durci : hash backup obligatoire, attestation JSON structurée SQL/IIS, restauration séparée Cur/Fix, 32 JMX historiques et 32 JMX d'entrée, vérification syntaxique PowerShell et refus négatif inerte. Il reste bloqué par l'absence d'un commit immuable approuvé de `Pipelines_Templates`, de cibles dédiées résolues et de la preuve d'exécution jusqu'à `jmeter -t`.

Précision : les 32 JMX historiques peuvent être utilisés directement ; aucune régénération n'est requise. Le runner est seulement vérifié statiquement jusqu'à `jmeter.bat -n -t`.

## 2026-09-07 — Vérification finale du blocage InventoryTracking 4434070

**FACT** — la lecture live du build `Y2_Plugins_InventoryTracking/master`, build `4434070`, reste impossible. `az pipelines build show` est bloqué par absence de session CLI; l’unique action navigateur tentée (`cua.createBrowserTab` vers l’URL du build) a été refusée avec le motif explicite « user declined permission » pour `https://dev.azure.com`. Aucun connecteur Azure DevOps autorisé n’est disponible.

**UNKNOWN** — cause racine, premier task causal, timeline, commit/YAML exacts, exécution des campagnes V26, image/ACR et build master plus récent. Ne pas transformer l’hypothèse image/ACR en cause.

**Suite** — obtenir une exportation ou session de lecture autorisée contenant métadonnées, timeline, premier log causal et YAML/templates résolus au commit exact; comparer ensuite au build master le plus récent. Le critère de réussite est l’exécution prouvée de Build et des campagnes V26 attendues, puis l’inventaire des erreurs métier, et non zéro échec métier par défaut.

Complément inventaire **2026-09-07** : intégration du bilan intermédiaire fourni par l'utilisateur pour la semaine précédente dans [le snapshot de suivi](../documentation/tracking/2026-09-07-bilan-intermediaire-semaine-precedente.md). Il couvre 18 couples dépôt/branche/version déclarés `InProgress`, avec les builds/PR et échecs rapportés pour FrenchTaxesRules, InventoryTracking et Clienteling. **FACT de provenance :** le contenu est un état rapporté, reçu le 2026-09-07 ; la date exacte des observations n'est pas fournie. **UNKNOWN :** fraîcheur actuelle, causes des échecs, résultat final des jobs et comparabilité legacy/JMeter tant que les preuves associées ne sont pas relues.

Mise à jour de reprise **2026-09-07** : un contrat offline minimal pour `Export_Run` a été préparé et vérifié sans modifier de dépôt. Le descripteur sans namespace sélectionne exactement un JMX direct, dont la copie et le hash sont contrôlés avant invocation théorique. Les blocages agent/acquisitions, cibles SQL/IIS avant écriture, secrets d'archive et isolation restent actifs ; résultat métier `UNKNOWN`.

Complément **2026-09-07** : copie de travail durcie du brouillon créée sous `evidence/local-2026-09-07-v26-fix-replay-draft-hardened/`. Harness inerte : bon JMX transmis au substitut; fichier absent et hash incorrect refusés avant invocation. Le préflight exige désormais une preuve explicite de cible dédiée et refuse les hôtes non résolus. Aucune exécution métier; disponibilités externes et réussite métier restent `UNKNOWN`.

Historique supersédé **2026-09-07** : la première tentative de compilation de FixSqlUnicodeValue était bloquée par `MSB3644` (assemblies de référence absentes). Cette ligne ne décrit plus l'état de la compilation isolée et est conservée uniquement comme trace de l'obstacle initial.

Mise à jour **2026-09-07** : la compilation isolée avec les façades/staging du 2026-09-06 réussit, le test durable appelle la DLL corrigée et la génération intégrée ItemSearch:Keywords TC02 confirme `NN'` avant contre `N'` après. Le blocage MSB3644 est levé uniquement pour cette sortie isolée; package, propagation Console/migration et rejeu métier restent `UNKNOWN`.

## 2026-09-07 — Consolidation des preuves locales

FACT — la compilation isolée net452 de FixSqlUnicodeValue est réussie avec le staging BuildTools/façades documenté ; l'ancien état `MSB3644` est supersédé pour cette sortie isolée uniquement. La génération Console/API→JMX de `ItemSearch_Keywords.xml` et des quatre plans Mobility/ItemSearch est prouvée par codes `0`, hashes et comptages. Cela ne prouve ni le package/migration, ni l'orchestration, ni le rejeu métier.

FACT — le contrat offline Export_Run est vérifié : le descripteur sans namespace pointe vers un JMX direct hashé et son contrôle retourne `nodes=1`, extension `.jmx`, hash identique et 86 `JDBCSampler`. INFERENCE — le raccord documentaire est démontré localement. UNKNOWN — ce contrat n'est pas installé dans un checkout de migration et aucun run métier n'a été exécuté.

Historique supersédé par la vérification réelle JMeter 5.6.3 ci-dessus : `//Fault` corrige la génération invalide `//`, mais échoue sur le Fault SOAP préfixé avec `XPath.namespace=false`; la configuration namespace-aware et le mapping SOAP sont démontrés séparément. La propagation et le rejeu restent UNKNOWN.

## 2026-09-07 — Correction locale CleanXpath

FACT — `CleanXpath` corrige `/soap:Fault` → `//` en conservant le nœud (`//Fault`). Compilation API net452 isolée code 0 avec BuildTools 17.14.14, targeting pack 1.0.3 et façades stagingées; six contrôles CleanXpath et neuf vecteurs Unicode appellent la DLL de production et passent. La source legacy `ItemSearch_Keywords.xml` est retrouvée dans l'archive indexée; le JMX du harness Unicode était déjà transformé, donc la génération intégrée complète depuis cette XML reste UNKNOWN. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-cleanxpath/`. Le brouillon Round 4 reste un préflight avec runner JMeter substitué, sans attestation SQL/IIS; Java 23 détecté, Java 21 cible non validée.

Historique supersédé pour la génération source : une première tentative Console depuis un staging profond a échoué sur `PathTooLongException` avant génération. Aucun contournement hors workspace n'a été utilisé. Cette limite a ensuite été levée pour un staging court documenté dans `local-2026-09-07-four-plans-integrated/`.

Génération intégrée réelle réussie dans le staging temporaire court autorisé : Console originale et corrigée, source legacy ItemSearch_Keywords.xml, code 0, JMX distincts et SQL TC02 corrigé observé. Les quatre plans Mobility/ItemSearch sont également générés 4/4 par variante; 682 SQL et 185 XPath parsés. RemoveSpecialCharsForXQuery est compilée et testée sur quatre vecteurs publics, avec échappement XML observé dans les JMX corrigés. Contrôle namespace local: `//Fault` ne sélectionne pas un Fault SOAP namespace-aware; le moteur JMeter complet n'étant pas disponible, portée UNKNOWN. Preuve : `evidence/local-2026-09-07-xpath-engine-semantics/`. Migration, JMeter métier et rejeu restent UNKNOWN.

Acquisition officielle Apache JMeter 5.6.3 et validation XPath sont désormais démontrées : ZIP conservé, SHA-512 `MATCH`, runtime JMeter code `0`, harnesses réels code `0`. **FACT** : avec `namespace=false`, `//Fault` ne matche pas un Fault SOAP préfixé ; avec `namespace=true`, mapping SOAP et `//soap:Fault`, les préfixes `soap`/`env` du même URI matchent et le mauvais namespace est rejeté. **INFERENCE** : `CleanXpath` corrige la syntaxe invalide `//`, mais pas la sémantique SOAP complète ; le générateur doit produire une configuration namespace-aware ciblée. **UNKNOWN** : SOAP 1.2, propagation package/migration, régénération complète et rejeu métier. Voir `investigations/ecarts-jmeter-migrations/findings/012-jmeter-5-6-3-xpath-namespace.md` et `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/`.

## 2026-09-07 — Voies Azure DevOps read-only et plan de rejeu isolé (Worker 3)

**FACT** — aucune capacité Azure DevOps dédiée n’est exposée dans cette session. La CLI locale échoue avant lecture sur `PermissionError` de `C:\Users\jegour\.azure\azureProfile.json`. Edge ne contient aucun onglet Azure DevOps ; une tentative read-only vers `https://dev.azure.com/cegid/Retail/_build` a été refusée par la politique utilisateur. Aucun contournement, changement d’identité ou secret n’a été tenté.

**FACT** — les preuves datées existantes restent la seule base exploitable : définition 5224 `Y2 Tools Jmeter Workflow`, dépôt `Y2_Tools_Jmeter_Workflow`, agent hébergé Azure Pipelines, YAML master avec triggers master/releases, stages Docker, publication JFrog/BuildInfo, Promote et Tag_Sources ; le YAML `sandbox/tests_rje` désactive ces effets externes mais conserve la publication PipelineArtifact. Voir `evidence/azure-devops/pipeline-5224/`.

**FACT** — le brouillon V26 Fix `ExportRunOnly` désactive ses triggers et limite la publication à un PipelineArtifact, mais son job ferait encore des écritures sur l’environnement : restauration backup, déploiement containerisé, SQL/IIS/configuration, téléchargements packages/PlatformDeploy et appels HTTP/SQL JMeter. Les paramètres d’agent LTSC2025, registre/image, PlatformDeploy, packages, backup, checkout, hôtes dédiés et variables secrètes ne sont pas tous prouvés.

**INFERENCE** — aucun rejeu Azure DevOps n’est suffisamment isolé pour être proposé à la queue dans ce lot. Une future queue doit utiliser une définition/branche dédiée, `trigger: none`, `pr: none`, `schedules: []`, `pipelineDevMode=false`, image par digest, JMX et backup hashés, marqueur de cible dédiée et contrôles pré-écriture. Arrêt au premier hôte ambigu, secret journalisé, publication externe, cible partagée ou stage attendu non exécuté.

**HISTORIQUE / supersédé pour 4434070** — cette section décrit l'accès de ce processus avant la collecte Worker 2 round2. La cause immédiate, la branche de migration et la timeline sont désormais prouvées dans la section primaire en tête; restent UNKNOWN le mécanisme package/restore/template, le correctif, le résultat métier et la propagation package/migration.

Voies locales encore investigables sans pipeline : propagation API→Console→migration de `FixSqlUnicodeValue`, puis régénération contrôlée ; comparaison des cas Clienteling dominants (FTS, défauts générateur, XML, endpoints et fixtures) ; TC22 FrenchTaxesRules et TC32 Clienteling restent des échecs communs legacy/JMeter, non des régressions démontrées. Aucun résultat Worker 1/2 nouveau n’était disponible au-delà des consolidations déjà présentes.

## 2026-09-07 — Revue indépendante du correctif SOAP round13

**FACT** — le contrat réel 4432510 inspecté contient `s:Fault` SOAP 1.1, puis `detail` et `faultcode` sans namespace propre. Le XPath round13 conserve `/detail/faultcode` après le prédicat namespace-aware ; cette forme est donc compatible avec le contrat observé. Les assertions round13 positives/négatives testées couvrent Fault présent, absence de Fault, mauvais namespace et préfixes variables.

**FACT** — round13 produit la DLL SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`. Le package Console local précédent référence une autre DLL SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81` ; **51FB31... ne contient pas, par cette preuve, le correctif SOAP 57BEAC...**. La propagation package/migration SOAP est donc UNKNOWN.

**FACT** — 377 JMX réels contiennent une assertion Fault, dont 40 avec négation (`XPath.negate=true`) et aucun avec `XPath.namespace=true`. **UNKNOWN** — round13 n’a pas exécuté d’assertion négative générée avec `ExpectedValue=0`; conserver la logique de négation ne vaut pas preuve d’exécution.

**INFERENCE** — le correctif générateur est ciblé aux chemins `soap:Fault` et ne doit pas modifier les assertions non SOAP. SOAP 1.2 n’est pas généralisé faute de contrat dans le périmètre.

## 2026-09-07 — Worker 3 Round 2 — Clienteling fixtures

**FACT** — onze fixtures JPG sont présentes dans l'historique V6, zéro image dans le snapshot Clienteling 4432602, et `CustomImageLocation` reste le placeholder `${tests.folder}\\${CustomImageFolder}`. Le template PlatformDeploy inspecté ne copie ni ne monte explicitement `CustomImage`/`ImageFolder`.

**FACT discriminant** — le test local [fixture-transport-check.ps1](../investigations/ecarts-jmeter-migrations/evidence/2026-09-07-brain-reprise-worker3/fixture-transport-check.ps1) résout une fixture factice via un chemin absolu et rejette le placeholder littéral. **UNKNOWN** — propriétaire du transport, chemin IIS final et support métier. PlatformDeploy exact pour 4432602 reste UNKNOWN; aucune queue ni mutation distante.

## 2026-09-07 — Préflight runtime V22 dédié Worker 1 round7

**FACT** — branche dédiée `codex/wi-2222897-v22-preflight-20260907`, commit YAML corrigé `5036e501ba797ab7efc861add60b111a40ff8141`, définition dédiée `14246`, triggers désactivés, checkout:none, image historique épinglée `sha256:268476...`.

**FACT** — validation preview serveur HTTP 200. Run `4441699` a échoué sur le traitement du stderr attendu de `docker image inspect` quand l’image n’était pas en cache ; run `4441719` a atteint l’acquisition réelle : Docker login `succeeded`, checkout `skipped`, puis `docker pull` refusé : `pull access denied for cegid-retail-docker-production/y2-jmeter, repository does not exist or may require 'docker login'`.

**VERDICT** — preuve runtime OS/image/conteneur/mount/réseau non obtenue. Aucun conteneur n’a été créé, aucune base restaurée, aucun package déployé, aucun appel métier/JMeter lancé. Le rejeu reste NOT RUN. Blocage précis : autoriser le service connection `AzureContainerRegistry-Docker-Retail` au repository historique ou fournir une source d’image équivalente explicitement approuvée.

**Correction round8** — cette formulation ne doit pas être lue comme une preuve de droits manquants : le login du service connection ciblait l’ACR `AcrRetailDocker`, tandis que le `docker pull` était non qualifié et pouvait viser le registre Docker par défaut. Une correction locale reviewable ajoute `acrretaildocker.azurecr.io/` devant le repository ; aucune nouvelle queue n’a été lancée. Preuve : `evidence/azure-devops-french-taxes-rules-v22-worker1-round8/`.

**Round9 — précision** : `AcrRetailDocker.azurecr.io` reste une inférence de nommage, pas un fait prouvé par les métadonnées AzDO. Le `loginServer` exact n’est pas exposé ; le patch round8 est donc une proposition locale non exécutable. Aucun nouveau préflight lancé. Intervention minimale : lecture ARM non sensible du `loginServer` ou confirmation par le propriétaire du service connection. Preuve : `evidence/azure-devops-french-taxes-rules-v22-worker1-round9/`.

## Vérification Console du 2026-09-06 — complément

FACT — les deux codes -1 de l'essai précédent ont été levés par un chemin court et input.xml dans TestPlans. Console officielle avec API corrigée : code 0, six JMX et six assertions conformes ; API originale : code 0, quatre écarts ISO et deux témoins conformes. [Preuve](../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-console-quick-diagnosis/README.md). Aucun pipeline nécessaire à ce déblocage. Compilation source Console, packaging, Docker et rejeu métier restent UNKNOWN.

## Export_Run complet du 2026-09-06 — préparation rejeu métier

FACT — la génération Console du plan complet `Export_Run` est validée avant/après, avec deux codes `0` et comparaison des JMX dans [la preuve dédiée](../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-export-complete-before-after/). UNKNOWN — aucune réussite métier : aucun JMeter, SQL, HTTP ou environnement Y2 n'a été exécuté pour ce rejeu. La pile cible, le digest image et le mécanisme backup ont depuis été identifiés, voir le handoff de pause. Hash historique du backup, acquisitions effectives et faisabilité du brouillon restent à vérifier ; aucune définition de rejeu créée.

