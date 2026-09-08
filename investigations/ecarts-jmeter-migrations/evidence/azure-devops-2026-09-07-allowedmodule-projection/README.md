# Preuve Azure DevOps — projection `allowedModule` (2026-09-07)

## Périmètre et provenance

- Date de collecte : 2026-09-07, Europe/Paris.
- Source : Azure DevOps `https://dev.azure.com/cegid`, projet `Retail`.
- Méthode : appels CLI Azure DevOps en lecture seule (`az repos list`, `az repos ref list`, `az devops invoke`, API Git 7.1), avec contenu limité aux fichiers cités.
- Aucun pipeline, push, branche, PR, publication ou modification distante exécuté.
- Le jeton utilisé pour l’accès n’est pas reproduit dans cette preuve.

## Faits directs

### Common : découverte et projection

Dans `Y2_Core_Common`, branche `releases/V5`, les fichiers suivants ont été lus :

- `/Cegid.Retail.Common.Services/ModuleCatalog/ModuleCatalogService.Implementation.cs`, objet `8c7f599561aa485c62edc255929449e80b4c3b98` ;
- `/Cegid.Retail.Common.Services/ModuleCatalog/GetUserAuthorizationScopesReplyFactory.cs`, objet `3d7fd91e75aade6eb78097919d7b9b95ae10a9cf` ;
- `/Cegid.Retail.Common.Services/ModuleCatalog/SafeDirectoryCatalog.cs`, objet `243e67fcfb457cec32d5920a52fcb71eff477d0e`.

Le service Common :

1. découvre les DLL `Cegid.Retail.*.dll` du répertoire applicatif via MEF ;
2. sélectionne les exports au contrat `Cegid.Retail.Services.ModuleCatalog` ;
3. appelle `GetUserAuthorizationScopes(...)` sur chaque catalogue de module ;
4. fusionne uniquement les doublons dont `AuthorizationScope` est égal avec comparaison insensible à la casse ;
5. recopie `AuthorizationScope`, `ClaimType`, description et catégorie sans réécriture.

Le factory de réponse construit les scopes sous la forme exacte `${id}:${action.ToString().ToLowerInvariant()}`, avec `ClaimType = allowedModule` par défaut. Aucun alias `purge-settings` vers `purge`, ni alias `FrenchTaxesRules`, n’apparaît dans ces fichiers.

### Identité des versions Common

Le même objet Git `8c7f599561aa485c62edc255929449e80b4c3b98` est retourné pour
`Y2_Core_Common` aux tags :

- `V3.300` — version retenue comme Common du Fix (`22.0.2.300`) ;
- `V3.311` — version candidate (`22.0.3.311`) ;
- `V3.315` — version Current (`22.0.3.315`).

Cela prouve une identité de contenu de l’implémentation de projection Common entre ces trois références.

### Core : absence d’alias plugin

Dans `Y2_Core`, branche `releases/V22`,
`/Dotnet/Cegid.Retail.Services/ModuleCatalog/ModuleCatalog.cs` (objet `80b143ce1b54cc60efbdf18f9358d5b320e0f850`) déclare les éléments Core et les accès API/partenaire. Il ne contient pas de table d’alias pour `FrenchTaxesRules`, `french-tax-rules-purge-settings:execute` ou `french-tax-rules-purge:execute`.

Dans `Y2_Core`, `/Dotnet/Cegid.Retail.Services/Security/RetailClaimsAuthorizationManager.cs` est identique (objet `857466c8ef2323732082cf817fa63be0b2bab2ed`) sur la branche `releases/V22` et le tag `V22.0.0.2096`. Le contrôle API key vérifie la présence exacte du couple claim type/valeur demandé ; il ne convertit pas `purge-settings` en `purge`.

### Identity : scopes propres, pas de FrenchTaxesRules

Dans `Y2_Plugins_Identity`,
`/Cegid.Retail.Identity.Services/ModuleCatalog/ModuleCatalog.cs` est l’objet `f8901ca02b5ba9f58ded194f92f923caad90008d` aux tags `V6.117` (candidat `22.0.6.117`) et `V6.171` (Current `22.0.6.171`). Le code émet seulement les scopes identité `devicemanagement:authority`, `user:systemuser` et `identity-userrestrictions:read`, selon les attributs utilisateur. Aucun scope `FrenchTaxesRules` ni `french-tax-rules-*` n’y figure.

Le chemin exact de ce fichier n’existe pas au tag Identity `V5.182` (Fix) selon la réponse Azure DevOps `TF401174`; cela signale une structure historique différente, mais ne prouve pas le contenu de l’assembly livrée.

### AuthenticationServer : copie, pas conversion

Au tag disponible le plus proche `Y2_Core_AuthenticationServer` `2.0.0.332` (la cible `2.0.0.368` n’a pas été retrouvée dans les tags retournés), `ApiKeyScopeService.cs` (objet `c4a42eab925b19be9a20fb4ee3004793022a5c87`) recopie les champs de la réponse d’autorisation distante sans transformer `AuthorizationScope`. `CatalogService.cs` (objet `1e93fc8b28313529c7f29ebdb29f60b9a0252b6c`) teste les noms de module/service/opération par égalité exacte.

## Conclusion qualifiée

- **FACT** — Le Common versionné aux références Fix/candidat/Current ne fournit aucune projection ou alias de `allowedModule`; il recopie les scopes du catalogue plugin par égalité exacte.
- **FACT** — Core et Identity lus ne déclarent pas les scopes FrenchTaxesRules ; le contrôle Core vérifie les valeurs exactes présentes dans les claims API key.
- **INFERENCE forte** — La différence `Current` 0 fail contre `Fix` en échec ne s’explique pas par une conversion propriétaire Common de `french-tax-rules-purge-settings:execute` vers `french-tax-rules-purge:execute`. Elle pointe plutôt vers une différence de catalogue/assembly effectivement chargée, de données/provisionnement d’API key, ou de chemin d’émission des claims entre environnements/builds.
- **UNKNOWN** — Les objets sources prouvés ne suffisent pas à déterminer pourquoi le Current a reçu les droits attendus avec le même numéro de plugin déclaré. Les binaires effectivement déployés, la réponse runtime `GetUserAuthorizationScopes` et les données d’autorisation de chaque cible restent non comparés. L’absence du tag exact AuthenticationServer `2.0.0.368`, Core `22.0.0.1011`/`22.0.0.2068` et du chemin Identity Fix empêche toute conclusion de contenu pour ces références exactes.

## Plus petit contrôle runtime discriminant

Sur une cible Fix puis Current, sans journaliser de jeton ni secret, capturer seulement :

1. la liste redigée des `AuthorizationScope` renvoyée par `GetUserAuthorizationScopes` pour le même utilisateur/domaine ;
2. la présence booléenne des trois valeurs discriminantes : `FrenchTaxesRules`, `french-tax-rules-purge-settings:execute`, `french-tax-rules-purge:execute` ;
3. l’empreinte et le chemin des assemblies `Cegid.Retail.*` chargées, hors contenu sensible.

Ce contrôle sépare émission/provisionnement des claims d’un éventuel défaut du plugin, sans exécuter de code produit depuis la collecte statique.
