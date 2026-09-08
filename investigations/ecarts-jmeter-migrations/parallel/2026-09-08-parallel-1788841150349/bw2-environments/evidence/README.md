# Index des preuves BW2

Date : 2026-09-08 (Europe/Paris). Les preuves sont locales, expurgées et limitées au périmètre BW2.

- [PlatformDeploy](platformdeploy/README.md) : revue du garde MSI existant, contrats de version/health checks, patch local de propagation du retour `deploy.ps1`, harness success/nonzero/exception/résiduel.
- [PlatformDeploy — consommation historique](platformdeploy/README.md) : `4432602` résout `5.0.86` / `V5.0.86` → `93f91487...`; `4432554` et `4432510` restent sans version PlatformDeploy prouvée.
- [PlatformDeploy — packaging Round 4](platformdeploy/round4-packaging-azdo.md) : archive privée, hashes source/extraction et lecture AzDO ciblée bloquée par TLS.
- [Full-Text](fulltext/) : preuves et revue du diagnostic SQL Full-Text existantes; `CONTAINSTABLE` reste non atteint.

## Règle de lecture

Les tests locaux inertes ne prouvent ni installation MSI réelle, ni environnement Docker/SQL/IIS, ni succès de migration JMeter. Les runs historiques et les images partagées restent hors de cette collecte.
