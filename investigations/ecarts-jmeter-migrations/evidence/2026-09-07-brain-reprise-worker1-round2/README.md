# Round 2 — validation générateur/package/JMeter

Date : 2026-09-07. Portée locale, hors FrenchTaxesRules releases/V5 V22/V23. Aucun dépôt, pipeline, package feed, SQL, HTTP ou fichier canonique partagé modifié.

## FACT

- Fixture source `fixture/TestPlans/plan01.xml` : ajout d'un `Control` SOAP `/soap:Fault/detail/faultcode` avec `ExpectedValue=0`, et d'un `Control` SQL non destructif `SELECT 'NN''é' AS UnicodeValue, '2026-09-07' AS DateValue`.
- Le package existant `local-2026-09-07-soap-package-round14/.../package-extracted-v2` a été copié dans le staging neuf `C:\Users\jegour\AppData\Local\Temp\wi2222897-r2-20260907-160040`.
- DLL API extraite du package : SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`.
- Génération Console réelle finale : `generation-final.log`, `EXIT=0`, JMX cible produit après les essais précédents. JMX copié dans `generated/001-plan01.jmx`, 111650 octets, SHA-256 `836A9558C526162E6A5007D73220829C2E5B691E19AFD8709AD10661A19C47D6`.
- Lecture par `System.Xml.XmlDocument.Load()` : deux assertions SOAP issues des contrôles `ExpectedValue=0`, `XPath.negate=true`, `XPath.namespace=true`, XPath exact `//*[local-name()='Fault' and namespace-uri()='http://schemas.xmlsoap.org/soap/envelope/']/detail/faultcode`. Requête SQL générée : `SELECT N'NN''é' AS UnicodeValue, '20260907' AS DateValue`.
- JMeter 5.6.3 réel : runtime complet `C:\Users\jegour\AppData\Local\Temp\wi2222897-r12-9ee5a7b4\apache-jmeter-5.6.3`, Java 23.0.1, `Using SaveService properties version 5.0`, run standalone code `0`. Nouveau JTL `results-r2-real.jtl`, SHA-256 `73D54F7ED83F4A4BF983F63CBB7C211E42C845EE7AEA0B83F40768780CFCB925` : `FAULT_PRESENT=false` (échec volontaire attendu), `NO_FAULT=true`, `WRONG_NAMESPACE=true`.

## Méthode et erreurs conservées

Les essais initiaux sont conservés : répertoires attendus manquants, GUID invalides, puis InputFiles/OutputFiles manquants. Le run final est celui de `generation-final.log`. Le premier runtime JMeter utilisé manquait `bin/saveservice.properties`, provoquant `CannotResolveClassException`; ce runtime n'est pas retenu. Le run final utilise le runtime r12 complet et le JTL, pas un JTL historique.

## INFERENCE

La chaîne locale est maintenant démontrée pour : package existant → Console packagée → JMX frais → extraction XML des transformations SOAP/SQL/date. Le harness JMeter négatif prouve la sémantique d'exécution sur les trois fixtures synthétiques, y compris l'échec volontaire du Fault présent.

## UNKNOWN

La chaîne ne prouve pas encore un package officiel publié/consommé, l'orchestration migration `step_00/step_01`, la sélection par un plugin réel, ni un rejeu métier SQL/HTTP sur cible dédiée. Le JMeter exécuté est un harness local de fixtures SOAP, pas le JMX métier généré avec accès SQL/HTTP. SOAP 1.2 reste non démontré.

## Prochaine action utile

Conserver ces postconditions puis traiter séparément l'orchestration migration avec checkout/JMX/backup/image/cibles dédiés et contrôles pré-écriture. Aucun pipeline n'est nécessaire pour les validations locales de ce lot.

## Empreintes principales

`generated/001-plan01.jmx` : `836A9558C526162E6A5007D73220829C2E5B691E19AFD8709AD10661A19C47D6`  
`results-r2-real.jtl` : `73D54F7ED83F4A4BF983F63CBB7C211E42C845EE7AEA0B83F40768780CFCB925`  
`fixture/TestPlans/plan01.xml` : `1DB6BCED4D774BE60CA3C26621A19C2386B425B386C13F7099D00949492E3562`
