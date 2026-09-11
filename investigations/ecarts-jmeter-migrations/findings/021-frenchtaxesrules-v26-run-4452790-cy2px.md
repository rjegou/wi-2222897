# Finding 021 — FrenchTaxesRules V26 : run 4452790 bloqué avant JMeter sur `*.cy2px`

## Périmètre et provenance

- **Périmètre rapporté** : `Y2_Plugins_FrenchTaxesRules`, V26/master, définition `FrenchTaxesRules CI` (`2054`).
- **Source** : [synthèse technique reçue le 2026-09-09](../evidence/local-2026-09-09-frenchtaxesrules-v26-synthese-technique/README.md).
- **Statut** : `rapporté, non revérifié`. Les commits, pushs, builds, stages et résultats décrits n'ont pas été relus directement dans Azure DevOps par cette intégration.

## Conclusion bornée

**Rapporté, non revérifié** — le document source décrit une séquence où :

1. les 48 faux échecs précédemment attribués au générateur JMX sont annoncés corrigés et validés localement (`16/16` HTTP, `32/32` SOAP Fault) ;
2. le nom logique d'image `win2025sql2025dotnet10` est rapporté comme différent du tag Docker réellement consommé en V26 (`sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`), avec mapping V22-V25 vers `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022` ;
3. le script `Step_04_modifYml.py` est rapporté corrigé pour les frontières `<= V21`, mais non idempotent lorsqu'il est rejoué sur un YAML déjà migré ;
4. le run `4452567` est rapporté arrêté avant JMeter dans `Ensure_Docker_Image_Up_To_Date` sur image/manifest indisponible ;
5. le run `4452790` est rapporté avoir dépassé ce blocage puis avoir échoué dans `Configure cy2px files` avec `Could not find files with glob [*.cy2px].` ; les tests JMeter ne sont donc pas prouvés exécutés par ce run.

## Ce que cette fiche établit et ne déduit pas

- **FACT documentaire** — le fichier source et son empreinte sont conservés dans l'index de preuve ; son contenu est une déclaration reçue, pas une observation indépendante.
- **UNKNOWN** — existence et contenu exacts des `*.cy2px` attendus, cause de leur absence, jobs/stages réellement exécutés dans `4452790`, exécution des 19 JMX, liste des échecs restants et création d'une PR.
- **UNKNOWN** — correspondance exacte entre le commit/push `bd3688e410e8227bd36487d3c5a35b899d25a8e7` rapporté et la branche réellement consommée par `4452790`.
- Ne pas reclasser `4452790` comme échec métier JMeter : la frontière rapportée est antérieure à l'exécution du moteur.

## Reprise discriminante

Relire directement la timeline et les logs de `4452790`, puis la définition et le commit consommés, pour déterminer le producteur attendu des `*.cy2px`. Après correction ciblée et preuve des fichiers dans le job, vérifier séparément que les stages JMeter Cur/Fix sont exécutés et collecter leurs résultats nominaux.
