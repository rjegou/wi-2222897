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

## Backups

For jmeter AutoTests, the database backup is stored in the `.\Tests\Backups` folder.[See Test Backup Archive](.\Tests\Readme.md)

## Configuration of y2 test environments

See [Jmeter Y2 Environnement Configuration](.\Config\Readme.md)