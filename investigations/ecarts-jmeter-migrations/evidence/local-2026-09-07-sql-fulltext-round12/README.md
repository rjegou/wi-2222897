# SQL Full-Text preparation — 2026-09-07

## Repository and correction

FACT — `worktrees/Pipelines_Docker_BaseImages` was `master` before this round with the existing local changes limited to `Images/SqlExpress/2019/dockerfile` and `Images/SqlExpress/tests.yml`; those changes were preserved.

FACT — `Images/SqlExpress/2025/dockerfile` previously invoked setup with `/FEATURES=SQLENGINE` at the SQL Server 2025 setup command. The minimal local correction changes only this argument to `/FEATURES=SQLENGINE,FullText`.

Microsoft Learn documents that `/FEATURES=SQLEngine` installs only the Database Engine and `/FEATURES=SQLEngine,FullText` installs the Database Engine and Full-Text: https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt?view=sql-server-ver17. Microsoft’s SQL Server 2025 release notes state that Express includes functionality formerly in Express with Advanced Services: https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2025?view=sql-server-ver17. The first fact establishes the need for explicit feature selection in this command; the second establishes media capability, not proof of installation.

## Inert tests.yml control

FACT — The actual Full-Text task body was extracted at runtime from `Images/SqlExpress/tests.yml`; it was not retyped or reimplemented. A PowerShell `sqlcmd` function substituted only the native command boundary. Cases:

- output `1`, exit 0: accepted;
- output `0`, exit 0: rejected;
- output `NULL`, exit 0: rejected;
- empty output, exit 0: rejected;
- synthetic output plus exit 7: rejected with the non-zero exit path.

No SQL process or container was started.

## 2019 media boundary

FACT — The preserved 2019 patch selects `/MediaType=Advanced`, expects `C:\tmp\SQLEXPRADV_x64_ENU.Exe`, extracts to `C:\tmp\SQLEXPRESS_SETUP`, and invokes `SETUP.EXE` with `/FEATURES=SQLENGINE,FullText`. Microsoft’s official SQL Server 2019 download page identifies `SQLEXPRADV` as the Express with Advanced Services package containing Full-Text Search: https://www.microsoft.com/en-us/download/details.aspx?id=101064.

UNKNOWN — I found no Microsoft Learn page in this read-only check that normatively documents this bootstrapper’s exact `/MediaType=Advanced` switch or guarantees the downloaded filename casing/path. Local Dockerfile coherence is internally consistent, but the downloader output and extraction were not executed.

## Scope and limits

FACT — No SQL installation, Docker build, media acquisition, publication, remote Git action, or common document/index mutation occurred. Component availability in media, component installation, `FULLTEXTSERVICEPROPERTY` runtime state, and Clienteling catalog/function availability remain separate claims; only the first is documented for 2025 and only the intended installation command is corrected here.
