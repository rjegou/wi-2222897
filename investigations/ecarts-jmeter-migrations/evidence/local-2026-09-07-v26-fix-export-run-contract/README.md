# Contrat offline Export_Run vers JMX corrigé

Date de collecte : 2026-09-07. Système source : fichiers locaux du WI-2222897 et worktree `Y2_Tools_Jmeter_Workflow` (lecture seule). Aucun pipeline, runner JMeter, SQL, HTTP, VM ou système distant n'a été exécuté.

## Contrat retenu pour le contrôle local

Le runner observé charge `Tests\ExportRunOnly.xml`, applique exactement `Select-Xml -XPath "//TestCampaign/TestPlanItem"`, joint chaque attribut `item` au dossier `Tests`, puis passe le chemin obtenu à `jmeter.bat -n -t`.

Le descripteur candidat précédent déclarait le namespace par défaut `TestAutomation` et pointait vers `TestPlans\Export_Run.xml`. Il sélectionnait donc zéro nœud et ne prouvait pas la consommation du JMX corrigé.

Cette preuve prépare un raccord discriminant, sans l'injecter dans un dépôt :

* `campaigns/ExportRunOnly.xml` n'a pas de namespace par défaut, pour être compatible avec le XPath effectivement utilisé ;
* `TestPlanItem/@item` pointe directement vers `Export_Run\001-Export_Run.jmx` ;
* `payload/Tests/Export_Run/001-Export_Run.jmx` est une copie hashée du JMX corrigé généré le 2026-09-06 ;
* `verify-contract.ps1` vérifie la sélection XPath, la résolution du chemin, l'extension `.jmx`, le hash et la présence des `JDBCSampler` avant toute invocation.

## Provenance et limites

Source JMX : `../local-2026-09-06-export-complete-before-after/corrected/001-Export_Run.jmx`, hash SHA-256 `C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C`, 366843 octets, 86 éléments XML `JDBCSampler` (172 occurrences textuelles incluant attributs et balises).

La copie et le contrôle prouvent seulement le raccord local du descripteur au fichier JMX. Ils ne prouvent ni le checkout réel du plugin, ni le déploiement, ni l'image, ni le backup, ni la réussite métier TC08→TC09→TC10.

Verdict : `FACT` pour le défaut XPath et le contrat offline vérifié ; `INFERENCE` pour l'aptitude de ce contrat à supprimer l'ambiguïté de sélection ; `UNKNOWN` pour toute exécution métier.
