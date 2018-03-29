; ==================================================================================================
; WORKSPACE MANAGEMENT SCRIPTS
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;    §1: DEPENDENCIES .........................................................................23
;    §2: FUNCTIONS & SUBROUTINES ..............................................................29
;    §3: WINDOW POSITIONING HOTKEYS ...........................................................89
;    §4: VIRTUAL DESKTOP HOTKEYS .............................................................644
;    §5: MOUSE HOTKEYS .......................................................................692
;    §6: AUDITORY CUE BINDING ................................................................748
;    §7: WINDOW POSITIONING GUIS .............................................................770
;    >>> §7.1: Window Adjustment GUI .........................................................774
;    §8: APP SPECIFIC WORKSPACE MANAGEMENT SCRIPTS ...........................................919
;    >>> §8.2: NOTEPAD++: TEXT EDITING ENHANCEMENT HOTKEYS & SCRIPTS .........................967
;    >>> §8.3: STICKY NOTES FOR CHROME ......................................................1049

; --------------------------------------------------------------------------------------------------
;   §1: DEPENDENCIES
; --------------------------------------------------------------------------------------------------

#include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\desktopStartup.ahk

; --------------------------------------------------------------------------------------------------
;   §2: FUNCTIONS & SUBROUTINES
; --------------------------------------------------------------------------------------------------

IsWindowOnLeftDualMonitor(title := "A") {
	global sysWinBorderW

	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, %title%
	SysGet, Mon2, Monitor, 2

	if (thisWinX < Mon2Right - sysWinBorderW) {
		return true
	} else {
		return false
	}
}

:*:@getInfoOnSystemMonitors::
	AppendAhkCmd(A_ThisLabel)	
	SysGet, numMonitors, MonitorCount
	msg := "The system has " . numMonitors . " installed."
	Loop, %numMonitors%
	{
		SysGet, iMon, Monitor, %A_Index%
		msg .= "`n`nInfo on monitor #" . A_Index . ":`nLeft = " . iMonLeft . ", Top = " . iMonTop
			. "`nRight = " . iMonRight . ", Bottom = " . iMonBottom
		SysGet, iMon, MonitorWorkArea, %A_Index%
		msg .= "`nWork Area:`nLeft = " . iMonLeft . ", Top = " . iMonTop
			. "`nRight = " . iMonRight . ", Bottom = " . iMonBottom
	}
	SysGet, xEdgeWidth, 32
	SysGet, yEdgeWidth, 33
	msg .= "`n`nResizeable window border widths:`nHorizontal = " . xEdgeWidth . ", Vertical: " 
		. yEdgeWidth
	MsgBox, % msg
Return

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
;   §3: WINDOW POSITIONING HOTKEYS
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

