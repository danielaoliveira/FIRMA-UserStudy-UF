@echo off
SET install_dir=%~dp0
SET faros_domain=http://faros.ece.ufl.edu:12380/
 
set /p pid="Please enter your participant ID here:"
>"%install_dir%Client\UserId.txt" echo %pid%
set /p uname="Please enter your name here (avoid spaces and special characters):"
set /p email="Please enter your primary email here:"

@echo on
if not exist C:\Windows\TestRecord0 mkdir C:\Windows\TestRecord0
if not exist C:\Windows\TestRecord1 mkdir C:\Windows\TestRecord1
if not exist C:\Windows\TestRecord2 mkdir C:\Windows\TestRecord2
if not exist C:\Windows\TestRecord3 mkdir C:\Windows\TestRecord3
if not exist C:\Windows\TestRecord4 mkdir C:\Windows\TestRecord4
if not exist C:\Windows\TestRecord5 mkdir C:\Windows\TestRecord5
if not exist C:\Windows\TestRecord6 mkdir C:\Windows\TestRecord6
:: ECHO "Created the required directories for the driver"

:: Install the EventLogger
msiexec /I "%install_dir%EventLogger\FIRMALoggerInstaller.msi" /qn /L+ Install.log

if not exist "C:\Program Files\Python37\python.exe" (
"%install_dir%Client\python-3.7.3-amd64-webinstall" /quiet InstallAllUsers=1 PrependPath=1 SimpleInstall=1
>"%install_dir%Client\is_python_installed.txt" echo 1
) else (
>"%install_dir%Client\is_python_installed.txt" echo 0
)

"C:\Program Files\Python37\Scripts\pip" install requests
:: ECHO "Installed python and requests library"
py -c "import sys; sys.path.append(r'%install_dir%Client'); import client; client.get_request('%faros_domain%register?username=%uname%&email=%email%&userid=%pid%')"

powershell -Command "& {cat  ${env:install_dir}Client\template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\FileUploader.xml}" 
schtasks.exe /create /tn FICSUploader /XML "%install_dir%Client\FileUploader.xml"
"%install_dir%Driver\devcon.exe" /r install "%install_dir%Driver\KMDFSystemProfiler.inf" Root\FIRMASystemMonitor

@echo off
ECHO "You are about to restart your machine, please save all your current files/applications"
PAUSE
shutdown -r -f -t 10 -c "Reboot System in 10 Seconds"