---
type: evidence
title: WI-2222897 — audit de remplacement de ref V22
date: 2026-09-07
source_system: Azure DevOps REST and local handoffs
freshness: live read-only snapshot
---

# FACT

- Les handoffs récents prescrivent de ne pas supprimer l'ancienne ref avant la
  fin de l'investigation, mais Azure DevOps ne retourne désormais aucune ref
  `refs/heads/codex` dans Retail, notamment dans
  `Y2_Plugins_FrenchTaxesRules`. La ref historique
  `codex/wi-2222897-v22-preflight-20260907` est donc absente côté serveur.
- La cible neutre `sandbox/WI-2222897-v22-preflight-20260907` est également
  absente du dépôt ciblé. Aucune cible neutre prouvée n'est donc disponible;
  l'ancienne ref n'a pas été recréée.
- La définition `14246` reste enabled, nommée
  `WI-2222897 V22 Runtime Preflight 20260907`, sans run récent dans les 20
  derniers builds interrogés. Son repository est
  `Y2_Plugins_FrenchTaxesRules` et son `defaultBranch` conserve la valeur
  historique supprimée. La définition n'a pas été modifiée.
- Le SHA historique documenté par les handoffs est
  `5036e501ba797ab7efc861add60b111a40ff8141`; aucune réécriture d'historique,
  suppression de logs/builds, PR ou commit n'a été effectuée.

# Couverture du nommage partagé

La définition et les métadonnées de pipeline ont un nom neutre. Aucun PR,
run actif ou ref distante contenant `codex` n'est présent dans l'audit live.
Les mentions locales dans HANDOFF/STATUS/JOURNAL/RESOURCES et les collectes
antérieures sont des traces de provenance non modifiables sans effacer
l'historique; elles n'ont pas été touchées. Les YAML locaux contenant ce texte
sont des snapshots/artefacts d'investigation, pas des entités partagées à
réécrire.

# Verdict et blocage

`FACT`: supprimer la mention résiduelle du `defaultBranch` demanderait une
mutation de la définition 14246. `UNKNOWN`: quelle branche neutre doit la
remplacer, puisque la candidate indiquée est absente et que pointer vers
`master` serait un changement de comportement non autorisé. La correction
reste volontairement non exécutée; le renseignement exact requis est une ref
neutre existante (ou l'instruction explicite de recréer celle-ci au SHA
`5036e501...`).

Fichiers : `branch-ref-audit.json`, `branch-ref-audit-french.json`,
`neutral-ref-audit.json`, `pipeline-14246-audit.json`, `SHA256SUMS.txt`.
Les réponses REST ne contiennent aucun secret.
