# Protocole de poursuite des investigations legacy / JMeter

Date de rédaction : 2026-09-06. Statut : protocole proposé, non exécuté. Fondé sur les documents locaux relus ce jour ; aucun état distant n'a été revérifié pour cette rédaction.

## Objectif et point de départ

Pour chaque famille d'écarts, obtenir une cause démontrée, une correction validée ou un blocage explicite avec la preuve manquante. Le diagnostic des sept builds est terminé ; cela ne signifie ni que les corrections sont appliquées, ni que la migration est validée.

**Principe directeur : l'objet est l'écart JMeter/Legacy, jamais le simple fait que JMeter soit en échec. Si le même test case échoue aussi en Legacy avec la même postcondition ou la même signature, l'outil de migration n'est pas mis en cause par ce résultat ; le verdict est un échec commun et l'enquête doit rechercher une cause produit/scénario/données/environnement. Une mise en cause de la migration exige une différence propre au chemin JMeter, démontrée à contrat comparable.**

La [matrice legacy](../../investigations/ecarts-jmeter-migrations/cases/LEGACY_COMPARISON_MATRIX.md) établit le point de départ suivant :

- FACT — sur les 491 identifiants V26 rapprochés, 489 passent dans les captures legacy et sont non passés sous JMeter ; les versions plugin et les environnements ne sont pas suffisamment comparables pour conclure à une régression.
- FACT — `FrenchTaxesRules_Run` TC22 et `SaleAndSellers_CreateReceipt` TC32 échouent déjà en legacy avec la même postcondition. Leur cause fonctionnelle reste UNKNOWN.
- UNKNOWN — aucune baseline legacy suffisamment comparable n'est établie pour les branches de release étudiées. Les captures master V26 ne remplacent pas ces baselines.

Conserver deux axes distincts : **corriger et valider les défauts techniques prouvés**, puis **expliquer les différences fonctionnelles restantes par des expériences comparables**. Un défaut de génération directement reproduit peut être corrigé sans attendre une baseline legacy complète ; cela ne prouve pas pour autant la cause de tous les échecs historiques.

## 0. Isoler les essais pour limiter l'impact sur les collègues

Cette règle s'applique à toutes les étapes suivantes : **un essai ne doit ni remplacer un artefact collectif, ni modifier un environnement utilisé par les collègues, ni devenir automatiquement consommable par leurs pipelines**. Préférer les lectures, les builds locaux et les artefacts attachés à un run identifié. Un nom distinct limite les collisions, mais ne protège pas à lui seul contre les déclenchements automatiques, les sélections par wildcard ou la consommation de ressources partagées.

Les chaînes de « publication » décrites dans le plan de correction indiquent les dépendances techniques. Pendant l'investigation, les réaliser par transfert explicite d'artefacts entre essais isolés. Leur publication dans les circuits collectifs relève d'une étape ultérieure distincte. La présente modification du protocole ne lance aucun essai et n'autorise pas un push Docker immédiat.

### 0.1. Code, pipelines et déclenchements

- Utiliser un worktree ou clone dédié et une branche personnelle identifiée par le WI ; relever l'état Git avant modification. Préserver les changements préexistants, notamment le YAML utilisateur. Ne pas modifier `master`, les branches de release, les templates partagés ni les définitions de pipeline collectives pour faciliter l'essai.
- Préparer localement le YAML complet de l'essai et vérifier les templates, scripts appelés et tâches de fin, y compris celles exécutées en cas d'échec. Contrôler les destinations après résolution des variables. Désactiver par défaut push NuGet, push Docker, BuildInfo JFrog, promotion, tags Git et déclenchement de déploiements.
- Avant un push de branche ou un lancement autorisé, vérifier aussi les triggers CI/PR, planifications, ressources pipeline, triggers de fin de build, hooks et releases qui pourraient réagir à ce push ou à cet artefact. Désactiver un trigger dans un YAML ne suffit pas à exclure les abonnements définis ailleurs. Si cet effet aval reste inconnu, utiliser un chemin local ou une définition d'essai explicitement isolée.
- Ne pas modifier les groupes de variables, connexions de service, credentials, configurations NuGet/Docker globales ou caches partagés. Utiliser des paramètres, répertoires de travail et caches propres à l'essai. Employer un accès en lecture seule quand aucune écriture n'est nécessaire.
- Limiter les runs aux cas ciblés, un lot à la fois par défaut, avec timeout et plafond de ressources définis avant lancement. Privilégier un agent dédié ; sur un pool partagé, vérifier la capacité et convenir d'un créneau si le lot risque de monopoliser l'agent. Ne pas arrêter ni purger les jobs des collègues.

