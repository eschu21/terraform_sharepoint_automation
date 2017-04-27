$DNS = "10.100.101.50"
$DNS2 = "8.8.8.8"
$EnvironmentName = 'example'
$DomainController = 'dc01'
$OU = 'OU=UsersSP2016,DC=example,DC=com'
$NewComputerName = 'hal-sp-sp01'
$DomainName = 'example.com'
$EnterpriseAdmin = 'spAdmin'
$NetBIOSName = "example"
$EnterpriseAdminPW  = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$AutoLoginUser = "spadmin"
$AutoLoginPassword = "Summer01!"

# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'AD_Create' -Value "c:\windows\system32\cmd.exe /c C:\scripts\01-sp_dependencies.bat"

# Registry path for Autologon configuration
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"


# Autologon configuration including: username, password,domain name and times to try autologon
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $RegPath "DefaultUsername" -Value "$AutoLoginUser" -type String
Set-ItemProperty $RegPath "DefaultPassword" -Value "$AutoLoginPassword" -type String
Set-ItemProperty $RegPath "DefaultDomainName" -Value "$NetBIOSName" -type String
Set-ItemProperty $RegPath "AutoLogonCount" -Value "10" -type DWord
## Get the network adapter info
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS,$DNS2

## Create Credentials to Join to Domain ##
$DomainUser = $EnvironmentName + '\' + $EnterpriseAdmin
$Credential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $EnterpriseAdminPW


## OutFile to show the script ran
echo "AD Join complete" | Out-File C:\status.txt

## Joins computer to domain
Add-Computer -DomainName $DomainName -OUPath $OU -Credential $Credential -NewName $NewComputerName -Options JoinWithNewName,AccountCreate -Restart
