$EnvironmentName = 'example'
$IP = (Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 -InterfaceAlias Ethernet | Select IPAddress -ExpandProperty IPAddress)
$SubnetMask = '24'
$Gateway = '10.10.10.1'
$DNS = '172.31.19.69'
$DomainName = 'example.com`'
$NetBIOS  = 'example.com`'
$LocalAdminPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SiteAdmin = 'admin'
$SiteAdminPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SharepointFarmPassphrase = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SharepointFarmAcct = 'svc-spFarmAcct'
$SharepointFarmPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$SharepointAppPoolAcct = 'svc-spAppPool'
$SharepointAppPoolPW = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$EnterpriseAdmin = 'admin'
$EnterpriseAdminPW  = (ConvertTo-SecureString 'Summer01!' -AsPlainText -Force)
$NewComputerName = 'noc-sp01'
$OU = 'OU=Computers,OU=org,DC=example,DC=com'
$DomainController = 'noc-sp01'
$RootCA = 'ldap:dc01.example.com\example-DC01-CA'


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
-RootCA $RootCA
