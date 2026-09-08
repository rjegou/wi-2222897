# 012 — Sémantique réelle XPathAssertion JMeter 5.6.3

Date : 2026-09-07. Portée : vérification offline de l'assertion XPath, sans pipeline ni rejeu métier.

## Conclusion

**FACT** — le ZIP officiel Apache JMeter 5.6.3 est conservé dans `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/manual-verification/`; son SHA-512 calculé correspond au checksum officiel (`MATCH`). Le runtime démarre avec code `0` et les harnesses compilent/s'exécutent avec code `0`.

**FACT** — avec `namespace=false` et XPath `//Fault`, JMeter 5.6.3 ne matche ni `<soap:Fault>` ni le même élément sous un autre préfixe, alors qu'il matche un `<Fault>` non préfixé. Une réponse sans Fault ne matche pas et le Fault d'un namespace différent testé ne matche pas.

**FACT** — avec `namespace=true`, le mapping `soap=http://schemas.xmlsoap.org/soap/envelope/` et XPath `//soap:Fault`, JMeter matche les préfixes `soap` et `env` liés au même URI SOAP, ne matche pas une réponse sans Fault et rejette `soap:Fault` lié à `urn:not-soap`.

**FACT** — `//*[local-name()='Fault']` est trop permissif : il matche aussi le Fault du namespace non SOAP testé.

## Conséquence pour CleanXpath et le générateur

**INFERENCE** — `CleanXpath` corrigée de `/soap:Fault` vers `//Fault` supprime le XPath invalide `//`, mais le résultat reste sémantiquement insuffisant pour détecter un Fault SOAP préfixé avec les JMX actuels (`XPath.namespace=false`). La correction locale ne doit donc pas être présentée comme une correction SOAP complète.

**INFERENCE** — le correctif générateur doit être redéfini pour les Fault SOAP : activer le mode namespace, fournir le mapping de l'URI SOAP, et générer un XPath préfixé (`//soap:Fault` ou équivalent). SOAP 1.1 et SOAP 1.2 doivent être distingués ; `local-name()` seul ne doit pas être choisi comme solution globale.

**UNKNOWN** — propriétaire exact et forme de configuration à appliquer dans le générateur, propagation API → Console → package de migration, régénération de tous les JMX et validation dans le runner métier. Les autres XPath générés n'ont pas été requalifiés par cette preuve.

## Preuves

- `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/manual-verification/README-manual-verification.md`
- `.../jmeter-hash-check.txt` — checksum `MATCH`.
- `.../jmeter-runtime-check.txt` — JMeter 5.6.3, code `0`.
- `.../jmeter-xpath-real-test.txt` — `namespace=false`.
- `.../jmeter-xpath-namespace-result.txt` — mapping SOAP.
- `.../jmeter-xpath-candidates-result.txt` — variantes de préfixe et namespace.

## Postconditions restantes

1. Identifier dans le code générateur la représentation complète des namespaces SOAP et décider la couverture 1.1/1.2.
2. Produire une génération source → JMX qui porte effectivement `namespace=true`, le mapping et le XPath préfixé.
3. Vérifier la propagation vers Console/package/migration avec hashes et régénération, sans publication distante implicite.
4. Rejouer un cas SOAP isolé, puis seulement les campagnes autorisées ; succès métier encore non démontré.

## Mise à jour round13 — générateur ciblé et provenance des binaires

**FACT** — le correctif local round13 est prouvé séparément dans `evidence/local-2026-09-07-soap-namespace-aware-round13/`. Il génère une expression SOAP 1.1 avec URI inline et `XPath.namespace=true`, sans dépendre d’un fichier de mapping externe. Le suffixe source `/detail/faultcode` est conservé.

**FACT** — un artefact réel du build 4432510 contient `s:Fault` dans l’URI SOAP 1.1, puis `detail` et `faultcode` sans namespace propre ; le suffixe non préfixé généré est donc compatible avec ce contrat réel. Les sorties round13 vérifient les assertions positives (Fault SOAP présent), négatives (absence de Fault et mauvais namespace) et les préfixes `soap`/`env`.

**FACT** — la DLL round13 a le SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`. Elle ne doit pas être confondue avec la DLL API `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81` utilisée dans le package Console local précédent : `51FB31...` ne constitue pas une preuve que le correctif SOAP round13 y est présent.

**FACT** — l’inventaire des contrats JMX réels recense 377 fichiers contenant une assertion Fault, dont 40 avec `XPath.negate=true` et aucun avec `XPath.namespace=true`. Round13 n’a pas exécuté de cas négatif généré avec `ExpectedValue=0`; la conservation de `XPath.negate` est visible dans le code, mais le comportement négatif reste à valider par un test dédié avant généralisation.

**INFERENCE** — le correctif est ciblé aux chemins contenant `soap:Fault`; `CleanXpath` continue de normaliser les assertions non SOAP. Il ne faut pas activer globalement `namespace=true` ni réécrire les descendants sans contrat : les descendants non préfixés sont ici une propriété du SOAP 1.1 réel observé.

## Complément du 2026-09-07 — handoff manuel, consolidation DLL et propagation SQL/date (non revérifié)

**Non revérifié dans ce processus.** Un addendum manuel reçu hors `brain-worker`, rangé sous [`evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/`](../evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/README.md) (fichier `WI-2222897_JMeter_Legacy_Handoff_Addendum_2026-09-07.md`), rapporte des tests directs contre la DLL `57BE...` déjà citée ci-dessus :

- **FACT rapporté** — testée par réflexion directe sans rebuild, la DLL `57BE...` produit `'2026-09-07'` → `'20260907'` (`EscapeJdbcDate`) et `SELECT 'NN''é' AS V` → `SELECT N'NN''é' AS V` (`FixSqlUnicodeValue`), en plus du correctif SOAP déjà établi. Cette même source revendique aussi la propagation réelle package→Console→génération JMX pour ces deux correctifs, via un `Control` SQL réel remplacé par un `SELECT` non destructif en staging isolé, avec relecture du JMX par `System.Xml.XmlDocument.Load()` (JMX SHA-256 `B392ED9DA7DF1C4E2CA0F7144BBFA50B56C2070649CD59411B6ACFBB2CE18A4F`).
- **Point avant cette source, resté ouvert dans le premier handoff rangé** (voir son `README.md`) : la consolidation `EscapeJdbcDate`/`FixSqlUnicodeValue` dans `57BE...` n'était pas confirmée. Cette source affirme la lever, mais aucune de ses affirmations n'a été rejouée indépendamment dans ce processus.

**Verdict arbitré** — les `UNKNOWN` de ce finding (propagation API → Console → package de migration, régénération effective, rejeu métier) restent en l'état pour SOAP. Pour `EscapeJdbcDate`/`FixSqlUnicodeValue`, ne pas citer la consolidation ni la propagation comme `FACT` canonique avant une revérification indépendante (réflexion directe sur le même binaire avec hash confirmé, régénération réelle avec lecture XML sûre et comparaison de hash).
