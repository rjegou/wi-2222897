# Couverture BeforeMigration et chaîne de génération isolée

Statut : proposé, non lancé. Espace exclusif : C:/clones/wi-2222897-bw/20260908/couverture.
Lire et appliquer [CONTRAT.md](CONTRAT.md) avant toute action.

Mesurer puis corriger le défaut de précédence de RemoveTestCases dans BeforeMigration.ps1,
et régénérer les tests réellement concernés. Retrouver d'abord le dépôt, la branche et les sources
exactes via la décision 6, la trace de PR 505832/thread 3573422 et l'entrée du 2026-09-04 du journal.
Ne pas supposer que ce script appartient à Clienteling ou InventoryTracking.
Comparer sur les mêmes sources la sélection originale et la sélection parenthésée : identités,
labels, critères A/B/C, conservés/supprimés et delta. Distinguer le défaut logique de son impact réel.
Ajouter une vérification discriminante couvrant EC/non-EC et les trois critères, puis appliquer le
correctif minimal dans le clone privé du propriétaire. Si le delta réel est nul, le prouver et ne pas
inventer de tests à régénérer. Sinon régénérer les plans affectés en conservant les tests non concernés.

Réutiliser les candidats API build 4444962/artifact 5037204 et Console build 4445025/artifact
5037277, version Console 2.0.43 ; SHA-256 nupkg
796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE.
Revalider l'identité des entrées et exploiter les preuves existantes, sans reconstruire une chaîne
déjà validée sans motif. Prouver la DLL embarquée et le package réellement consommé par cette
régénération ; inventorier et hasher les sorties. Ne pas prendre les 19 JMX FrenchTaxesRules pour
l'inventaire d'un autre plugin. Vérifier leur structure/chargement local sans envoyer d'appels métier.
Livrer delta nominatif, patch script, tests, manifestes des JMX régénérés et résultat de validation
isolée borné. Un défaut commun requis par InventoryTracking est une dépendance de seconde passe,
pas un motif de modifier le clone ou les sorties de l'autre instance. La publication reste différée.
