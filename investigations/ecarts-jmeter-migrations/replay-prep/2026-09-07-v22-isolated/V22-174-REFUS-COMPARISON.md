# V22 — comparaison par scénario et signature

Source : `findings/004-french-taxes-rules-v21-v23-build-4429167.md`, couverture V22 Fix du build 4429167. Cette matrice sert de critère de rejeu ; elle ne transforme pas une exécution future en preuve métier.

| Groupe | Signature historique | Volume attendu | Baseline Fix historique | Candidat attendu |
|---|---|---:|---|---|
| Legacy `FrenchTaxesRules:Run` | `CBP50101` / `ID4266` / `ClaimsPrincipalPermission` refusée | 38 tests | Reproduire le refus d'autorisation, après santé runtime établie | Le refus doit disparaître sur ces cas ; toute autre erreur est classée séparément |
| Legacy autres opérations FrenchTaxesRules | même famille `CBP50101` / `ID4266` | 100 tests | Reproduire la même signature, sans confondre avec panne d'infrastructure | Comparer par scénario et assertion |
| Web `Validation:SetDocumentErrorReason` | `FailedAuthentication`, `Access is denied` | 31 tests | Reproduire la signature d'autorisation | Vérifier disparition de la signature |
| Web `Purge:Execute` | `FailedAuthentication`, `Access is denied` | 5 tests | Reproduire la signature d'autorisation | Vérifier disparition de la signature |
| Web autres tests | pas de refus d'autorisation attendu | 108 tests passent historiquement | Ne pas exiger zéro autre échec métier | Comparer uniquement les scénarios/signatures correspondants |

Total : `138 Legacy + 36 Web = 174` refus historiques dans la capture complète. Le résultat global attendu est donc une partition par signature, pas un verdict binaire « zéro échec ».

## Garde-fou baseline

La baseline Fix est considérée utile si le déploiement/restauration et la readiness SQL/IIS réussissent, puis si les cas discriminants présentent la signature d'autorisation attendue. Un échec de téléchargement, restore, démarrage IIS/SQL, connexion ou JMeter est `INFRASTRUCTURE_BLOCKED` et ne valide ni n'invalide l'hypothèse métier ; le candidat ne doit pas être lancé si la baseline n'a pas atteint cette postcondition.

## Garde-fou candidat

Le candidat réutilise les mêmes JMX, plugin `22.0.6.478`, AuthenticationServer, backup et image ; seules les versions Core/Common/Identity changent. Pour chaque scénario, conserver uniquement les champs expurgés : statut HTTP/métier, signature booléenne (`CBP50101`, `ID4266`, `FailedAuthentication`), présence booléenne des scopes attendus, assertion JMeter, durée et hash/version des assemblies. Ne conserver aucun token, claim complet, mot de passe, URL secrète ou payload.
