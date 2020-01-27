import ctypes
from subprocess import Popen

CWD = os.getcwd()

class Buttons:
    BTN_OKCANCEL = 1
    IDOK = 1
    IDCANCEL = 2

def Mbox(title, text, style):
    return ctypes.windll.user32.MessageBoxW(0, text, title, style)


def uninstallIfNeeded():
    btnPressed = Mbox(u'UserStudy complete', u'Study complete! You may uninstall the profiler now', Buttons.BTN_OKCANCEL)
    
    if btnPressed == Buttons.IDOK:
        p = Popen("Uninstall.bat", cwd=r"CWD")
        stdout, stderr = p.communicate()
    elif btnPressed == Buttons.IDCANCEL:
        print ("cancel")
    else:
        print ("what button")

if __name__ == "__main__":
    try:
        uninstallIfNeeded()
    except:
        logging.warning('Had an exception while running the client!')
        logging.warning(traceback.format_exc())
