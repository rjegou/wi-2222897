---
type: "Preuve"
title: "Synthèse technique FrenchTaxesRules V26 — run 4452790 et correctifs rapportés"
description: "Provenance et extraction bornée d'un compte rendu reçu le 2026-09-09."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-frenchtaxesrules-v26-synthese-technique/README.md"
tags: ["jmeter", "frenchtaxesrules", "docker", "cy2px", "preuve"]
timestamp: "2026-09-09"
source_system: "local-kb"
---

# Synthèse technique FrenchTaxesRules V26 — 2026-09-09

## Provenance et fraîcheur

- **Source reçue** : `C:\Users\jegour\Downloads\WI-2222897_FrenchTaxesRules_V26_synthese_technique_2026-09-09.md`.
- **Empreinte SHA-256** : `28D1332375F964903C85B7FA184D2353B529A7098D8DF1624143531DA5DC3C5C`.
- **Taille** : `11 921` octets.
- **Méthode** : lecture locale du fichier source et extraction documentaire ciblée le 2026-09-09 ; le fichier original n'a pas été modifié.
- **Fraîcheur** : `rapporté, non revérifié`. Aucun build, commit, push ou résultat Azure DevOps n'a été relu directement dans ce processus.

## Éléments intégrés

- Le document rapporte une validation locale `48/48` des faux échecs du générateur JMX : `16/16` cas HTTP et `32/32` cas SOAP Fault, avec compilation API annoncée réussie.
- Il rapporte une migration V26 à `19` JMX (`10` LegacyServices et `9` WebServices), et un patch de deux tags Docker dans le YAML du plugin.
- Il rapporte les tags fonctionnels suivants : V26 `sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025` ; V22-V25 `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`.
- Il rapporte des tests de frontière de `Step_04_modifYml.py` pour V21, V25, V26 et V21+V25, ainsi qu'un défaut d'idempotence lors d'une seconde exécution sur un YAML déjà migré.
- Il rapporte que le build `4452567` s'est arrêté avant JMeter sur l'image Docker absente/manifest 404, puis que `4452790` a dépassé ce point mais s'est arrêté avant JMeter dans `Configure cy2px files`, faute de fichier `*.cy2px`.

## Limite

Cette extraction ne remplace pas les preuves brutes Azure DevOps ni une lecture des commits cités. Les comptes `48/48`, les tags, le commit `bd3688e4…`, le push annoncé et les états `4452567`/`4452790` restent donc rapportés jusqu'à revérification indépendante.
