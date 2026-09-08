# Collecte Clienteling — reprise Worker 3 — 2026-09-07

## Objet

Collecte isolée demandée par le brain-worker 3 pour le build Azure DevOps `4432602` (Clienteling releases/V6, V22/V23) : résoudre la version PlatformDeploy réellement consommée, suivre le traitement des retours MSI `1603`, et préparer une validation sans cible partagée.

FrenchTaxesRules releases/V5/V22 est hors périmètre.

## Provenance

- Date de collecte : 2026-09-07 (Europe/Paris).
- Source principale : snapshots locaux du workspace WI-2222897, notamment `sources/Y2_Plugins_Clienteling-v6-build-4432602/`, `evidence/build-4432602/`, et le worktree `worktrees/Y2_Tools_PlatformDeploy/`.
- Méthode : lecture seule PowerShell, `rg`, `Select-String`, `Get-FileHash`, inspection YAML/PowerShell; aucun fichier de preuve existant n'a été modifié.
- Build concerné : Azure DevOps build `4432602`, comme référencé par `findings/005-clienteling-v22-v23-build-4432602.md`.
- Fraîcheur : snapshots locaux datés du 2026-09-05/06; cette collecte est datée du 2026-09-07. L'état distant n'est pas revalidé.

## Résultats

### FACT — PlatformDeploy n'est pas fixé à une version exacte

Le YAML snapshot du build déclare le repository externe `Y2_Tools_PlatformDeploy` sans `ref` ni commit, et appelle `task-deploy-in-containerized-job.v2.yml@leoTemplates` avec `platformDeployVersion: lastV5` (lignes 88-90 et 311).

Le template local définit `lastV5` comme une recherche JFrog sur `Y2.Tools.PlatformDeploy/PlatformDeploy.5.*`, place le résultat dans `foundPlatformDeployVersion`, puis extrait l'archive correspondante. La version exacte est donc une sortie dynamique de la recherche JFrog, non une valeur déductible du YAML.

Les `downloadedPackages.json` conservés pour V22/V23 ne contiennent pas PlatformDeploy; aucun log conservé ne donne `foundPlatformDeployVersion`. **UNKNOWN** : numéro exact, BuildId/BuildNumber et commit du template PlatformDeploy consommés par 4432602.

### FACT — retours MSI 1603 observés

Les logs de déploiement Fix du build prouvent notamment :

- V22 : `E_IIS_SERVER_RETAIL_CLIENTELING` version `22.0.6.695`, `E_IIS_SERVER_RETAIL_TaxEngine` version `22.0.6.69`, `WORKER_PROCESS_RETAIL_LOYALTYENGINE` version `22.0.5.149` retournent `1603`.
- V23 : `E_IIS_SERVER_RETAIL_Technical` version `23.0.2.757` et `E_IIS_SERVER_RETAIL_TaxEngine` version `23.0.6.69` retournent `1603`.

Les logs associés sont sous `evidence/build-4432602/_extracted/v22-Fix_Deployment_logs-runnervmohg0i-Attempt#1/` et `v23-Fix_Deployment_logs-runnervmohg0i-Attempt#1/`. La fiche 005 documente les minima MSI et versions installées; aucune conclusion de support métier n'est ajoutée ici.

### FACT — mécanisme statique de propagation dans le checkout local

Dans `install-y2msi.ps1`, `Start-Process msiexec.exe` est attendu avec `-Wait -PassThru`; seuls les codes `0` et `3010` sont acceptés, tout autre code retourne `1`. `install-packages.ps1` additionne ces erreurs dans `$nbErr` et lève `Errors found during package installation` si `$nbErr -gt 0`.

**INFERENCE limitée** : si la version PlatformDeploy effectivement exécutée par 4432602 contenait exactement ces scripts, un `1603` devait faire échouer l'étape d'installation. La chronologie observée (`Launch Y2 deployment` réussie puis health check refusé) ne permet pas d'attribuer ce comportement à ce checkout local sans le ZIP/BuildId réellement consommé. **UNKNOWN** : raccord de la version exécutée, éventuelle capture/masquage de l'exception, et statut précis des tasks Azure.

## Disponibilité, compatibilité, support

- Disponibilité factuelle : les logs contiennent les MSI et codes `1603`; le snapshot YAML demande une résolution `lastV5`.
- Compatibilité technique : les tables de finding 005 montrent que plusieurs minima déclarés par les MSI Fix ne sont pas satisfaits par les versions Core/Common/Technical téléchargées.
- Support métier : **UNKNOWN**. Aucun support officiel de combinaison Fix V22/V23 n'est déduit de la seule présence des packages ou de leur installation.

## Validation isolée proposée

Avant toute queue, obtenir un artefact ou log de résolution contenant : `foundPlatformDeployVersion`, URL/nom exact `PlatformDeploy.<version>.zip`, BuildId/BuildNumber et commit des templates. Ensuite, sur une définition/branche dédiée sans trigger ni PR :

1. préflight lecture seule des packages et manifestes; vérifier les minima MSI avant installation;
2. installer un seul couple versionné sur une cible dédiée explicitement attestée;
3. capturer chaque exit code MSI et arrêter au premier `1603`;
4. ne lancer le health check qu'après preuve de tous les MSI requis en `0`/`3010`;
5. ne lancer qu'un cas Clienteling discriminant, puis seulement décider d'une campagne.

Cette proposition ne crée ni pipeline, ni branche, ni cible, ni publication.

## Limites

Une tentative de lecture Azure DevOps par API REST avec le PAT local autorisé a échoué avant lecture avec `Authentication failed`; la valeur du PAT n'a pas été affichée, journalisée ou persistée. Aucun changement d'authentification n'a été tenté.

## Round 2 — transport des fixtures Clienteling

**FACT** — le snapshot `Y2_Plugins_Clienteling-v6-build-4432602` contient le placeholder littéral `${tests.folder}\\${CustomImageFolder}` et zéro fichier image selon le test local; l'historique V6 contient exactement onze fichiers JPG sous `config_PLG/GetItemImage`.

**FACT** — le template `task-deploy-in-containerized-job.v2.yml` copie les bases et la configuration vers le répertoire de données Docker, mais le test local ne trouve aucune instruction `CustomImage` ou `ImageFolder` dans ce template. Le propriétaire de la copie/montage des onze fixtures n'est donc pas identifié.

**FACT discriminant** — `fixture-transport-check.ps1`, exécuté avec une fixture factice dans un répertoire temporaire nettoyé en `finally`, retourne `legacyFixtureCount=11`, `sourceSnapshotImageCount=0`, `pipelineCustomImageCopyCount=0`, `placeholderExistsAsPath=false` et `resolvedFixtureExists=true`.

**INFERENCE** — un chemin absolu résolu vers un dossier contenant la fixture est techniquement suffisant pour la résolution locale; cela ne prouve pas le chemin IIS réel ni un support métier. **UNKNOWN** — artefact de transport propriétaire, montage/container final et chemin visible par IIS.
