# Audit distant Products Clienteling — Worker 2 round 3

Date : 2026-09-07 (Europe/Paris). Périmètre strict : work item `668989`,
PR/commits directement liés à `ClientelingProductsService.svc` et conditions
de packaging. Aucun scénario, MSI, worktree, pipeline ou document partagé n'a
été modifié; aucun déploiement ni message externe n'a été effectué.

## Méthode Azure CLI isolée

L'index de preuves, la collecte round2 et la collecte terminale Full-Text ont
été lus avant interrogation. La lecture a utilisé `az rest` avec un
`AZURE_CONFIG_DIR` temporaire, le PAT lu dans le processus depuis
`C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`, et un header
Basic construit en mémoire. Le PAT n'a pas été affiché, persisté ou écrit dans
les preuves. Les profils temporaires ont été supprimés après usage; 16 dossiers
temporaires de cette reprise ont été supprimés explicitement, et le dernier
profil a été supprimé dans son bloc de nettoyage.

Requêtes read-only exécutées : work item `668989` avec expansion des relations,
PR `93749`, commit exact `805f68489c7e943c52aaf63274c61b45c139a16e`, liste des
changements de ce commit, puis les quatre commits de déréférencement connus.

## Résultats distants

**FACT — work item et relation directe.** Le work item `668989` existe, est
`Done`, et porte le titre `[LiveStore - API] Simplification de l'exposition
OpenAPI de la recherche article (v2 API products)`. Il possède cinq relations,
dont un ArtifactLink vers le commit exact et un ArtifactLink vers la PR `93749`.

**FACT — PR introductrice.** La PR `93749` est `completed`, merge réussi,
créée le 2021-11-24 et fermée le 2021-11-26. Son titre est `feat: add Product
GetItemsV2`, sa source `features/ProductGetItemsV2` et sa cible `master`. Le
commit exact `805f68489c7e943c52aaf63274c61b45c139a16e` porte le commentaire
`Merged PR 93749: feat: add Product GetItemsV2` et le lien `Related work items:
#668989`.

**FACT — portée de la PR.** Les changements de la PR couvrent le contrat
Products, l'implémentation/service WebApi, le `.svc` WebServices et les tests/
fixtures `Products_GetItemsV2`. La recherche ciblée dans la liste complète des
changements ne trouve aucun chemin `Kits/V22` à `Kits/V26`, manifest MSI ou
fichier de packaging installant le service. La PR est donc une introduction
API/service/tests, pas une preuve de livraison MSI par version.

**FACT — déréférencement ultérieur.** Les commits distants exacts
`8744999cabb6cea993db49a2d2bf741ae2dd5454`,
`a3b9c933ddeaaf1846785ea6bc044e4bf4a083bb`,
`8f1088fb5f0d54fc7bb17caf351b98edcaa67706` et
`1bcb509c38c31d337fcc5419c7b89d61a19fbe3a` portent tous le commentaire
`dereferencement`. Pour chacun, les changements ciblés sont des suppressions
des tests Products générés et des fixtures `FullTextSearch*Product`; aucun
chemin de manifest MSI ou de dossier `Kits` n'apparaît dans cette vérification.
La preuve ne permet pas d'identifier, à elle seule, une décision de support
runtime par version.

## Verdict support/packaging

La preuve distante améliore la provenance : Products a été introduit par une
PR et un work item API explicites, puis ses tests/fixtures ont été
déréférencés. Elle ne fournit toutefois aucune instruction normative disant
que `ClientelingProductsService.svc` doit être installé dans les MSI V22–V26,
ni aucune condition de livraison par version. Combinée à l'absence du service
dans les manifests et aux 404 historiques déjà établis, la conclusion reste :
**UNKNOWN — ne pas modifier Products**.

Prérequis extérieur irréductible : une décision/document de support par
version, ou un artefact MSI validé qui établit explicitement la présence
attendue du service. Aucun cible isolée réutilisable n'a été créée ou lancée.

## Provenance locale

Les README relus et les findings qui bornent les 404 sont empreintés dans
`MANIFEST.csv` et `SHA256SUMS.txt`. Aucun contenu brut distant ni secret n'est
conservé.
