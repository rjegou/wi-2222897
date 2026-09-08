# brain-worker — outil local disponible

## Fait constaté

**FACT — 2026-09-08.** L'outil local `brain-worker` est disponible dans le dépôt suivant :

```text
C:\Users\jegour\brain-worker
```

Ce chemin est la référence locale à utiliser pour consulter son fonctionnement. Le présent dépôt
ne copie pas son code et ne crée pas de dépendance versionnée vers ce dossier.

## Fonctionnement et point d'entrée

La description opérationnelle est dans le fichier suivant du dépôt local :

```text
C:\Users\jegour\brain-worker\README.md
```
Elle couvre notamment :

- le démarrage d'une mission avec `remote.ps1` ;
- l'envoi d'un complément à une session avec `tell.ps1` et son `SessionId` exact ;
- les tests locaux avec `npm ci` puis `node --test` ;
- les états de fin (`DONE`, `STOP`, `FAILED`) et les limites liées aux timeouts et aux interruptions.

Exemple de point d'entrée, à adapter au workspace et à la mission :

```powershell
& C:\Users\jegour\brain-worker\remote.ps1 `
  -Path 'C:\chemin\workspace' `
  -MaxRounds 12 `
  -Mission 'Décris ici la mission à traiter'
```

## Limites de preuve

**UNKNOWN —** la présence de ce dépôt sur ce poste ne prouve ni sa disponibilité sur un autre poste,
ni l'exécution ou la réussite d'une mission donnée. Les tests documentés dans son README utilisent
des doubles et ne lancent pas de mission réelle.