### 0.2. NuGet : fabrication et récupération uniquement par artefact de pipeline

**Aucun push NuGet d'investigation vers JFrog/Artifactory ni vers un autre feed partagé**, y compris pour API, Console et Workflow. Conserver le pack et la publication du `.nupkg` comme artefact du run Azure DevOps ; désactiver BuildInfo, promotion et tag source associés.

1. Donner à la version d'essai un identifiant unique compatible avec les outils consommateurs, par exemple une version prerelease `2.0.43-rje.wi2222897.b<buildId>` : exemple de convention, pas version disponible ni réservée. Si le consommateur refuse ce format, choisir une version technique unique et vérifier sa compatibilité sans l'envoyer dans un feed collectif.
2. Attacher les paquets, leur manifeste et leurs SHA-256 à un artefact nommé, par exemple, `rje-wi2222897-nuget-<buildId>`. Conserver les logs utiles et une durée de rétention adaptée à l'investigation, sans embarquer de secret ni tout le workspace.
3. Télécharger cet artefact par **définition, build ID et nom exacts** ; ne pas sélectionner le « dernier réussi », une version flottante ou un wildcard. Vérifier les empreintes après récupération.
4. Alimenter le build Console, le consommateur de migration ou le contexte Docker depuis les fichiers récupérés. Si une restauration NuGet est nécessaire, utiliser un dossier de paquets local à l'essai et une configuration dédiée ; vérifier que la dépendance testée vient bien de ce dossier. Les dépendances officielles peuvent rester téléchargées en lecture seule depuis leurs sources habituelles.
5. Garder le remplacement éventuel du `.nupkg` et des métadonnées de versions dans le worktree d'essai. Ne pas remplacer un package dans un répertoire, cache, partage ou configuration utilisé par d'autres personnes.

**Preuve de confinement :** run exact, artefact récupérable, empreintes concordantes, dépendances effectivement chargées et tâches de push/promotion non exécutées. Un artefact de pipeline reste visible selon les droits du projet et consomme du stockage ; vérifier qu'aucun consommateur automatique collectif ne le récupère.

### 0.3. Docker : local d'abord, publication isolée seulement si nécessaire

Appliquer cet ordre de préférence :

1. Construire et tester l'image dans le même job ou sur un hôte d'essai dédié, sans push vers un registre.
2. Si l'image doit traverser des jobs ou machines, envisager une archive d'image en artefact de pipeline, avec empreinte et chargement explicite. Vérifier taille, espace disque, temps de transfert et compatibilité de l'hôte Windows ; ne pas imposer cette solution si son coût est disproportionné.
3. Si un registre est nécessaire, préparer une publication limitée à une identité d'image dédiée, puis faire valider la destination concrète et le périmètre avant le premier push. Cette exception concerne Docker uniquement ; elle ne réactive pas les publications NuGet, BuildInfo ou promotions.

Convention proposée pour une image publiée :

```text
<registre>/<espace-sandbox-valide>/rje-wi2222897-y2-jmeter:<socle>-b<buildId>-<commitCourt>
<registre>/<espace-sandbox-valide>/rje-wi2222897-sqlexpress:<versionSql>-b<buildId>-<commitCourt>
```

