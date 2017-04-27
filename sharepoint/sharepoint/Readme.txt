RDP to NOC-RDGW as administrator

RDP to NOC-SP01
Open Powershell as administrator and run below command 

Set-ExecutionPolicy Unrestricted -force
new-item -type directory -path c:\scripts | explorer c:\scripts

Copy files from RD Gateway Desktop to NOC-SP01
NOC > Sharepoint > content to NOC-SP01 C:\Scripts

Run command
C:\scripts\noc_variables.ps1
powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\1_Baseline.ps1

Computer will reboot several times and install Sharepoint ~ 60 min

RDP to NOC-SP01

Verify Sharepoint services are running
Sharepoint Central administration is accessible https://computername:2016
Verify access to Sharepoint sites https://computername + domainame/sites/doc and https://computername + domainname/sites/shared (only for NOC)
