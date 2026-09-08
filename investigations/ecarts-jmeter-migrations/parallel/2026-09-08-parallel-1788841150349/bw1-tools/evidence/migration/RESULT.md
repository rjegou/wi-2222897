# Résultat

Date de collecte : 2026-09-08.

## FACT

- `step_00_miseEnPlaceRepo.ps1` lit `versionConsole` depuis `migration-tools/consoleWorkflowVersions.json` et l’écrit dans `PublishedSharedTools/packages.config`.
- `Testautos2Jmeter.bat` transmet `Tools_Path`, le nupkg installé et `CachedNupkgPath` à `checkPackage.ps1`, puis appelle le convertisseur par campagne depuis le XML legacy.
- `checkPackage.ps1` lit la version du `.nuspec`, exige `tools/Cegid.Retail.AutoTest.Console.exe`, restaure le cache si la version correspond, et retourne `1` sinon.
- Test local exécuté : cache absent côté installation + cache 2.0.41 → restauration code `0`, exe et nupkg présents; second passage installé valide → code `0`; configuration attendue 2.0.42 avec cache 2.0.41 → code `1`. Résultats : `checkPackage-test-results.txt`.

## INFERENCE

La sélection version/cache est actuellement vérifiable et fail-closed sur une version divergente. La génération réelle depuis XML legacy n’a pas été lancée ce round (pas d’artefact Console corrigé injecté).

## UNKNOWN

La propagation API corrigée → package Console → cache migration → JMX reste non démontrée dans ce clone. La réussite d’une campagne métier reste inconnue.

`Testautos2Jmeter.bat` appelle `PublishedSharedTools/packageInstaller.ps1` en cas de mismatch; ce fichier n’appartient pas à `migration-tools`, mais il est présent dans les snapshots de plugins. Ce n’est donc pas un défaut générique prouvé du dépôt migration; vérifier sa présence dans chaque plugin avant migration.

## Correction locale prouvée

`step_x_06_deref_avant_PR.ps1` a été corrigé dans le clone local pour retirer les projets legacy `WebServices.Tests` et `LegacyServices.Tests` (dossiers et blocs `.sln`). La fixture finale retire les deux dossiers et projets, supprime `IntegratedTests`, et conserve la dépendance `Y2.Core.Common`. Aucun plugin/BW3 n’a été modifié.

Empreinte du fichier patché : SHA-256 `EE97076D49FE53BB7B83901956BD2A57E08D75FC4CAD84D8BD25C883A394268B`.
