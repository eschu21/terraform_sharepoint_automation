$NewComputerName = "dc01"
$Domain = "example"
# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'AD_Create' -Value "c:\windows\system32\cmd.exe /c C:\scripts\01-ad_init.bat"

Rename-Computer -NewName $NewComputerName
Start-Sleep -Seconds 5
Restart-Computer -Force
