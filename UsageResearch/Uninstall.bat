@ECHO OFF

SET install_dir=%~dp0
CD "%install_dir%"

SET faros_domain=https://faros.ece.ufl.edu:12380/
SET /p email=<"%install_dir%Client\UserId.txt"

ECHO UNINSTALLATION IN PROGRESS. PLEASE DO NOT CLOSE THIS WINDOW

:: Unregister User 
>NUL py -3.7 -c "import sys; sys.path.append(r'%install_dir%Client'); import requests; requests.get('%faros_domain%leave?userid=%email%')"

:: Uninstall newly installed python
SET /p python_uninstall=<"%install_dir%Client\is_python_installed.txt"
IF %python_uninstall%==1 (
>NUL "%install_dir%Client\python-3.7.3-amd64-webinstall" /quiet /uninstall
)

:: Remove the Event logger
>NUL msiexec /x "%install_dir%EventLogger\FIRMALoggerInstaller.msi" /qn /L+ Install.log

:: Remove scheduled tasks
>NUL schtasks /delete /f /tn "FICSUploader"
>NUL schtasks /delete /f /tn "FICSWinEventLogger"
>NUL schtasks /delete /f /tn "FICSExtractorUninstaller"

:: Remove sysmon
>NUL 2>&1 "%install_dir%Driver\Sysmon.exe" -u force

:: Delete all newly created files
>NUL DEL "%install_dir%Client\is_python_installed.txt"
>NUL DEL "%install_dir%Client\FileUploader.xml"
>NUL DEL "%install_dir%Client\FICSWinEventLogger.xml"
>NUL DEL "%install_dir%Client\ExtractorUninstaller.xml"

:: Remove the Event logger directories
IF EXIST C:\FIRMA_UserStudy\EventRecord0 >NUL RD C:\FIRMA_UserStudy\EventRecord0 /s /q
IF EXIST C:\FIRMA_UserStudy\EventRecord1 >NUL RD C:\FIRMA_UserStudy\EventRecord1 /s /q
IF EXIST C:\FIRMA_UserStudy\EventRecord2 >NUL RD C:\FIRMA_UserStudy\EventRecord2 /s /q
IF EXIST C:\FIRMA_UserStudy\EventRecord3 >NUL RD C:\FIRMA_UserStudy\EventRecord3 /s /q
IF EXIST C:\FIRMA_UserStudy\EventRecord4 >NUL RD C:\FIRMA_UserStudy\EventRecord4 /s /q
IF EXIST C:\FIRMA_UserStudy\EventRecord5 >NUL RD C:\FIRMA_UserStudy\EventRecord5 /s /q
IF EXIST C:\FIRMA_UserStudy\EventRecord6 >NUL RD C:\FIRMA_UserStudy\EventRecord6 /s /q
IF EXIST C:\FIRMA_UserStudy >NUL RD C:\FIRMA_UserStudy /s /q

ECHO .
ECHO UNINSTALLATION COMPLETE. PLEASE RESTART YOUR MACHINE TO REMOVE ALL COMPONENTS
ECHO .
:: PAUSE
:: shutdown -r -f -t 10 -c "Reboot System in 10 Seconds"