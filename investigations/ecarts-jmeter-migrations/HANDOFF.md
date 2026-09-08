# Handoff — causes des résultats JMeter non passés sur les migrations restantes

## 2026-09-07 — Worker 2 round7 : 4442696 terminé avec préflight borné réussi

**FACT** — la collecte [Worker 1 round25](evidence/azure-devops-french-taxes-rules-v22-worker1-round25/README.md) supersède l’état provisoire round24 : le run unique `4442696` est `completed/succeeded`, au commit `68f1f7a8e575e79cf3098cafcd16e10b22237ada`, avec le YAML `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.

**FACT** — l’image a été tirée au digest attendu ; checkout skipped ; aucune étape métier ni publication d’artefact n’existe. Les sous-verdicts image-digest, OS Windows, architecture amd64, target-scope, mounts, networks et ports sont PASS. Le runtime rapporte `mounts=count=0; dangerous=0`, `containerState=created`, attestation PASS et `containerPresentAfterRemove=False`.

**UNKNOWN conservés** — `Config.Volumes` n’est pas observable dans les sorties persistées ; l’ID complet du conteneur n’est pas conservé ; l’origine/cycle de vie du mount historique `4442225` (`mounts=1; dangerous=1`) n’est pas expliquée par ce succès. Une absence de mounts dans 4442696 ne démontre pas que le mount historique était un faux comptage null, et ne prouve pas l’absence de partage dans les futurs jobs.

**Portée** — ce résultat clôt le diagnostic autorisé du préflight borné, pas l’attestation d’isolation des futurs jobs `Agent.ContainerMapping`, la consommation de packages, ni un résultat métier. Aucune collecte supplémentaire n’est nécessaire pour le préflight lui-même ; une investigation distincte serait requise pour relier l’ancien mount à son cycle de vie, sans assouplir la whitelist.

## 2026-09-07 — Worker 2 round6 : état final partiel du run 4442696

**FACT** — la collecte [Worker 1 round24](evidence/azure-devops-french-taxes-rules-v22-worker1-round24/README.md) porte sur le run unique `4442696`, définition `14246`, commit exécuté `68f1f7a8e575e79cf3098cafcd16e10b22237ada`, branche neutre et YAML SHA-256 `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.

**FACT** — `Initialize job` et l’authentification registry ont réussi ; checkout est skipped ; le stage `RuntimePreflight` et l’étape `Read-only host/image/container inspection` restent `inProgress` à `0%` ; la hashification finale est pending. Aucun stage métier, artefact publié ou second run n’est prouvé.

**FACT** — au snapshot `2026-09-07 20:08 UTC`, le run était encore `inProgress` après la limite YAML `timeoutInMinutes: 10`, avec timeline figée à `19:55:14Z`. Les logs disponibles couvrent seulement l’initialisation/login et ne contiennent pas de projection `Config.Volumes`, mounts, identité conteneur, sous-verdicts ou cleanup.

**UNKNOWN** — image réellement inspectée, conteneur créé, `Config.Volumes`, mounts, sous-verdicts et `containerPresentAfterRemove`. Une destination attendue ou une correspondance de whitelist future ne prouvera pas à elle seule l’origine du mount, son cycle de vie ni l’absence de partage hôte.

**Portée timeout/cleanup** — le YAML impose statiquement 10 minutes de job et 1 minute de délai d’annulation ; cela ne prouve pas que le processus bloqué a terminé ni que `finally` a exécuté `docker rm -f`. Le cleanup est conditionné à `$created`, donc l’état runtime reste UNKNOWN si la création ou la terminaison n’est pas confirmée.

**Suite discriminante read-only** — obtenir uniquement la timeline/logs finaux ou l’état d’annulation du run, puis vérifier les sorties scrubbed du même commit ; ne pas extrapoler aux futurs jobs `Agent.ContainerMapping` ni au métier.

## 2026-09-07 — Worker 2 round4 : réconciliation des hashes et HTTPS Python

**FACT** — `0D2D781CF054CD4644C46552AB610544282D4CDD805EDCE9D197F66C151A0D5B` est reproduit en appliquant au YAML exact `DB8ED1...` uniquement le filtre null de `patch-null-safe.diff`. Cette reconstruction ne contient ni `Config.Volumes` ni la projection scrubbed des mounts.

**FACT** — le candidat réellement testé reste `replay-prep/2026-09-07-v22-round21-review/azure-pipelines.wi2222897-v22-preflight.null-safe.yml`, SHA-256 `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`. L’écart est fonctionnel : la projection diagnostique manque dans le résultat `0D2D...`; les hashes restent identiques en LF et dans la forme source, donc ce n’est pas un problème d’encodage ou de fins de ligne.

**FACT** — le test de réconciliation et le test du candidat passent. Le YAML candidat conserve whitelist, timeout, collecte avant assertion, cleanup borné et absence de métier/publication.

**FACT** — la relecture Azure DevOps par Python/OpenSSL avec validation certificat/hostname a obtenu HTTP 200 et relu la branche neutre ainsi que la définition `14246`; aucun run actif n’a été trouvé. Schannel n’est donc plus un blocage global de lecture Azure DevOps, même si son échec historique reste documenté pour les clients concernés.

**VERDICT** — le chemin absolu du candidat à transmettre à Worker 1 est `C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897\investigations\ecarts-jmeter-migrations\replay-prep\2026-09-07-v22-round21-review\azure-pipelines.wi2222897-v22-preflight.null-safe.yml`. Ne pas substituer le résultat `0D2D...` au candidat `659DE...`.

## 2026-09-07 — Worker 2 round3 : candidat null-safe approuvé localement

**FACT** — la source exacte du commit `44070560cc855b461f5a307c9438a203e67cebe4` est vérifiée localement par le fichier indexé `evidence/azure-devops-french-taxes-rules-v22-exact-yaml-44070560/azure-pipelines.wi2222897-v22-preflight.yml`, SHA-256 `DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A`.

**FACT** — le candidat round21 initial est rejeté : `inspection.Mounts=$null` produisait un pseudo-mount. Le candidat corrigé est matérialisé dans `replay-prep/2026-09-07-v22-round21-review/azure-pipelines.wi2222897-v22-preflight.null-safe.yml`, SHA-256 `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`. Le filtre null est le seul correctif supplémentaire.

**FACT** — `Test-V22NullSafeCandidate.ps1` passe : syntaxe inline `0`, null mounts `0`, multiple mounts `2`, RW conservé, masquage conservé, whitelist et cleanup inchangés. Le diff complet et la preuve sont indexés dans `evidence/azure-devops-french-taxes-rules-v22-worker2-round3/`.

**FACT d’autorisation** — l’autorisation utilisateur actuelle couvre explicitement le seul patch diagnostic V22 sur branche dédiée et le diagnostic borné `14246`; elle supersède le constat documentaire antérieur d’autorisation insuffisante pour ces deux actions, sans autoriser métier, publication d’artefact, assouplissement de whitelist ou cleanup partagé.

**UNKNOWN / limite** — Schannel/TLS a été observé comme échec de lecture authentifiée dans le test Worker 1 (`SEC_E_NO_CREDENTIALS`), mais cela ne permet pas de déclarer l’accès définitivement impossible. Aucun accès distant n’a été tenté dans ce round.

## 2026-09-07 — Clôture V22 round4 : patch diagnostic et demande humaine

**FACT** — le patch local round20 ajoute une projection expurgée de `Config.Volumes` et des mounts (`name`, `type`, `source`, `destination`, `rw`) sans modifier les contrôles, la whitelist, l’image, le cleanup ni le comportement métier. Le test inerte local passe.

**FACT / UNKNOWN** — le commit rapporté de `4442225` est `44070560cc855b461f5a307c9438a203e67cebe4`, mais cet objet est absent du clone local (`bad object`). Le YAML local non suivi a été hashé `D1B53E1F2A6E7ED5C2B0450A957AC9693D4295064190FE035A69A977523646F4`; son lien cryptographique avec ce commit reste UNKNOWN. L’accès REST authentifié a échoué précédemment; aucun secret n’est demandé ni exposé.

**FACT documentaire** — le contrat runtime round11 corrige le transport vers `Agent.ContainerMapping.v22Jmeter.id`, avec tests locaux passés; la disponibilité et la propagation sur un run réel restent UNKNOWN. Les mounts runtime et leur transport hôte→conteneur restent UNKNOWN.

**VERDICT** — aucune publication, queue, Docker, checkout, restauration, déploiement ou exécution métier n’a été réalisée dans ce lot. Le rejeu reste bloqué par l’isolation non prouvée.

**Demande humaine unique** — rétablir la lecture authentifiée du YAML exact du commit `44070560...`, puis autoriser explicitement la publication du seul diagnostic `Config.Volumes`/mounts sur la branche dédiée et une queue de la définition `14246`, strictement read-only côté métier, sans assouplissement de whitelist, sans artefact publié et avec cleanup borné. Cette demande sépare l’autorisation manquante du problème technique d’authentification et ne requiert aucun secret dans la conversation.

Références : [patch round20](evidence/azure-devops-french-taxes-rules-v22-worker1-round20/patch.diff), [contrat runtime round11](evidence/2026-09-07-v22-runtime-contract-worker2-round11/README.md), [test inerte](evidence/azure-devops-french-taxes-rules-v22-worker1-round20/Test-V22MountProjection.ps1).

## 2026-09-07 — Round20 : portée de l’autorisation et décision après round19

**FACT — texte exact de l’autorisation originale** — la preuve [round10](evidence/azure-devops-french-taxes-rules-v22-worker1-round10/README.md), section « Périmètre et autorisation », dit : « **L’action de queue était explicitement limitée à ce préflight runtime et à cette branche/définition par la délégation Worker 1.** » Le contexte est la définition `14246`, le dépôt `Y2_Plugins_FrenchTaxesRules`, la branche dédiée alors utilisée et le service connection `AzureContainerRegistry-Docker-Retail`; la même preuve qualifie le run `4442003` d’unique run soumis dans ce périmètre.

**FACT — portée consommée** — cette autorisation ponctuelle couvrait la queue du préflight runtime dédié, pas un rejeu métier, une restauration SQL, un déploiement de packages, une publication, une modification de droits ou une ressource partagée. La preuve round10 l’associe au run `4442003`; les runs ultérieurs sont documentés, mais leur autorisation propre n’est pas retrouvée dans le texte round10. L’autorisation ne vaut pas autorisation générale de republier un patch, de relancer `14246` ou d’ajouter des jobs métier.

**FACT — restrictions ultérieures** — la pause de l’étape 28 impose d’informer l’utilisateur avant tout lancement Azure DevOps et précise que la préparation ne vaut pas autorisation de création de définition, push, lancement ou publication. Les reprises round10/round12/round16/round19 imposent en outre une référence neutre, des triggers désactivés, aucun effet JFrog/Promotion/Tag/TestAutos, et un arrêt avant SQL/IIS tant que l’isolation n’est pas attestée.

**FACT — round19** — la commande `docker create` visible dans le snapshot YAML ne demande aucun `--mount`, `-v` ou `volumes`; le run `4442225` conserve pourtant `count=1;dangerous=1`. `type/source/destination/rw` et `Config.Volumes` ne sont pas conservés. Cela autorise au plus un diagnostic read-only borné qui collecte ces projections expurgées sur le conteneur exact; la preuve round19 ne contient pas une autorisation de queue.

**VERDICT — patch diagnostic** — publication distante du patch : **NON autorisée par les textes retrouvés**. Une révision locale/documentaire reste dans le périmètre, mais son push ou sa publication nécessite un texte d’autorisation distinct; aucune publication n’est effectuée ici.

**VERDICT — nouvelle queue 14246** — **NON autorisée par la preuve round10 seule** : son autorisation était ponctuelle et consommée. La mission actuelle autorise la poursuite de l’analyse dans les autorisations documentées, ce qui couvre la lecture et la préparation locale; elle ne transforme pas cette ancienne délégation en nouvelle autorisation de queue. Le texte manquant est une autorisation explicite d’un nouveau préflight read-only sur `14246`/une ref neutre, avec collecte scrubbed des mounts et `Config.Volumes`, sans relaxation de whitelist ni effet métier.

**VERDICT métier** — rejeu métier **INTERDIT/BLOQUÉ** : `mounts` échoue (`count=1;dangerous=1`) et la source/destination restent UNKNOWN. Le garde-fou d’attestation hôte doit rester fermé; aucun job SQL/IIS, téléchargement de package, déploiement ou campagne ne doit être exécuté.

## 2026-09-07 — Round16 : sous-cause mounts discriminée

**FACT discriminant** — le run `4442225`, branche neutre, commit `44070560...`, échoue avec six sous-verdicts passés et un seul échoué : digest, OS, architecture, target-scope, networks et ports passent; `mounts` échoue (`count=1; dangerous=1`). Le digest exact est acquis et `containerPresentAfterRemove=False` est prouvé.

**UNKNOWN précis** — la source et la destination du mount dangereux ne sont pas conservées; son caractère réellement partagé n’est donc pas démontré. Le préflight ne prouve pas l’isolation des deux futurs jobs métier.

**FACT — policy et producteur** — la policy `V22-ISOLATION-POLICY.json` et le producteur hôte `Write-V22HostIsolationAttestation.ps1` sont présents et testés localement. Ils inspectent l’ID via `target: host`/`Agent.ContainerMapping`, refusent mounts dangereux, réseaux/ports divergents et déplacent l’attestation vers le job. Ces tests locaux ne prouvent pas que le producteur fonctionne dans les jobs métier réels.

**VERDICT** — le blocage vague d’isolation est remplacé par `mounts dangereux observés, provenance UNKNOWN`; le bug null-port n’est pas attribué comme cause complète. Aucun rejeu métier n’est autorisé ou exécuté; le garde-fou reste fermé tant que le producteur/policy ne sont pas vérifiés sur un run autorisé et que les jobs métier ne sont pas couverts.

**Nommage** — la référence active reste neutre; les mentions historiques `codex` dans preuves et documents sont conservées. L’audit est borné aux éléments créés de cette mission et ne conclut pas à une absence globale. L’ancien worktree endommagé n’est pas déclaré restauré sur la seule formule « seule modification observée » : aucune preuve du même dépôt/chemin ne le confirme.

## 2026-09-07 — Round14 : 4442178 échoue encore sur l’isolation

**FACT** — le run `4442178` (définition `14246`, branche neutre `refs/heads/investigation/wi-2222897-v22-preflight-20260907`, commit `2fd2830b4656ea836a20f12642649ff8d7057278`) a échoué après correction du cas null-port. L’acquisition du digest `sha256:268476...4da9cb` et `containerPresentAfterRemove=False` sont prouvées; l’inspection échoue encore sur `Runtime isolation whitelist assertion failed.`

**UNKNOWN bloquant** — les valeurs individuelles `dangerousMounts`, réseaux interdits, bindings de ports et `targetScopeValid` ne sont pas imprimées. Le correctif null-port exécuté ne suffit donc pas à expliquer l’échec runtime; aucune causalité supplémentaire n’est déduite.

**FACT — tête et provenance des commits** — la tête neutre relue est `2fd2830b...`. L’audit API round14 documente les quatre commits créés pour ce préflight, tous sans `codex` dans leurs messages : `5036e501` (Ronan JEGOU, `Fix read-only preflight cache miss handling`), `cd632126` (`rjegou`, `Fix V22 preflight registry image reference`), `a2a442c9` (`rjegou`, `Record V22 runtime isolation attestation`) et `2fd2830b` (`rjegou`, `Handle empty runtime port bindings`).