; TODO: Refactor to compensate for window border widths and how they affect positioning
^F9::
	SoundPlay, %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon1WorkArea_Right + (borderWidths.Horz - 1)) - (mon1WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - (widthDecrement * 4 / 3)
	newPosX := (widthDecrement * 4 / 3) - (borderWidths.Horz - 1)
	maxHeight := (mon1WorkArea_Bottom - mon1WorkArea_Top) + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinRestore, A
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(4, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

^F8::
	SoundPlay, %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon1WorkArea_Right + (borderWidths.Horz - 1)) - (mon1WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - widthDecrement * 4 / 3
	newPosX := -borderWidths.Horz + 1
	maxHeight := (mon1WorkArea_Bottom - mon1WorkArea_Top) + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinRestore, A
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(1, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

^F7::
	SoundPlay, %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon2WorkArea_Right + (borderWidths.Horz - 1)) - (mon2WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - (widthDecrement * 4 / 3)
	newPosX := -(maxWidth - widthDecrement * 4 / 3) + (borderWidths.Horz - 1)
	maxHeight := (mon2WorkArea_Bottom - mon2WorkArea_Top) + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinRestore, A
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(4, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

^F6::
	SoundPlay, %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon2WorkArea_Right + (borderWidths.Horz - 1)) - (mon2WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - widthDecrement * 4 / 3
	newPosX := -maxWidth + (borderWidths.Horz - 1)
	maxHeight := (mon2WorkArea_Bottom - mon2WorkArea_Top) + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinRestore, A
	WinMove, A, , %newPosX%, 0, %newWidth%, %newHeight%
	TriggerWindowAdjustmentGui(1, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!m::
	WinGetPos, thisX, thisY, thisW, thisH, A
	thisX := -thisX - thisW
	WinMove, A, , %thisX%, %thisY%, %thisW%, %thisH%
	SoundPlay, %windowMovementSound%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
; Snap the active window to the left edge of its monitor; if already snapped, reduce its width.
>^!#Left::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		widthDecrement := Round((monitorARight - monitorALeft) / 20)
		minWidth := Round((monitorARight - monitorALeft) / 20 * 3)
		maxWinX := monitorARight - monitorALeft
		maxWidth := maxWinX - widthDecrement
		DecrementWinDimension(winW, winX, monitorALeft, widthDecrement, minWidth, maxWidth, false
			, maxWinX)
		SafeWinMove("A", "", monitorALeft, winY, winW, winH)
	}
return

DecrementWinDimension(ByRef winDim, winPos, ByRef targetPos, decrement, minWinDim, maxWinDim
		, adjustPos, maxPos) {
	if (winPos = targetPos && winDim - decrement >= minWinDim) {
		winDim -= decrement
		if (adjustPos) {
			targetPos += decrement
		}
	} else if (winPos = targetPos && winDim - decrement < minWinDim) {
		winDim := maxWinDim
		if (adjustPos) {
			targetPos := maxPos - winDim
		}
	}
}

SafeWinMove(WinTitle, WinText, X, Y, Width, Height, ExcludeTitle := "", ExcludeText := "") {
	; TODO: Refactor this function for improved performance. Can use an hWnd array to check whether
	; the window behaves as expected.

	; Call WinMove twice such that: 1) The first call introduces a single pixel height change in
	; on top of the desired coordinates. 2) The second call cancels this one pixel height 
	; change out, resulting in the desired coordinates being set. This double call thus 
	; produces the effect of forcing the operating system to consider the window's height to 
	; be changing during the movement procedure, negating any edge snapping behavior that may 
	; produce unexpected changes in the final position of the window.
	; WinMove, % WinTitle, % WinText, % X, % Y, % Width, % Height - 1, % ExcludeTitle, % ExcludeText
	WinMove, % WinTitle, % WinText, % X, % Y, % Width, % Height, % ExcludeTitle, % ExcludeText
}

; Snap the active window to the left edge of its monitor; if already snapped, reduce its width. 
; Additionally, resize the window vertically to fill up the full vertical extent of the monitor's 
; available work area.
<^!#Left::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		widthDecrement := Round((monitorARight - monitorALeft) / 20)
		minWinWidth := Round((monitorARight - monitorALeft) / 20 * 3)
		maxWinX := monitorARight - monitorALeft
		maxWidth := maxWinX - widthDecrement
		heightChanged := UpdateVariableAsNeeded(winH, monitorABottom)
		if (!heightChanged) {
			DecrementWinDimension(winW, winX, monitorALeft, widthDecrement, minWidth, maxWidth
				, false, maxWinX)
		}
		SafeWinMove("A", "", monitorALeft, 0, winW, winH)
	}
return

UpdateVariableAsNeeded(ByRef variable, newValue) {
	if (variable != newValue) {
		variable := newValue
		varChanged := true
	} else {
		varChanged := false
	}
	return varChanged
}

; Snap the active window to the left edge of its monitor; if already snapped, increase its width.
>^!+#Left::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		widthIncrement := Round((monitorARight - monitorALeft) / 20)
		minWinWidth := Round((monitorARight - monitorALeft) / 20 * 3)
		maxWinWidth := monitorARight - monitorALeft - widthIncrement
		IncrementWinDimension(winW, winX, monitorALeft, widthDecrement, minWinWidth, maxWinWidth
			, false, maxWinWidth)
		SafeWinMove("A", "", monitorALeft, winY, winW, winH)
	}
return

IncrementWinDimension(ByRef winDim, winPos, ByRef targetPos, increment, minWinDim, maxWinDim
		, adjustPos, maxPos) {
	if (winPos = targetPos && winDim + increment <= maxWinDim) {
		winDim += increment
		if (adjustPos) {
			targetPos -= increment
		}
	} else if (winPos = targetPos && winDim + increment > maxWinDim) {
		winDim := minWinDim
		if (adjustPos) {
			targetPos := maxPos - winDim
		}
	}
}

