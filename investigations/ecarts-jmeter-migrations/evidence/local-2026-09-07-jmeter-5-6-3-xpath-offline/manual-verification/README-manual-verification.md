# Manual JMeter 5.6.3 XPath verification

Date: 2026-09-07

## Runtime

- Apache JMeter: 5.6.3
- Official ZIP preserved in this directory
- SHA-512 status: MATCH
- SHA-512: 387FADCA903EE0AA30E3F2115FDFEDB3898B102E6B9FE7CC3942703094BD2E65B235DF2B0C6D0D3248E74C9A7950A36E42625FD74425368342C12E40B0163076
- Java used for the experiment: 23.0.1

## FACT - generated XPath with namespace=false

Real Apache JMeter 5.6.3 XPathAssertion was executed directly against in-memory XML SampleResult instances.

Generated-style configuration:

- XPath: //Fault
- namespace=false
- tolerant=false
- validating=false
- whitespace=false
- negated=false

Observed:

- SOAP 1.1 <soap:Fault> -> NO MATCH
- SOAP 1.1 without Fault -> NO MATCH
- unprefixed <Fault> -> MATCH
- prefixed Fault in another namespace -> NO MATCH

Therefore //Fault does not preserve the semantics of a prefixed SOAP Fault.

## Candidate local-name()

//*[local-name()='Fault'] matches SOAP Fault independently of its prefix, but also matches Fault in an unrelated namespace.

It therefore introduces a potential false positive and is not sufficient as a robust namespace-safe replacement.

## FACT - namespace-aware configuration

Apache JMeter 5.6.3 was initialized with:

- namespace=true
- xpath.namespace.config pointing to namespaces.properties
- mapping:
  soap=http://schemas.xmlsoap.org/soap/envelope/
- XPath: //soap:Fault

Observed:

- SOAP 1.1 using prefix soap -> MATCH
- same SOAP namespace using prefix env -> MATCH
- SOAP response without Fault -> NO MATCH
- soap:Fault bound to urn:not-soap -> NO MATCH

This demonstrates with the real JMeter 5.6.3 XPathAssertion that namespace-aware evaluation preserves the SOAP namespace independently of the XML prefix and rejects the tested wrong namespace.

## Remaining limits

- This manual verification demonstrates XPathAssertion behavior, not a complete business/pipeline replay.
- SOAP 1.2 namespace-aware mapping has not yet been validated in this harness.
- Impact on all other generated XPath assertions must still be evaluated before changing the generator globally.
- Package/migration propagation and real business success remain to be demonstrated.

## Files

The Java harness sources, namespace mapping, raw outputs, official JMeter ZIP and official checksum are stored beside this README.