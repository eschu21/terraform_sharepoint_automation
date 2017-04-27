$NewComputerName = "mssql01"

# Configures script to run once on next logon
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'AD_Create' -Value "c:\windows\system32\cmd.exe /c C:\scripts\01-mssql_ad_join.bat"

Rename-Computer -NewName $NewComputerName
Start-Sleep -Seconds 5
Restart-Computer -Force
