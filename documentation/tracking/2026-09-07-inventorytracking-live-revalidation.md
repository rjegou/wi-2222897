# Revalidation live InventoryTracking — 2026-09-07

## Provenance

- Source : Azure DevOps `cegid/Retail`, collecte Worker 2 round2, lecture seule.
- Preuve primaire : `investigations/ecarts-jmeter-migrations/evidence/azure-devops-inventorytracking-2026-09-07-worker2-round2/`.
- PAT : lu uniquement en mémoire via `AZURE_DEVOPS_EXT_PAT`; sa valeur n'est pas conservée.
- Périmètre : builds, refs, commits, YAML et références de dépendances; aucune queue, PR, commentaire ou publication.

## État établi

| Objet | État |
|---|---|
| Build `4434070` | `failed`, branche `InventoryTracking_Migration_AutoTest_Jmeter_On_master`, commit `4de185bb...` |
| Cause immédiate | `Cegid.Retail.XmlDiff` non résolu dans VSBuild; `MSB3245` puis quatre `CS0103` |
| JMeter | stages `TI JMeter V26`, Cur et Fix skipped; aucune campagne exécutée |
| Master `4435986` | `succeeded`, mais ancien YAML sans `TI_Jmeter_V26`; ne valide pas la migration |
| PR InventoryTracking / WI 2222897 | `UNKNOWN` dans cette collecte: aucun artefact live WI/relations/PR fourni |

## Limites et suite

La branche de migration supprime `WebServices.Tests/packages.config`, qui portait `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28`, tandis que `Services.Tests` garde une référence vers `Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`. C'est la cause immédiate la mieux établie; le mécanisme exact package/restore/template reste à valider.

Le CSV/Excel historique et ce snapshot ne prouvent ni PR créée, ni validation JMeter, ni clôture du PBI. La prochaine preuve doit fournir la lecture live WI/relations/PR et un build local isolé du correctif candidat.
