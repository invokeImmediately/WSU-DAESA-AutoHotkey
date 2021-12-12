; ==================================================================================================
; ▐▀▄▀▌▄▀▀▄ ▐▀▀▄ ▀█▀▐▀█▀▌▄▀▀▄ █▀▀▄ ▐   ▌▄▀▀▄ █▀▀▄ █ ▄▀ ▄▀▀▄ █▀▀▄ █▀▀▀ ▄▀▀▄ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀ ▌█  █ █  ▐  █   █  █  █ █▄▄▀ ▐ █ ▌█  █ █▄▄▀ █▀▄  █▄▄█ █▄▄▀ █▀▀  █▄▄█ ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
; █   ▀ ▀▀  ▀  ▐ ▀▀▀  █   ▀▀  ▀  ▀▄ ▀ ▀  ▀▀  ▀  ▀▄▀  ▀▄█  ▀ ▀  ▀▄▀▀▀▀ █  ▀ ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Functions for obtaining a system monitor's work area under a variety of contexts.
;
; @version 1.0.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/Functions/monitorWorkAre
;   as.ahk
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
; Table of Contents:
; -----------------
;   §1: AddWinBordersToMonitorWorkArea(…).......................................................40
;   §2: ClipActiveWindowToMonitor().............................................................56
;   §3: FindActiveMonitor().....................................................................94
;   §4: FindMonitorMouseIsOn().................................................................130
;   §5: FindNearestActiveMonitor().............................................................159
;   §6: GetActiveMonitorWorkArea(…)............................................................201
;   §7: GetActiveMonitorResolution()...........................................................094
;   §8: RemoveWinBorderFromRectCoordinate......................................................244
;   §9: ResolveActiveMonitorWorkArea...........................................................284
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

:*?:@clipActiveWindowToMonitor::
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

:*?:@findActiveMonitor::
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
;   §4: FindMonitorMouseIsOn()
; --------------------------------------------------------------------------------------------------

FindMonitorMouseIsOn() {
	global
	local minDistance := -1
	local monMidpt := {}
	local mouseX
	local mouseY
	local distance
	local correctMon
	CoordMode, Mouse, Screen
	MouseGetPos, mouseX, mouseY
	RemoveWinBorderFromRectCoordinate(0, x, y)
	Loop, %sysNumMonitors% {
		monMidpt.x := mon%A_Index%Bounds_Left + (mon%A_Index%Bounds_Right 
			- mon%A_Index%Bounds_Left) / 2		
		monMidpt.y := mon%A_Index%Bounds_Top + (mon%A_Index%Bounds_Bottom
			- mon%A_Index%Bounds_Top)	/ 2
		distance := Sqrt( ( monMidpt.x - mouseX ) ** 2 + ( monMidpt.y - mouseY ) ** 2 )
		if ( minDistance = -1 || distance < minDistance ) {
			minDistance := distance
			correctMon := A_Index
		}
	}
	return correctMon
}

; --------------------------------------------------------------------------------------------------
;   §5: FindNearestActiveMonitor()
; --------------------------------------------------------------------------------------------------

; Find the currently "active" monitor based on where the active window is positioned.
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
	winMidpt.y := y + h / 2
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

:*?:@findNearestActiveMonitor::
	AppendAhkCmd(A_ThisLabel)
	whichMon := FindNearestActiveMonitor()
	MsgBox % "The active window is located on monitor " . whichMon
Return

; --------------------------------------------------------------------------------------------------
;   §6: GetActiveMonitorWorkArea(…)
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

	; First, see if we can find the nearest active monitor.
	whichMon := FindNearestActiveMonitor()
	if ( whichMon > 0 ) {
		monitorFound := whichMon
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
;   §7: GetActiveMonitorResolution
; --------------------------------------------------------------------------------------------------

GetActiveMonitorResolution() {
	resolution := {}
	VarSetCapacity(devMod, 156, 0)
	NumPut(156, devMod, 36)
	DllCall( "EnumDisplaySettingsA", UInt, 0, UInt, -1, UInt, &devMod )
	resolution.W := NumGet(devMod, 108, "UInt")
	resolution.H := NumGet(devMod, 112, "UInt")
	Return resolution
}

:*?:@getActiveMonitorResolution::
	AppendAhkCmd( A_ThisLabel )
	resolution := GetActiveMonitorResolution()
	MsgBox % "Resolution of active monitor '" . resolution.MonName . "'' = "
		. resolution.W "px by " . resolution.H . "px"
Return

GetMonitorResolution( whichMon ) {
	global sysNumMonitors
	resolution := {}

	; Handle potential edge case where a nonsensical monitor number was provided.
	if ( whichMon < 0 || whichMon > sysNumMonitors - 1 ) {
		resolution.MonName := "Error: Monitor not found"
		resolution.W := 0
		resolution.H := 0
		return resolution
	}

	; First, obtain the device name of the requested monitor.
	VarSetCapacity( dispDev, 424, 0 )
	NumPut( 424, dispDev, 0 )
	DllCall( "EnumDisplayDevicesA", Ptr, 0, UInt, whichMon, UInt, &dispDev, UInt, 1 )
	monDevName := ""
	VarSetCapacity( dispName, 32, 0 )
	Loop 32 {
		NumPut(NumGet( dispDev, 4 + A_Index - 1, "Char"), dispName, A_Index - 1 )
		monDevName .= Chr( NumGet( dispDev, 4 + A_Index - 1, "Char" ) )
		resolution.MonName := monDevName
	}

	; Use the device name of the requested monitor to obtain its resolution.
	VarSetCapacity(devMod, 156, 0)
	NumPut(156, devMod, 36)
	DllCall( "EnumDisplaySettingsA", Ptr, dispName, UInt, -1, UInt, &devMod )
	resolution.W := NumGet(devMod, 108, "UInt")
	resolution.H := NumGet(devMod, 112, "UInt")

	Return resolution
}

:*?:@getMonitorResolutions::
	AppendAhkCmd( A_ThisLabel )
	whichMon := 0
	resolution := GetMonitorResolution(0)
	MsgBox % "Resolution of monitor '" . resolution.MonName . "' = " . resolution.W . "px by "
		. resolution.H . "px"
Return

; --------------------------------------------------------------------------------------------------
;   §8: RemoveWinBorderFromRectCoordinate(…)
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
;   §9: ResolveActiveMonitorWorkArea(…)
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
	monitorFound := correctMon
	monitorALeft := mon%correctMon%WorkArea_Left
	monitorATop := mon%correctMon%WorkArea_Top
	monitorARight := mon%correctMon%WorkArea_Right
	monitorABottom := mon%correctMon%WorkArea_Bottom
	AddWinBordersToMonitorWorkArea(monitorALeft, monitorATop, monitorARight, monitorABottom)
}
