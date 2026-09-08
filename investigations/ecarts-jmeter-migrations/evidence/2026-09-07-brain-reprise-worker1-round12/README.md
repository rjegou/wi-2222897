---
type: evidence
title: WI-2222897 — audit de nommage partagé codex
date: 2026-09-07
source_system: Azure DevOps REST read-only
freshness: live read-only snapshot
---

# FACT

- La recherche REST des refs `refs/heads/codex` dans les dépôts Retail ne
  retourne aucune ref. La recherche ciblée dans `Y2_Plugins_FrenchTaxesRules`
  retourne également `value=[]`. La branche signalée
  `codex/wi-2222897-v22-preflight-20260907` est donc déjà supprimée côté
  serveur; aucun renommage Git (création/suppression) ne peut être effectué
  sans recréer une ref.
- La définition Azure DevOps `14246`, nom neutre
  `WI-2222897 V22 Runtime Preflight 20260907`, existe et est `enabled`, mais
  son repository defaultBranch pointe encore vers
  `refs/heads/codex/wi-2222897-v22-preflight-20260907`. Le dépôt est
  `Y2_Plugins_FrenchTaxesRules`, id `1d6b05fb-70bc-4884-adba-46d9e96651d8`.
- Les 20 derniers builds de la définition 14246 sont absents (`runs=[]`), donc
  aucun run actif ou dépendance d’exécution n’a été détecté. Aucun PR associé
  n’a pu être trouvé, la ref source étant absente.
- La preuve locale antérieure rattache cette ref au SHA
  `5036e501ba797ab7efc861add60b111a40ff8141`; ce SHA n’a pas été réécrit ni
  supprimé. Les logs/builds historiques ne sont pas modifiés.
- La ref candidate neutre `refs/heads/sandbox/WI-2222897-v22-preflight-20260907`
  n’existe pas non plus dans le dépôt ciblé. Elle est donc libre comme nom,
  mais pas encore une cible valide de defaultBranch.

# Audit des éléments partagés

Le pipeline/definition porte un nom sans `codex`. Le seul résidu partagé
directement prouvé est `repository.defaultBranch` dans la définition 14246.
Les YAML locaux et preuves contiennent le mot `codex` comme historique; ils ne
sont pas des entités Azure mutables à nettoyer et n’ont pas été supprimés.
Aucun commit, PR, run ou ref distant n’a été créé/modifié.

# INFERENCE / UNKNOWN

- `INFERENCE` : la branche a probablement été supprimée par une action
  antérieure, car la définition conserve sa valeur historique mais le serveur
  ne renvoie plus la ref.
- `UNKNOWN` : propriétaire opérationnel à autoriser pour corriger la
  définition 14246. Le handoff canonique indique qu’une autre instance traite
  déjà FrenchTaxesRules V22; modifier son defaultBranch sans cible existante
  pourrait casser sa reprise.

# Blocage précis et prochaine action

Créer `sandbox/WI-2222897-v22-preflight-20260907` au SHA exact
`5036e501...`, puis mettre à jour le defaultBranch 14246, est techniquement
possible mais constitue une recréation et une mutation d’une investigation
appartenant à l’autre instance. Il faut l’accord explicite de ce propriétaire
ou du BRAIN, ainsi que confirmation que ce SHA est toujours la cible voulue.
Je n’ai donc pas créé la ref et n’ai pas modifié la définition.

Fichiers bruts : `codex-ref-audit.json`, `french-codex-ref-audit.json`,
`neutral-ref-audit.json`, `pipeline-14246-audit.json`. Aucun secret n’est
présent; les valeurs de token ont été utilisées uniquement en mémoire.
