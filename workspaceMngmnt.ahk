; ==================================================================================================
; WORKSPACE MANAGEMENT SCRIPTS
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
; DEPENDENCIES
; --------------------------------------------------------------------------------------------------

#include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\desktopStartup.ahk

; --------------------------------------------------------------------------------------------------
; FUNCTIONS & SUBROUTINES
; --------------------------------------------------------------------------------------------------

IsWindowOnLeftDualMonitor() {
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	
	if (thisWinX < -8) {
		return true
	}
	else {
		return false
	}
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; --------------------------------------------------------------------------------------------------
;   WINDOW POSITIONING HOTKEYS
; --------------------------------------------------------------------------------------------------

^F10::WinSet, Alwaysontop, Toggle, A

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!F1::
	SwitchDesktopByNumber(1)
	SoundPlay, %desktopSwitchingSound%
Return

^!F2::
	SwitchDesktopByNumber(2)
	SoundPlay, %desktopSwitchingSound%
Return

^!F3::
	SwitchDesktopByNumber(3)
	SoundPlay, %desktopSwitchingSound%
Return

^!F4::
	SwitchDesktopByNumber(4)
	SoundPlay, %desktopSwitchingSound%
Return

^!F5::
	SwitchDesktopByNumber(5)
	SoundPlay, %desktopSwitchingSound%
Return

^!F6::
	SwitchDesktopByNumber(6)
;	SendInput #{Tab}
;	Sleep 330
;	SendInput {Tab}{Right}{Right}{Right}{Right}{Right}{Enter}
	SoundPlay, %desktopSwitchingSound%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^F9::
	SoundPlay, %windowSizingSound%
	SysGet, Mon1, MonitorWorkArea, 1
	maxWidth := Mon1Right - Mon1Left 
	newWidth := maxWidth - 200
	maxHeight := Mon1Bottom - Mon1Top 
	WinRestore, A
	WinMove, A, , 200, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(2, 320, maxWidth, newWidth, 180, maxHeight, maxHeight)
Return

^F8::
	SoundPlay, %windowSizingSound%
	SysGet, Mon1, MonitorWorkArea, 1
	maxWidth := Mon1Right - Mon1Left 
	newWidth := maxWidth - 200
	maxHeight := Mon1Bottom - Mon1Top
	WinRestore, A
	WinMove, A, , 0, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(1, 320, maxWidth, newWidth, 180, maxHeight, maxHeight)
Return

^F7::
	SoundPlay, %windowSizingSound%
	SysGet, Mon1, MonitorWorkArea, 1
	maxWidth := Mon1Right - Mon1Left
	newWidth := maxWidth - 200
	newPosX := -newWidth
	maxHeight := Mon1Bottom - Mon1Top
	WinRestore, A
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(2, 320, maxWidth, newWidth, 180, maxHeight, maxHeight)
Return

^F6::
	SoundPlay, %windowSizingSound%
	SysGet, Mon1, MonitorWorkArea, 1
	maxWidth := Mon1Right - Mon1Left
	newWidth := maxWidth - 200
	newPosX := -maxWidth
	maxHeight := Mon1Bottom - Mon1Top
	WinRestore, A
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(1, 320, maxWidth, newWidth, 180, maxHeight, maxHeight)
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

; Edge snapping values & meaning:
;   0b000001 = snap left
;   0b000010 = snap right
;   0b000100 = snap horizontal center
;   0b001000 = snap top
;   0b010000 = snap bottom
;   0b000100 = snap vertical center
; For mixed values, effects are triggered from top to bottom as listed above; thus, if left and 
; right snapping bits are both set to true, left snapping will override right snapping.
TriggerWindowAdjustmentGui(edgeSnapping, minWidth, maxWidth, initialWidth, minHeight, maxHeight
		, initialHeight) {
	global
	local whichHwnd
	local onLeftMonitor := IsWindowOnLeftDualMonitor()
	local sliderPos := (initialWidth - minWidth) / (maxWidth - minWidth) * 100

	WinGet, whichHwnd, ID, A
	guiWindowAdjustVars := Object()
	guiWindowAdjustVars.whichHwnd := whichHwnd
	guiWindowAdjustVars.minWidth := minWidth
	guiWindowAdjustVars.maxWidth := maxWidth
	guiWindowAdjustVars.minHeight := minHeight
	guiWindowAdjustVars.maxHeight := maxHeight
	guiWindowAdjustVars.edgeSnapping := edgeSnapping
	
	Gui, guiWindowAdjust: New,
		, % "Adjust Active Window Width"
	Gui, guiWindowAdjust: Add, Text, , Window width:
	Gui, guiWindowAdjust: Add, Slider
		, vguiWindowAdjustWidthSlider gHandleGuiWindowAdjustWidthSliderChange AltSubmit W300 X+5
		, %sliderPos%
	Gui, guiWindowAdjust: Add, Button, Default gHandleGuiWindowAdjustOK, &OK
	Gui, guiWindowAdjust: Show
	if (onLeftMonitor) {
		SysGet, Mon2, MonitorWorkArea, 2
		WinGet, guiHwnd, ID, A
		WinGetPos, posX, posY, posW, posH, ahk_id %guiHwnd%
		posX := Mon2Left + posX
		WinMove, ahk_id %guiHwnd%, , %posX%, %posY%, %posW%, %posH%
	}
}

HandleGuiWindowAdjustWidthSliderChange() {
	global guiWindowAdjustVars
	global guiWindowAdjustWidthSlider

	; Add test to ensure window still exists.
	Gui, guiWindowAdjust: Submit, NoHide
	whichHwnd := guiWindowAdjustVars.whichHwnd
	WinGetPos, posX, posY, posW, posH, ahk_id %whichHwnd%
	newWidth := guiWindowAdjustVars.minWidth + (guiWindowAdjustVars.maxWidth 
		- guiWindowAdjustVars.minWidth) * (guiWindowAdjustWidthSlider / 100)
	if (guiWindowAdjustVars.edgeSnapping & 1) {
		WinMove, ahk_id %whichHwnd%, , %posX%, %posY%, %newWidth%, %posH%
	} else if (guiWindowAdjustVars.edgeSnapping & (1 << 1)) {
		posXNew := posX - (newWidth - posW)
		WinMove, ahk_id %whichHwnd%, , %posXNew%, %posY%, %newWidth%, %posH%
	}
}

HandleguiWindowAdjustOK() {
	Gui, guiWindowAdjust: Destroy
}

guiWindowAdjustGuiEscape() {
	Gui, guiWindowAdjust: Destroy
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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
		WinRestore, A
		WinMove, A, , %newWinX%, %newWinY%, % (Mon2Right - Mon2Left - 200), % (Mon2Bottom 
			- Mon2Top - 112)
	}
	else {
		SysGet, Mon1, MonitorWorkArea, 1
		WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		newWinX := (Mon1Right - Mon1Left) / 2 - (Mon1Right - Mon1Left - 200) / 2 + Mon1Left
		newWinY := (Mon1Bottom - Mon1Top) / 2 - (Mon1Bottom - Mon1Top - 112) / 2 + Mon1Top
		WinRestore, A
		WinMove, A, , %newWinX%, %newWinY%, % (Mon1Right - Mon1Left - 200), % (Mon1Bottom 
			- Mon1Top - 112)
	}	
return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

; TODO: Add hotkeys for moving the window around on the desktop using the keyboard instead of 
; dragging with mouse

; --------------------------------------------------------------------------------------------------
;   VIRTUAL DESKTOP HOTKEYS
; --------------------------------------------------------------------------------------------------

^!1::
	MoveActiveWindowToVirtualDesktop(1)
	SoundPlay, %windowShiftingSound%
return

^!2::
	MoveActiveWindowToVirtualDesktop(2)
	SoundPlay, %windowShiftingSound%
return

^!3::
	MoveActiveWindowToVirtualDesktop(3)
	SoundPlay, %windowShiftingSound%
return

^!4::
	MoveActiveWindowToVirtualDesktop(4)
	SoundPlay, %windowShiftingSound%
return

^!5::
	MoveActiveWindowToVirtualDesktop(5)
	; if (IsWindowOnLeftDualMonitor()) {
		; SendInput, #{Tab}
		; Sleep, 400
		; SendInput, {Tab 2}{AppsKey}{m}{Down 4}{Enter}
		; Sleep, 120
		; SendInput, #{Tab}
	; }
	; else {
		; SendInput, #{Tab}
		; Sleep, 400
		; SendInput, {AppsKey}{m}{Down 4}{Enter}
		; Sleep, 120
		; SendInput, #{Tab}
	; }
	SoundPlay, %windowShiftingSound%
return

^!6::
	MoveActiveWindowToVirtualDesktop(6)
	SoundPlay, %windowShiftingSound%
Return

; --------------------------------------------------------------------------------------------------
;   AUDITORY CUE BINDING
; --------------------------------------------------------------------------------------------------


^!m::
	WinGetPos, thisX, thisY, thisW, thisH, A
	thisX := -thisX - thisW
	WinMove, A, , %thisX%, %thisY%, %thisW%, %thisH%
	SoundPlay, %windowMovementSound%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~^#Left::
	SoundPlay, %desktopSwitchingSound%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~+#Left::
	SoundPlay, %windowMovementSound%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~^#Right::
	SoundPlay, %desktopSwitchingSound%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~+#Right::
	SoundPlay, %windowMovementSound%
Return

; --------------------------------------------------------------------------------------------------
;   MOUSE HOTKEYS
; --------------------------------------------------------------------------------------------------

;TODO: Convert these functions into an array based format
^!+RButton::
	global savedMouseX
	global savedMouseY
	
	CoordMode, Mouse, Screen
	MouseGetPos, savedMouseX, savedMouseY
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!+LButton::
	global savedMouseX
	global savedMouseY

	CoordMode, Mouse, Screen
	MouseMove, %savedMouseX%, %savedMouseY%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!#LButton::
	CoordMode, Mouse, Screen
	MouseMove, -1568, 1065
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!#RButton::
	CoordMode, Mouse, Screen
	MouseMove, 351, 1065
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

#LButton::
	CoordMode, Mouse, Window
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	Sleep 20
	MouseMove, % (thisWinW / 2), % (thisWinH / 2)
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^#LButton::
!SC029::
	CoordMode, Mouse, Window
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	Sleep 20
	MouseMove, % (thisWinW / 7), % (thisWinH / 2)
Return

; --------------------------------------------------------------------------------------------------
;   APP SPECIFIC WORKSPACE MANAGEMENT SCRIPTS
; --------------------------------------------------------------------------------------------------

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
; >>> GNU IMAGE MANIPULATION PROGRAM: PHOTO EDITING & GRAPHIC DESIGN ENHANCEMENT HOTKEYS & SCRIPTS

:*:@toggleGimp::
	CheckForCmdEntryGui()
	WinGet, thisHwnd, ID, A
	SetTitleMatchMode, 2
	WinActivate, % "GIMP ahk_class gdkWindowToplevel"
	WinWaitActive, % "GIMP ahk_class gdkWindowToplevel", , 0.25
	if (ErrorLevel) {
		WinActivate, % "GNU Image ahk_class gdkWindowToplevel"
		WinWaitActive, % "GNU Image ahk_class gdkWindowToplevel", , 0.25
		if (!ErrorLevel) {
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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
; >>> NOTEPAD++: TEXT EDITING ENHANCEMENT HOTKEYS & SCRIPTS

DoChangeDelimiter(leftDelimiter, rightDelimeter) {
	Sleep 20
	Click, 311, -9
	Sleep 400
	Click, 179, 11
	Sleep 200
	Click, 35, 178
	Sleep 200
	Click, 389, 225, 2
	Sleep 100
	SendInput, %leftDelimiter%
	Sleep 200
	;Click, 501, 225, 2
	Click, 546, 255, 2 ; When allowed on several lines
	Sleep 100
	SendInput, %rightDelimeter%
	Sleep 200
	Click, 417, 335
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!+'::
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("""", """")
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!+9::
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("(", ")")
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!+[::
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("{{}", "{}}")
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^![::
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		DoChangeDelimiter("[", "]")
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
; >>> STICKY NOTES FOR CHROME

:*:@initStickyNoteToggle::
	global hwndStickyNoteWindow
	ahkCmdName := ":*:@initStickyNoteToggle"
	AppendAhkCmd(ahkCmdName)
	WinGet, hwndStickyNoteWindow, ID, A
	MsgBox, 0, % ":*:@initStickyNoteSwitcher", % "Sticky note window with HWND " 
		. hwndStickyNoteWindow . " can now be toggled via the hotstring @toggleStickyNote."
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@toggleStickyNote::
	global hwndStickyNoteWindow
	global hwndActiveBeforeStickyNote
	ahkCmdName := ":*:@toggleStickyNote"
	AppendAhkCmd(ahkCmdName)
	if (hwndStickyNoteWindow != undefined) {
		WinGet, thisHwnd, ID, A
		if (thisHwnd = hwndStickyNoteWindow) {
			if (hwndActiveBeforeStickyNote != undefined) {
				WinActivate, % "ahk_id " . hwndActiveBeforeStickyNote
			} else {
				ErrorBox(ahkCmdName, "Unable to switch away from Sticky Notes for Chrome because "
					. "the app that was previously active is unknown.")
			}
		} else {
			WinGet, hwndActiveBeforeStickyNote, ID, A
			WinActivate, % "ahk_id " . hwndStickyNoteWindow
		}
	} else {
		ErrorBox(ahkCmdName, "A sticky note window has not yet been initialized via "
			. "@initStickyNoteSwitcher for use with this hotstring.")
	}
Return