**FACT — garde-fou métier local** — le candidat round7 appelle `Assert-V22IsolationAttestation.ps1` avant readiness, téléchargements, déploiement ou écritures SQL/IIS. Il exige une attestation hôte et une politique produites par un mécanisme hôte autorisé. Aucun producteur hôte ni fichier d’attestation n’est fourni dans le pipeline; l’absence doit donc arrêter le job avant l’étape métier.

**VERDICT** — aucun rejeu métier n’est autorisé ou exécuté par ces preuves. `4442120` reste un succès limité d’acquisition/préflight, `4442152` et `4442178` échouent sur l’isolation; aucun ne prouve la réussite métier.

## 2026-09-07 — Mise à jour primaire round13 — 4442152 échoue sur l’isolation

**FACT supersédant l’ancien constat `defaultBranch`** — la collecte primaire [Worker 1 round13](evidence/azure-devops-french-taxes-rules-v22-worker1-round13/README.md) relit la définition `14246` avec `defaultBranch=refs/heads/investigation/wi-2222897-v22-preflight-20260907`. L’ancienne mention d’un `defaultBranch` encore `codex/...` est historique et ne décrit plus l’état courant.

**FACT — références actives et commits** — le run `4442152` a exécuté la branche neutre au commit `a2a442c98f05b2e57d02a98fd7228967ee4104df`; `cd632126...` est donc un commit antérieur de la correction, pas la tête à présenter pour ce run. La ref `codex/...` reste absente côté serveur. Les auteurs/messages détaillés des commits restent à vérifier par Worker 1.

**FACT — run 4442152** — l’image qualifiée a été téléchargée au digest attendu `sha256:268476...4da9cb`; le contrôle `containerPresentAfterRemove=False` a réussi. L’inspection a ensuite échoué sur `Runtime isolation whitelist assertion failed.`; la tâche retourne 1, tandis que hash des sorties et finalisation réussissent.

**UNKNOWN bloquant** — la sous-assertion fautive parmi `dangerousMounts`, réseaux interdits, bindings de ports et `targetScopeValid` n’est pas imprimée; les JSON détaillés restent dans `Agent.TempDirectory`. Les détails OS/architecture/ID/labels/mounts/réseaux/ports ne sont pas individuellement prouvés.

**FACT limité conservé** — `4442120` reste un succès limité d’acquisition/préflight antérieur; il ne prouvait pas l’isolation. Aucun des deux runs ne constitue un rejeu métier : aucun SQL, déploiement, appel métier ou stage de campagne n’a été exécuté.

**Audit de nommage** — la référence active est maintenant neutre (`investigation/...`); `codex/...` est une trace historique conservée dans les preuves et documents. Les métadonnées auteur/message des commits sont encore à vérifier; aucune absence globale de mentions n’est annoncée. Aucun élément Azure/JFrog nouvellement créé n’est prouvé au-delà de l’usage de l’ACR/service connection existant.

## 2026-09-07 — Audit live finalisé et préflight neutre 4442120

**FACT — branche corrigée** — les lectures REST live des collectes Worker 1 round12/round13 établissent que `refs/heads/codex/wi-2222897-v22-preflight-20260907` est absente côté serveur. La branche neutre exécutée est `refs/heads/investigation/wi-2222897-v22-preflight-20260907`, au commit `cd632126c17f3ac95c8a29b079d0e243fa538e54`, parent `5036e501...`. L’ancienne ref et l’historique du commit n’ont pas été réécrits.

**Portée exacte de la tête** — `cd632126...` est le commit relu et utilisé par le run `4442120`; cette preuve ne suffit pas à déclarer qu’il est encore la tête actuelle de la branche neutre. Le constat historique d’absence du SHA `a2a442c98f05b2e57d02a98fd7228967ee4104df` est supersédé par la preuve primaire round13, qui l’identifie comme commit exécuté par `4442152`; la tête postérieure au run reste non déclarée.

**FACT — définition et PR/runs** — la définition `14246` existe sous le nom neutre `WI-2222897 V22 Runtime Preflight 20260907` et reste enabled. L’audit live ne trouve aucun PR associé, aucune ref `codex` active et aucun run actif dans les 20 derniers runs interrogés. La définition conserve toutefois `repository.defaultBranch=refs/heads/codex/wi-2222897-v22-preflight-20260907`, référence historique obsolète.

**UNKNOWN ciblé** — le message et l’auteur du commit `cd632126...` ne figurent pas dans les collectes live relues; ils ne sont pas inventés. Aucun élément créé côté Azure Portal/JFrog n’est identifié dans cette mission au-delà de l’usage en lecture du service connection/ACR existant; cela ne constitue pas un audit global de ces systèmes.

**FACT — run 4442120** — la preview et le commit corrigé contiennent la référence complète ACR avec hostname, repository, tag et digest attendus. Le préflight `4442120` est `succeeded`; login registry, inspection host/image/container/mounts/network, hash des sorties et finalisation ont réussi. Les sorties restent dans `Agent.TempDirectory`; aucun artefact n’a été publié.

**FACT limité / UNKNOWN** — le succès prouve l’acquisition au digest et le préflight read-only, mais pas les valeurs détaillées de l’OS, de l’ID conteneur, des mounts/réseaux ni un rejeu métier. Aucun stage métier n’était présent et aucun résultat JMeter métier n’est revendiqué.

**Correction restante** — ne pas modifier la définition 14246 vers `master` ou une branche inexistante par supposition. La cible `refs/heads/sandbox/WI-2222897-v22-preflight-20260907` n’est pas présente dans l’audit live; corriger `defaultBranch` exige une ref neutre existante ou l’autorisation explicite de recréer cette ref au SHA voulu. Les logs/builds historiques et les mentions locales `codex` restent conservés pour provenance.

**Résultats locaux Worker 3 round3** — les validations du candidat local (préflight/dry-run, hashes et tests substitués) restent des preuves locales de préparation; elles ne valent ni validation runtime ni validation métier et ne doivent pas être fusionnées avec le succès limité de `4442120`.

## 2026-09-07 — Audit borné des traces partagées `codex`

**FACT issu de la preuve round11** — l’élément partagé explicitement identifié est la branche distante `refs/heads/codex/wi-2222897-v22-preflight-20260907` du dépôt `Y2_Plugins_FrenchTaxesRules`, au SHA `5036e501ba797ab7efc861add60b111a40ff8141`. Elle est consommée par la définition `14246` (`WI-2222897 V22 Runtime Preflight 20260907`) via `/azure-pipelines.wi2222897-v22-preflight.yml`. Référence : [preuve round11](evidence/azure-devops-french-taxes-rules-v22-worker1-round11/README.md).

**FACT issu des preuves round10/round11** — la branche et la définition ont été créées pour le préflight dédié, et les runs `4441699`, `4441719` et `4442003` sont les runs V22 explicitement indexés. La correction complète avec hostname ACR n’est pas publiée sur le SHA `5036e501`; `4442003` a donc utilisé l’ancienne référence d’image.

**FACT local** — les occurrences textuelles de `codex` dans le périmètre documentaire borné sont les mentions historiques de cette branche dans `HANDOFF.md`, `STATUS.md`, `JOURNAL.md`, `RESOURCES.md` et les preuves round10/round11. Elles ne doivent pas être supprimées : elles assurent la provenance des éléments déjà créés.

**UNKNOWN** — aucune lecture live indépendante des PR, messages de commit, autres refs de branche, définitions ou runs de l’organisation n’a été obtenue dans ce processus. La CLI Azure DevOps est bloquée par `PermissionError` sur le profil global; la tentative d’isoler la configuration CLI a été refusée par la politique d’exécution. Ne pas extrapoler l’absence d’occurrence au-delà des éléments indexés.

**FACT / conflit local** — le worktree `worktrees/Y2_Plugins_FrenchTaxesRules` a été laissé avec de nombreuses modifications/suppressions après l’échec du checkout dédié round11, selon la preuve round11. Son `git status` n’a pas pu être relu dans ce processus : Git refuse le dépôt pour `dubious ownership` et l’ajout global de `safe.directory` n’a pas été effectué. Ne pas nettoyer ni restaurer ce worktree sans son propriétaire.

### Inventaire et correction autorisée

| Surface | Occurrence | Visibilité/provenance | Action de cette mission |
|---|---|---|---|
| Branche AzDO | `refs/heads/codex/wi-2222897-v22-preflight-20260907` | Partagée, preuve round11 | Aucune modification distante par Worker 3; correction/renommage appartient à Worker 1 |
| Définition | `14246`, nom neutre | Partagée, liée à la branche | Lecture seule; aucun update/suppression |
| Runs | `4441699`, `4441719`, `4442003` | Historique AzDO, preuves round7/9/10 | Conserver logs et builds; aucune suppression |
| Commit | `5036e501...` | SHA distant consommé par le run; message non relu live | Ne pas réécrire l’historique |
| PR | aucune occurrence prouvée dans les index consultés | UNKNOWN live | Ne pas conclure à l’absence sans lecture AzDO autorisée |
| Azure/JFrog | aucune entité créée prouvée dans ce lot | UNKNOWN au-delà du service connection/ACR existant | Aucune inspection globale ni mutation |

Les futurs éléments partagés liés à cette mission doivent utiliser des noms de branche, définitions, commits et messages neutres, sans `codex`. Les mentions historiques ci-dessus restent immuables et doivent être étiquetées comme telles.

## 2026-09-07 — Reprise documentaire Round 2 — ACR confirmé, run 4442003 non concluant sur l’image

**FACT rapporté par l’utilisateur** — le `loginServer` exact d’AcrRetailDocker est `acrretaildocker-e2c3eugzbee2habm.azurecr.io`.

**FACT rapporté par l’utilisateur, vérifié par la preuve round10** — Azure CLI a confirmé la présence du digest historique `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb` dans le repository `cegid-retail-docker-production/y2-jmeter`, avec le tag `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`. Référence de collecte : [préflight ACR Worker 1 round10](evidence/azure-devops-french-taxes-rules-v22-worker1-round10/README.md).

**FACT** — le run `4442003` a exécuté le commit `5036e501ba797ab7efc861add60b111a40ff8141`, antérieur à la correction locale qui qualifiait l’image avec le hostname exact. La timeline montre l’authentification registry réussie, puis l’inspection image échouée sur un `docker pull` utilisant encore la référence non qualifiée `cegid-retail-docker-production/y2-jmeter...`; aucun conteneur, mount, réseau ou appel métier n’a été prouvé.

**INFERENCE** — l’échec de `4442003` ne teste pas la référence corrigée et ne permet donc pas de conclure négativement sur le hostname confirmé, la présence du digest dans l’ACR ou les droits ACR. Le blocage est reclassé en **UNKNOWN** pour l’acquisition/démarrage runtime avec la référence complète, et non en preuve de droits absents.

**UNKNOWN conservés** — compatibilité agent/OS, cycle de vie et isolation du conteneur, mounts/réseau, consommation des packages, restauration effective et résultat métier des variantes. Les constats secrets/comparaison de la readiness Worker 2 round1 restent en cours de vérification par Worker 2; ils ne sont ni effacés ni déclarés résolus par cette confirmation d’adresse image.

### Critères précis de poursuite

1. Repartir d’un artefact/commit qui contient effectivement le hostname `acrretaildocker-e2c3ugzbee2habm.azurecr.io` et la référence complète tag+digest; ne pas réutiliser `4442003` comme preuve de cette correction.
2. Vérifier dans la collecte du prochain essai la référence image réellement consommée, le digest démarré, puis l’identité/cycle de vie du conteneur, ses mounts, son réseau et le périmètre dédié SQL/IIS.
3. Maintenir l’arrêt avant rejeu métier tant que les écarts de secret, de comparaison baseline/candidat et de consommation des packages signalés dans [readiness Worker 2 round1](evidence/2026-09-07-v22-readiness-worker2-round1/README.md) ne sont pas vérifiés ou explicitement rejetés par preuve.
4. Ne lancer aucune action distante supplémentaire dans cette reprise documentaire; toute queue ultérieure doit rester explicitement autorisée et isolée.

## 2026-09-07 — Worker 3 Round 3 — candidat V22 complet reviewable

**FACT** — le candidat local [replay-prep](replay-prep/2026-09-07-v22-isolated/) contient maintenant un pipeline séquentiel `Preflight` → `FixHistorical` → `FixCandidate`, une image de job digestée, des refs commit locales figées, un préflight backup/JMX, une preuve runtime locale SQL/IIS, trois plans discriminants puis 376 tests, aucune publication d'artefact et un nettoyage job-scoped.

**FACT** — Pipelines_Templates n'est plus consommé; les étapes sont inline. Le template JMeter qui affichait `parameters.properties` n'est donc pas utilisé. Les worktrees PlatformDeploy et JMeter restent non modifiés, hormis la modification utilisateur préexistante de `Y2_Tools_Jmeter_Workflow/azure-pipeline.yml`.

**FACT** — PlatformDeploy `5.0.86` et SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295` sont résolus par Worker 1 round4 et intégrés au YAML; le commit code `93f91487...` reste une provenance distincte du ZIP.

**UNKNOWN bloquant** — identité/cycle de vie réel du container, mounts, cibles non partagées et compatibilité agent restent non prouvés. Aucun lancement ni queue.

**FACT de validation locale** — le digest complet `registry:tag@sha256` est accepté par le préflight positif sur le snapshot V22 : 32 JMX, 32 hashes, backup exact, 232 Legacy + 144 Web = 376, sans écriture. Le dry-run `Invoke-V22RunnerDryRun.ps1` confirme l'ordre baseline → trois opérations → campagne complète et neutralise SQL/IIS, JMeter, publication et queue. Les variantes digest invalide et hash backup invalide sont refusées avant écriture.

**FACT round5** — le manifeste `replay-prep/2026-09-07-v22-isolated/MANIFEST.sha256` fige le candidat; le plugin est checkouté séparément au commit exact, PlatformDeploy `5.0.86`/SHA-256 est renseigné, `-verbose` et l'argument secret du wrapper sont supprimés, et les résultats sont collectés sous forme expurgée. Les tests substitués passent pour baseline en échec, candidat en échec avec cleanup et comptage incorrect. La readiness SQL/IIS ne vaut pas attestation d'isolation.

**FACT round6** — Worker 1 a vérifié les hashes des trois ZIP baseline et le manifest/digest ACR de l'image historique; ils sont intégrés dans `PACKAGE-SHA256SUMS.txt`. La matrice `V22-174-REFUS-COMPARISON.md` sépare la signature d'autorisation attendue de toute panne infrastructure et n'exige pas zéro autre échec métier. Aucun rejeu métier.

**Commande de validation exacte** : depuis la racine WI, exécuter le `Invoke-V22RunnerDryRun.ps1` documenté dans le README du replay-prep avec le snapshot `sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167`. Une future définition/branche dédiée devra conserver `trigger: none`, `pr: none`, `schedules: []`, aucun `PublishPipelineArtifact`/JFrog/Promote/Tag et aucun déclenchement aval ; l'exécution réelle aurait pour seuls effets autorisés les ressources job-container, DB/IIS locaux et le cleanup de `Agent.TempDirectory`, mais reste non autorisée tant que PlatformDeploy n'est pas identifié.

## 2026-09-07 — Revalidation primaire InventoryTracking migration (Worker 2 round2)

**FACT** — la collecte [worker2-round2](evidence/azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md) établit la branche `InventoryTracking_Migration_AutoTest_Jmeter_On_master`, commit `4de185bb...`, et non `refs/heads/master`, pour le build `4434070`.

**FACT** — le premier échec causal est VSBuild log 51 : `Cegid.Retail.XmlDiff` absent/non résolu (`MSB3245`), puis quatre `CS0103`; image/ACR passent et les stages JMeter sont skipped. Le commit de migration supprime `WebServices.Tests` et son `packages.config`, qui restaurait XmlDiff/XMLDiffPatch, alors que Services.Tests garde la référence Y2Core.

**INFERENCE** — la suppression de l'acquisition de la dépendance encore requise est le mécanisme immédiat le mieux étayé. **UNKNOWN** — contenu du package Core, restore effectif et commits des templates externes; le correctif doit être testé localement avant tout run.

**FACT limité** — master `4435986` passe son ancien Build V26/TestAutos, mais son YAML ne déclare pas `TI_Jmeter_V26`; il ne valide pas la migration JMeter.

**UNKNOWN** — lecture live WI/relations/PR non fournie par la collecte round2, validation du correctif, campagnes JMeter et livrables PBI. L'ancien blocage global d'accès est supersédé pour les faits ci-dessus; les échecs TLS/navigateur des autres processus restent historiques et sont conservés plus bas.

Suite : créer aucun pipeline; effectuer uniquement un checkout local isolé du commit de migration, tester la restauration/référence minimale, puis demander la collecte WI/PR avant toute conclusion de PR.

## 2026-09-07 — Worker 3 : accès Azure DevOps et rejeu isolé

**FACT** — la compétence Azure DevOps a été appliquée en lecture seule. Aucun connecteur Azure DevOps n’est disponible dans la session. La CLI locale échoue avant lecture sur `PermissionError` pour `C:\Users\jegour\.azure\azureProfile.json`. Edge possède des onglets ChatGPT, SharePoint et Outlook, mais aucun Azure DevOps ; l’ouverture read-only de `https://dev.azure.com/cegid/Retail/_build` a été refusée par la politique utilisateur. Aucun secret, changement d’identité globale, contournement ou écriture distante n’a été effectué.

