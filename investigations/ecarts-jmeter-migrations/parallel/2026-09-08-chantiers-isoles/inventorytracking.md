# InventoryTracking : restaurer la campagne de 86 tests

Statut : proposé, non lancé. Espace exclusif : C:/clones/wi-2222897-bw/20260908/inventorytracking.
Lire et appliquer [CONTRAT.md](CONTRAT.md) avant toute action.

Lire findings/015 et 013 via leurs index. Revérifier en lecture seule les faits rapportés du
build 4445575 et la baseline 4440884. Télécharger les octets de Tests/WebServices/002-Device_Reassign.jmx
aux commits ef3d87034d38b88aca04c824061b140e2a29252c et
95aede774dcc45ba7e69abe163e6be410ae0c496 ; ne pas utiliser le champ JSON content comme preuve.
Attendus historiques : 4097371 octets / 39E6036031D1AD30304405D3E08DA159DA89B94F0E1ADC7B4BB6A5C14CFBE59E
et 4098601 octets / A59C06A49C64306F674143D4C4FAED73C234CD15047C0913BA47944C1CE313BA.
Comparer autour de la ligne 8522, expliquer HeaderManager cannot be cast to HashTree, remonter
au commit ou au script producteur. Reproduire le chargement avec JMeter 5.6.3 sans démarrer les
requêtes de la campagne (chargement seul avec les dépendances nécessaires, pas simple jmeter -n -t).
Si la cause appartient au plugin, corriger dans le clone privé et montrer échec avant/succès après.
Si elle appartient à l'API/générateur commun, livrer reproduction et proposition précise pour le
propriétaire couverture ; ne pas modifier ce composant ni attendre son travail.
Comparer les identités des 86 tests, dont TC122, avant/après. La présence/chargeabilité n'est pas
leur exécution : les 1991 résultats et le verdict métier TC122 resteront à prouver par un rejeu futur.
Livrer patch minimal, cause/producteur, preuve de chargement, inventaire restauré et commande ou
plan de rejeu isolé sans le lancer. Aucun nouveau run 2072, modification de définition, publication
ou intégration du fallback d'investigation dans une PR.
