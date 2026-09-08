---
type: evidence
title: SQL Full-Text build 4442156 — suivi terminal partiel
date: 2026-09-07
source_system: Azure DevOps REST read-only
freshness: live snapshot 2026-09-07
---

# FACT

- Build `4442156`, definition `14251`, branch
  `sandbox/WI-2222897-sql-fulltext`, source `0baf69c1...`, est encore
  `inProgress` au dernier contrôle; aucun nouveau run n'a été lancé.
- La timeline prouve SQL2019 terminé `failed` et SQL2025 encore `inProgress`.
  Checkout passe; publication d'artefact est skipped/pending.
- Le log SQL2019 montre l'image construite avec `/FEATURES=SQLENGINE,FullText`,
  puis l'échec réel `Full-Text population did not finish: [1]` après 90 secondes;
  `CONTAINSTABLE` n'est pas atteint. Ce n'est pas un échec de compilation du
  probe ni une simple erreur de parsing.
- Aucun ERRORLOG/DMV/fragment exploitable n'est encore disponible pour
  SQL2019 dans le log de tâche filtré, et SQL2025 n'a pas encore terminé; la
  cause de population bloquée n'est donc pas identifiée.

# INFERENCE / UNKNOWN

`INFERENCE`: l'installation Full-Text semble franchir le contrôle de présence,
mais le statut `[1]` prouve seulement une population non terminée au timeout.
`UNKNOWN`: service/processus, état catalogue/table, `dm_fts_index_population`,
fragments et ERRORLOG comparés entre SQL2019/2025; aucun changement correctif
ne peut être justifié avant le terminal et ces diagnostics.

Suite : suivre 4442156 jusqu'au terminal, puis lire uniquement les diagnostics
filtrés et classer la première cause; ne pas augmenter le timeout ni lancer un
nouveau run tant que cette preuve n'est pas complète.
