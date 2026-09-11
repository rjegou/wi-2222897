# RESULT — candidat révisable de transport local de package

Date : 2026-09-09  
Périmètre : prochain couple du chantier, non nommé dans les sources.  
Statut : préparation locale uniquement ; aucune queue ni exécution distante.

## Verdict borné

`FACT` — Le finding 017 rapporte que le transport `PipelineArtifact + manifest` a permis le
parcours InventoryTracking du run 4447425. La restauration des 86 tests perdus dans 4445575
est attribuée dans ce finding au correctif JMX (balise `<hashTree/>` manquante), et non
causalement au transport.

`FACT` — Le finding 018 rapporte pour FrenchTaxesRules un sous-dossier `localPackageRoot`
contenant exactement les 4 fichiers décrits par le manifest, séparé de l'artifact `_Software`
complet de 12 fichiers MSI/XML. Les champs de provenance rapportés sont `sourceBuildId`,
`artifactName`, `packageVersion`, SHA-256 et taille par fichier.

`INFERENCE` — Le gabarit ci-dessous est un candidat réutilisable pour préparer un prochain
couple : il reprend ces contrôles de provenance et de sélection sans prétendre reproduire une
interface non publiée dans les findings.

`UNKNOWN` — Le prochain couple, son `sourceBuildId`, son `artifactName`, sa `packageVersion`,
les chemins exacts et leur nombre `N`, leurs octets, leurs tailles, l'URL ou interface de téléchargement,
le nom de la tâche de déploiement et le commit exact de la variante FrenchTaxesRules ne sont
pas fournis. Ils doivent être vérifiés avant toute mise en file.

`UNKNOWN` — Le finding 018 ne permet pas d'affirmer que le raffinement est isolé, committé,
reproductible ou généralisable à un autre plugin. Il ne constitue pas une preuve indépendante
de l'exécution rapportée.

## Paramètres à renseigner avant usage

Renseigner ces valeurs à partir du manifest et de l'artifact réellement sélectionnés :

```text
targetCouple       = <UNKNOWN — ne pas inventer>
sourceBuildId      = <UNKNOWN>
artifactName       = <UNKNOWN>
packageVersion     = <UNKNOWN>
manifestPath       = <UNKNOWN — chemin exact du manifest>
localPackageRoot   = <UNKNOWN — répertoire dédié, hors _Software>
deploymentTarget   = <UNKNOWN — interface/tâche à confirmer>
sourceCommit       = <UNKNOWN — commit à confirmer>
```

`localPackageRoot` est dédié à ce package et ne doit pas être confondu avec `_Software`.
Le nombre de quatre entrées est spécifique au cas FrenchTaxesRules rapporté ; ce n'est pas
une constante générale du gabarit.

## Procédure candidate révisable

1. Sélectionner exactement un `sourceBuildId`, un `artifactName`, une `packageVersion` et un
   manifest. Arrêter si une valeur est absente, ambiguë ou issue d'un autre build.
2. Lire le manifest sélectionné et produire `MANIFEST.csv` avec exactement `N` entrées,
   où `N` est le nombre effectivement listé dans ce manifest. Pour l'exemple FrenchTaxesRules
   rapporté, `N = 4` ; cette valeur ne doit pas être généralisée. Pour chaque fichier, conserver
   le chemin relatif, la taille et le SHA-256.
3. Depuis l'artifact complet sélectionné, copier/sélectionner uniquement les `N` fichiers du
   manifest vers `localPackageRoot`. Des fichiers supplémentaires peuvent exister dans
   l'artifact source ; ils sont interdits dans le répertoire dédié final. Contrôler, en tant que
   proposition de gabarit (`INFERENCE`), les chemins relatifs, les collisions et l'absence de
   traversée de répertoire (`..`, chemin absolu ou résolution hors racine). Arrêter au premier
   écart, fichier manquant, fichier supplémentaire dans `localPackageRoot` ou hash/taille divergents.
4. Passer uniquement `localPackageRoot` au déploiement cible confirmé. Ne pas publier sur un
   feed partagé et ne pas substituer `_Software` au répertoire dédié.
5. Conserver les valeurs de provenance et la sortie de validation dans un dossier de preuve
   séparé. Ne conclure à l'attestation qu'après observation directe des postconditions de
   campagne ; la préparation seule ne vaut pas exécution.

## Conditions d'arrêt

- manifest non identifié ou différent de celui demandé ;
- nombre d'entrées différent de `N` issu du manifest sélectionné, ou sélection non limitée au
  manifest ; `N = 4` uniquement pour l'exemple FrenchTaxesRules rapporté ;
- chemin absolu, traversée `..`, collision de chemins ou résolution hors de la racine dédiée ;
- taille ou SHA-256 divergent, artifact/packageVersion incohérents, ou sourceBuildId ambigu ;
- interface YAML/tâche de déploiement non vérifiée ;
- preuve d'une publication, promotion ou écriture distante non explicitement autorisée ;
- absence de preuve séparée que le stage JMeter a réellement exécuté le package transporté.

## Critères d'attestation de campagne

Attester séparément, avec identifiants et preuves brutes :

- les stages JMeter sont exécutés et non `skipped` ;
- les Test Runs sont attribués au build par `buildUri` ;
- les comptes Cur et Fix sont présents et comparables ;
- les `N` fichiers consommés sont reliés au manifest par chemin, taille et SHA-256 ;
- le cleanup est observé, sans déduire sa complétude d'un simple statut final.

Sans ces preuves, conserver `UNKNOWN`, même si le transport a été préparé ou si le pipeline
est vert.
