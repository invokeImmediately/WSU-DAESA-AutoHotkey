; ==================================================================================================
; workspaceMngmnt.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Script for managing the desktop's workspace.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck.
;
;   Permission to use, copy, modify, and/or distribute this software for any purpose with or
;   without fee is hereby granted, provided that the above copyright notice and this permission
;   notice appear in all copies.
;
;   THE SOFTWARE IS PROVIDED "AS IS" AND DANIEL RIECK DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
;   SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
;   DANIEL RIECK BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
;   DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
;   CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;   PERFORMANCE OF THIS SOFTWARE.
; --------------------------------------------------------------------------------------------------
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: AUTOMATED DESKTOP SET UP...............................................................109
;   §2: WINDOW POSITIONING HOTKEYS.............................................................115
;     >>> §2.1: ^F12 — "Always on top" toggle..................................................119
;     >>> §2.2: ^!F1-F7 — Virtual desktop switching............................................124
;       →→→ §2.2.1: caf1thruN_switchToDesktop(…)...............................................167
;     >>> §2.3: ^F6-F11 — Snapped positioning of windows on multiple monitor systems...........179
;     >>> §2.4: ^!m: Mirrored window positioning for multiple monitors.........................285
;     >>> §2.5: >^!#Left — Snap window to or collapse at left edge.............................322
;       →→→ §2.5.1: DecrementWinDimension......................................................340
;       →→→ §2.5.2: SafeWinMove................................................................358
;     >>> §2.6: <^!#Left — Snap to/collapse at left edge + expand height.......................375
;       →→→ §2.6.1: UpdateVariableAsNeeded.....................................................398
;     >>> §2.7: >^!+#Left — Snap to/expand at left edge........................................411
;       →→→ §2.7.1: IncrementWinDimension......................................................428
;     >>> §2.8: <^!+#Left — Snap to/expand at left edge + expand height........................446
;     >>> §2.9: >^!#Right — Snap window to or collapse at right edge...........................468
;     >>> §2.10: <^!#Right — Snap to/collapse at right edge + expand height....................487
;     >>> §2.11: >^!+#Right — Snap to/expand at right edge.....................................511
;     >>> §2.12: <^!+#Right — Snap to/expand at right edge + expand height.....................530
;     >>> §2.13: >^!#Up — Snap window to or collapse at top edge...............................552
;     >>> §2.14: <^!#Up — Snap to/collapse at top edge + expand height.........................570
;     >>> §2.15: >^!+#Up — Snap to/expand at top edge..........................................592
;     >>> §2.16: <^!+#Up — Snap to/expand at top edge + expand height..........................610
;     >>> §2.17: >^!#Down — Snap window to or collapse at bottom edge..........................631
;     >>> §2.18: <^!#Down — Snap to/collapse at bottom edge + expand height....................649
;     >>> §2.19: >^!+#Down — Snap to/expand at bottom edge.....................................670
;     >>> §2.20: <^!+#Down — Snap to/expand at bottom edge + expand height.....................688
;     >>> §2.21: ^!#Numpad5 — Snap to/collapse at midpoint.....................................709
;     >>> §2.22: ^!#NumpadClear — Snap to/expand at midpoint...................................765
;	  >>> §2.23: ^NumpadX — Keyboard based movement of active windows..........................809
;       →→→ §2.23.1: TranslateActiveWindow(…)..................................................844
;       →→→ §2.23.1: TAW_ChangeDelta().........................................................869
;       →→→ §2.23.1: TAW_ChechkDefaultDelta()..................................................896
;       →→→ §2.23.1: @changeNumpadMovementDelta................................................907
;   §3: VIRTUAL DESKTOP HOTKEYS................................................................915
;     >>> §3.1: ^!1-7 — Movement of windows between virtual desktops...........................919
;       →→→ §3.1.1: ca1thruN_moveToDesktop(…)..................................................962
;   §4: MOUSE HOTKEYS..........................................................................970
;     >>> §4.1: ^!+RButton — Remember/forget mouse coordinates.................................974
;     >>> §4.2: ^!+LButton — Move to remembered mouse coordinates..............................1010
;       →→→ §4.2.1: casLButton_IsMouseAtCurrentCoord...........................................1021
;       →→→ §4.2.2: casLButton_MoveMouseToCurrentCoord.........................................1041
;       →→→ §4.2.3: casLButton_MoveMouseToNextCoord...........................................1070
;     >>> §4.3: ^!#L/RButton — Move mouse to taskbar..........................................1089
;     >>> §4.4: #LButton — Move mouse to center of active window..............................1102
;   §5: AUDITORY CUE BINDING..................................................................1120
;   §6: WINDOW POSITIONING GUIS...............................................................1140
;     >>> §6.1: Window Adjustment GUI.........................................................1144
;       →→→ §6.1.1: TriggerWindowAdjustmentGui................................................1147
;       →→→ §6.1.2: HandleGuiWinAdjWidthSliderChange..........................................1220
;       →→→ §6.1.3: HandleGuiWinAdjOK.........................................................1255
;       →→→ §6.1.4: guiWinAdjGuiEscape........................................................1262
;       →→→ §6.1.5: GuiWinAdjUpdateEdgeSnapping...............................................1269
;       →→→ §6.1.6: GuiWinAdjCheckNewPosition.................................................1289
;   §7: APP SPECIFIC WORKSPACE MANAGEMENT SCRIPTS.............................................1310
;     >>> §7.1: CHROME........................................................................1314
;       →→→ §7.1.1: OpenWebsiteInChrome.......................................................1317
;       →→→ §7.1.2: OpenNewTabInChrome........................................................1338
;       →→→ §7.1.3: OpenNewWindowInChrome.....................................................1350
;       →→→ §7.1.4: NavigateToWebsiteInChrome.................................................1363
;       →→→ §7.1.5: MoveToNextTabInChrome.....................................................1377
;     >>> §7.2: GNU IMAGE MANIPULATION PROGRAM................................................1389
;       →→→ §7.2.1: @toggleGimp...............................................................1392
;     >>> §7.3: NOTEPAD++: TEXT EDITING ENHANCEMENT HOTKEYS & SCRIPTS.........................1436
;     >>> §7.4: STICKY NOTES FOR CHROME.......................................................1508
;       →→→ §7.4.1: @initStickyNoteToggle.....................................................1511
;       →→→ §7.4.2: @toggleStickyNote.........................................................1523
;     >>> §7.5: SUBLIME TEXT 3................................................................1550
;       →→→ §7.5.1: @sst3 (Start Sublime Text 3)..............................................1553
;       →→→ §7.5.2: updateTableOfContents.ahk.................................................1560
;     >>> §7.6: iTunes........................................................................1565
;       →→→ §7.6.1: @restartItunes............................................................1568
;   §8: Diagnostic hotstrings.................................................................1601
;     >>> §8.1: @getActiveMonitorWorkArea.....................................................1605
;     >>> §8.2: @getInfoOnSystemMonitors......................................................1615
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: AUTOMATED DESKTOP SET UP
; --------------------------------------------------------------------------------------------------

