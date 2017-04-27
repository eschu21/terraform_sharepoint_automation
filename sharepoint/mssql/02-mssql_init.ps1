## Variables

$Server = "$env:COMPUTERNAME"
$User = "example\SPAdmin"
$Password = "Summer01!"
$Role = "dbcreator"
#$smo = 'Microsoft.SqlServer.Management.Smo.'
#$wmi = new-object ($smo + 'Wmi.ManagedComputer')




## Create Function to Add User and Role
Function Add-SQLAccountToSQLRole ([String]$Server, [String] $User, [String]$Password, [String]$Role)
{

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

$Svr = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "$env:COMPUTERNAME"

# Check if Role entered Correctly
$SVRRole = $svr.Roles[$Role]
    if($SVRRole -eq $null)
        {
        Write-Host " $Role is not a valid Role on $Server"
        }

    else
        {
#Check if User already exists
                if($svr.Logins.Contains($User))
                            {
                $SqlUser = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login $Server, $User
                $LoginName = $SQLUser.Name
                if($Role -notcontains "public")
                    {

                    $SVRRole.AddMember($LoginName)
                    }
                }

            else
                {
                $SqlUser = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login $Server, $User
                $SqlUser.LoginType = 'WindowsUser'
                $SqlUser.PasswordExpirationEnabled = $false
                $SqlUser.Create($Password)
                $LoginName = $SQLUser.Name
                if($Role -notcontains "public")
                    {
                    $SVRRole.AddMember($LoginName)
                    }
                }
        }

}

## Call function
Add-SQLAccountToSQLRole $Server $User $Password $Role


#Import-Module "sqlps"
#$smo = 'Microsoft.SqlServer.Management.Smo.'
#$wmi = new-object ($smo + 'Wmi.ManagedComputer').
#
#
## List the object properties, including the instance names.
#$Wmi
#
## Enable the Named Pipe protocol on the default instance.
#$uri = "ManagedComputer[@Name='" + (get-item env:\computername).Value + "']/ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Np']"
#$Np = $wmi.GetSmoObject($uri)
#$Np.IsEnabled = $true
#$Np.Alter()
#$Np
#
### Restart SQL Service
## Get a reference to the ManagedComputer class.
#CD SQLSERVER:\SQL\$Server
#$Wmi = (get-item .).ManagedComputer
## Get a reference to the default instance of the Database Engine.
#$DfltInstance = $Wmi.Services['MSSQLSERVER']
## Display the state of the service.
#$DfltInstance
## Stop the service.
#$DfltInstance.Stop();
## Wait until the service has time to stop.
#Start-Sleep -Seconds 30
## Refresh the cache.
#$DfltInstance.Refresh();
## Display the state of the service.
#$DfltInstance
## Start the service again.
#$DfltInstance.Start();
## Wait until the service has time to start.
#Start-Sleep -Seconds 30
## Refresh the cache and display the state of the service.
#$DfltInstance.Refresh(); $DfltInstance


Write-Host "Boostrapping of DB complete!"
