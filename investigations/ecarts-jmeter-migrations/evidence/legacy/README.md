# Preuves legacy collectées

Point d'entrée LLM : [curated/00_START_HERE.md](curated/00_START_HERE.md).

## Organisation

| Dossier | Contenu | Règle |
|---|---|---|
| `curated/` | 11 index Markdown orientés runner/plugin/branche | lire avant les fichiers bruts |
| `raw/source-staging/` | staging de collecte, 16 155 fichiers relevés avant réorganisation | provenance brute ; ne pas supposer qu'il est identique à une archive |
| `raw/primary-package-extracted/` | extraction du paquet principal, 343 fichiers relevés | collection brute et ancien index |
| `raw/missing-supplement/` | complément PublishedReports/PublishTRX/Workflow, 475 fichiers relevés | collection brute complémentaire |
| `archives/` | deux paquets ZIP reçus | conserver inchangés |

## Empreintes des archives

| Archive | SHA-256 vérifié le 2026-09-06 |
|---|---|
| `LegacyEvidence-20260906-071608.zip` | `840A6F358D2CDCBA43AC6FDBEF4594BB257D094C69C380B1783491F54108663B` |
| `LegacyEvidence-Missing-20260906-073621.zip` | `ECD103E47A4B0B4F0B65EF572FC47EA39F527A2D0968DF5214C5879ECC081A57` |

Ne pas modifier les manifestes, hashes ou chemins d'origine à l'intérieur des lots bruts : ils documentent la collecte sur la machine source. Les chemins de navigation actuels sont maintenus dans `curated/` et dans l'index parent.
