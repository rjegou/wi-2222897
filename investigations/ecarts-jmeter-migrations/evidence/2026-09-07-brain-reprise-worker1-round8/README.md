---
type: evidence
title: InventoryTracking 4440884 — JTL inventory and extraction boundary
date: 2026-09-07
freshness: one read-only artifact retrieval during this collection
---

# Résultat

Build `4440884`, définition `2072`, commit plugin
`ef3d87034d38b88aca04c824061b140e2a29252c`. Aucun pipeline, queue, publication,
SQL ou HTTP métier n'a été appelé. Les deux artefacts `v26-Fix_WebServices_TestLogs`
et `v26-Cur_WebServices_TestLogs` ont été lus via requests avec TLS vérifié
(plusieurs passes techniques ont été nécessaires pour isoler l'inventaire puis
l'en-tête); aucune archive n'a été conservée. Les archives et payloads ont été
supprimés du staging temporaire après inventaire.

## FACT

- Chaque artefact contient un ZIP imbriqué et 33 fichiers de données : 32 JTL
  par plan et un CSV `*-errors.csv`. `jtl-inner-file-inventory.txt` établit
  les 32 chemins JTL pour Cur et Fix et `download-manifest.txt` les empreintes
  des deux ZIP extérieurs téléchargés.
- Le CSV d'erreurs expose les colonnes `TestPlan`, `TestCase`, `Operation`,
  `OpError`, `XmlResError`, `JmxQuery`, `JmxPayload`. Les deux dernières colonnes
  sont volontairement exclues de toute conservation : elles peuvent contenir
  du contenu métier ou des informations sensibles. La structure est conservée
  dans `jtl-error-csv-structure.txt`, sans ligne de payload.
- L'inventaire local du commit exact contient 32 JMX et `Tests/WebServices.xml`
  référence exactement les mêmes 32 noms (`plan-list-diff.txt` vide). Le JMX
  `001-DashBoard_GetDetail2.jmx` contient `TC 04 - A-PreQuery3` avec la requête
  `select count(*) from LISTEINVENT where gie_etablissement = '6302' and
  gie_codeliste = '6302160509000001' and GIE_NBLIGNE = 44`.
- La source legacy historique au commit `f192139aa9b8a0c7f26350b73695d9f0b24b56c2`
  contient le `TestCase Code="04"` correspondant et les contrôles LISTEINVENT;
  le fichier n'est plus dans l'arbre `ef3d8703` après déréférencement.

## Limite rencontrée

La première lecture CSV naïve a rencontré des retours à la ligne dans des
champs non quotés (`_csv.Error: new-line character seen in unquoted field`).
Une lecture avec le séparateur `;` a confirmé l'en-tête et les fichiers, mais
les lignes contiennent les champs `JmxPayload`; elles n'ont donc pas été
conservées ni affichées. Il n'existe pas encore dans cette collecte de jointure
fiable par `TestPlan/TestCase/Operation` ni de comptage de clés uniques Cur/Fix.
Le candidat `001-DashBoard_GetDetail2/TC04` reste donc INFERENCE pour la
première occurrence SQL, malgré la preuve structurelle JMX/source.

## Verdicts et suite

- `FACT` : les JTL détaillés sont disponibles dans les artefacts et leur
  inventaire est prouvé; les résultats historiques donnent 141 messages SQL
  et 123 différences XML par variante.
- `UNKNOWN` : cas uniques, jointure Cur/Fix, cascades et premier échantillon
  exact, faute d'un parseur sûr ignorant les colonnes payload tout en gérant le
  format CSV effectivement produit.
- Action locale suivante : parser en streaming avec séparateur `;`, projection
  stricte des cinq colonnes non sensibles (`TestPlan`, `TestCase`, `Operation`,
  `OpError`, `XmlResError`) et validation du nombre de colonnes avant émission;
  ne jamais écrire `JmxQuery` ou `JmxPayload`. Puis comparer les clés Cur/Fix
  et rattacher uniquement les signatures présentes.

Les fonctions générateur `FixSqlQuery`, `EscapeJdbcDate` et
`FixSqlUnicodeValue` ont été inspectées précédemment; aucune reproduction
locale SQL ou attribution causale supplémentaire n'est revendiquée ici.
