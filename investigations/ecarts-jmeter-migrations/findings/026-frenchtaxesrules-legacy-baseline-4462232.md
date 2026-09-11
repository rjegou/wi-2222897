# Finding 026 — FrenchTaxesRules master : baseline Legacy 10.95 / build 4462232

**Date d'intégration : 2026-09-11** · **Statut : preuve locale vérifiée**

## Conclusion bornée

- **FACT** — l'archive locale concerne `Y2_Plugins_FrenchTaxesRules`, branche `master`, plugin `10.95`, build Azure DevOps `4462232`, sur `Y2-TSTAUTOXXPG2`.
- **FACT** — le workflow trace Fix puis Current, la sélection d'Identity `26.0.7.221`, l'exécution MSTest et la génération des TRX.
- **FACT** — Fix et Current ont chacun 274 tests exécutés selon le compteur TRX ; les résultats élémentaires sont 253 par campagne.
- **FACT** — Fix contient 1 échec élémentaire (`Test_22`) ; Current contient 44 échecs élémentaires.
- **FACT** — les fichiers bruts et leurs SHA-256 sont conservés dans [la preuve locale](../evidence/legacy/Y2_Plugins_FrenchTaxesRules/master/10.95-build-4462232/README.md).
- **UNKNOWN** — la comparabilité cas à cas avec une campagne JMeter n'est pas démontrée par cette archive seule : contrats, paramètres, données, versions complètes et environnement de comparaison doivent être alignés.

Cette archive devient la baseline Legacy locale de référence pour `FrenchTaxesRules/master`.
Elle ne transforme pas automatiquement les résultats JMeter antérieurs en régression : les
cas communs et les conditions d'exécution devront être comparés explicitement.