**FACT** — les preuves existantes identifient la définition 5224 `Y2 Tools Jmeter Workflow` et son YAML master comme une chaîne à effets : triggers master/releases, Build, stages Docker, publication JFrog/BuildInfo, Promote et Tag_Sources. Le YAML `sandbox/tests_rje` désactive ces effets externes, mais publie toujours un PipelineArtifact Azure DevOps. Ces éléments sont datés du 2026-09-05 et ne valent pas état courant.

**FACT** — le brouillon durci V26 Fix `ExportRunOnly` n’est pas une simple simulation read-only : il télécharge PlatformDeploy/packages, restaure `AUTO_V26_00.bak`, déploie l’environnement containerisé, peut écrire SQL/IIS/configuration et lance JMeter contre `APPSERVER_HOST`. Les garde-fous de marqueur dédié, hôtes résolus et hash JMX sont locaux et ne prouvent pas la disponibilité réelle des ressources.

**INFERENCE** — pas de queue sûre dans ce lot. La prochaine queue, après autorisation et preuves techniques, doit viser une définition/branche dédiée avec triggers désactivés, `pipelineDevMode=false`, image digestée, checkout/commit figé, manifestes de packages/backup/JMX et preuve pré-écriture de cibles SQL/IIS dédiées. Critères d’arrêt : cible ambiguë ou partagée, agent incompatible, package non identifié, secret visible, publication/promotion/tag/TestAutos inattendu, ou stage/campagne non exécuté.

**HISTORIQUE / supersédé pour 4434070** — cette section décrit l'accès de ce processus avant la collecte Worker 2 round2. La branche de migration, le premier échec XmlDiff et les stages skipped sont désormais établis en tête; restent UNKNOWN les packages/backup effectivement consommés, le mécanisme restore/template, le résultat métier et la propagation package/migration.

Voies indépendantes restantes : propagation contrôlée de `FixSqlUnicodeValue` API→Console→migration ; rejeux locaux de génération ; et analyse ciblée des causes Clienteling/FTS/générateur/XML/fixtures. TC22 et TC32 restent des échecs communs legacy/JMeter.

## 2026-09-07 — Revue indépendante SOAP round13

**FACT** — dans le contrat réel du build 4432510, `Fault` est dans l’URI SOAP 1.1 tandis que `detail` et `faultcode` sont sans namespace propre. Le XPath round13 `//*[local-name()='Fault' and namespace-uri()='http://schemas.xmlsoap.org/soap/envelope/']/detail/faultcode` conserve donc correctement le chemin descendant pour ce contrat. Le JMX round13 garde `XPath.negate` selon `ExpectedValue` et laisse `//Result` en `namespace=false`.

**FACT** — le rejeu JMeter 5.6.3 round13 a vérifié les positifs SOAP avec deux préfixes et les négatifs absence de Fault/mauvais namespace. **UNKNOWN** — aucun cas round13 avec négation `ExpectedValue=0` n’a été exécuté, alors que 40 JMX réels contenant Fault ont `XPath.negate=true`.

**FACT** — provenance stricte : DLL round13 = SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`; DLL API du package Console local précédent = `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`. **51FB31... ne doit pas être décrit comme contenant le correctif SOAP round13.** La propagation officielle package/migration reste UNKNOWN.

**INFERENCE** — le ciblage `soap:Fault` est volontairement limité à SOAP 1.1 prouvé. `CleanXpath` reste la normalisation des assertions non SOAP ; aucune généralisation SOAP 1.2 ni mapping externe manquant ne doit être inventée.

## 2026-09-07 — Vérification finale InventoryTracking master / build 4434070

**FACT** — aucune preuve live n’a été obtenue pour le build `4434070`. La collecte bornée est [indexée ici](evidence/azure-devops-inventorytracking-4434070-blocked/README.md).

**FACT** — l’action navigateur exacte était `cua.createBrowserTab('edge', 'https://dev.azure.com/cegid/Retail/_build/results?buildId=4434070&view=results')`. Elle a été rejetée avec le motif explicite : l’utilisateur a refusé la permission d’accès à `https://dev.azure.com`. Il s’agit d’un refus utilisateur remonté par l’outil, pas d’une simple erreur réseau/technique ni d’une revue automatique signalée.

**FACT** — aucun connecteur Azure DevOps déjà disponible et autorisé n’a été trouvé. L’Azure CLI reste installée mais non authentifiée dans le profil isolé; aucune connexion interactive, demande de secret, modification d’authentification ou nouvelle tentative de l’action refusée n’a été faite.

**UNKNOWN** — cause racine du fail, identité dépôt/branche/commit, définition et paramètres, stages exécutés ou sautés, premier task causal et son log, tests démarrés ou non, image/ACR, et existence d’un build `master` plus récent. L’hypothèse image/ACR n’est pas une preuve.

**Solution minimale pour avancer le PBI** : fournir une exportation ou lecture Azure DevOps autorisée, en lecture seule, contenant les métadonnées du build `4434070`, sa timeline complète, le log du premier task causal et les YAML/templates résolus au commit exact, puis les mêmes éléments pour le build `master` le plus récent. Vérifier ensuite l’exécution réelle de `Build` et des campagnes/stages V26 attendus, puis inventorier séparément les erreurs métier. Le critère n’est pas « zéro test métier en échec » : la définition de tests concluants reste ambiguë dans la synthèse du PBI.

## Clôture documentaire de la tentative JMeter offline — 2026-09-07

**FACT** — la collecte `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/README.md` est conservée sous le chemin canonique et indexée dans `evidence/README.md`. Les deux seules acquisitions autorisées (`Invoke-WebRequest`, puis `curl.exe`) ont échoué en TLS Schannel avec `SEC_E_NO_CREDENTIALS`. Aucun ZIP, checksum SHA-512 vérifié, moteur ou harness XPathAssertion n’a été exécuté.

**UNKNOWN** — comportement SOAP réel de JMeter, et donc qualification du défaut CleanXpath. Les pages API Apache consultées décrivent les signatures et paramètres `XPathAssertion`/`XPathUtil`, mais ne constituent pas une vérification du code source au tag exact `v5.6.3`; leur comportement ne doit pas être présenté comme démontré pour cette version.

**FACT conservés** — corrections de génération et génération locale Console/API→JMX restent prouvées; TC22 FrenchTaxesRules et TC32 Clienteling restent des échecs communs observés en legacy. **UNKNOWN conservés** — propagation migration/package, environnement, SQL/IIS, backup et rejeu métier.

### Conditions concrètes de reprise

- Test offline : rendre accessible dans le workspace la distribution officielle Apache JMeter `5.6.3` et son checksum officiel vérifié; ensuite seulement exécuter le harness minimal SOAP avec `namespace=false` et contrôles namespace-aware explicites.
- Rejeu métier : traiter séparément les prérequis d’isolation (agent, image, packages, backup, cibles SQL/IIS, secrets et artefacts) et l’autorisation distante; la disponibilité de JMeter ne vaut pas autorisation de pipeline ni preuve métier.

## Mise à jour — vérification réelle JMeter 5.6.3 XPathAssertion — 2026-09-07

**FACT** — cette section supersède la clôture documentaire précédente sur le seul point XPath offline. Le ZIP officiel est présent, son SHA-512 correspond au checksum officiel, JMeter 5.6.3 démarre avec code `0`, et les harnesses invoquent réellement `XPathAssertion`.

**FACT** — avec `namespace=false`, `//Fault` ne matche pas un Fault SOAP préfixé, quel que soit le préfixe testé, mais matche un Fault non préfixé. Avec `namespace=true`, le mapping `soap=http://schemas.xmlsoap.org/soap/envelope/` et `//soap:Fault` matche les préfixes `soap` et `env`, rejette l'absence de Fault et rejette le mauvais namespace testé. `local-name()` est écarté comme solution robuste car il matche aussi le namespace non SOAP testé.

**INFERENCE** — `CleanXpath` corrige bien la syntaxe invalide `//`, mais `//Fault` ne constitue pas une correction SOAP complète dans les JMX actuels. Le générateur doit être adapté de manière ciblée pour les Fault SOAP : mode namespace-aware, mapping explicite et XPath préfixé. SOAP 1.1/1.2 et les autres XPath générés restent à inventorier avant modification globale.

**UNKNOWN** — forme exacte du changement générateur, propagation API → Console → package de migration, régénération effective, et rejeu métier. Référence atomique : [finding 012](findings/012-jmeter-5-6-3-xpath-namespace.md). Preuves : `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/` et ses artefacts `manual-verification/`.

## Consolidation documentaire du 2026-09-07 — portée des preuves

**FACT** — la compilation isolée net452 de `FixSqlUnicodeValue` est réussie avec le staging BuildTools/façades ; l'ancien `MSB3644` est un état historique supersédé pour cette sortie uniquement. La génération Console/API→JMX est prouvée pour `ItemSearch_Keywords.xml` et les quatre plans Mobility/ItemSearch (`4/4` par variante, `682` SQL, `185` XPath). **UNKNOWN** — package, propagation migration et rejeu métier.

**FACT** — le contrat offline `ExportRunOnly.xml` est vérifié vers un JMX direct hashé (`nodes=1`, extension `.jmx`, hash identique, `86` `JDBCSampler`). **INFERENCE** — le raccord documentaire est démontré localement. **UNKNOWN** — installation dans un checkout de migration, orchestration et résultat métier.

**Historique supersédé** — le comportement SOAP réel de `XPathAssertion` est désormais établi par la vérification JMeter 5.6.3 ci-dessus : `//Fault` échoue sur un Fault SOAP préfixé avec `namespace=false`. Les cas TC22 FrenchTaxesRules et TC32 Clienteling restent des échecs communs observés en legacy, et le packaging V22 reste une hypothèse non validée.

Références : `evidence/local-2026-09-07-api-jmx-unicode/`, `evidence/local-2026-09-07-four-plans-integrated/`, `evidence/local-2026-09-07-v26-fix-export-run-contract/` et `evidence/local-2026-09-07-xpath-engine-semantics/`.

## Reprise du 2026-09-07 — piste packaging V22, conseil de Ludo

**FACT** — le packaging `22.0.23`, son manifeste et ses ZIP sont présents en production JFrog. Les trois dépendances candidates Core `22.0.0.2068`, Common `22.0.3.311`, Identity `22.0.6.117` sont aussi disponibles individuellement. Le blocage de lecture JFrog est levé avec le token fourni par l'utilisateur, utilisé uniquement en mémoire.

**INFERENCE / UNKNOWN** — ce trio supérieur au Fix historique est un candidat pour les 174 refus FrenchTaxesRules V22 du build 4429167 ; aucune correction métier validée. Le packaging référence un FrenchTaxesRules plus ancien que `22.0.6.478`, conservé pour l'essai proposé. Lire le [complément canonique de la fiche 004](findings/004-french-taxes-rules-v21-v23-build-4429167.md) et la [synthèse de collecte](evidence/2026-09-07-jfrog-v22-packaging/README.md).

Un prompt opérateur a été remis à l'utilisateur pour préparer un avant/après isolé, puis trois cas représentatifs et les 376 tests. Aucun lancement réalisé. Cette piste V22 est distincte du brouillon Export_Run V26 ci-dessous : ne pas réutiliser sa cible/image/données par supposition, ni présenter sa pause historique comme le résultat des tests V22. La présente session se termine par une mise à jour documentaire uniquement.

## Reprise du 2026-09-07 — handoff manuel, mécanisme DLL d'autorisation V22

**Non revérifié dans ce processus.** Un handoff manuel reçu hors `brain-worker` est rangé sous [`evidence/local-2026-09-07-french-taxes-rules-v22-authorization-handoff/`](evidence/local-2026-09-07-french-taxes-rules-v22-authorization-handoff/README.md) et complète [finding 004](findings/004-french-taxes-rules-v21-v23-build-4429167.md). Il rapporte un mécanisme causal supplémentaire pour le trio candidat déjà identifié Core `22.0.0.2068` / Common `22.0.3.311` / Identity `22.0.6.117` : ce trio restaurerait, via `ExternalsToRestore.xml`, le NuGet externe `FWK-CEGID-NET-FULL 12.9.185`, qui contient `Cegid.Erp.Services.Implementation.dll 12.9.185.17` — exactement la version chargée par le Current V22 qui passe 376/376, contre `12.9.153.1506` chargée par le Fix historique aux 174 échecs `ID4266`.

**INFERENCE rapportée, non revérifiée ici** — cela renforce l'hypothèse d'un packaging Fix trop ancien plutôt qu'un défaut JMX. **NON DÉMONTRÉ** — la source elle-même n'a pas exécuté le replay isolé ; l'état du brouillon `replay-prep/2026-09-07-v22-isolated/` (bloqué par le ref `Pipelines_Templates` et l'attestation de cible dédiée) est inchangé. Avant de citer ce mécanisme comme `FACT`, revérifier indépendamment les `ExternalsToRestore.xml` des deux Core et le contenu du NuGet téléchargé dans ce processus.

## Reprise du 2026-09-07 — brouillon durci hors ligne

