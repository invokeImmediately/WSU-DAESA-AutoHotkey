; ============================================================================================================
; WORKSPACE MANAGEMENT SCRIPTS
; ============================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

; ------------------------------------------------------------------------------------------------------------
; DEPENDENCIES
; ------------------------------------------------------------------------------------------------------------
#include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\desktopStartup.ahk

; ------------------------------------------------------------------------------------------------------------
; FUNCTIONS
; ------------------------------------------------------------------------------------------------------------

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

; ------------------------------------------------------------------------------------------------------------
; HOTKEYS
; ------------------------------------------------------------------------------------------------------------

^F10::WinSet, Alwaysontop, Toggle, A

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F1::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Enter}
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F2::
    SendInput, #{Tab}
    Sleep, 330
    SendInput, {Tab}{Right}{Enter}
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F3::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Enter}
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F4::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Enter}
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F5::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Right}{Enter}
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F6::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Right}{Right}{Enter}
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F9::
	SoundPlay, %windowSizingSound%
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 200
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , 200, 0, %M1Width%, %M1Height%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F8::
	SoundPlay, %windowSizingSound%
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 200
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , 0, 0, %M1Width%, %M1Height%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F7::
	SoundPlay, %windowSizingSound%
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 200
    M1X := -M1Width
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , %M1X%, 0, %M1Width%, %M1Height%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F6::
	SoundPlay, %windowSizingSound%
    SysGet, Mon1, MonitorWorkArea, 1
    M1X := -(Mon1Right - Mon1Left)
    M1Width := Mon1Right - Mon1Left - 200
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , %M1X%, 0, %M1Width%, %M1Height%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Left::
	;Snap the active window to the left edge of its monitor; if already snapped, reduce its width
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		thisWinH := monitorABottom - monitorATop
		if (thisWinX = monitorALeft and thisWinW > (monitorARight - monitorALeft) / 4) {
			WinMove, A, , %monitorALeft%, 0, % (thisWinW - 100), %thisWinH%        
		} else if (thisWinW > (monitorARight - monitorALeft) / 4) {
			WinMove, A, , %monitorALeft%, 0, %thisWinW%, %thisWinH%        
		} else {
			thisWinW := monitorARight - monitorALeft - 100
			WinMove, A, , %monitorALeft%, 0, %thisWinW%, %thisWinH%        
		}
	}
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!+#Left::
	;Snap the active window to the left edge of its monitor; if already snapped, increase its width
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		thisWinH := monitorABottom - monitorATop
		if (thisWinX = monitorALeft and thisWinW < (monitorARight - monitorALeft - 100)) {
			WinMove, A, , %monitorALeft%, 0, % (thisWinW + 100), %thisWinH%        
		} else if (thisWinW < (monitorARight - monitorALeft - 100)) {
			WinMove, A, , %monitorALeft%, 0, %thisWinW%, %thisWinH%        
		} else {
			thisWinW := (monitorARight - monitorALeft) / 4
			WinMove, A, , %monitorALeft%, 0, %thisWinW%, %thisWinH%        
		}
	}
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Right::
	;Snap the active window to the right edge of its monitor; if already snapped, reduce its width
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinX := monitorARight - thisWinW
		thisWinH := monitorABottom - monitorATop
		if (thisWinX = newWinX and thisWinW > (monitorARight - monitorALeft) / 4) {
			newWinX += 100
			thisWinW -= 100
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%        
		} else if (thisWinW > (monitorARight - monitorALeft) / 4) {
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%        
		} else {
			thisWinW := monitorARight - monitorALeft - 100
			newWinX := monitorALeft + 100
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%        
		}
	}
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!+#Right::
	;Snap the active window to the right edge of its monitor; if already snapped, increase its width
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinX := monitorARight - thisWinW
		thisWinH := monitorABottom - monitorATop
		if (thisWinX = newWinX and thisWinW < (monitorARight - monitorALeft - 100)) {
			newWinX -= 100
			thisWinW += 100
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%        
		} else if (thisWinW < (monitorARight - monitorALeft - 100)) {
			newWinX := monitorARight - thisWinW
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%
		} else {
			thisWinW := (monitorARight - monitorALeft) / 4
			newWinX := monitorARight - thisWinW
			WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%        
		}
	}
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Down::
	;TODO: Refactor to rely on global variables that store monitor dimensions
	SoundPlay, %windowMovementSound%
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

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Numpad5::
	;Snap the center of the active window to the center of its monitor
	;TODO: Refactor to rely on global variables that store monitor dimensions
	;TODO: Expand to reduce window dimensions if already snapped
	;TODO: Add a hotkey variant that increases the window dimensions if already snapped
	SoundPlay, %windowMovementSound%
    if (IsWindowOnLeftDualMonitor()) {
        SysGet, Mon2, MonitorWorkArea, 2
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		; if (thisWinW < ) 50 vs. 28.125
		newWinX := (Mon2Right - Mon2Left) / 2 - (Mon2Right - Mon2Left - 200) / 2 + Mon2Left
		newWinY := (Mon2Bottom - Mon2Top) / 2 - (Mon2Bottom - Mon2Top - 112) / 2 + Mon2Top
		WinMove, A, , %newWinX%, %newWinY%, % (Mon2Right - Mon2Left - 200), % (Mon2Bottom - Mon2Top - 112)
    }
    else {
        SysGet, Mon1, MonitorWorkArea, 1
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		newWinX := (Mon1Right - Mon1Left) / 2 - (Mon1Right - Mon1Left - 200) / 2 + Mon1Left
		newWinY := (Mon1Bottom - Mon1Top) / 2 - (Mon1Bottom - Mon1Top - 112) / 2 + Mon1Top
		WinMove, A, , %newWinX%, %newWinY%, % (Mon1Right - Mon1Left - 200), % (Mon1Bottom - Mon1Top - 112)
    }	
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

