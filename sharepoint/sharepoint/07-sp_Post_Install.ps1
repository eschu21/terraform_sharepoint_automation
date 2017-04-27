$EnvFile = 'C:\env.txt'
$environment = (get-content $EnvFile -First 1)
$Usersfile = 'C:\users.txt'
$SPDocTemplate= 'STS#0'
$SPTeamTemplate = 'STS#0'
$WebAppName = $environment + ' Web Application'
$SpOwner =  (get-content $Usersfile)[0]
$SPsite1Name =  $environment + ' Local Site'
$SpSite2Name = "Team Site"
$env:userdnsdomain = 'example.com'
$sSMTPServer=$environment + '-ex01.' + $env:userdnsdomain.ToLower()
$sFromEMail=$environment + '-sharepoint@' + $env:userdnsdomain.ToLower()
$sReplyEmail=$environment + '-reply@' + $env:userdnsdomain.ToLower()
$sChartSet=65001
$FarmAcc = 'example\spadmin'
$FarmPassword = 'Summer01!'
$FarmAccPWD = ConvertTo-SecureString $FarmPassword  -AsPlaintext -Force
$Username = 'spadmin'
$DBName = '10.100.101.51'

$secusername = "$env:userdnsdomain" + "\" + (get-content $Usersfile)[3]
$SharepointAppPoolPWFile = "C:\SharepointAppPoolPWFile.txt"
$KeyFile = "C:\AES.key"
$key = Get-Content $KeyFile

## Use below encryption method when we start using AES keys and the like to pass credentials around the Windows OS...
## Preferably we can use Consul instead...
#$encryptedpw = Get-Content $SharepointAppPoolPWFile | ConvertTo-SecureString -Key $key

$creds = New-Object System.Management.Automation.PSCredential ("$FarmAcc", $FarmAccPWD)

# Add SharePoint Powershell module
Add-PsSnapin Microsoft.SharePoint.PowerShell

# Add Sharepoint Managed account from AD
$Managed = New-SPManagedAccount -Credential $creds

# Search Specifics
$ServerName = 'hal-sp-sp01'
$serviceAppName = "Search Service Application"
$searchDBName = "sp.SearchService"

# Create new Sharepoint service application pool
$AppPool = New-SPServiceApplicationPool -Name "ApplicationPool"  -Account $Managed.Username

# Create new MetaData service application
New-SPMetadataServiceApplication -Name "MetadataServiceApp" -ApplicationPool $AppPool.name -DatabaseName "sp.MetadataDB"
# Create new Secure Store service application
New-SPSecureStoreServiceApplication -ApplicationPool $AppPool.Name -AuditingEnabled:$false -DatabaseServer $DBName -DatabaseName "sp.SecureStore" -Name "Secure Store"

$service1 = $(Get-SPServiceInstance | where {$_.TypeName -match "App Management Service" })
Start-SPServiceInstance -Identity $service1.ID

$service2 = $(Get-SPServiceInstance | where {$_.TypeName -match "Secure Store Service" })
Start-SPServiceInstance -Identity $service2.ID

$service3 = $(Get-SPServiceInstance | where {$_.TypeName -match "Microsoft SharePoint Foundation Subscription Settings Service" })
Start-SPServiceInstance -Identity $service3.ID


# Start Search Service Instances
Write-Host "Starting Search Service Instances..."
Start-SPEnterpriseSearchServiceInstance $ServerName
Start-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance $ServerName