**FACT** — une copie de travail du brouillon est sous `evidence/local-2026-09-07-v26-fix-replay-draft-hardened/`; la preuve du 2026-09-06 reste intacte. Le descripteur sans namespace pointe directement vers le JMX corrigé hashé. Un préflight exige un marqueur de cible dédiée, refuse les hôtes non résolus et vérifie le hash source/destination avant toute suite de déploiement. Les propriétés ne sont plus affichées et l'archive de déploiement est réduite à une liste de noms d'entrées ZIP.

**FACT** — le harness inerte reproduisant le passage d'arguments au runner obtient le bon `-t ...001-Export_Run.jmx`; les variantes fichier absent et hash incorrect sont refusées avant invocation. Aucun JMeter métier, SQL, HTTP, pipeline ou dépôt n'a été exécuté/modifié.

**UNKNOWN** — agent compatible, accès registre/image, version PlatformDeploy, packages, backup et cible dédiée effective. La copie durcie est préparatoire et ne constitue pas une autorisation de définition ou d'exécution.

## Reprise du 2026-09-07 — correction FixSqlUnicodeValue

**FACT** — `FixSqlUnicodeValue` est implémentée dans le worktree API d'essai par parcours des littéraux et prise en charge des apostrophes SQL doublées. La preuve offline couvre Unicode simple, Unicode avec `''`, ASCII avec `''`, texte hors littéral, préfixe `N` existant et le SQL JMX `ItemSearch:Keywords` TC02. Voir `evidence/local-2026-09-07-fix-sql-unicode/`.

**Historique supersédé** — la première compilation net452 a rencontré `MSB3644` sans assemblies de référence. **FACT actuelle limitée** — la compilation isolée réussit avec le staging BuildTools/façades ; DLL/package publiée, propagation Console/migration et rejeu métier restent `UNKNOWN`. Ne pas republier ni lancer.

**Mise à jour FACT 2026-09-07** — la compilation isolée est désormais réussie grâce au MSBuild BuildTools et au staging net452 déjà documentés. Le test durable appelle la DLL corrigée; la génération intégrée produit un JMX ItemSearch:Keywords TC02 avec `MAM_MOTCLE=N'` contre `NN'` avec l'assembly originale. Preuve : `evidence/local-2026-09-07-api-jmx-unicode/`. Packaging Console/migration, acquisitions et rejeu métier restent UNKNOWN.

## Reprise du 2026-09-07 — contrat offline Export_Run préparé

**FACT** — le défaut de sélection est corrigé dans une preuve isolée, sans toucher au pipeline ni aux worktrees : `campaigns/ExportRunOnly.xml` sans namespace par défaut pointe directement vers `Export_Run\001-Export_Run.jmx`; la copie du JMX corrigé est hashée `C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C`. Le script `verify-contract.ps1` reproduit le XPath du runner et vérifie `nodes=1`, extension `.jmx`, présence du fichier, hash identique et 86 nœuds XML `JDBCSampler`.

**INFERENCE** — ce contrat supprime les deux ambiguïtés prouvées (namespace et XML de plan non consommable) pour la préparation locale. Il ne prouve pas que le checkout réel ou un job futur l'installe, ni la réussite métier.

Preuve : `evidence/local-2026-09-07-v26-fix-export-run-contract/`. Suite sûre : faire relire ce contrat, puis l'intégrer dans une définition explicitement isolée seulement après résolution des blocages agent/acquisitions/cibles pré-écriture/secrets. Aucun lancement ne découle de cette preuve.

## État courant — après revue locale du 2026-09-06

**La revue de l'étape 28 est terminée. Le brouillon reste bloqué avant exécution : la reproduction exacte du `Select-Xml` du runner renvoie zéro nœud sur le descripteur candidat (namespace `TestAutomation`), donc aucun chemin de plan n'est sélectionné.** La prochaine étape réelle est de documenter, sans l'appliquer, un contrat de descripteur compatible et un artefact/copie hashé du JMX corrigé; aucune génération, exécution ou modification de pipeline n'est autorisée dans cette étape. Preuve : `evidence/local-2026-09-06-v26-fix-jmx-xpath-reproduction/`.

### Règle de décision — objet exact de l'investigation

Cette investigation doit expliquer les **écarts JMeter ↔ Legacy**. Un test case qui échoue aussi dans Legacy, sur la même postcondition ou la même signature, n'est pas un défaut de l'outil de migration démontré : il constitue un échec commun et oriente l'analyse vers le produit, le scénario, les données ou l'environnement. Il ne peut être requalifié en écart de migration que si une différence propre au chemin JMeter est prouvée à contrat comparable. En conséquence, `FrenchTaxesRules_Run` TC22 et `SaleAndSellers_CreateReceipt` TC32 doivent rester traités comme des recherches de cause commune, et non comme des régressions JMeter.

### Historique — PAUSE utilisateur du 2026-09-06 après étape 28

**Travail en pause, aucun rejeu métier lancé. La prochaine étape historique était la revue locale du brouillon pipeline, pas son exécution.** Cette section conserve sa portée datée.

### Mode de collaboration à conserver

- L'assistant principal prépare un seul prompt concis, précis et autonome pour un LLM opérateur moins puissant, puis attend le compte rendu recopié par l'utilisateur avant de donner la suite.
- En cas de blocage manifestement difficile pour l'opérateur, l'assistant fait seulement une investigation directe courte. Ne pas enchaîner de longues recherches ni des tentatives sans preuve nouvelle.
- Informer l'utilisateur avant tout lancement Azure DevOps. La préparation de brouillons ne vaut pas autorisation de création de définition, push de branche, lancement ou publication. Aucun déclenchement automatique de reprise.
- Priorité : impact minimal sur les collègues. NuGet d'essai uniquement en artefact du run ; aucun push JFrog/feed partagé. Docker existant épinglé par digest pour le rejeu envisagé ; aucune image à publier à ce stade. Toute future publication Docker exige une identité dédiée et un périmètre validé.
- Conserver les artefacts du run avec `always()` et une sélection de fichiers sans secrets. Ne pas confondre PipelineArtifact avec publication JFrog. Aucun nettoyage global ou changement des ressources collectives.

### Acquis à ne pas recommencer

| Sujet | État prouvé / limite | Preuve de reprise |
|---|---|---|
| Correctif API | `EscapeJdbcDate` : `${1}${3}${2}` → `${1}${2}${3}` ; modification locale non commitée, compilation net452 réussie et comparaison JMX avant/après | [API compilée](evidence/local-2026-09-06-api-build-net452-complete/), [comparaison API](evidence/local-2026-09-06-api-jmx-date-before-after/) |
| Console officielle 2.0.42 + API substituée | génération locale validée, 6/6 fixtures corrigées ; aucune recompilation Console validée | [diagnostic et validation](evidence/local-2026-09-06-console-quick-diagnosis/README.md) |
| Plan réel Export_Run | deux codes Console 0, 86 JDBCSampler par JMX ; dates TC08/TC09 corrigées, TC10 inchangé ; comparaison complète normalisée documentée | [Export_Run avant/après](evidence/local-2026-09-06-export-complete-before-after/) |
| Résultat métier | UNKNOWN : aucun JMeter, appel SQL/HTTP ou rejeu Y2 de ces essais n'a validé TC08–TC10 | [préparation métier historique](evidence/local-2026-09-06-export-run-business-replay-prep/) |
| Image et données V26 Fix | SQL 2025, image/digest et restauration backup identifiés dans le build 4432510 ; hash historique du backup UNKNOWN | [image et données](evidence/local-2026-09-06-v26-fix-4432510-image-data/README.md) |
| Pipeline d'essai | brouillon documentaire seulement, non exécutable, non publié, pas de définition créée pour ce rejeu | [brouillon étape 28](evidence/local-2026-09-06-v26-fix-replay-draft/README.md) |

API corrigée à préserver : SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`, version d'assembly `1.1.46.0`, token `fe0ce61bd76bef19`. Ne pas l'identifier uniquement par sa version : l'originale porte la même identité.

Baseline choisie : build `4432510`, commit `f80bc731571b2b5ed8a67da171b288873de428a6`, plugin Fix `26.0.10.75`, Core `26.0.0.1762`. Ne pas mélanger avec le plugin `26.0.10.67` du build `4426342` ni avec la source legacy de génération `07a42172...` sans expliciter leur rôle.

Image historique : `y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`, digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`. Le registre masqué dans les logs reste à résoudre pour une définition d'essai. Données : `Tests/Backups/AUTO_V26_00.bak`, mode `-LocalDBInContainer Backup`, base `AUTO_V26_00`, tenant `TESTS_AUTO_JMETER`. Calculer le hash du fichier acquis avant restauration future ; ne pas prétendre retrouver le hash historique par ce calcul.

### État Git local revérifié à la pause, sans fetch

| Worktree | Branche / HEAD | État |
|---|---|---|
| `Y2_Tools_AutoTest_Api` | master / `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` | propre |
| `Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE` | sandbox/rje-wi2222897-escape-jdbc-date / même HEAD | uniquement `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` modifié ; préserver |
| `Y2_Tools_AutoTest_Console` | master / `fa8a5fb411bbadcef16204f149bae3a65b0f7abb` | propre |
| `Y2_Tools_AutoTest_Console_Date_RJE` | sandbox/rje-wi2222897-console-date / même HEAD | propre |
| `Y2_Tools_Jmeter_Workflow` | master / `4db2dcdab647249de3cdc27eadaf15a158b3a26a` | `azure-pipeline.yml` modifié par l'utilisateur ; préserver |
| `Y2_Plugins_FrenchTaxesRules` | master / `07a42172bebc65d17093e166ac08de22e4fe7248` | propre |

Chemins relatifs à `../../worktrees/`. L'état distant n'a pas été revalidé pendant la pause. Aucun commit, nettoyage ni sauvegarde par stash n'a été effectué.

### Prochaine étape unique : revue critique du brouillon, localement

Lire [azure-pipelines.candidate.yml](evidence/local-2026-09-06-v26-fix-replay-draft/azure-pipelines.candidate.yml), ses templates candidats, `campaigns/ExportRunOnly.xml` et `scripts/stage-evidence.ps1`. Les preuves sous `evidence/` restent immuables : produire toute révision dans un nouveau dossier, pas sur ce brouillon.

Le périmètre proposé est le plan Export_Run complet, dans son ordre original, un seul job V26 Fix. Ce n'est pas une sélection exclusive TC08–TC10. Avant toute action distante, résoudre ou garder bloquants :

1. Contrat du descripteur XML consommé par le runner JMeter : vérifier qu'il référence effectivement le JMX corrigé, et non un plan legacy destiné au générateur. Le brouillon référence actuellement `TestPlans/Export_Run.xml` ; cette correspondance doit être revue contre le template, pas supposée valide.
2. Chemin de checkout : le brouillon fait `checkout: self` mais emploie un sous-dossier `Y2_Plugins_FrenchTaxesRules`. Vérifier l'arborescence réelle, la provenance du JMX corrigé et son rattachement à la baseline.
3. Agent Windows compatible LTSC2025, capacité et quotas : `windows-latest` dans le brouillon n'est pas une compatibilité démontrée. Résoudre registre/connexion, `platformDeployVersion`, `artifactoryPackageFolder` et acquisitions des packages/backup/config.
4. Les versions déclarées dans `variables` ou écrites dans `references-consumed.txt` ne prouvent pas les versions consommées : vérifier le déploiement réel et préparer une collecte des identités effectives.
5. Vérifier les cibles SQL/IIS/`__CONTAINER_HOST__`/`APPSERVER_HOST` AVANT les écritures de déploiement. La seule trace après déploiement ne constitue pas un garde-fou. Bloquer toute cible partagée ou ambiguë.
6. Vérifier triggers et consommateurs aval, noms/volumes/réseaux/staging, nettoyage limité aux ressources du run ; aucun TestAutos, push, promotion, tag ou déploiement externe.
7. Vérifier la collecte `always()` en cas d'échec partiel. Examiner le contenu de l'archive de déploiement avant inclusion : un nom de fichier autorisé ne prouve pas l'absence de secrets dans son contenu.

Ces points sont des contrôles de revue ouverts, pas des corrections appliquées ni une validation du YAML. La prochaine réponse attendue est un prompt opérateur pour cette revue et son compte rendu, puis une décision sur les préparatifs restants. Ne pas lancer un pipeline à la reprise.

### Pièges déjà résolus et ressources

- Ancien runtime .NET : utiliser des chemins courts dédiés sous `C:/temp/`, pas les chemins profonds sous OneDrive pour exécuter Console. `input.xml` doit être au chemin réellement référencé sous `TestPlans`.
- Les sorties `Run_01.xml` à `Run_04.xml` ne sont PAS requises par Export_Run : aucun ExpectedOutput pour TC01–TC04 ; TC10 référence Run_07. Ne pas rouvrir le faux blocage par numérotation des fichiers.
- Compilation API : références net452 et 51 façades via import externe ont permis la compilation ; les preuves contiennent les commandes. La compilation Console reste bloquée sur l'identité XmlDiffPatch.View mais n'empêche pas le test avec Console officielle et API substituée.
- Ne pas reprendre les recherches historiques de hash de backup sans nouvelle source identifiée. Une nouvelle expérience maîtrisée reste possible sans équivalence historique cryptographique complète.
- Ressources et règles de conservation : [RESOURCES.md](../../RESOURCES.md). Conserver les worktrees, DLL, essais courts et preuves pendant la pause ; aucun nettoyage demandé.

---

## État de la reprise

Les sept builds prioritaires de FrenchTaxesRules et Clienteling sont maintenant analysés. Pour chaque couple plugin, branche, version et variante Cur/Fix, le dossier conserve :

1. le nombre exact d'échecs issu d'Azure DevOps ;
2. des groupes de fautes par signature normalisée ;
3. la première faute causale et les éventuels échecs en cascade ;
4. une classification : infrastructure/déploiement, outil de migration, scénario de test, produit, ou reporting ;
5. la preuve qui soutient la conclusion ;
6. le correctif recommandé, son dépôt propriétaire et le rejeu minimal de validation.

Rester en lecture seule dans Azure DevOps. Ne pas pousser de branche, créer de PR, commenter un WI ou relancer un pipeline sans demande explicite.

## Reprise du 2026-09-06 — preuves legacy récupérées sur Y2-TSTAUTOXXPG2

Les preuves aval récupérées sur la VM complètent les Test Runs Azure DevOps déjà collectés, notamment les TRX Clienteling vides. Elles ne correspondent pas aux corrélations `162`, `66`, `226`, `227` ou `228` : ce sont des exécutions legacy indépendantes et antérieures. Ne pas les présenter comme le résultat des builds legacy candidats du 2026-09-03/04.

### FACT — exécutions master V26 réellement observées

| Plugin | Exécution legacy | Résultats élémentaires réellement exécutés | Rapprochement avec les cas JMeter non passés |
|---|---|---|---|
| FrenchTaxesRules | Fix, SQL, plugin `26.0.10.25`, Core Fix `26.0.0.1762`, 2026-08-04 | 253 `UnitTestResult` : 252 `Passed`, 1 `Failed` (`FrenchTaxesRules_Run` TC22) | 6/6 identifiants plan/TestCase retrouvés : Export TC08-10 et les deux Validation TC99 passent ; TC22 échoue avec `Expected 2 / Actual 1` sur DAEMON, comme sous JMeter |
| Clienteling | Fix, SQL, plugin `26.0.10.18`, Core Fix `26.0.0.1762`, 2026-08-04 | 2 131 `UnitTestResult` : 2 130 `Passed`, 1 `Failed` (`SaleAndSellers_CreateReceipt` TC32) | 485/485 identifiants plan/TestCase JMeter retrouvés : 484 passent ; TC32 échoue sur le même comptage `MCHPSUTILISATDATA`, `Expected 1 / Actual 0` |

