# Dépendances Console alignées — vérification sans compilation

Date : 2026-09-06. Source inspectée : `worktrees/Y2_Tools_AutoTest_Console_Date_RJE`, commit `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`, état Git propre. Aucun fichier du projet ou du worktree n'a été modifié. Aucun build n'a été relancé.

La matrice complète des 17 références applicatives est `reference-matrix.tsv` : identité demandée, version `packages.config`, `HintPath`, `SpecificVersion` (non déclaré partout), candidats réels et statut. Les versions NuGet et versions d'assembly sont séparées.

Staging privé sans homonymes concurrents : `staging/allrefs/` contient 17 DLL résolues ou candidates, `staging/facades/` les 51 façades net452. L'API corrigée est conservée avec SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`. `staging-manifest.tsv` contient identité, source et SHA-256.

Références résolues par identité : API 1.1.46, Model 1.0.6, ColorConsole 1.0.1, CompareFileStream 1.0.0, IndentText 1.0.0, Svn 1.0.4, XmlDiff 1.0.5, CommandLine 1.9.71, ServiceLocation 1.3, Unity 4.0.1, Unity.Configuration 4.0.1, RegistrationByConvention 4.0.1, Prism.Core 6.1.0, Prism.Unity 6.1.1, Prism.Wpf 6.1.0 et XmlDiffPatch 1.0.8.28.

NuGet/assembly notable : Prism.Unity NuGet `6.1.1` fournit bien `Prism.Unity.Wpf` assembly `6.1.0.0`, conforme à la référence. `Cegid.Retail.Svn 1.0.4.0` provient de l'artefact local Console 2.0.42, run 4311240, nupkg SHA-256 `4ACE80675261D7D5DAD2DB3F0E8C7983790E1983D32C12661FF980C54B16E5DE`.

`Cegid.Retail.XmlDiff 1.0.5` a été récupéré en lecture seule depuis Artifactory all-nuget dans `packages/`, nupkg SHA-256 `05AFA18BA8304A74E9A8CC4B7FEA78C8FEA739896EAA0718B90C6AE40D50DDF7`. Il fournit `Cegid.Retail.XmlDiff 1.0.5.0` et `XmlDiffPatch 1.0.8.28` conformes.

Blocage : la référence `XmlDiffPatch.View` demande le token `59dd5855c27c6c17`. Le package 1.0.5 fournit le même nom/version mais le token `8d9c769b09370619`; le package 1.0.3 local fournit `3675d7d1b79eb039`. Aucun contournement, redirection ou substitution n'a été ajouté et cette DLL n'est pas dans le staging aligné.

Sources et commandes sans secrets : `logs/search-*.log`, `logs/download-*.log`, `sources.txt`. nuget.org ne contient pas `Cegid.Retail.XmlDiff`; Artifactory expose 1.0.5 et les candidats 1.0.4/1.0.3. Verdict : **pas prêt à retenter la compilation** tant que l'identité exacte de `XmlDiffPatch.View` n'est pas établie.
