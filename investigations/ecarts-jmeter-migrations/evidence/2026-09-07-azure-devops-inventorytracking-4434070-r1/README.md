# InventoryTracking master — build 4434070 — collecte r1

## Provenance

- Date de collecte : 2026-09-07 (Europe/Paris).
- Système source ciblé : Azure DevOps `https://dev.azure.com/cegid`, projet `Retail`.
- Identifiant ciblé : build `4434070`, pipeline/repository attendu `Y2_Plugins_InventoryTracking/master` selon le snapshot local.
- Méthodes : appel REST direct .NET avec le PAT lu en mémoire depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`; tentative Azure CLI avec `AZURE_DEVOPS_EXT_PAT` et `AZURE_CONFIG_DIR` temporaire dans le workspace.
- Portée : lecture seule; aucun lancement, annulation, publication, push, PR, commentaire ou modification Azure DevOps.
- Fraîcheur : tentative effectuée le 2026-09-07; aucune réponse HTTP Azure DevOps n’a été obtenue.

## Résultats directs

### FACT — l’authentification n’a pas atteint Azure DevOps

L’appel REST vers `/_apis/build/builds/4434070?api-version=7.1` échoue localement pendant la négociation TLS, avant tout statut HTTP. La chaîne d’exception non sensible est :

`System.Security.Authentication.AuthenticationException: Authentication failed, see inner exception.`

`System.ComponentModel.Win32Exception: Aucune information d’identification n’est disponible dans le package de sécurité`

La même famille d’erreur Schannel a été observée avec le client PowerShell et avec `HttpWebRequest`, en TLS 1.2. Aucun contenu de réponse Azure DevOps n’est donc disponible dans cette collecte.

### FACT — Azure CLI n’a pas fourni de repli exploitable

La commande de lecture du projet `Retail`, exécutée avec `AZURE_DEVOPS_EXT_PAT` dans un processus borné et un profil temporaire, n’a produit aucune réponse exploitable avant expiration/arrêt du processus. Le profil global initial est par ailleurs inaccessible (`Permission denied` sur `C:\Users\jegour\.azure\azureProfile.json`). Aucun jeton n’a été affiché, journalisé ou persisté par cette collecte; la variable d’environnement a été supprimée dans `finally`.

### FACT — seule la preuve locale précédente reste disponible

`investigations/ecarts-jmeter-migrations/evidence/azure-devops-inventorytracking-4434070-blocked/README.md` rapporte le build `4434070` comme échoué, sur la base du snapshot local `documentation/tracking/2026-09-07-bilan-intermediaire-semaine-precedente.md:26`. Cette information n’est pas une lecture live du build.

## Verdict

- **FACT** : la collecte live r1 n’a obtenu ni métadonnées, ni timeline, ni logs, ni artefacts.
- **UNKNOWN** : dépôt/branche/commit exacts, définition et paramètres, stages exécutés ou sautés, premier task causal, tests démarrés, image/ACR et build master plus récent.
- **UNKNOWN** : cause racine du fail. Le statut local « Build en échec » ne permet pas de distinguer compilation, orchestration, infrastructure, image ou test métier.
- **INFERENCE** : le blocage observé dans cette collecte est local à la négociation TLS/profil CLI; il ne constitue pas une cause du build 4434070.

## Omission et reprise

Aucun log distant n’a été copié, afin de ne pas enregistrer d’éventuels secrets sans possibilité de filtrage fiable. Pour avancer, obtenir une exportation ou une session Azure DevOps autorisée contenant build, timeline, premier log causal et YAML/templates résolus, puis répéter ces éléments sur le build `master` le plus récent.
