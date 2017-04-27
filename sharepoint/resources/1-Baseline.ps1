[CmdletBinding()]
 param (

[Parameter(Mandatory=$true)] 
[string]$EnvironmentName, 

[Parameter(Mandatory=$true)] 
[string]$IP, 

[Parameter(Mandatory=$true)] 
[string]$SubnetMask, 

[Parameter(Mandatory=$true)] 
[string]$Gateway, 

[Parameter(Mandatory=$true)] 
[string]$DNS, 

[Parameter(Mandatory=$true)] 
[string]$DomainName,

[Parameter(Mandatory=$true)] 
[string]$NetBIOS,

[Parameter(Mandatory=$true)]
[Security.SecureString]$LocalAdminPW,

[Parameter(Mandatory=$true)]
[string]$SiteAdmin, 

[Parameter(Mandatory=$true)]
[Security.SecureString]$SiteAdminPW,

[Parameter(Mandatory=$true)]
[Security.SecureString]$SharepointFarmPassphrase,

[Parameter(Mandatory=$true)]
[string]$SharepointFarmAcct,

[Parameter(Mandatory=$true)]
[Security.SecureString]$SharepointFarmPW,

[Parameter(Mandatory=$true)]
[string]$SharepointAppPoolAcct,

[Parameter(Mandatory=$true)]
[Security.SecureString]$SharepointAppPoolPW,

[Parameter(Mandatory=$true)]
[string]$EnterpriseAdmin, 

[Parameter(Mandatory=$true)]
[Security.SecureString]$EnterpriseAdminPW,

[Parameter(Mandatory=$true)] 
[string]$NewComputerName,

[Parameter(Mandatory=$true)] 
[string]$OU,

[Parameter(Mandatory=$true)] 
[string]$DomainController,

[Parameter(Mandatory=$true)] 
[string]$RootCA

) 


$EnvFile = 'C:\env.txt'
$EnvironmentName,$DomainName,$NetBIOS,$RootCA | Out-File $EnvFile
$UsersFile = 'C:\users.txt'
$EnterpriseAdmin,$SiteAdmin,$SharepointFarmAcct,$SharepointAppPoolAcct | Out-File $UsersFile
$KeyFile = "C:\AES.key"
$Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile

#Creating SecureString object
$Key = Get-Content $KeyFile
$LocalAdminPWFile = 'C:\LocalAdminPW.txt'
$LocalAdminPW | ConvertFrom-SecureString -key $Key | Out-File $LocalAdminPWFile
$SiteAdminPWFile = 'C:\SiteadminPW.txt'
$SiteAdminPW | ConvertFrom-SecureString -key $Key | Out-File $SiteAdminPWFile
$SharepointFarmPassphraseFile = "C:\SharepointFarmPassphrase.txt"
$SharepointFarmPassphrase | ConvertFrom-SecureString -key $Key | Out-File $SharepointFarmPassphraseFile
$SharepointFarmPWFile = "C:\SharepointFarmPW.txt"
$SharepointFarmPW | ConvertFrom-SecureString -key $Key | Out-File $SharepointFarmPWFile
$SharepointAppPoolPWFile = "C:\SharepointAppPoolPWFile.txt"
$SharepointAppPoolPW | ConvertFrom-SecureString -key $Key | Out-File $SharepointAppPoolPWFile
$EnterpriseAdminPWFile = 'C:\EnterpriseAdminPW.txt'
$EnterpriseAdminPW | ConvertFrom-SecureString -key $Key | Out-File $EnterpriseAdminPWFile


$DomainUser = $DomainName + '\' + $EnterpriseAdmin
$Credential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $EnterpriseAdminPW

$LocalAdminEncrypted = Get-Content $LocalAdminPWFile | ConvertTo-SecureString -Key $key
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LocalAdminEncrypted)
$LocalAdminPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

([adsi]"WinNT://$env:COMPUTERNAME/Administrator").SetPassword($LocalAdminPassword)


$IPType = "IPv4"
# Retrieve the network adapter that you want to configure
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
 $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}
If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
 $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}
 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
 -AddressFamily $IPType `
 -IPAddress $IP `
 -PrefixLength $SubnetMask `
 -DefaultGateway $Gateway
# Configure DNS IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS


# Sleep after changing IP address
start-sleep -seconds 5

$encryptedpw = Get-Content $EnterpriseAdminPWFile | ConvertTo-SecureString -Key $key
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedpw)
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Registry path for Autlogon configuration
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
# Autologon configuration including: username, password,domain name and times to try autologon
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty $RegPath "DefaultUsername" -Value "$DomainUser" -type String 
Set-ItemProperty $RegPath "DefaultPassword" -Value "$Password" -type String
Set-ItemProperty $RegPath "DefaultDomainName" -Value "$NetBIOS" -type String
Set-ItemProperty $RegPath "AutoLogonCount" -Value "10" -type DWord

#Configures script to run on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SQL-Install' -Value "c:\windows\system32\cmd.exe /c C:\scripts\2-SQL-install.bat"


# Install Sharepoint prereq Windows Features
Install-WindowsFeature Net-Framework-Features,Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-App-Dev,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Http-Tracing,Web-Security,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Digest-Auth,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Application-Server,AS-Web-Support,AS-TCP-Port-Sharing,AS-WAS-Support,AS-HTTP-Activation,AS-TCP-Activation,AS-Named-Pipes,AS-Net-Framework,WAS,WAS-Process-Model,WAS-NET-Environment,WAS-Config-APIs,Web-Lgcy-Scripting,Windows-Identity-Foundation,Server-Media-Foundation,Xps-Viewer,InkAndHandwritingServices,Desktop-Experience -Source "C:\Scripts\winsxs"

#Rename computer
Rename-Computer -NewName $NewComputerName
Start-Sleep -Seconds 5

$DomainController = $DomainController + '.' + $DomainName
# Joins computer to domain
Add-Computer -DomainName $DomainName -OUPath $OU -Server $DomainController -Credential $Credential -Options JoinWithNewName,AccountCreate -Restart
