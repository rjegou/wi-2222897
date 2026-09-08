# Legacy TestAuto evidence

Evidence collected from Y2-TSTAUTOXXPG2 for WI-2222897.

## Recommended reading order

1. Existing investigation HANDOFF / findings.
2. 01_RUNNER/INDEX.md only when execution mechanics are relevant.
3. FrenchTaxesRules or Clienteling index for the investigated branch.
4. Prefer actual execution evidence:
   - TRX
   - execution XML
   - mstest / host logs
5. Consult Workflow when execution semantics need explanation.
6. Consult AutoTest/Data only for a specific testcase, request, expected output or fixture.

## Critical rule

A Legacy green result does not by itself prove a JMeter migration regression.

Before concluding, compare:
- testcase/scenario
- plugin branch and version
- Current/Fix
- input data
- environment
- request/payload
- assertion/expected result

Use FACT / INFERENCE / UNKNOWN.

## Raw collections

Primary:
C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897\investigations\ecarts-jmeter-migrations\evidence/legacy/raw/primary-package-extracted

Complement:
C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897\investigations\ecarts-jmeter-migrations\evidence/legacy/raw/missing-supplement
