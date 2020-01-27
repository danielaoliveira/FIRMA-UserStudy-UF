SET install_dir=%~dp0
SET faros_domain=http://faros.ece.ufl.edu:12380/

SET /p pid=<"%install_dir%Client\UserId.txt"

cd "%install_dir%"

:: Remove the Event logger
msiexec /x "%install_dir%EventLogger\FIRMALoggerInstaller.msi" /qn /L+ Install.log

:: Unregister User 
py -c "import sys; sys.path.append(r'%install_dir%Client'); import client; client.get_request('%faros_domain%leave?userid=%pid%')"

:: Uninstall newly installed python
SET /p python_uninstall=<"%install_dir%Client\is_python_installed.txt"
if %python_uninstall% == 1 (
"%install_dir%Client\python-3.7.3-amd64-webinstall" /quiet /uninstall
)

@echo on
:: Remove scheduled tasks
schtasks /delete /f /tn "FICSUploader"
schtasks /delete /f /tn "FICSWinEventLogger"
schtasks /delete /f /tn "ExtractorUninstaller"

:: Remove sysmon
"%install_dir%Driver\Sysmon.exe" -u force

:: Delete all newly created files
del "%install_dir%Client\is_python_installed.txt"
del "%install_dir%Client\FileUploader.xml"
del "%install_dir%Client\FICSWinEventLogger.xml"
del "%install_dir%Client\ExtractorUninstaller_template.xml"
del "%install_dir%Client\ExtractorUninstaller.xml"

:: Remove the Event logger directories
if exist C:\FIRMA_UserStudy\EventRecord0 rd C:\FIRMA_UserStudy\EventRecord0 /s /q
if exist C:\FIRMA_UserStudy\EventRecord1 rd C:\FIRMA_UserStudy\EventRecord1 /s /q
if exist C:\FIRMA_UserStudy\EventRecord2 rd C:\FIRMA_UserStudy\EventRecord2 /s /q
if exist C:\FIRMA_UserStudy\EventRecord3 rd C:\FIRMA_UserStudy\EventRecord3 /s /q
if exist C:\FIRMA_UserStudy\EventRecord4 rd C:\FIRMA_UserStudy\EventRecord4 /s /q
if exist C:\FIRMA_UserStudy\EventRecord5 rd C:\FIRMA_UserStudy\EventRecord5 /s /q
if exist C:\FIRMA_UserStudy\EventRecord6 rd C:\FIRMA_UserStudy\EventRecord6 /s /q
if exist C:\FIRMA_UserStudy rd C:\FIRMA_UserStudy /s /q

@echo off
ECHO "You are about to restart your machine, please save all your current files/applications"
PAUSE
shutdown -r -f -t 10 -c "Reboot System in 10 Seconds"