# Clienteling round 2 evidence

Date : 2026-09-08. Les preuves sont des snapshots locaux déjà indexés ou des tests purs créés sous ce dossier.

- `Test-ClientelingEndpointMetadata.ps1` : cinq transitions XML contre HEAD source.
- `Test-ClientelingProductsManifest.ps1` : cinq manifestes MSI baseline, présence du SVC source dans chaque version et candidat V26.
- `Test-ClientelingFixtureContract.ps1` : contrat factice, sans IIS/SQL/Docker, qui rejette le placeholder et résout un dossier relatif de package.

Aucun secret, fichier de test brut distant ou contenu de token n’est copié dans cette preuve.
