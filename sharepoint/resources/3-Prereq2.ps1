# Local path for Sharepoint image
$imagepath = "C:\scripts\prereq\shp2016.img"

# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-Prereq' -Value "c:\windows\system32\cmd.exe /c C:\scripts\4-Install.bat"

# Mounts ISO and set drivelette variable
$mount = Mount-DiskImage -ImagePath $imagepath -PassThru
$drive = $mount | Get-Volume
$driveletter = $drive.DriveLetter + ":"

Start-Process -FilePath $driveletter\prerequisiteinstaller.exe -ArgumentList '/unattended' -Wait -PassThru
Restart-Computer -Force