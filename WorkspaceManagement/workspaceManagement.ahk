; ==================================================================================================
; ▐   ▌▄▀▀▄ █▀▀▄ █ ▄▀ ▄▀▀▀ █▀▀▄ ▄▀▀▄ ▄▀▀▀ █▀▀▀ ▐▀▄▀▌▐▀▀▄ █▀▀▀ ▐▀▄▀▌▐▀▀▄▐▀█▀▌  ▄▀▀▄ █  █ █ ▄▀ 
; ▐ █ ▌█  █ █▄▄▀ █▀▄  ▀▀▀█ █▄▄▀ █▄▄█ █    █▀▀  █ ▀ ▌█  ▐ █ ▀▄ █ ▀ ▌█  ▐  █    █▄▄█ █▀▀█ █▀▄  
;  ▀ ▀  ▀▀  ▀  ▀▄▀  ▀▄▀▀▀  █    █  ▀  ▀▀▀ ▀▀▀▀ █   ▀▀  ▐ ▀▀▀▀ █   ▀▀  ▐  █  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Script for managing the desktop's workspace.
;
; @version 1.4.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/WorkspaceManagement/work
;   spaceManagement.ahk
; @license MIT Copyright (c) 2021 Daniel C. Rieck.
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;     and associated documentation files (the “Software”), to deal in the Software without
;     restriction, including without limitation the rights to use, copy, modify, merge, publish,
;     distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;     Software is furnished to do so, subject to the following conditions:
;   The above copyright notice and this permission notice shall be included in all copies or
;     substantial portions of the Software.
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;     BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;     DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: AUTOMATED DESKTOP SET UP...............................................................117
;   §2: WINDOW POSITIONING HOTKEYS.............................................................123
;     >>> §2.1: ^!+F3 — "Always on top" toggle.................................................127
;     >>> §2.2: ^!F1-F7 — Virtual desktop switching............................................132
;       →→→ §2.2.1: caf1thruN_switchToDesktop(…)...............................................175
;     >>> §2.3: ^F5-F12 — Snapped positioning of windows on multiple monitor systems...........187
;       →→→ §2.3.1: SnapWindowViaFN............................................................194
;     >>> §2.4: ^!m: Mirrored window positioning for multiple monitors.........................281
;     >>> §2.5: >^!#Left — Snap window to or collapse at left edge.............................318
;       →→→ §2.5.1: DecrementWinDimension......................................................337
;       →→→ §2.5.2: SafeWinMove................................................................355
;     >>> §2.6: <^!#Left — Snap to/collapse at left edge + expand height.......................372
;       →→→ §2.6.1: UpdateVariableAsNeeded.....................................................399
;     >>> §2.7: >^!+Left — Snap to/expand at left edge.........................................412
;       →→→ §2.7.1: IncrementWinDimension......................................................430
;     >>> §2.8: <^!+Left — Snap to/expand at left edge + expand height.........................448
;     >>> §2.9: >^!#Right — Snap window to or collapse at right edge...........................477
;     >>> §2.10: <^!#Right — Snap to/collapse at right edge + expand height....................497
;     >>> §2.11: >^!+Right — Snap to/expand at right edge......................................525
;     >>> §2.12: <^!+Right — Snap to/expand at right edge + expand height......................547
;     >>> §2.13: >^!#Up — Snap window to or collapse at top edge...............................573
;     >>> §2.14: <^!#Up — Snap to/collapse at top edge + expand height.........................594
;     >>> §2.15: >^!+Up — Snap to/expand at top edge...........................................619
;     >>> §2.16: <^!+Up — Snap to/expand at top edge + expand height...........................640
;     >>> §2.17: >^!#Down — Snap window to or collapse at bottom edge..........................664
;     >>> §2.18: <^!#Down — Snap to/collapse at bottom edge + expand height....................685
;     >>> §2.19: >^!+Down — Snap to/expand at bottom edge......................................709
;     >>> §2.20: <^!+Down — Snap to/expand at bottom edge + expand height......................730
;     >>> §2.21: ^!#Numpad5 — Snap to/collapse at midpoint.....................................754
;     >>> §2.22: ^!#NumpadClear — Snap to/expand at midpoint...................................810
;     >>> §2.23: ^NumpadX — Keyboard based movement of active windows..........................855
;       →→→ §2.23.1: TranslateActiveWindow(…)..................................................926
;       →→→ §2.23.2: TAW_ChangeDelta().........................................................939
;       →→→ §2.23.3: TAW_ChechkDefaultDelta()..................................................966
;       →→→ §2.23.4: @changeNumpadMovementDelta................................................977
;     >>> §2.24: ^!NumpadX — Keyboard based expansion and contraction of active windows........985
;       →→→ §2.24.1: NxScaleActiveWindow(…)...................................................1056
;       →→→ §2.24.2: NxScaleAW_ChangeDelta()..................................................1075
;       →→→ §2.24.3: NxScaleAW_ChechkDefaultDelta()...........................................1104
;       →→→ §2.24.4: @changeNumpadScalingDelta................................................1115
;     >>> §2.25: #Numpad5 — Keyboard based simulation of mouse clicks.........................1123
;   §3: VIRTUAL DESKTOP HOTKEYS...............................................................1138
;     >>> §3.1: ^!1-7 — Movement of windows between virtual desktops..........................1142
;       →→→ §3.1.1: ca1thruN_moveToDesktop(…).................................................1185
;   §4: MOUSE HOTKEYS.........................................................................1193
;     >>> §4.1: ^!+RButton — Remember/forget mouse coordinates................................1197
;     >>> §4.2: ^!+LButton — Move to remembered mouse coordinates.............................1233
;       →→→ §4.2.1: casLButton_IsMouseAtCurrentCoord..........................................1244
;       →→→ §4.2.2: casLButton_MoveMouseToCurrentCoord........................................1266
;       →→→ §4.2.3: casLButton_MoveMouseToNextCoord...........................................1296
;     >>> §4.3: ^!#L/RButton — Move mouse to taskbar..........................................1320
;     >>> §4.4: #LButton — Move mouse to center of active window..............................1333
;   §5: AUDITORY CUE BINDING..................................................................1385
;   §6: WINDOW POSITIONING GUIS...............................................................1405
;     >>> §6.1: Window Adjustment GUI.........................................................1409
;       →→→ §6.1.1: TriggerWindowAdjustmentGui................................................1412
;       →→→ §6.1.2: HandleGuiWinAdjWidthEditChange............................................1495
;       →→→ §6.1.3: HandleGuiWinAdjWidthSliderChange..........................................1539
;       →→→ §6.1.4: HandleGuiWinAdjOK.........................................................1578
;       →→→ §6.1.5: guiWinAdjGuiEscape........................................................1585
;       →→→ §6.1.6: GuiWinAdjUpdateEdgeSnapping...............................................1592
;       →→→ §6.1.7: GuiWinAdjCheckNewPosition.................................................1612
;   §7: APP SPECIFIC WORKSPACE MANAGEMENT SCRIPTS.............................................1633
;     >>> §7.1: CHROME........................................................................1637
;       →→→ §7.1.1: OpenWebsiteInChrome.......................................................1640
;       →→→ §7.1.2: OpenNewTabInChrome........................................................1664
;       →→→ §7.1.3: OpenNewWindowInChrome.....................................................1679
;       →→→ §7.1.4: NavigateToWebsiteInChrome.................................................1692
;       →→→ §7.1.5: MoveToNextTabInChrome.....................................................1715
;     >>> §7.2: GNU IMAGE MANIPULATION PROGRAM................................................1727
;       →→→ §7.2.1: @toggleGimp...............................................................1730
;     >>> §7.3: NOTEPAD++: TEXT EDITING ENHANCEMENT HOTKEYS & SCRIPTS.........................1774
;     >>> §7.4: STICKY NOTES FOR CHROME.......................................................1846
;       →→→ §7.4.1: @initStickyNoteToggle.....................................................1849
;       →→→ §7.4.2: @toggleStickyNote.........................................................1861
;     >>> §7.5: SUBLIME TEXT 3................................................................1888
;       →→→ §7.5.1: @sst3 (Start Sublime Text 3)..............................................1891
;       →→→ §7.5.2: updateTableOfContents.ahk.................................................1898
;     >>> §7.6: iTunes........................................................................1903
;       →→→ §7.6.1: @restartItunes............................................................1906
;   §8: Window stacking.......................................................................1961
;     >>> §8.1: @sendActiveWinToBack..........................................................1965
;   §9: Diagnostic hotstrings.................................................................1974
;     >>> §9.1: @getActiveMonitorWorkArea.....................................................1978
;     >>> §9.2: @getInfoOnSystemMonitors......................................................1989
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: AUTOMATED DESKTOP SET UP
; --------------------------------------------------------------------------------------------------

