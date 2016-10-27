; ============================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

OpenChromeTab:
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "chrome.exe") {
        SendInput ^n
        Sleep 250
        isReady := false
        while !isReady
        {
            IfWinExist, % "New Tab"
            {
                isReady := true
                Sleep, 500
            }
            else
            {
                Sleep, 250
            }
        }
    }
return

IsWindowOnLeftDualMonitor() {
    WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
    
    if (thisWinX < -8) {
        return true
    }
    else {
        return false
    }
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F10::WinSet, Alwaysontop, Toggle, A

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F1::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F2::
    SendInput, #{Tab}
    Sleep, 330
    SendInput, {Tab}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F3::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F4::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F5::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Right}{Enter}
Return

^!F6::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Right}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F9::
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 100
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , 100, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F8::
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 100
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , 0, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F7::
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 100
    M1X := -M1Width
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , %M1X%, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F6::
    SysGet, Mon1, MonitorWorkArea, 1
    M1X := -(Mon1Right - Mon1Left)
    M1Width := Mon1Right - Mon1Left - 100
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , %M1X%, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Left::
    if (IsWindowOnLeftDualMonitor()) {
        SysGet, Mon2, MonitorWorkArea, 2
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		thisWinH := Mon2Bottom - Mon2Top
		if (thisWinX = Mon2Left and thisWinW > (Mon2Right - Mon2Left) / 4) {
			WinMove, A, , %Mon2Left%, 0, % (thisWinW - 100), %thisWinH%        
		}
		else if (thisWinW > (Mon2Right - Mon2Left) / 4) {
			WinMove, A, , %Mon2Left%, 0, %thisWinW%, %thisWinH%        
		}
		else {
			thisWinW := Mon2Right - Mon2Left - 100
			WinMove, A, , %Mon2Left%, 0, %thisWinW%, %thisWinH%        
		}
    }
    else {
        SysGet, Mon1, MonitorWorkArea, 1
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		thisWinH := Mon1Bottom - Mon1Top
		if (thisWinX = Mon1Left and thisWinW > (Mon1Right - Mon1Left) / 4) {
			WinMove, A, , %Mon1Left%, 0, % (thisWinW - 100), %thisWinH%			
		}
		else if (thisWinW > (Mon1Right - Mon1Left) / 4) {
			WinMove, A, , %Mon1Left%, 0, %thisWinW%, %thisWinH%			
		}
		else {
			thisWinW := Mon1Right - Mon1Left - 100
			WinMove, A, , %Mon1Left%, 0, %thisWinW%, %thisWinH%
		}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Right::
    if (IsWindowOnLeftDualMonitor()) {
        SysGet, Mon2, MonitorWorkArea, 2
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinX := Mon2Right - thisWinW
		thisWinH := Mon2Bottom - Mon2Top
		if (thisWinX = newWinX and thisWinW > (Mon2Right - Mon2Left) / 4) {
			newWinX := newWinX + 100
			WinMove, A, , %newWinX%, 0, % (thisWinW - 100), %thisWinH%
		}
		else if (thisWinW > (Mon2Right - Mon2Left) / 4) {
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%
		}
		else {
			thisWinW := Mon2Right - Mon2Left - 100
			newWinX := Mon2Left + 100
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%
		}
    }
    else {
        SysGet, Mon1, MonitorWorkArea, 1
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinX := Mon1Right - thisWinW
		thisWinH := Mon1Bottom - Mon1Top
		if (thisWinX = newWinX and thisWinW > (Mon1Right - Mon1Left) / 4) {
			newWinX := newWinX + 100
			WinMove, A, , %newWinX%, 0, % (thisWinW - 100), %thisWinH%
		}
		else if (thisWinW > (Mon1Right - Mon1Left) / 4) {
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%
		}
		else {
			thisWinW := Mon1Right - Mon1Left - 100
			newWinX := Mon1Left + 100
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%
		}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Down::
    if (IsWindowOnLeftDualMonitor()) {
        SysGet, Mon2, MonitorWorkArea, 2
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinY := Mon2Bottom - thisWinH
		newWinW := Mon2Right - Mon2Left
		if (thisWinY = newWinY and thisWinH > (Mon2Bottom - Mon2Top) / 4) {
			newWinY := newWinY + 100
			WinMove, A, , %Mon2Left%, %newWinY%, %newWinW%, % (thisWinH - 100)
		}
		else if (thisWinH > (Mon2Bottom - Mon2Top) / 4) {
			WinMove, A, , %Mon2Left%, %newWinY%, %newWinW%, %thisWinH%
		}
		else {
			thisWinH := Mon2Bottom - Mon2Top - 100
			newWinY := 100
			WinMove, A, , %Mon2Left%, %newWinY%, %newWinW%, %thisWinH%
		}
    }
    else {
        SysGet, Mon1, MonitorWorkArea, 1
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinY := Mon1Bottom - thisWinH
		newWinW := Mon1Right - Mon1Left
		if (thisWinY = newWinY and thisWinH > (Mon1Bottom - Mon1Top) / 4) {
			newWinY := newWinY + 100
			WinMove, A, , %Mon1Left%, 0, %newWinW%, % (thisWinH - 100)
		}
		else if (thisWinH > (Mon1Bottom - Mon1Top) / 4) {
			WinMove, A, , %Mon1Left%, 0, %newWinW%, %thisWinH%
		}
		else {
			thisWinH := Mon1Right - Mon1Left - 100
			newWinY := 100
			WinMove, A, , %Mon1Left%, 0, %newWinW%, %thisWinH%
		}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Numpad5::
    if (IsWindowOnLeftDualMonitor()) {
        SysGet, Mon2, MonitorWorkArea, 2
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		newWinX := (Mon2Right - Mon2Left) / 2 - thisWinW / 2 + Mon2Left
		newWinY := (Mon2Bottom - Mon2Top) / 2 - thisWinH / 2 + Mon2Top
		WinMove, A, , %newWinX%, %newWinY%, %thisWinW%, %thisWinH%
    }
    else {
        SysGet, Mon1, MonitorWorkArea, 1
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		newWinX := (Mon1Right - Mon1Left) / 2 - thisWinW / 2 + Mon1Left
		newWinY := (Mon1Bottom - Mon1Top) / 2 - thisWinH / 2 + Mon1Top
		WinMove, A, , %newWinX%, %newWinY%, %thisWinW%, %thisWinH%
    }	
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!1::
    hotstrStartTime := A_TickCount
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    hotstrEndTime := A_TickCount
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!2::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!3::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down 2}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down 2}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!4::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down 3}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down 3}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!5::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down 4}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down 4}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!m::
    WinGetPos, thisX, thisY, thisW, thisH, A
    thisX := -thisX - thisW
    WinMove, A, , %thisX%, %thisY%, %thisW%, %thisH%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