Ces références sont des gabarits : vérifier l'existence et les règles de l'espace sandbox avant usage. Préférer un dépôt/chemin séparé et un nom préfixé, **en plus** d'un tag unique. Un simple suffixe sur le tag d'une image collective est insuffisant si des outils surveillent tout son dépôt. Ne créer aucun dépôt distant et ne modifier aucune politique collective pour l'essai sans périmètre autorisé.

- Ne jamais écraser une référence existante, utiliser `latest`, un tag de release collectif ou un alias mutable partagé. Aucun retag ni promotion vers le circuit normal.
- Vérifier qu'aucun pipeline, scan avec action aval ou mécanisme de déploiement collectif ne sélectionne cet espace ou ce préfixe. Si cette isolation ne peut être établie, conserver l'image localement ou en artefact et documenter la limite.
- Épingler le consommateur d'essai sur le digest obtenu après push, vérifier le digest après récupération et contrôler le contenu/version des outils dans le conteneur. Enregistrer également le digest de l'image de base ; un tag unique ne remplace pas cette preuve.
- Si Full-Text nécessite une nouvelle base SQL, appliquer la même isolation à la base et à l'image JMeter dérivée. Modifier la référence de base seulement dans le Dockerfile ou les paramètres d'essai.
- Limiter les droits d'écriture au périmètre d'essai lorsque possible. Consigner référence, digest, propriétaire, run, consommateurs connus, taille et échéance de conservation dans `RESOURCES.md`.

### 0.4. Environnements, données et effets métier

- Restaurer les backups dans des bases d'essai distinctes avec noms, fichiers et chemins dédiés. Ne jamais restaurer sur une base des collègues ni changer ses données, droits, schéma ou paramètres. Les backups sources restent inchangés.
- Donner aux conteneurs, volumes, réseaux, ports, dossiers et tenants d'essai des identités propres au WI et au run ; vérifier les collisions et les montages effectifs avant démarrage. Aucun montage en écriture sur un répertoire collectif ; copier les fixtures dans l'espace dédié.
- Exécuter installations MSI, changements Full-Text/IIS, redémarrages et réglages système uniquement sur l'hôte ou le conteneur isolé. Ne pas reconfigurer la VM legacy partagée, ses workflows ou son scheduler pour obtenir une baseline. Si un rejeu n'est possible que sur cette VM, préciser les ressources touchées et convenir du créneau avec son responsable avant l'action.
- Vérifier les endpoints réellement résolus et les dépendances externes : files de messages, traitements planifiés, exports, webhooks et notifications. Utiliser des cibles et identités de test sans destinataires réels. Si une neutralisation change le contrat étudié, le noter comme limite de comparabilité ; ne pas annoncer une équivalence complète.
- Si une cible partagée inattendue est détectée, arrêter uniquement l'essai concerné et conserver la preuve. Ne pas tenter une réparation ou un rollback collectif automatique.

### 0.5. Conditions de lancement et de nettoyage

Ajouter à la fiche d'expérience : noms exacts des ressources, sources lues, destinations écrites, déclenchements possibles, budget de durée/disque/concurrence, modalités de récupération des preuves et nettoyage prévu. **Ne pas lancer tant qu'une destination d'écriture ou un consommateur aval potentiel reste indéterminé.** Préparer l'ensemble localement ; une demande d'autorisation éventuelle doit porter sur une action concrète et son périmètre exact, en tenant compte des autorisations déjà données.

Après le run, contrôler les tâches réellement exécutées et les ressources créées : pas de push NuGet, pas de promotion/tag collectif, référence Docker conforme si l'exception était autorisée, aucun déploiement aval inattendu. Ne pas déduire l'absence d'impact du seul succès du pipeline ; indiquer la portée des contrôles et tout UNKNOWN restant.

Nettoyer seulement les ressources de l'essai identifiées dans le registre, après conservation des preuves et selon le périmètre autorisé. Vérifier propriétaire et identifiant exact avant suppression ; pour une image publiée, vérifier qu'aucun consommateur ne la référence encore. Aucun `docker system prune`, nettoyage global de cache, suppression par wildcard ou purge de registre partagé. Préserver les images de base, volumes et artefacts des collègues. La validation d'une correction ouvre une étape distincte d'intégration au circuit collectif ; elle ne déclenche aucune promotion automatique de l'essai.

