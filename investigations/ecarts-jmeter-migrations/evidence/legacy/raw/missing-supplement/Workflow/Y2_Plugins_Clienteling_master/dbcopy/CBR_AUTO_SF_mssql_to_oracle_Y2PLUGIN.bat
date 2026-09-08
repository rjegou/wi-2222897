echo off

:: numéro de la version su format XX.YYNN, avec NN abréviation du plugin, Exemple 12.01MC
set Version=14.00MC
set FullVersion=%Version%_Y2_PLUGIN

:: chemin semi-complet(sans le nom du serveur) du backup SQL, Backup\TstAuto\V12_01MC\AUTO_V12_01MC_01MC_Y2_PLUGIN.bak
set BackupSql=Backup\TstAuto\V%Version%\AUTO_V%FullVersion:.=_%.bak

::Nom de la base de données SQL, déduit du numéro de la version  : CBR_AUTO_1201MC_Y2_PLUGIN
set DBSql=CBR_AUTO_%FullVersion:.=%

::Nom de la base de données ORACLE, déduit du numéro de la version  : CEG_TESTAUTO_1201MC_Y2_PLUGIN
set DBOracle=CEG_TESTAUTO_%FullVersion:.=%

::\\CBRTSTAUTO-ECBP\c$\Program Files (x86)\Cegid\CegidIntegrationTests\override\CommonTargets\DatabaseManager\
set rep=%~dp0
cd "%~dp0..\..\CommonTargets\IntegrationTestDatabaseManager\dbcopy\"

::call DbCopy_MSSQL_TO_ORACLE %BackupSql% %DBSql% %DBOracle% %DBOracle% CBRTESTAUTO-SQL.cegidalpha.local sa cegid.2012 D:\CBRTESTAUTO_DATA\
echo DbCopy_MSSQL_TO_ORACLE %BackupSql% %DBSql% %DBOracle% LOC LOC CEG_TESTAUTO_%FullVersion:.=%
call DbCopy_MSSQL_TO_ORACLE %BackupSql% %DBSql% %DBOracle% LOC LOC CEG_TESTAUTO_%FullVersion:.=%

cd %rep%