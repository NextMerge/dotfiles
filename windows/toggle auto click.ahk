f1::
toggle := !toggle  ;toggle on off
tooltip % "AutoClicker: " (toggle ? "ACTIVE" : "OFF")
settimer,tooltipoff,1000 ;set a timer for 1 second to clear the tooltip
return

tooltipoff:
settimer,tooltipoff,off ;turn the timer off
tooltip ;clear the tooltip
return

#if toggle ;hotkey only works if toggled on
~$LButton::
    While (toggle) { ; and GetKeyState("LButton", "P")) { if not toggle or not holding lbutton stop
        Click
        Sleep 50  ;  milliseconds
    }
return
#if ;reset condition so all hotkeys work if posted under here