; Snap the active window to the left edge of its monitor; if already snapped, increase its width. 
; Additionally, match the height of the window to the full height of the active monitor's work area.
<^!+#Left::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		widthIncrement := Round((monitorARight - monitorALeft) / 20)
		minWinWidth := Round((monitorARight - monitorALeft) / 20 * 3)
		maxWinX := monitorARight - monitorALeft
		maxWinWidth := maxWinX - widthIncrement
		heightChanged := UpdateVariableAsNeeded(winH, monitorABottom)
		if (!heightChanged) {
			IncrementWinDimension(winW, winX, monitorALeft, widthDecrement, minWinWidth
				, maxWinWidth, false, maxWinX)
		}
		SafeWinMove("A", "", monitorALeft, 0, winW, winH)
	}
return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

; Snap the active window to the right edge of its monitor; if already snapped, reduce its width.
>^!#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		monWith := monitorARight - monitorALeft
		widthDecrement := Round(monWith / 20)
		minWidth := Round(monWith / 20 * 3)
		maxWidth := monWidth - widthDecrement
		newWinX := monitorARight - winW
		DecrementWinDimension(winW, winX, newWinX, widthDecrement, minWidth, maxWidth, true
			, monitorARight)
		SafeWinMove("A", "", newWinX, winY, winW, winH)
	}
return

; Snap the active window to the right edge of its monitor; if already snapped, reduce its width.
; Additionally, resize the window vertically to fill up the full vertical extent of the monitor's 
; available work area.
<^!#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		monWidth := monitorARight - monitorALeft
		widthDecrement := Round(monWith / 20)
		minWidth := Round(monWith / 20 * 3)
		maxWidth := monWidth - widthDecrement
		newWinX := monitorARight - winW
		heightChanged := UpdateVariableAsNeeded(winH, monitorABottom)
		if (!heightChanged) {
			DecrementWinDimension(winW, winX, newWinX, widthDecrement, minWidth, maxWidth, true
				, monitorARight)			
		}
		SafeWinMove("A", "", newWinX, 0, winW, winH)
	}
return

; Snap the active window to the right edge of its monitor; if already snapped, increase its width.
>^!+#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		monWidth := monitorARight - monitorALeft
		widthIncrement := Round(monWidth / 20)
		minWidth := Round(monWidth / 20 * 3)
		maxWidth := monWidth - widthIncrement
		newWinX := monitorARight - winW
		IncrementWinDimension(winW, winX, newWinX, widthIncrement, minWidth, maxWidth, true
			, monitorARight)
		SafeWinMove("A", "", newWinX, winY, winW, winH)
	}
return

; Snap the active window to the right edge of its monitor; if already snapped, increase its width.
<^!+#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		monWidth := monitorARight - monitorALeft
		widthIncrement := Round(monWidth / 20)
		minWidth := Round(monWidth / 20 * 3)
		maxWidth := monWidth - widthIncrement
		newWinX := monitorARight - winW
		heightChanged := UpdateVariableAsNeeded(winH, monitorABottom)
		if (!heightChanged) {
			IncrementWinDimension(winW, winX, newWinX, widthIncrement, minWidth, maxWidth, true
				, monitorARight)
		}
		SafeWinMove("A", "", newWinX, 0, winW, winH)
	}
return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

>^!#Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		heightDecrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightDecrement
		newWinY := 0
		maxWinY := monitorABottom
		DecrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, false
			, maxWinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

<^!#Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		heightDecrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightDecrement
		newWinY := 0
		maxWinY := monitorABottom
		widthChanged := UpdateVariableAsNeeded(winW, monitorARight - monitorALeft)
		if (!widthChanged) {
			DecrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, false
				, maxWinY)
		}
		SafeWinMove("A", "", monitorALeft, newWinY, winW, winH)
	}
return

>^!+#Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		heightIncrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightIncrement
		newWinY := 0
		maxWinY := monitorABottom
		IncrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, false
			, maxWinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

<^!+#Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		heightIncrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightIncrement
		newWinY := 0
		maxWinY := monitorABottom
		widthChanged := UpdateVariableAsNeeded(winW, monitorARight - monitorALeft)
		if (!widthChanged) {
			IncrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, false
				, maxWinY)
		}
		SafeWinMove("A", "", monitorALeft, newWinY, winW, winH)
	}
return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

>^!#Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightDecrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightDecrement
		maxWinY := monitorABottom
		DecrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, true
			, maxwinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

