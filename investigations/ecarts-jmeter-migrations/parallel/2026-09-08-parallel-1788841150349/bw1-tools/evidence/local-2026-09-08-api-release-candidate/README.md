# Candidat local API — 2026-09-08

## Provenance

- Date : 2026-09-08, collecte locale.
- Source : copie de travail du dépôt `Y2_Tools_AutoTest_Api`, HEAD initial `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.
- Patch appliqué : les quatre corrections déjà validées localement (`EscapeJdbcDate`, `FixSqlUnicodeValue`, `RemoveSpecialCharsForXQuery`, XPath SOAP `CleanXpath`).
- Version proposée : `Cegid.Retail.AutoTest.Api` `1.1.47`.
- Commit local : `16a03a83c7e4d9a7c65237f556a4167604ed294b`.
- Branche locale : `WI-2222897/clienteling/autotest-api-1.1.47`.
- Patch de reproductibilité : `16a03a8-api-correction.patch`, SHA-256 `C3688D2A2CED1AB959CFA7CDF9716E1B979DED0F78653575E8CB2952F6EB1E37`.

## Verdict

**FACT** — le commit local contient les quatre corrections et épingle l'incrément de version API `1.1.47`.

**FACT** — `git push` a atteint Azure DevOps mais a été refusé par `VS403660` : l'identité `rjegou@cegid.com` n'a pas le droit de créer `refs/heads/WI-2222897/clienteling/autotest-api-1.1.47`. La branche n'existe donc pas à distance.

**UNKNOWN** — aucune DLL, NuGet API/Console ou JMX n'est revendiqué comme produit par cette collecte : le poste ne possède pas les références .NET Framework 4.5.2 et le build local s'est arrêté sur `MSB3644`.

**UNKNOWN** — aucun pipeline API/Console n'a été lancé; aucune publication feed/JFrog n'a eu lieu.

## Contrat de consommation proposé après déblocage

1. Pipeline `2637` produit et publie l'API `1.1.47`.
2. Console consomme exactement API `1.1.47` et sort `Cegid.Retail.AutoTest.Console` `2.0.43`.
3. La migration épingle `versionConsole=2.0.43`; contrôle `checkPackage.ps1`, hash du `.nupkg`, hash de chaque DLL et hash des JMX régénérés.
4. Aucun consommateur ne doit utiliser une version flottante; la campagne Clienteling reste hors de cette collecte et relève de WORKER 3.

Ce contrat est une proposition, pas une preuve de package disponible.
