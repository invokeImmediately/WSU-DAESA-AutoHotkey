; ==================================================================================================
; monitorWorkAreas.ahk
; ==================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents:
; -----------------
;   §1: AddWinBordersToMonitorWorkArea(…).......................................................20
;   §2: ClipActiveWindowToMonitor().............................................................36
;   §3: FindActiveMonitor().....................................................................69
;   §4: FindNearestActiveMonitor()..............................................................94
;   §5: GetActiveMonitorWorkArea(…)............................................................129
;   §6: RemoveWinBorderFromRectCoordinate......................................................171
;   §7: ResolveActiveMonitorWorkArea...........................................................211
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: AddWinBordersToMonitorWorkArea(…)
; --------------------------------------------------------------------------------------------------

; Adjust the work area of the monitor the active window is occupying by compensating for the width
; of the active window's borders. The intended effect of this compensation is restriction of the
; active window's client rectangle to the monitor's work area.
AddWinBordersToMonitorWorkArea(ByRef monitorWaLeft, ByRef monitorWaTop, ByRef monitorWaRight
		, ByRef monitorWaBottom) {
	borderWidth := GetActiveWindowBorderWidths()
	monitorWaLeft -= (borderWidth.Horz - 1)
	monitorWaTop -= (borderWidth.Vert - 1)
	monitorWaRight += (borderWidth.Horz - 1)
	monitorWaBottom += (borderWidth.Vert - 1)
}

; --------------------------------------------------------------------------------------------------
;   §2: ClipActiveWindowToMonitor()
; --------------------------------------------------------------------------------------------------

ClipActiveWindowToMonitor() {
	GetActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight, monitorABottom)
	WinGetPos, x, y, w, h, A
	; Set up clipping of the horizontal dimensions of the window.
	if (x >= monitorALeft && x + w > monitorARight) {
		w := monitorARight - x
	} else if (x < monitorALeft && x + w > monitorALeft && x + w <= monitorARight) {
		w := x + w - monitorALeft
		x := monitorALeft
	} else if (x < monitorALeft && x + w > monitorALeft && x + w > monitorARight) {
		x := monitorALeft
		w := monitorARight - x
	}

	; Now set up clipping of the vertical dimensions.
	if (y >= monitorATop && y + h > monitorABottom) {
		h := monitorABottom - y
	} else if (y < monitorATop && y + h > monitorATop && y + h <= monitorABottom) {
		h := y + h - monitorATop
		y := monitorATop
	} else if (y < monitorATop && y + h > monitorATop && y + h > monitorABottom) {
		y := monitorATop
		h := monitorABottom - y
	}

	; Perform clipping
	WinMove, A, , x, y, w, h
}

:*:@clipActiveWindowToMonitor::
	AppendAhkCmd(A_ThisLabel)
	ClipActiveWindowToMonitor()
Return

; --------------------------------------------------------------------------------------------------
;   §3: FindActiveMonitor()
; --------------------------------------------------------------------------------------------------

FindActiveMonitor() {
	global
	local whichMon := 0
	local x
	local y
	local w
	local h

	WinGetPos, x, y, w, h, A
	RemoveWinBorderFromRectCoordinate(0, x, y)
	Loop, %sysNumMonitors% {
		if (x >= mon%A_Index%Bounds_Left && y >= mon%A_Index%Bounds_Top
				&& x < mon%A_Index%Bounds_Right && y < mon%A_Index%Bounds_Bottom) {
			whichMon := A_Index
			break
		}
	}

	return whichMon
}

:*:@findActiveMonitor::
	AppendAhkCmd(A_ThisLabel)
	whichMon := FindActiveMonitor()
	if (whichMon == 0) {
		MsgBox % "Could not find the active window's monitor; window probably lies outside of the w"
. "ork area of all monitors."
	} else {
		MsgBox % "The active window is located on monitor " . whichMon
	}
Return

; --------------------------------------------------------------------------------------------------
;   §4: FindNearestActiveMonitor()
; --------------------------------------------------------------------------------------------------

FindNearestActiveMonitor() {
	global
	local minDistance := -1
	local winMidpt := {}
	local monMidpt := {}
	local x
	local y
	local w
	local h
	local distance
	local correctMon

	WinGetPos, x, y, w, h, A
	RemoveWinBorderFromRectCoordinate(0, x, y)
	winMidpt.x := x + w / 2
	winMidpt.y := x + h / 2
	Loop, %sysNumMonitors% {
		monMidpt.x := mon%A_Index%Bounds_Left + (mon%A_Index%Bounds_Right 
			- mon%A_Index%Bounds_Left) / 2		
		monMidpt.y := mon%A_Index%Bounds_Top + (mon%A_Index%Bounds_Bottom
			- mon%A_Index%Bounds_Top)	/ 2
		distance := Sqrt((monMidpt.x - winMidpt.x)**2 + (monMidpt.y - winMidpt.y)**2)
		if (minDistance = -1 || distance < minDistance) {
			minDistance := distance
			correctMon := A_Index
		}
	}

	return correctMon
}

:*:@findNearestActiveMonitor::
	AppendAhkCmd(A_ThisLabel)
	whichMon := FindNearestActiveMonitor()
	MsgBox % "The active window is located on monitor " . whichMon
