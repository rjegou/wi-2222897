# État consolidé actionnable — hors FrenchTaxesRules releases/V5/V22

## Matrice des pistes ouvertes

| Piste | Dernière preuve | Postcondition manquante | Prochaine action concrète | Voie |
|---|---|---|---|---|
| SOAP `ExpectedValue=0` | JMX round2 frais : `ExpectedValue=0`, `negate=true`, `namespace=true`; JTL round2 hashé et JMeter 5.6.3 | Package officiel, orchestration migration et plan métier sélectionné | Conserver le couple fixture/JMX/JTL; refaire seulement après identification du package consommé et du plugin réel | Local puis CI dédiée |
| SQL/date | DLL `57BE...` et JMX synthétique round2 produisent `N'NN''é'` et `20260907` | Propagation package→Console→sandbox et exécution SQL comparable | Injecter le vecteur dans un package de test isolé déjà identifié, hash du JMX, puis validation sur cible dédiée | Local puis cible dédiée |
| Orchestration migration | Round9 prouve Console/API/XML→JMX; `step_00/step_01` non exécutés | Checkout, package, backup, image, sélection de campagne et postconditions réelles | Construire une définition dédiée sans effets JFrog/Publish/Promote/Tag, avec entrées et hashes immuables | CI dédiée; pas queue partagée |
| XmlDiff InventoryTracking | Correctif ciblé restore/références et `ResolveAssemblyReferences` passent; build complet local échoue ailleurs | Build complet sur agent/restore équivalents, absence de `MSB3245` et quatre `CS0103` | Vérifier le dépôt/agent de build et exécuter un Build-only isolé désactivant publication, JMeter et promotion | CI dédiée |
| SQL Full-Text (item 5) | Correction locale préparée: `/FEATURES=SQLENGINE,FullText`; smoke `tests.yml` testé inerte; aucune installation | Média réellement acquis, installation SQL, `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')=1`, catalogue/fonction Clienteling | Utiliser un agent/CI isolé avec média hashé et tâche smoke seule; refuser publication et campagnes si le smoke échoue | CI dédiée, Docker local bloqué |
| Endpoints Clienteling V26 | Cinq plans source→JMX corrigés et contrôlés; aucun HTTP | Smoke HTTP sur endpoint déployé et MSI réel | Déployer sur cible dédiée et tester un endpoint Deployment/Mobility; ne pas généraliser aux versions historiques | CI/cible dédiée |
| Products V22–V25 (item 6) | Les snapshots V22/V23/V24/V25 contiennent le code/service Products; les manifests MSI inspectés ne montrent pas `ClientelingProductsService.svc` dans les fichiers de copie; V26 source/manifest a aussi besoin d'une décision explicite | Décision de support officielle et preuve d'installation/présence du service par version | Faire valider support métier; comparer manifest exact et artefact MSI V22–V25; seulement ensuite générer/rejouer `Products:GetItemsV2` | Local statique puis CI dédiée |
| Fixtures Clienteling | Onze JPG historiques; zéro image snapshot; placeholder et absence de copie template prouvés; fixture factice seulement | Propriétaire transport, artefact/montage et chemin IIS réel | Obtenir le contrat de packaging/montage puis un smoke de présence des onze fichiers sur cible dédiée | CI/cible dédiée |
| JTL legacy comparable | JTL round1 historique distinct du JTL round2 synthétique; aucun contrat/scénario/environnement commun démontré | Même scénario, plugin/version, données, backup, environnement, payload et assertions | Construire une matrice cas-à-cas; ne déclarer aucune régression sur le seul code JTL | Local documentaire puis exécution dédiée |
| PlatformDeploy 4432602 | YAML dynamique `lastV5`, `foundPlatformDeployVersion` absent des logs conservés | ZIP/version/hash/BuildId exact consommé | Lire le log de résolution du build via méthode Azure DevOps fonctionnelle; ne pas relancer une authentification déjà échouée | Lecture CI/Azure DevOps |

## Items 5/6 — décision de reprise

Les corrections locales `local-2026-09-07-sql-fulltext-round12` et `local-2026-09-07-clienteling-endpoint-metadata-round10/11` ne sont pas refaites ici. Elles ne ferment pas les postconditions runtime. La priorité utile est :

1. obtenir une voie CI dédiée pour le smoke Full-Text avec média hashé et sans publication;
2. obtenir la décision officielle de support `ClientelingProductsService.svc` et les couples source/manifeste V22–V25;
3. exécuter ensuite un seul smoke HTTP/Products si le service est déclaré supporté et installé.

## Changements proposés à fusionner manuellement

- Ajouter cette matrice comme section datée du handoff canonique, sans supprimer les restrictions historiques; qualifier les restrictions d'accès comme historiques seulement lorsqu'une collecte Worker 2 live les supersède.
- Conserver explicitement la distinction JTL historique round1 / JTL frais round2 et la contradiction de provenance SOAP; ne pas fusionner les hashes.
- Ajouter aux pistes items 5/6 les postconditions runtime ci-dessus, sans modifier les corrections locales ni leurs worktrees.
- Maintenir `UNKNOWN` pour IIS réel, Products support, build complet XmlDiff, orchestration, package officiel et PlatformDeploy exact.

## Contradictions à signaler au BRAIN

- SOAP : round1 contrôlé montre `negate=false` ou harness manuel `negate=true`; round2 frais montre `ExpectedValue=0 → negate=true`. Les hashes et fixtures diffèrent; vérifier la provenance avant toute conclusion globale.
- JTL : `FAB798...` est historique round1; `73D54...` est round2 frais. Le premier ne valide pas le second et inversement.
- Azure DevOps : la disponibilité n'est pas uniformément rétablie. Worker 2 dispose d'une méthode Python REST fonctionnelle; CLI/profil global et Schannel restent en échec.
- XmlDiff : résolution ciblée locale réussie, build complet local échoué sur un autre manque; aucune réussite CI complète.
- Fixtures : transport factice local réussi, transport IIS/montage réel non prouvé.

