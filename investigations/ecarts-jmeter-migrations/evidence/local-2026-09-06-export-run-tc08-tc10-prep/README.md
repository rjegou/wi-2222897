# Préparation Export_Run TC08–TC10 — 2026-09-06

## FACT

- Source legacy : `worktrees/Y2_Plugins_FrenchTaxesRules/IntegratedTests/AutoTest/Data/LegacyServices/TestPlans/Export_Run.xml`.
- Provenance : dépôt local `Y2_Plugins_FrenchTaxesRules`, branche `master`, HEAD `07a42172bebc65d17093e166ac08de22e4fe7248`, état Git propre au contrôle.
- Plan source SHA-256 : `A3F64788FCBCB1C1157DEBBCC233EABE9EA82A132A220182EE4A4999974373A4`.
- Campagne source : `.../Data/LegacyServices/LegacyServices.xml`, SHA-256 `7E0DDE51044559EB3D7F620386750519FBB8B21866702478432ADE7F6FCC0307`.
- La campagne source référence plusieurs plans. La copie d'essai utilise `fixtures/Export_Run.xml`, descripteur nouveau qui ne référence que le plan complet `TestPlans/Export_Run.xml`.

## Copie isolée

Racine : `C:\temp\rje-wi2222897-export-20260906-173737\`.
Le plan complet est conservé. Les entrées sont sous `fixtures\TestPlans\InputFiles\Export\` et les graines attendues sous `seed\IntegratedTests\AutoTest\Data\Export_Run\TestPlans\OutputFiles\Export\`, conformément aux chemins observés dans `JmeterGenerator`.

TC08 utilise `Run_08.xml` et les prérequêtes portent les dates `2016-01-03` et `2015-12-01`. TC09 utilise `Run_09.xml` et les dates `2016-03-03` et `2016-02-01`. TC10 utilise `Run_10.xml` et ne contient pas de date de prérequête. Les autres valeurs SQL ne sont pas recopiées dans cette preuve.

## Limites

Aucune génération, Console, JMeter, SQL, HTTP ou réseau n'a été exécuté. Aucun JMX n'est présent : la source legacy et le JMX futur restent distincts. Aucun fichier requis parmi les sept copies n'est manquant ; le runtime Console/API n'est volontairement pas copié ici. Les empreintes source→copie sont dans `manifest.tsv`.
