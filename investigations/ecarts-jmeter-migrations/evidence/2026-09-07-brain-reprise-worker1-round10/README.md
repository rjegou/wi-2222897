---
type: evidence
title: InventoryTracking 4440884 — CSV errors producer and causal join
date: 2026-09-07
freshness: read-only artifact retrieval and local source inspection
---

# FACT

- Le producteur réel est `PipelineTemplates/task-run-campaign.v1.yml`, fonction
  `New-ReportErrorCsv`. Il lit le JUnit XML associé au JTL, sélectionne les
  `testcase.error`, extrait `TestPlan`, `TestCase`, `Operation`, puis remplit
  `OpError` et `XmlResError`. Il ajoute aussi `JmxQuery` et `JmxPayload` ; ces
  deux colonnes n'ont jamais été conservées dans cette collecte.
- Le format réel est CSV UTF-8, séparateur `;`, avec champs potentiellement
  multilignes. Le parseur borné en mémoire a ignoré toute ligne ambiguë
  (`None`/colonnes supplémentaires) et n'a émis que les quatre champs
  `TestPlan/TestCase/Operation/signature`, signature dérivée d'OpError ou
  XmlResError.
- La projection JTL directe contient 13 781 lignes Cur et 13 782 Fix. La
  projection errors contient 339 clés Cur et 340 Fix, chaque clé étant
  `(TestPlan, TestCase, Operation, signature)`; aucune valeur `success` n'est
  utilisée dans l'identité errors.
- Le premier SQL est maintenant raccordé :
  `002-Device:Reassign / TC 105 / A-PreQuery3 / SQLIncorrectSyntax`, présent
  Cur et Fix. Le JTL correspondant est `002-Device_Reassign/...results.jtl`.
  La requête JMX locale au commit `ef3d87034d38b88aca04c824061b140e2a29252c`
  est documentée sous forme structurelle avec payload redacted dans
  `jmx-first-failure.txt`.
- Le différentiel errors contient une clé Cur-only : `002-Device:Reassign /
  TC 122 / B-XQuery / Other`. Cela rejoint le JTL : Cur `success=false`, Fix
  `success=true` pour TC122 B-XQuery (les deux postqueries associées sont
  également Cur false / Fix true dans la projection JTL).

# INFERENCE / UNKNOWN

- `INFERENCE` : TC122 est un signal Fix discriminant, mais sans réponse HTTP
  ou payload il ne prouve pas à lui seul une résolution métier.
- `UNKNOWN` : la cause SQL de TC105. Le CSV prouve la signature d'erreur et le
  plan/TC/opération, mais son `JmxPayload` a été exclu; aucun SQL métier n'a
  été exécuté. La forme JMX montre seulement une mise à jour Unicode avec
  payload XML et `SELECT @@ROWCOUNT`.
- `UNKNOWN` : séparation complète des cascades et comparaison legacy. Les
  JTL fournissent des statuts, tandis que les erreurs agrégées ne suffisent
  pas à prouver la causalité temporelle entre samplers.

Fichiers : projections Cur/Fix, `producer-relevant-lines.txt`,
`jmx-first-failure.txt`, `SHA256SUMS.txt`. Aucun fichier canonique partagé,
pipeline, queue, publication, SQL ou HTTP métier n'a été modifié ou exécuté.
