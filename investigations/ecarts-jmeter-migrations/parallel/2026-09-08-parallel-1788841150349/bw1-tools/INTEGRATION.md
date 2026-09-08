# Contrat d’intégration proposé

## Pour BW2 / workflow-image

Consommer uniquement un package Console local explicitement identifié par version nuspec et SHA-256. Contrôler l’identité avant tout cache ou image; ne pas déduire le contenu image d’un YAML.

## Pour BW3 / API-plugin

La chaîne attendue est : DLL API corrigée → package Console corrigé → `PublishedSharedTools` → cache `migration-tools/Cegid.Retail.AutoTest.Console.nupkg` → régénération depuis XML legacy original. À chaque étape, conserver version, SHA-256, chemin et commit. Le retrait MSTest doit vérifier les références non-MSTest; InventoryTracking reste au périmètre BW3.

## Garde-fous

Aucune publication, branche, PR, queue ou appel métier n’est requis par ce contrat. Un package absent, une version divergente ou un hash manquant doit arrêter la régénération.

## Contrôles Console ajoutés

- DLL API finale avec SHA-256 et liste des correctifs ; `FB497E...` reste candidat non approuvé.
- Runtime Console compatible et jeu complet des dépendances csproj/packages.config, notamment Unity.Configuration, Unity.RegistrationByConvention, XmlDiff, XmlDiffPatch et XmlDiffPatch.View.
- Contrôler API/Console/dépendances avant et après extraction du nupkg, puis seulement `PublishedSharedTools` et cache temporaire.
- Les XML legacy exacts sont obligatoires ; les JMX historiques de l'inventaire ne peuvent pas servir de source de remplacement.
- Incident secret transitoire rapporté comme retiré : aucune valeur ne doit être consultée ; le nettoyage reste à vérifier par le worker migration.