Les compteurs globaux des TRX incluent aussi les conteneurs `orderedtest` : 274 résultats / 3 échecs pour FrenchTaxesRules et 2 283 / 3 pour Clienteling. Les totaux ci-dessus comptent uniquement les scénarios élémentaires `UnitTestResult`, afin de ne pas compter en double l'échec de leur conteneur parent.

Preuves exactes :

- `evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544_Y2_Plugin_Fix_sql.trx` ; SHA-256 `25768CC10F28BB74E1A7893F813D6D97F12C8FBA956D8B3338BF223EEDD7BA4B` ;
- `evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_FrenchTaxesRules_master_26.0.test.10.25-20260804_033544.xml` pour le package, Core, la variante et la commande MSTest réellement utilisés ;
- `evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_Clienteling_master_26.0.test.10.18-20260804_031847_Y2_Plugin_Fix_sql.trx` ; SHA-256 `3C8F65A14AED6D5980ADA723198A532EFAD4510ED4DFC7FEFC53E2B47FE56D56` ;
- `evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_Clienteling_master_26.0.test.10.18-20260804_031847.xml` pour le package, Core, la variante et la commande MSTest réellement utilisés ;
- inventaire scénario par scénario : `evidence/LEGACY_TEST_INVENTORY.md` ; verdicts de rapprochement : `cases/LEGACY_COMPARISON_MATRIX.md`.

### FACT / UNKNOWN — branches de release

- FACT — FrenchTaxesRules V5 : les exécutions `test.6.473` et `test.6.480` s'arrêtent avant MSTest, car `override\Y2_Plugins_FrenchTaxesRules_V5` est absent ; aucun scénario n'est exécuté dans ces deux captures.
- FACT — FrenchTaxesRules V7 : même arrêt avant MSTest pour `test.9.17`, `test.9.19` et `test.9.20`, dossier projet absent ; aucun scénario n'est exécuté.
- FACT — Clienteling V8 : même arrêt avant MSTest pour `test.9.12`, `test.9.13` et `test.9.18`, dossier projet absent ; aucun scénario n'est exécuté.
- FACT — les cinq XML Clienteling V7 `test.7.317`, `.319`, `.321`, `.323` et `.328` sont présents mais mesurent zéro octet ; Clienteling V6 ne possède aucun rapport d'exécution dans l'index collecté.
- UNKNOWN — aucune baseline branch-specific exécutable n'est donc établie pour FrenchTaxesRules V21-V25 ni Clienteling V22-V25. Les workflows/configurations seuls ne prouvent pas l'exécution d'un TestCase.

### Verdict de comparabilité

- FACT — les identifiants plan/TestCase V26 et, pour les deux échecs legacy, les assertions et valeurs observées se rapprochent directement des JMX.
- FACT — le Core Fix `26.0.0.1762` est commun aux exécutions legacy et aux variantes JMeter Fix documentées.
- UNKNOWN — les patches plugin diffèrent (`FrenchTaxesRules 26.0.10.25` contre `26.0.10.75` ; `Clienteling 26.0.10.18` contre `26.0.10.23`) et l'équivalence du backup, du déploiement VM/conteneur et des autres dépendances n'est pas démontrée.
- Verdict — TC22 FrenchTaxesRules et CreateReceipt TC32 Clienteling ne sont plus des cas « legacy vert / JMeter rouge » : la même postcondition échoue déjà dans la capture legacy. Pour les 489 cas passés en legacy puis non passés sous JMeter, conserver `UNKNOWN — comparabilité insuffisante` et ne pas conclure à une régression JMeter.

## Phase suivante — plan de correction

Le [protocole de poursuite des investigations](../../documentation/guides/PROTOCOLE_INVESTIGATION_ECARTS_LEGACY_JMETER.md), rédigé le 2026-09-06, définit les étapes de comparabilité, les rejeux discriminants et les critères de fermeture. Il complète le plan de correction ci-dessous ; sa rédaction ne constitue ni une implémentation ni un rejeu.

Le plan implémentable fondé uniquement sur les causes prouvées est conservé dans [CORRECTION_PLAN.md](CORRECTION_PLAN.md). Il couvre les quatre défauts de `JmeterCodeGen.cs`, les images SQL Full-Text, les endpoints/fixtures Clienteling, les piles Fix incompatibles et les autorisations FrenchTaxesRules V22 Fix. Il précise les décisions et propriétaires encore `UNKNOWN`, tient compte du garde-fou déjà présent sur le master actuel de PlatformDeploy et sépare explicitement les réponses métier, les TC99, collisions de données et différences sans baseline suffisamment comparable dans « Ne pas corriger sans preuve ». TC22 FrenchTaxesRules et CreateReceipt TC32 Clienteling doivent désormais y être lus comme des échecs également observés en legacy, dont la cause fonctionnelle reste à trancher, et non comme des régressions JMeter.

Cette phase n'a modifié aucun code, package, pipeline ou branche Azure DevOps.

## Frontière de preuve spécifique à Clienteling — état complété le 2026-09-06

Les résultats Clienteling analysés prouvent des cas JMeter non passés et leurs premières causes observables. Le TRX aval récupéré sur Y2-TSTAUTOXXPG2 prouve maintenant une exécution legacy master V26 Fix de 2 131 scénarios élémentaires, dont les 485 identifiants non passés sous JMeter. Il ne rend pas pour autant les environnements suffisamment comparables.

FACT — les runs Azure DevOps des branches legacy Clienteling n'ont publié aucun résultat automatique exploitable dans leurs TRX VSTest, mais cela décrivait seulement le pipeline amont. Le TRX MSTest local du 2026-08-04 est la preuve distincte d'une exécution aval TestAuto. L'hypothèse d'une désactivation générale est réfutée pour master V26 Fix à cette date ; elle reste `UNKNOWN` pour les exécutions exactes corrélées aux builds et pour les branches de release sans TRX exploitable. Ne jamais transformer un legacy `Passed` en « régression de migration » tant que package, backup, payload/assertion et environnement ne sont pas suffisamment rapprochés.

### Résultat de l'audit timeline/logs Clienteling

- FACT — les logs VSTest `4432556/45`, `4432653/45`, `4432675/45` et `4432608/230,231,233` appliquent `TestCategory!=BDD`, indiquent `No test matches`, sortent avec le code `0`, puis publient zéro résultat dans les Test Runs `6180391`, `6180481`, `6180515`, `6180482`, `6180483` et `6180484`.
- FACT — les tâches `launch-testsAutos` réussissent pour `4432556/94`, `4432653/101` et `4432675/102`, avec les workflows `226`, `227` et `228`. Cette preuve établit la soumission de la demande, pas l'exécution des tests sur l'environnement cible.
- FACT — `4432608` possède aussi les Test Runs vides `6180431`, `6180433` et `6180435`, mais les logs VSTest actuellement reliés ne permettent pas d'attribuer individuellement leur cause.
- INFERENCE — le désalignement filtre/catégories est le mécanisme le mieux étayé pour les six couples log/run explicitement reliés.
- UNKNOWN — il n'est pas démontré que les tests étaient désactivés, ni que les workflows externes ont exécuté ou non des tests. Les six TRX vides restent donc non comparables au JMeter, sans conclure à une régression.

## Résultat de la recherche de baselines comparables

### FrenchTaxesRules — `Export_Run` et `DocumentSignature_SignOne`

- FACT — recherche read-only sur 61 Test Runs appartenant aux 100 derniers builds de la définition `FrenchTaxesRules CI` (`2054`), branches `master` et `releases/V*` : aucun résultat Test Run nommé `Export_Run` ou `DocumentSignature_SignOne`.
- FACT — les builds vérifiés incluent `4436133`/commit `07a42172bebc65d17093e166ac08de22e4fe7248`/run `6182739`, `4432395`/commit `07a42172bebc65d17093e166ac08de22e4fe7248`/runs `6180138`,`6180388`, `4432288`/commit `07a42172bebc65d17093e166ac08de22e4fe7248`/run `6180090`, et `4427434`/commit `07a42172bebc65d17093e166ac08de22e4fe7248`/run `6176642`. Les TRX récupérés pour ces runs ne contiennent aucun des deux scénarios.
- FACT — au commit source `657a61cd6d6d08cac698517309077202c43a29f8`, `AutoTest/Export/Export_Run.g.cs` et `AutoTest/DocumentSignature/DocumentSignature_SignOne.g.cs` contiennent les classes MSTest exactes, marquées `TestCategory("BDD")`, avec appels au `LegacyDispatcherService` et fixtures XML correspondantes.
- FACT — le YAML exact du build `4432288` (`evidence/legacy-build-4432288/azure-pipelines-exact.json`) génère `WebServices` et `LegacyServices`, exclut `bdd`/`suspended` dans `testsFilterCriteria`, puis délègue l'exécution des tests BDD au job externe `TestAutos` via `IntegrationTests\\launch-testsAutos.v2.yml@azoTemplates`.
- Verdict `Export_Run` : `FACT — aucune exécution publiée trouvée dans le périmètre vérifié`.
- Verdict `DocumentSignature_SignOne` : `FACT — aucune exécution publiée trouvée dans le périmètre vérifié`.
- UNKNOWN — le workflow externe n'est pas couvert par les résultats Test Runs inspectés ; absence publiée ne prouve pas l'absence d'exécution externe.

### Clienteling — commits exacts et chemin d'exécution

- FACT — YAML exacts conservés : `4432556`/`0c0fd26533e46b13e029276f90b5c085c1804012`, `4432608`/`1b29b27aa3d899a39d2628f849b6643340de6a31`, `4432653`/`1abc22e57cf1c04557b146a42bfd1b822221c2b6`, `4432675`/`78902d855738d3736b4338aa835e7ef95829afbf`. Tous génèrent depuis `Data\\WebServices\\WebServices.xml`, compilent les assemblies `*.Tests.dll`, puis définissent `TestAutos (on Premise)` dépendant de `Publish` et appelant `IntegrationTests\\launch-testsAutos.v2.yml@azoTemplates`.
- FACT — les TRX vides cités contiennent tous le message `No test matches` avec le filtre `TestCategory!=BDD` ; les runs sont `6180391`, `6180481`, `6180515`, `6180431`, `6180433`, `6180435`, `6180482`, `6180483`, `6180484`.
- FACT — la timeline marque `TestAutos` skipped pour `4432608`, succeeded pour `4432556`, `4432653` et `4432675`. Les logs de lancement `94`, `101`, `102` retournent respectivement les workflows `226`, `227`, `228`.
- Verdict Clienteling : `FACT — aucune exécution publiée trouvée dans le périmètre vérifié` pour les TRX zéro résultat.
- Verdict complémentaire : `UNKNOWN — workflow externe ou preuve inaccessible` pour l'exécution effective de `TestAutos` et l'intention du filtre ; ne pas conclure à une désactivation.

## Traçage aval de TestAutos — arrêté sur autorisation manquante

Le template exact `evidence/Pipelines_Templates/IntegrationTests/launch-testsAutos.v2.yml` appelle asynchronement `http://<hostname>:8181/integrationlauncher` par SOAP `StartWorkflowAsync`. Le payload contient le nom du workflow, une itération `test.<buildNumber>-<timestamp>` et les arguments ; la réponse immédiate fournit un identifiant de corrélation. Le template ne définit aucun endpoint de statut, polling, téléchargement de logs ou collecte de TRX aval.

| Build | Commit | Corrélation | Verdict |
|---:|---|---:|---|
| FrenchTaxesRules `4432288` | `07a42172bebc65d17093e166ac08de22e4fe7248` | `162`, log `137` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| FrenchTaxesRules `4429632` | `4fdc84f70c869293711201416e195d1a36984472` | `66`, log `108` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| FrenchTaxesRules `4432320` | commit dans `evidence/legacy-build-4432320/build.json` | aucune étape TestAutos dans `timeline.json` | FACT — aucune soumission publiée dans la timeline vérifiée ; UNKNOWN — autre mécanisme éventuel |
| FrenchTaxesRules `4432365` | commit dans `evidence/legacy-build-4432365/build.json` | aucune étape TestAutos dans `timeline.json` | FACT — aucune soumission publiée dans la timeline vérifiée ; UNKNOWN — autre mécanisme éventuel |
| FrenchTaxesRules `4429170` | `1a34bcd2dc5d47a871ad330d82aff661934098bd` | phase skipped | FACT — étape skipped ; UNKNOWN — autre exécution aval éventuelle |
| Clienteling `4432556` | `0c0fd26533e46b13e029276f90b5c085c1804012` | `226`, log `94` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| Clienteling `4432608` | `1b29b27aa3d899a39d2628f849b6643340de6a31` | phase skipped, aucun identifiant | FACT — étape skipped ; UNKNOWN — autre exécution aval éventuelle |
| Clienteling `4432653` | `1abc22e57cf1c04557b146a42bfd1b822221c2b6` | `227`, log `101` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |
| Clienteling `4432675` | `78902d855738d3736b4338aa835e7ef95829afbf` | `228`, log `102` | FACT — soumission acceptée ; UNKNOWN — workflow externe ou preuve inaccessible |

FACT — les corrélations `162`, `66`, `226`, `227` et `228`, ainsi que les itérations exactes consignées dans les logs, ne réapparaissent dans aucune preuve locale inventoriée avec un statut final, un log aval, un TRX ou un résultat supplémentaire.

FACT — `Y2-TSTAUTOXXPG2` se résout localement, mais son endpoint `:8181/integrationlauncher` ne fournit pas de lecture GET exploitable.

UNKNOWN — l'autorisation ou l'interface de consultation du système `IntegrationTestsLauncherService` sur `Y2-TSTAUTOXXPG2` manque. La recherche s'arrête ici ; une soumission acceptée ne vaut pas exécution réussie.

## Phase effectuée — recherche des baselines depuis les Test Runs legacy

### Objectif et limite de la phase

Cette phase a déterminé, dans le périmètre vérifié, quels tests legacy ont été publiés et avec quel résultat, puis a recherché les noms exacts des scénarios JMeter encore UNKNOWN. Elle est restée strictement en lecture seule : aucun pipeline n'a été lancé ou relancé, aucune branche n'a été modifiée et aucun résultat n'a été publié.

Les TRX des runs legacy candidats ont maintenant été téléchargés et analysés. Les résultats de tests Azure DevOps sont publiés séparément comme `Test Run` et peuvent exister sans `Pipeline Artifact`. Un TRX MSTest doit être considéré comme une preuve legacy ; l'absence de JMeter dans ce TRX ne suffit pas à l'écarter. La comparabilité est décidée sur le contrat, les entrées, les sorties, les assertions, les packages et l'environnement.

En particulier, les formulations de `findings/001`, `findings/003` et `findings/009` ont été corrigées : les TRX couvrent des tests MSTest, et pour V26 `JsonWriteTest1`/`XmlWriteTest1` exécutent une analyse métier sur des fichiers fixtures. L'équivalence cas à cas avec les plans JMeter n'est toutefois pas démontrée et reste `UNKNOWN`.

### Candidats connus et état initial