<^!#Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightDecrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightDecrement
		maxWinY := monitorABottom
		widthChanged := UpdateVariableAsNeeded(winW, monitorARight - monitorALeft)
		if (!widthChanged) {
			DecrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, true
				, maxwinY)
		}
		SafeWinMove("A", "", monitorALeft, newWinY, winW, winH)
	}
return

>^!+#Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightIncrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightIncrement
		maxWinY := monitorABottom
		IncrementWinDimension(winH, winY, newWinY, heightIncrement, minHeight, maxHeight, true
			, maxWinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

<^!+#Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightIncrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - heightIncrement
		widthChanged := UpdateVariableAsNeeded(winW, monitorARight - monitorALeft)
		maxWinY := monitorABottom
		if (!widthChanged) {
			IncrementWinDimension(winH, winY, newWinY, heightIncrement, minHeight, maxHeight, true
				, maxWinY)
		}
		SafeWinMove("A", "", monitorALeft, newWinY, winW, winH)
	}
return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!#Numpad5::
	; Snap the center of the active window to the center of its monitor. Decrement its width & 
	; height up to minimum thresholds if already snapped, and wrap the width/height if minimum 
	; threshholds are exceeded.
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, aMonLeft, aMonTop, aMonRight, aMonBottom)
	if (monitorFound) {
		WinRestore, A
		WinGetPos, winX, winY, winW, winH, A
		aMonMidPtX := (aMonRight - aMonLeft) / 2
		aMonMidPtY := aMonBottom / 2
		dimChanged := false

		widthDecrement := Round((aMonRight - aMonLeft) / 20)
		minWinWidth := widthDecrement * 3
		maxWinWidth := aMonRight - aMonLeft - widthDecrement * 2
		if (winW > maxWinWidth) {
			winW := maxWinWidth
			dimChanged := true
		}
		newWinX := aMonMidPtX - winW / 2 + aMonLeft
		if (!dimChanged && winX + 1 > newWinX && winX - 1 < newWinX && winW 
				- widthDecrement >= minWinWidth) {
			winW -= widthDecrement
			newWinX += widthDecrement / 2
		} else if (!dimChanged && winX + 1 > newWinX && winX - 1 < newWinX  && winW 
				- widthDecrement < minWinWidth) {
			winW := maxWinWidth
			newWinX := aMonMidPtX - winW / 2
		}

		heightDecrement := Round(aMonBottom / 20)
		minWinHeight := heightDecrement * 3
		maxWinHeight := aMonBottom - heightDecrement * 2
		if (winH > maxWinHeight) {
			winH := maxWinHeight
			dimChanged := true
		}
		newWinY := aMonMidPtY - winH / 2
		if (!dimChanged && winY + 1 > newWinY && winY - 1 < newWinY && winH 
				- heightDecrement >= minWinHeight) {
			winH -= heightDecrement
			newWinY += heightDecrement / 2
		} else if (!dimChanged && winY + 1 > newWinY && winY - 1 < newWinY  && winH 
				- heightDecrement < minWinHeight) {
			winH := maxWinHeight
			newWinY := aMonMidPtY - winH / 2
		}

		SafeWinMove("A", "", newWinX, newWinY, winW, winH)
	}
return

^!#NumpadClear:: ; Equivalent to ^!+#Numpad5
	; Snap the center of the active window to the center of its monitor. Increment its width & 
	; height up to maximum thresholds if already snapped, and wrap the width/height if maximum 
	; thresholds are exceeded.
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, aMonLeft, aMonTop, aMonRight, aMonBottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		aMonMidPtX := (aMonRight - aMonLeft) / 2
		aMonMidPtY := aMonBottom / 2
		newWinX := aMonMidPtX - winW / 2 + aMonLeft
		newWinY := aMonMidPtY - winH / 2

		widthIncrement := Round((aMonRight - aMonLeft) / 20)
		minWinWidth := widthIncrement * 3
		maxWinWidth := aMonRight - aMonLeft - widthIncrement
		if (winX + 1 > newWinX && winX - 1 < newWinX && winW + widthIncrement <= maxWinWidth) {
			winW += widthIncrement
			newWinX -= widthIncrement / 2
		} else if (winX + 1 > newWinX && winX - 1 < newWinX  && winW 
				+ widthIncrement > maxWinWidth) {
			winW := minWinWidth
			newWinX := aMonMidPtX - winW / 2
		}

		heightIncrement := Round(aMonBottom / 20)
		minWinHeight := heightIncrement * 3
		maxWinHeight := aMonBottom - heightIncrement
		if (winY + 1 > newWinY && winY - 1 < newWinY && winH + heightIncrement <= maxWinHeight) {
			winH += heightIncrement
			newWinY -= heightIncrement / 2
		} else if (winY + 1 > newWinY && winY - 1 < newWinY  && winH 
				+ heightIncrement > maxWinHeight) {
			winH := minWinHeight
			newWinY := aMonMidPtY - winH / 2
		}

		SafeWinMove("A", "", newWinX, newWinY, winW, winH)
	}
