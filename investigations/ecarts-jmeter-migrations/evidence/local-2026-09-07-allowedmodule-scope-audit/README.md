# Audit local des scopes `allowedModule` — FrenchTaxesRules V22

Date de collecte : 2026-09-07

## Portée

Lecture seule du snapshot source du build Azure DevOps `4429167` (commit
`2d826b8fd19ecb4d7200f574414efb7583de8ed2`) et du worktree courant
`Y2_Plugins_FrenchTaxesRules` (`master`, HEAD `07a42172bebc65d17093e166ac08de22e4fe7248`).
Aucun pipeline, déploiement, publication ou modification distante n'a été effectué.

## Preuves directes

Source historique :
`../../sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167/Cegid.Retail.FrenchTaxesRules.Services/ModuleCatalog/ModuleCatalog.cs`

Worktree courant :
`../../../../worktrees/Y2_Plugins_FrenchTaxesRules/Cegid.Retail.FrenchTaxesRules.Services/ModuleCatalog/ModuleCatalog.cs`

Le `ModuleCatalog` expose sous la claim `allowedModule` :

- `french-tax-rules-purge-settings:read`
- `french-tax-rules-purge-settings:write`
- `french-tax-rules-purge-settings:execute`
- `french-tax-rules-validation:read`
- `french-tax-rules-validation:write`

Les adapters historiques demandent :

- `allowedModule / FrenchTaxesRules` pour les services Legacy et Validation ;
- `allowedModule / french-tax-rules-purge-settings:write` pour `Purge.CreateParam` ;
- `allowedModule / french-tax-rules-purge:execute` pour `Purge.Execute` ;
- `allowedModule / french-tax-rules-purge-settings:read` pour `Purge.GetParam`.

Contrôle d'identité : `ModuleCatalog.cs` historique et courant ont le même
SHA-256 `B809B9785D6CF97A3CD974A09492FA98938044E15D855A95518EEEDE12914AEE`.
`PurgeService.CwasAdapter.g.cs` historique et courant ont le même SHA-256
`CEBAB1059B983004143F356351BA5D94AA743235454784A41BC2A16E86597DC8`.

Historique Git accessible : le fichier `ModuleCatalog.cs` provient du commit
`00683e288b656831ab3239ecf77fc1f0590a6093` (`Merged PR 148148: Scopes`,
2023-01-18) ; aucune évolution ultérieure du fichier n'est présente dans
l'historique local consulté.

## Verdict

**FACT** — le plugin historique contient une incohérence textuelle entre les
scopes publiés par son catalogue et au moins deux opérations exigées par ses
adapters (`FrenchTaxesRules` et `french-tax-rules-purge:execute`).

**FACT** — cette incohérence est identique dans le snapshot du build 4429167 et
le worktree courant ; elle n'est donc pas une différence introduite par la
migration JMeter.

**INFERENCE** — la réussite Cur avec le même plugin `22.0.6.478` implique qu'une
différence de pile Cur/Fix (catalogue externe, projection/normalisation dans
Core/Common/Identity, ou consommation effective des binaires) peut compenser ou
masquer cette incohérence. Le code local ne permet pas de choisir laquelle.

**UNKNOWN** — contenu et comportement exacts de Core/Common/Identity aux
versions Fix `22.0.0.1011` / `22.0.2.300` / `22.0.5.182`, Cur
`22.0.0.2096` / `22.0.3.315` / `22.0.6.171`, et candidate
`22.0.0.2068` / `22.0.3.311` / `22.0.6.117` ; aucun de ces composants n'est
présent en source exploitable dans les worktrees locaux.

## Plus petit contrôle runtime discriminant

Sur une cible dédiée, sans afficher de jeton : appeler le endpoint/catalogue
des scopes avec les mêmes identifiants et dossier V22, puis vérifier uniquement
la présence des chaînes suivantes dans la réponse expurgée :

1. `FrenchTaxesRules` ;
2. `french-tax-rules-purge:execute` ;
3. `french-tax-rules-purge-settings:execute` ;
4. `french-tax-rules-validation:write`.

Faire ce contrôle après installation séparée de Fix, Cur et candidate, avec le
même plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, image et backup.
Ensuite seulement exécuter les trois opérations discriminantes :
`FrenchTaxesRules:Run`, `SetDocumentErrorReason`, `Purge:Execute`.

Le contrôle ne doit pas être remplacé par une lecture ou conservation du JWT
brut. Il distingue directement catalogue exposé, projection effective et
autorisation consommée ; un résultat différent entre catalogue et endpoint
reste à classer UNKNOWN jusqu'à obtention de la réponse réellement consommée.
