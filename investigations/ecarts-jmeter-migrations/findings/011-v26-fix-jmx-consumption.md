# Consommation du JMX corrigé pour Export_Run

Date : 2026-09-06. **FACT** — la chaîne locale est documentée dans [la preuve](../evidence/local-2026-09-06-v26-fix-jmx-consumption-review/README.md) : le descripteur `ExportRunOnly.xml` est chargé par `jmeter-cli.ps1`, son `TestPlanItem` est joint au dossier `Tests`, puis le chemin obtenu est passé directement à `jmeter.bat -t`.

**FACT** — le brouillon ne génère ni ne transporte le JMX corrigé. La génération locale corrigée connue produit `001-Export_Run.jmx` dans `out/Tests/Export_Run` (`console.stdout.log:20-23`), mais aucun raccord de ce dossier ou de cet artefact vers le checkout consommé n’existe dans le brouillon. **FACT** — la reproduction exacte de `Select-Xml -Xml $xml -XPath '//TestCampaign/TestPlanItem'` renvoie `Count: 0` sur le XML candidat, dont le namespace par défaut vaut `TestAutomation` ([preuve](../evidence/local-2026-09-06-v26-fix-jmx-xpath-reproduction/README.md)). Aucun chemin de plan n’est donc sélectionné; `Tests\TestPlans\Export_Run.xml` reste théorique. **UNKNOWN** — une substitution préexistante dans le checkout réel n’est pas prouvée.

Décision : conserver le brouillon bloqué. Préparer seulement un manifeste hashé du JMX source/destination et un descripteur pointant sans ambiguïté vers le fichier consommé; ne pas régénérer, exécuter ou modifier le pipeline dans cette étape.

Le contrat minimal proposé (non réalisé) est : descripteur compatible ciblant directement le JMX, artefact/copie avec source-destination-commit-hash, vérification du fichier avant invocation, et séparation explicite de la source de génération `07a42172...` et de la baseline `4432510` / `f80bc731...`. Les garde-fous SQL/IIS, secrets, agent/acquisitions et isolation restent bloquants; résultat métier UNKNOWN.
