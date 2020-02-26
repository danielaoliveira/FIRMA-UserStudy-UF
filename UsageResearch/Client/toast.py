import ctypes
import os
from subprocess import Popen

CWD = os.getcwd()

class ButtonDisplay:
    BTN_OK = 0
    BTN_OKCANCEL = 1
    
class ButtonPress:
    IDOK = 1
    IDCANCEL = 2

def Mbox(title, text, style):
    return ctypes.windll.user32.MessageBoxW(0, text, title, style)


def uninstallIfNeeded():
    btnPressed = Mbox(u'UserStudy complete', u'Study complete! Click OK to uninstall the Extractor now', ButtonDisplay.BTN_OKCANCEL)
    
    if btnPressed == ButtonPress.IDOK:
        p = Popen(r"Uninstall.bat", cwd=CWD)
        p.wait()
        #stdout, stderr = p.communicate()
        #print (stdout)
        #print (stderr)
        Mbox(u'UserStudy complete', u'Uninstall complete. All components will be removed successfully on Restart', ButtonDisplay.BTN_OK)
        
    elif btnPressed == ButtonPress.IDCANCEL:
        print ("Uninstallation to be done later")
        Mbox(u'UserStudy complete', u'Uninstall cancelled. Please run Uninstall.bat as Administrator and Restart to uninstall Extractor', ButtonDisplay.BTN_OK)
    
    else:
        print ("Unknown Button ID")

if __name__ == "__main__":
    uninstallIfNeeded()
    