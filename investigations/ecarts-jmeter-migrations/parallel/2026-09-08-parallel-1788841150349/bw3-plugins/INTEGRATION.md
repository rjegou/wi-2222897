# Proposition d'intégration — InventoryTracking

À transmettre au lanceur/BW1 : lors de la suppression d'un projet de tests MSTest, calculer les dépendances des projets conservés avant de supprimer leur unique `packages.config`. Si une référence conservée pointe vers une assembly fournie par le projet supprimé, transférer explicitement le package et la référence vers le projet conservé, puis exécuter une résolution d'assemblies discriminante.

Cas prouvé : `Services.Tests` conserve `XmlDiff` (4 usages) mais la migration supprime le `packages.config` de `WebServices.Tests`, seul porteur de `Cegid.Retail.XmlDiff`/`XMLDiffPatch`. Correctif produit dans le clone privé uniquement; aucun migrateur n'a été modifié.

Ne pas conclure à la réussite JMeter : les stages de `4434070` étaient skipped et les builds revendiqués `4440774`/`4440884` n'ont pas été revérifiés ici.
