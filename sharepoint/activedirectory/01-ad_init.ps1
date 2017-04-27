#Reference: http://technet.microsoft.com/en-us/library/hh472162.aspx
#DomainMode / ForestMode - Server 2003: 2 or Win2003 / Server 2008: 3 or Win2008 / Server 2008 R2: 4 or Win2008R2 / Server 2012: 5 or Win2012 / Server 2012 R2: 6 or Win2012R2
$DomainName = "example.com"
$NetBIOSName = "example"
$DomainMode = "Win2012R2"
$ForestMode = "Win2012R2"
$SafeModeAdministratorPassword = ConvertTo-SecureString "Summer01!" -AsPlaintext -Force
$AutoLoginUser = "Administrator"
$AutoLoginPassword = "Summer01!"

## Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'AD-Step2' -Value "c:\windows\system32\cmd.exe /c C:\scripts\02-ad_add_domain_users.bat"

# Registry path for Autologon configuration
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"


# Autologon configuration including: username, password,domain name and times to try autologon
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $RegPath "DefaultUsername" -Value "$AutoLoginUser" -type String
Set-ItemProperty $RegPath "DefaultPassword" -Value "$AutoLoginPassword" -type String
Set-ItemProperty $RegPath "DefaultDomainName" -Value "$NetBIOSName" -type String
Set-ItemProperty $RegPath "AutoLogonCount" -Value "1" -type DWord



Write-Host "Windows Server 2012 R2 - Active Directory Installation"

Write-Host " - Installing AD-Domain-Services..."
Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

Write-Host " - Creating new AD-Domain-Services Forest..."
Install-ADDSForest -CreateDNSDelegation:$False -SafeModeAdministratorPassword $SafeModeAdministratorPassword -DomainName $DomainName -DomainMode $DomainMode -ForestMode $ForestMode -DomainNetBiosName $NetBIOSName -InstallDNS:$True -Confirm:$False

Write-Host " - Done.`n"
