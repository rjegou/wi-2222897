# Reprise indépendante Worker 1 — handoff SOAP et chaîne générateur

Date de collecte : 2026-09-07. Système : fichiers locaux du workspace WI-2222897, .NET Reflection/XML et artefacts JMeter/Console déjà présents. Portée : vérification indépendante du handoff manuel, hors FrenchTaxesRules releases/V5 V22/V23.

## Résultat synthétique

**FACT** — la DLL `Cegid.Retail.AutoTest.Api.dll` extraite du package Console SOAP v2 a le SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`. Une invocation indépendante par réflexion confirme :

- `EscapeJdbcDate("'2026-09-07'")` → `'20260907'` : **PASS** ;
- `FixSqlUnicodeValue("SELECT 'NN''é' AS V")` → `SELECT N'NN''é' AS V` : **PASS**.

**FACT** — le package local v2 contient cette DLL. Le `.nupkg` a le SHA-512 `519DB0E99A9E9E2424F69D8DAACCB551C9ED4790F3817E25DB84D528E0752C35DF8EE6F342085BEF14843B4046CAB1C4DC36A9AA7AA99C3E5879BD232C7AB3D8`.

**FACT** — le JMX SOAP produit par la Console packagée contient le XPath namespace-aware et une assertion `TC 01 - B-XQuery - Control SOAP Fault namespace` avec `XPath.namespace=true`, mais `XPath.negate=false`. La même collecte contient une seconde assertion non-SOAP avec `negate=true`.

**FACT** — l'exécution réelle JMeter 5.6.3 du harness négatif manuel a un exit code `0`; la lecture JTL donne `FAULT_PRESENT success=false`, `NO_FAULT success=true`, `WRONG_NAMESPACE success=true`. Le postcondition du harness est donc cohérente avec un contrôle négatif.

**UNKNOWN** — le handoff affirme `ExpectedValue=0 → XPath.negate=true` dans une génération Console réelle, mais aucun JMX généré SOAP trouvé dans les artefacts contrôlés ne démontre cette relation : `soap-negative-generated` et `round14` ont tous deux `negate=false` pour le contrôle SOAP. Le fichier `soap-negative-jmeter56/soap-negative-harness.jmx` porte `negate=true`, mais il est un harness JMeter manuel et ne prouve pas la génération source→Console.

**UNKNOWN** — la propagation package→Console→JMX des deux transformations SQL/date n'est pas prouvée par cette collecte. La preuve indépendante au niveau DLL est positive; le package v2 contrôlé est la variante SOAP et son JMX contrôlé ne contient pas le vecteur SQL/date `SELECT N'NN''é' ... '20260907'`.

## Commandes et sorties principales

### Git avant toute édition de dépôt

`git -c safe.directory=<worktree> -C <worktree> status --short --branch` a été exécuté sur les worktrees API RJE, Console RJE, migration sandbox et workflow. Résultats notables :

- API RJE : branche `sandbox/rje-wi2222897-escape-jdbc-date`, modifications locales existantes `JmeterCodeGen.cs` et `tests/` ; préservées ;
- migration sandbox : propre ;
- workflow : modification locale existante `azure-pipeline.yml` ; préservée.

Aucun dépôt n'a été édité.

### Réflexion DLL

DLL contrôlée : `evidence/local-2026-09-07-soap-package-round14/package-extracted-v2/tools/Cegid.Retail.AutoTest.Api.dll`.

Méthode : `Assembly.LoadFrom`, type `Cegid.Retail.AutoTest.Api.JmeterCodeGen`, méthodes statiques `EscapeJdbcDate` et `FixSqlUnicodeValue`, sans rebuild ni mutation du binaire. Sortie : `METHOD_FOUND=True`, `ESCAPE_ACTUAL='20260907'`, `ESCAPE_PASS=True`, `UNICODE_ACTUAL=SELECT N'NN''é' AS V`, `UNICODE_PASS=True`.

### XML JMX

Lecture par `System.Xml.XmlDocument.Load()` des fichiers :

- `evidence/local-2026-09-07-soap-negative-generated/generated/Tests/campaign/001-plan01.jmx` : contrôle SOAP `negate=false` ;
- `evidence/local-2026-09-07-soap-package-round14/generated-from-packaged-console/Tests/campaign/001-plan01.jmx` : contrôle SOAP `negate=false`, XPath namespace-aware ;
- `evidence/local-2026-09-07-soap-negative-jmeter56/soap-negative-harness.jmx` : `negate=true`, mais harness manuel.

Le hash du JMX package round14 est `DDDFAB27C0DD17622A5DF7D273C2D704C68DA5622759B95665D9C3A3088C2035`.

### JMeter/JTL

Artefact JTL : `evidence/local-2026-09-07-soap-negative-jmeter56/results-fixed.jtl`, SHA-256 `FAB79862FA84CA439B0B134767284D0BAC35D44A9BCDA4F4BB7FD84780A2702D`. Le log indique JMeter `5.6.3`; la distribution officielle et son checksum `MATCH` sont indexés dans `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/`. Le code `0` n'a pas été utilisé seul : les colonnes `success` et `failureMessage` du JTL ont été relues.

## Chaîne et manque d'orchestration

**FACT** : DLL `57BE...` → package local SOAP v2 → extraction `package-extracted-v2` → exécutable Console packagé → génération JMX SOAP est démontré par les artefacts et hashes ci-dessus.

**INFERENCE** : la chaîne technique locale est fonctionnelle pour SOAP positif et pour les corrections SQL/date au niveau DLL, mais les preuves disponibles ne démontrent pas encore une migration métier complète.

**UNKNOWN restant** : package officiel publié/consommé par le workflow, sélection du package par `Migration_Jmeter_RJE_Sandbox` dans un run réel, orchestration `step_00/step_01`, sélection de campagne par plugin réel, cibles SQL/IIS/backup dédiées, exécution JMeter métier et comparaison legacy cas à cas. Aucun pipeline, package feed, SQL, HTTP ou worktree partagé n'a été modifié.

## Propositions précises pour le BRAIN

1. Ne pas lever l'UNKNOWN `ExpectedValue=0` sur la seule base du handoff ; produire un fixture source `Control` SOAP à `ExpectedValue=0`, supprimer le JMX cible, lancer la Console packagée v2, puis vérifier par XML que le contrôle SOAP généré porte `negate=true` avant tout JMeter.
2. Pour SQL/date, fabriquer une variante locale distincte du nupkg v2 avec la DLL 57BE, injecter uniquement le `SELECT` non destructif, puis relire le JMX avec `XmlDocument.Load()` et hash; ne jamais déduire cette propagation du test de réflexion.
3. Après ces postconditions locales, traiter séparément l'orchestration migration réelle. Aucun lancement ADO n'est utile pour clore ces lacunes de preuve locale sans cible et contrat d'entrée immuables.

## Limites / préservation

Cette collecte ne modifie ni `STATUS.md`, ni `HANDOFF.md`, ni `JOURNAL.md`, ni les index partagés, ni les sources/snapshots existants. Les valeurs de hash et résultats sont datés de cette reprise. Les conclusions FrenchTaxesRules sont volontairement exclues.
