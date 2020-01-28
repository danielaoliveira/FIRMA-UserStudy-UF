@echo off
SET install_dir=%~dp0
SET faros_domain=http://faros.ece.ufl.edu:12380/
 
set /p pid="Please enter your participant ID here:"
>"%install_dir%Client\UserId.txt" echo %pid%
set /p uname="Please enter your name here (avoid spaces and special characters):"
set /p email="Please enter your primary email here:"

@echo on

cd %install_dir%

:: Install the EventLogger
msiexec /I "%install_dir%EventLogger\FIRMALoggerInstaller.msi" /qn /L+ Install.log

:: Install python if not installed already
if not exist "C:\Program Files\Python37\python.exe" (
"%install_dir%Client\python-3.7.3-amd64-webinstall" /quiet InstallAllUsers=1 PrependPath=1 SimpleInstall=1
>"%install_dir%Client\is_python_installed.txt" echo 1
) else (
>"%install_dir%Client\is_python_installed.txt" echo 0
)

:: Install requests package
"C:\Program Files\Python37\Scripts\pip" install requests

:: ECHO "Installed python and requests library". Register User now
py -c "import sys; sys.path.append(r'%install_dir%Client'); import client; client.get_request('%faros_domain%register?username=%uname%&email=%email%&userid=%pid%')"

:: Schedule a task for File uploader
powershell -Command "& {cat  ${env:install_dir}Client\template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\FileUploader.xml}" 
schtasks.exe /create /tn FICSUploader /XML "%install_dir%Client\FileUploader.xml"

:: Sysmon installation
CALL "%install_dir%Driver\Sysmon.exe" /accepteula /i "%install_dir%Driver\sysmon_config.xml"

:: Set permissions required for Network data capture by Sysmon
wevtutil.exe sl Microsoft-Windows-Sysmon/Operational /ca:O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;NS)

:: Schedule a task for Sysmon log capture
powershell -Command "& {cat  ${env:install_dir}Client\FICSWinEventLogger_template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\FICSWinEventLogger.xml}"
schtasks.exe /create /tn FICSWinEventLogger /XML "%install_dir%Client\FICSWinEventLogger.xml"

@echo off
ECHO "You are about to restart your machine, please save all your current files/applications"
PAUSE
shutdown -r -f -t 10 -c "Reboot System in 10 Seconds"