return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

; TODO: Add hotkeys for moving the window around on the desktop using the keyboard instead of 
; dragging with mouse. Can use numpad for additional hotkeys.

; --------------------------------------------------------------------------------------------------
;   §4: VIRTUAL DESKTOP HOTKEYS
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
;   §5: MOUSE HOTKEYS
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
;   §6: AUDITORY CUE BINDING
; --------------------------------------------------------------------------------------------------

~^#Left::
	SoundPlay, %desktopSwitchingSound%
Return

~+#Left::
	SoundPlay, %windowMovementSound%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~^#Right::
	SoundPlay, %desktopSwitchingSound%
Return

~+#Right::
	SoundPlay, %windowMovementSound%
Return

; --------------------------------------------------------------------------------------------------
;   §7: WINDOW POSITIONING GUIS
; --------------------------------------------------------------------------------------------------

; ··································································································
;   >>> §7.1: Window Adjustment GUI
; Edge snapping values & meaning:
;   0b000001 = snap left
;   0b000010 = snap horizontal center
;   0b000100 = snap right
;   0b001000 = snap top
;   0b010000 = snap vertical center
;   0b000100 = snap bottom
; For mixed values, effects are triggered from top to bottom as listed above; thus, if left and 
; right snapping bits are both set to true, left snapping will override right snapping.
TriggerWindowAdjustmentGui(edgeSnapping, minWidth, maxWidth, initialWidth, minHeight, maxHeight
		, initialHeight) {
	global
	local whichHwnd
	local onLeftMonitor := IsWindowOnLeftDualMonitor()
	local sliderPos := (initialWidth - minWidth) / (maxWidth - minWidth) * 100
	local xSnapOptL
	local xSnapOptC
	local xSnapOptR
	local ySnapOptT
	local ySnapOptC
	local ySnapOptB

	; Store persistent data in GUI's associated global object
	WinGet, whichHwnd, ID, A
	guiWinAdjVars := Object()
	guiWinAdjVars.whichHwnd := whichHwnd
	guiWinAdjVars.minWidth := minWidth
	guiWinAdjVars.maxWidth := maxWidth
	guiWinAdjVars.minHeight := minHeight
	guiWinAdjVars.maxHeight := maxHeight
	guiWinAdjVars.edgeSnapping := edgeSnapping

	; Process edgeSnapping bitmask
	xSnapOptL := edgeSnapping & 1
	xSnapOptC := edgeSnapping & (1 << 1)
	xSnapOptR := edgeSnapping & (1 << 2)
	ySnapOptT := edgeSnapping & (1 << 3)
	ySnapOptC := edgeSnapping & (1 << 4)
	ySnapOptR := edgeSnapping & (1 << 5)

	; Setup GUI & display to user	
	Gui, guiWinAdj: New,
		, % "Adjust Active Window Width"
	Gui, guiWinAdj: Add, Text, , Window width:
	Gui, guiWinAdj: Add, Slider
		, vguiWinAdjWidthSlider gHandleGuiWinAdjWidthSliderChange AltSubmit W300 x+5
		, %sliderPos%
	Gui, guiWinAdj: Add, Text, xm, Horizontal snapping:
	Gui, guiWinAdj: Add, Radio, vguiWinAdjXSnapOpts x+5 Checked%xSnapOptL%, Left
	Gui, guiWinAdj: Add, Radio, x+5 Checked%xSnapOptC%, Center
	Gui, guiWinAdj: Add, Radio, x+5 Checked%xSnapOptR%, Right	
	Gui, guiWinAdj: Add, Button, Default gHandleGuiWinAdjOK xm y+15, &OK
	Gui, guiWinAdj: Show

	; GUI always loads on primary, right monitor; switch to left monitor if appropriate
	if (onLeftMonitor) {
		SysGet, Mon2, MonitorWorkArea, 2
		WinGet, guiHwnd, ID, A
		WinGetPos, posX, posY, posW, posH, ahk_id %guiHwnd%
		posX := Mon2Left + posX
		WinMove, ahk_id %guiHwnd%, , %posX%, %posY%, %posW%, %posH%
	}
}

