@echo off
SET install_dir=%~dp0

CALL "%install_dir%Driver\Sysmon.exe" /accepteula /i "%install_dir%Driver\sysmon_config.xml"

wevtutil.exe sl Microsoft-Windows-Sysmon/Operational /ca:O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;NS)

cd %install_dir%
powershell -Command "& {cat  ${env:install_dir}Client\FICSWinEventLogger_template.xml | %%{$_ -replace '#FICSTEST#', $env:install_dir} > ${env:install_dir}Client\FICSWinEventLogger.xml}" 
schtasks.exe /create /tn FICSWinEventLogger /XML "%install_dir%Client\FICSWinEventLogger.xml"


@echo off
ECHO "If you don't see any error messages hit Enter. Otherwise mail a screenshot"
PAUSE