## Mise à jour Round 4 — PlatformDeploy exact et MSI 1603

| Élément | Preuve live | Conclusion |
|---|---|---|
| Version PlatformDeploy | Build 4432602 logs 215/243/244 | `PlatformDeploy.5.0.86.zip`, `foundPlatformDeployVersion=5.0.86`, extraction réussie |
| Source correspondante | ADO Repos `refs/tags/V5.0.86` → `93f91487...`; même objet que master local | Scripts locaux inspectés au commit exact; hash ZIP absent |
| MSI V22 Fix | log 248 | Premier 1603: `WORKER_PROCESS_RETAIL_LOYALTYENGINE.MSI`; exception agrégée visible |
| MSI V23 Fix | log 255 | Premier 1603: `E_IIS_SERVER_RETAIL_Technical.MSI`; exception agrégée visible |
| Timeline | records `Launch Y2 deployment` Fix `succeeded`; `Test Y2 deployment` Fix `failed` | propagation du code non nul jusqu'à Azure DevOps non démontrée par la timeline; health check refusé |
| Harness | `platformdeploy-propagation-harness.ps1`, SHA-256 `B8B1DAC438F038E9663A6AF26424B661555352739CF0E9792AA7FE261AA127A8` | modèle inerte reproduit `1603 → throw`, puis `TF_BUILD` wrapper code 0 |

### Prochaine action PlatformDeploy

La prochaine validation utile est une revue propriétaire du wrapper/init-container et un test CI dédié qui capture explicitement le code de sortie après `deploy.ps1`, sans installer de MSI sur une cible partagée. Ne pas déduire le correctif officiel du seul harness; ne pas relancer le build 4432602.

### Provenance technique et hashes inspectés

- `install-y2msi.ps1`: `395BCB3BE429ED74E51FE68C23F2D9C87630A8DDAAEEA927C6290E008C58660D` (acceptation 0/3010, retour 1 sinon).
- `install-packages.ps1`: `480D8B9DDAD49868D09810C1A7CF15C5747B1545C6905AE7BB7E674413E7419E` (agrégation `$nbErr`, throw final).
- `init-container.ps1`: `21607FE7F753892953A0EC02DCDCD2709EDCA8BCCBBF8A23BF60F67F68653997` (appel enfant sans contrôle en pipeline).
- `docker-pipeline-deploy.ps1`: `A92E7CF05F79868F11ABEAC6D72867AC021D3E319309DA8A0B9D25B6815673C44`.
- `docker-pipeline-deploy-ps7.ps1`: `79980805D74A6F09EA6B1D0914099F4FE2C1240C7692D7FE066946F0C80B961C`.
- `task-deploy-in-containerized-job.v2.yml`: `B35C4A493A85245E2C823172F53925421D92F89DD829A51E7765FD8CFA3C1940`.

Les deux premiers hashes sont ceux déjà présents dans la collecte round1; les quatre derniers ont été recalculés sur le checkout local propre dont le commit correspond au tag V5.0.86. Aucun fichier partagé n'a été modifié au round4.

## Mise à jour Round 5 — archive et candidat de propagation

### Identité des trois objets à ne pas confondre

| Objet | Preuve | Portée |
|---|---|---|
| Source PlatformDeploy | tag `V5.0.86` → commit `93f91487...`; clone isolé `Y2_Tools_PlatformDeploy_worker3_r5b` | scripts source inspectables; identité du dépôt |
| Archive JFrog disponible le 2026-09-07 | même chemin, HTTP 200 documenté, 7 566 674 octets, SHA-256 `625EEC...`, `lastModified` daté | archive actuelle identifiée; binaire non conservé ici |
| Archive historiquement consommée par 4432602 | logs 215/243/244, chemin `PlatformDeploy.5.0.86.zip`, extraction réussie | version et chemin historiques; égalité SHA avec l'archive actuelle UNKNOWN |

La tentative directe sans authentification a répondu `401`, ce qui confirme que l'acquisition directe ne doit pas contourner le mécanisme secret autorisé. `jfrogToken.txt` n'a pas été ouvert.

### Correctif candidat local

Le seul changement du clone isolé est dans `Src/Powershell/Code/Scripts/init-container.ps1` : après l'appel à `deploy.ps1`, capture de `$LASTEXITCODE`, journalisation et exception immédiate si le code est non nul. Le comportement de succès reste inchangé par le diff; le worktree source `Y2_Tools_PlatformDeploy` n'est pas modifié.

Résultat du test processus réel (`test-platformdeploy-wrapper-process.ps1`) :

```text
beforeGuardPresent=false
afterGuardPresent=true
child 0      -> process 0
child 7      -> process 7
child throw  -> process 1, exception synthétique observée
```

Le test appelle le wrapper réel dans un staging temporaire avec un enfant contrôlé et nettoie ce staging. Il ne simule pas une installation MSI et ne constitue pas une validation de compatibilité V22/V23.

### Suite proposée

1. Revue propriétaire du candidat `init-container.ps1` et de la compatibilité PS5/PS7.
2. Test CI dédié ou test automatisé du wrapper avec code enfant non nul, sans cible SQL/IIS et sans publication.
3. Seulement après acceptation du correctif, revalider séparément les minima MSI; ne jamais conclure que la propagation corrigée rend les piles V22/V23 installables.