#include %A_ScriptDir%\WorkspaceManagement\automatedDesktopSetUp.ahk

; --------------------------------------------------------------------------------------------------
;   §2: WINDOW POSITIONING HOTKEYS
; --------------------------------------------------------------------------------------------------

;   ······························································································
;     >>> §2.1: ^F12 — "Always on top" toggle

^!+F3::WinSet, AlwaysOnTop, Toggle, A

;   ······························································································
;     >>> §2.2: ^!F1-F7 — Virtual desktop switching

^!F1::
	caf1thruN_switchToDesktop(1)
Return

^!F2::
	caf1thruN_switchToDesktop(2)
Return

^!F3::
	caf1thruN_switchToDesktop(3)
Return

^!F4::
	caf1thruN_switchToDesktop(4)
Return

^!F5::
	caf1thruN_switchToDesktop(5)
Return

^!F6::
	caf1thruN_switchToDesktop(6)
Return

^!F7::
	caf1thruN_switchToDesktop(7)
Return

^!F8::
	caf1thruN_switchToDesktop(8)
Return

^!F9::
	caf1thruN_switchToDesktop(9)
Return

^!F10::
	caf1thruN_switchToDesktop(10)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.2.1: caf1thruN_switchToDesktop(…)

caf1thruN_switchToDesktop(whichDesktop) {
	global vdDesktopCount

	if (whichDesktop >= 1 && whichDesktop <= vdDesktopCount) {
		SwitchDesktopByNumber(whichDesktop)
		SoundPlay, %desktopSwitchingSound%
	}
}

;   ······························································································
;     >>> §2.3: ^F6-F11 — Snapped positioning of windows on multiple monitor systems

^F12::
	SnapWindowViaFN(4, 4, 0.9, "^F10")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.3.1: SnapWindowViaFN

SnapWindowViaFN( monN, snapOpts, dfltScaler, fbFN ) {
	global

	if ( sysNumMonitors >= monN ) {
		; Ensure the window is in view and in a restored state.
		RemoveMinMaxStateForActiveWin()

		; Fetch a copy of the active window's border widths for use in calculations.
		local borderWidths := GetActiveWindowBorderWidths()

		; Determine the range of widths that the window will be allowed to span across based on the
		;   active monitor's work area.
		local maxWidth := ( mon%monN%WorkArea_Right + ( borderWidths.Horz - 1 ) )
			- ( mon%monN%WorkArea_Left - ( borderWidths.Horz - 1 ) )
		local minWidth := Round( maxWidth / 20 * 3 )
		local widthDecrement := minWidth

		; If we have previously snapped and sized the window with this series of hotkeys, reuse the
		;   percentage width in our calculations.
		local scaler
		if ( !isVarDeclared( guiWinAdjVars ) ) {
			scaler := dfltScaler
		} else {
			scaler := guiWinAdjVars.curWidth / 100
		}

		; Determine the new width and horizontal position of the snapped window.
		local newWidth := minWidth + ( maxWidth - minWidth ) * scaler
		local newPosX
		if ( ( snapOpts & ( 1 << 2 ) ) >> 2 ) {
			newPosX := mon%monN%WorkArea_Left + ( maxWidth - minWidth) * ( 1 - scaler )
				- (borderWidths.Horz - 1)
		} else {
			newPosX := mon%monN%WorkArea_Left - borderWidths.Horz + 1
		}

		; Also calculate the height and vertical position the snapped window should occupy on screen.
		local maxHeight := mon%monN%WorkArea_Bottom - mon%monN%WorkArea_Top + ( borderWidths.Vert - 1)
		local minHeight := Round( maxHeight / 20 * 3 )
		local newHeight := maxHeight
		local newPosY := mon%monN%WorkArea_Top

		; Reposition the window, trigger the adjustment GUI, and play a sound.
		WinMove, A, , %newPosX%, %newPosY%, %newWidth%, %maxHeight%
		TriggerWindowAdjustmentGui( snapOpts, minWidth, maxWidth, newWidth, minHeight, maxHeight
			, newHeight )
		SoundPlay, %windowSizingSound%
	} else {
		; We must have less than four monitors installed on the system; default to positioning the
		;   active window on the third system monitor.
		if ( fbFN != "" ) {
			Gosub, % fbFN
		}
	}
}

^F11::
	SnapWindowViaFN(4, 1, 0.9, "^F9")
Return

^F10::
	SnapWindowViaFN(3, 4, 0.9, "^F8")
Return

^F9::
	SnapWindowViaFN(3, 1, 0.9, "^F7")
Return

^F8::
	SnapWindowViaFN(2, 4, 0.9, "^F6")
Return

^F7::
	SnapWindowViaFN(2, 1, 0.9, "^F5")
Return

^F6::
	SnapWindowViaFN(1, 4, 0.9, "")
Return

^F5::
	SnapWindowViaFN(1, 1, 0.9, "")
Return

;   ······························································································
;     >>> §2.4: ^!m: Mirrored window positioning for multiple monitors

^!m::
	aMon := FindNearestActiveMonitor()
	WinGetPos, thisX, thisY, thisW, thisH, A
	thisX := CtrlAltM_GetNewXCoord(aMon, thisX, thisW)
	WinMove, A, , %thisX%, %thisY%, %thisW%, %thisH%
	SoundPlay, %windowMovementSound%
Return

