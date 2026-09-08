LEGACY TESTAUTO EVIDENCE PACKAGE
================================
Created: 2026-09-06 07:18:43
Machine: Y2-TSTAUTOXXPG2
User: CEGIDGROUP\SvcTestAutoRetail
Purpose
-------
Read-only evidence collected from Y2-TSTAUTOXXPG2 to investigate
Legacy TestAuto vs JMeter migration differences.
Target scope
------------
FrenchTaxesRules:
- master / V26
- V7 / V25
- V5 / V21-V23
Clienteling:
- master / V26
- V8 / V25
- V7 / V24
- V6 / V21-V23
Included
--------
- Legacy runner logs and configuration
- AppData execution XML/log/html outputs
- IntegratedTests/Workflow
- IntegratedTests/AutoTest/Data including InputFiles/OutputFiles
- PublishTRX scripts/configuration
- Published XML/TXT/LOG/TRX evidence for target families
- MANIFEST.csv
- SHA256SUMS.txt
Intentionally excluded
----------------------
- generated *.report rendering trees
- ReportHistory coverage history
- bulk HTM/JS/CSS/SVG rendering assets
- unrelated historical plugins and legacy versions
Important
---------
This package is evidence only.
Do not infer environment equivalence solely from a green Legacy result.
Compare plugin version, branch, scenario, configuration, backup and packages.
