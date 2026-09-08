set versionLabel=Retail V12.01MC Integration Tests
set pathTRX=c:\inetpub\wwwroot\integrationTestsReports\
set WepApp_Cbr_Net=12.99.0.93
set WepApp_Cbp_Net=10.6.340.334
set WP_Cbr_Delphi=12.99.0.38
set WP_Cbr_Net=12.99.0.93
set WP_Cbp_Delphi=10.6.340.273
set WP_Cbp_Net=10.6.340.334
set CPTX_SQL=1
set CPTX_ORA=1

set cmd=PublishTRX.exe "%versionLabel%" "-mail=%versionLabel%" %pathTRX% http://CBRTSTAUTO-12XX/integrationTestsReports WebApp=[Cbr.Net=%WepApp_Cbr_Net%;Cbp.Net=%WepApp_Cbr_Net%];WorkerProcess=[Cbr.Delphi=%WP_Cbr_Delphi%;Cbr.Net=%WP_Cbr_Net%;Cbp.Delphi=%WP_Cbp_Delphi%Cbp.Net=%WP_Cbp_Net%];CPTXFile=[MSSQL=%CPTX_SQL%;ORACLE=%CPTX_ORA%]
echo %cmd%
call %cmd%

pause