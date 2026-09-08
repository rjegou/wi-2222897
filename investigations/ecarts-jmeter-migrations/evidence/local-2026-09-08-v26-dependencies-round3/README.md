# FrenchTaxesRules V26 — dépendances round 3

Collecte locale et REST en lecture seule, 2026-09-08 (Europe/Paris). Aucun run métier, publication de définition, modification de droit, nettoyage de ressource ou édition d'un canon partagé n'a été effectué.

## État factuel

- **FACT** — La ref `sandbox/frenchtaxesrules/api-jmeter-fixes` du dépôt `Y2_Tools_AutoTest_Api` (`60951ba6-fb32-4a61-9b7d-9df7b31d575c`) est trouvée avec le filtre REST exact `heads/sandbox/frenchtaxesrules/api-jmeter-fixes` et pointe sur `9081ecfe7aa07f5e584073d2af1828d3ac9f7235`. Le précédent zéro résultat venait du filtre incomplet `sandbox/...`, pas d'une absence de branche.
- **FACT** — Le build API `4444765` / définition `2637` a produit le package candidat `1.1.47-wi2222897-api-candidate`; son SHA-256 nupkg est `296D7EAA4031138369C39986BE9F38264AF5BAB96AE0DC1D29E2380567BB864F`.
- **FACT** — Une lecture REST au 2026-09-08 constate zéro run actif pour la définition API `2637`, mais le build Console `4444888` est `inProgress` sur `sandbox/frenchtaxesrules/console-api-artifact`, commit `202f8a6a22784786ed90d417f24626e0381bc07e`. La définition legacy `2054` a également le build `4423394` encore `inProgress` sur `master`. Ces runs sont hors périmètre et interdisent un lancement concurrent non nécessaire.
- **FACT** — Les définitions `2054` (CI plugin, YAML `/azure-pipelines.yml`) et `11454` (JMeter historique, YAML `azure-pipelines-Jmeter.yml`) sont activées, mais aucune n'est une chaîne V26 isolée. `2054` conserve la chaîne staging / TestAutos / promotion / tag ; `11454` est la définition web-app historique.
- **FACT** — Le clone local `migration-current-source` contient un package Console `2.0.41` (SHA-256 `7C5C6D5023037838EE15E7DA3C518660D1ACADB20447CA778D61AB62B15409DC`) dont le nuspec dépend de l'API `1.1.46`. Il n'est donc pas l'artefact Console du build 4444888 et ne peut pas être injecté dans V26.
- **FACT** — Dans ce clone, `Tests/Backups/AUTO_V26_00.bak`, `Tests/Export_Run/001-Export_Run.jmx` et un descripteur `DocumentSignatureSignOneOnly` sont absents. Le seul JMX indexé localement est `LocalParameters.jmx`; aucune preuve actuelle ne fournit les 32 JMX ou le descripteur demandé.
- **FACT** — Le candidat round 2 contient bien 18 références `template:`, mais elles pointent vers `replay-assets/templates/*.candidate.yml`, chemin absent de la collecte courante. Elles ne sont donc pas transitivement vérifiables. Le lot hardened local contient 7 fichiers sous `templates/`; ses occurrences `JFrogGenericArtifacts` sont des téléchargements PlatformDeploy conservés par la source, pas une preuve d'absence d'effet externe runtime.

## Dépendances non résolues

- **UNKNOWN** — package Console construit par `4444888`, son SHA-256 et son contenu exact ; attendre la fin du build puis l'artefact PipelineArtifact.
- **UNKNOWN** — provenance/hash du backup `AUTO_V26_00.bak`, agent compatible, cible IIS/SQL dédiée et attestation runtime des mounts/cleanup.
- **UNKNOWN** — version et archive exactes de PlatformDeploy consommées par ce rejeu V26. La version `5.0.86`/hash historique documentés ailleurs ne sont pas une preuve FrenchTaxesRules V26.
- **UNKNOWN** — contenu du descriptor `DocumentSignatureSignOneOnly` et JMX correspondant. Ne pas le fabriquer à partir des logs legacy.

## Décision opérationnelle

Le rejeu métier V26 reste **NON PRÊT**. La prochaine commande autorisée est une lecture ciblée du build Console `4444888`, suivie de la collecte de son artefact, du manifeste JMX exact et du backup hashé. Après résolution et attestation d'isolation, seulement alors publier une définition dédiée sans triggers, staging/promotion/tag/TestAutos, puis exécuter dans l'ordre `Export_Run` TC08, TC09, TC10 et `DocumentSignature_SignOne` TC02. Les cas absents/skipped doivent rester visibles et ne valent pas réussite.
