# Comparaison source live

Collectée par REST le 2026-09-08, sans écriture distante.

## Commits

- `4de185bb132cfbfb50643b6b53d6feb85508f4e2` — `dereferencement`, parent `33bcac946d82dbb655c45b10693896286a98043f`, 2026-09-04. Ce commit est la tête actuelle de `InventoryTracking_Migration_AutoTest_Jmeter_On_master`.
- `ef3d87034d38b88aca04c824061b140e2a29252c` — `Fix InventoryTracking XmlDiff test dependencies`, parent `4de185bb...`, 2026-09-07. Le commit reste accessible par son identifiant mais n'est pas la tête de la branche migration.
- `master` actuel : `20aa528945ac33ba94598222b66fa3071c7e87b9`.

## Diff exact ef3d8703 contre son parent

```diff
diff --git a/Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj b/Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj
--- a/Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj
+++ b/Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj
@@
-    <Reference Include="Cegid.Retail.XmlDiff">
-      <HintPath>..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll</HintPath>
+    <Reference Include="Cegid.Retail.XmlDiff, Version=1.0.0.0, Culture=neutral, PublicKeyToken=3ea389785c619660, processorArchitecture=MSIL">
+      <SpecificVersion>False</SpecificVersion>
+      <HintPath>..\Sln\packages\Cegid.Retail.XmlDiff.1.0.0\lib\net452\Cegid.Retail.XmlDiff.dll</HintPath>
@@
-    <Reference Include="System.Xml" />
-    <Reference Include="System.Xml.Linq" />
+    <Reference Include="System.Xml" />
+    <Reference Include="System.Xml.Linq" />
+    <Reference Include="XmlDiffPatch, Version=1.0.8.28, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a">
+      <HintPath>..\Sln\packages\XMLDiffPatch.1.0.8.28\lib\net\XmlDiffPatch.dll</HintPath>
+    </Reference>
diff --git a/Cegid.Retail.InventoryTracking.Services.Tests/packages.config b/Cegid.Retail.InventoryTracking.Services.Tests/packages.config
--- a/Cegid.Retail.InventoryTracking.Services.Tests/packages.config
+++ b/Cegid.Retail.InventoryTracking.Services.Tests/packages.config
@@
 <packages>
+  <package id="Cegid.Retail.XmlDiff" version="1.0.0" targetFramework="net48" />
@@
   <package id="System.Threading.Tasks.Extensions" version="4.5.4" targetFramework="net48" />
+  <package id="XMLDiffPatch" version="1.0.8.28" targetFramework="net48" />
 </packages>
```

## PR target

**FACT:** the migration branch is four commits ahead of master; the REST diff reports aggregate
counts `Add=944`, `Edit=8`, `Delete=3125`, plus rename combinations. The API request was capped at
200 returned paths, so this is a count summary, not a complete path listing in this file.

**INFERENCE:** if the WI requires merging the InventoryTracking migration, the PR source must be a
branch containing the migration state rooted at `4de185bb...` plus `ef3d8703...` (or an equivalent
reviewed successor). A PR containing only the two XmlDiff dependency edits would fix the build cause
but would not constitute the migration. The operator should create/update the PR only after confirming
the intended migration files and target branch with the source owner.

**UNKNOWN:** whether the 4de migration commit contains every functional migration file expected by
the WI, and whether any files were intentionally excluded. This cannot be resolved from aggregate
diff counts alone.
