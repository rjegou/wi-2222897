# CONSOLIDATED_STATE — Round7

## Matrice courte des pistes ouvertes hors FrenchTaxesRules releases/V5 V22

| Piste | Postcondition acquise | Manque précis | Action encore faisable / prérequis |
|---|---|---|---|
| InventoryTracking XmlDiff | Compilation CI sans `MSB3245/CS0103`; 48/48 assemblies; Cur/Fix et 32+32 plans exécutés | 141 erreurs SQL et 123 différences XML par variante, TC non rattaché | Faisable : extraire le premier signal JTL non sensible et rattacher plan/TC/paramètres; comparer legacy seulement après gate de comparabilité |
| Full-Text SQL, 224 cas | Correction locale existante, non refaite par cette instance | Chemin d’exécution réel non validé; Docker local indisponible; CreateBranch/prérequis CI à établir | Faisable par CI dédiée avec cible isolée; prérequis : CreateBranch et moteur SQL réellement accessibles |
| ClientelingProductsService.svc / endpoints | Métadonnées/correction locale existante | Décision de support métier/technique absente; couples source/manifeste V22–V25 absents | Faisable : obtenir sources/manifeste exacts et décision du propriétaire; ne pas déduire le support du seul YAML |
| Clienteling fixtures / runtime IIS | Fixtures factices et transport statique documentés | Transport réel des 11 fixtures et visibilité IIS non prouvés | Faisable en cible IIS isolée, avec chemin résolu et postcondition de lecture; pas de cible partagée |
| PlatformDeploy MSI | Version 5.0.86 résolue; premier MSI 1603 et health-check aval observés; garde de propagation candidat testé | Compatibilité MSI inconnue; archive historique non localement disponible; harness ne lance pas init-container réel | Revue propriétaire puis CI isolée; capturer archive/hash, logs MSI et health-check; ne pas présenter le garde comme correctif MSI |
| PlatformDeploy archive | Hash `625EEC...` rapporté par collecte authentifiée | ZIP historique exact non présent localement, hash non recalculé ici | Prérequis extérieur : accès authentifié et conservation contrôlée de l’archive exacte |
| PlatformDeploy harness | Différentiel wrapper réel + fixture TF_BUILD : original absorbe 7, corrigé retourne 1; succès/exception inchangés | Appel direct init-container original/corrigé non exécuté | Faisable localement si staging complet et paramètres inertes sont disponibles; sinon revue propriétaire du candidat |
| InventoryTracking résultats | Campagnes Cur/Fix réellement exécutées et publiées | Échecs SQL/XML communs encore non attribués, pas de conclusion legacy | Faisable sur artefacts expurgés; prérequis : accès aux JTL/inputs non sensibles |

## Classification

- **FACT** : compilation XmlDiff et 48 tests assemblies du build `4440884`; campagnes Cur/Fix exécutées; erreurs SQL/XML communes; portée exacte du harness PlatformDeploy; ressources créées/observées listées dans `README.md`.
- **INFERENCE** : XmlDiff n’est plus le blocage de compilation; la propagation PlatformDeploy explique une divergence de statut mais ne résout pas MSI.
- **UNKNOWN** : attribution des erreurs InventoryTracking, support Products, transport IIS réel, compatibilité MSI, identité binaire historique du ZIP et exécution complète d’init-container.

## Revue indépendante intégrée

Worker 2 a identifié une lacune concrète du harness précédent. Round7 la conserve explicitement et n’altère ni le candidat isolé ni les preuves antérieures : le test round6 est une preuve de frontière de processus, pas une exécution complète du script d’initialisation.
