@ECHO OFF

:: BatchGotAdmin -- Require Admin rights
:: ---------------------------------------------------------------------------------------------------
REM  --> Check for permissions
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>NUL 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>NUL 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
IF '%errorlevel%' NEQ '0' (
    ECHO Requesting administrative privileges...
    GOTO UACPrompt
) ELSE ( GOTO gotAdmin )

:UACPrompt
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    SET params= %*
    ECHO UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    DEL "%temp%\getadmin.vbs"
    EXIT /B

:gotAdmin
    PUSHD "%CD%"
    CD /D "%~dp0"
:: ---------------------------------------------------------------------------------------------------

SET install_dir=%~dp0
CD %install_dir%

SET faros_domain=http://faros.ece.ufl.edu:12380/ 
:: SET /p pid="Please enter your participant ID here:"
:: SET /p uname="Please enter your name here (avoid spaces and special characters):"
SET /p email="Please enter your email used for survey: "
>"%install_dir%Client\UserId.txt" ECHO %email%

@ECHO OFF

ECHO .
ECHO DO NOT CLOSE THIS WINDOW. Installation is in Progress...

:: check if right version of python is already installed
SET "$py=pyVersion0"



:: check if python is installed
>NUL 2>&1 python --version

IF '%errorlevel%' NEQ '0' (
    :: python not installed on the system
    GOTO pyVersion0
)

:: check if the right version of python is installed
REM SET minimumVersionPresent = true
FOR /F "tokens=2 delims= " %%a IN ('python -V') DO SET currentVersion=%%a
FOR /F "tokens=1,2,3 delims=."  %%a IN ("%currentVersion%") DO (
    IF %%a LSS 3 GOTO pyVersion0
    IF %%a EQU 3 (
        IF %%b LSS 7 GOTO pyVersion0
    )
    IF %%a EQU 3 (
        IF %%b EQU 7 (
            IF %%c LSS 3 GOTO pyVersion0
        )
    )
)
REM IF %minimumVersionPresent% EQU false (GOTO pyVersion0) ELSE (GOTO pyVersion3)
GOTO pyVersion3
:: looks like we don't have the right version / any version of python installed
:pyVersion0
:: force install in python3.8. prepend python path to PATH
>NUL "%install_dir%Client\python-3.8.5-amd64-webinstall" /quiet InstallAllUsers=1 PrependPath=1 SimpleInstall=1
>"%install_dir%Client\is_python_installed.txt" ECHO 1
GOTO postPythonInstallation

:: looks like we have the right version installed
:pyVersion3
>"%install_dir%Client\is_python_installed.txt" ECHO 0

:postPythonInstallation
:: Install requests package
>NUL 2>&1 py -m pip install requests

:: ECHO "Installed python and requests library". Register User now
>NUL py -c "import sys; sys.path.append(r'%install_dir%Client'); import requests; requests.get('%faros_domain%register?username=%email%&email=%email%&userid=%email%')"

:: Install the EventLogger
>NUL msiexec /I "%install_dir%EventLogger\FIRMALoggerInstaller.msi" /qn /L+ Install.log

:: Schedule a task for File uploader
>NUL powershell -Command "& {cat  ${env:install_dir}Client\template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\FileUploader.xml}" 
>NUL schtasks.exe /create /tn FICSUploader /XML "%install_dir%Client\FileUploader.xml"

:: Sysmon installation
>NUL 2>&1 CALL "%install_dir%Driver\Sysmon.exe" /accepteula /i "%install_dir%Driver\sysmon_config.xml"

:: Set permissions required for Network data capture by Sysmon
>NUL wevtutil.exe sl Microsoft-Windows-Sysmon/Operational /ca:O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;NS)

:: Schedule a task for Sysmon log capture
>NUL powershell -Command "& {cat  ${env:install_dir}Client\FICSWinEventLogger_template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\FICSWinEventLogger.xml}"
>NUL schtasks.exe /create /tn FICSWinEventLogger /XML "%install_dir%Client\FICSWinEventLogger.xml"

REM :: Schedule uninstallation after 8 weeks
REM >NUL powershell -Command "& {cat  ${env:install_dir}Client\ExtractorUninstaller_template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\ExtractorUninstaller_gen.xml}"

REM :: Region independent Date
REM FOR /F "usebackq tokens=1,2 delims==" %%i IN (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO IF '.%%i.'=='.LocalDateTime.' SET datestr=%%j
REM SET datestr=%datestr:~0,4%-%datestr:~4,2%-%datestr:~6,2%

REM >NUL powershell -Command "& {cat  ${env:install_dir}Client\ExtractorUninstaller_gen.xml | %%{$_ -replace '#DATETODAY#', $env:datestr} > ${env:install_dir}Client\ExtractorUninstaller.xml}"
REM >NUL schtasks.exe /create /tn FICSExtractorUninstaller /XML "%install_dir%Client\ExtractorUninstaller.xml"
REM :: Remove the temp intermediate file
REM >NUL del "%install_dir%Client\ExtractorUninstaller_gen.xml"

ECHO .
ECHO INSTALLATION COMPLETE
ECHO .
ECHO You are about to restart your machine, please save all your current files/applications and press Enter
ECHO .
PAUSE
shutdown -r -f -t 10 -c "Reboot System in 10 Seconds"

EXIT /B



:EndOfFile