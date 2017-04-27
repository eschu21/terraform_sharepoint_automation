## Variables for Domain Join ##
$DNS = "10.100.101.50"
$DNS2 = "8.8.8.8"
$OU = 'OU=UsersSP2016,DC=example,DC=com'
$NewComputerName = 'hal-db-sp01'
$DomainName = 'example.com'
$NetbiosName = "example"
$EnterpriseAdmin = 'spAdmin'
$EnterpriseAdminPW  = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$AutoLoginUser = "Administrator"
$AutoLoginPassword = "Summer01!"
#Creating SecureString object

# Registry path for Autologon configuration
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

$DomainUser = $NetbiosName + '\' + $EnterpriseAdmin
# Autologon configuration including: username, password,domain name and times to try autologon
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $RegPath "DefaultUsername" -Value "$AutoLoginUser" -type String
Set-ItemProperty $RegPath "DefaultPassword" -Value "$AutoLoginPassword" -type String
Set-ItemProperty $RegPath "DefaultDomainName" -Value "$NetBIOS" -type String
Set-ItemProperty $RegPath "AutoLogonCount" -Value "10" -type DWord

# Configures script to run on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-NextStep-2' -Value "c:\windows\system32\cmd.exe /c C:\scripts\02-mssql_init.bat"



## Get the network adapter info
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS,$DNS2

## Create Credentials to Join to Domain ##

$Credential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $EnterpriseAdminPW

## Joins computer to domain
Add-Computer -DomainName $DomainName -OUPath $OU -Credential $Credential -NewName $NewComputerName -Options JoinWithNewName,AccountCreate -Restart
