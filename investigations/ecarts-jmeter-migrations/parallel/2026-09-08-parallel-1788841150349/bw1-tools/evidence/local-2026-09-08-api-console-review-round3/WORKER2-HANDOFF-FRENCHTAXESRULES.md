# Handoff Worker 2 — FrenchTaxesRules API exacte

Utiliser exclusivement le candidat API suivant :

- dépôt `Y2_Tools_AutoTest_Api`, branche `sandbox/frenchtaxesrules/api-jmeter-fixes` ;
- commit `9081ecfe7aa07f5e584073d2af1828d3ac9f7235` ;
- build `2637/4444765` ;
- PipelineArtifact `Nuget` id `5036993` ;
- version `1.1.47-wi2222897-api-candidate` ;
- nupkg local : `C:\clones\wi-2222897\investigations\ecarts-jmeter-migrations\evidence\local-2026-09-08-api-publish-round2\artifacts\Cegid.Retail.AutoTest.Api.1.1.47-wi2222897-api-candidate.nupkg` ;
- DLL locale : `C:\clones\wi-2222897\investigations\ecarts-jmeter-migrations\evidence\local-2026-09-08-api-publish-round2\artifacts\Cegid.Retail.AutoTest.Api.dll` ;
- nupkg SHA-256 `296D7EAA4031138369C39986BE9F38264AF5BAB96AE0DC1D29E2380567BB864F` ;
- DLL SHA-256 `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.

Contrôle obligatoire : recalculer le hash avant compilation/staging et vérifier que la DLL placée
dans le package Console est exactement `A7D3…`. Le candidat Console local
`2.0.42-soapnamespace.20260907` est rejeté comme chaîne corrigée : son API interne est `1.1.46.0`,
hash `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B`. Ne pas utiliser ce
package sans remplacement et rehash.

Le diff Console `7d0667c90db1eca8e18e94f8fb4b572f9a9ee8e8` reste à relire directement; son effet
sur la référence API est `UNKNOWN`. Après build, conserver nupkg, nuspec, DLL/EXE, hashes, timeline
et logs. Aucun feed partagé, Promote, Tag, TestAutos ou queue aval inutile.
