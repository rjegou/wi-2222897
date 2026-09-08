@echo off
set "GIT_CHECKOUT=%~dp0"
set "Tools_Path=%GIT_CHECKOUT%PublishedSharedTools"
set "AutoTestConsole=./tools/Cegid.Retail.AutoTest.Console.exe"
set "TEST_CAMPAGNE_BASE_PATH=%GIT_CHECKOUT%IntegratedTests\AutoTest\Data"
set "NUPKG_PATH=%Tools_Path%\Cegid.Retail.AutoTest.Console\Cegid.Retail.AutoTest.Console.nupkg"
set "CACHED_NUPKG_PATH=%GIT_CHECKOUT%..\migration-tools\Cegid.Retail.AutoTest.Console.nupkg"
powershell.exe -NoProfile -ExecutionPolicy Unrestricted -File "%GIT_CHECKOUT%checkPackage.ps1" -Tools_Path "%Tools_Path%" -NUPKG_PATH "%NUPKG_PATH%" -CachedNupkgPath "%CACHED_NUPKG_PATH%"
if errorlevel 1 exit /b 1
pwsh.exe -NoProfile -NonInteractive -ExecutionPolicy Unrestricted -File "%GIT_CHECKOUT%BeforeMigration.ps1" -OriginCampaignsPath "%GIT_CHECKOUT%IntegratedTests\AutoTest\Data"
if errorlevel 1 exit /b 1
cd /d "%Tools_Path%\Cegid.Retail.AutoTest.Console"
"%AutoTestConsole%" --tstj=%TEST_CAMPAGNE_BASE_PATH%\WebServices\WebServices.xml --dstFolder=%GIT_CHECKOUT%
exit /b %errorlevel%
