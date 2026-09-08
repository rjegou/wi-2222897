# Audit Clienteling endpoints/packaging — Worker 2 round 1

Date de collecte : 2026-09-07 (Europe/Paris). Périmètre strict : item 6
endpoints/packaging Clienteling, hors FrenchTaxesRules releases/V5/V22 et hors
travail des autres instances. Cette collecte est une consolidation de lecture
des preuves existantes; aucun worktree, pipeline, MSI, endpoint HTTP, feed,
document canonique partagé ou ressource externe n'a été modifié.

## Provenance et état Git

Les instructions locales, l'index de preuves et les collectes rounds 10/11 ont
été lus avant travail. La commande obligatoire
`git -C worktrees/Y2_Plugins_Clienteling status --short --branch` a été tentée
avant toute écriture. Elle est bloquée par `dubious ownership` entre le compte
du worktree et le compte d'exécution. Aucune exception Git globale n'a été
ajoutée et aucun checkout/nettoyage/édition n'a été tenté.

## Résultats

**FACT — V26 déjà couvert, non refait.** Les rounds 10/11 prouvent les cinq
attributs source corrigés, la concordance avec le manifeste V26 et la chaîne
source → Console → JMX (Console code 0, cinq plans représentés, aucun nom
générique dans les champs endpoint). Cette collecte ne modifie ni ne rejoue
ces contrôles.

**FACT — couples canoniques V22–V25 disponibles.** La collecte Worker 1 round3
conserve les commits sources exacts `97bc21d41`, `f9ce510ab`, `789ab7280`,
`119014398`, leurs archives hashées et les blobs de manifests. Les cinq XML
historiques sont identiques entre ces versions et portent les noms génériques,
tandis que chaque manifeste déclare `ClientelingDeploymentService.svc` et
`ClientelingMobilityService.svc`.

**FACT — génération historique complète.** Les rounds 3/4 établissent 20/20
JMX V22–V25 générés avec Console code 0, XML parsé, et trois endpoints
Deployment/deux Mobility spécifiques par version. Les hashes des lots V24/V25
et les lots V22/V23 sont conservés dans les collectes sources référencées.

**FACT / UNKNOWN — Products.** Le code historique ajoute
`ClientelingProductsService.svc` et `Products_GetItemsV2.xml`, puis les commits
de déréférencement retirent plan et fixtures. Les quatre manifests V22–V25
inspectés ne déclarent pas `ClientelingProductsService.svc`. Le support officiel,
l'installation MSI et le contrat par version restent **UNKNOWN**. Aucun plan
Products n'a été activé, supprimé ou généré.

**FACT — aucune validation runtime disponible dans ce périmètre.** Les rounds
3–5 déclarent explicitement aucune installation MSI, aucun appel HTTP métier,
aucune exécution SQL/IIS et aucune publication distante. La recherche ciblée
des preuves Clienteling ne trouve pas de statut HTTP, log `msiexec` réussi ou
artefact de déploiement isolé. Le résultat générateur (20/20) reste donc
distinct du résultat HTTP/MSI, qui demeure **UNKNOWN / NOT RUN**.

## Verdict et prochaine piste

La correction Deployment/Mobility est étayée pour V22–V26 au niveau
source/manifeste/générateur, sans généraliser Products. Il n'existe pas de
piste locale utile supplémentaire sans décision externe. Pré-requis :

1. décision explicite du propriétaire Clienteling sur le support de
   `ClientelingProductsService.svc` pour chaque version concernée;
2. cible HTTP/IIS et installation MSI isolées, autorisées et identifiées, puis
   smoke séparé par endpoint avec postcondition observable.

## Fichiers de provenance

Les empreintes des README relus sont dans `MANIFEST.csv` et `SHA256SUMS.txt`.
Les preuves brutes existantes ne sont ni copiées ni réécrites.
