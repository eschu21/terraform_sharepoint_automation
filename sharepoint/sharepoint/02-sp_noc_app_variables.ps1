$EnvironmentName = 'example'
$IP = (Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 -InterfaceAlias Ethernet | Select IPAddress -ExpandProperty IPAddress)
$SubnetMask = '24'
$Gateway = '10.100.101.50'
$DNS = '10.100.101.50'
$DomainName = 'example.com'
$NetBIOSName  = 'example'
$LocalAdminPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SiteAdmin = 'admin'
$SiteAdminPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SharepointFarmPassphrase = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SharepointFarmAcct = 'SPAdmin'
$SharepointFarmPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SharepointAppPoolAcct = 'svc-spAppPool'
$SharepointAppPoolPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$EnterpriseAdmin = 'spadmin'
$EnterpriseAdminPW  = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$NewComputerName = 'hal-app-sp01'
$OU = 'OU=UsersSP2016,DC=example,DC=com'
$DomainController = 'dc01'
$RootCA = 'ldap:dc01.example.com\example-DC01-CA'

echo "Variables Set" | Out-File -Append C:\status.txt

& "C:\scripts\03-sp_Baseline.ps1" `
-EnvironmentName $EnvironmentName `
-IP $IP `
-SubnetMask $SubnetMask `
-Gateway $Gateway `
-DNS $DNS `
-DomainName $DomainName `
-NetBIOS $NetBIOSName `
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
-RootCA $RootCA
