# Local path for Sharepoint image
$imagepath = "C:\scripts\prereq\officeserver.img"
# Mounts ISO and set drivelette variable
$mount = Mount-DiskImage -ImagePath $imagepath -PassThru
$drive = $mount | Get-Volume
$driveletter = $drive.DriveLetter + ":"
# Sharepoint configuraiton file
$configlist = "C:\scripts\config.xml"

$EnvFile = 'C:\env.txt'
$Environment = (get-content $EnvFile -First 1)
$Usersfile = 'C:\users.txt'

# Configures script to run once on next logon -DISABLED TO TEST SWITCHING USERS
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-farm' -Value "c:\windows\system32\cmd.exe /c C:\scripts\06-sp_Create_farm.bat"

# Install Sharepoint
Start-Process $driveletter\setup.exe -ArgumentList "/config `"$configlist`"" -PassThru -Wait

echo "Sharepoint Installed" | Out-File -Append C:\status.txt

## Will re-enable the restart once I get all scripts working
Restart-Computer -Force
