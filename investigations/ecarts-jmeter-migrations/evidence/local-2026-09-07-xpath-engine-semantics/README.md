# Sémantique XPath — contrôle local

Date : 2026-09-07. JMX observé : `evidence/local-2026-09-07-four-plans-integrated/corrected/001-1.jmx` et plans corrigés associés.

FACT : les assertions générées portent `XPath.namespace=false`, `XPath.tolerant=false`, `XPath.validate=false`, `XPath.whitespace=false`; `XPath.negate` varie selon ExpectedValue. Les XPath Fault corrigés sont `//Fault`, `//Fault/faultcode[...]` et descendants. Le JMX n'ajoute aucun namespace manager.

Contrôle XML local sur réponse SOAP synthétique namespace-aware : `//Fault` sélectionne 0 nœud; `//soap:Fault` avec namespace `urn:soap` sélectionne 1; le code Fault namespace-aware sélectionne 1. Cela démontre un risque de faux négatif si le moteur JMeter applique strictement `namespace=false` sur un DOM namespace-aware.

Le moteur JMeter complet n'est pas disponible dans les worktrees; `verification/jmeter.bat` est seulement un stub de capture et n'a pas été traité comme moteur. Java local détecté 23.0.1, cible de la chaîne 21 non validée. Aucun défaut supplémentaire n'est corrigé dans CleanXpath, car la sémantique exacte de XPathAssertion JMeter reste UNKNOWN.

Tests production dernière DLL SHA-256 `847FBE7A3E934FF144B46E18A35672A159DDE55BF15C1B1FEFD30B962A28550A` : CleanXpath 6 PASS, Unicode 9 PASS, dates incluses dans les tests existants de génération; aucun SQL/HTTP/JMeter métier.

Acquisition officielle Apache JMeter 5.6.3 tentée le 2026-09-07 (`apache-jmeter-5.6.3.zip` et `.sha512`). `Invoke-WebRequest` et `curl.exe` ont échoué TLS avec `SEC_E_NO_CREDENTIALS`; aucun fichier acquis ou exécuté. La page officielle Apache recommande SHA-512/PGP; moteur réel reste UNKNOWN.