| Plugin/version | Build JMeter à rapprocher | Build legacy candidat | État au démarrage |
|---|---:|---:|---|
| FrenchTaxesRules V26 | 4432510 et 4426342 | 4432288 | Test Run 6180090, TRX 522/522 passés ; `JsonWriteTest1` et `XmlWriteTest1` exécutent une analyse métier sur fixtures et génèrent des rapports. Équivalence avec JMeter à établir. |
| FrenchTaxesRules V26 | 4432510 et 4426342 | 4432320 et 4432365 | TRX de 522/522 tests passés par build, avec les mêmes sorties `JsonWriteTest1`/`XmlWriteTest1` ; stage JMeter skipped dans ces builds. |
| FrenchTaxesRules V25 | 4429629 | 4429632 | Run 6178203, TRX de 82/82 tests passés ; correspondance avec les cas JMeter non démontrée. |
| FrenchTaxesRules V22/V23 | 4429167 | 4429170 | Dix TRX de 2/2 tests passés, soit 20 résultats ; correspondance avec les cas JMeter non démontrée. |
| Clienteling V22/V23 | 4432602 | 4432608 | Six TRX, zéro résultat ; aucune désactivation ne peut être inférée. |
| Clienteling V24 | 4432652 | 4432653 | TRX zéro résultat ; aucune désactivation ne peut être inférée. |
| Clienteling V25 | 4432672 | 4432675 | TRX zéro résultat ; aucune désactivation ne peut être inférée. |
| Clienteling V26 | 4432554 | 4432556 | TRX zéro résultat ; aucune désactivation ne peut être inférée. |

Ne jamais choisir une baseline uniquement parce qu'elle est verte ou proche dans le temps. Pour être comparable, elle doit couvrir le même plugin et la même version, les mêmes scénarios, des packages identiques ou explicitement rapprochés, ainsi qu'un backup et une configuration d'exécution équivalents.

### Collecte Azure DevOps à effectuer

Pour chaque build candidat `<BuildId>` :

1. conserver ses métadonnées, son commit, ses paramètres et sa timeline ;
2. rechercher les Test Runs avec le filtre exact `buildUri=vstfs:///Build/Build/<BuildId>` ;
3. conserver le détail de chaque Test Run et ses statistiques globales ;
4. lister ses attachments avec `GET .../_apis/test/runs/<TestRunId>/attachments?api-version=7.1` ;
5. télécharger chaque `.trx` depuis l'URL exacte retournée pour l'attachment ;
6. inventorier dans le TRX chaque `UnitTestResult` : nom, outcome, durée, nom de classe éventuel, `StdOut`, `StdErr`, message et stack trace ;
7. relever les chemins de fichiers cités dans les sorties, sans considérer ces fichiers comme récupérables s'ils n'ont pas été explicitement publiés ou attachés.

Exemple PowerShell en lecture seule pour retrouver les Test Runs :

    $organization = 'cegid'
    $project = 'Retail'
    $buildId = 4432288
    $azureDevOpsResource = '499b84ac-1321-427f-aa17-267ca6975798'
    $aadToken = (az account get-access-token --resource $azureDevOpsResource --query accessToken -o tsv).Trim()
    $headers = @{ Authorization = "Bearer $aadToken" }
    $buildUri = [uri]::EscapeDataString("vstfs:///Build/Build/$buildId")
    $runsUri = "https://dev.azure.com/$organization/$project/_apis/test/runs?buildUri=$buildUri&api-version=7.1"
    $testRuns = Invoke-RestMethod -Method Get -Uri $runsUri -Headers $headers

Pour un run `<TestRunId>` :

    $runUri = "https://dev.azure.com/$organization/$project/_apis/test/runs/<TestRunId>?api-version=7.1"
    $attachmentsUri = "https://dev.azure.com/$organization/$project/_apis/test/runs/<TestRunId>/attachments?api-version=7.1"
    $run = Invoke-RestMethod -Method Get -Uri $runUri -Headers $headers
    $attachments = Invoke-RestMethod -Method Get -Uri $attachmentsUri -Headers $headers

Télécharger le TRX avec `Invoke-WebRequest` sur la propriété `url` exacte de l'attachment, puis supprimer les variables contenant le jeton. Ne jamais afficher, écrire dans un fichier ou committer le jeton AAD.

### Arborescence de preuve attendue

Conserver les réponses brutes et les téléchargements sans écraser les preuves existantes :

    evidence/legacy-build-<BuildId>/
      build.json
      timeline.json
      test-runs.json
      test-run-<TestRunId>.json
      test-run-<TestRunId>-attachments.json
      test-run-<TestRunId>.trx
      SHA256SUMS.txt

Ajouter les hashes SHA-256 et la provenance dans `evidence/README.md`. Si un build ne possède aucun Test Run, conserver la réponse vide et noter exactement : « aucun Test Run publié pour ce build ». Cette observation ne prouve ni que les tests étaient désactivés, ni qu'ils n'ont pas été lancés par un autre mécanisme.

### Rapprochement legacy ↔ JMeter

Créer `cases/LEGACY_COMPARISON_MATRIX.md` avec une ligne par cas rapproché et les colonnes minimales suivantes :

| Plugin | Version | Variante | Plan/TestCase legacy | Résultat legacy | Build/TestRun legacy | Plan/TestCase JMeter | Résultat JMeter | Équivalence environnement | Verdict | Preuve |
|---|---:|---|---|---|---|---|---|---|---|---|

Appliquer ces règles :

- `FACT — comportement déjà présent en legacy` seulement si le même cas échoue avec la même signature dans un environnement comparable ;
- `CANDIDAT ÉCART DE MIGRATION` si le même cas passe en legacy et échoue sous JMeter dans un environnement comparable ; ce verdict devient `FACT` seulement après avoir relié la différence à la requête, au payload, aux assertions ou à l'ordre généré ;
- `UNKNOWN — non comparable` si le cas n'est pas présent dans le TRX, si le contrat testé diffère, ou si packages, backup, paramètres ou version diffèrent sans rapprochement démontré. Une campagne MSTest peut rester une preuve legacy pertinente même sans JMeter.
- un chemin `*.error-descriptions.txt` mentionné dans `StdOut` est un indice, pas le contenu du fichier, tant que celui-ci n'est pas publié ou attaché ;
- ne jamais conclure à un écart Clienteling à partir du seul résultat JMeter si aucun cas legacy équivalent n'a réellement été exécuté.

### Ordre de travail recommandé

1. Auditer complètement `4432288 → 6180090 → TRX` et dire si les scénarios FrenchTaxesRules V26 concernés font partie des 522 tests.
2. Auditer les Test Runs de 4432320 et 4432365, puis celui de 4429632.
3. Identifier les builds legacy candidats pour les versions restantes à partir des définitions, branches, commits, versions de packages et périodes des builds JMeter.
4. Auditer Clienteling et distinguer : aucun Test Run publié, tâche de tests skipped/désactivée, ou Test Run ne couvrant que d'autres tests.
5. Construire la matrice de comparaison, puis réviser uniquement les verdicts `UNKNOWN` que les nouvelles preuves permettent réellement de relever.
6. Mettre à jour `cases/STATUS_MATRIX.md`, les fiches `findings/` concernées et la section « Conclusions déjà établies » de ce handoff avec les identifiants Build/TestRun/TRX exacts.

### Critère de fin de cette phase

La phase est terminée lorsque chaque build legacy candidat est associé soit à un inventaire TRX détaillé, soit à une preuve conservée d'absence de Test Run publié, et que chaque groupe JMeter encore présenté comme potentiellement comparable au legacy possède un verdict `FACT`, `CANDIDAT ÉCART DE MIGRATION` ou `UNKNOWN — non comparable` accompagné de sa preuve exacte.

## Documents à lire dans cet ordre

1. ce fichier ;
2. references/legacy_test_vm_technical_cheatsheet.md pour les VMs legacy, les chemins de collecte et les limites d'accès ;
3. cases/STATUS_MATRIX.md ;
4. findings/001-french-taxes-rules-v26.md ;
5. findings/002-build-4429629-initial-state.md ;
6. findings/003-french-taxes-rules-v25-build-4429629.md ;
7. findings/004-french-taxes-rules-v21-v23-build-4429167.md ;
8. findings/005-clienteling-v22-v23-build-4432602.md ;
9. findings/006-clienteling-v26-build-4432554.md ;
10. findings/007-clienteling-v24-build-4432652.md ;
11. findings/008-clienteling-v25-build-4432672.md ;
12. findings/009-french-taxes-rules-v26-build-4426342.md ;
13. evidence/README.md ;
14. ../../archive/handoffs/french-taxes-rules-v26-handoff-2026-09-05.md pour le détail historique de FrenchTaxesRules V26.

## Périmètre communiqué le 2026-09-05

| Priorité | Plugin | Branche | Versions | Build | Observation communiquée | État de preuve |
|---:|---|---|---|---:|---|---|
| 1 | FrenchTaxesRules | releases/V7 | 25 | 4429629 | capture : Fix 42, Cur 90 | Conflit : les runs Azure donnent Fix 90, Cur 42 |
| 2 | FrenchTaxesRules | releases/V5 | 21 à 23 | 4429167 | V22 Cur 0, Fix 138 ; V23 Cur 0, Fix bloqué sur InitializeContainers | Vérifié : V21 skipped ; V22 Fix 174, dont 138 Legacy et 36 Web ; V23 Fix bloqué par Docker avant test |
| 3 | Clienteling | releases/V6 | 21 à 23 | 4432602 | V22 Cur 383 ; Fix bloqué au déploiement ; V23 Cur 388 ; Fix bloqué au déploiement | Vérifié : deux totaux réels entièrement couverts ; Fix bloqués par des minima MSI incompatibles |
| 4 | Clienteling | master | 26 | 4432554 | 485 échecs en Cur et Fix | Vérifié : deux runs de 2 118 tests, 485 non passés chacun, entièrement couverts |
| 5 | Clienteling | releases/V7 | 24 | 4432652 | 380 échecs en Cur et Fix | Vérifié : deux runs de 2 118 tests, 380 non passés chacun, entièrement couverts |
| 6 | Clienteling | releases/V8 | 25 | 4432672 | 482 échecs en Cur et Fix | Vérifié : deux runs de 2 118 tests, 482 non passés chacun, entièrement couverts |
| 7 | FrenchTaxesRules | master | 26 | 4426342 | LegacyServices 4 échecs ; WebServices 2 échecs | Vérifié : mêmes six clés que 4432510 dans Cur et Fix ; 19/19 JMX byte-identiques ; mêmes causes et mêmes limites de preuve |

La capture source est conservée sous evidence/inventaire-branches-utilisateur-2026-09-05.png.

## Métadonnées Azure DevOps déjà vérifiées

| Build | Définition | Branche | Commit | Paramètres | Résultat |
|---:|---|---|---|---|---|
| 4426342 | FrenchTaxesRules CI | FrenchTaxesRules_Migration_AutoTest_Jmeter_On_master | 358fe9507e0eb1a4601437ec0c9db6bf197015cc | V26, Cur/Fix, LegacyServices/WebServices | partiallySucceeded |
| 4429167 | FrenchTaxesRules CI | FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V5 | 2d826b8fd19ecb4d7200f574414efb7583de8ed2 | V21/V22/V23, Cur/Fix, LegacyServices/WebServices | failed |
| 4429629 | FrenchTaxesRules CI | FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V7 | 657a61cd6d6d08cac698517309077202c43a29f8 | V25, Cur/Fix, LegacyServices/WebServices | partiallySucceeded |
| 4432554 | Clienteling CI | Clienteling_Migration_AutoTest_Jmeter_On_master | 1bcb509c38c31d337fcc5419c7b89d61a19fbe3a | V26, Cur/Fix, WebServices | partiallySucceeded |
| 4432602 | Clienteling CI | Clienteling_Migration_AutoTest_Jmeter_On_releases/V6 | 8744999cabb6cea993db49a2d2bf741ae2dd5454 | V21/V22/V23, Cur/Fix, WebServices | failed |
| 4432652 | Clienteling CI | Clienteling_Migration_AutoTest_Jmeter_On_releases/V7 | a3b9c933ddeaaf1846785ea6bc044e4bf4a083bb | V24, Cur/Fix, WebServices | partiallySucceeded |
| 4432672 | Clienteling CI | Clienteling_Migration_AutoTest_Jmeter_On_releases/V8 | 8f1088fb5f0d54fc7bb17caf351b98edcaa67706 | V25, Cur/Fix, WebServices | partiallySucceeded |

Ces métadonnées ont été relues le 2026-09-05 via l'API Build Azure DevOps.

## Conclusions déjà établies : ne pas les rouvrir sans preuve contraire

### FrenchTaxesRules V26, build détaillé 4432510

- FACT — Export TC08 : Cegid.Retail.AutoTest.Api inverse mois et jour pour les dates SQL ISO déjà entre apostrophes. La règle fautive produit année-jour-mois au lieu de année-mois-jour.
- FACT — TC09 et TC10 sont des conséquences de TC08 : la ligne mal datée n'est pas nettoyée, TC09 rencontre un doublon, puis TC10 compte la ligne résiduelle.
- FACT — ExpectedValue=-1 désactive seulement l'assertion sur le nombre de lignes ; il n'autorise pas une erreur SQL.
- FACT — Code=99 n'est pas une convention de skip. Les deux TC99 en faute sont des cas actifs sans assertion métier et obtiennent réellement HTTP 500 / CBR_062_0005.
- FACT — les runs verts 4432320 et 4432365 sur le même commit n'ont pas exécuté JMeter : le stage TI JMeter V26 était skipped. Ils ne constituent pas une baseline verte.
- INFERENCE FORTE — FrenchTaxesRules TC22 est un scénario indéterministe ou obsolète : deux DAEMON ont la même date et le produit utilise TOP 1 avec un ORDER BY uniquement sur cette date. Une décision fonctionnelle est nécessaire.
- UNKNOWN — le passage des mêmes scénarios sous le runner legacy n'est pas démontré. Le build legacy 4432288 est canceled, mais son TRX 6180090 a été analysé : 522 tests passés, dont `JsonWriteTest1` et `XmlWriteTest1` avec sorties métier sur fixtures ; leur équivalence aux cas JMeter reste non démontrée.

### Chaîne de packages du convertisseur

- FACT — le défaut est toujours présent sur master de Y2_Tools_AutoTest_Api au commit 220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2, version 1.1.46.
- FACT — le package Cegid.Retail.AutoTest.Console 2.0.41 utilisé par la migration embarque AutoTest.Api 1.1.46 et reproduit directement les conversions erronées.
- FACT — le package Console courant 2.0.42 embarque encore AutoTest.Api 1.1.46 et reproduit la même faute par invocation directe du binaire.
- FACT — les pipelines officiels sont AutoTest_Api CI, définition 2637, et AutoTest_Console CI, définition 2641.
- FACT — leurs derniers runs vérifiés, 4311236 et 4311240, sont succeeded mais ne publient aucun test run Azure. Les dépôts ne contiennent aucun projet de tests séparé.
- FACT — aucun PR actif ne corrige le sujet dans les dépôts API ou Console au 2026-09-05.
- FACT — la faute a été introduite par le commit 7cdeaea0f089c6b93cf52d11ae8d5d3137a0b3cd du 2025-02-11.

Conséquence pour le correctif durable : corriger et versionner l'API, mettre à jour la dépendance et la version de Console, republier Console, puis remplacer le package et la version dans Migration_Jmeter_RJE_Sandbox. Une retouche manuelle des JMX ne suffit pas.