Return

; --------------------------------------------------------------------------------------------------
;   §5: GetActiveMonitorWorkArea(…)
; --------------------------------------------------------------------------------------------------

GetActiveMonitorWorkArea(ByRef monitorFound, ByRef monitorALeft, ByRef monitorATop
		, ByRef monitorARight, ByRef monitorABottom) {
	global
	local whichMon
	local winCoords
	local x
	local y
	local w
	local h
	local whichVertex

	monitorFound := false
	RemoveMinMaxStateForActiveWin()
	whichMon := FindNearestActiveMonitor()
	if (whichMon > 0) {
		monitorFound := true
		monitorALeft := mon%whichMon%WorkArea_Left
		monitorATop := mon%whichMon%WorkArea_Top
		monitorARight := mon%whichMon%WorkArea_Right
		monitorABottom := mon%whichMon%WorkArea_Bottom
	}

	if (monitorFound = false) {
		winCoords := {}
		WinGetPos, x, y, w, h, A
		whichVertex := 0
		RemoveWinBorderFromRectCoordinate(whichVertex, x, y)
		winCoords.x := x
		winCoords.y := y
		winCoords.w := w
		winCoords.h := h
		ResolveActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight
			, monitorABottom, winCoords)
	} else {
		AddWinBordersToMonitorWorkArea(monitorALeft, monitorATop, monitorARight, monitorABottom)
	}
}

; --------------------------------------------------------------------------------------------------
;   §6: RemoveWinBorderFromRectCoordinate(…)
; --------------------------------------------------------------------------------------------------

; Remove the width of a window's border from one of its outer rectangle coordinates. This has the 
; effect of transforming an outer rectangle coordinate into a client rectangle coordinate.
;
; Additional Notes on arguments:
; ------------------------------------------------------
;    Value of whichVertex  |  Interpretation
; ------------------------------------------------------
;    0                        Top-left window vertex
;    1                        Top-right
;    2                        Bottom-left
;    3                        Bottom-right
;    Anything else            Leave coordinate unchanged
RemoveWinBorderFromRectCoordinate(whichVertex, ByRef coordX, ByRef coordY) {
	WinGet, hwnd, ID, A
	winInfo := API_GetWindowInfo(hwnd)
	borderWidth := {}
	if (whichVertex = 0) {
		borderWidth.Horz := abs(winInfo.Window.Left - winInfo.Client.Left)
		borderWidth.Vert := abs(winInfo.Window.Top - winInfo.Client.Top)
	} else if (whichVertex = 1) {
		borderWidth.Horz := -1 * abs(winInfo.Window.Right - winInfo.Client.Right)
		borderWidth.Vert := abs(winInfo.Window.Top - winInfo.Client.Top)
	} else if (whichVertex = 2) {
		borderWidth.Horz := abs(winInfo.Window.Left - winInfo.Client.Left)
		borderWidth.Vert := -1 * abs(winInfo.Window.Bottom - winInfo.Client.Bottom)
	} else if (whichVertex = 3) { ; Assume bottom-right vertex
		borderWidth.Horz := -1 * abs(winInfo.Window.Right - winInfo.Client.Right)
		borderWidth.Vert := -1 * abs(winInfo.Window.Bottom - winInfo.Client.Bottom)
	} else {
		borderWidth.Horz := 0
		borderWidth.Vert := 0
	}
	coordX += borderWidth.Horz
	coordY += borderWidth.Vert
}

; --------------------------------------------------------------------------------------------------
;   §7: ResolveActiveMonitorWorkArea(…)
; --------------------------------------------------------------------------------------------------

; Notes on arguments:
; -------------------
; winCoords = object with properties x, y, w, and h that have been set by call to WinGetPos
ResolveActiveMonitorWorkArea(ByRef monitorFound, ByRef monitorALeft, ByRef monitorATop
		, ByRef monitorARight, ByRef monitorABottom, winCoords) {
	global
	local distance
	local minDistance := -1
	local correctMon := 0
	local winMidpt := {}
	local monMidpt := {}
	winMidpt.x := winCoords.x + winCoords.w / 2
	winMidpt.y := winCoords.x + winCoords.h / 2
	Loop, %sysNumMonitors% {
		monMidpt.x := mon%A_Index%Bounds_Left + (mon%A_Index%Bounds_Right 
			- mon%A_Index%Bounds_Left) / 2		
		monMidpt.y := mon%A_Index%Bounds_Top + (mon%A_Index%Bounds_Bottom
			- mon%A_Index%Bounds_Top)	/ 2
		distance := Sqrt((monMidpt.x - winMidpt.x)**2 + (monMidpt.y - winMidpt.y)**2)
		if (minDistance = -1 || distance < minDistance) {
			minDistance := distance
			correctMon := A_Index
		}
	}
	monitorFound := true
	monitorALeft := mon%correctMon%WorkArea_Left
	monitorATop := mon%correctMon%WorkArea_Top
	monitorARight := mon%correctMon%WorkArea_Right
	monitorABottom := mon%correctMon%WorkArea_Bottom
	AddWinBordersToMonitorWorkArea(monitorALeft, monitorATop, monitorARight, monitorABottom)
}

