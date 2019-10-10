@echo off

for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
     set dow=%%i
     set month=%%j
     set day=%%k
     set year=%%l
)
set datestr=%year%_%month%_%day%
wevtutil qe "Microsoft-Windows-Sysmon/Operational" /c:1000 /q:"*[System[TimeCreated[timediff(@SystemTime)<300000]]]" /e:Events /f:xml  >> "C:\FIRMA_UserStudy\EventRecord0\%datestr%_SysmonEventLog_%RANDOM%.xml"

@echo off