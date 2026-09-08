# Résolution XmlDiffPatch.View — artefact Console officiel

Date : 2026-09-06  
Périmètre : inspection locale, sans compilation, exécution, réseau ni modification de projet.

## Provenance

- Artefact : `evidence/packages-current/AutoTest_Console_4311240/Cegid.Retail.AutoTest.Console.2.0.42.nupkg`
- Version/run : Console 2.0.42, run 4311240.
- SHA-256 nupkg : `4ACE80675261D7D5DAD2DB3F0E8C7983790E1983D32C12661FF980C54B16E5DE`.
- Extraction inspectée : `evidence/packages-extracted/console-2.0.42-current/`.
- Copies de preuve et SHA-256 : `metadata.csv`.

## Référence du projet

`worktrees/Y2_Tools_AutoTest_Console_Date_RJE/Cegid.Retail.AutoTest.Console/Cegid.Retail.AutoTest.Console.csproj` demande `XmlDiffPatch.View, Version=1.0.1493.40755, PublicKeyToken=59dd5855c27c6c17`, avec HintPath `..\packages\Cegid.Retail.XmlDiff.1.0.5\lib\net452\XmlDiffPatch.View.dll`; `SpecificVersion` n'est pas déclaré.

## Observations metadata-only

- L'artefact officiel ne contient aucun `XmlDiffPatch.View.dll`, `XmlDiffPatch.dll` ni `Cegid.Retail.XmlDiff.dll`; son nuspec et `cegid-packages.xml` ne désignent aucune de ces DLL.
- `Cegid.Retail.AutoTest.Console.exe` officiel : `2.0.42.0`, token `4a78b93fa9cdb37d`; références pertinentes : AutoTest.Api 1.1.46.0, AutoTest.Model 1.0.6.0 et Svn 1.0.4.0. Aucune référence XmlDiff.
- `Cegid.Retail.AutoTest.Api.dll` officiel : `1.1.46.0`, token `fe0ce61bd76bef19`; références pertinentes : IndentText, AutoTest.Model, CompareFileStream et Svn 1.0.2.0. Aucune référence XmlDiff.
- DLL locale du package XmlDiff 1.0.5 : `XmlDiffPatch.View 1.0.1493.40755`, token `8d9c769b09370619`, SHA-256 `30BA575A435A9B078BEF4A5D84641F243E33F31E422550943B2D77E518BA467D`.
- Candidats locaux 1.0.4 et 1.0.3 : tokens respectifs `1a0de8f0f7caa6ed` et `3675d7d1b79eb039`; aucun ne correspond à `59dd5855c27c6c17`.
- `Cegid.Retail.XmlDiff 1.0.5` local référence `XmlDiffPatch` 1.0.8.28 token `b03f5f7f11d50a3a`, mais n'établit pas l'identité demandée de `XmlDiffPatch.View`.

Les références ont été lues avec `System.Reflection.Metadata` depuis le runtime .NET local et `AssemblyName.GetAssemblyName`; aucun code d'assembly n'a été exécuté. Aucun fichier n'a été ajouté au staging, car aucune correspondance exacte n'existe.

Verdict : `UNKNOWN` pour la DLL correspondant exactement au projet. Prochaine action : identifier l'artefact/package qui fournit le token `59dd5855c27c6c17`, sans modifier la référence ni compiler avant cette preuve.
