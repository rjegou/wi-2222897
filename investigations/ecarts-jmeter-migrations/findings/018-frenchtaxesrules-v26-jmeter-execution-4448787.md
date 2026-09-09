# Finding 018 — FrenchTaxesRules V26 : exécution JMeter réelle rapportée (build 4448787), 253 tests Cur/Fix, 51 échecs communs

## Périmètre et provenance

- **Système** : Azure DevOps `cegid/Retail`, définition `FrenchTaxesRules CI` (`2054`), branche de
  validation FrenchTaxesRules V26.
- **Source** : document reçu dans `Downloads` le 2026-09-09
  (`2026-09-09-lecons-apprises-ftr-v26-jmeter.md`), copié sans modification dans
  [evidence/local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/](../evidence/local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/README.md).
- **Statut de fraîcheur** : `rapporté, non revérifié`. Aucune lecture directe d'Azure DevOps n'a été
  faite dans ce processus pour confirmer le build `4448787`, ses runs de test ou les hashes cités.
  Cette fiche documente ce qui est rapporté ; elle ne constitue pas une revérification indépendante.

## Conclusion bornée

**Rapporté, non revérifié** — la séquence de diagnostic sur la branche de validation FrenchTaxesRules
V26 a abouti à une exécution réelle des campagnes JMeter Cur et Fix :

1. **Cause du blocage `Launch Y2 deployment` levée sans republier sur un feed partagé** : le paquet
   `Y2.Plugin.FrenchTaxesRules` a été transporté vers le déploiement conteneurisé via un sous-dossier
   dédié (`$(Pipeline.Workspace)\frenchtaxesrules-local-package`) contenant exactement les 4 fichiers
   décrits par le manifest, distinct de l'artifact `_Software` complet (12 fichiers MSI/XML). Ce
   mécanisme est un raffinement du transport `PipelineArtifact` déjà validé sur InventoryTracking
   ([finding 017](017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md)), pas une
   republication partagée. Provenance déclarée conservée : `sourceBuildId`, `artifactName`,
   `packageVersion`, hash SHA-256 et taille par fichier.
2. **Incident `Move-Item Access denied` (build `4447926`) qualifié transitoire, pas corrigé en dur** :
   un rejeu identique (même agent `vm-alm-agent-02-A`, même compte `tfsbuild`, même package
   `FWK-CEGID-NET-FULL.12.9.193`) a réussi. `Move-Item` n'a pas été remplacé par `Copy-Item` sans
   preuve de cause.
3. **Build final `4448787`, `partiallySucceeded`** :
   - JMeter Cur : **253 tests exécutés**.
   - JMeter Fix : **253 tests exécutés**.
   - Couverture quantitative alignée avec la baseline historique (`4432510`/`4432288`, 253 tests par
     variante — voir [matrice legacy](../cases/LEGACY_COMPARISON_MATRIX.md) et
     [STATUS_MATRIX.md](../cases/STATUS_MATRIX.md)).
   - **51 échecs par variante, strictement identiques nom pour nom entre Cur et Fix** — signal fort
     d'une cause commune (scénario, données, environnement, JMX ou comportement produit partagé),
     pas d'un défaut spécifique au packaging Fix.
   - Les cas discriminants historiquement surveillés — `Export_Run` TC08/09/10 et
     `DocumentSignature_SignOne` TC02 — ne figurent pas dans la liste des 51 échecs.

## Ce que cette fiche résout et ce qui reste ouvert

- Résout partiellement l'`UNKNOWN` de la [fiche 017](017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md#actions-non-effectuées-et-limites-unknown)
  (« résultats effectifs des 19 JMX de FrenchTaxesRules sous JMeter... tant que le package MSI n'est
  pas transporté localement dans le conteneur ») — sous réserve de revérification indépendante de
  `4448787`.
- `UNKNOWN` — regroupement causal des 51 échecs communs par cause réelle (accès REST aux résultats
  détaillés) ; c'est l'étape suivante indiquée par le document source, pas encore faite.
- `UNKNOWN` — identité exacte des 51 cas (liste nominative), correspondance avec les causes déjà
  prouvées du générateur JMX (105 cas, [décision 5](../../../decisions/README.md#5-autorise-t-on-la-republication-de-la-chaîne-api--console--outil-de-migration)),
  et avec les 174 refus V22 ([décision 2](../../../decisions/README.md#2-la-pile-frenchtaxesrules-v22-fix-reste-t-elle-supportée)) — ces
  périmètres sont distincts (V26 vs V22) et ne doivent pas être fusionnés sans preuve.
- `UNKNOWN` — le mécanisme `localPackageRoot` décrit n'a pas été relu dans le YAML de la branche de
  validation par cette session ; son commit exact et son caractère réellement isolé (pas de
  modification de `Pipelines_Templates`) restent à vérifier avant d'en généraliser l'usage à
  Clienteling ou InventoryTracking.

## Actions non effectuées dans ce processus

Aucune lecture Azure DevOps, aucune relance de build, aucune modification de pipeline ou de code n'a
été faite pour produire ou vérifier cette fiche : elle intègre un document reçu, sans plus.