CtrlAltM_GetNewXCoord(aMon, oldX, winW) {
	global ctrlAltM_lastAMon
	global ctrlAltM_lastHwnd
	global mon3Bounds_Left
	newX := oldX
	WinGet, aHwnd, ID, A
	if (aHwnd <> ctrlAltM_lastHwnd) {
		ctrlAltM_lastAMon := 0
	}
	ctrlAltM_lastHwnd := aHwnd
	if (aMon == 1) {
		ctrlAltM_lastAMon := 1
		newX := -newX - winW
	} else if (aMon == 2) {
		if (ctrlAltM_lastAMon == 1) {
			newX := mon3Bounds_Left * 2 - newX - winW
		} else {
			newX := -newX - winW
		}
	} else if (aMon == 3) {
		ctrlAltM_lastAMon := 3
		newX := mon3Bounds_Left * 2 - newX - winW
	}
	return newX
}

;   ······························································································
;     >>> §2.5: >^!#Left — Snap window to or collapse at left edge

; Snap the active window to the left edge of its monitor; if already snapped, reduce its width.
>^!#Left::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.5.1: DecrementWinDimension

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.5.2: SafeWinMove

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

;   ······························································································
;     >>> §2.6: <^!#Left — Snap to/collapse at left edge + expand height

; Snap the active window to the left edge of its monitor; if already snapped, reduce its width.
; Additionally, resize the window vertically to fill up the full vertical extent of the monitor's
; available work area.
<^!#Left::
	GetActiveMonitorWorkArea( monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom )
	if ( monitorFound ) {
		RemoveMinMaxStateForActiveWin()
		WinGetPos, winX, winY, winW, winH, A
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		widthDecrement := Round( ( monitorARight - monitorALeft ) / 20 )
		minWinWidth := Round( ( monitorARight - monitorALeft ) / 20 * 3 )
		maxWinX := monitorARight - monitorALeft - 1
		maxWidth := maxWinX - widthDecrement
		heightChanged := UpdateVariableAsNeeded( winH, monitorABottom - monitorATop - borderWs.Vert
			+ 1 )
		if ( !heightChanged ) {
			DecrementWinDimension( winW, winX, monitorALeft, widthDecrement, minWidth, maxWidth
				, false, maxWinX )
		}
		SafeWinMove( "A", "", monitorALeft, monitorATop + borderWs.Vert - 1, winW, winH )
	}
return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.6.1: UpdateVariableAsNeeded

UpdateVariableAsNeeded(ByRef variable, newValue) {
	if (variable != newValue) {
		variable := newValue
		varChanged := true
	} else {
		varChanged := false
	}
	return varChanged
}

;   ······························································································
;     >>> §2.7: >^!+Left — Snap to/expand at left edge

; Snap the active window to the left edge of its monitor; if already snapped, increase its width.
>^!+Left::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGetPos, winX, winY, winW, winH, A
		widthIncrement := Round((monitorARight - monitorALeft) / 20)
		minWinWidth := Round((monitorARight - monitorALeft) / 20 * 3)
		maxWinWidth := monitorARight - monitorALeft - widthIncrement
		IncrementWinDimension(winW, winX, monitorALeft, widthDecrement, minWinWidth, maxWinWidth
			, false, maxWinWidth)
		SafeWinMove("A", "", monitorALeft, winY, winW, winH)
	}
return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.7.1: IncrementWinDimension

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

;   ······························································································
;     >>> §2.8: <^!+Left — Snap to/expand at left edge + expand height

; Snap the active window to the left edge of its monitor; if already snapped, increase its width.
; Additionally, match the height of the window to the full height of the active monitor's work area.
<^!+Left::
	GetActiveMonitorWorkArea( monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom )
	;;; MsgBox % monitorFound . " | " . monitorALeft . " | " . monitorATop . " | " . monitorARight . " | " . monitorABottom
	if ( monitorFound ) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		widthIncrement := Round( ( monitorARight - monitorALeft ) / 20 )
		minWinWidth := Round( ( monitorARight - monitorALeft ) / 20 * 3 )
		maxWinX := monitorARight - monitorALeft
		maxWinWidth := maxWinX - widthIncrement
		oldWinH := winH
		heightChanged := UpdateVariableAsNeeded( winH, monitorABottom - monitorATop - borderWs.Vert
			+ 1 )
		if ( !heightChanged ) {
			MsgBox % winW . " / " . winX . " / " . monitorALeft . " / " . widthIncrement . " / " . minWinWidth . " / " . maxWinWidth . " / " . maxWinX
			IncrementWinDimension( winW, winX, monitorALeft, widthIncrement, minWinWidth
				, maxWinWidth, false, maxWinX )
		}
		SafeWinMove( "A", "", monitorALeft, monitorATop + borderWs.Vert - 1, winW, winH )
	}
return

;   ······························································································
;     >>> §2.9: >^!#Right — Snap window to or collapse at right edge

; Snap the active window to the right edge of its monitor; if already snapped, reduce its width.
>^!#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGetPos, winX, winY, winW, winH, A
		monWidth := monitorARight - monitorALeft
		widthDecrement := Round(monWidth / 20)
		minWidth := Round(monWidth / 20 * 3)
		maxWidth := monWidth - widthDecrement
		newWinX := monitorARight - winW
		DecrementWinDimension(winW, winX, newWinX, widthDecrement, minWidth, maxWidth, true
			, monitorARight)
		SafeWinMove("A", "", newWinX, winY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.10: <^!#Right — Snap to/collapse at right edge + expand height

; Snap the active window to the right edge of its monitor; if already snapped, reduce its width.
; Additionally, resize the window vertically to fill up the full vertical extent of the monitor's
; available work area.
<^!#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		monWidth := monitorARight - monitorALeft
		widthDecrement := Round(monWidth / 20)
		minWidth := Round(monWidth / 20 * 3)
		maxWidth := monWidth - widthDecrement
		newWinX := monitorARight - winW
		heightChanged := UpdateVariableAsNeeded( winH, monitorABottom - monitorATop - borderWs.Vert
			+ 1 )
		if (!heightChanged) {
			DecrementWinDimension(winW, winX, newWinX, widthDecrement, minWidth, maxWidth, true
				, monitorARight)
		}
		SafeWinMove("A", "", newWinX, monitorATop + borderWs.Vert - 1, winW, winH)
	}
return

;   ······························································································
;     >>> §2.11: >^!+Right — Snap to/expand at right edge

; Snap the active window to the right edge of its monitor; if already snapped, increase its width.
>^!+Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
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

;   ······························································································
;     >>> §2.12: <^!+Right — Snap to/expand at right edge + expand height

; Snap the active window to the right edge of its monitor; if already snapped, increase its width.
<^!+Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		monWidth := monitorARight - monitorALeft
		widthIncrement := Round(monWidth / 20)
		minWidth := Round(monWidth / 20 * 3)
		maxWidth := monWidth - widthIncrement
		newWinX := monitorARight - winW
		heightChanged := UpdateVariableAsNeeded( winH, monitorABottom - monitorATop - borderWs.Vert
			+ 1 )
		if (!heightChanged) {
			IncrementWinDimension(winW, winX, newWinX, widthIncrement, minWidth, maxWidth, true
				, monitorARight)
		}
		SafeWinMove("A", "", newWinX, monitorATop + borderWs.Vert - 1, winW, winH)
	}
return

;   ······························································································
;     >>> §2.13: >^!#Up — Snap window to or collapse at top edge

