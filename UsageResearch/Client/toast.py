import ctypes
import os
from subprocess import Popen

CWD = os.getcwd()

class Buttons:
    BTN_OKCANCEL = 1
    IDOK = 1
    IDCANCEL = 2

def Mbox(title, text, style):
    return ctypes.windll.user32.MessageBoxW(0, text, title, style)


def uninstallIfNeeded():
    btnPressed = Mbox(u'UserStudy complete', u'Study complete! Click OK to uninstall the Extractor now', Buttons.BTN_OKCANCEL)
    
    if btnPressed == Buttons.IDOK:
        p = Popen(r"Uninstall.bat", cwd=CWD)
        stdout, stderr = p.communicate()
        print (stdout)
        print (stderr)
        
    elif btnPressed == Buttons.IDCANCEL:
        print ("Uninstallation to be done later")
    
    else:
        print ("Unknown Button ID")

if __name__ == "__main__":
    uninstallIfNeeded()
    