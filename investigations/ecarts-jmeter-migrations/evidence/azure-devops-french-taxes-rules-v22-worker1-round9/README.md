# Résolution du registry ACR — diagnostic 4441719 — Worker 1 round 9

Date : 2026-09-07. Lecture seule ; aucune queue, définition, branche, permission ou service connection modifiée.

## Faits directs

1. YAML historique `investigations/ecarts-jmeter-migrations/sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167/azure-pipelines.yml:27-38` sépare : `jfrogImage.Name=y2-jmeter`, `jfrogImage.Tag=...ltsc2022`, `acrImage.AcrName=AcrRetailDocker`, `acrImage.Repository=cegid-retail-docker-production`, `acrImage.Name=y2-jmeter`, même tag.
2. Son `resources.containers` (`:94-97`) utilise l’image logique non qualifiée `$(acrImage.Repository)/$(acrImage.Name):$(acrImage.Tag)` avec `endpoint: AzureContainerRegistry-Docker-Retail`. Dans ce contexte Azure Pipelines, l’endpoint est associé à la ressource container ; ce n’est pas la même opération que le `docker pull` manuel du préflight.
3. Build `4429167`, log `15` : `acrRepositoryName=***-retail-docker-production/y2-jmeter`, `acrImageDigest=sha256:268476...`, puis URL JFrog `.../all-docker/y2-jmeter/.../manifest.json`. Le log montre une commande Azure ACR logique et une vérification JFrog séparée, pas un `docker pull` avec hostname.
4. Service connection `AzureContainerRegistry-Docker-Retail` : métadonnée non sensible `type=dockerregistry`, resource ID `.../registries/AcrRetailDocker`, `url=https://management.azure.com/`. Le champ `loginServer` n’est pas exposé dans cette métadonnée ; aucun champ d’autorisation n’a été lu ou affiché.
5. Run `4441719`, log `6` : tâche `Docker@2` login réussie, sans hostname imprimé. Log `7` : `docker pull` reçoit exactement `cegid-retail-docker-production/y2-jmeter:...@sha256:268476...` sans hostname et échoue avec `pull access denied ... repository does not exist or may require 'docker login'`.
6. Manifest JFrog Docker API round8 : HTTP 200, media type Docker v2, `Docker-Content-Digest=sha256:268476...` pour `cegid.jfrog.io/artifactory/api/docker/all-docker/v2/y2-jmeter/manifests/<tag>`. Cela prouve le manifest JFrog, pas sa présence sous un chemin ACR donné.

## Comparaison et conclusion

Le chemin logique repository/tag/digest concorde caractère par caractère entre le YAML historique, le log ACR 4429167 et la chaîne YAML du préflight. Le chemin JFrog est différent par conception (`all-docker/y2-jmeter`) mais porte le même digest. Le défaut démontré est que le script hôte a utilisé un pull Docker non qualifié après un login d’endpoint ACR ; le message Docker ne suffit donc pas à conclure à un droit ACR manquant.

Le hostname complet ACR ne peut pas être déclaré **FACT** : `AcrRetailDocker.azurecr.io` est seulement le hostname conventionnel déduit du nom de ressource, non retourné par les métadonnées disponibles. La résolution DNS locale de ce nom échoue également. Le patch local round8 qui ajoute ce hostname reste une proposition reviewable, pas une correction prouvée.

## Décision d’action

- Aucun changement distant n’a été effectué sur la définition `14246`, la branche dédiée ou le service connection.
- Aucun nouveau préflight n’a été lancé : l’adresse complète n’est pas prouvée et le lot exigeait de ne lancer qu’après résolution.
- Intervention humaine minimale : fournir une lecture ARM non sensible du champ `loginServer` de la ressource `AcrRetailDocker`, ou confirmer explicitement le loginServer utilisé par `AzureContainerRegistry-Docker-Retail`. Ensuite seulement, remplacer la référence locale par `<loginServer>/cegid-retail-docker-production/y2-jmeter:<tag>@sha256:268476...`, vérifier le manifest ACR exact, puis décider d’un unique nouveau préflight.

## Pourquoi deux runs précédents

Le premier run `4441699` a été lancé après preview et a découvert un défaut de script (`No such image` traité comme erreur avant le pull). Le second `4441719` a corrigé ce défaut et a atteint l’étape d’acquisition ; il a donc fourni le diagnostic de référence non qualifiée. Aucun troisième run n’a été lancé dans ce round.