HandleGuiWinAdjWidthSliderChange() {
	global guiWinAdjVars
	global guiWinAdjWidthSlider
	global guiWinAdjXSnapOpts
	global sysWinBorderW

	; Add test to ensure window still exists.
	whichHwnd := guiWinAdjVars.whichHwnd

	if (WinExist("ahk_id " . whichHwnd)) {
		Gui, guiWinAdj: Submit, NoHide
		GuiWinAdjUpdateEdgeSnapping()

		; Move window as dictated by snapping choice and slider position
		WinGetPos, posX, posY, posW, posH, ahk_id %whichHwnd%
		newWidth := guiWinAdjVars.minWidth + (guiWinAdjVars.maxWidth 
			- guiWinAdjVars.minWidth) * (guiWinAdjWidthSlider / 100) + sysWinBorderW * 2
		if (guiWinAdjVars.edgeSnapping & 1) {
			posXNew := posX
		} else if (guiWinAdjVars.edgeSnapping & (1 << 1)) {
			posXNew := posX - (newWidth - posW) / 2
		} else if (guiWinAdjVars.edgeSnapping & (1 << 2)) {
			posXNew := posX - (newWidth - posW)
		}
		GuiWinAdjCheckNewPosition(whichHwnd, posXNew, posY, newWidth, posH)
		WinMove, ahk_id %whichHwnd%, , %posXNew%, %posY%, %newWidth%, %posH%
	} else {
		MsgBox, % "The window you were adjusting has closed; GUI will now exit."
		Gui, guiWinAdj: Destroy
	}
}

HandleGuiWinAdjOK() {
	Gui, guiWinAdj: Destroy
}

guiWinAdjGuiEscape() {
	Gui, guiWinAdj: Destroy
}

GuiWinAdjUpdateEdgeSnapping() {
	global guiWinAdjVars
	global guiWinAdjXSnapOpts

	bitMask := 56 ; 0b111000
	if (guiWinAdjXSnapOpts == 1) {
		bitSwitch := 1 ; 0b000001
	} else if (guiWinAdjXSnapOpts == 2) {
		bitSwitch := 2 ; 0b000010
	} else {
		bitSwitch := 4 ; 0b000100
	}
	guiWinAdjVars.edgeSnapping &= bitMask
	guiWinAdjVars.edgeSnapping += bitSwitch
	edgeSnap := guiWinAdjVars.edgeSnapping
}

GuiWinAdjCheckNewPosition(whichHwnd, ByRef posX, ByRef posY, ByRef winWidth, ByRef winHeight) {
	global sysWinBorderW
	if (IsWindowOnLeftDualMonitor("ahk_id " . whichHwnd)) {
		SysGet, iMon, MonitorWorkArea, 2
	} else {
		SysGet, iMon, MonitorWorkArea, 1
	}
	leftEdge := iMonLeft - (sysWinBorderW - 1)
	rightEdge := iMonRight + (sysWinBorderW - 1)
	topEdge := iMonTop
	bottomEdge := iMonBottom
	if (winWidth - (sysWinBorderW - 1) * 2 > iMonRight - iMonLeft) {
		winWidth := iMonRight - iMonLeft + (sysWinBorderW - 1) * 2
	}
	if (posX < leftEdge) {
		posX := leftEdge
	}
	if (posX + winWidth > rightEdge) {
		posX -= (posX + winWidth) - rightEdge
	}
}

; --------------------------------------------------------------------------------------------------
;   §8: APP SPECIFIC WORKSPACE MANAGEMENT SCRIPTS
; --------------------------------------------------------------------------------------------------

; ··································································································
; >>> §8.1: GNU IMAGE MANIPULATION PROGRAM

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

; ··································································································
;   >>> §8.2: NOTEPAD++: TEXT EDITING ENHANCEMENT HOTKEYS & SCRIPTS

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

; ··································································································
;   >>> §8.3: STICKY NOTES FOR CHROME

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
