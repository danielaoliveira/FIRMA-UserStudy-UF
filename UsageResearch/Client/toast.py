import ctypes
class Buttons:
    BTN_OKCANCEL = 1
    IDOK = 1
    IDCANCEL = 2

def Mbox(title, text, style):
    return ctypes.windll.user32.MessageBoxW(0, text, title, style)
btnPressed = Mbox(u'UserStudy complete', u'Study complete! You may uninstall the profiler now', Buttons.BTN_OKCANCEL)

if btnPressed == Buttons.IDOK:
    print ("ok")
elif btnPressed == Buttons.IDCANCEL:
    print ("cancel")
else:
    print ("what button")

