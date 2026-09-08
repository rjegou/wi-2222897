# Clienteling : retrouver le backup V26 et le transport des images

Statut : proposé, non lancé. Espace exclusif : C:/clones/wi-2222897-bw/20260908/clienteling.
Lire et appliquer [CONTRAT.md](CONTRAT.md) avant toute action.

Lire finding 016, plan de correction item 7 et synthèses techniques via leurs index.
Priorité 1 : vérifier si l'objet LFS historique du backup Clienteling est récupérable :
8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C, 156663808 octets,
Tests/Backups/AUTO_V26_00.bak. Une réponse de métadonnées ne suffit pas : si téléchargeable,
obtenir le fichier dans l'espace privé et vérifier taille/hash. Ne pas le confondre avec le backup
homonyme FrenchTaxesRules. Revérifier ref/HEAD c20755d8 rapporté, l'absence du chemin et le
checkout LFS. Préparer localement le changement minimal de pointeur LFS/.gitattributes/checkout
pour 14264, sans push et sans mettre le binaire en Git classique. Si indisponible, chercher seulement
les copies historiques indexées et documenter le blocage précis.

Priorité 2, indépendante : retrouver les onze fixtures JPG historiques, leur disparition et la
résolution de CustomImageLocation. Suivre sources, artefact/MSI ou montage, déploiement et chemin
vu par IIS ; inventorier les huit cas Image:GetSerialNumberImage concernés. Ne pas inventer une
copie ad hoc sans vérifier le mécanisme existant. Proposer ou corriger localement le transport dans
le plugin si sa responsabilité est prouvée ; sinon livrer un contrat de transport et un patch proposé
sans éditer PlatformDeploy commun. Le périmètre produit décidé est master, releases/V6/V7/V8 ;
commencer par V26 pour la cible 14264 puis cartographier les différences nécessaires.

Réutiliser PlatformDeploy 5.0.86/configs rapportées et les wrappers replay-prep comme entrées,
sans rouvrir les agents privés A/B. Livrer hashes backup/fixtures, provenance, chemins IIS prouvés
ou UNKNOWN, patch local révisable et prérequis restants de 14264 (image/digest/réseau/SQL/IIS/
endpoints/cleanup). Aucun conteneur, restauration SQL, campagne, queue 14264 ou modification
d'image Full-Text. La génération et les packages API/Console sont hors propriété de cette instance.
