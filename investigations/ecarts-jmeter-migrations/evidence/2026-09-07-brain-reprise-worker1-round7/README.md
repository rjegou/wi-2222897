---
type: evidence
title: InventoryTracking 4440884 — signatures SQL/XML and plan mapping
date: 2026-09-07
source_system: Azure DevOps build logs plus exact local source checkout
freshness: collected 2026-09-07; build 4440884 is historical and not rerun
---

# Portée

Collecte read-only ciblée du build `4440884` (`7.76`, définition `2072`, dépôt
`Y2_Plugins_InventoryTracking`, branche
`refs/heads/validation/WI-2222897-inventorytracking-xmldiff`, commit
`ef3d87034d38b88aca04c824061b140e2a29252c`). Aucun pipeline, SQL, HTTP métier,
publication ou queue n'a été appelé. Les artefacts JTL bruts n'ont pas été
retéléchargés : ils ne sont pas présents dans le workspace et les logs de
contrôle conservés sont les seules preuves disponibles pour cette collecte.

# Faits établis

- `log-51.json` (collecte round6) montre une compilation réussie (`0 Error(s)`)
  avec les références XmlDiff/XMLDiffPatch; `log-52.json` montre `48/48` tests
  VSTest passés. Le défaut XmlDiff de la campagne précédente est donc résolu
  pour ce build.
- `log-161.json` (Cur) et `log-162.json` (Fix) montrent chacun 32 plans lancés
  et terminés. `generated-jmx-plan-list.txt` et
  `campaign-descriptor-plan-list.txt` contiennent chacun 32 entrées; leur
  comparaison est vide (`plan-list-diff.txt`), donc le descripteur
  `Tests/WebServices.xml` correspond effectivement aux 32 JMX locaux du commit
  exact.
- `log-168.json` (Cur) et `log-171.json` (Fix) rapportent chacun 141
  occurrences textuelles `SQLServerException: Incorrect syntax` et 123
  occurrences textuelles `differences were found`. Les deux variantes ont les
  mêmes signatures et volumes. Ce sont des occurrences de messages, pas des
  cas uniques; l'identité par échantillon/JTL n'est pas disponible ici.
- La première signature visible dans `log-168.json` est
  `A-PreQuery3`. L'ordre du premier plan du descripteur permet de localiser le
  premier candidat dans `001-DashBoard_GetDetail2.jmx`, `TC 04`, dont la
  requête générée est : `select count(*) from LISTEINVENT where
  gie_etablissement = '6302' and gie_codeliste = '6302160509000001' and
  GIE_NBLIGNE = 44`. Le log agrégé ne porte pas le couple plan/TC sur chaque
  ligne : le rattachement « premier candidat » est donc une INFERENCE, pas une
  preuve d'échantillon JTL exact.
- La source XML legacy correspondante est retrouvée dans l'historique local au
  commit `f192139aa9b8a0c7f26350b73695d9f0b24b56c2`, blob
  `a163100f78da53acf80115e043674afccbf6176f`. Le `TestCase Code="04"` y est
  `NC : StoreId 6302 avec plusieurs inventaires et documents`, et ses contrôles
  incluent la requête source `select count(*) from LISTEINVENT where
  gie_etablissement = '6302' and gie_validation != 'X'` ainsi que la requête
  `GIE_NBLIGNE = 44`. Le chemin XML legacy a été déréférencé avant le commit
  `ef3d8703` (parent `4de185bb`); il n'existe donc pas dans l'arbre exact du
  build. La provenance source est FACT historique, mais l'association directe
  à la ligne d'erreur reste UNKNOWN sans JTL détaillé.

# Générateur et causes discriminantes

`JmeterCodeGen.cs` du worktree de l'outil a été lu après contrôle Git; les
transformations sont séquencées dans `FixSqlQuery` : `LONGCHAR`, concaténation,
quotes, unicode, `now`, `EscapeJdbcDate`, fonctions date puis GUID. La source
contient bien les fonctions `EscapeJdbcDate` et `FixSqlUnicodeValue`; aucune
preuve ne montre que la requête `TC 04/A-PreQuery3` passe par une transformation
qui la rend syntaxiquement invalide. La requête générée locale est XML-valide
et conserve une syntaxe SQL simple. Il serait spéculatif de qualifier le
générateur de cause du défaut SQL sur la seule chaîne d'erreur agrégée.

La compilation et le déploiement étant passés, le premier défaut discriminant
observé est le contrôle de résultats post-exécution JMeter (Cur et Fix), pas
XmlDiff, le build ou la génération de plans. Les différences XML ne peuvent
pas être déclarées cascade des erreurs SQL : leur cardinalité textuelle est
distincte, mais le lien par échantillon n'est pas prouvé. Les préfixes de
catégories (`A-PreQuery*`, `B-XQuery`, etc.) ne doivent pas être comptés comme
cas uniques; ils contiennent plusieurs lignes et parfois des statuts.

# Comparabilité et suite

- Cur/Fix sont comparables au niveau campagne/plan : mêmes 32 noms et même
  descripteur. Le mapping par TC, nombre de cas uniques, requête effectivement
  exécutée, et séparation des cascades nécessitent une extraction non sensible
  de métadonnées JTL (label, success, assertion, plan/TC), sans réponse SOAP,
  paramètres ou secrets.
- Une reproduction locale du défaut SQL n'est pas déclarée : aucun moteur SQL
  métier n'a été appelé et la preuve disponible ne distingue pas syntaxe
  générée, moteur/environnement ou données. Le package corrigé existant ne
  peut donc pas être crédité d'une résolution de ce build sur cette collecte.
- Aucun appel de régression legacy n'est revendiqué; la comparabilité complète
  (scénario, données, version, environnement, résultat par cas) manque.

## Empreintes et fichiers produits

- JMX local exact au commit `ef3d8703`: SHA-256
  `55822279B24ACC8374B0D97B643734D69302BD268221B5846D8521D69D511E47`.
- Descripteur `Tests/WebServices.xml`: SHA-256
  `0F2F6654C719E6F44443DC63027F9BF4A0958ECDB3C77AD5D78E59B88D868B2E`.
- Source XML legacy historique `f192139a`: blob SHA-1
  `a163100f78da53acf80115e043674afccbf6176f`.
- Les logs causaux et leurs hashes sont dans
  `../2026-09-07-brain-reprise-worker1-round6/`; ils ne sont pas dupliqués.
