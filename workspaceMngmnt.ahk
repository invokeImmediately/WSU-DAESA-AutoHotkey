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
	SoundPlay, %windowMovementSound%
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

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Right::
	SoundPlay, %windowMovementSound%
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

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Down::
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
