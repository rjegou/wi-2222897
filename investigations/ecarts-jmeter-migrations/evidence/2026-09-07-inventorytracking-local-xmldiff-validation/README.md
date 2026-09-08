# InventoryTracking XmlDiff local validation

Date: 2026-09-07

## Scope

Migration commit:

4de185bb132cfbfb50643b6b53d6feb85508f4e2

Worktree:

InventoryTracking_Migration_AutoTest_Jmeter_On_master_worker2

The existing worker patch modifies:

- Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj
- Cegid.Retail.InventoryTracking.Services.Tests/packages.config

## Patch under validation

The patch makes Services.Tests explicitly own the dependencies that were previously supplied through the removed WebServices.Tests/packages.config:

- Cegid.Retail.XmlDiff 1.0.0
- XMLDiffPatch 1.0.8.28

The Cegid.Retail.XmlDiff reference now targets:

..\Sln\packages\Cegid.Retail.XmlDiff.1.0.0\lib\net452\Cegid.Retail.XmlDiff.dll

The XMLDiffPatch reference targets:

..\Sln\packages\XMLDiffPatch.1.0.8.28\lib\net\XmlDiffPatch.dll

## NuGet restore validation

A local 
uget restore of Sln\InventoryTracking.sln completed successfully.

Results:

- NuGet exit code: 0
- Cegid.Retail.XmlDiff.1.0.0 restored successfully from Cegid JFrog
- XMLDiffPatch.1.0.8.28 restored successfully
- both expected DLLs exist under Sln\packages

## Targeted MSBuild validation

The .NET Framework 4.8 reference assemblies were supplied locally through the NuGet package:

Microsoft.NETFramework.ReferenceAssemblies.net48 1.0.3

Command intent:

ResolveAssemblyReferences on Cegid.Retail.InventoryTracking.Services.Tests.csproj, with project-reference builds disabled.

Result:

- MSBuild exit code: 0
- Cegid.Retail.XmlDiff resolved successfully to the new NuGet HintPath
- XMLDiffPatch resolved successfully to the new NuGet HintPath
- no XmlDiff resolution failure detected

This directly validates the dependency-resolution mechanism targeted by the patch.

## Full local build limitation

A complete local build was also attempted.

It progressed past the .NET Framework 4.8 targeting-pack issue but stopped in Cegid.Retail.InventoryTracking.ServiceContracts because several Cegid external assemblies are not populated locally, including:

- Cegid.Framework.Common
- Cegid.Retail.Common
- Cegid.Retail.Tools

This causes downstream VersionningNamespace compilation errors.

Therefore the full local build is not a valid end-to-end confirmation of the pipeline, but this blocker is distinct from the XmlDiff failure.

## Current conclusion

The local evidence strongly supports the proposed XmlDiff fix:

1. the required packages are restorable;
2. the expected DLLs exist;
3. MSBuild resolves both references successfully from their new NuGet locations;
4. the original XmlDiff resolution failure is absent from the targeted resolution step.

A real Azure DevOps pipeline execution remains the appropriate end-to-end validation when desired.
