# Handoff V26 — JMX générés avec Console 4445025

Transmission immédiate au responsable V26.

FACT : package Console `2.0.43-wi2222897-console-candidate`, build `4445025`, commit
`dfda5e52e637e423432023d9fb6b870e92104703`, nupkg SHA-256
`796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`. DLL API embarquée
`A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.

JMX prioritaires récupérables :

- `generated-jmx/Export_Run/001-Export_Run.jmx` — SHA-256
  `C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C`.
- `generated-jmx/DocumentSignature_SignOne/001-DocumentSignature_SignOne.jmx` — SHA-256
  `432AA8C477E875652D4A4991D84DB19DB0B3790469EB2DE81212F85F0F341AE9`.

Les deux ont été générés par le binaire du package candidate, code retour `0`. Ils n'ont pas été
exécutés par JMeter et ne prouvent pas un résultat métier. Utiliser les fichiers depuis ce dossier,
ne pas reprendre le package historique 2.0.42.

Limite : la collecte complète du commit source produit 19 JMX, alors que le manifeste exige 32;
voir `manifest-32-attempt.log.txt` et `README.md`. Les 13 plans manquants restent UNKNOWN.
