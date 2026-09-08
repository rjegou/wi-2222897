# Audit borné du support Products Clienteling — Worker 2 round 2

Date : 2026-09-07 (Europe/Paris). Périmètre : `ClientelingProductsService.svc`
et `Products:GetItemsV2`, versions V22 à V26. Hors FrenchTaxesRules et hors
génération/correction Deployment/Mobility déjà prouvée. Aucun worktree,
Products, document partagé, pipeline, MSI, cible ou ressource distante n'a été
modifié. Aucun propriétaire n'a été contacté.

## Méthode et provenance

L'index `evidence/README.md`, la collecte précédente
`2026-09-07-clienteling-endpoint-packaging-worker2-round1` et les collectes
sources rounds 3–5 ont été lues avant les recherches ciblées. Les findings
005–008, les snapshots exacts V22/V23/V24/V25/V26 et les JTL/XML Products
existants ont ensuite été relus. Les empreintes des notes et XML principaux
sont dans `MANIFEST.csv` et `SHA256SUMS.txt`.

## Preuves de support et de packaging

**FACT — introduction technique.** La preuve round3 rattache le commit
`805f68489` (`feat: add Product GetItemsV2`) au work item `#668989`. Les
snapshots V22–V26 contiennent le code `.svc`, le contrat/plan
`Products_GetItemsV2.xml` et le JMX qui cible `ClientelingProductsService.svc`.
Cela prouve une introduction technique et une intention de test, pas une
garantie de support MSI par version.

**FACT — absence dans les manifests.** Les manifests exacts inspectés pour
V22, V23, V24, V25 et V26 listent les services Clienteling Deployment/Mobility
et d'autres services, mais pas `ClientelingProductsService.svc`. Les findings
005–008 qualifient cette absence pour V22/V23/V24/V25/V26 et proposent soit un
packaging, soit le retrait des cas selon la décision de support.

**UNKNOWN — norme de support.** La recherche locale ciblée ne contient ni
documentation de contrat de support par version, ni PR/artefact normatif qui
transforme le commit introducteur en obligation d'installation MSI. La lecture
Azure DevOps du work item `668989` a été tentée avec le PAT local, sans afficher
ni persister le secret, mais a échoué avant réponse sur Schannel :
`SEC_E_NO_CREDENTIALS`. Cela ne prouve ni l'absence ni l'existence d'une PR ou
d'une décision distante; cette piste distante reste non vérifiée.

## Preuves runtime existantes

**FACT — appels historiques Products observés.** Les XML JTL conservés montrent
les sous-échantillons `Products:GetItemsV2 ... B-XQuery` avec `rc=404` et
`rm=Not Found` :

| version / build | variante(s) relue(s) | appels B-XQuery | résultat |
|---|---|---:|---|
| V22 / 4432602 | Cur | 9 | 404:9 |
| V23 / 4432602 | Cur | 9 | 404:9 |
| V24 / 4432652 | Cur, Fix | 10 par variante | 404:10 par variante |
| V25 / 4432672 | Cur, Fix | 10 par variante | 404:10 par variante |
| V26 / 4432554 | Cur, Fix | 10 par variante | 404:10 par variante |

Les tokens AuthServer et certaines pré/post-requêtes peuvent être `200`; ils
ne constituent pas une réponse Products réussie. Le `404` démontre le résultat
HTTP de ces campagnes historiques, mais ne distingue pas à lui seul absence de
packaging, routage ou autre configuration IIS.

## Cible isolée

**FACT limité.** Les findings V24/V25/V26 attestent des jobs historiques ayant
déployé leur pile et exécuté JMeter; les XML conservent des hostnames de
conteneur éphémères. **UNKNOWN** : aucune cible Clienteling dédiée, encore
active et réutilisable, n'est identifiée dans les preuves. Aucun déploiement ou
rejeu n'a été créé/lancé pour lever cette lacune.

## Verdict

Le support Products ne peut pas être établi par les preuves accessibles :
introduction technique et tests présents, mais absence répétée du service dans
les manifests et réponses HTTP 404. Conserver `UNKNOWN`; ne pas modifier
Products et ne pas activer/rejouer ses cas.

Pré-requis réellement irréductibles :

1. preuve normative accessible (work item/PR/contrat ou manifeste MSI validé)
   indiquant le statut supporté de Products par version ;
2. si supporté, artefact MSI contenant le service et cible IIS dédiée identifiée,
   puis smoke HTTP séparé avec postcondition observable ;
3. si non supporté, décision/versioning explicite avant retrait ou désactivation
   des cas.
