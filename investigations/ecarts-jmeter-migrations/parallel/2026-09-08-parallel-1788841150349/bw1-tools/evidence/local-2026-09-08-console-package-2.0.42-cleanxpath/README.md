# Package Console local exploitable — 2026-09-08

## Provenance

- Source : staging temporaire local `C:\Users\jegour\AppData\Local\Temp\wi2222897-console-package-migration-20260907-b`.
- Nuspec : `Cegid.Retail.AutoTest.Console` `2.0.42-cleanxpath.20260907`.
- SHA-256 nupkg : `82F9C7EE19E635DB14F937078339ED5424A2EDE5BE13B2A10F75A790400D70C0`.
- API embarquée : `Cegid.Retail.AutoTest.Api.dll`, SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`.
- Console embarquée : `Cegid.Retail.AutoTest.Console.exe`, SHA-256 `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F`.
- Provenance documentaire : `evidence/local-2026-09-07-console-package-migration-isolated/` et `evidence/local-2026-09-07-package-fixsqlunicode-postcondition/`.

## Contrôle de contenu

**FACT** — l’archive a été extraite et son nuspec/ensemble `tools/` relus le 2026-09-08. Elle contient l’exécutable Console, l’API `51FB…` et les dépendances listées dans l’archive.

**FACT** — la preuve ciblée `local-2026-09-07-package-fixsqlunicode-postcondition` établit que l’API `51FB…` ne contient pas le correctif `FixSqlUnicodeValue` attendu pour les apostrophes SQL doublées. Ce package ne doit donc pas être présenté comme le package final des quatre corrections.

## Comparaison avec le candidat SOAP signalé par WORKER 3

| Élément | Candidat SOAP rapporté | Artefact réellement disponible ici |
|---|---|---|
| Package | `2.0.42-soapnamespace.20260907`, `803DDBAA…` | `2.0.42-cleanxpath.20260907`, `82F9C7EE…` |
| API DLL | `57BEACA2…` | `51FB31F7…` |
| SOAP namespace-aware | rapporté FACT par la preuve round13 | non revendiqué ici |
| EscapeJdbcDate / FixSqlUnicodeValue | rapporté par réflexion dans une collecte distincte, mais non revalidé sur le fichier du package ici | FixSqlUnicodeValue explicitement non corrigé |
| RemoveSpecialCharsForXQuery | non hashé explicitement vers `57BE…` dans les preuves consultées | non revendiqué ici |

**UNKNOWN** — le nupkg `803D…` et la DLL `57BE…` ne sont pas présents dans les artefacts accessibles; leur contenu ne peut pas être recontrôlé indépendamment dans cette session.

## Usage sûr

Ce fichier est un artefact local de diagnostic, non publié. Toute consommation doit utiliser le chemin exact, vérifier le SHA-256 ci-dessus et conserver `2.0.42-cleanxpath.20260907` distinct de la future version API `1.1.47` / Console `2.0.43` proposée. Ne pas lancer la campagne Clienteling avec ce package comme preuve des quatre corrections.
