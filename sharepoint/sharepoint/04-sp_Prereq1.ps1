# Local path for Sharepoint image
$imagepath = "C:\scripts\prereq\officeserver.img"

# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'SP-Prereq2' -Value "c:\windows\system32\cmd.exe /c C:\scripts\04-sp_Prereq2.bat"

# Mounts ISO and set drivelette variable
$mount = Mount-DiskImage -ImagePath $imagepath -PassThru
$drive = $mount | Get-Volume
$driveletter = $drive.DriveLetter + ":"

#Directory path where SP 2016 files are stored
$PreRequsInstallerPath= $driveletter

#Directory path where SP 2016 Pre-requisites files are kept
$PreRequsFilesPath = "C:\Scripts\prereq"

cmd /c $PreRequsInstallerPath\PrerequisiteInstaller.exe /unattended  /SQLNCli:$PreRequsFilesPath\sqlncli.msi /idfx11:C:\scripts\prereq\MicrosoftIdentityExtensions-64.msi /Sync:$PreRequsFilesPath\Synchronization.msi /AppFabric:$PreRequsFilesPath\WindowsServerAppFabricSetup_x64.exe /kb3092423:$PreRequsFilesPath\AppFabric-KB3092423-x64-ENU.exe /MSIPCClient:$PreRequsFilesPath\setup_msipc_x64.exe /wcfdataservices56:$PreRequsFilesPath\WcfDataServices.exe /odbc:$PreRequsFilesPath\msodbcsql.msi /msvcrt11:$PreRequsFilesPath\vc_redist.x64.exe /msvcrt14:$PreRequsFilesPath\vcredist_x64.exe /dotnetfx:$PreRequsFilesPath\NDP46-KB3045557-x86-x64-AllOS-ENU.exe

echo "Prereq1 Complete" | Out-File -Append C:\status.txt

## Will re-enable the restart once I get all scripts working
Restart-Computer -Force