>^!#Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		heightDecrement := Round( ( monitorABottom - monitorATop ) / 20 )
		minHeight := Round( ( monitorABottom - monitorATop ) / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
		newWinY := monitorATop + borderWs.Vert - 1
		maxWinY := monitorABottom - borderWs.Vert + 1
		DecrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, false
			, maxWinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.14: <^!#Up — Snap to/collapse at top edge + expand height


<^!#Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		heightDecrement := Round( ( monitorABottom - monitorATop ) / 20 )
		minHeight := Round( ( monitorABottom - monitorATop ) / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
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

;   ······························································································
;     >>> §2.15: >^!+Up — Snap to/expand at top edge

>^!+Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		heightDecrement := Round( ( monitorABottom - monitorATop ) / 20 )
		minHeight := Round( ( monitorABottom - monitorATop ) / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
		newWinY := monitorATop + borderWs.Vert - 1
		maxWinY := monitorABottom
		IncrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, false
			, maxWinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.16: <^!+Up — Snap to/expand at top edge + expand height

<^!+Up::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		heightDecrement := Round( ( monitorABottom - monitorATop ) / 20 )
		minHeight := Round( ( monitorABottom - monitorATop ) / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
		newWinY := monitorATop + borderWs.Vert - 1
		maxWinY := monitorABottom - borderWs.Vert + 1
		widthChanged := UpdateVariableAsNeeded(winW, monitorARight - monitorALeft)
		if (!widthChanged) {
			IncrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, false
				, maxWinY)
		}
		SafeWinMove("A", "", monitorALeft, newWinY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.17: >^!#Down — Snap window to or collapse at bottom edge

>^!#Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightDecrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
		maxWinY := monitorABottom
		DecrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, true
			, maxwinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.18: <^!#Down — Snap to/collapse at bottom edge + expand height

<^!#Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightDecrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
		maxWinY := monitorABottom
		widthChanged := UpdateVariableAsNeeded(winW, monitorARight - monitorALeft)
		if (!widthChanged) {
			DecrementWinDimension(winH, winY, newWinY, heightDecrement, minHeight, maxHeight, true
				, maxwinY)
		}
		SafeWinMove("A", "", monitorALeft, newWinY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.19: >^!+Down — Snap to/expand at bottom edge

>^!+Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightIncrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
		maxWinY := monitorABottom
		IncrementWinDimension(winH, winY, newWinY, heightIncrement, minHeight, maxHeight, true
			, maxWinY)
		SafeWinMove("A", "", winX, newWinY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.20: <^!+Down — Snap to/expand at bottom edge + expand height

<^!+Down::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGet, hwnd, ID, A
		borderWs := GetWindowBorderWidths(hwnd)
		WinGetPos, winX, winY, winW, winH, A
		newWinY := monitorABottom - winH
		heightIncrement := Round(monitorABottom / 20)
		minHeight := Round(monitorABottom / 20 * 3)
		maxHeight := monitorABottom - monitorATop - borderWs.Vert + 1 - heightDecrement
		widthChanged := UpdateVariableAsNeeded(winW, monitorARight - monitorALeft)
		maxWinY := monitorABottom
		if (!widthChanged) {
			IncrementWinDimension(winH, winY, newWinY, heightIncrement, minHeight, maxHeight, true
				, maxWinY)
		}
		SafeWinMove("A", "", monitorALeft, newWinY, winW, winH)
	}
return

;   ······························································································
;     >>> §2.21: ^!#Numpad5 — Snap to/collapse at midpoint

^!#Numpad5::
	; Snap the center of the active window to the center of its monitor. Decrement its width &
	; height up to minimum thresholds if already snapped, and wrap the width/height if minimum
	; threshholds are exceeded.
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, aMonLeft, aMonTop, aMonRight, aMonBottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
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

;   ······························································································
;     >>> §2.22: ^!#NumpadClear — Snap to/expand at midpoint

^!#NumpadClear:: ; Equivalent to ^!+#Numpad5
	; Snap the center of the active window to the center of its monitor. Increment its width &
	; height up to maximum thresholds if already snapped, and wrap the width/height if maximum
	; thresholds are exceeded.
	SoundPlay, %windowMovementSound%
	GetActiveMonitorWorkArea(monitorFound, aMonLeft, aMonTop, aMonRight, aMonBottom)
	if (monitorFound) {
		RemoveMinMaxStateForActiveWin()
		WinGetPos, winX, winY, winW, winH, A
		aMonMidPtX := (aMonRight - aMonLeft) / 2
		aMonMidPtY := (aMonBottom - aMonTop) / 2
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

;   ······························································································
;     >>> §2.23: ^NumpadX — Keyboard based movement of active windows

^Numpad1::
	TranslateActiveWindow(-1, 1)
Return

^#Numpad1::
	TranslateActiveWindow(-5, 5)
Return

^Numpad2::
	TranslateActiveWindow(0, 1)
Return

^#Numpad2::
	TranslateActiveWindow(0, 5)
Return

^Numpad3::
	TranslateActiveWindow(1, 1)
Return

^#Numpad3::
	TranslateActiveWindow(5, 5)
Return

^Numpad4::
	TranslateActiveWindow(-1, 0)
Return

^#Numpad4::
	TranslateActiveWindow(-5, 0)
Return

^Numpad5::
	Gosub :*?:@changeNumpadMovementDelta
Return

^Numpad6::
	TranslateActiveWindow(1, 0)
Return

^#Numpad6::
	TranslateActiveWindow(5, 0)
Return

^Numpad7::
	TranslateActiveWindow(-1, -1)
Return

^#Numpad7::
	TranslateActiveWindow(-5, -5)
Return

^Numpad8::
	TranslateActiveWindow(0, -1)
Return

^#Numpad8::
	TranslateActiveWindow(0, -5)
Return

^Numpad9::
	TranslateActiveWindow(1, -1)
Return

^#Numpad9::
	TranslateActiveWindow(5, -5)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.1: TranslateActiveWindow(…)

TranslateActiveWindow(delX, delY) {
	global twMvDelta

	TAW_CheckDefaultDelta()
	WinGetPos xl, yt, w, h, A
	newX := xl + delX * twMvDelta
	newY := yt + delY * twMvDelta
	WinMove A, , %newX%, %newY%
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.2: TAW_ChangeDelta() [TAW = TranslateActiveWindow]

TAW_ChangeDelta() {
	global checkType
	global minMonWorkAreaDim
	global twMvDelta

	TAW_CheckDefaultDelta()
	InputBox newTwMvDelta, % "Numpad-mediated Window Movement", % "Please enter a new value for the"
		. " number of pixels a window should be translated with each keystroke when the numpad is u"
		. "sed to move a window around on the desktop.`n`n(Current Δpx = " . twMvDelta . ")"
	if ( !ErrorLevel ) {
		maxDelta := minMonWorkAreaDim / 4
		if ( checkType.IsInteger( newTwMvDelta ) && newTwMvDelta > 0 && newTwMvDelta <= maxDelta ) {
			oldMvDelta := twMvDelta
			twMvDelta := newTwMvDelta
			DisplaySplashText( "Numpad-mediated window movement delta changed from " . oldMvDelta
				. " to " . twMvDelta )
		} else {
			DisplaySplashText( "Due to invalid input, the numpad-mediated window movement delta has"
				. " been left unchanged. (New delta requirements: integer, >0, ≤" . maxDelta .  ")"
				, 3000 )
		}
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.3: TAW_ChechkDefaultDelta()

TAW_CheckDefaultDelta() {
	global twMvDelta

	if ( !doesVarExist( twMvDelta ) || isVarEmpty( twMvDelta ) ) {
		twMvDelta := 10
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.4: @changeNumpadMovementDelta

:*?:@changeNumpadMovementDelta::
	AppendAhkCmd( A_ThisLabel )
	TAW_ChangeDelta()
Return

;   ······························································································
;     >>> §2.24: ^!NumpadX — Keyboard based expansion and contraction of active windows

^NumpadEnd::
	NxScaleActiveWindow( -1, -1 )
Return

^#NumpadEnd::
	NxScaleActiveWindow( -5, -5 )
Return

^NumpadDown::
	NxScaleActiveWindow( 0, -1 )
Return

^#NumpadDown::
	NxScaleActiveWindow( 0, -5 )
Return

^NumpadPgDn::
	NxScaleActiveWindow( 1, -1 )
Return

^#NumpadPgDn::
	NxScaleActiveWindow( 5, -5 )
Return

^NumpadLeft::
	NxScaleActiveWindow( -1, 0 )
Return

^#NumpadLeft::
	NxScaleActiveWindow( -5, 0 )
Return

^NumpadClear::
	Gosub :*?:@changeNumpadScalingDelta
Return

^NumpadRight::
	NxScaleActiveWindow( 1, 0 )
Return

^#NumpadRight::
	NxScaleActiveWindow( 5, 0 )
Return

^NumpadHome::
	NxScaleActiveWindow( -1, 1 )
Return

^#NumpadHome::
	NxScaleActiveWindow( -5, 5 )
Return

^NumpadUp::
	NxScaleActiveWindow( 0, 1 )
Return

^#NumpadUp::
	NxScaleActiveWindow( 0, 5 )
Return

^NumpadPgUp::
	NxScaleActiveWindow( 1, 1 )
Return

^#NumpadPgUp::
	NxScaleActiveWindow( 5, 5 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.24.1: NxScaleActiveWindow(…)

NxScaleActiveWindow( delX, delY ) {
	global nxawScaleDelta
	global minMonWorkAreaDim

	NxScaleAW_CheckDefaultDelta()
	WinGetPos xl, yt, w, h, A
	if ( w + delX * nxawScaleDelta >= minMonWorkAreaDim / 4
			&& h + delY * nxawScaleDelta > minMonWorkAreaDim / 4 ) {
		newW := w + delX * nxawScaleDelta
		newH := h + delY * nxawScaleDelta
		newX := xl - ( delX * nxawScaleDelta ) / 2
		newY := yt - ( delY * nxawScaleDelta ) / 2
		WinMove A, , %newX%, %newY%, %newW%, %newH%
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.24.2: NxScaleAW_ChangeDelta()

NxScaleAW_ChangeDelta() {
	global checkType
	global minMonWorkAreaDim
	global nxawScaleDelta

	NxScaleAW_CheckDefaultDelta()
	InputBox newNxawScaleDelta, % "Numpad-mediated Window Expansion and Contraction", % "Please "
		. "enter a new value for the number of pixels the active window should be scaled with each "
		. "keystroke when the numpad is used to expand or contract it.`n`n(Current Δpx = "
		. nxawScaleDelta . ")"
	if ( !ErrorLevel ) {
		maxDelta := minMonWorkAreaDim / 4
		if ( checkType.IsInteger( newNxawScaleDelta ) && newNxawScaleDelta > 0
				&& newNxawScaleDelta <= maxDelta ) {
			oldScaleDelta := nxawScaleDelta
			nxawScaleDelta := newNxawScaleDelta
			DisplaySplashText( "Numpad-mediated window scaling delta changed from " . oldScaleDelta
				. " to " . nxawScaleDelta . " pixels.")
		} else {
			DisplaySplashText( "Due to invalid input, the numpad-mediated window scaling delta has"
				. " been left unchanged. (New delta requirements: integer, >0, ≤" . maxDelta .  ")"
				, 3000 )
		}
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.24.3: NxScaleAW_CheckDefaultDelta()

NxScaleAW_CheckDefaultDelta() {
	global nxawScaleDelta

	if ( !doesVarExist( nxawScaleDelta ) || isVarEmpty( nxawScaleDelta ) ) {
		nxawScaleDelta := 20
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.24.4: @changeNumpadScalingDelta

:*?:@changeNumpadScalingDelta::
	AppendAhkCmd( A_ThisLabel )
	NxScaleAW_ChangeDelta()
Return

;   ······························································································
;     >>> §2.25: #Numpad5 — Keyboard based simulation of mouse clicks

#Numpad5::
	Send {Click}
Return

!Numpad5::
	Send {Click Right}
Return

^#Numpad5::
	Gosub, #LButton
Return

; --------------------------------------------------------------------------------------------------
;   §3: VIRTUAL DESKTOP HOTKEYS
; --------------------------------------------------------------------------------------------------

;   ······························································································
;     >>> §3.1: ^!1-7 — Movement of windows between virtual desktops

^!1::
	ca1thruN_moveToDesktop(1)
return

^!2::
	ca1thruN_moveToDesktop(2)
return

^!3::
	ca1thruN_moveToDesktop(3)
return

^!4::
	ca1thruN_moveToDesktop(4)
return

^!5::
	ca1thruN_moveToDesktop(5)
return

^!6::
	ca1thruN_moveToDesktop(6)
Return

^!7::
	ca1thruN_moveToDesktop(7)
Return

^!8::
	ca1thruN_moveToDesktop(8)
Return

^!9::
	ca1thruN_moveToDesktop(9)
Return

^!0::
	ca1thruN_moveToDesktop(10)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §3.1.1: ca1thruN_moveToDesktop(…)

ca1thruN_moveToDesktop(whichDesktop) {
	MoveActiveWindowToVirtualDesktop(whichDesktop)
	SoundPlay, %windowShiftingSound%
}

; --------------------------------------------------------------------------------------------------
;   §4: MOUSE HOTKEYS
; --------------------------------------------------------------------------------------------------

;   ······························································································
;     >>> §4.1: ^!+RButton — Remember/forget mouse coordinates

;TODO: Convert these functions into an array based format
<^!+RButton::
	global savedMouseCoords

	if (savedMouseCoords = undefined) {
		savedMouseCoords := {}
		savedMouseCoords.idx := 0
		savedMouseCoords.array := {}
	}

	CoordMode, Mouse, Screen
	MouseGetPos, mouseX, mouseY
	savedMouseCoords.idx++
	(savedMouseCoords.array).InsertAt(savedMouseCoords.idx, {x: mouseX, y: mouseY})
Return

>^!+RButton::
	global savedMouseCoords

	if (savedMouseCoords != undefined) {
		if ( savedMouseCoords.idx == 0 && savedMouseCoords.array.Length() != 0 ) {
			savedMouseCoords.idx := savedMouseCoords.array.Length()
		}
		if ( savedMouseCoords.idx > 0 ) {
			if (!casLButton_IsMouseAtCurrentCoord()) {
				casLButton_MoveMouseToCurrentCoord()
			}
			savedMouseCoords.array.RemoveAt(savedMouseCoords.idx)
			savedMouseCoords.idx--
		}
	}
Return

;   ······························································································
;     >>> §4.2: ^!+LButton — Move to remembered mouse coordinates

^!+LButton::
	if (casLButton_IsMouseAtCurrentCoord()) {
		casLButton_MoveMouseToNextCoord()
	} else {
		casLButton_MoveMouseToCurrentCoord()
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.1: casLButton_IsMouseAtCurrentCoord

casLButton_IsMouseAtCurrentCoord() {
	global savedMouseCoords
	global startingMouseCoords

	atCurrentCoord := False
	if (savedMouseCoords != undefined) {
		if (savedMouseCoords.idx = 0) {
			coords := startingMouseCoords
		} else {
			coords := savedMouseCoords.array[savedMouseCoords.idx]
		}
		mouseX := coords.x
		mouseY := coords.y
		atCurrentCoord := IsMouseAtCoord( mouseX, mouseY )
	}

	return atCurrentCoord
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.2: casLButton_MoveMouseToCurrentCoord

casLButton_MoveMouseToCurrentCoord() {
	global savedMouseCoords
	global startingMouseCoords

	if (savedMouseCoords != undefined) {
		; Automatically save the mouse's current position to the end of the remembered coordinate
		CoordMode, Mouse, Screen
		MouseGetPos, mouseX, mouseY
		if (startingMouseCoords = undefined) {
			startingMouseCoords := {}
		}
		startingMouseCoords.x := mouseX
		startingMouseCoords.y := mouseY

		; Move the cursor to the active mouse coordinate in the remembered coordinate array.
		if ( savedMouseCoords.idx = 0) {
			casLButton_MoveMouseToNextCoord()
		} else {
			coords := savedMouseCoords.array[savedMouseCoords.idx]
			mouseX := coords.x
			mouseY := coords.y
			CoordMode, Mouse, Screen
			MouseMove, %mouseX%, %mouseY%
		}
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.3: casLButton_MoveMouseToNextCoord

casLButton_MoveMouseToNextCoord() {
	global savedMouseCoords
	global startingMouseCoords

	if (savedMouseCoords != undefined) {
		savedMouseCoords.idx--
		if (savedMouseCoords.idx = 0) {
			coords := startingMouseCoords
		} else if (savedMouseCoords.idx < 0) {
			savedMouseCoords.idx := savedMouseCoords.array.Length()
			coords := savedMouseCoords.array[savedMouseCoords.idx]
		} else {
			coords := savedMouseCoords.array[savedMouseCoords.idx]
		}
		mouseX := coords.x
		mouseY := coords.y
		CoordMode, Mouse, Screen
		MouseMove, %mouseX%, %mouseY%
	}
}

;   ······························································································
;     >>> §4.3: ^!#L/RButton — Move mouse to taskbar

^!#LButton::
	CoordMode, Mouse, Screen
	MouseMove, -1568, 1065
Return

^!#RButton::
	CoordMode, Mouse, Screen
	MouseMove, 351, 1065
Return

;   ······························································································
;     >>> §4.4: #LButton — Move mouse to center of active window

#LButton::
	CoordMode, Mouse, Screen
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	execDelayer.Wait( "s" )
	if ( IsMouseAtCoord( thisWinX + thisWinW / 2, thisWinY + thisWinH / 2 ) ) {
		Send % "{Alt Down}{Shift Down}{Tab}{Shift Up}{Alt Up}"
		execDelayer.Wait( "m" )
		WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
		execDelayer.Wait( "s" )
		MouseMove, % (thisWinX + thisWinW / 2), % (thisWinY + thisWinH / 2)
	} else {
		MouseMove, % (thisWinX + thisWinW / 2), % (thisWinY + thisWinH / 2)
	}
Return

^#LButton::
!SC029::
	; First, get the midpoint of the work area for the monitor the mouse cursor is situated on.
	curMon := FindMonitorMouseIsOn()
	aMonMidPtX := ( mon%curMon%WorkArea_Right - mon%curMon%WorkArea_Left ) / 2
		+ mon%curMon%WorkArea_Left
	aMonMidPtY := ( mon%curMon%WorkArea_Bottom - mon%curMon%WorkArea_Top ) / 2
		+ mon%curMon%WorkArea_Top

	; Now, determine how to move the cursor based on whether it is positioned at the monitor's
	;   midpoint.
	if ( IsMouseAtCoord( aMonMidPtX, aMonMidPtY ) && sysNumMonitors > 1 ) {
		
		; Since the mouse cursor is already positioned at the midpoint of the monitor it is on, move the
		;   cursor to the midpoint of the next system monitor.
		nextMon := curMon + 1
		if ( nextMon > sysNumMonitors ) {
			nextMon := 1
		}
		aMonMidPtX := ( mon%nextMon%WorkArea_Right - mon%nextMon%WorkArea_Left ) / 2
			+ mon%nextMon%WorkArea_Left
		aMonMidPtY := ( mon%nextMon%WorkArea_Bottom - mon%nextMon%WorkArea_Top ) / 2
			+ mon%nextMon%WorkArea_Top
		CoordMode, Mouse, Screen
		MouseMove, % aMonMidPtX, % aMonMidPtY
	} else {

		; Since the mouse cursor is not positioned at the midpoint of the monitor it is currently on,
		;   move it there.
		CoordMode, Mouse, Screen
		MouseMove, % aMonMidPtX, % aMonMidPtY
	}
Return

; --------------------------------------------------------------------------------------------------
;   §5: AUDITORY CUE BINDING
; --------------------------------------------------------------------------------------------------

~^#Left::
	SoundPlay, %desktopSwitchingSound%
Return

~+#Left::
	SoundPlay, %windowMovementSound%
Return

~^#Right::
	SoundPlay, %desktopSwitchingSound%
Return

~+#Right::
	SoundPlay, %windowMovementSound%
Return

; --------------------------------------------------------------------------------------------------
;   §6: WINDOW POSITIONING GUIS
; --------------------------------------------------------------------------------------------------

;   ······························································································
;     >>> §6.1: Window Adjustment GUI

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.1: TriggerWindowAdjustmentGui

; Edge snapping values & meaning:
;   0b000001 = snap left
;   0b000010 = snap horizontal center
;   0b000100 = snap right
;   0b001000 = snap top
;   0b010000 = snap vertical center
;   0b000100 = snap bottom
; For mixed values, effects are triggered from top to bottom as listed above; thus, if left and
; right snapping bits are both set to true, left snapping will override right snapping.
TriggerWindowAdjustmentGui( edgeSnapping, minWidth, maxWidth, initialWidth, minHeight, maxHeight
		, initialHeight ) {
	global
	local whichHwnd
	local sliderPos
	local xSnapOptL
	local xSnapOptC
	local xSnapOptR
	local ySnapOptT
	local ySnapOptC
	local ySnapOptB
	local aMonId
	local aMonLeft
	local aMonTop
	local aMonRight
	local aMonBottom

	; Start by getting work area of active monitor
	GetActiveMonitorWorkArea( aMonId, aMonLeft, aMonTop, aMonRight, aMonBottom )

	; Store persistent data in GUI's associated global object
	WinGet, whichHwnd, ID, A
	if ( !isVarDeclared(guiWinAdjVars) ) {
		guiWinAdjVars := Object()
	}
	guiWinAdjVars.whichHwnd := whichHwnd
	guiWinAdjVars.minWidth := minWidth
	guiWinAdjVars.maxWidth := maxWidth
	guiWinAdjVars.minHeight := minHeight
	guiWinAdjVars.maxHeight := maxHeight
	if ( isVarEmpty( guiWinAdjVars.curWidth ) ) {
		guiWinAdjVars.curWidth := Round( ( initialWidth - minWidth ) / ( maxWidth - minWidth )
			* 100 )
	}
	sliderPos := guiWinAdjVars.curWidth
	guiWinAdjVars.edgeSnapping := edgeSnapping
	guiWinAdjVars.timerId

	; Process edgeSnapping bitmask
	xSnapOptL := edgeSnapping & 1
	xSnapOptC := ( edgeSnapping & ( 1 << 1 ) ) >> 1
	xSnapOptR := ( edgeSnapping & ( 1 << 2 ) ) >> 2
	ySnapOptT := ( edgeSnapping & ( 1 << 3 ) ) >> 3
	ySnapOptC := ( edgeSnapping & ( 1 << 4 ) ) >> 4
	ySnapOptR := ( edgeSnapping & ( 1 << 5 ) ) >> 5

	; Setup GUI & display to user
	Gui, guiWinAdj: New,
		, % "Adjust Active Window Width"
	Gui, guiWinAdj: Add, Text, , % "Window &width (%):"
	Gui, guiWinAdj: Add, Slider
		, vguiWinAdjWidthSlider gHandleGuiWinAdjWidthSliderChange W300 x+5
		, %sliderPos%
	Gui, guiWinAdj: Add, Edit
		, vguiWinAdjWidthEdit gHandleGuiWinAdjWidthEditChange x+5 W60, %sliderPos%
	Gui, guiWinAdj: Add, Text, xm, Horizontal snapping:
	Gui, guiWinAdj: Add, Radio, vguiWinAdjXSnapOpts x+5 Checked%xSnapOptL%, &Left
	Gui, guiWinAdj: Add, Radio, x+5 Checked%xSnapOptC%, &Center
	Gui, guiWinAdj: Add, Radio, x+5 Checked%xSnapOptR%, &Right
	Gui, guiWinAdj: Add, Button, Default gHandleGuiWinAdjOK xm y+15, &OK
	Gui, guiWinAdj: Show

	; GUI always loads on primary monitor; switch to different monitor if appropriate
	if ( aMonLeft != 0 ) {
		WinGet, guiHwnd, ID, A
		WinGetPos, posX, posY, posW, posH, ahk_id %guiHwnd%
		posX := aMonLeft + posX
		WinMove, ahk_id %guiHwnd%, , %posX%, %posY%, %posW%, %posH%
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.2: HandleGuiWinAdjWidthEditChange

HandleGuiWinAdjWidthEditChange() {
	SetTimer, ExecGuiWinAdjWidthEditChange, -200
}

ExecGuiWinAdjWidthEditChange() {
	global guiWinAdjVars
	global guiWinAdjWidthSlider
	global guiWinAdjWidthEdit
	global guiWinAdjXSnapOpts

	; Test to ensure window still exists.
	whichHwnd := guiWinAdjVars.whichHwnd
	borderWs := GetWindowBorderWidths(whichHwnd)
	if (WinExist("ahk_id " . whichHwnd)) {
		Gui, guiWinAdj: Submit, NoHide

		; Move window as dictated by snapping choice and slider position
		WinGetPos, posX, posY, posW, posH, ahk_id %whichHwnd%
		if (guiWinAdjWidthEdit > 0) {
			newWidth := guiWinAdjVars.minWidth + (guiWinAdjVars.maxWidth
				- guiWinAdjVars.minWidth) * (guiWinAdjWidthEdit / 100) + (borderWs.Horz * 2)
		} else {
			newWidth := guiWinAdjVars.minWidth

		}
		if (guiWinAdjVars.edgeSnapping & 1) {
			posXNew := posX
		} else if (guiWinAdjVars.edgeSnapping & (1 << 1)) {
			posXNew := posX - (newWidth - posW) / 2
		} else if (guiWinAdjVars.edgeSnapping & (1 << 2)) {
			posXNew := posX - (newWidth - posW) + 1
		}
		GuiWinAdjCheckNewPosition(whichHwnd, posXNew, posY, newWidth, posH)
		WinMove, ahk_id %whichHwnd%, , %posXNew%, %posY%, %newWidth%, %posH%
		GuiControl, -g, guiWinAdjWidthSlider
		GuiControl, guiWinAdj:, guiWinAdjWidthSlider, %guiWinAdjWidthEdit%
		GuiControl, +gHandleGuiWinAdjWidthSliderChange, guiWinAdjWidthSlider
		guiWinAdjVars.curWidth := guiWinAdjWidthEdit
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.3: HandleGuiWinAdjWidthSliderChange

HandleGuiWinAdjWidthSliderChange() {
	global guiWinAdjVars
	global guiWinAdjWidthSlider
	global guiWinAdjWidthEdit
	global guiWinAdjXSnapOpts

	; Test to ensure window still exists.
	whichHwnd := guiWinAdjVars.whichHwnd
	borderWs := GetWindowBorderWidths(whichHwnd)
	if (WinExist("ahk_id " . whichHwnd)) {
		Gui, guiWinAdj: Submit, NoHide
		GuiWinAdjUpdateEdgeSnapping()

		; Move window as dictated by snapping choice and slider position
		WinGetPos, posX, posY, posW, posH, ahk_id %whichHwnd%
		newWidth := guiWinAdjVars.minWidth + (guiWinAdjVars.maxWidth
			- guiWinAdjVars.minWidth) * (guiWinAdjWidthSlider / 100) + (borderWs.Horz * 2)
		if (guiWinAdjVars.edgeSnapping & 1) {
			posXNew := posX
		} else if (guiWinAdjVars.edgeSnapping & (1 << 1)) {
			posXNew := posX - (newWidth - posW) / 2
		} else if (guiWinAdjVars.edgeSnapping & (1 << 2)) {
			posXNew := posX - (newWidth - posW) + 1
		}
		GuiWinAdjCheckNewPosition(whichHwnd, posXNew, posY, newWidth, posH)
		WinMove, ahk_id %whichHwnd%, , %posXNew%, %posY%, %newWidth%, %posH%
		GuiControl, -g, guiWinAdjWidthEdit
		GuiControl, , guiWinAdjWidthEdit, %guiWinAdjWidthSlider%
		GuiControl, +gHandleGuiWinAdjWidthEditChange, guiWinAdjWidthEdit
		guiWinAdjVars.curWidth := guiWinAdjWidthSlider
	} else {
		MsgBox, % "The window you were adjusting has closed; GUI will now exit."
		Gui, guiWinAdj: Destroy
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.4: HandleGuiWinAdjOK

HandleGuiWinAdjOK() {
	Gui, guiWinAdj: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.5: guiWinAdjGuiEscape

guiWinAdjGuiEscape() {
	Gui, guiWinAdj: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.6: GuiWinAdjUpdateEdgeSnapping

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.7: GuiWinAdjCheckNewPosition

GuiWinAdjCheckNewPosition(whichHwnd, ByRef posX, ByRef posY, ByRef winWidth, ByRef winHeight) {
	global sysWinBorderW
	GetActiveMonitorWorkArea(monitorFound, iMonLeft, iMonTop, iMonRight, iMonBottom)
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
;   §7: APP SPECIFIC WORKSPACE MANAGEMENT SCRIPTS
; --------------------------------------------------------------------------------------------------

;   ······························································································
;     >>> §7.1: CHROME

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.1: OpenWebsiteInChrome

OpenWebsiteInChrome(website, inNewTab := True) {
	global execDelayer
	delay := execDelayer.InterpretDelayString("short")
	website .= "{Enter}"
	attemptCount := 0
	WinGet procName, ProcessName, A
	while (procName != "chrome.exe" && attemptCount <= 8) {
		execDelayer.Wait( delay, 2.5 )
		WinActivate % "ahk_exe chrome.exe"
		execDelayer.Wait( delay )
		WinGet procName, ProcessName, A
		attemptCount++
	}
	if ( inNewTab ) {
		OpenNewTabInChrome()
	} else {
		execDelayer.Wait( delay, 2 )
	}
	NavigateToWebsiteInChrome( website )
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.2: OpenNewTabInChrome

OpenNewTabInChrome() {
	global execDelayer
	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		WinGetTitle, title, A
		if ( InStr(title, "New Tab") != 1 ) {
			SendInput, ^t
		}
		execDelayer.Wait( "short", 2 )
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.3: OpenNewWindowInChrome

OpenNewWindowInChrome() {
	global execDelayer

	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput, ^n
		execDelayer.Wait( "m" )
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.4: NavigateToWebsiteInChrome

NavigateToWebsiteInChrome( website ) {
	global execDelayer
	delay := execDelayer.InterpretDelayString( "short" )
	WinGet, procName, ProcessName, A
	if (procName == "chrome.exe") {
		WinGetTitle, curTitle, A
		SendInput, !d
		execDelayer.Wait( delay )
		SendInput, % website
		execDelayer.Wait( delay, 5 )
		WinGetTitle, newTitle, A
		idx := 0
		while ( curTitle == newTitle && idx < 10 ) {
			WinGetTitle, newTitle, A
			execDelayer.Wait( delay, 5 )
			idx++
		}
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.5: MoveToNextTabInChrome

MoveToNextTabInChrome() {
	delay := GetDelay("short")
	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput ^{Tab}
		Sleep %delay%
	}
}

;   ······························································································
;     >>> §7.2: GNU IMAGE MANIPULATION PROGRAM

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.1: @toggleGimp

:*?:@toggleGimp::
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

;   ······························································································
;     >>> §7.3: NOTEPAD++: TEXT EDITING ENHANCEMENT HOTKEYS & SCRIPTS

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

;   ······························································································
;     >>> §7.4: STICKY NOTES FOR CHROME

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.1: @initStickyNoteToggle

:*?:@initStickyNoteToggle::
	global hwndStickyNoteWindow
	ahkCmdName := ":*?:@initStickyNoteToggle"
	AppendAhkCmd(ahkCmdName)
	WinGet, hwndStickyNoteWindow, ID, A
	MsgBox, 0, % ":*?:@initStickyNoteSwitcher", % "Sticky note window with HWND "
		. hwndStickyNoteWindow . " can now be toggled via the hotstring @toggleStickyNote."
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.2: @toggleStickyNote

:*?:@toggleStickyNote::
	global hwndStickyNoteWindow
	global hwndActiveBeforeStickyNote
	ahkCmdName := ":*?:@toggleStickyNote"
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

;   ······························································································
;     >>> §7.5: SUBLIME TEXT 3

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.1: @sst3

:*?:@sst3::
	SendInput, % "start sublime_text.exe "
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.2: updateTableOfContents.ahk

#Include %A_ScriptDir%\WorkspaceManagement\updateTableOfContents.ahk

;   ······························································································
;     >>> §7.6: iTunes

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.1: @restartItunes

:*?:@restartItunes::
	AppendAhkCmd( A_ThisLabel )
	DetectHiddenWindows, On
	execDelayer.Wait( "s" )
	winTitle := "iTunes ahk_exe iTunes.exe"
	iTunesHwnd := WinExist( winTitle )
	if ( iTunesHwnd ) {
		; Keep a record of the currently active window for later.
		aHwnd := WinExist( "A" )
		if (aHwnd == iTunesHwnd) {
			aHwnd := 0
		}

		; Find iTunes and close it.
		WinActivate % winTitle
		WinWaitActive %winTitle%, , 30
		proceed := !ErrorLevel
		if ( proceed ) {
			WinClose %winTitle%
			WinWaitClose %winTitle%, , 30
			proceed := !ErrorLevel
		} else {
			failedFunc := "WainWaitActive for closing iTunes"
		}
		; Now reopen iTunes.
		if ( proceed ) {
			execDelayer.Wait( "l" )
			LaunchStdApplicationPatiently( "shell:appsFolder\AppleInc.iTunes_nzyj5cx40ttqa!iTunes"
				, "iTunes")
			execDelayer.Wait( "l" )
			WinWaitActive %winTitle%, , 30
			proceed := !ErrorLevel
		} else {
			failedFunc := "WainWaitClose for closing iTunes"
		}

		; Restore focus to the window that was open before we restarted iTunes.
		if ( proceed && aHwnd ) {
			execDelayer.Wait( "l" )
			WinActivate % "ahk_id " . aHwnd
		} else {
			failedFunc := "WainWaitActive for reopening iTunes"
		}

		; Report any errord that were encountered above.
		if ( !proceed ) {
			ErrorBox( A_ThisLabel, failedFunc . " reports ErrorLevel = " . ErrorLevel )
		}
	}
	DetectHiddenWindows, Off
Return

; --------------------------------------------------------------------------------------------------
;   §8: Window stacking
; --------------------------------------------------------------------------------------------------

;   ······························································································
;     >>> §8.1: @sendActiveWinToBack

:*?:@sendActiveWinToBack::
  AppendAhkCmd(A_ThisLabel)
  WinGet, hWnd, ID, A
  DllCall("SetWindowPos", "uint", hWnd, "uint", 1, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x13)
Return

; --------------------------------------------------------------------------------------------------
;   §9: Diagnostic hotstrings
; --------------------------------------------------------------------------------------------------

;   ······························································································
;     >>> §9.1: @getActiveMonitorWorkArea

:*?:@getActiveMonitorWorkArea::
	AppendAhkCmd(A_ThisLabel)
	GetActiveMonitorWorkArea(aMon, aMon_Left, aMon_Top, aMon_Right, aMon_Bottom)
	MsgBox, % "Work area of monitor #" . aMon . ":`r"
		. "Upper left: " . aMon_Left . ", " . aMon_Top . "`r"
		. "Lower right: " . aMon_Right . ", " . aMon_Bottom
Return

;   ······························································································
;     >>> §9.2: @getInfoOnSystemMonitors

:*?:@getInfoOnSystemMonitors::
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
