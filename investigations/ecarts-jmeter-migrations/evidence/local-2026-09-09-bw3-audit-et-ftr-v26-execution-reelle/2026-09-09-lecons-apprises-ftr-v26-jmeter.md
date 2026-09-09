# FrenchTaxesRules V26 — Leçons apprises pendant le diagnostic JMeter

## Contexte

Cette synthèse reprend uniquement les enseignements utiles tirés du diagnostic et des corrections effectuées sur la branche de validation FrenchTaxesRules V26, jusqu'à l'exécution réelle des campagnes JMeter Cur/Fix.

## 1. Ne pas transformer trop vite un incident transitoire en bug de pipeline

Le build `4447926` avait échoué avant JMeter sur un `Move-Item` avec `Access denied` lors du déplacement de `FWK-CEGID-NET-FULL.12.9.193\content\BIN` vers `Assemblies\CBP`.

Le run suivant a réussi :

- sur le même agent `vm-alm-agent-02-A` ;
- avec le même compte `tfsbuild` ;
- avec NuGet `7.6.0.59` ;
- avec le même package `FWK-CEGID-NET-FULL.12.9.193` ;
- avec exactement le même `Move-Item`.

Le diagnostic ajouté juste avant le restore montrait également :

```text
Assemblies\CBP
Exists: False
```

### Leçon

Quand une opération identique réussit ensuite dans les mêmes conditions principales, il faut privilégier l'hypothèse d'un **incident filesystem transitoire** plutôt que modifier immédiatement le code ou le template.

Causes compatibles mais non prouvées : verrou temporaire, processus concurrent, antivirus/indexation ou état fugace du workspace.

**Ne pas remplacer `Move-Item` par `Copy-Item` sans preuve de cause.**

---

## 2. Ajouter un diagnostic minimal au plus près de la faute

Le petit probe placé immédiatement avant `restore-externals` a permis de répondre à une question précise : `Assemblies\CBP` existait-il déjà ?

Cette approche est plus efficace qu'une instrumentation large du pipeline : une hypothèse, une observation, puis décision.

### Leçon

Pour un incident CI intermittent :

1. observer juste avant la commande fautive ;
2. collecter seulement les éléments discriminants ;
3. ne modifier le comportement qu'une fois la cause suffisamment démontrée.

---

## 3. Vérifier les vrais noms produits par le build, pas les noms supposés

Le premier blocage du transport local venait d'un contrôle qui attendait :

```text
E_IIS_SERVER_FRENCHTAXESRULES.MSI
E_IIS_SERVER_FRENCHTAXESRULES.XML
```

alors que l'artifact produit réellement :

```text
E_IIS_SERVER_RETAIL_FRENCHTAXESRULES.MSI
E_IIS_SERVER_RETAIL_FRENCHTAXESRULES.XML
```

Le nom réel était cohérent avec le kit déclaré dans le YAML :

```text
E_IIS_SERVER_RETAIL_FRENCHTAXESRULES
```

### Leçon

Avant de corriger un script de validation d'artifact, **regarder le contenu réel de l'artifact Azure DevOps** et aligner les contrôles sur les fichiers effectivement produits.

---

## 4. Un artifact global peut contenir plus de fichiers que le sous-ensemble nécessaire au test

L'artifact `_Software` contenait 12 fichiers MSI/XML légitimes : IIS, Process, CPTX, SaftFileAnalysis, TaskScheduler, Worker Process, etc.

Le contrôle initial exigeait pourtant que l'artifact ne contienne **exactement que les 4 fichiers utilisés par le test**. Il échouait donc même lorsque les 4 fichiers nécessaires étaient présents.

### Leçon

Il faut distinguer :

- **artifact de build complet** ;
- **sous-ensemble nécessaire à un scénario de déploiement**.

Le bon contrôle est : « les 4 fichiers requis sont présents exactement une fois », et non : « l'artifact entier ne contient que 4 fichiers ».

---

## 5. Le répertoire local transmis au déploiement doit correspondre exactement au manifest

Après le premier correctif, le manifest décrivait seulement 4 fichiers, mais `localPackageRoot` pointait encore vers le dossier `_Software` contenant les 12 fichiers.

Le déploiement a alors échoué avec :

```text
Local package root contains an absent or unexpected file.
```

La solution robuste a été de créer un sous-dossier dédié :

```text
$(Pipeline.Workspace)\frenchtaxesrules-local-package
```

contenant uniquement les 4 fichiers attendus, tandis que le manifest restait séparé.

### Leçon

Quand un outil valide un package par manifest :

**le contenu physique de `localPackageRoot` doit être strictement cohérent avec le manifest.**

Le manifest ne doit pas servir uniquement de filtre logique sur un dossier contenant d'autres fichiers.

---

## 6. Préserver la provenance même lorsqu'on construit un sous-package local

Le sous-dossier local ne remplace pas l'artifact de build comme source de vérité. Les métadonnées ont été conservées :

