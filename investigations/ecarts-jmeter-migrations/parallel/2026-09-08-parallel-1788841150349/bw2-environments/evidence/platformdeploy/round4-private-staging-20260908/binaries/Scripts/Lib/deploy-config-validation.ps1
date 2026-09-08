# File: deploy-config-validation.ps1
# Contains method to perform some deployConfig file validation
#
# 2022-11-24 : file creation

#Requires -Version 7.6

# Vérifie que chaque host utilise uniquement des rôles valides
function ValidateHostRoles( [object] $hostsList )
{
    $result = $TRUE
    foreach( $hostItem in $hostsList.host)
    {
        if ($FALSE -eq [RoleUtils]::IsRoleListValid($hostItem.roles))
        {
            [Logger]::Error("One or more role used by host {$($hostItem.name)} is invalid (values are {$([RoleTypes].GetEnumValues())})")
            $result = $FALSE
        }
    }
    return $result
}

# Vérifie que le host courant (ou le token conteneur) est bien déclaré dans la liste
function ValidateCurrentHostPresent( [object] $hostsList, [string] $currentHost, [bool] $dockerMode )
{
    if ($FALSE -eq $dockerMode)
    {
        if ($NULL -eq ($hostsList.host | Where-Object name -eq "$currentHost")) # Where-Object is non case sensitive
        {
            [Logger]::Error("This host ({$currentHost}) is not defined in hosts managed by the deploy config file")
            return $FALSE
        }
    }
    else
    {
        $cntrHostToken = [DockerUtils]::ContainerHostToken()
        if ($NULL -eq ($hostsList.host | Where-Object {($_.name -eq "$currentHost") -or ($_.name -eq "$cntrHostToken")})) # Where-Object is non case sensitive
        {
            [Logger]::Error("This host ({$currentHost}) or a host having the docker container token ({$cntrHostToken}) is not defined in hosts managed by the deploy config file")
            return $FALSE
        }
    }
    return $TRUE
}

# Vérifie qu'aucun rôle n'est affecté à plus d'un host
function ValidateRoleUniqueness( [object] $hostsList )
{
    $result = $TRUE
    foreach ($role in [RoleTypes].GetEnumValues())
    {
        $hosts = $hostsList.host | Where-Object { $_.roles.ToLower().Contains($role.ToString().ToLower()) }
        # Empty string if no host have specified role
        if ((($hosts | Measure-Object).Count) -gt 1)
        {
            [Logger]::Error("Role {$role} is used by more than one host")
            $result = $FALSE
        }
    }
    return $result
}

# Host configuration validation
function CheckHostsConfiguration( [string] $deployConfig, [string] $currentHost, [bool] $dockerMode )
{
    if (-not [DeployCfg]::HaveHostConfig($deployConfig)) { return $TRUE }

    $hostsList = [DeployCfg]::GetHostList( $deployConfig )
    $rolesOk   = ValidateHostRoles        -hostsList $hostsList
    $hostOk    = ValidateCurrentHostPresent -hostsList $hostsList -currentHost $currentHost -dockerMode $dockerMode
    $uniqueOk  = ValidateRoleUniqueness   -hostsList $hostsList

    return ($rolesOk -and $hostOk -and $uniqueOk)
}

# CustomAppSettings validation
function CheckCustomAppSettingsConfiguration( [string] $deployConfig )
{
    $result=$TRUE
    if ([DeployCfg]::HaveCustomAppSettings($deployConfig))
    {
        # Check role in CustomAppSettings
        $customAppSettings = [DeployCfg]::GetCustomAppSettings($deployConfig)
        foreach ($setting in $customAppSettings.appSetting)
        {
            if ($FALSE -eq [RoleUtils]::IsValideRole($setting.role))
            {
                [Logger]::Error("One CustomAppSettings use an unknow role {$($setting.role)}")
                $result = $FALSE
            }
            else
            {
                if ($setting.role.ToLower().Equals(([RoleTypes]::AuthServer).ToString().ToLower()) -or $setting.role.ToLower().Equals(([RoleTypes]::WebApps).ToString().ToLower()))
                {
                    [Logger]::Error("CustomAppSettings can not be applied on role {$($setting.role)}")
                    $result = $FALSE
                }
            }
        }
    }

    return $result
}
