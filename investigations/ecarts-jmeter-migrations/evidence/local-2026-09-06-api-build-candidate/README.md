# Compilation API corrigée — candidat local

Date : 2026-09-06. Projet seul compilé : `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/Cegid.Retail.AutoTest.Api/Cegid.Retail.AutoTest.Api.csproj`. État Git avant/après : worktree initial propre ; worktree corrigé avec uniquement `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` modifié.

MSBuild utilisé : `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe`, version `17.14.14.31908`. Configuration existante `Debug`, plateforme `AnyCPU`, cible projet `v4.5.2`, signature inchangée (`SignAssembly=true`). La clé locale référencée n'a pas été ouverte, copiée ou affichée.

Commande exacte : voir `logs/command.txt`. Elle invoque uniquement `/t:Build`, sans restore, et redirige `ReferencePath`, `FrameworkPathOverride`, `OutDir`, `OutputPath`, `BaseIntermediateOutputPath`, `IntermediateOutputPath`, `MSBuildProjectExtensionsPath` et `DocumentationFile` vers ce dossier.

Résultat : code de sortie `1`, `0` avertissement, `36` erreurs. Première erreur causale : `JmeterGenerator.cs(98,45) CS0012`, le type `IDisposable` exige `System.Runtime, Version=4.0.0.0, PublicKeyToken=b03f5f7f11d50a3a`; les erreurs suivantes répètent la même référence manquante dans plusieurs sources. Arrêt après cet échec, sans modification du projet ni nouvelle tentative.

Aucune DLL API n'a été produite, donc aucun SHA-256 ou identité d'assembly à relever. Les seuls fichiers générés sont le journal, le staging de références et des intermédiaires sous `obj/` de cette preuve. Les dossiers `Assemblies/Bin`, `Assemblies/XML`, `bin` et `obj` des deux worktrees API n'existent pas ; les `git status` restent conformes.

Limite : `System.Runtime` n'a pas été ajouté ni contourné à cette étape. Compilation API et génération JMX restent UNKNOWN.
