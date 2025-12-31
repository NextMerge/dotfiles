#Requires AutoHotkey v2.0
SendMode("Event") ; Without this keys sometimes get stuck in Roblox

global listOfExeNamesFileName := "game exes.txt"
global targetExes := []
global targetQWERTYExes := []
global noVpnWarningExes := []

ReadExeNamesFromTxt(listOfExeNamesFileName)

global exeAppendices := ["-Win64-Shipping", "-WinGDK-Shipping"]

global disableGlobal := true
global forceGaming := false
global forceQWERTY := false

global TYPING_MODE_TIMEOUT_MS := 700
global typingMode := false

DisableTypingMode() {
    global typingMode
    typingMode := false
}

ResetTypingModeTimer() {
    global typingMode
    typingMode := true
    SetTimer(DisableTypingMode, 0)
    SetTimer(DisableTypingMode, TYPING_MODE_TIMEOUT_MS)
}

ReadExeNamesFromTxt(fileName) {
    scriptDir := A_ScriptDir
    filePath := scriptDir . "\" . fileName
    if !FileExist(filePath) {
        MsgBox("File not found: " . filePath)
        return
    }

    gettingQwertyExes := false

    for line in StrSplit(FileRead(filePath), "`n") {
        line := Trim(line)
        if (line = "") {
            continue
        }

        hasNoVpnWarning := false

        if InStr(line, ";") {
            if (line = ";QWERTY;") {
                gettingQwertyExes := true
                continue
            }

            ; Check for ;nov flag
            if InStr(line, ";nov") {
                hasNoVpnWarning := true
            }

            line := Trim(StrSplit(line, ";")[1])
        }

        if (line != "") {
            if (gettingQwertyExes) {
                targetQWERTYExes.Push(line)
            } else {
                targetExes.Push(line)
            }

            if (hasNoVpnWarning) {
                noVpnWarningExes.Push(line)
            }
        }
    }
}

ShouldSwapKeys() {
    return (forceGaming && !forceQWERTY) || (disableGlobal && IsTargetExeActive(targetExes))
}

ShouldSwapKeysForQWERTY() {
    return forceQWERTY || (disableGlobal && IsTargetExeActive(targetQWERTYExes))
}

IsTargetExeActive(exesToCheck) {
    try {
        activeExe := WinGetProcessName("A")
        SplitPath(activeExe, , , , &activeExeNameNoExt)
        for exe in exesToCheck {
            if (StrLower(activeExeNameNoExt) = StrLower(exe)) {
                return true
            }

            for appendix in exeAppendices {
                if (activeExeNameNoExt = exe . appendix) {
                    return true
                }
            }
        }
        return false
    } catch {
        return false
    }
}

IsMegaVPNRunning() {
    try {
        megaVPNProcessName := "MEGA VPN.exe"
        megaVPNProcessCount := 0
        for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process") {
            if (proc.Name = megaVPNProcessName) {
                megaVPNProcessCount++
            }
        }

        return megaVPNProcessCount >= 2 ; 1 for the actual process, 1 for the VPN tunnel
    }

    return false
}

WarningOnVPNActive() {
    isTargetExe := IsTargetExeActive(targetExes)
    isTargetQWERTYExe := IsTargetExeActive(targetQWERTYExes)

    shouldSkipVpnWarning := IsTargetExeActive(noVpnWarningExes)

    if ((isTargetExe || isTargetQWERTYExe) && IsMegaVPNRunning() && !shouldSkipVpnWarning) {
        ToolTip("Warning: Game launched with MEGA VPN running")
        SetTimer(() => ToolTip(), -1000)
    }
}

ToggleKeySwaps() {
    global disableGlobal
    disableGlobal := !disableGlobal
    if (disableGlobal) {
        ToolTip("Key swaps enabled")
    } else {
        ToolTip("Key swaps disabled")
    }
    SetTimer(() => ToolTip(), -1000)
}