### Portée silencieuse déjà trouvée dans FrenchTaxesRules V26

Le défaut ne touche pas seulement Export. DocumentSignature_SignOne TC02 contient deux littéraux 2025-10-07 générés en 20250710. Le test passe parce que ses assertions ne contrôlent pas le sens de cette date. Après correction du générateur, régénérer au minimum les plans Export_Run et DocumentSignature_SignOne, puis comparer le diff de tous les JMX.

### Piège dans les artefacts 4432510

Les artefacts WebServices contiennent aussi une copie byte-identique des 90 fichiers LegacyServices déjà présents dans les artefacts LegacyServices. Ne pas doubler les échecs en parcourant naïvement tous les fichiers extraits.

## État initial précis du build 4429629

Azure DevOps publie les résultats suivants :

| Variante | Campagne | Total | Passed | Failed |
|---|---|---:|---:|---:|
| Fix | LegacyServices | 185 | 136 | 49 |
| Fix | WebServices | 65 | 24 | 41 |
| Cur | LegacyServices | 185 | 155 | 30 |
| Cur | WebServices | 65 | 53 | 12 |

Total calculé : Fix 90, Cur 42. C'est l'inverse du texte de la capture. Les quatre runs 6178258, 6178260, 6178259 et 6178261 ainsi que leurs CSV d'erreurs ont été vérifiés : le conflit est résolu en faveur des compteurs Azure.

Le clone local sources/Y2_Plugins_FrenchTaxesRules-v7-build-4429629 est détaché exactement sur le commit du build, 657a61cd. La branche distante a depuis avancé à 54e9227c avec une seule modification de azure-pipelines.yml. Aucun nouveau run de cette branche n'a été trouvé après 4429629 ; ne pas analyser le YAML courant comme s'il avait produit ce build.

## Ordre de reprise recommandé

### 1. FrenchTaxesRules releases/V7 — build 4429629 — terminé

Les huit artefacts utiles ont été téléchargés et les 132 échecs sont couverts dans `findings/003-french-taxes-rules-v25-build-4429629.md`. Résultat confirmé : Fix 90, Cur 42. Les causes sont mixtes ; les verdicts encore UNKNOWN ont chacun un test discriminant explicite.

### 2. FrenchTaxesRules releases/V5 — build 4429167 — terminé

L'analyse est dans `findings/004-french-taxes-rules-v21-v23-build-4429167.md`. V21 est bien skipped. V22 Cur et V23 Cur sont verts. V22 Fix compte 174 refus d'autorisation, pas 138 : 138 Legacy et 36 Web. Les journaux MSI prouvent désormais l'installation historique des versions Core/Common/Identity Cur et Fix avec statut `0`; ils ne prouvent pas la consommation effective des binaires ni la projection correcte du catalogue `allowedModule`. L'absence des claims reste une conclusion antérieure rapportée, sans consultation de jeton dans la reprise. La cause composant reste `UNKNOWN`; aucune correction et aucun rejeu n'ont été réalisés. V23 Fix n'a exécuté aucun test, car le moteur Docker n'a pas répondu pendant `Initialize containers`.

## Full-Text SQL — état et reprise ciblée (2026-09-07)

**FACT** — les builds `4442156` et `4442685` de la définition dédiée `14251`, branche `sandbox/WI-2222897-sql-fulltext`, ont échoué sur les deux variantes SQL. `4442685` exécute exactement `e3b674b007071259fd74b024f6b4b48baf0a7f5d`; SQL2019 et SQL2025 atteignent `PopulateStatus=1` puis le timeout de 90 secondes. `CONTAINSTABLE` n’est pas atteint.

**FACT** — le probe au SHA distant et local est identique. Le patch local non publié est limité à `validation/WI-2222897/sql-fulltext-hosted-build.yml` dans `worktrees/Pipelines_Docker_BaseImages_worker2_round9` ; il collecte dans la console la propriété Full-Text, FD Launcher/fdhost, DMV catalogue/population/batches/ranges, état de crawl, espace disque et extraits de journaux ciblés expurgés. Il rend la collecte tolérante aux erreurs, conserve l’échec smoke, et vérifie `docker rm -f`; l’absence du conteneur n’est affirmée que si `docker ps` réussit, sinon elle reste `UNKNOWN`.

**FACT — revue round5** — la version précédente au hash `2698D6F4EFF7FBEE88419336AB169C823196156B656FCA3DCD48633CF6EF06B6` était bloquante : accolade supplémentaire dans SQL2025 et absence de contrôle du code de sortie `docker ps`. La correction locale actuelle est hashée `6C6FD9EC35AD02DA4B71DB8562888BB479441BCC44BED78D4B169E7DB66E21B3`; extraction complète, parse PowerShell et fixtures inertes passent. Aucun push ni queue n’a été effectué.

**UNKNOWN** — cause moteur/service FDHOST, crawl/word breaker, configuration ou espace disque ; `IsFullTextInstalled=1` ne suffit pas. `CONTAINSTABLE`, cleanup runtime et propagation dans les images JMeter restent non démontrés. Les 224 échecs Clienteling restent une incompatibilité d’infrastructure initialement prouvée, mais aucune correction métier n’est validée par ces smoke tests.

**SUITE minimale** — aucune publication Git autorisée dans cette reprise. Faire publier ce seul diff local, après contrôle de l’absence de changements étrangers et conservation du parent `e3b674b...`, sur la branche existante `sandbox/WI-2222897-sql-fulltext`, puis effectuer une seule queue manuelle de `14251`. Ne pas utiliser `yamlOverride` de preview comme preuve d’exécution ; relire le YAML effectivement référencé, le commit source et les logs terminaux. La queue doit rester sans trigger/PR/schedule, sans image/feed/JFrog/promotion/tag, avec PipelineArtifact seulement. Ne lancer aucun rejeu Clienteling avant preuve de population terminée, `CONTAINSTABLE` positif et cleanup vérifié.

Référence : [finding 014](findings/014-sql-fulltext-runtime-4442685.md) et [preuve 4442685](evidence/2026-09-07-sql-fulltext-build-4442685/README.md).

### 3. Clienteling releases/V6 — build 4432602

Terminé dans `findings/005-clienteling-v22-v23-build-4432602.md`. V22 Cur publie 383 cas non passés et V23 Cur 388. Les 381 cas communs ont la même signature ; la différence nette de cinq vient uniquement des postconditions propres à chaque version. La partition causale couvre tous les cas. Les variantes Fix n'atteignent pas JMeter : leurs versions minimales violent des prérequis MSI explicites et le contrôle de santé rencontre ensuite des connexions refusées.

### 4. Clienteling master — build 4432554 — terminé

L'analyse est dans `findings/006-clienteling-v26-build-4432554.md`. Cur et Fix publient chacun 485 cas non passés ; les 485 clés et leurs catégories correspondent exactement. Le groupe dominant est l'absence de SQL Full-Text, 224 cas. La partition couvre aussi 105 défauts prouvés du générateur, 23 endpoints inexistants, 23 XML internes déséchappés, 22 collisions de préconditions, 85 réponses différentes des attendus et les groupes résiduels bornés. Le package Clienteling est 26.0.10.23 dans les deux variantes.

### 5. Clienteling releases/V7 — build 4432652 — terminé

L'analyse est dans `findings/007-clienteling-v24-build-4432652.md`. Cur et Fix publient chacun 380 cas non passés, avec les mêmes 380 clés et catégories. V24 partage 378 clés de même catégorie avec V26. Cette répétition ne constitue pas une comparaison avec le legacy. La partition couvre tous les cas.

### 6. Clienteling releases/V8 — build 4432672 — terminé

L'analyse est dans `findings/008-clienteling-v25-build-4432672.md`. Cur et Fix publient chacun 482 cas non passés, avec les mêmes clés et catégories. Les 482 clés sont un sous-ensemble exact des clés V26 ; V26 ajoute seulement trois différences d'images. Cette répétition ne constitue pas une comparaison avec le legacy. La partition couvre tous les cas.

### 7. FrenchTaxesRules master — build 4426342 — terminé

Le rapprochement est dans `findings/009-french-taxes-rules-v26-build-4426342.md`. Les runs 6175734/6175735 publient quatre cas LegacyServices et les runs 6175746/6175748 deux cas WebServices, avec les mêmes six clés dans Cur et Fix. Ces clés correspondent exactement au build 4432510 et les 19 JMX des deux commits sont byte-identiques. Les causes de findings/001 s'appliquent, sans relever les verdicts encore `UNKNOWN`. Le plugin a évolué de 26.0.10.67 à 26.0.10.75 entre les deux builds : il s'agit d'une reproduction des causes, pas d'environnements intégralement identiques.

## Procédure de collecte sûre

Initialiser le PAT uniquement dans le processus courant :

    $env:AZURE_DEVOPS_EXT_PAT = (Get-Content -Raw -LiteralPath 'C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt').Trim()

Commandes de lecture usuelles :

    az pipelines runs show --id <buildId> --organization https://dev.azure.com/cegid --project Retail -o json
    az devops invoke --organization https://dev.azure.com/cegid --area build --resource timeline --route-parameters project=Retail buildId=<buildId> -o json
    az pipelines runs artifact list --run-id <buildId> --organization https://dev.azure.com/cegid --project Retail -o table

Télécharger seulement les artefacts dont le nom contient Deployment_logs, LegacyServices_TestLogs, WebServices_TestLogs ou RunLogs. Créer un dossier evidence/build-<id> par build et conserver les ZIP originaux à côté d'un sous-dossier _extracted.

À la fin de chaque commande :

    Remove-Item Env:\AZURE_DEVOPS_EXT_PAT -ErrorAction SilentlyContinue

Ne jamais afficher, persister ou committer le PAT. Ne pas ouvrir ni recopier `../../worktrees/Migration_Jmeter_RJE_Sandbox/jfrogToken.txt`.

## Méthode d'analyse attendue pour chaque build

1. Figer le commit du build, ses templateParameters et sa timeline.
2. Vérifier si la branche distante a avancé depuis ce commit.
3. Inventorier les test runs Azure et calculer les totaux par campagne et variante.
4. Télécharger les artefacts utiles et vérifier les duplications entre artefacts avant de compter.
5. Construire un tableau de signatures normalisées : plan, TestCase, opération, code HTTP/exception, code métier, assertion observée/attendue.
6. Relier chaque signature au JMX exact, puis à la source XML legacy et au code du générateur si la requête ou le payload diffère.
7. Pour les cascades, démontrer l'état laissé par le premier échec et l'ordre d'exécution.
8. Pour un échec de déploiement, arrêter l'analyse fonctionnelle tant que le test n'a pas réellement démarré.
9. Comparer avec un run vert seulement si les mêmes stages, campagnes, variantes, commit et paramètres ont été exécutés.
10. Mettre à jour cases/STATUS_MATRIX.md et créer une fiche courte dans findings/.

## Critère de fin d'une investigation

Une ligne n'est terminée que lorsque toutes les fautes publiées sont couvertes par des signatures comptées et qu'au moins l'un des verdicts suivants est démontré pour chaque signature :

- cause racine prouvée ;
- cause probable avec preuve et test discriminant restant ;
- UNKNOWN avec le manque de preuve précisément identifié.

Un build vert, un message de succès de script ou une similarité de symptômes ne constitue pas seul une preuve.

## Actions non réalisées

- Aucun code produit, XML source, JMX, branche distante, PR, pipeline ou work item n'a été modifié dans cette reprise.
- Les artefacts des sept builds prioritaires et les Test Runs/TRX des candidats legacy 4432288, 4432320, 4432365, 4429632, 4429170, 4432556, 4432608, 4432653 et 4432675 ont été collectés et analysés en lecture seule ; toutes les lignes de la matrice sont couvertes.
- Les TRX MSTest n'ont pas été écartés : `JsonWriteTest1` et `XmlWriteTest1` sont documentés comme preuve fonctionnelle legacy ; la matrice conserve `UNKNOWN` uniquement lorsque l'équivalence avec le contrat JMeter n'est pas démontrée.
- Les snapshots exacts FrenchTaxesRules V5/V7/master et Clienteling V6/V7/V8/master sont matérialisés. Le snapshot FrenchTaxesRules 4426342 est un export sans métadonnées Git parce que les commits 358fe950 et f80bc731 ont des histoires disjointes.
- Le backup Git LFS n'a pas été téléchargé ; il ne le faut que pour un rejeu local ciblé.

## 2026-09-06 — Revue locale du brouillon après étape 28

La revue documentaire des sept contrôles est dans `evidence/local-2026-09-06-v26-fix-replay-review/` et sa conclusion atomique dans `findings/010-v26-fix-replay-draft-review.md`. Verdict : **BLOQUÉ avant définition/exécution**. Le XML résout `ExportRunOnly.xml` vers le plan complet `TestPlans\Export_Run.xml`, mais le JMX corrigé effectivement consommé reste UNKNOWN. Le checkout/commit, l’agent LTSC2025, PlatformDeploy/packages/backup et les identités effectivement chargées restent UNKNOWN. Le contrôle SQL/IIS est insuffisant car la journalisation des cibles est postérieure au déploiement. Enfin, `parameters.properties` est affiché avec `PASSWORD`/`DB_PASSWORD` et l’archive de déploiement est collectée sans inspection de contenu : ne pas publier ce brouillon tel quel.

Suite uniquement après correction documentaire : épingler checkout/JMX et manifestes d’empreintes, résoudre l’agent et les acquisitions, ajouter les refus pré-écriture et l’isolation des ressources, supprimer les impressions secrètes et inspecter/redacter l’archive. Aucun pipeline, JMeter, déploiement ou mutation distante n’a été lancé.

## 2026-09-07 — Prérequis artefacts FrenchTaxesRules V22

Le snapshot du build 4429167 contient un seul backup, `Tests/Backups/AUTO_V21_00.bak`, hashé dans [la collecte des prérequis](evidence/2026-09-07-v22-replay-prereqs/README.md). Le YAML passe `Tests/Backups` au déploiement et injecte `DB_NAME=$(backupName)`, mais la valeur résolue par le groupe de variables n'est pas disponible. Ne pas exiger un nom V22 sans preuve. Les manifests sélectionnent 12 JMX LegacyServices et 20 WebServices ; trois JMX minimaux sont hashés pour le rejeu discriminant. UNKNOWN : restauration, contenu/compatibilité SQL, substitutions finales SQL/IIS et cible dédiée. La revalidation JFrog conserve uniquement un README de synthèse, sans ZIP ni fichier de hashes séparé. Aucun lancement, restauration ou mutation externe n'a eu lieu.

Le brouillon `replay-prep/2026-09-07-v22-isolated/` vérifie maintenant le backup par SHA-256, une attestation JSON non secrète des cibles SQL/IIS non partagées, la restauration séparée par variante, les 32 JMX historiques et les 32 JMX d'entrée. Le script est syntaxiquement valide et refuse inerte une attestation absente. Les SHA-256 de fichiers templates locaux sont documentés, mais aucun commit approuvé du dépôt `Pipelines_Templates` n'est prouvé ; `TEMPLATES_COMMIT_REQUIRED` et l'arrêt avant déploiement restent en place. Aucun résultat métier n'est acquis.

Les JMX historiques peuvent être réutilisés directement ; aucune régénération n'est imposée. Le runner local est suivi statiquement jusqu'à `jmeter.bat -n -t`, mais aucune exécution n'est prouvée.
## 2026-09-07 — CleanXpath et provenance Unicode

