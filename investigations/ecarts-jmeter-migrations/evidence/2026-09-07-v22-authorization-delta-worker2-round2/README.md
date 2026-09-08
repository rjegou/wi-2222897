# FrenchTaxesRules V22 — delta d'autorisation binaire/contrat, Worker 2 round 2

Date : 2026-09-07 (Europe/Paris)
Source : collecte locale Worker 1, snapshot FrenchTaxesRules build 4429167 et finding 004.
Méthode : lecture ciblée des XML, hash SHA-256, extraction NuGet déjà conservée, `AssemblyName.GetAssemblyName`, recherche de chaînes ASCII/UTF-16 dans la DLL. Aucun service partagé, endpoint, token ou donnée métier n'a été utilisé.

## Preuves vérifiées

- **FACT** — `sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167/ExternalsToRestore_V22.xml` déclare `FWK-CEGID-NET-FULL` `12.9.153` vers `Assemblies\\CBP`, Common `22.0.2.300` et Identity `22.0.5.182`. Hash du XML : `5D2CBF7EF79555734B0C400DE41C42A63EF959344FA96DF56D779327BC508AD3`.
- **FACT** — les `candidate-ExternalsToRestore.xml` et `current-ExternalsToRestore.xml` extraits des commits Y2_Core `e24de4fe8a6adf886b6d4ef942366a3a4fce09b4` et `7c9f454d1c304b051e636a7acdca30caa3a419ac` sont byte-identiques, hash `B22DC69CD6E82315345074020BD4FABF3C946427FC6350C1C69864FF77252DBB`, et déclarent `FWK-CEGID-NET-FULL` `12.9.185` vers `Packages\\CBP.Net`.
- **FACT** — le NuGet conservé `FWK-CEGID-NET-FULL.12.9.185.nupkg` fait `15,953,130` octets, hash `9A5090100035D3821A7A9A41890E568D78D318C73043503E3813155D9EBA7714`. La DLL extraite `content/BIN/Erp/Cegid.Erp.Services.Implementation.dll` fait `339,544` octets, hash `834382CA635DC7623721D6CCAA08B1EB49FFFDA2C7F5F6AD6DE695F26E332020`, AssemblyVersion `12.9.185.17`.
- **FACT** — la recherche locale dans cette DLL `Cegid.Erp.Services.Implementation` ne trouve pas les chaînes `allowedModule`, `ClaimsPrincipalPermission` ou `FrenchTaxesRules`; elle trouve toutefois des symboles d'autorisation ERP (`IAuthorizationService`, `GetErpAuthorization`, `AllowedProcessConfigurationCollection`). Cette DLL ne suffit donc pas à prouver la projection Identity `allowedModule`.
- **FACT** — une tentative de réflexion sur cette DLL échoue avant l'énumération complète des types, car ses dépendances `Cegid.Framework.Services`, `Cegid.Framework.Common` et `Cegid.Framework.Data` en version `12.9.185.17` ne sont pas présentes dans l'extraction. Il s'agit d'une limite d'environnement local, pas d'une preuve de comportement d'autorisation.
- **FACT rapporté, non revérifié indépendamment** — les logs Fix montrent `Cegid.Erp.*` `12.9.153.1506` et les logs Current `Cegid.Erp.Services.Implementation` `12.9.185.17`; le même rapport attribue à Identity V6 le mécanisme `ModuleCatalog.GetUserAuthorizationScopes()`/`allowedModule` et relie les 174 refus aux opérations `allowedModule/FrenchTaxesRules`, `SetDocumentErrorReason` et `french-tax-rules-purge:execute`.
- **FACT selon la collecte AzDO dédiée** — Common `V3.300`, `V3.311` et `V3.315` partagent le même objet Git pour la projection; le factory forme les scopes `${id}:${action}` et recopie `ClaimType=allowedModule` sans alias. Core ne contient pas d'alias FrenchTaxesRules et son manager compare exactement le couple claim type/valeur. Identity V6.117/V6.171 ne déclare que ses propres scopes; aucun scope FrenchTaxesRules n'y est codé. Voir `evidence/azure-devops-2026-09-07-allowedmodule-projection/README.md`.

## Reproduction ciblée

La reproduction locale réalisable est contractuelle et binaire, pas métier :

1. comparer le XML Fix historique au couple candidate/current ; le delta `12.9.153` → `12.9.185` est reproduit par hashes et lecture XML ;
2. extraire le NuGet candidate et vérifier que l'assembly chargée attendue est `12.9.185.17` ;
3. vérifier que la DLL disponible n'expose pas directement `allowedModule`.

Résultat : **FACT de mécanisme de packaging**, mais pas preuve que le principal reçoit le claim ni que les appels sont autorisés. Aucune DLL Fix `12.9.153.1506` ni DLL Identity `22.0.6.117/22.0.5.182` n'est jointe localement, donc aucune comparaison binaire complète n'est possible ici.

La reproduction instrumentée à réaliser sur un environnement dédié doit conserver uniquement des observations booléennes/compteurs et des codes, jamais le jeton ou les claims complets :

| Point | Observation non sensible | Interprétation discriminante |
|---|---|---|
| Authentification | HTTP status de l'acquisition de token, présence d'un access token (`true/false`) | HTTP différent de 200 ou absence de token = problème d'authentification/endpoint |
| Projection | nombre de claims `allowedModule` et présence booléenne des valeurs attendues, sans valeur complète | token obtenu mais droit absent = projection/catalogue/packaging candidate |
| Autorisation fine | code HTTP et code métier par opération, booléens `CBP50101`, `ID4266`, `FailedAuthentication` | claim présent mais refus persistant = mapping Resource/Operation, service ou configuration |
| Métier | statut JMeter et assertion/postcondition pour `FrenchTaxesRules:Run`, `SetDocumentErrorReason`, `Purge:Execute` | trois opérations vertes sont nécessaires avant d'étendre à 376 tests |

## Décision et avant/après

**INFERENCE** — le delta externe `FWK-CEGID-NET-FULL` est une cause candidate concrète et falsifiable, mieux localisée que la seule présence du package Core. Le fait que candidate/current partagent exactement le contrat Core renforce la piste, sans isoler le rôle de Common ou Identity.

**UNKNOWN** — projection effective runtime de `allowedModule`, données d'autorisation de chaque cible, correspondance exacte des claims avec chaque opération, compatibilité du trio candidate avec FrenchTaxesRules `22.0.6.478`, et disparition des 174 refus. La nouvelle DLL ne doit pas être décrite comme une correction démontrée.

Protocole avant/après inchangé : mêmes plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, image, backup, JMX et paramètres; restaurations séparées Fix/Candidate sur cibles dédiées; contrôler sans journaliser les tokens l'acquisition, les claims/droits, puis les trois cas `FrenchTaxesRules:Run`, `SetDocumentErrorReason`, `Purge:Execute`; seulement ensuite les 376 tests.

## Ressources temporaires

**FACT** — aucun ZIP temporaire n'est actuellement présent sous `C:\temp` ou `C:\Users\jegour\AppData\Local\Temp`. Le ZIP Core temporaire mentionné par le handoff Worker 1 n'est pas conservé et son chemin exact n'est pas documenté. Ressource réutilisable et présente : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-worker1-french-taxes-rules-v22-authorization/FWK-CEGID-NET-FULL.12.9.185.nupkg` et son extraction adjacente. Aucune suppression n'a été tentée dans cette collecte.
