# Handoff manuel — piste framework d'autorisation FrenchTaxesRules V22

## Provenance

Document reçu hors du processus `brain-worker` (fichier déposé dans `Downloads`, daté 2026-09-07) et rangé ici tel que reçu, sans modification : [WI-2222897_FrenchTaxesRules_V22_investigation_handoff.md](WI-2222897_FrenchTaxesRules_V22_investigation_handoff.md).

**Ce fichier n'a pas été réexécuté ni revérifié lors de ce rangement.** Ses affirmations `FACT` sont rapportées comme telles par la source (recherches JFrog/Git décrites en synthèse), pas confirmées de façon indépendante ici : aucun ZIP, log MSI ou NuGet n'est joint, seuls des extraits (versions, chemins, empreintes JFrog, timestamp de build, commit Git) sont cités dans le texte.

## Contenu

- Reprend le diagnostic déjà `FACT` de [finding 004](../../findings/004-french-taxes-rules-v21-v23-build-4429167.md) : build 4429167, V22 Fix `202/376` passés, 174 échecs homogènes `CBP50101`/`ID4266`/`ClaimsPrincipalPermission.Demand()` sur le module `FrenchTaxesRules`, authentification réussie mais autorisation fine refusée.
- **Point nouveau** : identifie que la DLL réellement chargée diffère entre Fix et Current — `Cegid.Erp.Services.Implementation 12.9.153.1506` (Fix) contre `12.9.185.17` (Current) — et trace cette DLL jusqu'au NuGet externe `FWK-CEGID-NET-FULL 12.9.185` (`retail-nuget-production`, `CBP12_9/12.9.185/DotNet`), restauré via `ExternalsToRestore.xml` de `Y2_Core`, et non embarqué dans `Y2_Core` lui-même.
- **Point nouveau** : le Core candidat `22.0.0.2068` (déjà identifié comme candidat dans le complément JFrog du 2026-09-07 de finding 004) restaurerait ce même `FWK-CEGID-NET-FULL 12.9.185`, donc la même DLL `12.9.185.17` que Current. Le document trace aussi ce build JFrog à un timestamp (`2025-09-05T17:24 UTC`) et propose un commit Git correspondant sur `Y2_Core` branche `releases/V22` (`e24de4fe...`, PR 416695 « change call Legacy UserManagement »), non recoupé ici.
- **Point nouveau** : sur Identity, situe `V6.117` (candidat) et `V6.171` (Current) comme porteurs d'un `ModuleCatalog.GetUserAuthorizationScopes()` avec claim `allowedModule`, absent de `V5.182` (Fix) — cohérent avec la piste déjà `INFERENCE FORTE` de finding 004, sans démonstration d'un claim `FrenchTaxesRules` explicite dans le code cité.
- Reste `NON DÉMONTRÉ` par la source elle-même : correction réelle des 174 échecs sans exécution du replay isolé.
- Leçons méthodologiques rapportées : distinguer authentification/autorisation-endpoint/claims/autorisation-fine ; privilégier l'inspection d'un NuGet externe (15 Mo) à celle d'un ZIP Core complet (~400 Mo) ; limites d'accès JFrog (`Build Info` 403 alors que propriétés artefact et AQL répondent) ; `git fetch --depth=<N>` à la place de `--shallow-since` non supporté par ce serveur Azure DevOps ; ne pas fusionner stderr/stdout (`2>&1`) avant `ConvertFrom-Json`.
- Le brouillon de replay isolé référencé (`replay-prep/2026-09-07-v22-isolated/`) est déjà connu et indexé ; ce document ne modifie pas son état, seulement la justification technique du trio candidat à y tester.

## Relation avec l'évidence et les conclusions déjà canoniques

- Le trio candidat Core `22.0.0.2068` / Common `22.0.3.311` / Identity `22.0.6.117` est le même que celui déjà `INFERENCE` dans [finding 004](../../findings/004-french-taxes-rules-v21-v23-build-4429167.md) et revalidé par checksum JFrog dans [`2026-09-07-jfrog-v22-packaging-revalidation/`](../2026-09-07-jfrog-v22-packaging-revalidation/README.md). Ce handoff ajoute une justification mécanistique (la DLL `Cegid.Erp.Services.Implementation`) mais ne referme aucun `UNKNOWN` déjà consigné : compatibilité avec FrenchTaxesRules `22.0.6.478`, contenu réel des ZIP Core/Common au-delà de leur checksum, et résultat métier restent `UNKNOWN`.
- **Avant de citer le commit `e24de4fe...` ou le trio Fix `12.9.153.1506` comme `FACT` dans `findings/004` ou `HANDOFF.md`, il faut revérifier indépendamment** : lecture directe de `ExternalsToRestore.xml` des deux Core (2068 et 2096), inspection du NuGet `FWK-CEGID-NET-FULL 12.9.185` téléchargé dans ce processus (pas seulement rapporté), et confirmation Git du commit sur `releases/V22`. Rien de tout cela n'a été refait ici.
- Un pointeur de reprise a été ajouté dans `HANDOFF.md` et un complément dans `findings/004` (entrées datées 2026-09-07) pour rendre ce document découvrable depuis les points d'entrée canoniques, sans en faire une conclusion validée.