`CleanXpath` est corrigée dans le worktree API et validée sur DLL de production compilée isolément. Les tests couvrent Fault nu, prédicat, descendants, témoins non-Fault et XML SOAP avec namespace. La source legacy `ItemSearch_Keywords.xml` est bien présente dans la preuve indexée; le JMX du harness Unicode reste un artefact déjà transformé, donc aucune génération intégrée complète depuis cette XML n'est revendiquée. Voir `evidence/local-2026-09-07-cleanxpath/`.

Le brouillon Round 4 (`worktrees/WI-2222897-v26-fix-replay-draft-round4/`) ne fait qu'un préflight. Son runner a été exercé avec `jmeter.bat` inerte, sans JMeter métier; il n'atteste pas l'isolation SQL/IIS. Java 23 a été détecté, Java 21 cible non validée; acquisitions et Azure CLI restent UNKNOWN.

Historique supersédé : une tentative de génération Console intégrée depuis la source legacy `ItemSearch_Keywords.xml` (DLL CleanXpath corrigée, staging profond) avait échoué avant JMX sur `System.IO.PathTooLongException` dans `JmeterGenerator.CloneDirectory`. Aucun `C:\temp`/`subst` n'avait été utilisé. La génération source→JMX et la validation de `RemoveSpecialCharsForXQuery` sont ensuite prouvées depuis un staging court, voir `evidence/local-2026-09-07-four-plans-integrated/`.

Depuis le staging temporaire court autorisé, Console originale et corrigée ont généré `001-plan01.jmx` depuis la véritable `ItemSearch_Keywords.xml` (code 0). SQL TC02 diffère comme attendu (`N'...''N'` original contre littéral Unicode correctement conservé corrigé); XPath observé `//GetKeywordsResponse/GetKeywordsResult/Keywords/string` est identique. JMX hashes : original `15754B161BDBB78E66A61E6EAF83504F894758E8AA1EB4DCEA2D1E31EBFF833B`, corrigé `972A87B410BF2CB1A0C85E03D171092D5056D32B210139703C352C668E975B22`. Cette formulation est historique pour les quatre plans : leur génération source→JMX est désormais prouvée dans la validation étendue ci-dessous.

Validation étendue : les quatre XML legacy Mobility/ItemSearch ont été générés par Console originale et corrigée dans un staging temporaire court, 4/4 JMX par variante, code 0. Parsing : 682 SQL et 185 XPath; XML interne échappé dans la variante corrigée, Fault émis sous `//Fault/...` au lieu de `//fault...`. Preuve `evidence/local-2026-09-07-four-plans-integrated/`. Aucun moteur JMeter, SQL, HTTP ou migration exécuté.

Contrôle sémantique XPath : les JMX corrigés configurent `namespace=false`, `tolerant=false`, `validate=false`, `whitespace=false`. Sur SOAP synthétique, XML local montre `//Fault` = 0 avec namespace SOAP, contre `//soap:Fault` = 1 avec namespace manager. Le moteur JMeter complet n'étant pas disponible (stub seulement; Java 23.0.1 vs cible 21), le risque de faux négatif reste UNKNOWN et aucune nouvelle modification CleanXpath n'est justifiée.

## 2026-09-07 — Rangement d'un handoff manuel externe (non revérifié)

Un document manuel externe au processus `brain-worker` a été rangé et indexé sous [evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/](evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/README.md). Il revendique, sur la même DLL `57BE...` que le round13 SOAP ci-dessus, une validation négative complète (`ExpectedValue=0` → `XPath.negate=true`, fixture `Control` et non `OutputControl`, exécution JMeter 5.6.3 réelle avec `EXECUTION_POSTCONDITION=PASS`) — ce qui, si confirmé, lèverait l'`UNKNOWN` signalé plus haut (« aucun cas round13 avec négation `ExpectedValue=0` n'a été exécuté »). Il signale aussi comme non résolu si `57BE...` consolide `EscapeJdbcDate` et `FixSqlUnicodeValue`.

**Ce rangement n'a revérifié aucune de ces affirmations.** Avant de mettre à jour `findings/012` ou de lever l'`UNKNOWN` correspondant, rejouer indépendamment le cas négatif et vérifier les deux correctifs SQL/date dans la DLL `57BE...`.

## 2026-09-07 — Addendum au handoff manuel externe : consolidation DLL, propagation SQL/date, diagnostic Docker par agent (non revérifié)

Un second document, déposé dans `Downloads` et rangé à côté du handoff ci-dessus (même dossier [`evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/`](evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/README.md), fichier `WI-2222897_JMeter_Legacy_Handoff_Addendum_2026-09-07.md`), complète explicitement ce handoff sans le remplacer.

**Ce rangement n'a pas non plus revérifié ces affirmations.** La source revendique trois avancées :

1. la DLL `57BE...` contiendrait, en plus de SOAP namespace-aware, les correctifs `EscapeJdbcDate` et `FixSqlUnicodeValue` (testés par réflexion directe sur le binaire) — ce qui, si confirmé, lèverait le point resté ouvert dans le handoff précédent ;
2. la propagation package→Console→JMX de ces deux correctifs SQL/date serait désormais prouvée par le même chemin réel que SOAP, avec relecture correcte du JMX via `System.Xml.XmlDocument.Load()` (une lecture `Get-Content -Raw` sous PowerShell 5.1 ayant d'abord produit un faux négatif d'encodage) ;
3. le cas déjà canonique `Y2_Plugins_FrenchTaxesRules releases/V5 V23-Fix` (build `4429167`, cf. [finding 004](findings/004-french-taxes-rules-v21-v23-build-4429167.md) : « V23 Fix n'a exécuté aucun test, car le moteur Docker n'a pas répondu ») serait précisé au niveau agent : `V23-Cur` réussi sur `Azure Pipelines 51`, `V23-Fix` échoué sur `Azure Pipelines 21` (`Log ID 449`), d'autres jobs réussis sur `41`/`53` — concluant à un agent 21 défaillant/transitoire.

**Écart signalé, non tranché** : cette source indique quatre tentatives `docker version` avant l'échec, contre trois dans `findings/004` (établi le 2026-09-05). Ne pas citer l'un ou l'autre chiffre comme `FACT` sans relire directement le log `4429167` / `449`.

Avant de citer la consolidation DLL, la propagation SQL/date ou le détail par agent comme `FACT` canonique, rejouer indépendamment : réflexion directe sur la DLL `57BE...` pour `EscapeJdbcDate`/`FixSqlUnicodeValue`, régénération réelle du JMX de propagation, et relecture du log Azure DevOps exact du build `4429167`. Compléments ajoutés dans [finding 004](findings/004-french-taxes-rules-v21-v23-build-4429167.md) et [finding 012](findings/012-jmeter-5-6-3-xpath-namespace.md).

## 2026-09-07 — Rangement d'un second handoff manuel externe : InventoryTracking XmlDiff (non revérifié)

Un second document manuel externe a été rangé et indexé sous [evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/](evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/README.md). Il reprend la cause déjà canonique du [finding 013](findings/013-inventorytracking-xmlDiff-migration-build-4434070.md) (perte de restauration `Cegid.Retail.XmlDiff`/`XMLDiffPatch` pour `Services.Tests` après suppression de `WebServices.Tests`) et le correctif déjà validé localement dans [evidence/2026-09-07-inventorytracking-local-xmldiff-validation/](evidence/2026-09-07-inventorytracking-local-xmldiff-validation/README.md).

**Point nouveau et sensible, non revérifié** : il revendique la création d'une branche distante `validation/WI-2222897-inventorytracking-xmldiff` (commit `ef3d8703`) et un run Azure DevOps réel sur la définition `2072` — build `4440774`, `SUCCEEDED`, `Build V26` passant. Ceci va au-delà de la consigne de la section « Revalidation primaire InventoryTracking migration (Worker 2 round2) » ci-dessus (« créer aucun pipeline ; effectuer uniquement un checkout local isolé »). **Ne pas traiter ce run comme preuve canonique sans vérification indépendante** (existence réelle du build/branche via `az`/API REST, absence de merge/PR vers une branche partagée) et sans réconcilier explicitement l'écart avec la consigne de prudence précédente.

Acquisition Apache JMeter 5.6.3 tentée dans un staging temporaire, mais TLS échoue (`SEC_E_NO_CREDENTIALS`) avec Invoke-WebRequest et curl. Aucune distribution acquise; validation JMeter réelle reste UNKNOWN. La preuve `local-2026-09-07-migration-chain-isolated-round9/` établit seulement Console/API/XML→JMX, pas l'orchestrateur migration ni le package.

## 2026-09-07 — Second handoff manuel (17:15), même sujet InventoryTracking : escalade du run ADO et premier écart JMeter réel (non revérifié)

Un second document, déposé dans `Downloads` et rangé à côté du précédent (même dossier [`evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/`](evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/README.md), fichier `HANDOFF_WI-2222897_2026-09-07.md`), reprend intégralement le contenu ci-dessus et ajoute, toujours **non revérifié** :

- un **second run réel** `Build ID 4440884` (`pipelineDevMode=true`), qui activerait en plus `Ensure_Docker_Image_Up_To_Date` et la publication `ArtifactoryCloud staging`, et exécuterait réellement les campagnes JMeter Cur/Fix — **une escalade supplémentaire de l'écart déjà signalé** avec la consigne « créer aucun pipeline » ci-dessus, cette fois avec des effets externes (image Docker, publication staging) et pas seulement un build ;
- le **premier écart JMeter réel rapporté pour InventoryTracking depuis le correctif XmlDiff** : sur 1991 tests publiés de chaque côté, delta net d'un seul test, `002-Device:Reassign - TC 122` (Fix `Failed` sur `B-XQuery:Internal Server Error`, Cur `Passed`) — la cause et la reproductibilité restent `UNKNOWN` selon la source elle-même, et le mapping vers le sample JMeter brut n'a pas été retrouvé dans les artefacts déjà téléchargés.

**Avant de traiter ce second run ou l'écart `TC 122` comme canonique** : vérifier indépendamment l'existence et le statut réels de `4440884` via `az`/API REST, concilier explicitement les deux runs revendiqués avec la consigne de prudence, et ne pas relancer de nouveau run tant que le mapping `TC 122` → sample brut n'est pas résolu par lecture des artefacts déjà téléchargés. Complément ajouté dans [finding 013](findings/013-inventorytracking-xmlDiff-migration-build-4434070.md).

## 2026-09-07 — Worker 3 Round 2 — Clienteling fixtures

**FACT** — la collecte [2026-09-07-brain-reprise-worker3](evidence/2026-09-07-brain-reprise-worker3/README.md) relie la configuration `CustomImageLocation` au placeholder `${tests.folder}\\${CustomImageFolder}`, compte onze JPG dans l'historique V6 et zéro image dans le snapshot migré. Le template PlatformDeploy ne contient pas de copie/montage explicite `CustomImage`/`ImageFolder`.

**FACT discriminant** — le script local archivé prouve `placeholderExistsAsPath=false` et `resolvedFixtureExists=true` avec une fixture factice temporaire, puis nettoie sa ressource. **INFERENCE** — une correction doit être portée par le propriétaire du transport de fixtures et définir un chemin absolu/visible par IIS. **UNKNOWN** — propriétaire exact, artefact ou montage final, chemin IIS et support métier.

**PlatformDeploy** — la méthode Worker 2 round2 via `AZURE_DEVOPS_EXT_PAT` éphémère et `az pipelines build show`/timeline/logs est disponible dans sa collecte; aucune nouvelle boucle d'authentification n'a été lancée par Worker 3. Pour 4432602, `foundPlatformDeployVersion` reste UNKNOWN dans les preuves locales.

## 2026-09-07 — Préflight runtime FrenchTaxesRules V22 Worker 1 round7

**FACT** — support dédié créé sur branche `codex/wi-2222897-v22-preflight-20260907`, commit final `5036e501ba797ab7efc861add60b111a40ff8141`, définition `14246`, YAML inline avec `checkout:none`, triggers désactivés, image historique `sha256:268476...` et timeout 10 minutes.

**FACT** — preview serveur HTTP 200. Run `4441699` a échoué avant pull sur un défaut local du script, corrigé sans effet distant. Run `4441719` : service connection `AzureContainerRegistry-Docker-Retail` login réussi, checkout skipped, puis pull refusé par le registre : `pull access denied for cegid-retail-docker-production/y2-jmeter, repository does not exist or may require 'docker login'`. Aucun conteneur/output runtime n’a été produit ; nettoyage final réussi.

**VERDICT** — le préflight distant est bloqué par l’accès image du service connection ; il ne fournit pas la preuve runtime. Le rejeu métier n’a pas été lancé. La prochaine action nécessite une décision/autorité humaine sur le service connection ou une source image approuvée ; aucun contournement TLS, secret ou permission partagée n’est acceptable.

Preuves détaillées : [`evidence/azure-devops-french-taxes-rules-v22-worker1-round7/`](evidence/azure-devops-french-taxes-rules-v22-worker1-round7/).

### Addendum round8 — correction du diagnostic image

Le blocage ci-dessus ne démontre pas à lui seul un droit ACR manquant. Le service connection indique l’ACR resource `AcrRetailDocker`, tandis que la chaîne du `docker pull` de 4441719 omettait le hostname et pouvait être résolue vers le registre Docker par défaut. Le log historique 4429167 employait le même chemin logique avec `az acr manifest`, pas un pull Docker non qualifié. Le manifest JFrog Docker API HTTP 200 et son `Docker-Content-Digest` concordent avec `sha256:268476...`.

Patch local reviewable : [`replay-prep/2026-09-07-v22-preflight/image-reference-correction.local.patch`](replay-prep/2026-09-07-v22-preflight/image-reference-correction.local.patch), ajout de `acrretaildocker.azurecr.io/` devant le repository. Non poussé, non mis en queue. Preuves complètes : [`evidence/azure-devops-french-taxes-rules-v22-worker1-round8/`](evidence/azure-devops-french-taxes-rules-v22-worker1-round8/).

### Addendum round9 — hostname exact non établi

Les logs et YAML historiques prouvent le couple logique ACR `AcrRetailDocker` + `cegid-retail-docker-production/y2-jmeter`, et le digest. Ils ne fournissent pas le champ `loginServer`. Le hostname `acrretaildocker.azurecr.io` est seulement conventionnel/inféré ; ne pas le présenter comme fait ni lancer le préflight corrigé avec cette valeur sans confirmation. Aucune permission/service connection n’a été modifiée et aucune queue supplémentaire n’a été lancée. Intervention minimale : lecture ARM non sensible du `loginServer` par une identité déjà autorisée, ou confirmation écrite du propriétaire. Preuve : [`evidence/azure-devops-french-taxes-rules-v22-worker1-round9/`](evidence/azure-devops-french-taxes-rules-v22-worker1-round9/).

## 2026-09-08 — Trois missions BW paralleles lancees

Nouvelle demande utilisateur : identifier et tester les correctifs outils, environnements et depots produit, sans impact negatif significatif sur les collegues. [Prompts et suivi du lot](parallel/2026-09-08-parallel-1788841150349/README.md). Trois orchestrateurs distincts, maximum 12 rounds chacun, clones et sorties exclusifs. Le lanceur seul consolide les documents communs. BW2 seul operateur des essais d'environnement dedies; aucune promotion JFrog ni publication vers un feed partage. Statut initial : running, aucun resultat de correction encore revendique.
