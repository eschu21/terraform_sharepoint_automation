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
$AutoLoginUser = "Administrator"
$AutoLoginPassword = "Summer01!"

$KeyFile = "C:\AES.key"
$Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile
$EnterpriseAdminPWFile = 'C:\EnterpriseAdminPW.txt'
$EnterpriseAdminPW | ConvertFrom-SecureString -key $Key | Out-File $EnterpriseAdminPWFile

# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-Prereq2' -Value "c:\windows\system32\cmd.exe /c C:\scripts\04-sp_Prereq1.bat"


echo "Baseline installed" | Out-File -Append C:\status.txt

# Install Sharepoint prereq Windows Features
Install-WindowsFeature Net-Framework-Features,Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-App-Dev,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Http-Tracing,Web-Security,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Digest-Auth,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Application-Server,AS-Web-Support,AS-TCP-Port-Sharing,AS-WAS-Support,AS-HTTP-Activation,AS-TCP-Activation,AS-Named-Pipes,AS-Net-Framework,WAS,WAS-Process-Model,WAS-NET-Environment,WAS-Config-APIs,Web-Lgcy-Scripting,Windows-Identity-Foundation,Server-Media-Foundation,Xps-Viewer,InkAndHandwritingServices,Desktop-Experience -Source "C:\Scripts\winsxs"

Restart-Computer -Force