### 0.6. Écritures Azure DevOps par REST : verrouiller avant, vérifier après

Toute écriture sur une branche existante suit le même ordre, sans exception : relire le HEAD réel,
le comparer au HEAD attendu, puis l'utiliser comme `oldObjectId` du push. Pour créer une branche,
vérifier d'abord que la ref cible n'existe pas, puis utiliser
`oldObjectId = 0000000000000000000000000000000000000000` ; une seconde tentative doit détecter la ref
existante et s'arrêter sans écrire.

Après toute écriture : relire la ref, vérifier que son HEAD correspond exactement au commit produit,
relire les changements du commit et contrôler qu'il n'y a ni fichier manquant ni fichier inattendu.
Ne pousser que les fichiers réellement différents — comparer les SHA-256 distants et locaux avant le
push évite de modifier artificiellement un fichier déjà correct et rend la vérification post-push
triviale.

Trois pièges de client, tous rencontrés :

- PowerShell 5.1 déroule un tableau à un seul élément ; `$Body | ConvertTo-Json` produit alors un
  objet là où l'API attend un tableau (`Value cannot be null. Parameter name: refUpdates`). Utiliser
  `ConvertTo-Json -InputObject $RefUpdates`.
- une variable suivie immédiatement de `?` dans une URL est mal interpolée : écrire
  `".../builds/${BuildId}?api-version=7.1"`.
- l'API `/items` change de représentation selon `includeContent`, `download` et `resolveLfs`. Avec
  `download=true`, `Invoke-WebRequest` expose des octets : décoder explicitement
  `[Text.Encoding]::UTF8.GetString([byte[]]$Response.Content)` au lieu d'afficher `.Content`.

Ne jamais nommer une variable métier `$Matches` : c'est une variable automatique réécrite par
l'opérateur `-match`.

### 0.7. Collecter de façon ciblée, et savoir ce qu'une ligne de log prouve

Une collecte efficace part d'une source autoritative précise, dans cet ordre : build historique connu,
timeline, log du job concerné, puis blob Git au commit exact. Éviter les scans récursifs et les dumps
complets de timeline ou de logs : une question par probe, quelques dizaines de lignes, un fichier
temporaire. Cela distingue immédiatement fait prouvé, hypothèse et donnée historique.

Deux règles de lecture :

- **un stage vert ne prouve rien si les stages métier sont `skipped`.** Vérifier explicitement la
  timeline avant de qualifier un run. À l'inverse, un `partiallySucceeded` dont la timeline montre
  Build, déploiements et jobs JMeter exécutés est une meilleure baseline qu'un `failed` précoce.
- **quand les sorties sont redirigées, raisonner sur l'ordre d'exécution et les points de `throw`.**
  Si un script écrit `passed=true` après l'opération qu'on veut prouver, et que le build est
  `succeeded`, l'opération a terminé sans exception : c'est une `INFERENCE` valide, à condition
  d'avoir relu le script réellement exécuté. Relancer un pipeline pour « voir la ligne » est inutile.

Ne pas deviner les chemins runtime d'un outil de déploiement : les relever dans les logs d'un build
qui a réellement exécuté le job. Ne pas supposer non plus qu'un fichier présent dans un ancien
checkout existe encore dans l'arbre Git actuel — pour un fichier Git LFS, le SHA-256 de l'objet réel
se lit dans le pointeur (`oid sha256:<hash>`), et restaurer un pointeur vaut mieux que republier un
gros binaire si l'objet historique existe encore côté serveur.

## 1. Ouvrir une fiche par expérience

Partir du [handoff](../../investigations/ecarts-jmeter-migrations/HANDOFF.md), de la [matrice de statut](../../investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md) et de l'[index des preuves](../../investigations/ecarts-jmeter-migrations/evidence/README.md). Réutiliser la fiche de cause existante ; ne pas recommencer une collecte globale.