#include %A_ScriptDir%\WorkspaceManagement\automatedDesktopSetUp.ahk

; --------------------------------------------------------------------------------------------------
;   §2: WINDOW POSITIONING HOTKEYS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: ^F12 — "Always on top" toggle

^F12::WinSet, AlwaysOnTop, Toggle, A

;   ································································································
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.2.1: caf1thruN_switchToDesktop(…)

caf1thruN_switchToDesktop(whichDesktop) {
	global vdDesktopCount

	if (whichDesktop >= 1 && whichDesktop <= vdDesktopCount) {
		SwitchDesktopByNumber(whichDesktop)
		SoundPlay, %desktopSwitchingSound%		
	}
}

;   ································································································
;     >>> §2.3: ^F6-F11 — Snapped positioning of windows on multiple monitor systems

^F11::
	RemoveMinMaxStateForActiveWin()
	SoundPlay, %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon3WorkArea_Right + (borderWidths.Horz - 1)) - (mon3WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - (widthDecrement * 4 / 3)
	newPosX := mon3WorkArea_Left + (widthDecrement * 4 / 3) - (borderWidths.Horz - 1)
	maxHeight := mon3WorkArea_Bottom + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(4, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

^F10::
	RemoveMinMaxStateForActiveWin()
	SoundPlay, %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon3WorkArea_Right + (borderWidths.Horz - 1)) - (mon3WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - widthDecrement * 4 / 3
	newPosX := mon3WorkArea_Left - borderWidths.Horz + 1
	maxHeight := mon3WorkArea_Bottom + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(1, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

; TODO: Refactor to compensate for window border widths and how they affect positioning
^F9::
	RemoveMinMaxStateForActiveWin()
	SoundPlay, %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon2WorkArea_Right + (borderWidths.Horz - 1)) - (mon2WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - (widthDecrement * 4 / 3)
	newPosX := mon2WorkArea_Left + (widthDecrement * 4 / 3) - (borderWidths.Horz - 1)
	maxHeight := mon2WorkArea_Bottom + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(4, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

^F8::
	RemoveMinMaxStateForActiveWin()
	SoundPlay %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon2WorkArea_Right + (borderWidths.Horz - 1)) - (mon2WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - widthDecrement * 4 / 3
	newPosX := mon2WorkArea_Left - borderWidths.Horz + 1
	maxHeight := mon2WorkArea_Bottom + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(1, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

^F7::
	RemoveMinMaxStateForActiveWin()
	SoundPlay %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon1WorkArea_Right + (borderWidths.Horz - 1)) - (mon1WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - (widthDecrement * 4 / 3)
	newPosX := mon1WorkArea_Left + (widthDecrement * 4 / 3) - (borderWidths.Horz - 1)
	maxHeight := mon1WorkArea_Bottom + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinMove, A, , %newPosX%, 0, %newWidth%, %maxHeight%
	TriggerWindowAdjustmentGui(4, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

^F6::
	RemoveMinMaxStateForActiveWin()
	SoundPlay %windowSizingSound%
	borderWidths := GetActiveWindowBorderWidths()
	maxWidth := (mon1WorkArea_Right + (borderWidths.Horz - 1)) - (mon1WorkArea_Left 
		- (borderWidths.Horz - 1))
	minWidth := Round(maxWidth / 20 * 3)
	widthDecrement := minWidth
	newWidth := maxWidth - widthDecrement * 4 / 3
	newPosX := mon1WorkArea_Left - (borderWidths.Horz - 1)
	maxHeight := mon1WorkArea_Bottom + (borderWidths.Vert - 1)
	minHeight := Round(maxHeight / 20 * 3)
	newHeight := maxHeight
	WinMove, A, , %newPosX%, 0, %newWidth%, %newHeight%
	TriggerWindowAdjustmentGui(1, minWidth, maxWidth, newWidth, minHeight, maxHeight, newHeight)
Return

;   ································································································
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

;   ································································································
;     >>> §2.5: >^!#Left — Snap window to or collapse at left edge

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
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

;   ································································································
;     >>> §2.6: <^!#Left — Snap to/collapse at left edge + expand height

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
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

;   ································································································
;     >>> §2.7: >^!+#Left — Snap to/expand at left edge

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
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

;   ································································································
;     >>> §2.8: <^!+#Left — Snap to/expand at left edge + expand height

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

;   ································································································
;     >>> §2.9: >^!#Right — Snap window to or collapse at right edge

; Snap the active window to the right edge of its monitor; if already snapped, reduce its width.
>^!#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
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

;   ································································································
;     >>> §2.10: <^!#Right — Snap to/collapse at right edge + expand height

; Snap the active window to the right edge of its monitor; if already snapped, reduce its width.
; Additionally, resize the window vertically to fill up the full vertical extent of the monitor's 
; available work area.
<^!#Right::
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	if (monitorFound) {
		WinGetPos, winX, winY, winW, winH, A
		monWidth := monitorARight - monitorALeft
		widthDecrement := Round(monWidth / 20)
		minWidth := Round(monWidth / 20 * 3)
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

;   ································································································
;     >>> §2.11: >^!+#Right — Snap to/expand at right edge

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

;   ································································································
;     >>> §2.12: <^!+#Right — Snap to/expand at right edge + expand height

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

;   ································································································
;     >>> §2.13: >^!#Up — Snap window to or collapse at top edge

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

;   ································································································
;     >>> §2.14: <^!#Up — Snap to/collapse at top edge + expand height


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

;   ································································································
;     >>> §2.15: >^!+#Up — Snap to/expand at top edge

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

;   ································································································
;     >>> §2.16: <^!+#Up — Snap to/expand at top edge + expand height

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

;   ································································································
;     >>> §2.17: >^!#Down — Snap window to or collapse at bottom edge

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

;   ································································································
;     >>> §2.18: <^!#Down — Snap to/collapse at bottom edge + expand height

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

;   ································································································
;     >>> §2.19: >^!+#Down — Snap to/expand at bottom edge

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

;   ································································································
;     >>> §2.20: <^!+#Down — Snap to/expand at bottom edge + expand height

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

;   ································································································
;     >>> §2.21: ^!#Numpad5 — Snap to/collapse at midpoint

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

;   ································································································
;     >>> §2.22: ^!#NumpadClear — Snap to/expand at midpoint

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

;   ································································································
;     >>> §2.23: ^NumpadX — Keyboard based movement of active windows

^Numpad1::
	TranslateActiveWindow(-1, 1)
Return

^Numpad2::
	TranslateActiveWindow(0, 1)
Return

^Numpad3::
	TranslateActiveWindow(1, 1)
Return

^Numpad4::
	TranslateActiveWindow(-1, 0)
Return

^Numpad6::
	TranslateActiveWindow(1, 0)
Return

^Numpad7::
	TranslateActiveWindow(-1, -1)
Return

^Numpad8::
	TranslateActiveWindow(0, -1)
Return

^Numpad9::
	TranslateActiveWindow(1, -1)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.1: TranslateActiveWindow(…)

TranslateActiveWindow(delX, delY) {
	global twMvDelta

	TAW_CheckDefaultDelta()
	WinGetPos xl, yt, w, h, A
	xr := xl + w
	yb := yt + h
	; if ( delX < 0 && xl + delX < leftMostMonWorkAreaCoord ) {
	; 	delX := leftMostMonWorkAreaCoord - xl
	; } else if ( delX > 0 && xr + delX > rightMostMonWorkAreaCoord ) {
	; 	delX := rightMostMonWorkAreaCoord - xr
	; }
	; if ( delY < 0 && yt + delY < topMostMonWorkAreaCoord ) {
	; 	delY := topMostMonWorkAreaCoord - yt
	; } else if ( delY > 0 && yb + delY > bottomMostMonWorkAreaCoord ) {
	; 	delY := bottomMostMonWorkAreaCoord - yb
	; }
	newX := xl + delX * twMvDelta
	newY := yt + delY * twMvDelta
	WinMove A, , %newX%, %newY%
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.2: TAW_ChangeDelta() [TAW = TranslateActiveWindow]

TAW_ChangeDelta() {
	global checkType
	global minMonWorkAreaDim
	global twMvDelta

	TAW_CheckDefaultDelta()
	InputBox newTwMvDelta, % "Numpad-mediated Window Movement", % "Please enter a new value for the"
		. " number of pixels a window should be translated with each keystroke when the numpad is u"
		. "sed to move a window around on the desktop."
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.3: TAW_ChechkDefaultDelta()

TAW_CheckDefaultDelta() {
	global twMvDelta

	if ( !doesVarExist( twMvDelta ) || isVarEmpty( twMvDelta ) ) {
		twMvDelta := 10
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.23.4: @changeNumpadMovementDelta

:*:@changeNumpadMovementDelta::
	AppendAhkCmd( A_ThisLabel )
	TAW_ChangeDelta()
Return

; --------------------------------------------------------------------------------------------------
;   §3: VIRTUAL DESKTOP HOTKEYS
; --------------------------------------------------------------------------------------------------

;   ································································································
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §3.1.1: ca1thruN_moveToDesktop(…)

ca1thruN_moveToDesktop(whichDesktop) {
	MoveActiveWindowToVirtualDesktop(whichDesktop)
	SoundPlay, %windowShiftingSound%
}

; --------------------------------------------------------------------------------------------------
;   §4: MOUSE HOTKEYS
; --------------------------------------------------------------------------------------------------

;   ································································································
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

;   ································································································
;     >>> §4.2: ^!+LButton — Move to remembered mouse coordinates

^!+LButton::
	if (casLButton_IsMouseAtCurrentCoord()) {
		casLButton_MoveMouseToNextCoord()
	} else {
		casLButton_MoveMouseToCurrentCoord()
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.1: casLButton_IsMouseAtCurrentCoord

casLButton_IsMouseAtCurrentCoord() {
	global savedMouseCoords

	atCurrentCoord := False
	if (savedMouseCoords != undefined) {
		coords := savedMouseCoords.array[savedMouseCoords.idx]
		mouseX := coords.x
		mouseY := coords.y
		CoordMode, Mouse, Screen
		MouseGetPos, actualMouseX, actualMouseY
		atCurrentCoord := ( Abs( actualMouseX - mouseX ) <= 4 )
			&& ( Abs( actualMouseY - mouseY ) <= 4 )
	}

	return atCurrentCoord
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.2: casLButton_MoveMouseToCurrentCoord

casLButton_MoveMouseToCurrentCoord() {
	global savedMouseCoords

	if (savedMouseCoords != undefined) {
		; Automatically save the mouse's current position to the end of the remembered coordinate
		; array so this initial position can be restored later.
		; if (savedMouseCoords.curCoordSaved) {
		; 	if (savedMouseCoords.idx == savedMouseCoords.)
		; 	(savedMouseCoords.array).Pop()
		; }
		; CoordMode, Mouse, Screen
		; MouseGetPos, mouseX, mouseY
		; (savedMouseCoords.array).Push({x: mouseX, y: mouseY})
		; if (!(savedMouseCoords.curCoordSaved)) {
		; 	savedMouseCoords.curCoordSaved := true
		; }

		; Move the cursor to the active mouse coordinate in the remembered coordinate array.
		coords := savedMouseCoords.array[savedMouseCoords.idx]
		mouseX := coords.x
		mouseY := coords.y
		CoordMode, Mouse, Screen
		MouseMove, %mouseX%, %mouseY%
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.3: casLButton_MoveMouseToNextCoord

casLButton_MoveMouseToNextCoord() {
	global savedMouseCoords

	if (savedMouseCoords != undefined) {
		savedMouseCoords.idx--
		if (savedMouseCoords.idx < 1) {
			savedMouseCoords.idx := savedMouseCoords.array.Length()
		}
		coords := savedMouseCoords.array[savedMouseCoords.idx]
		mouseX := coords.x
		mouseY := coords.y
		CoordMode, Mouse, Screen
		MouseMove, %mouseX%, %mouseY%
	}
}

;   ································································································
;     >>> §4.3: ^!#L/RButton — Move mouse to taskbar

^!#LButton::
	CoordMode, Mouse, Screen
	MouseMove, -1568, 1065
Return

^!#RButton::
	CoordMode, Mouse, Screen
	MouseMove, 351, 1065
Return

;   ································································································
;     >>> §4.4: #LButton — Move mouse to center of active window

#LButton::
	CoordMode, Mouse, Window
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	Sleep 20
	MouseMove, % (thisWinW / 2), % (thisWinH / 2)
Return

^#LButton::
!SC029::
	CoordMode, Mouse, Window
	WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
	Sleep 20
	MouseMove, % (thisWinW / 7), % (thisWinH / 2)
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

;   ································································································
;     >>> §6.1: Window Adjustment GUI

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
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
TriggerWindowAdjustmentGui(edgeSnapping, minWidth, maxWidth, initialWidth, minHeight, maxHeight
		, initialHeight) {
	global
	local whichHwnd
	local sliderPos := (initialWidth - minWidth) / (maxWidth - minWidth) * 100
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
	GetActiveMonitorWorkArea(aMonId, aMonLeft, aMonTop, aMonRight, aMonBottom)

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
	Gui, guiWinAdj: Add, Text, , Window &width:
	Gui, guiWinAdj: Add, Slider
		, vguiWinAdjWidthSlider gHandleGuiWinAdjWidthSliderChange AltSubmit W300 x+5
		, %sliderPos%
	Gui, guiWinAdj: Add, Text, xm, Horizontal snapping:
	Gui, guiWinAdj: Add, Radio, vguiWinAdjXSnapOpts x+5 Checked%xSnapOptL%, &Left
	Gui, guiWinAdj: Add, Radio, x+5 Checked%xSnapOptC%, &Center
	Gui, guiWinAdj: Add, Radio, x+5 Checked%xSnapOptR%, &Right	
	Gui, guiWinAdj: Add, Button, Default gHandleGuiWinAdjOK xm y+15, &OK
	Gui, guiWinAdj: Show

	; GUI always loads on primary monitor; switch to different monitor if appropriate
	if (aMonLeft != 0) {
		WinGet, guiHwnd, ID, A
		WinGetPos, posX, posY, posW, posH, ahk_id %guiHwnd%
		posX := aMonLeft + posX
		WinMove, ahk_id %guiHwnd%, , %posX%, %posY%, %posW%, %posH%
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.2: HandleGuiWinAdjWidthSliderChange

HandleGuiWinAdjWidthSliderChange() {
	global guiWinAdjVars
	global guiWinAdjWidthSlider
	global guiWinAdjXSnapOpts

	; Add test to ensure window still exists.
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
	} else {
		MsgBox, % "The window you were adjusting has closed; GUI will now exit."
		Gui, guiWinAdj: Destroy
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.3: HandleGuiWinAdjOK

HandleGuiWinAdjOK() {
	Gui, guiWinAdj: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.4: guiWinAdjGuiEscape

guiWinAdjGuiEscape() {
	Gui, guiWinAdj: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.5: GuiWinAdjUpdateEdgeSnapping

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.6: GuiWinAdjCheckNewPosition

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

;   ································································································
;     >>> §7.1: CHROME

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.1: OpenWebsiteInChrome

OpenWebsiteInChrome(website, inNewTab := True) {
	delay := GetDelay("short")
	website .= "{Enter}"
	attemptCount := 0
	WinGet procName, ProcessName, A
	while (procName != "chrome.exe" && attemptCount <= 8) {
		Sleep % delay * 2.5
		WinActivate % "ahk_exe chrome.exe"
		Sleep %delay%
		WinGet procName, ProcessName, A
		attemptCount++
	}
	if (inNewTab) {
		OpenNewTabInChrome()
	}
	NavigateToWebsiteInChrome(website)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.2: OpenNewTabInChrome

OpenNewTabInChrome() {
	delay := GetDelay("short")
	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput, ^t
		Sleep, %delay%
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.3: OpenNewWindowInChrome

OpenNewWindowInChrome() {
	global execDelayer

	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput, ^n
		execDelayer.Wait( "m" )
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.4: NavigateToWebsiteInChrome

NavigateToWebsiteInChrome(website) {
	delay := GetDelay("short")
	WinGet, procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput, !d
		Sleep, %delay%
		SendInput, % website
		Sleep, % delay * 3
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.5: MoveToNextTabInChrome

MoveToNextTabInChrome() {
	delay := GetDelay("short")
	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput ^{Tab}
		Sleep %delay%
	}
}

;   ································································································
;     >>> §7.2: GNU IMAGE MANIPULATION PROGRAM

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.1: @toggleGimp

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

;   ································································································
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

;   ································································································
;     >>> §7.4: STICKY NOTES FOR CHROME

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.1: @initStickyNoteToggle

:*:@initStickyNoteToggle::
	global hwndStickyNoteWindow
	ahkCmdName := ":*:@initStickyNoteToggle"
	AppendAhkCmd(ahkCmdName)
	WinGet, hwndStickyNoteWindow, ID, A
	MsgBox, 0, % ":*:@initStickyNoteSwitcher", % "Sticky note window with HWND " 
		. hwndStickyNoteWindow . " can now be toggled via the hotstring @toggleStickyNote."
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.2: @toggleStickyNote

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

;   ································································································
;     >>> §7.5: SUBLIME TEXT 3

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.1: @sst3

:*:@sst3::
	SendInput, % "start sublime_text.exe "
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.2: updateTableOfContents.ahk

#Include %A_ScriptDir%\WorkspaceManagement\updateTableOfContents.ahk

;   ································································································
;     >>> §7.6: iTunes

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.1: @restartItunes

:*:@restartItunes::
	delay := GetDelay("long")
	winTitle := "iTunes ahk_exe iTunes.exe"
	iTunesHwnd := WinExist(winTitle)
	if (iTunesHwnd) {
		aHwnd := WinExist("A")
		if (aHwnd == iTunesHwnd) {
			aHwnd := 0
		}
		WinActivate % winTitle
		WinWaitActive %winTitle%, , 7
		proceed := !ErrorLevel
		if (proceed) {
			WinClose %winTitle%
			WinWaitClose %winTitle%, , 7
			proceed := !ErrorLevel
		}
		if (proceed) {
			Sleep % delay
			LaunchStdApplicationPatiently("shell:appsFolder\AppleInc.iTunes_nzyj5cx40ttqa!iTunes"
				, "iTunes")
			WinWaitActive %winTitle%, , 10
			proceed := !ErrorLevel
		}
		if (proceed && aHwnd) {
			WinActivate % "ahk_id " . aHwnd
		}
	}
Return

; --------------------------------------------------------------------------------------------------
;   §8: Diagnostic hotstrings
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §8.1: @getActiveMonitorWorkArea

:*:@getActiveMonitorWorkArea::
	GetActiveMonitorWorkArea(aMon, aMon_Left, aMon_Top, aMon_Right, aMon_Bottom)
	MsgBox, % "Work area of monitor #" . aMon . ":`r"
		. "Upper left: " . aMon_Left . ", " . aMon_Top . "`r"
		. "Lower right: " . aMon_Right . ", " . aMon_Bottom
Return

;   ································································································
;     >>> §8.2: @getInfoOnSystemMonitors

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
