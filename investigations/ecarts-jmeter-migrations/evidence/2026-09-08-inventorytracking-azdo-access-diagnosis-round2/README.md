# Vérification AzDO InventoryTracking — voie Python/OpenSSL réussie

## Provenance

- Date : 2026-09-08 (Europe/Paris).
- Source : Azure DevOps `https://dev.azure.com/cegid/Retail`, projet `Retail`.
- Pipeline : définition `2072`, `InventoryTracking CI`.
- Dépôt : `Y2_Plugins_InventoryTracking`, ID `90f886fd-8a68-483f-b798-126928e6297f`.
- Méthode : API REST en lecture seule avec Python `requests`/OpenSSL; PAT lu en mémoire depuis le chemin opérationnel, jamais affiché ni persisté, puis supprimé de l'environnement.
- Fraîcheur : réponses obtenues le 2026-09-08; les builds datent du 2026-09-07.
- Artefacts ciblés téléchargés hors dépôt : `C:\Users\jegour\AppData\Local\Temp\WI-2222897-InventoryTracking-4440884`. Les quatre ZIP et leurs SHA-256 sont décrits dans `artifact-downloads.txt`.

## Authentification et réseau

**FACT** — DNS et TCP/443 vers `dev.azure.com` fonctionnent.

**FACT** — `az devops login` et `Invoke-RestMethod`/curl PowerShell échouent avant une lecture exploitable avec Schannel : `SEC_E_NO_CREDENTIALS (0x8009030E)`, « Aucune information d’identification n’est disponible dans le package de sécurité ».

**FACT** — Python/OpenSSL atteint AzDO sans secret (HTTP 203), puis avec le PAT en mémoire (HTTP 200 JSON). Le PAT n’est donc pas démontré expiré ou invalide; le blocage initial est le transport Schannel/outillage, tandis que le mécanisme CLI a aussi rejeté le jeton dans ce contexte.

## Builds et stages

**FACT** — build `4440774` / `7.75` est `completed/succeeded`, définition `2072`, branche `refs/heads/validation/WI-2222897-inventorytracking-xmldiff`, commit `ef3d87034d38b88aca04c824061b140e2a29252c`. Le stage `Build` est `succeeded`; `TI JMeter V26`, `TI Jmeter V26-Cur`, `TI Jmeter V26-Fix`, `Promote` et publication Artifactory sont `skipped`.

**FACT** — build `4440884` / `7.76` est `completed/partiallySucceeded`, avec la même branche et le même commit. Le stage `Build` est `succeeded`; les phases `TI Jmeter V26-Cur` et `TI Jmeter V26-Fix` sont `succeededWithIssues`. Les tâches de préparation, lancement JMeter, conversion JTL→JUnit, regroupement et extraction d’erreurs sont `completed/succeeded`. `Promote` est `skipped`; la publication Artifactory staging est `succeeded`.

**FACT** — l’index d’artefacts confirme pour `4440884` les artefacts NuGet/Software/HtmlDocs et les artefacts séparés de déploiement, `WebServices_TestLogs` et `RunLogs` Cur/Fix. `4440774` contient seulement NuGet/Software/HtmlDocs.

## Résultats individuels Cur/Fix

**FACT** — les test runs `6185924` (`...v26-Fix`) et `6185925` (`...v26-Cur`) sont `Completed`, chacun avec exactement `1991` résultats. Cur : `1652` passed et `339` failed. Fix : `1651` passed et `340` failed.

La requête de liste `test/runs?buildIds=...` a renvoyé un inventaire global de 42209 runs dans les deux réponses; l’association au build est donc établie par les endpoints détaillés des runs `6185924` et `6185925`, dont `buildConfiguration.id=4440884`, `buildDefinitionId=2072` et la branche/commit correspondants.

**FACT** — jointure exacte par `(testCaseTitle, automatedTestName, testCaseReferenceId)` : 1991 clés communes, aucune clé propre à une variante. Répartition des outcomes : `1651 Pass/Pass`, `339 Fail/Fail`, `1 Fail/Pass` et `0 Pass/Fail`.

**FACT** — l’unique delta d’outcome est `002-Device:Reassign - TC 122`, référence `1127761` : Fix résultat `100084` / run `6185924` = `Failed`, erreur `B-XQuery:Internal Server Error ;| C-PostQuery1:OK ;| C-PostQuery2:OK`; Cur résultat `100084` / run `6185925` = `Passed`.

**FACT** — une comparaison brute des champs `errorMessage` donne 198 différences textuelles, mais les 197 autres restent `Failed/Failed` et les chemins contiennent le nom de variante Cur/Fix. Elles ne constituent pas 198 deltas de verdict.

## Branche, PR et effets

**FACT** — la relecture du ref exact `refs/heads/validation/WI-2222897-inventorytracking-xmldiff` renvoie zéro ref au moment de la collecte; la recherche de PR dont la source est cette branche renvoie zéro résultat. Cela ne contredit pas que les builds historiques portent cette sourceBranch; cela indique seulement que la ref/PR n’est plus retrouvée maintenant.

**FACT** — `4440884` a réellement exécuté Build + JMeter Cur/Fix et a réussi la publication Artifactory staging selon la timeline; ces effets sont historiques et n’ont pas été reproduits dans cette collecte.

**UNKNOWN** — contenu exact des fichiers bruts dans les artefacts, mapping complet JTL→JUnit au-delà des résultats publiés, cause applicative du HTTP 500 TC122, et raison de la disparition actuelle de la ref distante.

## Limites et prochaine action

Aucun pipeline, branche, PR, artefact ou ressource distante n’a été créé, modifié, relancé, téléchargé ou publié dans ce lot. Aucun document canonique partagé n’a été modifié et aucun commit n’a été tenté.

La prochaine expérience discriminante est une lecture ciblée des artefacts Cur/Fix déjà publiés pour relier TC122 au sample JMeter et à sa réponse HTTP; ne pas relancer avant cette analyse.

Les détails ciblés TC122 sont dans `TC122-artifact-analysis.txt`; la classification des échecs communs est dans `common-failure-signatures.txt`.
