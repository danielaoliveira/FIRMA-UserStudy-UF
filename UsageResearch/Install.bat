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
SET /p pid="Please enter your participant ID here:"
>"%install_dir%Client\UserId.txt" ECHO %pid%
SET /p uname="Please enter your name here (avoid spaces and special characters):"
SET /p email="Please enter your primary email here:"

@ECHO OFF

ECHO .
ECHO DO NOT CLOSE THIS WINDOW. Installation is in Progress...

:: Install python if not installed already
IF NOT EXIST "C:\Program Files\Python37\python.exe" (
>NUL "%install_dir%Client\python-3.7.3-amd64-webinstall" /quiet InstallAllUsers=1 PrependPath=1 SimpleInstall=1
>"%install_dir%Client\is_python_installed.txt" ECHO 1
) ELSE (
>"%install_dir%Client\is_python_installed.txt" ECHO 0
)

:: Usually python installation is where our installer fails
:: Check for successful python installation again
IF NOT EXIST "C:\Program Files\Python37\python.exe" (
ECHO Python installation failed. Make sure the system has active internet connection and run installer again
PAUSE
GOTO EndOfFile
)

:: Usually python installation is where our installer fails
:: Check for successful python installation again
IF NOT EXIST "C:\Program Files\Python37\Scripts\pip.exe" (
ECHO Pip not found. Make sure the system has active internet connection and run installer again
PAUSE
GOTO EndOfFile
)

:: Install requests package
:: Not writing errors too as pip cries a lot about version mismatch
>NUL 2>&1 "C:\Program Files\Python37\Scripts\pip" install requests

:: ECHO "Installed python and requests library". Register User now
>NUL py -c "import sys; sys.path.append(r'%install_dir%Client'); import client; client.get_request('%faros_domain%register?username=%uname%&email=%email%&userid=%pid%')"

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

:: Schedule uninstallation after 8 weeks
>NUL powershell -Command "& {cat  ${env:install_dir}Client\ExtractorUninstaller_template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\ExtractorUninstaller_gen.xml}"
FOR /f "tokens=1-4 delims=/ " %%i IN ("%date%") DO (
    SET dow=%%i
    SET month=%%j
    SET day=%%k
    SET year=%%l
)
SET datestr=%year%-%month%-%day%
>NUL powershell -Command "& {cat  ${env:install_dir}Client\ExtractorUninstaller_gen.xml | %%{$_ -replace '#DATETODAY#', $env:datestr} > ${env:install_dir}Client\ExtractorUninstaller.xml}"
>NUL schtasks.exe /create /tn FICSExtractorUninstaller /XML "%install_dir%Client\ExtractorUninstaller.xml"
:: Remove the temp intermediate file
>NUL del "%install_dir%Client\ExtractorUninstaller_gen.xml"

ECHO .
ECHO INSTALLATION COMPLETE
ECHO .
ECHO You are about to restart your machine, please save all your current files/applications and press Enter
ECHO .
PAUSE
shutdown -r -f -t 10 -c "Reboot System in 10 Seconds"

:EndOfFile