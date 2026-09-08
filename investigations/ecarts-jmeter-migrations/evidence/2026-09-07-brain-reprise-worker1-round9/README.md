---
type: evidence
title: InventoryTracking 4440884 — direct JTL projection
date: 2026-09-07
freshness: collected read-only 2026-09-07
---

# FACT

- Les 64 fichiers JTL (32 Cur, 32 Fix) des artefacts WebServices ont été lus
  directement en mémoire; aucun payload, `JmxQuery` ou secret n'a été écrit.
- Chaque variante contient 13 501 lignes JTL et 13 501 clés uniques sur
  `(plan,label,success,signature)`. Le fichier de projection conserve seulement
  `plan`, `label`, `success`, `signature`.
- Le champ `failureMessage` des JTL ne porte pas les textes SQL/XML; les
  signatures sont donc vides dans la projection. Les assertions sont toutefois
  visibles par `success=false`.
- Le premier échec JTL Cur et Fix est `002-Device_Reassign /
  002-Device:Reassign - TC 105 - A-PreQuery3`, `success=false`, et non le
  candidat précédent `001-DashBoard_GetDetail2/TC04`. Cette localisation est
  désormais FACT au niveau JTL.
- Le JMX exact local au commit `ef3d87034d38b88aca04c824061b140e2a29252c`
  contient cette étape avec la requête structurelle suivante (payload XML
  volontairement remplacé) : `update MMOBILEINV set MOI_APPDATA =
  <PAYLOAD_REDACTED> where MOI_CODEMOBILE = 'REFER0001' SELECT @@ROWCOUNT`.
  Le JMX est XML-valide et le hash SHA-256 est dans `jmx-first-failure.txt`.
- Cur/Fix sont identiques sur ce premier échec. Une différence discriminante
  est prouvée pour `002-Device_Reassign / TC122`: Cur échoue sur B-XQuery,
  C-PostQuery1 et C-PostQuery2, alors que Fix réussit ces trois clés; les
  projections et le diff sont conservés dans `cur-fix-key-diff.txt`.

# Source historique et générateur

La source legacy `DashBoard_GetDetail2.xml` au commit historique
`f192139aa9b8a0c7f26350b73695d9f0b24b56c2` confirme séparément le TC04
LISTEINVENT/GIE_NBLIGNE=44; elle ne correspond donc pas au premier échec JTL
désormais localisé en TC105. La source de TC105 n'est pas présente dans l'arbre
exact `ef3d8703` après déréférencement.

La requête TC105 montre `N'...'` avant le payload, cohérent avec
`FixSqlUnicodeValue`; le payload a été masqué et aucune attribution causale au
générateur n'est faite. La correction package existante n'a pas été reconstruite
ni créditée : cette collecte ne lance aucun SQL métier.

# INFERENCE / UNKNOWN

- `INFERENCE` : les trois succès Fix de TC122 constituent un signal de
  différence Cur/Fix potentiellement discriminant, mais ne prouvent pas une
  résolution métier sans réponse HTTP comparable.
- `UNKNOWN` : la signature SQL exacte du TC105, car elle n'est pas dans le JTL
  (`failureMessage` vide); le CSV errors associe cette information à des champs
  payload et nécessite un parseur CSV borné séparant strictement les colonnes.
- `UNKNOWN` : cascades globales et comparaison legacy; aucune régression legacy
  n'est revendiquée.

Fichiers : `parse_jtl.py`, `Cur-jtl-projection.tsv`, `Fix-jtl-projection.tsv`,
`cur-fix-key-diff.txt`, `jtl-direct-summary.txt`, `jmx-first-failure.txt` et
`SHA256SUMS.txt`.
