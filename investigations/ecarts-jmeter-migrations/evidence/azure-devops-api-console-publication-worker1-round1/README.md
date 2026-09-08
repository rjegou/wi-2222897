# Publication API → Console → migration — Worker 1 round 1 — blocage d’accès

## Provenance

- Date : 2026-09-08 (Europe/Paris)
- Système source : poste local, Azure DevOps `https://dev.azure.com/cegid/Retail`
- Périmètre : publication autorisée de la chaîne `Cegid.Retail.AutoTest.Api` →
  `Cegid.Retail.AutoTest.Console` → `Migration_Jmeter_RJE_Sandbox`
- Méthode : lecture des consignes et preuves locales, contrôle Git des worktrees présents,
  tentative de lecture REST Azure DevOps avec le PAT local autorisé en mémoire du processus,
  tentative de lecture Git et tentative de session CLI Azure DevOps isolée
- Fraîcheur : collecte nouvelle, état distant non obtenu

## Résultats

### FACT

- `patches/README.md` confirme que les quatre corrections du générateur JMX sont sauvegardées
  localement mais ni committées, ni poussées, ni packagées, ni publiées.
- `investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md` identifie la chaîne et les
  versions historiques `Cegid.Retail.AutoTest.Api` 1.1.46 et `Cegid.Retail.AutoTest.Console`
  2.0.42 comme références à remplacer après correction.
- Le PAT autorisé existe à `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`.
  Son contenu n’a pas été affiché, journalisé, persisté dans ce dépôt ou copié dans une sortie.
- `git ls-remote` vers les trois dépôts Azure DevOps retourne le code 128 sans référence lue.
- La requête REST du dépôt `Y2_Tools_AutoTest_Api` échoue avant réponse avec
  `System.Net.Http.HttpRequestException: The SSL connection could not be established`.
- `curl.exe` vers Azure DevOps et NuGet échoue avec
  `schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS (0x8009030E)`.
- `az devops configure --list` global échoue sur `C:\Users\jegour\.azure\azureProfile.json`
  avec `PermissionError`. Une configuration temporaire isolée ne possède aucune session valide.
- La lecture de l’onglet Azure DevOps déjà ouvert a été refusée par la politique de sécurité du
  navigateur ; aucun clic, lancement, publication ou modification distante n’a été effectué.
- Les dépôts locaux `C:\clones\Migration_Jmeter_RJE_Sandbox` et
  `C:\clones\Y2_Tools_PlatformDeploy` refusent `git status` pour `dubious ownership` dans ce
  processus. Aucun `safe.directory` global n’a été ajouté et aucun worktree n’a été modifié.

### UNKNOWN

- HEAD et état actuels des dépôts API, Console et migration.
- Version réellement disponible du package API/Console et contenu/hash d’un package publié.
- Destination de feed autorisée, branche de publication, build de packaging et artefact NuGet.
- Correspondance commit source → API → Console → package de migration.
- Régénération FrenchTaxesRules et vérification des JMX résultants.
- Exécution d’un pipeline build + tests JMeter et résultat métier.

## Blocage opérationnel

La chaîne ne peut pas être publiée ou vérifiée dans cette session tant qu’un accès sortant TLS
fonctionnel vers Azure DevOps (ou un artefact/checkout local explicitement fourni) n’est pas
disponible. Relancer une publication sans pouvoir lire les refs, les builds et les artefacts
violerait l’exigence de preuve et pourrait écraser ou promouvoir une version inconnue.

## Postcondition

Aucune mutation externe n’a été exécutée. Aucun secret n’est présent dans ce dossier.
