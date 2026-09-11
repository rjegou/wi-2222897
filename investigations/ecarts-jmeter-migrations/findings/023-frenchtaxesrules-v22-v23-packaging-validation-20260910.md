# Finding 023 — FrenchTaxesRules V22/V23 : validation de packaging rapportée et diagnostic Identity

## Périmètre et provenance

- **Périmètre rapporté** : `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V5`, puis
  validation des configurations V22/V23 Cur/Fix sur des branches `sandbox/*`.
- **Source** : [synthèse technique conservée](../evidence/local-2026-09-10-frenchtaxesrules-v22-v23-validation/README.md).
- **Statut** : `rapporté, non revérifié` ; aucune lecture Azure DevOps, JFrog ou dépôt distant n'a
  été effectuée lors de cette intégration.

## Conclusion bornée

**FACT documentaire** — le compte rendu rapporte que le trio V22 issu du packaging `22.0.23`
(`Y2.Core 22.0.0.2068`, `Y2.Core.Common 22.0.3.311`, `Y2.Plugin.Identity 22.0.6.117`) a été
appliqué en conservant AuthenticationServer `2.0.0.368` et le plugin FrenchTaxesRules de la
branche testée. Il rapporte ensuite V22 Cur et Fix verts dans le run `4453591`, avec toutes les
campagnes V22 jouées avec succès.

**INFERENCE bornée** — si le compte rendu est confirmé par lecture directe, cette combinaison
corrige le contrat V22 Fix qui présentait historiquement 174 refus d'autorisation (138
LegacyServices, 36 WebServices). Elle ne permet pas d'identifier le composant causal exact ni la
version minimale individuelle de Core, Common ou Identity.

**FACT documentaire** — le compte rendu rapporte un V23 Cur entièrement vert et un V23 Fix arrêté
avant JMeter dans `Test Y2 deployment`, avec `System.ArgumentException: The parameter
'sectionGroupName' is invalid` dans `IdentityServerConfiguration.ExtractAdditionalConfig`. Le
symptôme `PasswordNotValid / invalid_username_or_password` est rapporté comme secondaire.

**INFERENCE bornée** — puisque le plugin et AuthenticationServer sont rapportés identiques entre
Cur et Fix, et que la trace pointe Identity, le test `Y2.Plugin.Identity 23.0.5.243 -> 23.0.6.171`
seul est un test discriminant pertinent avant l'alignement de Core/Common. Il ne prouve pas la
cause tant que son résultat n'est pas observé.

## Pipeline et effets externes

**FACT documentaire** — le compte rendu rapporte que l'absence du plugin `22.0.6.482` dans
`retail-software-staging` a bloqué un premier run avant JMeter (`4452873`), puis qu'une publication
JFrog Staging a été autorisée pour permettre le test. Il rapporte que ACR, Promote et Tag sont restés
désactivés sur la branche de validation.

**INFERENCE opérationnelle** — pour un essai isolé, le contrat doit distinguer les écritures
strictement nécessaires au test de la promotion/distribution : Build, déploiement, JMeter et
artifacts conservés ; publication Staging seulement si le plugin testé doit y être consommé ; ACR,
Promote et Tag bloqués. Cette règle ne constitue pas une autorisation de publier ou de relancer.

## UNKNOWN et reprise discriminante

- `UNKNOWN` — existence et résultat réels des runs `4452873`, `4453511`, `4453591` et `4453877`, ainsi
  que leur branche, paramètres effectifs et artifacts.
- `UNKNOWN` — résultat du run manuel V23 Fix avec Identity seule, annoncé en cours dans la source.
- `UNKNOWN` — versions minimales individuelles V22 et cause exacte V23 (`Identity` seule ou trio).
- `UNKNOWN` — statut réel des branches et commits rapportés :
  `sandbox/WI-2222897-frenchtaxesrules-v22-packaging-validation-20260909` (`28ebc530…`,
  `aacbfd11…`, `f565c1bd…`) et
  `sandbox/WI-2222897-frenchtaxesrules-v23-identity-validation-20260910`
  (`07397fd…`).

Avant toute conclusion ou nouveau rejeu, relire directement la ref et la timeline du run V23
discriminant, vérifier les paramètres réellement pris (le compte rendu signale que `4453877` a
ignoré les paramètres REST), puis établir la couverture Cur/Fix et le premier stage terminal. Ne
pas compter un stage JMeter absent comme des cas fonctionnels rouges ; ne pas publier, promouvoir,
taguer ou modifier un pipeline sans autorisation explicite.