Avant tout rejeu, renseigner :

| Champ | Contenu obligatoire |
|---|---|
| Périmètre | plugin, branche, version produit, Cur ou Fix, service, plan et TestCase |
| Question | une hypothèse causale et l'observation qui permettrait de la réfuter |
| Références | builds/runs/commits exacts et chemins des preuves historiques |
| Expérience | état avant, unique facteur changé, résultat attendu si l'hypothèse est juste |
| Dépendances | cas préalables, ordre d'exécution, initialisation, nettoyage et services asynchrones |
| Attribution | dépôt propriétaire identifié ; interlocuteur à identifier si inconnu |
| Isolation | ressources dédiées, destinations d'écriture, triggers aval, budget et nettoyage selon la section 0 |
| Sortie | preuves attendues, verdict et critère de fermeture |

Séparer Cur et Fix. Compter les scénarios élémentaires legacy, sans additionner leurs conteneurs `orderedtest`. Dédoublonner les artefacts JMeter recopiés entre LegacyServices et WebServices. Distinguer première faute et conséquences en cascade.

**Passage à l'étape suivante :** question testable, cas minimal et preuve attendue identifiés. Sinon, préciser le manque au lieu de lancer une campagne entière.

## 2. Établir le contrat de comparaison

Pour toute conclusion legacy/JMeter, constituer deux manifestes et rapprocher :

| Dimension | Vérification |
|---|---|
| Scénario | source canonique, plan/TestCase, payload, prérequêtes, postrequêtes, assertions et attendus |
| Produit | versions exactes des plugins, Core, Common, Identity, Technical et autres dépendances utilisées |
| Données | même backup identifié par empreinte, mêmes fixtures et état initial contrôlé |
| Configuration | tenant, paramètres effectifs, endpoints, droits, locale, fuseau et horloge si le cas en dépend |
| Exécution | ordre, prérequis, parallélisme, délais, retries et attente des traitements asynchrones |
| Environnement | SQL/version/collation/Full-Text, IIS et runtimes ; différences VM/conteneur documentées |
| Outillage | versions et empreintes des runners, API/Console, sources et JMX générés, image réellement exécutée |

Les runners diffèrent par construction ; leurs effets sur le contrat doivent être explicités. Une différence matérielle non maîtrisée impose `UNKNOWN — comparabilité insuffisante`.

Pour V26, choisir une version plugin disponible et supportée par les deux chemins, puis la figer. Le Core commun observé ne suffit pas : FrenchTaxesRules utilise historiquement `26.0.10.25` en legacy contre `26.0.10.75` sous JMeter ; Clienteling `26.0.10.18` contre `26.0.10.23`.

Si aucun couple commun n'est exécutable, conserver cette limite. Une comparaison ancien/nouveau package dans un même runner peut isoler un effet de version, mais ne remplace pas une comparaison legacy/JMeter à version identique.

**Passage :** manifestes rapprochés ou écarts résiduels explicitement listés. Seules les comparaisons suffisamment maîtrisées pourront recevoir un verdict de migration.

## 3. Vérifier les prérequis avant les tests métier

Sur l'environnement d'essai prévu, vérifier :

1. moteur Docker disponible ; installation MSI réussie ; services worker/IIS opérationnels ;
2. pile supportée et compatible avec les minima MSI, notamment Clienteling V22/V23 Fix ;
3. jeton acquis et droit attendu effectivement projeté, notamment FrenchTaxesRules V22 Fix ;
4. Full-Text installé, catalogue attendu initialisé et fonction SQL requise présente ;
5. endpoints réellement installés et fixtures présentes au chemin visible par IIS ;
6. identité des packages et de l'image exécutés, par versions/empreintes constatées dans le conteneur.

Une chaîne YAML ou une étape de copie réussie ne prouve pas le contenu de l'image. Un health check rouge arrête le lot : classer le blocage comme infrastructure/déploiement et ne pas interpréter les tests métier non exécutés.