:*:@toggleGimp::
	CheckForCmdEntryGui()
	WinGet, thisHwnd, ID, A
	SetTitleMatchMode, 2
	WinActivate, % "GIMP ahk_exe gimp-2.8.exe"
	WinWaitActive, % "GIMP ahk_exe gimp-2.8.exe", , 0.25
	if (ErrorLevel) {
		WinActivate, % "GNU Image Manipulation Program ahk_exe gimp-2.8.exe"
		WinWaitActive, % "GNU Image Manipulation Program ahk_exe gimp-2.8.exe", , 0.25
		if (!ErrorLevel) {
			SendInput, {Tab}
		}
	}
	else {
		SendInput, {Tab}
	}
	WinActivate, % "ahk_id" . thisHwnd
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

;TODO: Implement this for Skype muting regardless of what application is currently active.

;^m::
;    WinGet, thisProcessID, ID, A
;	IfWinExist,
;    WinGetPos, thisX, thisY, thisW, thisH, A
;    thisX := -thisX - thisW
;    WinMove, A, , %thisX%, %thisY%, %thisW%, %thisH%
;Return

PeformBypassingCtrlM:
    Suspend
    Sleep 10
    SendInput ^m
    Sleep 10
    Suspend, Off
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

DoChangeDelimiter(leftDelimiter, rightDelimeter) {
	CoordMode, Mouse, Client
	Click, 311, -9
	Sleep 60
	Click, 179, 11
	Sleep 100
	Click, 35, 181
	Sleep 60
	Click, 391, 125, 2
	SendInput, %leftDelimiter%
	Sleep 60
	Click, 547, 157, 2
	SendInput, %rightDelimeter%
	Sleep 60
	Click, 417, 335
}

^!+'::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("""", """")
	}
Return

^!+9::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("(", ")")
	}
Return

^!+[::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("{{}", "{}}")
	}
Return

^![::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("[", "]")
	}
Return
