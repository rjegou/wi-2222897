# Revue indépendante round 3 — FrenchTaxesRules V22

Date : 2026-09-07  
Worker : 2  
Périmètre : corrections locales de `replay-prep/2026-09-07-v22-isolated/`. Aucun lancement métier, pipeline, queue ou mutation distante.

## Verdict

**Préparation locale cohérente sous préconditions runtime ; rejeu toujours non autorisé.** Le round2 avait retiré la clé de l'appel PlatformDeploy, mais aurait laissé le CLI JFrog sans son dépôt de token : cela pouvait échouer systématiquement. Ce défaut est corrigé sans passer le secret en argument.

## Authentification PlatformDeploy — preuve et correction

Le code exact du worktree PlatformDeploy établit le mécanisme suivant :

- `Program.cs:104-124` expose `config jfrog <token>` et `clear <configItem>`.
- `JfrogArtifactoryCloudService.cs:49-65` appelle `IConfigurationService.GetJFrogToken()` et échoue si le token n'est pas configuré.
- `RetailTokenRepository.cs:50` fixe le fichier `%APPDATA%\Cegid.Retail\Retail-JfrogCli.json`; `:165-170` chiffre avec AES, et `ConfigurationService.cs:109-116` sauvegarde sous la clé `JFROG`.
- Le `docker-pipeline-deploy-ps7.ps1` épinglé déclare `RetailJfrogApiKey` mais ne l'utilise pas dans son corps; le script PS1 historique le retransmet, ce qui explique la contradiction du handoff.

La correction `scripts/Invoke-V22PlatformDeploy.ps1:11-67` :

1. lit uniquement `RETAIL_JFROG_API_KEY` depuis l'environnement masqué;
2. refuse toute révision où la clé apparaît autrement que dans sa déclaration obligatoire;
3. reproduit le format de stockage/chiffrement du CLI dans `Retail-JfrogCli.json`, sans afficher ni passer le secret en argument;
4. invoque la copie PS7 sans `-RetailJfrogApiKey`;
5. restaure ou supprime le fichier de configuration et efface la variable dans `finally`.

Le contrôle est donc fail-closed si le format du script évolue. La disponibilité réelle de l'API key/JFrog reste UNKNOWN tant qu'aucun run autorisé n'a pas exécuté le téléchargement.

## Comparaison par scénario, signature et provenance

`Assert-V22AuthorizationComparison.ps1:29-58` utilise le label `lb`/`label`/`sampler_label` du JTL ou XML comme identité de scénario, puis la catégorie de signature (`CBP50101`/`ID4266`/`ClaimsPrincipalPermission` pour Legacy ; `FailedAuthentication`/`Access is denied` pour Web). Le fichier est seulement un fallback si aucun label n'existe.

- `:77-80` refuse une baseline qui ne reproduit pas 138 Legacy + 36 Web = 174 signatures ciblées.
- `:83-94` vérifie l'image digestée, plugin, AuthenticationServer, backup et versions Core/Common/Identity de la baseline; le candidat refuse tout scénario/signature historique encore présent.
- Les échecs non liés restent comptables mais ne sont pas transformés en succès; les tests non exécutés ou dossiers absents font échouer le contrôle.
- `steps-replay-variant.yml:86-101` transporte uniquement le résumé JSON expurgé via l'output du job historique et refuse son absence côté candidat.

La provenance inter-jobs est donc contrôlée pour les entrées partagées et les versions historiques attendues. Elle ne constitue pas une preuve d'identité du container ni de l'assembly IIS effectivement chargée.

## Recherche du marqueur de nommage interdit

- **FACT** — recherche insensible à la casse du marqueur interdit dans le candidat replay-prep corrigé : 0 occurrence.
- **FACT** — aucun dossier local sous `worktrees/` ne porte le marqueur interdit dans son nom.
- **FACT** — des preuves historiques partagées contiennent encore ce marqueur et l'ancien nom de branche, notamment `evidence/azure-devops-french-taxes-rules-v22-worker1-round7/`, `round10/`, `round11/` et l'audit `2026-09-07-brain-reprise-worker1-round12/`. Elles sont des traces de provenance et n'ont pas été supprimées ou réécrites.

Aucun nouveau nom de pipeline, branche, commit, PR ou entité partagée n'a été créé par ce worker.

## Vérifications locales

- `Test-V22ReplayFailureModes.ps1` : **PASS** sous PowerShell 7 et Windows PowerShell 5.1; fixture inerte : 232+144, baseline 138+36 par scénario, candidat zéro signature ciblée avec erreurs non liées conservées.
- `Invoke-V22RunnerDryRun.ps1` : **PASS**; préflight 32 JMX, backup hashé, digest ACR complet, orchestration, auth JFrog temporaire, campagne et nettoyage vérifiés sans écriture métier.
- Analyse syntaxique PowerShell : **PASS** sur tous les scripts.
- `MANIFEST.sha256` : **PASS** après mise à jour.

## UNKNOWN / limites

- Aucun pull ACR, téléchargement JFrog, restauration SQL, déploiement IIS ou JMeter métier n'a été exécuté.
- L'isolation réelle du container, mounts, réseau, cibles partagées et compatibilité agent restent UNKNOWN.
- La vérification des ZIP et `downloadedPackages.json` établit les packages téléchargés/consommés par PlatformDeploy, pas l'assembly réellement chargée par IIS. Une preuve runtime devrait relever les versions/hash des assemblies après installation, sans exposer de secret.
