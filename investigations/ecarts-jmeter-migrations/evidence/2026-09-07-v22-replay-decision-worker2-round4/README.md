# Décision de rejeu V22 — revue Worker 2 round 4

Date : 2026-09-07. Revue locale et lecture seule distante ; aucun lancement, aucune restauration distante, aucune mutation de branche ou de définition.

## Verdict

**NOT READY TO QUEUE / approbation métier finale manquante.** Le candidat local est prêt pour examen technique, mais le succès du préflight `4442120` ne vaut pas autorisation de restauration, déploiement ou rejeu métier.

## Faits vérifiés

- `azure-devops-french-taxes-rules-v22-worker1-round12/README.md:5-40` établit le run `4442120`, définition `14246`, branche neutre `refs/heads/investigation/wi-2222897-v22-preflight-20260907`, image digest-pinnée et absence de publication. Le même rapport dit explicitement : « aucun rejeu métier » et « Le run ne constitue pas un rejeu métier ».
- L’attestation baseline est produite par `FixHistorical/captureBaseline`, exposée comme variable de sortie, puis consommée par `FixCandidate` via `stageDependencies.FixHistorical.FixHistorical.outputs['captureBaseline.V22BaselineAuthSummary']`. Le transport Azure réel n’a pas été exécuté ni relu ; la fixture locale prouve seulement l’encodage/validation, pas le transfert entre agents.
- Chaque job appelle le contrôle de runtime local avant toute écriture de déploiement et après celle-ci. Le candidat ne publie pas d’artefact pour transporter l’attestation.
- `Invoke-V22PlatformDeploy.ps1` est compatible avec le mécanisme observé dans la version épinglée de PlatformDeploy 5.0.86 : copie temporaire sans argument secret, fichier `Retail-JfrogCli.json` au chemin attendu, restauration/suppression dans `finally`, effacement de la variable d’environnement. Le chemin d’échec PowerShell est couvert localement ; une terminaison forcée de l’agent avant `finally` reste UNKNOWN.
- `Test-V22ReplayFailureModes.ps1` passe dans PowerShell 7 et Windows PowerShell 5.1 : échec baseline bloque le candidat, cleanup candidat reste exigé, mauvais comptage refusé, attestation acceptée avant écritures candidat, comparaison par scénario/signature avec échecs non ciblés conservés.
- `Invoke-V22RunnerDryRun.ps1` passe avec le snapshot `Y2_Plugins_FrenchTaxesRules-v5-build-4429167` : 32 JMX, 3 opérations discriminantes, 232 Legacy + 144 Web = 376, sans SQL/IIS, JMeter, publication ou queue.

## Autorisations recherchées

Aucune formulation utilisateur indexée n’accorde explicitement le rejeu métier, la restauration ou le déploiement. La preuve round 12 limite l’action à une collecte sans rejeu. La preuve round 6 contient au contraire : « VERDICT : NON AUTORISÉ / BLOCKED » et « Aucune queue ne doit être lancée avant correction/proof de ces points. » Ces formulations sont des verdicts de preuve, pas une autorisation utilisateur à transformer en permission implicite.

## Candidat et effets envisagés

Le candidat local est `replay-prep/2026-09-07-v22-isolated/`. Aucun branchement ou définition de rejeu n’a été créé. Proposition de nom neutre à examiner seulement après autorisation : branche `investigation/wi-2222897-v22-isolated-20260907`, définition `WI-2222897 V22 Isolated Replay 20260907`.

Effets exacts à accepter séparément : restauration de la sauvegarde attendue, déploiement SQL/IIS local dans les deux jobs, trois opérations discriminantes, campagnes JMeter Legacy/Web, collecte scrubbed et nettoyage job-scoped. Aucun effet de publication, promotion, tag, PR ou branche n’est requis.

## Conditions de décision restantes

1. Obtenir une approbation explicite et finale du rejeu métier, distincte du préflight.
2. Valider côté serveur la définition/candidate et prouver le transport réel de la sortie baseline entre jobs/agents.
3. Prouver au runtime l’image ACR exacte `acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter`, le tag historique et le digest confirmé.
4. Prouver l’acquisition et la consommation effective des packages, l’assembly réellement chargé par IIS, l’identité SQL/IIS, les mounts/réseaux et l’absence de cible partagée.
5. Accepter uniquement une comparaison baseline/candidat par identité de scénario et signature : baseline 138 + 36 = 174 refus ciblés ; candidat disparition des 174 signatures ciblées ; nouveaux échecs, tests non exécutés et échecs non ciblés comptés séparément ; totaux de campagne 232 + 144 attendus.

## Limites

Le run `4442120` est une preuve de readiness de services et d’immutabilité de préflight, pas une preuve d’isolation runtime détaillée ni une preuve de rejeu. Le transport `stageDependencies`, la restauration réelle, l’assembly IIS chargée et les effets métiers restent non établis tant qu’un run autorisé et comparable n’a pas produit ces attestations.