Appliquer les conditions d'isolation de la section 0 avant tout rejeu : NuGet uniquement en artefact du run, image Docker locale ou en artefact de préférence, publication Docker exceptionnelle sous une identité dédiée. La présente rédaction n'autorise aucune publication, modification distante ni relance.

## 4. Valider les corrections déjà justifiées

Le [plan de correction](../../investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) reste la référence unique pour les fichiers, transformations, tests et chaînes de packages. Ne pas recopier ni remplacer ce plan.

Ordre proposé :

| Lot | Travail et preuve de validation |
|---|---|
| A — génération | tester puis corriger séparément `CleanXpath`, `RemoveSpecialCharsForXQuery`, `EscapeJdbcDate`, `FixSqlUnicodeValue` ; chaque test doit échouer avant et passer après |
| B — propagation | construire API puis Console, transmettre les NuGet exclusivement par artefacts de runs identifiés, mettre à jour le consommateur dans le worktree d'essai, régénérer les JMX et vérifier les versions réellement consommées ; aucun push NuGet ni correction manuelle durable des JMX |
| C — environnement | traiter Full-Text dans `Pipelines_Docker_BaseImages`, valider les piles Fix et les droits avant les rejeux concernés |
| D — scénarios/configuration | corriger les métadonnées Clienteling dans la source canonique ; décider du support Products et identifier le transport des images avant de modifier ces points |

Les lots peuvent être préparés indépendamment ; leurs effets doivent rester attribuables. Ne pas mélanger une mise à jour produit, un changement de backup et une correction du générateur dans une seule expérience causale.

Rejeux minimaux prioritaires :

- dates FrenchTaxesRules : `Export_Run` TC08, puis TC09 et TC10 dans l'ordre après leurs prérequis ; `DocumentSignature_SignOne` TC02 ;
- génération Clienteling : un cas Fault par plan concerné, un cas de chacune des familles XML citées au plan, les cas dates ciblés et `ItemSearch:Keywords` TC02 ;
- infrastructure/configuration : smoke tests Full-Text, Deployment, Mobility, droits et images avant les familles complètes.

**Passage :** transformation ou prérequis corrigé démontré, JMX/artefact consommé identifié et première faute disparue. Si une autre faute apparaît ensuite, ouvrir ou compléter sa fiche ; ne pas déclarer le scénario réussi avant sa postcondition finale.

## 5. Trancher les écarts fonctionnels restants

Commencer par un représentant de chaque famille UNKNOWN en V26 Fix, où les preuves legacy sont les plus riches. Inclure les deux TC99 FrenchTaxesRules et les cas Clienteling `GetHeaderList` TC03 / `UpdateHeader` TC01. Traiter TC22 FrenchTaxesRules et CreateReceipt TC32 comme recherches de cause commune, sans présumer une cause JMeter.

Pour chaque expérience :

1. Restaurer deux états initiaux équivalents dans des bases d'essai dédiées depuis le backup figé, selon la section 0.4 ; contrôler les lignes et fixtures utiles au cas.
2. Exécuter legacy et JMeter avec le contrat de l'étape 2. Ne pas faire passer le second runner sur la base déjà modifiée par le premier sans restauration.
3. Respecter la séquence minimale de préparation du cas. Capturer prérequêtes, requête réellement émise, réponse, assertions, postrequêtes et état final pertinent.
4. Localiser la **première divergence** : préparation SQL, transport/payload, réponse produit, extraction/assertion ou postcondition.
5. Modifier un seul facteur suspect, puis refaire l'expérience depuis un état restauré. Conserver avant/après et, si faisable, un retour au comportement initial pour confirmer la causalité.
6. Si le résultat varie sans changement maîtrisé, classer la stabilité comme UNKNOWN et examiner ordre, concurrence, délais et traitements asynchrones avant tout changement d'attendu.

Ne pas modifier l'attendu pour obtenir du vert. Une évolution d'attendu exige une justification du contrat métier, distincte de la preuve d'exécution. Ne pas utiliser `ExpectedValue=-1`, `Code=99` ou un skip global pour masquer une erreur technique.

