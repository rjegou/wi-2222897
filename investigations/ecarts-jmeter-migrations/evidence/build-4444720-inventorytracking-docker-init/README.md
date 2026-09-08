# InventoryTracking — build 4444720 — pull Docker progressif, annulation avant création du conteneur

## Provenance

- Date : 2026-09-08 (Europe/Paris).
- Source : Azure DevOps `cegid/Retail`, définition `2072` (`InventoryTracking CI`).
- Dépôt : `Y2_Plugins_InventoryTracking`, ID `90f886fd-8a68-483f-b798-126928e6297f`.
- Méthode : API REST et Azure DevOps CLI en lecture/queue contrôlée; aucun secret, log brut ou contenu sensible collecté.
- Branche : `refs/heads/validation/WI-2222897-inventorytracking-isolated-20260908`.
- Commit exécuté : `efba57ea5a96d346170f4407e37050985244dcee`.
- YAML `/azure-pipelines.yml` au commit exécuté : SHA-256 `6F23D0724F57A69E5DE25E1220A52DA33469A5D3D7F7D46EAFBB0D616D9118E0`, 15 948 octets.
- Fraîcheur : relecture live du build et de la timeline le 2026-09-08.

## Run

**FACT** — le run `4444720` (`7.82`) a été queue avec `pipelineDevMode=true`, `versionsToTest=[26]`, `typesToTest=[Cur,Fix]` et `campaignsToTest=[WebServices]`. Le run a exécuté le commit ci-dessus et s'est terminé `completed/canceled` à `2026-09-08T09:47:20.5375799Z`.

**FACT** — `Build` a réussi; le stage séparé `Docker preflight for isolated JMeter` et le job `Verify Docker daemon before JMeter` ont réussi. `Ensure Docker image` est resté skipped; aucun Publish staging, Promote ou Tag n'a été exécuté.

**FACT** — les jobs `TI Jmeter V26-Cur` et `TI Jmeter V26-Fix` ont exécuté leur initialisation sur `Azure Pipelines 29` et `Azure Pipelines 44`, respectivement. Les logs complets des tâches `Initialize containers` (Cur : log 185 ; Fix : log 159) montrent une API Docker joignable en version 1.55, un login ACR réussi et le lancement du pull de l'image `sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`.

**FACT** — 31 couches étaient annoncées par le pull. Huit messages `Pull complete` sont observables dans chaque log avant annulation : la première couche est complète vers `09:42:00Z`/`09:42:05Z`, la dernière observée vers `09:46:00Z`/`09:46:05Z`. Aucun `Final exit code for Docker pull`, `Status: Downloaded`, `docker create`, `docker start` ou démarrage de conteneur n'est présent avant l'annulation.

**FACT** — l'opération a été annulée vers `09:46:26Z` (Fix) et `09:46:38Z` (Cur), soit environ 7 min 30 s à 7 min 50 s après le début du pull. Le nettoyage de fin a tenté de supprimer le réseau et a signalé qu'il n'existait pas. Aucun résultat JMeter ni conteneur de campagne exploitable n'est donc prouvé.

## Verdict borné

**FACT** — dans ce run, contrairement au Fix de `4444389` (log 129), l'absence du daemon Docker n'est pas démontrée : les commandes `docker version`, le login et le pull ont progressé sur les deux jobs.

**INFERENCE** — `4444720` montre un pull lent ou non terminé dans la fenêtre observée, puis une annulation, et non un blocage démontré du daemon. Les réussites `4440884` et l'initialisation Cur de `4444389` montrent que la même famille d'image peut finir son pull, créer/démarrer le conteneur et atteindre le démarrage applicatif après environ dix minutes de pull. Un rejeu doit laisser cette progression atteindre son terminal avant d'inférer un défaut.

**UNKNOWN** — le run aurait-il terminé le pull avec plus de temps, et quelle part relève du cache, du débit réseau ou de la capacité de l'agent. La création du conteneur, les campagnes Cur/Fix, les résultats et les artefacts métier restent non prouvés.

## Effets et limites

Aucune publication NuGet/JFrog/Artifactory, promotion, tag, trigger aval, modification d'agent/service ou nettoyage partagé n'a été réalisé. Les runs exploratoires `4444700` et `4444703` ont été annulés avant JMeter car le paramètre effectif `pipelineDevMode` était `False`; ils ne constituent pas des runs métier.
