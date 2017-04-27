# Local path for Sharepoint image
$imagepath = "C:\scripts\prereq\officeserver.img"

# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-Prereq' -Value "c:\windows\system32\cmd.exe /c C:\scripts\05-sp_Install.bat"

# Mounts ISO and set drivelette variable
$mount = Mount-DiskImage -ImagePath $imagepath -PassThru
$drive = $mount | Get-Volume
$driveletter = $drive.DriveLetter + ":"

Start-Process -FilePath $driveletter\prerequisiteinstaller.exe -ArgumentList '/unattended' -Wait -PassThru

echo "Prereq2 complete" | Out-File -Append C:\status.txt

## Will re-enable the restart once I get all scripts working
Restart-Computer -Force
