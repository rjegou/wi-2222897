# Round 3 — Azure DevOps readback and official constraints

Date de collecte : 2026-09-08 (Europe/Paris). Source : Azure DevOps REST HTTPS vérifié sur `https://dev.azure.com/cegid`; PAT lu en mémoire du processus, transmis uniquement à cet hôte, puis supprimé de l'environnement. Aucun objet distant n'a été créé ou modifié.

## Readback REST

- **FACT** — pool `79` est `Azure Pipelines`, `isHosted=true`, `size=100`. L'API retourne 100 agents déclarés; au snapshot, 98 sont offline et 2 online. Les agents exposent `osDescription` (Windows 10.0.20348/10.0.26100 et Ubuntu selon agent) mais aucune `systemCapabilities` dans la réponse.
- **FACT** — pool `94` est `Private VS2019`, `isHosted=false`, `size=20`. Les 20 agents sont online au snapshot, Windows `10.0.17763`, agent `4.270.0`; les capacités exposées ne contiennent ni Docker ni `FullTextValidation`.
- **FACT** — définition `14251` : `WI-2222897 SQL FullText Hosted Build Round11`, active, YAML `/validation/WI-2222897/sql-fulltext-hosted-build.yml`, dépôt `Pipelines_Docker_BaseImages`, queue `591`, pool `79` (`Azure Pipelines`, hosted).
- **FACT** — build `4442685` : failed, branche `refs/heads/sandbox/WI-2222897-sql-fulltext`, commit `e3b674b007071259fd74b024f6b4b48baf0a7f5d`, `2026-09-07T19:47:34Z`→`20:02:23Z`.
- **FACT** — build `4442156` : failed, même branche, commit `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`, `2026-09-07T16:42:52Z`→`16:58:11Z`.
- **FACT** — tentative `az pipelines ...` avec `AZURE_DEVOPS_EXT_PAT` en mémoire : échec avant HTTP sur `PermissionError` de `C:\Users\jegour\.azure\azureProfile.json`. La lecture REST directe a réussi en HTTPS et ne justifie donc pas un UNKNOWN d'absence de connecteur.

## Correction de formulation Microsoft-hosted

**FACT officiel** — Microsoft documente qu'un agent Microsoft-hosted fournit une VM fraîche pour chaque job, détruite après le job. Cela établit une exclusivité par job/VM allouée, pas une capacité Docker donnée ni un digest d'image donné. Source : https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops et https://learn.microsoft.com/en-us/azure/devops/pipelines/process/runs?view=azure-devops.

**FACT officiel** — les capabilities/demands servent surtout au routage des agents self-hosted; pour Microsoft-hosted, le choix se fait par image `vmImage`, et les capabilities système ne sont pas exposées comme pour un agent self-hosted. Source : https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops et https://learn.microsoft.com/en-us/azure/devops/pipelines/process/demands?view=azure-devops.

**FACT officiel** — la compatibilité Windows container dépend du build host/image; plusieurs couples sont bloqués si les builds diffèrent, avec exceptions documentées. Source : https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility.

**VERDICT** — l'ancienne formulation « Microsoft-hosted non dédié » était trop forte. Formulation correcte : `pool 79 est mutualisé au niveau du service, mais Microsoft garantit une VM fraîche par job; l'exclusivité de cette VM est donc FACT documentaire, tandis que la compatibilité Docker Windows effective, l'OS exact alloué au job, le digest final et l'absence de mounts/ports/endpoints applicatifs restent à prouver par le run.`

## Condition minimale manquante

Pour autoriser une queue Full-Text, il manque une preuve runtime de la VM effectivement allouée pour chaque stage : OS/build Windows, mode Docker, digest final SQL, inspection du conteneur avant SQL (`Mounts=[]`, ports publiés vides, réseau exclusif), et propriétaire de cleanup. Le pool 79 n'est pas une preuve suffisante de ces attributs; le pool 94 est explicitement inadapté au snapshot (`Windows 10.0.17763`, partagé, Docker non déclaré).
