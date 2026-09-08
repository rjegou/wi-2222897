# Candidat de compilation Console — EscapeJdbcDate

Date : 2026-09-06. Worktree dédié : `worktrees/Y2_Tools_AutoTest_Console_Date_RJE`, branche `sandbox/rje-wi2222897-console-date`, commit `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`. Le worktree source `Y2_Tools_AutoTest_Console` est resté propre au même commit.

Staging privé : `staging/allrefs/` contient 18 DLL et `staging/facades/` les 51 façades net452 déjà validées. L'API corrigée demandée est présente avec l'identité `Cegid.Retail.AutoTest.Api, Version=1.1.46.0, PublicKeyToken=fe0ce61bd76bef19` et SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`. Le manifeste consigne chaque source, identité et hash.

La commande MSBuild est dans `logs/command.txt`; MSBuild 17.14.14, `.csproj` seul, `Debug|AnyCPU`, `ReferencePath` vers le staging, `FrameworkPathOverride` vers les références net452 et import externe des façades. Aucun restore, pack ou téléchargement n'a été effectué. La signature est restée active ; la clé n'a pas été ouverte ni copiée.

Résultat réel : code `1`, première erreur causale `CS0234` sur `Cegid.Retail.Svn` dans `Program.cs`. Le projet demande `Cegid.Retail.Svn 1.0.4.0`; le fichier initialement stagingué depuis la preuve API est `1.0.2.0`. L'identité Console exacte `1.0.4.0` existe dans l'artefact local `packages-extracted/console-2.0.42-current/tools`, mais la compilation a été arrêtée après ce constat.

Blocage indépendant : le projet demande `Cegid.Retail.XmlDiff 1.0.5.0` et `XmlDiffPatch.View` avec PublicKeyToken `59dd5855c27c6c17`; les preuves locales disponibles portent `Cegid.Retail.XmlDiff 1.0.3.0` et `XmlDiffPatch.View` token `3675d7d1b79eb039`. Aucune substitution n'a été appliquée.

Sorties conservées : journal MSBuild, intermédiaires et `build/obj/Debug/Cegid.Retail.AutoTest.Console.exe.config`; aucun `.exe` Console final ni API copiée à côté n'a été produit. Console n'a pas été exécutée. Génération JMX via Console reste UNKNOWN.
