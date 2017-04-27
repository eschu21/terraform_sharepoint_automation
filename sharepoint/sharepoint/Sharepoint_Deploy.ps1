# Path for variable CSV
$csvpath = "c:\scripts\variables.csv"

# Credentials to connect to remote computer
$User = $IP + '\' + 'administrator'
$UserPW = 'Password123'

# Variables
$csv = import-csv $csvpath
$IP= $csv.sharepointip
$ScriptSourcePath= $csv.scriptsource+"\Sharepoint"
$sitename = $csv.sitename


#$UserPW = Read-host 'Enter local admin password'
$PW = (ConvertTo-SecureString $UserPW -AsPlainText -Force)

# Remote path for scripts
$RemoteComputerPath = 'C:\scripts\'
$RemoteScript = "$RemoteComputerPath\$sitename-variables.ps1"

# Create secure credential object
$Cred = $Credential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PW
# Create remote session and copy files
$TargetSession = New-PSSession -ComputerName $IP -Credential $Cred

Write-host "Connecting to Computer $IP.... copying files...." -ForegroundColor Green
Copy-Item -ToSession $TargetSession -Path $ScriptSourcePath, $csvpath -Destination $RemoteComputerPath -Recurse
Write-Host "File copy has completed" -ForegroundColor Green

Write-Host "Starts script on remote computer $IP" -ForegroundColor Green
# Start deployment script as a job on remote computer
$DeployJob = Invoke-Command -ComputerName $IP -ScriptBlock { & $($args[0]) } -JobName "DeployScript" -AsJob -Credential $Cred -ArgumentList $RemoteScript
$job = get-job

Write-Output $DeployJob
Wait-Job $DeployJob

Write-Host 'Remote job output' -ForegroundColor Green
" `n `n"
Receive-Job -Id $job.Id

# Start deployment script on remote computer
#Invoke-Command -Computername $IP -ScriptBlock { & 'C:\scripts\noc_variables.ps1' } -Credential $Cred
