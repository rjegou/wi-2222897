# Manifeste de preuve — FrenchTaxesRules round 1

Date de collecte : `2026-09-08` (Europe/Paris). Système source : snapshots locaux indexés dans `investigations/ecarts-jmeter-migrations/sources/`, finding/matrice locaux. Méthode : lecture ciblée, `rg`, parse XML PowerShell, comptage structurel ; aucun contenu sensible copié.

## Entrées exactes

- `sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167`, HEAD `2d826b8...`, build `4429167`.
- `sources/Y2_Plugins_FrenchTaxesRules-v7-build-4429629`, HEAD `657a61c...`, build `4429629`.
- `sources/Y2_Plugins_FrenchTaxesRules`, HEAD `f80bc73...`, snapshot V26.
- Configurations `Tests/Config/v22|v25|v26-(cur|fix).cy2px` : 8 fichiers parsés, 8 PASS.
- `Cegid.Retail.FrenchTaxesRules.Services/ModuleCatalog/ModuleCatalog.cs` dans les trois snapshots : SHA-256 `B809B9785D6CF97A3CD974A09492FA98938044E15D855A95518EEEDE12914AEE` pour chacun.
- Preuves canoniques relues : `findings/004-french-taxes-rules-v21-v23-build-4429167.md`, `findings/003-french-taxes-rules-v25-build-4429629.md`, `cases/STATUS_MATRIX.md`.

## Contrat de rejeu — NOT RUN

Préconditions : pile complète versionnée, plugin exact, backup exact et environnement identique Cur/Fix ; aucun secret dans le bundle. Opérations :

1. `FrenchTaxesRules:Run` — vérifier claim `allowedModule/FrenchTaxesRules` et absence de `CBP50101`.
2. `Validation:SetDocumentErrorReason` — vérifier le claim correspondant et la réponse métier.
3. `Purge:Execute` — vérifier `french-tax-rules-purge-settings:execute` et la réponse métier.

Postcondition d'extension : si et seulement si les trois passent, exécuter les 376 cas avec les mêmes assertions et conserver StdOut/StdErr/TRX expurgés. État actuel : **NOT RUN**, donc aucune réussite migration déduite.

## Contrat round 3

`replay-contract-v22-round3.json` est le contrat hashable des trois opérations puis 376 cas, état **NOT RUN**.

## Collecte distante round 2

Lecture Azure DevOps du 2026-09-08 tentée avec profil temporaire sous cette evidence et PAT en variable de processus. La CLI a échoué sur extension absente/profil global ; REST a échoué sur `Authentication failed`. Aucun résultat distant n'est revendiqué. Le profil temporaire peut rester à dépolluer : **UNKNOWN**, suppression automatique refusée par la politique d'exécution ; il ne contient pas de PAT affiché dans les sorties.
