@echo off

:: Region independent Date
FOR /F "usebackq tokens=1,2 delims==" %%i IN (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO IF '.%%i.'=='.LocalDateTime.' SET datestr=%%j
SET datestr=%datestr:~0,4%_%datestr:~4,2%_%datestr:~6,2%
SET rand=%RANDOM%
wevtutil qe "Microsoft-Windows-Sysmon/Operational" /c:1000 /q:"*[System[TimeCreated[timediff(@SystemTime)<300000]]]" /e:Events /f:xml  >> "C:\FIRMA_UserStudy\EventRecord0\%datestr%_SysmonEventLog_%rand%.xml"
ECHO "Flushing DNS at %datestr% -- %rand%" >> "C:\FIRMA_UserStudy\dnslog.txt"
ipcongif /flushDNS
ECHO "DNS Flushing done at %datestr% -- %rand%" >> "C:\FIRMA_UserStudy\dnslog.txt"
@echo off