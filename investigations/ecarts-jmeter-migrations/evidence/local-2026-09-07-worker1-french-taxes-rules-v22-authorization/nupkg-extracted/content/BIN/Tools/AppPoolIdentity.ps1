Function Pause($message = "Press any key to continue...")
{
    Write-Host -NoNewLine $message 
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
}

Function ElevateIfNot($commandDefinition, $commandArguments)
{
    $CurrentWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent() 
    $WindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($CurrentWindowsID)   
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    if (-not $WindowsPrincipal.IsInRole($adminRole))    
    {
		foreach ($commandArgument in $commandArguments)
		{
			$commandArgumentString = $commandArgumentString + " " + $commandArgument;
		}
        $newProcess = new-object System.Diagnostics.ProcessStartInfo "powershell";       
        $newProcess.Arguments = " -File " + $commandDefinition + " " + $commandArgumentString;
        $newProcess.Verb = "runas";
        [System.Diagnostics.Process]::Start($newProcess);
        exit
    }
}

ElevateIfNot $myInvocation.MyCommand.Definition $args

Import-Module WebAdministration

$appPoolName = $args[0]
if (!$appPoolName)
{
	$appPoolName = Read-Host "Please enter the application pool name"
}
$appPoolPath = "IIS:\AppPools\$appPoolName"
$appPool = get-item $appPoolPath
Write-Host "Application Pool = $appPoolName"

# Un compte spécifique demandé à l'utilisateur
#$credential = Get-Credential
#$appPool.ProcessModel.UserName = $credential.GetNetworkCredential().UserName
#$appPool.ProcessModel.Password = $credential.GetNetworkCredential().Password
#$appPool.ProcessModel.IdentityType = 3
#$appPool | set-item

