# Contrat d’intégration proposé

## Addendum 2026-09-08 — épinglage release candidate

Le candidat local épingle `Cegid.Retail.AutoTest.Api` `1.1.47` au commit `16a03a83c7e4d9a7c65237f556a4167604ed294b`. Après déblocage de la création de branche, le contrat de consommation WORKER 3 est : `Cegid.Retail.AutoTest.Console` `2.0.43`, `versionConsole=2.0.43`, puis contrôle `checkPackage.ps1` et hashes API/Console/NuGet/JMX. La commande de migration doit consommer le cache local explicitement nommé `Cegid.Retail.AutoTest.Console.2.0.43.nupkg`; aucune résolution `latest` ou version flottante.

État : **UNKNOWN**, car la branche distante n'a pas pu être créée (`VS403660`) et aucun package final n'existe encore. Ne pas lancer la campagne sur ce candidat tant que les hashes du package et des JMX ne sont pas fournis.

Artefact local réellement disponible pour diagnostic : `evidence/local-2026-09-08-console-package-2.0.42-cleanxpath/`, nupkg SHA-256 `82F9C7EE19E635DB14F937078339ED5424A2EDE5BE13B2A10F75A790400D70C0`, API embarquée `51FB31...`. Il est explicitement incomplet pour le lot des quatre corrections et ne doit pas être utilisé comme release candidate Clienteling.

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
