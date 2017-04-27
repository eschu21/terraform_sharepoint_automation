#Lets create our farm

$DBServer = (get-content C:\scripts\db_info.txt)
$ConfigDB = 'spFarmConfiguration'
$CentralAdminContentDB = 'spCentralAdministration'
$CentralAdminPort = '2016'
$PassPhrase = 'Summer01!'
$SecPassPhrase = ConvertTo-SecureString $PassPhrase -AsPlaintext -Force

$FarmAcc = 'example\spFarmAcc'
$FarmPassword = 'Summer01!'
$FarmAccPWD = ConvertTo-SecureString $FarmPassword  -AsPlaintext -Force
$cred_FarmAcc = New-Object System.Management.Automation.PsCredential $FarmAcc,$FarmAccPWD

# Configures script to run once on next logon -DISABLED TO TEST SWITCHING USERS
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-farm' -Value "c:\windows\system32\cmd.exe /c C:\scripts\07-sp_Post_farm.bat"

## --WebFrontEnd, Application, DistributedCache, Search, Custom, SingleServerFarm -- ##
$ServerRole = "Custom"


Write-Host " - Enabling SP PowerShell cmdlets..."
If ((Get-PsSnapin |?{$_.Name -eq "Microsoft.SharePoint.PowerShell"})-eq $null)
{
    Add-PsSnapin Microsoft.SharePoint.PowerShell | Out-Null
}
Start-SPAssignment -Global | Out-Null



Write-Host " - Creating configuration database..."
New-SPConfigurationDatabase -DatabaseName "$ConfigDB" -DatabaseServer "$DBServer" -AdministrationContentDatabaseName "$CentralAdminContentDB" -Passphrase $SecPassPhrase -FarmCredentials $cred_FarmAcc -LocalServerRole $ServerRole

Write-Host " - Installing Help Collection..."
Install-SPHelpCollection -All

Write-Host " - Securing Resources..."
Initialize-SPResourceSecurity

Write-Host " - Installing Services..."
Install-SPService

Write-Host " - Installing Features..."
$Features = Install-SPFeature -AllExistingFeatures -Force

Write-Host " - Creating Central Admin..."
$NewCentralAdmin = New-SPCentralAdministration -Port $CentralAdminPort -WindowsAuthProvider "NTLM"

Write-Host " - Waiting for Central Admin to provision..." -NoNewline
sleep 5
Write-Host "Created!"

Write-Host " - Installing Application Content..."
Install-SPApplicationContent



Stop-SPAssignment -Global | Out-Null


#At this point we have a basic farm installed, no service applications installed yet, but based on this then you can move on and install the service applicacions depending on the server role you will deploy.


# Creating a self-signed cert... this will need to be replaced with a CSR creation for prod ##
New-SelfSignedCertificate `
  -DnsName hal-sp-sp01.example.com `
  -CertStoreLocation cert:Localmachine\My
echo "Farm Created" | Out-File -Append C:\status.txt


## Will re-enable the restart once I get all scripts working
Restart-Computer -Force