- `sourceBuildId` ;
- `artifactName` ;
- `packageVersion` ;
- hash SHA-256 et taille de chaque fichier.

### Leçon

On peut **adapter physiquement le transport** sans perdre la traçabilité du build source. Le sous-package est une vue contrôlée de l'artifact, pas un nouvel artifact métier indépendant.

---

## 7. Éviter de modifier les templates partagés si le besoin peut être isolé dans le dépôt consommateur

Les corrections utiles ont pu être faites dans le YAML FrenchTaxesRules et son transport local, sans modifier `Pipelines_Templates` ni le comportement global des autres plugins.

### Leçon

Dans une investigation de migration, préférer une correction **locale, bornée et réversible** à une modification d'un template partagé, surtout tant que la cause n'est pas générale et démontrée.

---

## 8. Attention à la structure YAML lors d'un remplacement manuel

Une première édition avait accidentellement supprimé le bloc :

```text
jobs → each typeTest → job → steps
```

alors que le PowerShell lui-même était correct.

### Leçon

Après un remplacement manuel dans Azure DevOps, vérifier systématiquement non seulement le contenu modifié, mais aussi **son niveau d'indentation et ses parents YAML**.

---

## 9. Pour les résultats de tests, REST est nettement plus efficace que l'UI

L'UI Azure DevOps permettait de voir les volumes globaux, mais comparer manuellement les échecs Cur/Fix était trop long.

La REST API a permis de récupérer directement les 4 Test Runs et leurs résultats :

- LegacyServices Cur : 187 tests, 48 failed ;
- LegacyServices Fix : 187 tests, 48 failed ;
- WebServices Cur : 66 tests, 3 failed ;
- WebServices Fix : 66 tests, 3 failed.

Soit par variante :

```text
253 tests
202 passed
51 failed
```

### Leçon

Pour une comparaison volumineuse ou nominative de résultats Azure DevOps, passer rapidement par REST plutôt que parcourir les tests à la main.

---

## 10. Séparer exécution, couverture et succès métier

Le build final `4448787` est `partiallySucceeded`, mais cela ne signifie pas que la migration JMeter n'a pas fonctionné.

Au contraire :

- Cur a exécuté 253 tests ;
- Fix a exécuté 253 tests ;
- la volumétrie attendue de 253 identités par variante est retrouvée ;
- aucun test n'est « non reporté » dans la vue globale observée.

### Leçon

Toujours distinguer trois questions :

1. **Les campagnes se sont-elles réellement exécutées ?**
2. **La couverture attendue est-elle présente ?**
3. **Les tests métier sont-ils tous verts ?**

Un `partiallySucceeded` ne répond à aucune de ces questions à lui seul.

---

## 11. Cur et Fix identiques orientent fortement le diagnostic

Les 51 échecs sont **strictement les mêmes, nom pour nom**, en Cur et en Fix.

Cela rend peu probable un défaut spécifique au packaging Fix. Les causes sont plutôt communes aux deux variantes : scénario, données, environnement, JMX ou comportement produit partagé.

### Leçon

Le différentiel Cur/Fix est un signal de diagnostic très fort :

- **Cur vert / Fix rouge** → examiner en priorité packaging/pile Fix ;
- **Cur et Fix rouges sur les mêmes tests** → chercher en amont ou dans un composant commun.

---

## 12. Les cas discriminants historiques doivent être vérifiés explicitement

Les cas surveillés lors de la campagne, notamment `Export_Run TC08/09/10` et `DocumentSignature_SignOne TC02`, ne figurent pas dans la liste des échecs du run final.

### Leçon

Ne pas se contenter du nombre total de fails. Une correction peut être validée par quelques **cas discriminants nominatifs** même si d'autres erreurs indépendantes subsistent dans la campagne.

---

## 13. Amélioration de méthode pour la suite

Le diagnostic du `Access denied` a fini par apporter suffisamment d'éléments pour considérer l'incident comme probablement transitoire, mais il aurait été possible de s'arrêter plus tôt dès qu'un rejeu identique avait réussi sur le même agent.

### Leçon

Dès qu'un incident transitoire n'empêche plus l'objectif principal, **revenir rapidement au chemin critique de la PBI**. La priorité est ici : obtenir les campagnes JMeter réelles, vérifier leur couverture, puis classifier les erreurs restantes.

---

# État obtenu à l'issue de cette séquence

- Build / packaging : fonctionnel sur le run final.
- Transport local MSI/XML : fonctionnel.
- Déploiement : suffisamment fonctionnel pour lancer les campagnes.
- JMeter V26 Cur : 253 tests exécutés.
- JMeter V26 Fix : 253 tests exécutés.
- Couverture quantitative attendue : retrouvée.
- Échecs : 51 par variante, strictement identiques Cur/Fix.
- Prochaine étape utile : **regrouper ces 51 échecs par cause réelle via les détails REST des résultats**, plutôt que les traiter test par test.
