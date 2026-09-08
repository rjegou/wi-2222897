# JMeter AutoTests

At the root of your Git repository, you will find two command files related to JMeter tests:

- `Jmeter_Launch_GUI.cmd`: This file allows you to install and launch the JMeter user interface.
- `Jmeter_Run_All_Campaigns.cmd` : This file allows you to execute all test campaigns via JMeter in non-GUI mode. It uses files located in `.\Tests\$campagne.xml`.

## Description of the Tests Folder

Structure of the tests folder:

```plaintext
Tests
├── Backups
│   ├── Readme.md
│   └── *.bak
├── Config
│   ├── Readme.md
│   ├── parameters.properties.sample
│   └── *.cy2px
└── $Campagne$
    └── $Campagne$.xml
```

| Name     | Description |
| -------- | ----------- |
| `./Tests/Backups` | Folder: Contains backups necessary for testing |
| `./Tests/Backups/Readme.md` | File: Instructions for database backup |
| `./Tests/Config` | Folder: Contains test environments configuration for fixed and current versions for each release |
| `./Tests/Config/Readme.md` | File: Information about the configuration |
| `./Tests/Config/parameters.properties.sample` | File: Example of `parameters.properties` file to create and fill out to run a local test campaign |
|   |   |

## Running Tests in the Pipeline

In the Azure pipeline, the JMeter tests will be executed on a Y2 environment within a Docker container.

### Configuration of `Fix` & `Cur` Test Environment Deployment in the Pipeline

Create two `.cy2px` files for each major version supported by the branch of your repository. These files should be stored in the `./Tests/Config` folder. Currently, we have the following predefined types:

- `Fix`: Tests the latest artifact of your product on the minimum supported Y2 version of your dependencies.
- `Cur`: Tests the latest artifact of your product on the latest version of your dependencies.

Examples:

- `v24-fix.cy2px`: Represents your test deployment for the minimum supported Y2 version 24.
- `v24-cur.cy2px`: Represents your test deployment for the current Y2 version 24.

Documentation on `.cy2px` files is available [here](https://dev.azure.com/cegid/Retail/_git/Y2_Tools_PlatformDeploy?path=/README.md).

See what has been done for the Technical plugin: [Config - Repos](https://dev.azure.com/cegid/Retail/_git/Y2_Plugins_Technical?path=/Tests/Config).

In the `.cy2px` files, you can find the following placeholders:

- `__plugin_Version__`: The pipeline will automatically replace this placeholder with the build version of the plugin.
- `__CONTAINER_HOST__`: The pipeline will automatically replace this placeholder with the name of the Docker container during the plugin build.

#### Configuration of Packages to Deploy

To reference all the dependencies required by your plugin, follow these steps in the `<packages>` section of the XML configuration file:

1. Add the dependencies your plugin needs, specifying the minimum (`Fix`) or current (`Cur`) version.
2. Include your plugin in the list of dependencies.
3. Add the authentication server in the minimum supported version.

#### Configuration of Y2 Components to Deploy

Specify the Y2 components that need to be deployed for testing:

```xml
<host name="__CONTAINER_HOST__" roles="Y2, Cptx, AuthServer" />
```

In this XML snippet, the `<host>` element is used to define a machine or container that will host the specified roles. The `name` attribute will be replaced by the actual name of the Docker container when the pipeline runs. The `roles` attribute lists the components to be deployed on this host, in this case, Y2 components, Cptx, and the Authentication Server.

#### Configuration of Tenant Information

Configure the tenant information `<tenant>`, necessary for the backup restoration and the setting of the restored database name.

- `tenant id`: The name under which the database will be restored, also corresponding to the folder ID (`folderId`).
- `tenant name`: The name of the backup to be restored, which is located in the `.\Tests\Backups` folder.

Example:

```xml
<tenant id="TESTS_AUTO_JMETER" databaseName="AUTO_V21_00" userId="" password="" dataLanguageReference="FRA" />
```

In this XML snippet, the `<tenant>` element is used to define the necessary details for setting up the tenant in the test environment. The `id` attribute specifies the tenant id, which is also used as the database name when restoring the database. The `databaseName` attribute indicates the name of the database backup that will be used once restored. The `userId` and `password` attributes would be used to provide authentication details if necessary, and `dataLanguageReference` indicates the language reference for the tenant data, which in this case is set to "FRA" for French.

#### CustomAppSettings Configuration

For more details, refer to the documentation on managing custom application settings [CustomAppSettings Management](https://dev.azure.com/cegid/Retail/_git/Y2_Tools_PlatformDeploy?anchor=gestion-d%27app-settings-personnalis%C3%A9s)

Example:

```xml
<AppSetting key="CurrentDateTime" value="2020-02-05T05:15:30" role="y2" file=".\web.config" legacy="false" enabled="true"/>
```

The provided example sets the `CurrentDateTime` key to a specific date and time value in the `web.config` file for the Y2 role, indicating it is not a legacy setting and should be enabled during the deployment process.

### Execution

When you wish to run tests on your development branch, set the `pipelineDevMode` parameter to true when you execute it.

### Pipeline Artifacts from Test Results

Following the execution of tests in the pipeline, you will find the following artifacts:

- The results of your tests are published under the test tab in the execution of your pipeline.
- The deployment logs of your environments `vXX-TTT_Deployment_logs-fv-az795-37-Attempt#1`
- The execution logs of the tests `vXX-TTT_$Campagne$_TestLogs-Attempt#1`
- The run logs of your environments `vXX-TTT_RunLogs-Attempt#1`

With:

- `XX`: The major Y2 version tested.
- `TTT`: Fix/Cur.
- `$Campagne$`: The name of the test campaign.

## Running Tests Locally

To do this, you must have a Y2 environment, which you can update to Fix or Cur as needed.

1) Y2 must have WCF compression disabled, ignore invalid signatures, and include detail of exceptions. (Remember the options for the process launcher and the worker.)
2) If you are making SQL requests in your tests on tables protected by DML, you will need to disable it.
3) Remember to define the customAppSettings for your tests.
4) Download and unzip the nuget package `Cegid.Retail.Common.Library` for the deployed version of `Cegid.Retail.Common`, and copy the library `Cegid.Retail.QualityTools.dll` into the Bin folder of the Y2 web app.
5) Perform a binding redirect for `Cegid.Retail.QualityTools.dll`.
   Example of Binding Redirect for QualityTools V25:  

    ```ps1
    $appDir = "C:\inetpub\wwwroot\Cegid Retail\Y2 25.0"
    Write-Host "Start Binding redirect for QualityTools" -ForegroundColor White
    $prgm = "$appDir\Setup\BindingRedirectGenerator.exe"
    $params = "/InputDirFilter:'Cegid.Retail.QualityTools.dll'", "/InputDir:'$appDir\Bin/'", "/OutputFile:'$appDir\Web.config'", "/Override"
    $result = & "$prgm" @params
    $result
    Write-Host " - Binding redirect for QualityTools done. " -ForegroundColor White
    ```

