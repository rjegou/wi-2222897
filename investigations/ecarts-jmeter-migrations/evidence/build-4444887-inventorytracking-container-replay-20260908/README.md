# InventoryTracking — build 4444887 — conteneurs initialisés, package staging absent

## Provenance

- Date de collecte : 2026-09-08 (Europe/Paris).
- Source : Azure DevOps `cegid/Retail`, définition `2072` (`InventoryTracking CI`), lecture REST/CLI.
- Branche : `refs/heads/validation/WI-2222897-inventorytracking-isolated-20260908`.
- Commit : `efba57ea5a96d346170f4407e37050985244dcee`.
- Run : `4444887` (`7.83`).
- Paramètres effectifs : `pipelineDevMode=true`, `versionsToTest=['26']`, `typesToTest=['Cur','Fix']`, `campaignsToTest=['WebServices']`.
- Méthode : queue unique puis relecture build/timeline/logs avec Azure DevOps CLI ; le PAT est resté dans l'environnement du processus et n'est pas reproduit.
- Fraîcheur : lecture live du terminal et des logs le 2026-09-08.

## Déroulement et garde-fous

**FACT** — le build `4444887` a démarré à `10:03:10Z`, le stage `Build` a réussi (`10:03:12Z`–`10:10:14Z`) et le job `Build V26` a réussi sur `vm-alm-agent-05-A` (`10:05:11Z`–`10:10:09Z`).

**FACT** — le preflight Docker a réussi (`10:10:30Z`–`10:11:11Z`). `Ensure ACR`, `Publish to ArtifactoryCloud staging`, `Promote` et `Tag_Sources` ont été skipped par les conditions de la branche isolée. Aucun trigger aval n'a été observé.

**FACT** — les deux jobs ont initialisé leur conteneur : Cur de `10:10:38Z` à `10:19:45Z` (9 min 06 s), Fix de `10:10:41Z` à `10:21:54Z` (11 min 13 s). Les tâches `Initialize containers` sont `completed/succeeded`; cette exécution ne reproduit donc pas un daemon absent ni une annulation pendant le pull.

## Échec causal avant JMeter

**FACT** — Cur a échoué dans `Launch Y2 deployment` (`10:21:15Z`–`10:21:48Z`, log 104). PlatformDeploy `5.0.86` a trouvé et téléchargé les dépendances de production, puis n'a trouvé aucun artefact `Y2.Plugin.InventoryTracking` version `26.0.7.83` dans `retail-software-staging`; le processus s'est terminé avec le code 1. Les tâches Prepare/Run JMeter, conversion JTL et extraction d'erreurs Cur ont été skipped.

**FACT** — Fix a échoué dans `Launch Y2 deployment` (`10:23:37Z`–`10:24:21Z`, log 153) pour la même absence de `Y2.Plugin.InventoryTracking.26.0.7.83` dans `retail-software-staging`. Les tâches Prepare/Run JMeter, conversion JTL et extraction d'erreurs Fix ont été skipped.

**FACT** — le run est terminal `completed/failed` à `2026-09-08T10:25:05.178403Z`; Cur, Fix et le stage `TI JMeter V26` sont `failed`. Staging Artifactory, promotion et tag sont `skipped`.

## Verdict borné

**INFERENCE** — la stratégie `container:` est viable pour ce candidat : les deux conteneurs ont été initialisés, avec des durées de pull de l'ordre de 9 à 11 minutes. Le défaut causal de ce run est le transport attendu du package plugin vers le staging JFrog, pas Docker.

**UNKNOWN** — une campagne JMeter Cur/Fix réellement exécutée et ses résultats TC122 ; image et digest consommés par les jobs ; JMX, données, requêtes/réponses et assertions métier ; méthode autorisée pour rendre le package disponible sans publication partagée.

**DÉCISION** — ne pas relancer ce YAML inchangé. Une suite doit résoudre et faire revoir le contrat package/staging (ou fournir un transport strictement isolé compatible avec PlatformDeploy), tout en conservant les garde-fous de publication/promotion/tag. Aucun changement de service, agent partagé, feed ou image n'a été effectué.

## Ressources

Aucune ressource distante créée hors du run Azure DevOps. Le répertoire local `.azcli-round4-temp` utilisé pour l'authentification CLI a été supprimé après la collecte ; les logs AzDO restent la source externe immuable référencée par les IDs ci-dessus.
