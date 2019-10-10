@echo off
SET install_dir=%~dp0

cd %install_dir%Driver
START "" /D Sysmon.exe "-accepteula –i -c "%install_dir%Driver\sysmon_config.xml""
 
cd %install_dir%
powershell -Command "& {cat  ${env:install_dir}Client\FICSWinEventLogger_template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\FICSWinEventLogger.xml}" 
schtasks.exe /create /tn FICSWinEventLogger /XML "%install_dir%Client\FICSWinEventLogger.xml"

@echo off
ECHO "If you don't see any error messages hit Enter. Otherwise mail a screenshot"
PAUSE