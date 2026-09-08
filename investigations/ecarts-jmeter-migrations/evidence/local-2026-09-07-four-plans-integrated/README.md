# Quatre plans legacy — génération Console intégrée

Date : 2026-09-07. Staging temporaire court autorisé : `C:\Users\jegour\AppData\Local\Temp\wi2222897-r8-40d79ec7`. Sources indexées : plans legacy master Clienteling `Mobility_UpdateMobileParameters.xml`, `Mobility_GetMobileParameters.xml`, `ItemSearch_GetItemsFacets.xml`, `ItemSearch_GetItems.xml`; entrées/sorties correspondantes recopiées sans modification. Aucun métier exécuté.

## FACT

Console officielle originale et corrigée ont produit 4/4 JMX, code 0, depuis les mêmes XML. Hashes original/corrigé : 001 `4C814F...`/`A9A555...`, 002 `44BF05...`/`362EE7...`, 003 `183692...`/`C27CFE...`, 004 `9BC105...`/`FA2154...`.

Parsing XML : 682 requêtes SQL et 185 assertions XPath par variante. Les SQL contenant XML interne sont échappés dans la variante corrigée (`&lt;...&gt;`) et non double-échappés après parsing; les Fault émis passent de `//faultcode`/`//fault` à `//Fault/...` dans la variante corrigée. Les XPath `//Fault`, `//Fault/faultcode` et descendants sont syntaxiquement parseables; l’évaluation sur réponses SOAP réelles n’est pas exécutée (aucun HTTP).

La dernière DLL corrigée contient les quatre transformations et a été compilée code 0; tests publics : CleanXpath 6, Unicode 9, RemoveSpecialChars 4 PASS.

## LIMITES

Cette génération prouve Console→JMX local, pas migration→JMX ni rejeu métier. Les tests de sélection XPath avec la configuration JMeter effectivement générée restent limités au parsing et aux chemins émis; aucun moteur JMeter n’a été lancé. SQL Full-Text, PlatformDeploy, isolation SQL/IIS et acquisitions restent UNKNOWN.
