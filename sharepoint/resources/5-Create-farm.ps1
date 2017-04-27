$ConfigDB = 'sp.FarmConfiguration'
$CentralAdminContentDB = 'sp.CentralAdministration'
$CentralAdminPort = '2016'

$SharepointFarmPassphraseFile = 'C:\SharepointFarmPassphrase.txt'
$KeyFile = "C:\AES.key"
$key = Get-Content $KeyFile
$FarmPassPhrase = Get-Content $SharepointFarmPassphraseFile | ConvertTo-SecureString -Key $key

$EnvFile = 'C:\env.txt'
$environment = (get-content $EnvFile -First 1)
$Usersfile = 'C:\users.txt'

$FarmAcct = (get-content $Usersfile)[2]
$ServerRole = "Custom"

$SharepointFarmPWFile = "C:\SharepointFarmPW.txt"
$FarmAcctPW = Get-Content $SharepointFarmPWFile | ConvertTo-SecureString -Key $key


# Path for RootCA
$DC = $environment = (get-content $EnvFile)[3]
# Certificate to use for certificate request
$Certificate_Template = "WebServer"
$ServerName = (Get-ChildItem env:COMPUTERNAME).value
$SharepointDNSName = (get-content $EnvFile -First 1) + '-portal'


# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-Post' -Value "c:\windows\system32\cmd.exe /c C:\scripts\6-Post-install.bat"

Write-Host " - Enabling SP PowerShell cmdlets..."  
If ((Get-PsSnapin |?{$_.Name -eq "Microsoft.SharePoint.PowerShell"})-eq $null)  
{
    Add-PsSnapin Microsoft.SharePoint.PowerShell | Out-Null
}
Start-SPAssignment -Global | Out-Null

$FarmAcctFqdn = "$env:userdomain\" + $FarmAcct
$FarmCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $FarmAcctFqdn, $FarmAcctPW


Write-Host " - Creating configuration database..."  
New-SPConfigurationDatabase –DatabaseName "$ConfigDB" –DatabaseServer $env:COMPUTERNAME –AdministrationContentDatabaseName $CentralAdminContentDB –Passphrase $FarmPassPhrase –FarmCredentials $FarmCredential -LocalServerRole $ServerRole

Write-Host " - Installing Help Collection..."  
Install-SPHelpCollection -All

Write-Host " - Securing Resources..."  
Initialize-SPResourceSecurity

Write-Host " - Installing Services..."  
Install-SPService

Write-Host " - Installing Features..."  
$Features = Install-SPFeature –AllExistingFeatures -Force

Write-Host " - Creating Central Admin..."  
$NewCentralAdmin = New-SPCentralAdministration -Port $CentralAdminPort -WindowsAuthProvider "NTLM" -SecureSocketsLayer

Write-Host " - Waiting for Central Admin to provision..." -NoNewline  
sleep 5  
Write-Host "Created!"

Write-Host " - Installing Application Content..."  
Install-SPApplicationContent

Stop-SPAssignment -Global | Out-Null

sleep 15 

# Certificate Subject name  
$Subject = 'CN='
$fqdn = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName
$Subjectname = -join ($Subject,$fqdn)

# Certificate DNS names
$Dns1 = $fqdn.ToLower()
$Dns2 = $ServerName.ToLower()
$Dns3 = $SharepointDNSName + '.' + $env:USERDNSDOMAIN.ToLower()

# Certificate request
$enrollResult = Get-Certificate -Template $Certificate_Template  -CertStoreLocation cert:\LocalMachine\My -SubjectName "$SubjectName" -DnsName $Dns1,$Dns2,$Dns3 -Url $DC
$thumbprint = $enrollResult.Certificate.Thumbprint
$enrollResult.Certificate.FriendlyName = "$Dns1"

$site = Get-WebBinding -protocol https -ErrorAction SilentlyContinue
if (!$site) { 
    Write-Output "Creating SSL Web Binding" 
    New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
} else {
    write-host "SSL Web Binding already exists"
}

$certificate = "IIS:\SslBindings\0.0.0.0!443"
$path = test-path $certificate 
if (!$path) {
    Write-output "Installing Certificate"
    get-item cert:\LocalMachine\MY\$thumbprint | New-Item "IIS:\SSLBindings\0.0.0.0!443"
    get-item cert:\LocalMachine\MY\$thumbprint | New-Item "IIS:\SSLBindings\0.0.0.0!2016"

} else {

Write-Output "Removing old SSL Certificate" 
    Remove-Item IIS:\SslBindings\0.0.0.0!443
    Remove-Item IIS:\SslBindings\0.0.0.0!2016
    Write-Output "Installing new SSL certificate"
    get-item cert:\LocalMachine\MY\$thumbprint | New-Item "IIS:\SSLBindings\0.0.0.0!443"
    get-item cert:\LocalMachine\MY\$thumbprint | New-Item "IIS:\SSLBindings\0.0.0.0!2016"
}


Restart-Computer -Force