| Observation | Verdict permis |
|---|---|
| Contrat ou environnement insuffisamment rapproché | UNKNOWN — comparaison non concluante |
| Legacy passe, JMeter échoue, comparaison maîtrisée et reproductible | CANDIDAT ÉCART DE MIGRATION ; rechercher encore le mécanisme causal |
| Transformation fautive isolée et correction validée à contrat constant | FACT — défaut de migration démontré pour les cas couverts |
| Les deux échouent sur la même postcondition | FACT — échec commun observé ; cause produit/scénario/données à établir |
| Les deux passent | FACT — réussite sur le périmètre rejoué ; l'écart historique n'est expliqué que si le facteur causal a été isolé |
| Tests non exécutés, sortie vide ou soumission asynchrone seule | UNKNOWN sur le résultat fonctionnel ; documenter le blocage réel |

## 6. Étendre aux releases puis aux campagnes complètes

Pour chaque branche de release, obtenir une exécution legacy exploitable sur la version ciblée ou documenter l'impossibilité. Les captures arrêtées avant MSTest, les XML vides et les configurations seules ne constituent pas une baseline.

Ne reprendre la recherche des anciennes corrélations TestAutos que si une nouvelle source de preuve ou un accès exploitable est disponible. Les TRX master du 4 août sont indépendants des corrélations `162`, `66`, `226`, `227`, `228` ; ils ne les clôturent pas.

Si une baseline release reste indisponible, poursuivre la validation des corrections techniques prouvées et les tests de contrat accessibles, tout en laissant l'équivalence legacy/JMeter UNKNOWN. Une décision de support peut retirer un périmètre ; elle doit être explicite et ne vaut pas résultat de test.

Après succès des rejeux minimaux, étendre à tous les cas de la famille puis aux campagnes attendues, séparément par version et Cur/Fix. Vérifier les stages réellement exécutés, les volumes attendus, les skips et les postconditions. Un build vert avec stage sauté n'est pas une validation.

Descendre le contrôle au niveau du plan, pas du seul stage : comparer le total publié au total d'une exécution de référence identifiée, et grouper les tests manquants par préfixe de plan avant de les inspecter un par un. Une campagne entière peut disparaître sans rougir le pipeline, et l'égalité des échecs Cur/Fix sur un périmètre amputé ne vaut pas absence de régression. Le mode opératoire est dans [DEPANNAGE_JMETER.md](DEPANNAGE_JMETER.md), section 3.

## 7. Conserver les preuves et fermer chaque lot

Déposer les nouvelles preuves dans un nouveau dossier de l'investigation, par exemple `evidence/local-YYYY-MM-DD-<cas>/` ou `evidence/build-<id>/`, avec sous-dossiers legacy/JMeter/avant/après. Conserver : manifeste de comparabilité, commandes et paramètres sans secrets, résultats bruts TRX/JTL, logs utiles, réponses et observations SQL, versions/empreintes et limites de l'expérience.

Mettre à jour l'index des preuves, la fiche `findings/`, les matrices concernées, puis le handoff et `STATUS.md`. Tracer enfin la session dans `JOURNAL.md` et les ressources temporaires dans `RESOURCES.md` si nécessaire. Les preuves existantes et les snapshots `sources/` restent immuables.

Un lot est clos uniquement si :

- la cause est prouvée et son correctif validé jusqu'à la postcondition, avec portée explicite ; ou
- le comportement est justifié par une décision métier/support tracée ; ou
- l'investigation est explicitement bloquée, avec UNKNOWN, preuve manquante, responsable à solliciter et condition de reprise. Ce dernier état ne clôt pas la validation de migration.

**Première séquence de travail recommandée :** établir le confinement de la section 0 ; préparer les tests des quatre transformations et les manifestes V26 Fix ; valider les prérequis ; rejouer Export TC08–TC10 et un représentant par défaut Clienteling ; comparer les UNKNOWN résiduels à contrat constant ; étendre ensuite aux releases et aux campagnes complètes.