6) You must restore your backup before each test campaign launch and the following settings.
7) Execute the query to update the authentication domain.  

    ```sql
    UPDATE dbo.UTILISAT SET US_DOMAINEAUTHENT = '$TenantId'
    ```

### Running a JMX Locally

Prerequisites, the following elements must be installed and accessible via a console:

- Nuget
- Git
- Java
- Python 3

#### Opening a JMX

Run the batch file "Jmeter_Launch_GUI.cmd" located at the root of the repository. If JMeter is not installed, it will perform the following operations:

- Install JMeter
- Install prerequisites
- Install xunit-viewer to convert the test report to HTML format

#### Configuring JMX Parameters

Update the `Command line parameter` node, with the values from your test platform:

| Name               | Description                                                           |
|--------------------|-----------------------------------------------------------------------|
| APPSERVER_HOST     | The hostname of the machine hosting the Y2 application                |
| APPSERVER_PORT     | The port on which Y2 is exposed                                       |
| APPSERVER_PROTOCOL | The protocol used for connecting to Y2 (e.g., HTTP, HTTPS)            |
| APPNAME            | The name of the Y2 application (e.g., Retail_25.0)                    |
| FOLDER_ID          | Identifier for the Y2 folder, which is also the database name         |
| USERNAME           | The username for testing (e.g., SvcTestAutoRetail)                    |
| PASSWORD           | The password for the test user                                        |
| DB_HOST            | The hostname of the machine hosting the SQL server                    |
| DB_PORT            | The port on which the SQL server is exposed                           |
| DB_NAME            | The name of the database                                              |
| DB_USER            | The admin username for the database (e.g., sa)                        |
| DB_PASSWORD        | The password for the database admin user                              |
| DB_INSTANCE        | The name of the SQL server instance                                   |
| AUTHORITY_HOST     | The hostname of the machine hosting the authentication service (Y2)   |
| AUTHORITY_PORT     | The port on which the authentication service is exposed               |
| AUTHORITY_PROTOCOL | The protocol used for connecting to the authentication service        |
| AUTHORITY_APPNAME  | The name of the authentication application (e.g., authenticationserver)|
| RESULT_PATH        | Path & Folder is used for storing logs and differences found  |
| RESULT_FOLDER      | during full XML comparisons (Don't touch this values)  |

To facilitate the debugging of Jmeter tests:

1. In the option menu, you can display the log window (Log Viewer).
2. By default, only execution errors are shown; if you want to see all the execution results you need to uncheck Errors.
3. Click on Run to execute the test plan.
4. Review the test logs in the folder: .\Tests\Results.
   You will find a folder in the format: yyyy-MM-dd_HH-mm, corresponding to the execution time of your jmx.

### Execution of a campaign locally

Remember to restore your test backup before each campaign run (and to have updated the cptx).
And update the authentication domain:

```sql
UPDATE dbo.UTILISAT SET US_DOMAINEAUTHENT = '$TenantId'
```

#### Campaign Parameters Configuration

Setting up a parameters file for the execution of test campaigns by version Y2.
Copy the file `.\Tests\Config\parameters-sample.properties` into the file `.\Tests\Config\parameters.properties`.

Modify the values so that they correspond to your test environment:

```ini
# Sample user.properties file
#---------------------------------------------------------------------------
# you must define your jmeter parameters
#---------------------------------------------------------------------------
APPSERVER_HOST=cgdlpt010365
APPSERVER_PORT=80
APPSERVER_PROTOCOL=http
APPNAME=Retail_24.0
FOLDER_ID=POS_V24_00
USERNAME=SvcTestAutoRetail
PASSWORD=xt3Mcn1Cm5zAHc4w
DB_HOST=cgdlpt010365
DB_PORT=1433
DB_NAME=POS_V24_00
DB_USER=sa
DB_PASSWORD=Cegid.2016
DB_INSTANCE=\\SQL2016DEV
AUTHORITY_HOST=cgdlpt010365
AUTHORITY_PORT=443
AUTHORITY_PROTOCOL=https
AUTHORITY_APPNAME=authenticationserver
RESULT_PATH=../Results/
RESULT_FOLDER=
```

> **_NOTE:_** Remember to double the `\` for the instance name: `\\SQL2016DEV`

Open a console at the root of your repository and execute:

```cmd
.\Jmeter_Launch_TestCampaigns.cmd
```
