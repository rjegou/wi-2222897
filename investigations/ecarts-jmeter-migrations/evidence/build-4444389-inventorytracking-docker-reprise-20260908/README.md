# Build 4444389 — InventoryTracking Docker et point de reprise

**Collecte :** 2026-09-08, lecture REST Azure DevOps par Python `urllib` avec TLS/certificat
standard et PAT chargé depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`
uniquement en mémoire du processus. Le secret n'est pas conservé.

**Sources :** projet `Retail`, définition `2072` (`InventoryTracking CI`), dépôt
`Y2_Plugins_InventoryTracking`, build `4444389`, timeline et logs `77`, `102`, `103`, `129`,
`178`, `179`, définition et refs Git. Cette collecte est expurgée : elle ne recopie ni secret,
ni nom d'image/registry non nécessaire.

## Verdict

**FACT — état terminal.** Le build `4444389` est `completed / canceled`, queue
`2026-09-08T08:40:58.379Z`, début `08:41:09.297Z`, fin `09:02:22.263Z`. Il utilise la branche
`validation/WI-2222897-inventorytracking-isolated-20260908`, le commit
`13d0db910153952f1827f05f6532fa0f06741124`, le build number `7.77`, et le pool hébergé
`Azure Pipelines` (pool `79`, queue `591`).

**FACT — panne Docker dans Fix.** Le log `129`, job `TI Jmeter V26-Fix`, montre trois appels
`docker version` échouant sur le pipe Windows `npipe:////./pipe/docker_engine` avec « system cannot
find the file specified », puis `Exit code 1`. Les erreurs `ContainerId` nul et les publications de
logs absentes sont des conséquences (`102`, `103`), pas la cause initiale.

**FACT — Cur n'est pas tombé sur la même panne initiale.** Le log `178`, job `TI Jmeter V26-Cur`,
montre Docker API/client `1.55`, login réussi, pull réussi, création et démarrage du conteneur
réussis. Le job atteint ensuite l'annulation à `09:01:44.439Z`; les étapes de campagne et de
publication sont alors skipped. Le cleanup du conteneur et du réseau s'exécute à `09:01:46–48Z`.

**FACT — annulation distincte de la panne Docker.** La timeline montre le job Fix failed à
`08:51:05.980Z`, tandis que les messages d'annulation de Cur apparaissent à `09:01:44Z` et que
son job se termine à `09:01:48Z`. La cause de la décision d'annuler le run global n'est pas exposée
par ces sorties; elle ne doit donc pas être inventée comme « timeout » ou « annulation manuelle ».

**FACT — définition et code exacts.** La définition `2072`, révision `5`, lit
`/azure-pipelines.yml`, dépôt par défaut `master`, trigger CI activé, `maxConcurrentBuildsPerBranch=1`.
Le YAML du commit exécuté a le SHA-256
`5baf745c21ac495d554747be94f386c60015e014f122d7cef4c3742e1c9fa210`; il déclare un container de
job et les stages `Build`, `TI_Jmeter_V26-Fix`, `TI_Jmeter_V26-Cur`, puis `Promote`.

**FACT — refs et concurrence au snapshot.** La ref isolée pointe désormais vers
`efba57ea5a96d346170f4407e37050985244dcee`, commit parent du commit exécuté et message
`WI-2222897 InventoryTracking TC122 diagnostic and Docker preflight` (09:07:22Z). Aucun run
`inProgress` de la définition `2072` et aucune PR source pour cette ref n'ont été trouvés le
2026-09-08 lors de la collecte.

## Recommandation minimale

**INFERENCE opérationnelle :** ne pas relancer le même YAML inchangé. Le correctif minimal est de
séparer le diagnostic de disponibilité Docker du rejeu métier, puis d'exiger un agent/slot Windows
où `docker version` réussit avant de lancer les jobs containerisés. Conserver la ref et le commit de
diagnostic actuels comme base, mais figer explicitement le commit/YAML du prochain run; vérifier
avant queue que les jobs Cur **et** Fix obtiennent chacun un daemon Docker fonctionnel. Après ce
préflight, seulement alors exécuter Build puis Cur/Fix et contrôler package/image/ACR, compteur de
version, publication staging et ressources partagées.

**UNKNOWN conservés :** mécanisme exact ayant annulé Cur/global run; raison de l'absence du daemon
sur l'agent du job Fix; contenu de l'image effectivement consommée par le prochain run; résultat
fonctionnel de TC122; existence ou non d'une PR historique supprimée.

Voir `timeline-expurgated.md` et `MANIFEST.csv` pour les identifiants et extraits ciblés.