ToggleQWERTY() {
    global forceQWERTY
    forceQWERTY := !forceQWERTY
    ToolTip("QWERTY mode: " . (forceQWERTY ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -1000)
}

CopyExeNameToClipboardAndOpenFile() {
    try {
        activeExe := WinGetProcessName("A")
        activeExe := RegExReplace(activeExe, "\.exe$", "")
        A_Clipboard := "`n" . activeExe
        ToolTip("Copied exe name to clipboard: " . activeExe)
        SetTimer(() => ToolTip(), -1000)
        Run("notepad.exe " . A_ScriptDir . "\" . listOfExeNamesFileName)
    } catch {
        ToolTip("Error copying exe name to clipboard")
        SetTimer(() => ToolTip(), -1000)
    }
}

CheckVpnStatus() {
    if (IsMegaVpnRunning()) {
        ToolTip("MEGA VPN Tunnel is running")
    } else {
        ToolTip("MEGA VPN Tunnel is NOT running")
    }
    SetTimer(() => ToolTip(), -1000)
}

TypeOutSanitizedTextInClipboard() {
    textToType := SanitizeText(A_Clipboard)
    if (textToType = "") {
        return
    }

    SetTimer(TypeText.Bind(textToType), -1000)
}

SanitizeText(text) {
    text := RegExReplace(text, "\n", " ")
    text := RegExReplace(text, "\r", " ")
    text := RegExReplace(text, "\t", " ")
    text := RegExReplace(text, "\s+", " ")
    text := RegExReplace(text, "!", "")
    return text
}

TypeText(text) {
    ToolTip()
    Send(text)
}

OpenDiscord() {
    if WinExist("ahk_exe discord.exe") {
        WinActivate("ahk_exe discord.exe")
    } else {
        Run("C:\Users\markj\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk")
        WinWait("ahk_exe discord.exe")
    }
}

SetTimer(WarningOnVPNActive, 1000)

#HotIf ShouldSwapKeys() && !typingMode
Backspace::Space
Delete::Enter
#HotIf

#HotIf ShouldSwapKeys() || ShouldSwapKeysForQWERTY()
~Space:: {
    ResetTypingModeTimer()
}
~*f:: ResetTypingModeTimer()
~*g:: ResetTypingModeTimer()
~*c:: ResetTypingModeTimer()
~*r:: ResetTypingModeTimer()
~*l:: ResetTypingModeTimer()
~*d:: ResetTypingModeTimer()
~*h:: ResetTypingModeTimer()
~*t:: ResetTypingModeTimer()
~*n:: ResetTypingModeTimer()
~*s:: ResetTypingModeTimer()
~*b:: ResetTypingModeTimer()
~*m:: ResetTypingModeTimer()
~*w:: ResetTypingModeTimer()
~*v:: ResetTypingModeTimer()
~*z:: ResetTypingModeTimer()
#HotIf

#HotIf ShouldSwapKeysForQWERTY() && !typingMode
Backspace::Space
Delete::Enter

*SC027::t ; semicolon key
*o::a
*e::w
*u::d
*j::s
*i::f
*,::z
*.::x
*p::c
*y::v
*a::LShift
*SC028::m ; apostrophe key
*k::e
*x::r
*Left::g
*Right::b
#HotIf

#HotIf typingMode
~*a:: ResetTypingModeTimer()
~*b:: ResetTypingModeTimer()
~*c:: ResetTypingModeTimer()
~*d:: ResetTypingModeTimer()
~*e:: ResetTypingModeTimer()
~*f:: ResetTypingModeTimer()
~*g:: ResetTypingModeTimer()
~*h:: ResetTypingModeTimer()
~*i:: ResetTypingModeTimer()
~*j:: ResetTypingModeTimer()
~*k:: ResetTypingModeTimer()
~*l:: ResetTypingModeTimer()
~*m:: ResetTypingModeTimer()
~*n:: ResetTypingModeTimer()
~*o:: ResetTypingModeTimer()
~*p:: ResetTypingModeTimer()
~*q:: ResetTypingModeTimer()
~*r:: ResetTypingModeTimer()
~*s:: ResetTypingModeTimer()
~*t:: ResetTypingModeTimer()
~*u:: ResetTypingModeTimer()
~*v:: ResetTypingModeTimer()
~*w:: ResetTypingModeTimer()
~*x:: ResetTypingModeTimer()
~*y:: ResetTypingModeTimer()
~*z:: ResetTypingModeTimer()
~*0:: ResetTypingModeTimer()
~*1:: ResetTypingModeTimer()
~*2:: ResetTypingModeTimer()
~*3:: ResetTypingModeTimer()
~*4:: ResetTypingModeTimer()
~*5:: ResetTypingModeTimer()
~*6:: ResetTypingModeTimer()
~*7:: ResetTypingModeTimer()
~*8:: ResetTypingModeTimer()
~*9:: ResetTypingModeTimer()
~*,:: ResetTypingModeTimer()
~*.:: ResetTypingModeTimer()
~*;:: ResetTypingModeTimer()
~*':: ResetTypingModeTimer()
~*Left:: ResetTypingModeTimer()
~*Right:: ResetTypingModeTimer()
~*Up:: ResetTypingModeTimer()
~*Down:: ResetTypingModeTimer()
~*Backspace:: ResetTypingModeTimer()
~*Delete:: ResetTypingModeTimer()
~*Enter:: ResetTypingModeTimer()
~*Tab:: ResetTypingModeTimer()
~*LShift:: ResetTypingModeTimer()
~*RShift:: ResetTypingModeTimer()
~*LCtrl:: ResetTypingModeTimer()
~*RCtrl:: ResetTypingModeTimer()
~*LAlt:: ResetTypingModeTimer()
~*RAlt:: ResetTypingModeTimer()
~*Space:: ResetTypingModeTimer()
#HotIf

^+!g:: ToggleKeySwaps()
^+!q:: ToggleQWERTY()
^+!r:: Reload()
^+!y:: CopyExeNameToClipboardAndOpenFile()
^+!v:: CheckVpnStatus()
^+!i:: TypeOutSanitizedTextInClipboard()