# Le compte NetworkService
$appPool.ProcessModel.IdentityType = 2
$appPool | set-item
# SIG # Begin signature block
# MIIQ6QYJKoZIhvcNAQcCoIIQ2jCCENYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOUBNv+IwbN31CHwT7IfD5AEy
# vUqgggzSMIIDejCCAmKgAwIBAgIQOCXX+vhhr570kOcmtdZa1TANBgkqhkiG9w0B
# AQUFADBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xKzAp
# BgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EwHhcNMDcw
# NjE1MDAwMDAwWhcNMTIwNjE0MjM1OTU5WjBcMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xNDAyBgNVBAMTK1ZlcmlTaWduIFRpbWUgU3RhbXBp
# bmcgU2VydmljZXMgU2lnbmVyIC0gRzIwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
# AoGBAMS18lIVvIiGYCkWSlsvS5Frh5HzNVRYNerRNl5iTVJRNHHCe2YdicjdKsRq
# CvY32Zh0kfaSrrC1dpbxqUpjRUcuawuSTksrjO5YSovUB+QaLPiCqljZzULzLcB1
# 3o2rx44dmmxMCJUe3tvvZ+FywknCnmA84eK+FqNjeGkUe60tAgMBAAGjgcQwgcEw
# NAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJpc2ln
# bi5jb20wDAYDVR0TAQH/BAIwADAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# LnZlcmlzaWduLmNvbS90c3MtY2EuY3JsMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MA4GA1UdDwEB/wQEAwIGwDAeBgNVHREEFzAVpBMwETEPMA0GA1UEAxMGVFNBMS0y
# MA0GCSqGSIb3DQEBBQUAA4IBAQBQxUvIJIDf5A0kwt4asaECoaaCLQyDFYE3CoIO
# LLBaF2G12AX+iNvxkZGzVhpApuuSvjg5sHU2dDqYT+Q3upmJypVCHbC5x6CNV+D6
# 1WQEQjVOAdEzohfITaonx/LhhkwCOE2DeMb8U+Dr4AaH3aSWnl4MmOKlvr+ChcNg
# 4d+tKNjHpUtk2scbW72sOQjVOCKhM4sviprrvAchP0RBCQe1ZRwkvEjTRIDroc/J
# ArQUz1THFqOAXPl5Pl1yfYgXnixDospTzn099io6uE+UAKVtCoNd+V5T9BizVw9w
# w/v1rZWgDhfexBaAYMkPK26GBPHr9Hgn0QXF7jRbXrlJMvIzMIIDxDCCAy2gAwIB
# AgIQR78Zld+NUkZD99ttSA0xpDANBgkqhkiG9w0BAQUFADCBizELMAkGA1UEBhMC
# WkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIGA1UEBxMLRHVyYmFudmlsbGUx
# DzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhhd3RlIENlcnRpZmljYXRpb24x
# HzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcgQ0EwHhcNMDMxMjA0MDAwMDAw
# WhcNMTMxMjAzMjM1OTU5WjBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNp
# Z24sIEluYy4xKzApBgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpyrKkzM0grwp9
# iayHdfC0TvHfwQ+/Z2G9o2Qc2rv5yjOrhDCJWH6M22vdNp4Pv9HsePJ3pn5vPL+T
# rw26aPRslMq9Ui2rSD31ttVdXxsCn/ovax6k96OaphrIAuF/TFLjDmDsQBx+uQ3e
# P8e034e9X3pqMS4DmYETqEcgzjFzDVctzXg0M5USmRK53mgvqubjwoqMKsOLIYdm
# vYNYV291vzyqJoddyhAVPJ+E6lTBCm7E/sVK3bkHEZcifNs+J9EeeOyfMcnx5iIZ
# 28SzR0OaGl+gHpDkXvXufPF9q2IBj/VNC97QIlaolc2uiHau7roN8+RN2aD7aKCu
# FDuzh8G7AgMBAAGjgdswgdgwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC52ZXJpc2lnbi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBBBgNV
# HR8EOjA4MDagNKAyhjBodHRwOi8vY3JsLnZlcmlzaWduLmNvbS9UaGF3dGVUaW1l
# c3RhbXBpbmdDQS5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgEGMCQGA1UdEQQdMBukGTAXMRUwEwYDVQQDEwxUU0EyMDQ4LTEtNTMwDQYJKoZI
# hvcNAQEFBQADgYEASmv56ljCRBwxiXmZK5a/gqwB1hxMzbCKWG7fCCmjXsjKkxPn
# BFIN70cnLwA4sOTJk06a1CJiFfc/NyFPcDGA8Ys4h7Po6JcA/s9Vlk4k0qknTnqu
# t2FB8yrO58nZXt27K4U+tZ212eFX/760xX71zwye8Jf+K9M7UhsbOCf3P0owggWI
# MIIEcKADAgECAgp84braAAAAAAA2MA0GCSqGSIb3DQEBBQUAME8xFTATBgoJkiaJ
# k/IsZAEZFgVsb2NhbDEaMBgGCgmSJomT8ixkARkWCmNlZ2lkZ3JvdXAxGjAYBgNV
# BAMTEUF1dGhvcml0eUNFR0lELUNBMB4XDTExMTIwODE0MzA0MVoXDTEyMTIwODE0
# NDA0MVowgZQxCzAJBgNVBAYTAkZSMQ4wDAYDVQQIEwVSaG9uZTENMAsGA1UEBxME
# TFlPTjEOMAwGA1UEChMFQ0VHSUQxIDAeBgNVBAsMF1BsYXRlZm9ybWUgZXQgc3lz
# dMOobWVzMREwDwYDVQQDEwhCTEFOQ0hJTjEhMB8GCSqGSIb3DQEJARYSdGJsYW5j
# aGluQGNlZ2lkLmZyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6xnM
# JKmrKeQHhAOtaRtVMf1hkqxmD5cHcsScBRVdlngas5NvWmDsgBrAbMeMgcLsNt4W
# rdkDldgJgLou1e846DBbq0DeMAAA3ramYXENfl/VZxXIrPik051y+yQGjceG62gn
# jlnt1pDha0wLzYpXAHlaXE8FD5+PDom/wzS9CAc8Jlub+OmAq2TE5nhVD5B+s79K
# YDG4r82zAxR1jBUO5sccEgYITXXxWQHQcKmScQaK8uRtScpeWVbv8G2qjKHDA5T2
# IwYkPlkzaazZNMFbx0856SnMFJcs3UfjcFOT24uqvJrsSUWmHXg0CLKEV1yd8T6N
# E/M/7h35P2yZ+l8ojwIDAQABo4ICHjCCAhowDgYDVR0PAQH/BAQDAgTwMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBRF4IHcSfW94PLcGgeAR1MdB7IEizAf
# BgNVHSMEGDAWgBRJGduMnJYxC2PPvmPyW62FLTNoXjCB2QYDVR0fBIHRMIHOMIHL
# oIHIoIHFhoHCbGRhcDovLy9DTj1BdXRob3JpdHlDRUdJRC1DQSxDTj1DR0RMWU9W
# TTAwODUsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZp
# Y2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y2VnaWRncm91cCxEQz1sb2NhbD9jZXJ0
# aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJp
# YnV0aW9uUG9pbnQwgcgGCCsGAQUFBwEBBIG7MIG4MIG1BggrBgEFBQcwAoaBqGxk
# YXA6Ly8vQ049QXV0aG9yaXR5Q0VHSUQtQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtl
# eSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y2Vn
# aWRncm91cCxEQz1sb2NhbD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9
# Y2VydGlmaWNhdGlvbkF1dGhvcml0eTAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEB
# BQUAA4IBAQAUUqXvvQIQZ5IrOE2Qhl9zvEqOm5WLROUEWbAjxSoGgKAragKYFX7r
# bPKNBWxArmvU/Jnr57Aa8NjcgYc7kT37c5yIRqmxHh6RaD/tQpe3EwFGkEAJHkMp
# PvT03N8lMsgeScGwJb0uu10ebYwhDNdyIiIhxc9Lu59f//U3bALSyqaMao5kzkIw
# +XkzBVq5JWzsp0k5cmnfl3FdboKFe2BnOvpMpSLrKgXUv74dsTOUaUf2ciSElnIV
# /pWr67SnFvuXAruoP58csgGUwDzAf2TjqdXf6GJhlAwlMihWj3XKTTbTccF44Qtr
# 480axlEKLCQ2h6pHxxulrm96DoqMJqnVMYIDgTCCA30CAQEwXTBPMRUwEwYKCZIm
# iZPyLGQBGRYFbG9jYWwxGjAYBgoJkiaJk/IsZAEZFgpjZWdpZGdyb3VwMRowGAYD
# VQQDExFBdXRob3JpdHlDRUdJRC1DQQIKfOG62gAAAAAANjAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUh7YSQm/NHNIFW+oPFFBBtsfX92swDQYJKoZIhvcNAQEBBQAEggEAyn3BEW64
# 8HKIlEAIoZ5DBDD3YLdNUYdW/Rw9mTC2jhXdJIPRHULlMviQBEfWEGX1tDU3lP1T
# oG13hzhiZ8Dyy4u4JHKWrTqr4cyJIfPVmynBsRlu3ze6j6qhEliEH2PBltEeTpaV
# ui5M3v3dNYiKZzHz6iWVJ+1xLsh3og3S51oJ+s4yqMQg1WHlcQxkCTUnTTLKhbfK
# WZvsNTiOUtT4Q7dYFvH+GRt73deKpxRSfbZbPDwAY9QVbm4Ehx6GeIXwbqRWkrBY
# IcvXQ4CVCZp0d+8ygsEFagOqo/+ZoDvosz8tTmcDTxjEMLrLd8r1II9F2Cen+une
# 1MECfIAgQWevuaGCAX8wggF7BgkqhkiG9w0BCQYxggFsMIIBaAIBATBnMFMxCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjErMCkGA1UEAxMiVmVy
# aVNpZ24gVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBDQQIQOCXX+vhhr570kOcmtdZa
# 1TAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG
# 9w0BCQUxDxcNMTIwMTI3MDg0NDA3WjAjBgkqhkiG9w0BCQQxFgQU/10WcDhxpmCu
# P3S/+l5+vE8V938wDQYJKoZIhvcNAQEBBQAEgYAoLeN6VtKrsuBdZyiLP86a6l6R
# UpgRLBbenA4Ke9MmUDeAdUx9rs54u9Ssuj2lMpGVPCicw0HkMlsTM6BkCn8EKCwW
# X1GlYayzOrpcKAhIJOCpMpgRGxeOmUbR9EcAO7UxFo/ZYIpAOpTuvnQloKJEH352
# G6MRhKa+3o0PbmauBA==
# SIG # End signature block