# Create the Search Service Application and Proxy
Write-Host "Creating Search Service Application and Proxy..."
#$searchServiceApp = New-SPEnterpriseSearchServiceApplication -Name $serviceAppName -ApplicationPool $AppPool.name -DatabaseName $searchDBName
#$searchProxy = New-SPEnterpriseSearchServiceApplicationProxy -Name "$serviceAppName Proxy" -SearchApplication $searchServiceApp
#
## Clone the default Topology (which is empty) and create a new one and then activate it
#Write-Host "Configuring Search Component Topology..."
#$Searchindexpath = 'D:\Sharepoint\Index'
#$clone = $searchServiceApp.ActiveTopology.Clone()
#$searchServiceInstance = Get-SPEnterpriseSearchServiceInstance
#New-SPEnterpriseSearchAdminComponent -SearchTopology $clone -SearchServiceInstance $searchServiceInstance
#New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $clone -SearchServiceInstance $searchServiceInstance
#New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $clone -SearchServiceInstance $searchServiceInstance
#New-SPEnterpriseSearchCrawlComponent -SearchTopology $clone -SearchServiceInstance $searchServiceInstance
#New-SPEnterpriseSearchIndexComponent -SearchTopology $clone -SearchServiceInstance $searchServiceInstance -RootDirectory (new-item -itemtype directory -path $Searchindexpath)
#New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $clone -SearchServiceInstance $searchServiceInstance
#$clone.Activate()


$ap = New-SPAuthenticationProvider
$HostHeader = $ServerName.ToLower() + ".$env:userdnsdomain".ToLower()
$Url = 'https://' + $HostHeader
New-SPWebApplication -Name $WebAppName -Port 443 -HostHeader $HostHeader -URL $Url -ApplicationPool $AppPool.Name -ApplicationPoolAccount $AppPool.ProcessAccount -AuthenticationProvider $ap -SecureSocketsLayer

$SpSiteUrl1 = $Url + "/sites/" + "doc"
$SpSiteUrl2 = $Url + "/sites/" + "shared"
$SpUsername = $env:USERDNSDOMAIN.ToLower() + "\$SpOwner"

New-SPSite $SpSiteUrl1 -OwnerAlias $SpUsername -Template $SPDocTemplate -Name $SPsite1Name -Verbose
New-SPSite $SpSiteUrl2 -OwnerAlias $SpUsername -Template $SPTeamTemplate -Name $SpSite2Name -Verbose

# Registry path for Autologon configuration
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Removes Autologon configuration
Remove-ItemProperty -Path $RegPath -Name "AutoAdminLogon"
Remove-ItemProperty -Path $RegPath -Name "DefaultUsername"
Remove-ItemProperty -Path $RegPath -Name "AutoLogonCount"
Remove-ItemProperty -Path $RegPath -Name "DefaultPassword"
Remove-ItemProperty -Path $RegPath -Name "DefaultDomainName"


#Definition of the function that configures outgoing e-mail in SharePoint
function Configure-OutGoingEMail
{
    param ($sSMTPServer,$sFromEMail,$sReplyEmail,$sCharSet)
    try
    {
        $CAWebApp = Get-SPWebApplication -IncludeCentralAdministration | Where { $_.IsAdministrationWebApplication }
        $CAWebApp.UpdateMailSettings($sSMTPServer, $sFromEMail, $sReplyEmail, $sCharSet)
        write-host -f Blue "Outgoing e-mail configured"
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}


# Assign AD Groups and permissions - USE THESE WHEN WE WANT TO START MAPPING ROLES. This is disabled as I am not adding these users quite yet.
#$ADGroupName = $env:USERDNSDOMAIN.ToLower() +'\' + (get-content $EnvFile -First 1) + '-SP-Contribute'
#New-SPUser -UserAlias $ADGroupName -Web $SpSiteUrl1 -PermissionLevel Contribute
#$ADGroupName = $env:USERDNSDOMAIN.ToLower() +'\' + (get-content $EnvFile -First 1) + '-SP-Shared-Contribute'
#New-SpUser -UserAlias $ADGroupName -Web $SpSiteUrl2 -PermissionLevel Contribute
#$ADGroupName = $env:USERDNSDOMAIN.ToLower() +'\' + (get-content $EnvFile -First 1) + '-SP-Read'
#New-SpUser -UserAlias $ADGroupName -Web $SpSiteUrl1 -PermissionLevel Read

echo "Post-Install Complete" | Out-File -Append C:\status.txt
