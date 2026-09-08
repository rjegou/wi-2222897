# Preuve Clienteling endpoint metadata

Date : 2026-09-08. Source : dépôt local `Y2_Plugins_Clienteling`, HEAD `0c0fd26533e46b13e029276f90b5c085c1804012`; le worktree source avait cinq modifications locales avant reprise. Méthode : `Test-ClientelingEndpointMetadata.ps1` lit chaque fichier au HEAD via Git, parse le candidat XML exclusif et vérifie précisément la transition attendue.

Commande expurgée : `powershell -NoProfile -ExecutionPolicy Bypass -File Test-ClientelingEndpointMetadata.ps1 -SourceRepo <source-local> -CandidateRoot <bw3>/worktrees/clienteling`.

Résultat : **PASS** — cinq transitions attendues, XML valide. Aucun environnement, HTTP, MSI, JMeter, Docker, SQL ou pipeline exécuté.

Voir [MANIFEST.csv](MANIFEST.csv) pour les SHA-256 des fichiers candidats et du test.
