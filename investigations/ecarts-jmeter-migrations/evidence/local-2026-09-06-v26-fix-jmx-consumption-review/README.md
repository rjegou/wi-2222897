# Chaîne de consommation JMX Export_Run — revue locale

Date : 2026-09-06. Source système : fichiers locaux du WI-2222897, brouillon `local-2026-09-06-v26-fix-replay-draft`, worktree `Y2_Tools_Jmeter_Workflow`, snapshot `Y2_Plugins_FrenchTaxesRules` et preuve de génération Export_Run. Aucun runner, JMeter, pipeline, déploiement ou opération distante exécuté.

## Chaîne prouvée

1. **Descripteur de campagne.** Le brouillon appelle le template avec `campaignsFolderPath=...\Tests` et `campaignName=ExportRunOnly` (`draft/azure-pipelines.candidate.yml:79-92`). Le fichier `campaigns/ExportRunOnly.xml:2-3` contient `TestPlanItem item="TestPlans\Export_Run.xml"`.
2. **Résolution runner.** Le template candidat construit `$campaignFilePath = "$campaignsFolderPath\$campaignName.xml"` puis appelle `jmeter-cli.ps1 invoke-campaign` (`draft/templates/task-run-campaign.candidate.yml:121-144`). Dans le runner local, `Get-CampaignTestPlans` charge ce XML, sélectionne `//TestCampaign/TestPlanItem`, puis fait `Join-Path $campaignsFolderPath $_.item` (`worktrees/Y2_Tools_Jmeter_Workflow/Scripts/jmeter-cli.ps1:302-327`). Il obtient donc `...\Tests\TestPlans\Export_Run.xml`.
3. **Sélection JMX et invocation.** `Invoke-Campaign` itère les chemins renvoyés puis exécute directement `jmeter.bat -n -t "$testPlan" -p ...` (`Scripts/jmeter-cli.ps1:160-169`, chemin du binaire `:600-603`). Dans cette chaîne, le `TestPlanItem` doit donc être un fichier JMeter consommable par `-t`; aucun appel de génération n’est présent.
4. **Génération historique/corrigée distincte.** La preuve de génération locale indique que Console charge `fixtures\TestPlans\Export_Run.xml` et écrit/écrase `out/Tests/Export_Run\001-Export_Run.jmx` (`evidence/local-2026-09-06-export-complete-before-after/corrected/console.stdout.log:20-23`). Cette preuve utilise la source legacy `07a42172...` et Console/API locaux documentés dans son README; elle n’est pas la baseline pipeline 4432510 (`f80bc731...`).

## Verdicts

- **FACT** — le runner ne régénère pas le JMX pendant `invoke-campaign`; il charge le descripteur puis passe le chemin résolu à JMeter.
- **FACT** — le descripteur candidat déclare le namespace XML par défaut `TestAutomation` (`draft/campaigns/ExportRunOnly.xml:2`), tandis que le runner utilise l’XPath non préfixé `//TestCampaign/TestPlanItem` (`Scripts/jmeter-cli.ps1:322-326`) sans `XmlNamespaceManager` visible. **INFERENCE** — la sélection peut retourner zéro nœud dans ce cas; ce point doit être vérifié/corrigé statiquement avant tout run, sans exécution.
- **FACT** — le brouillon ne contient ni étape Console, ni copie depuis un output Console, ni téléchargement d’un artefact JMX corrigé, ni redirection de `campaignsFolderPath` vers un dossier de sortie généré.
- **FACT** — le `stage-evidence.ps1` du brouillon collecte `Tests\LegacyServices\010-Export_Run.jmx` (`draft/scripts/stage-evidence.ps1:9-11`), alors que le descripteur candidat résout `Tests\TestPlans\Export_Run.xml`; cette collecte ne prouve pas que le JMX réellement consommé est celui corrigé.
- **INFERENCE** — si `Tests\TestPlans\Export_Run.xml` est un descripteur de génération comme dans la preuve Console, le brouillon transmet un XML de campagne/plan à JMeter et ne peut pas exécuter le JMX corrigé attendu. Si un fichier JMX homonyme existe dans le checkout réel, sa provenance corrigée reste non établie.
- **UNKNOWN** — aucune preuve locale disponible ne relie un JMX corrigé produit par l’API `EscapeJdbcDate` au chemin exact consommé par ce brouillon sur la baseline 4432510.

## Substitution sans régénération

**UNKNOWN / non démontré.** Le runner lui-même accepterait un JMX préexistant si le `TestPlanItem` et le chemin résolu pointent directement vers ce fichier; cependant le brouillon ne fournit pas ce raccord et le nom `Export_Run.xml` ne correspond pas au JMX observé `001-Export_Run.jmx`. Une substitution sûre exige un artefact ou une copie explicitement hashée dans le checkout, puis un descripteur dont la résolution et le chemin `-t` sont vérifiables avant run. Ne pas modifier le code ou pipeline dans cette étape.

## Blocage et prochaine preuve minimale

Composant absent : étape de production/transport du JMX corrigé dans le répertoire consommé, avec manifeste `source -> destination -> SHA-256`, et validation statique que `Get-CampaignTestPlans` renvoie ce chemin. La prochaine étape réelle est de résoudre ce raccord documentaire uniquement; ne pas lancer le brouillon.
