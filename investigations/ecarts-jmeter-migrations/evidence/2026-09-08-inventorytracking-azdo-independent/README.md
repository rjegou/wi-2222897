# Vérification indépendante AzDO InventoryTracking — accès bloqué

## Provenance

- Date de collecte : 2026-09-08 (Europe/Paris).
- Système source visé : Azure DevOps `https://dev.azure.com/cegid/Retail`.
- Pipeline visé : définition `2072` (`InventoryTracking CI`).
- Objets visés : builds `4440774` et `4440884`, commit `ef3d87034d38b88aca04c824061b140e2a29252c`, branche `validation/WI-2222897-inventorytracking-xmldiff`, timelines, logs, tests, artefacts et PR.
- Méthodes tentées : `az pipelines build show`, `az pipelines show`, API REST Build/Git/Pull Request/Timeline/Artifacts avec `Invoke-RestMethod`, sans afficher ni persister le secret.
- Fraîcheur : collecte du 2026-09-08, mais aucune réponse AzDO authentifiée obtenue.

## Résultat

**FACT** — le dépôt documentaire était sur `main` avec `origin/main [gone]`; aucun fichier suivi n'était modifié avant la collecte.

**FACT** — le profil Azure CLI global n'était pas accessible en écriture (`PermissionError` sur `C:\Users\jegour\.azure\azureProfile.json`). Un profil temporaire local a été utilisé.

**FACT** — `az devops login` avec le PAT présent dans le chemin opérationnel documenté a répondu `Failed to authenticate using the supplied token`. La tentative REST avec le même secret a répondu `Authentication failed`.

**FACT** — la navigation vers AzDO via le navigateur connecté a été refusée par la politique d'accès de la session.

**UNKNOWN** — existence, statut, résultat, branche, commit exécuté, paramètres, stages réellement exécutés, logs, tests, artefacts, refs distantes et PR pour `4440774`/`4440884`.

**UNKNOWN** — les chiffres rapportés `1991`, `339`, `340`, les test runs `6185924`/`6185925` et l'unicité du delta `TC 122`.

## Limites et absence d'effet

Aucun pipeline n'a été lancé, aucune branche/PR n'a été créée ou modifiée, et aucun artefact n'a été publié ou téléchargé. Les fichiers JSON vides présents dans ce dossier correspondent aux commandes CLI interrompues avant l'appel réseau; ils ne constituent pas une preuve AzDO.

La branche et le commit mentionnés dans les handoffs locaux restent des **faits rapportés non confirmés**. Les documents canoniques n'ont pas été modifiés.

## Prochaine expérience discriminante

Répéter la même collecte depuis une session AzDO authentifiée et autorisée en lecture, puis enregistrer séparément pour chaque build : `build`, `timeline`, logs des records Build/JMeter Cur/Fix, résultats individuels des test runs, artefacts, ref de branche et PR. Comparer les couples de testcases par identifiant/nom et conserver les divergences complètes, pas seulement les totaux.
