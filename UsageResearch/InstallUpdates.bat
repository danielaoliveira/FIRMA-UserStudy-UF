@echo off
SET install_dir=%~dp0
SET faros_domain=http://faros.ece.ufl.edu:12380/
 
cd %install_dir%Driver
python unzipDriver.py

cd %install_dir%
"%install_dir%Driver\devcon.exe" /r install "%install_dir%Driver\KMDFSystemProfiler.inf" Root\FIRMASystemMonitor

@echo off
ECHO "You are about to restart your machine, please save all your current files/applications"
PAUSE
shutdown -r -f -t 10 -c "Reboot System in 10 Seconds"