# Legacy TestAuto evidence — LLM entry point

Purpose: evidence for WI-2222897 JMeter migration investigations.

## Recommended reading order

1. Runner-Legacy.md
2. FrenchTaxesRules_master.md
3. Clienteling_master.md
4. Relevant release branch index only when needed
5. AutoTest/Data fixtures only for a specific investigated testcase

## Important evidence

FrenchTaxesRules master/V26:
- real Legacy execution reports exist
- published TRX exists
- workflow and AutoTest sources are available

Clienteling master/V26:
- real Legacy execution reports exist
- published TRX exists
- workflow and AutoTest sources are available

## Evidence rule

Do not infer a migration regression merely because Legacy is green and JMeter is red.

Establish comparability of:
- plugin/version
- branch
- testcase/scenario
- Current vs Fix
- data/environment
- request/payload/assertion

Classify conclusions as FACT / INFERENCE / UNKNOWN.

## Raw evidence

All original collected files remain under ../files.

MANIFEST.csv maps each original VM path to its collected path.
SHA256SUMS.txt preserves evidence integrity.
