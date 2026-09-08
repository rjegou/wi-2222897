# Vérification JMeter 5.6.3 — XPathAssertion offline

Date de collecte : 2026-09-07. Collecte lecture seule, sans code produit, pipeline, package partagé, réseau métier, SQL, Y2 ou JMX métier.

## Provenance du runtime

- **FACT** — le ZIP officiel `apache-jmeter-5.6.3.zip` est conservé dans `manual-verification/`.
- **FACT** — le SHA-512 fourni par Apache et le hash calculé correspondent : `387FADCA903EE0AA30E3F2115FDFEDB3898B102E6B9FE7CC3942703094BD2E65B235DF2B0C6D0D3248E74C9A7950A36E42625FD74425368342C12E40B0163076` (`jmeter-hash-check.txt`, statut `MATCH`).
- **FACT** — le runtime JMeter 5.6.3 démarre avec code `0`; Java observé : `23.0.1` (`jmeter-runtime-check.txt`).
- **FACT** — les harnesses Java compilent et s'exécutent avec code `0`; ils invoquent réellement `XPathAssertion` sur des `SampleResult` en mémoire.

## Résultats réels avec `namespace=false`

Configuration générée : `XPath=//Fault`, `namespace=false`, `tolerant=false`, `validating=false`, `whitespace=false`, `negated=false`.

- **FACT** — SOAP 1.1 `<soap:Fault>` et le même Fault sous un autre préfixe ne matchent pas.
- **FACT** — un `<Fault>` non préfixé matche.
- **FACT** — un Fault d'un autre namespace ne matche pas dans le cas testé.
- **FACT** — une réponse SOAP sans Fault ne matche pas.

Conclusion bornée : `//Fault` est syntaxiquement valide après la correction de `CleanXpath`, mais il ne préserve pas la détection d'un Fault SOAP préfixé lorsque les JMX restent en `namespace=false`. Il s'agit d'un faux négatif de l'assertion, pas d'une preuve de succès métier.

## Résultats réels avec namespace et mapping SOAP

Configuration : `namespace=true`, `namespaces.properties` avec `soap=http://schemas.xmlsoap.org/soap/envelope/`, XPath `//soap:Fault`.

- **FACT** — SOAP 1.1 avec préfixe `soap` : `MATCH`.
- **FACT** — même namespace SOAP 1.1 avec préfixe `env` : `MATCH`.
- **FACT** — SOAP sans Fault : `NO_MATCH`.
- **FACT** — `soap:Fault` lié à `urn:not-soap` : `NO_MATCH`.

Le moteur réel démontre donc que le mapping porte sur l'URI namespace, indépendamment du préfixe lexical, et rejette le mauvais namespace testé.

## Candidat écarté

`//*[local-name()='Fault']` matche les Fault SOAP quel que soit leur préfixe, mais matche aussi un Fault d'un namespace sans rapport. Il ne constitue pas un remplacement namespace-safe.

## Conséquences et limites

- **INFERENCE** — la correction actuelle de `CleanXpath` (`/soap:Fault` → `//Fault`) supprime l'expression invalide `//`, mais ne suffit pas pour une assertion SOAP robuste dans les JMX actuels.
- **INFERENCE** — le correctif générateur doit, pour les Fault SOAP, produire une assertion namespace-aware (`namespace=true`), un mapping explicite de l'URI SOAP et un XPath préfixé tel que `//soap:Fault`; il faut traiter séparément SOAP 1.1 et SOAP 1.2 et éviter une modification globale sans inventaire des autres XPath.
- **UNKNOWN** — propagation de cette correction dans API → Console → package de migration, régénération complète des JMX, et résultat métier en pipeline.
- **UNKNOWN** — validation SOAP 1.2 dans ce harness et comparabilité Java 21 de la cible métier.

## Fichiers de preuve

Les sources Java, le mapping, les sorties brutes, le ZIP officiel et le checksum sont conservés dans ce dossier. Les sorties principales sont `jmeter-xpath-real-test.txt`, `jmeter-xpath-candidates-result.txt` et `jmeter-xpath-namespace-result.txt`.
