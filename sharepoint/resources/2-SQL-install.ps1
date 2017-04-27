# Local path for SQL ISO
$imagepath = "C:\scripts\prereq\sql2014.iso"
# SQL related variables
$SQLconfigTemplate = 'C:\scripts\Sql-template.ini'
$SQLOutput = 'C:\Scripts\sql.ini'

$EnvFile = 'C:\env.txt'
$environment = (get-content $EnvFile -First 1)
$Usersfile = 'C:\users.txt'

$SiteAdmin =  (get-content $Usersfile)[1]
$SPAppPoolAcct = (get-content $Usersfile)[2]
$SPSqlSysAdmin = $SiteAdmin
$SPSqlSvc = '_' + $Environment + '-sp01'

# Configures script to run on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-Prereq' -Value "c:\windows\system32\cmd.exe /c C:\scripts\3-Prereq1.bat"

# Add user to local admin group
$strComputer = "$env:COMPUTERNAME"
$computer = [ADSI]("WinNT://" + $strComputer + ",computer")
$computer.name
$Group = $computer.psbase.children.find("administrators")
$Group.name
$Group.Add("WinNT://" + $env:USERDOMAIN + "/" + $SPAppPoolAcct)

$SPSqlSvcFQDN = "$env:USERDNSDOMAIN\" + "$SPSqlSvc"
$SPSqlSysAdmin = "$env:USERDNSDOMAIN\" + "$SPSqlSysAdmin"


# Mounts ISO and set drivelette variable
$mount = Mount-DiskImage -ImagePath $imagepath -PassThru
$drive = $mount | Get-Volume
$driveletter = $drive.DriveLetter + ":"

(get-content $SQLconfigTemplate).replace("Variable1",$env:USERDNSDOMAIN + "\" + "Domain Admins").replace("Variable2","$SPSqlSysAdmin") | Set-Content $SQLOutput

$Argumentlist= "/qs /CONFIGURATIONFILE=$SQLOutput /IACCEPTSQLSERVERLICENSETERMS"

Start-Process -FilePath $driveletter\setup.exe -ArgumentList $Argumentlist -Wait -PassThru

#If not installed add the PowerShell AD features
if ((Get-WindowsFeature RSAT-AD-PowerShell).InstallState -ne 'Installed') {
	Add-WindowsFeature RSAT-AD-PowerShell
}

# Adds one or more managed service accounts to an Active Directory computer
Add-ADComputerServiceAccount -Identity $env:COMPUTERNAME -ServiceAccount $SPSqlSvc
#Installs an Active Directory service account on a computer
Install-ADServiceAccount $SPSqlSvc

#Reconfigure SQL Server to use the new Managed service account
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null
 
$SMOWmiserver = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') "$env:COMPUTERNAME"           
$ChangeService=$SMOWmiserver.Services | where {$_.name -eq 'MSSQLSERVER'} 
$UName="$SPSqlSvcFQDN$"
$PWord=""           
$ChangeService.SetServiceAccount($UName, $PWord)

#If installed remove the PowerShell AD features
if ((Get-WindowsFeature RSAT-AD-PowerShell).InstallState -eq 'Installed' -or 'InstallPending' ) {
	Remove-WindowsFeature RSAT-AD-PowerShell
}
    
Restart-Computer -Force