;TODO: Add hotkeys for moving the window around on the desktop using the keyboard instead of dragging with mouse

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!1::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {Tab 2}{AppsKey}{m}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {AppsKey}{m}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
	SoundPlay, %windowShiftingSound%
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!2::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {Tab 2}{AppsKey}{m}{Down}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {AppsKey}{m}{Down}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
	SoundPlay, %windowShiftingSound%
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!3::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {Tab 2}{AppsKey}{m}{Down 2}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {AppsKey}{m}{Down 2}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
	SoundPlay, %windowShiftingSound%
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!4::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {Tab 2}{AppsKey}{m}{Down 3}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {AppsKey}{m}{Down 3}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
	SoundPlay, %windowShiftingSound%
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!5::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {Tab 2}{AppsKey}{m}{Down 4}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 400
        SendInput, {AppsKey}{m}{Down 4}{Enter}
        Sleep, 120
        SendInput, #{Tab}
    }
	SoundPlay, %windowShiftingSound%
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!m::
    WinGetPos, thisX, thisY, thisW, thisH, A
    thisX := -thisX - thisW
    WinMove, A, , %thisX%, %thisY%, %thisW%, %thisH%
	SoundPlay, %windowMovementSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

~^#Left::
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

~+#Left::
	SoundPlay, %windowMovementSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

~^#Right::
	SoundPlay, %desktopSwitchingSound%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

~+#Right::
	SoundPlay, %windowMovementSound%
Return

; ------------------------------------------------------------------------------------------------------------
; GNU Image Manipulation Program: Photo Editing & Graphic Design Enhancement Hotkeys & Scripts
; ------------------------------------------------------------------------------------------------------------

:*:@toggleGimp::
	CheckForCmdEntryGui()
	WinGet, thisHwnd, ID, A
	SetTitleMatchMode, 2
	WinActivate, % "GIMP"
	WinWaitActive, % "GIMP", , 0.25
	if (ErrorLevel) {
		WinActivate, % "GNU Image Manipulation Program"
		WinWaitActive, % "GNU Image Manipulation Program", , 0.25
		if (!ErrorLevel) {
			;TODO: make sure we have found gimp-2.8.exe before proceeding
			SendInput, {Tab}
		} else {
			MsgBox, % "Could not find and activate GIMP."
		}
	} else {
		;TODO: make sure we have found gimp-2.8.exe before proceeding
		SendInput, {Tab}
	}
	WinActivate, % "ahk_id" . thisHwnd
return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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

; ------------------------------------------------------------------------------------------------------------
; Notepad++: Text Editing Enhancement Hotkeys & Scripts
; ------------------------------------------------------------------------------------------------------------

DoChangeDelimiter(leftDelimiter, rightDelimeter) {
	CoordMode, Mouse, Client
	Click, 311, -9
	Sleep 60
	Click, 179, 11
	Sleep 100
	Click, 35, 181
	Sleep 60
	Click, 395, 125, 2
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

>^t::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "notepad++.exe") {
		SendInput, % "{Esc}"
		Sleep, 10
		SendInput, % "^f"
		Sleep, 10
		SendInput, % "<"
		Sleep, 10
		SendInput, % "!x"
		Sleep, 10
		SendInput, % "!d"
		Sleep, 10
		SendInput, % "{Enter}"
		Sleep, 10
		SendInput, % "{Esc}"
		Sleep, 10
		SendInput, % "{Right}"
	}
Return

; ------------------------------------------------------------------------------------------------------------
; Mouse Hotkeys
; ------------------------------------------------------------------------------------------------------------

;TODO: Convert these functions into an array based format
^!+RButton::
	global savedMouseX
	global savedMouseY
	
	CoordMode, Mouse, Screen
	MouseGetPos, savedMouseX, savedMouseY
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!+LButton::
	global savedMouseX
	global savedMouseY

	CoordMode, Mouse, Screen
	MouseMove, %savedMouseX%, %savedMouseY%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#LButton::
	CoordMode, Mouse, Screen
	MouseMove, -1568, 1065
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#RButton::
	CoordMode, Mouse, Screen
	MouseMove, 351, 1065
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

#LButton::
	CoordMode, Mouse, Window
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	Sleep 20
	MouseMove, % (thisWinW / 2), % (thisWinH / 2)
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^#LButton::
!SC029::
	CoordMode, Mouse, Window
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	Sleep 20
	MouseMove, % (thisWinW / 7), % (thisWinH / 2)
Return
