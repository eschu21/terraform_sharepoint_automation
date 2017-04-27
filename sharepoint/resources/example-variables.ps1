<#
Edit the following variables before running.
$IP
$SubnetMask
$Gateway
$DNS
$NetworkID
#>
$csv = import-csv "c:\scripts\variables.csv"
$IP= $csv.sharepointip
$EnvironmentName = $csv.sitename
$dns= $csv.dns
$Gateway = $csv.gateway
$SubnetMask = $csv.subnetmask


$DomainName = 'example.com' 
$NetBIOS  = 'example'
$LocalAdminPW = (ConvertTo-SecureString 'Pasword123' -AsPlainText -Force)
$SiteAdmin = 'example_admin'
$SiteAdminPW = (ConvertTo-SecureString 'Pasword123' -AsPlainText -Force)
$SharepointFarmPassphrase = (ConvertTo-SecureString 'Pasword123' -AsPlainText -Force)
$SharepointFarmAcct = 'example-spFarmAcct'
$SharepointFarmPW = (ConvertTo-SecureString 'Pasword123' -AsPlainText -Force)
$SharepointAppPoolAcct = 'example-spAppPool'
$SharepointAppPoolPW = (ConvertTo-SecureString 'Pasword123' -AsPlainText -Force)
$EnterpriseAdmin = 'admin'
$EnterpriseAdminPW  = (ConvertTo-SecureString 'Pasword123' -AsPlainText -Force)
$NewComputerName = 'example-sp01'
$OU = 'OU=Computers,DC=example,DC=mil'
$DomainController = 'example-dc01'
$RootCA = 'ldap:example-dc01.example.com\example-example-DC01-CA'
$FirstSharePointServer = 'Yes'


& "C:\scripts\1-Baseline.ps1" `
-EnvironmentName $EnvironmentName `
-IP $IP `
-SubnetMask $SubnetMask `
-Gateway $Gateway `
-DNS $DNS `
-DomainName $DomainName `
-NetBIOS $NetBIOS `
-LocalAdminPW $LocalAdminPW `
-SiteAdmin $SiteAdmin `
-SiteAdminPW $SiteAdminPW `
-SharepointFarmPassphrase $SharepointFarmPassphrase `
-SharepointFarmAcct $SharepointFarmAcct `
-SharepointFarmPW $SharepointFarmPW `
-SharepointAppPoolAcct $SharepointAppPoolAcct `
-SharepointAppPoolPW $SharepointAppPoolPW `
-EnterpriseAdmin $EnterpriseAdmin `
-EnterpriseAdminPW $EnterpriseAdminPW `
-NewComputerName $NewComputerName `
-DomainController $DomainController `
-OU $OU `
-RootCA $RootCA `
-FirstSharepointServer $FirstSharePointServer
