# Lot local — correctif générateur SOAP namespace-aware

- Date de collecte : 2026-09-07 (Europe/Paris).
- Worktree : `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE`.
- Modification : `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` uniquement pour ce correctif ; les modifications préexistantes EscapeJdbcDate/FixSqlUnicodeValue/CleanXpath ont été conservées.
- Aucun push, publication, pipeline ou fichier `STATUS.md`, `HANDOFF.md`, `JOURNAL.md` modifié.

## FACT

1. Le build local .NET Framework 4.5.2 du projet API avec les références de staging existantes s'est terminé avec `EXIT_CODE=0`, sans warning ni erreur. La DLL produite est `runtime/Cegid.Retail.AutoTest.Api.dll`.
2. Le générateur émet désormais pour un contrôle source contenant `soap:Fault` :

   `//*[local-name()='Fault' and namespace-uri()='http://schemas.xmlsoap.org/soap/envelope/']/detail/faultcode`

   avec `XPath.namespace=true`. La chaîne est inline : aucun fichier de mapping namespace n'est requis ou supposé présent.
3. Le même JMX généré conserve `/Result` sous la forme `//Result` avec `XPath.namespace=false`.
4. Le JMX généré est `generated-jmx/soap-fault.jmx`; la génération vérifie les deux postconditions dans `generation-results.txt` (`SOAP_POSTCONDITION=PASS`, `NON_SOAP_POSTCONDITION=PASS`).
5. L'assertion extraite du JMX généré a été exécutée avec Apache JMeter officiel 5.6.3 :

   - préfixe `soap`, URI SOAP 1.1 : match ;
   - préfixe `env`, même URI SOAP 1.1 : match ;
   - réponse sans `Fault` : pas de match ;
   - élément `Fault` sous le mauvais namespace `urn:not-soap` : pas de match.

   Résultat : `EXECUTION_POSTCONDITION=PASS` dans `jmeter-run/generated-execution.log`. Ce rejeu utilise les classes JMeter 5.6.3 et la XPath lue du JMX généré ; il ne dépend pas du mapping externe `xpath.namespace.config`.

## INFERENCE

- `CleanXpath` seul ne peut pas rendre une assertion SOAP sûre : supprimer le préfixe conserve une ambiguïté entre namespaces. Le correctif doit donc activer le mode namespace et porter l'URI SOAP dans l'expression consommée par JMeter.
- Le ciblage est volontairement limité aux chemins contenant `soap:Fault`. Les assertions non SOAP continuent à suivre `CleanXpath` et leur comportement observé (`//Result`, namespace désactivé).

## UNKNOWN / limites

- Les contrats et sorties inspectés dans cette enquête établissent SOAP 1.1 (`http://schemas.xmlsoap.org/soap/envelope/`). Aucun contrat SOAP 1.2 n'a été trouvé dans le périmètre ; le correctif ne généralise donc pas à `http://www.w3.org/2003/05/soap-envelope`.
- Le rejeu couvre les préfixes variables, l'absence de Fault et le mauvais namespace, mais ne constitue pas une validation de package/migration ni un rejeu Azure DevOps.
- La forme exacte des descendants (`detail/faultcode`) reste celle du contrôle source du fixture ; d'autres chemins SOAP devront conserver leur suffixe et être validés par scénario.

## Empreintes SHA-256

```text
57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B  runtime/Cegid.Retail.AutoTest.Api.dll
0CBD70E2247C77499D9124C26498C78D764740B030A0F1C424BDB88A8C9ED6A6  generated-jmx/soap-fault.jmx
35C8B06EF9E4CF35D8CEFADF3984BE9C04DC9AF454BF04F4AFA5EB066348857D  jmeter-run/generated-execution.log
```

