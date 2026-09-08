# Corrections locales vérifiées — FrenchTaxesRules V22

Date : 2026-09-07  
Worker : 2, round 2  
Périmètre : `replay-prep/2026-09-07-v22-isolated/`. Aucun pipeline, queue ou système distant n'a été lancé ou modifié.

## Corrections appliquées

1. **Image complète.** `azure-pipelines.candidate.yml` référence désormais `acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:<tag>@sha256:268476...4da9cb` dans la variable et la ressource container. Le tag, repository, digest et loginServer sont ceux fournis et acceptés pour cette mission.
2. **Contrôles avant écriture.** `steps-replay-variant.yml` exécute `Assert-V22LocalContainerRuntime.ps1` dans chacun des jobs `FixHistorical` et `FixCandidate` avant téléchargement/restauration. Ce contrôle reste une readiness locale ; il ne simule pas une attestation d'isolation manquante.
3. **Secret sans argument.** Le constat précédent venait de la ligne historique qui appelait directement `docker-pipeline-deploy-ps7.ps1 -RetailJfrogApiKey $key`. L'interface épinglée déclare bien ce paramètre obligatoire, mais le corps PS7 inspecté ne le réutilise pas ; l'ancienne version PS1, elle, le retransmet à un processus enfant. `Invoke-V22PlatformDeploy.ps1` vérifie cette forme exacte, crée seulement une copie temporaire avec déclaration optionnelle et invoque le PS7 sans argument de clé. Si une future révision consomme la clé ailleurs, le contrôle échoue avant invocation. Aucun secret n'a été affiché.
4. **Packages effectivement téléchargés.** `Assert-V22ConsumedPackages.ps1` vérifie, après le déploiement PlatformDeploy et avant les campagnes, les trois ZIP de la variante contre `PACKAGE-SHA256SUMS.txt`, puis vérifie les trois versions dans l'unique `downloadedPackages.json`. Cela prouve les entrées téléchargées par PlatformDeploy ; cela ne prétend pas prouver l'assembly finalement chargé par IIS.
5. **174 refus par scénario/signature.** `Assert-V22AuthorizationComparison.ps1` exige pour `FixHistorical` 138 signatures Legacy et 36 Web, sérialise seulement ce résumé expurgé comme output de job, puis exige pour `FixCandidate` l'absence de chacune des signatures par scénario. Les autres erreurs ne sont pas transformées en échec global.

## Vérifications locales

- `Test-V22ReplayFailureModes.ps1` : **PASS**. Il vérifie désormais aussi une fixture inerte `138 + 36` pour la baseline, `0` signature correspondante côté candidat et la conservation d'erreurs applicatives non liées.
- `Invoke-V22RunnerDryRun.ps1` : **PASS** — préflight `32 JMX`, `232 + 144 = 376`, ordre baseline → trois opérations → campagnes, nouvelle orchestration de déploiement, contrôle packages et comparaison présents ; aucun SQL/IIS, JMeter, publication, queue ou mutation.
- Analyse syntaxique PowerShell : **PASS** sur tous les scripts du replay-prep.
- `MANIFEST.sha256` : **PASS**, recalcul des hashes de tous les fichiers manifestés.
- Contrat secret PlatformDeploy : **PASS** par inspection locale du script épinglé : deux occurrences de `RetailJfrogApiKey`, uniquement sa variable et le texte de l'exception obligatoire ; aucune utilisation dans le corps PS7. L'appel réel n'a pas été exécuté.

## Diff ciblé

- Modifiés : `azure-pipelines.candidate.yml`, `README.md`, `MANIFEST.sha256`, `scripts/steps-replay-variant.yml`, `scripts/Invoke-V22RunnerDryRun.ps1`, `scripts/Test-V22ReplayFailureModes.ps1`.
- Ajoutés : `scripts/Invoke-V22PlatformDeploy.ps1`, `scripts/Assert-V22ConsumedPackages.ps1`, `scripts/Assert-V22AuthorizationComparison.ps1`.
- `Preflight-V22FrenchTaxesRules.ps1` n'a pas été modifié.

## Limites et préconditions runtime restantes

- **UNKNOWN** : pull réel avec le service connection, compatibilité `windows-latest`/image LTSC2022, identité et cycle de vie du container, mounts, réseau et absence de cible partagée.
- **UNKNOWN** : authentification JFrog réellement disponible pour le CLI interne, puisque l'interface PS7 historique déclarait mais n'utilisait pas la clé ; aucune tentative réseau n'a été faite.
- La vérification packages est post-déploiement par nécessité de l'orchestration monolithique PlatformDeploy ; elle est fail-closed avant toute campagne, mais ne constitue pas un garde-fou pré-écriture de restauration.
- **UNKNOWN** : résultat métier réel et disparition des 174 refus ; aucune campagne JMeter n'a été exécutée.
