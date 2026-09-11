---
type: "Preuve"
title: "Synthèse technique FrenchTaxesRules V22/V23 — validation de packaging et blocage V23"
description: "Copie immuable d'un compte rendu reçu le 2026-09-10 ; les observations distantes restent rapportées."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-10-frenchtaxesrules-v22-v23-validation/README.md"
tags: ["jmeter", "frenchtaxesrules", "v22", "v23", "preuve"]
timestamp: "2026-09-10"
source_system: "local-kb"
---

# Synthèse technique FrenchTaxesRules V22/V23

## Provenance et fraîcheur

- **Source reçue** : `C:\Users\jegour\Downloads\WI-2222897_synthese_technique_2026-09-10.md`.
- **Copie conservée** : [`WI-2222897_synthese_technique_2026-09-10.md`](WI-2222897_synthese_technique_2026-09-10.md).
- **Empreinte SHA-256 source et copie** : `AEB9459F53E28B038DFB3F6B507E376E2C3055BC13D3F30F623584D7CFC70B3E`.
- **Taille** : `10 691` octets.
- **Méthode** : lecture et copie locale le 2026-09-10 ; aucun système distant n'a été relu pendant ce rangement.
- **Fraîcheur** : `rapporté, non revérifié`. Les runs, branches, commits, versions et causes restent des déclarations de la source.

## Éléments retenus

Le compte rendu porte sur FrenchTaxesRules V22/V23, la validation du packaging `22.0.23`, la
publication JFrog Staging nécessaire au test et l'isolation des effets ACR/Promote/Tag. Il rapporte
un V22 Cur/Fix vert dans le run `4453591`, puis un blocage V23 Fix avant JMeter dans `Test Y2 deployment`.

## Limites

Cette preuve ne confirme pas indépendamment les identifiants Azure DevOps, les refs, les commits,
les résultats métier ni les publications. Elle ne permet pas de retenir une version minimale
individuelle parmi Core/Common/Identity, ni de conclure sur V23 Fix tant que le run discriminant
Identity seul n'est pas relu directement.
