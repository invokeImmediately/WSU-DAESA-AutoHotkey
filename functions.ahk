; ==================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ==================================================================================================
; IMPORT DEPENDENCIES
;   This file has no import dependencies.
; ==================================================================================================
; IMPORT ASSUMPTIONS
;   This file makes no import assumptions.
; ==================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
; General FUNCTIONS used for multiple purposes
; --------------------------------------------------------------------------------------------------

isTargetProcessActive(targetProcess, caller := "", notActiveErrMsg := "") {
	WinGet, thisWin, ProcessName, A
	targetProcessIsActive := thisWin = targetProcess
	if (!targetProcessIsActive && caller != "" && notActiveErrMsg != "") {
		ErrorBox(caller, notActiveErrMsg)
	}
	return targetProcessIsActive
}

areTargetProcessesActive(targetProcesses, caller := "", notActiveErrMsg := "") {
	WinGet, thisWin, ProcessName, A
	numPossibleProcesses := targetProcesses.Length()
	activeProcessIndex := 0
	activeProcessName := ""
	Loop, %numPossibleProcesses%
	{
		if (thisWin = targetProcesses[A_Index]) {
			activeProcessIndex := A_Index
			Break
		}
	}
	if (!activeProcessIndex && caller != "" && notActiveErrMsg != "") {
		ErrorBox(caller, notActiveErrMsg)
	} else {
		activeProcessName := targetProcesses[activeProcessIndex]
	}
	return activeProcessName
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

doesVarExist(ByRef v) { ; Requires 1.0.46+ 
	return &v = &undeclared ? 0 : 1 
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

isVarEmpty(ByRef v) { ; Requires 1.0.46+ 
	return v = "" ? 1 : 0 
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

isVarDeclared(ByRef v) { ; Requires 1.0.46+ 
	return &v = &undeclared ? 0 : v = "" ? 0 : 1
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

ErrorBox(whichFunc, errorMsg) {
	MsgBox, % 0x10, % "Error in " . whichFunc, % errorMsg
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

InsertFilePath(ahkCmdName, filePath, headerStr:="") {
	global lineLength
	AppendAhkCmd(ahkCmdName)
	if (UserFolderIsSet()) {
		if (IsGitShellActive()) {
			if (headerStr != "" && StrLen(headerStr) <= 108 && lineLength != undefined) {
				leftLength := Floor(lineLength / 2) - Floor(StrLen(headerStr) / 2)
				fullHeader := "write-host '``n"
				Loop, %leftLength% {
					fullHeader .= "-"
				}
				fullHeader .= headerStr
				rightLength := lineLength - leftLength - StrLen(headerStr)
				Loop, %rightLength% {
					fullHeader .= "-"
				}
				fullHeader .= "' -foreground 'green'{Enter}"
				SendInput, % fullHeader
			}
			SendInput, % "cd '" . filePath . "'{Enter}"
		} else {
			SendInput, % filePath . "{Enter}"
		}
	}
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

LaunchApplicationPatiently(path, title, matchMode := 2)
{
	oldMatchMode := 0
	if (A_TitleMatchMode != matchMode) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode, % matchMode
	}
	Run % path
	isReady := false
	while !isReady
	{
		IfWinExist, % title
		{
			isReady := true
			Sleep, 500
		}
		else
		{
			Sleep, 250
		}
	}
	if (oldMatchMode) {
		SetTitleMatchMode, % oldMatchMode
	}
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

LaunchStdApplicationPatiently(path, title, matchMode := 2)
{
	oldMatchMode := 0
	if (A_TitleMatchMode != matchMode) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode, % matchMode
	}
	Run, % "explorer.exe """ . path . """"
	isReady := false
	while !isReady
	{
		IfWinExist, % title
		{
			isReady := true
			Sleep, 500
		}
		else
		{
			Sleep, 250
		}
	}
	if (oldMatchMode) {
		SetTitleMatchMode, % oldMatchMode
	}
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

MoveCursorIntoActiveWindow(ByRef curPosX, ByRef curPosY)
{
	WinGetPos, winPosX, winPosY, winW, winH, A
	if (curPosX < 0) {
		curPosX := 50
	} else if(curPosX > winW - 100) {
		curPosX := winW - 100
	}
	if (curPosY < 0) {
		curPosY := 100
	} else if(curPosY > winH - 100) {
		curPosY := winH - 100
	}
}

GetCursorCoordsToCenterInActiveWindow(ByRef newPosX, ByRef newPosY)
{
	WinGetPos, winPosX, winPosY, winW, winH, A
	newPosX := winW / 2
	newPosY := winH / 2
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

PasteText(txtToPaste) {
	if (clipboard != txtToPaste) {
		clipboard := txtToPaste
	}
	Sleep, 60
	SendInput, % "^v"
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

; TODO: Apply to all functions where appropriate
ChangeMatchMode(newMatchMode) {
	; TODO: refactor for improved safety
	oldMatchMode := 0
	if (A_TitleMatchMode != newMatchMode) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode, % newMatchMode
	}	
	return oldMatchMode
}

RestoreMatchMode(oldMatchMode) {
	; TODO: refactor for improved safety
	if (oldMatchMode) {
		SetTitleMatchMode, % oldMatchMode
	}	
}

SafeWinActivate(titleToMatch, matchMode := 2, waitTime := 5) {
	success = false
	oldMatchMode := ChangeMatchMode(matchMode)

	WinActivate, % titleToMatch
	if(!WinActive(titleToMatch)) {
		WinWaitActive, % titleToMatch, waitTime
		success := WinActive(titleToMatch)
	}

	RestoreMatchMode(oldMatchMode)

	if (!success) {
		FallbackWinActivate(titleToMatch, matchMode)
	}
}

FallbackWinActivate(titleToMatch, matchMode := 2) {
	oldMatchMode := ChangeMatchMode(matchMode)

	WinGet, hWnd, ID, % titleToMatch
	if (hWnd) {
		DllCall("SetForegroundWindow", UInt, hWnd)
	}

	RestoreMatchMode(oldMatchMode)
}

WaitForApplicationPatiently(title)
{
	delay := 250
	isReady := false
	while !isReady
	{
		IfWinExist, % title
		{
			isReady := true
			Sleep, % delay * 2
		}
		else
		{
			Sleep, % delay
		}
	}
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

WriteCodeToFile(hsCaller, srcCode, srcFileToOverwrite) {
	errorMsg := ""
	if (UserFolderIsSet()) {
		srcFile := FileOpen(srcFileToOverwrite, "w")
		if (srcFile != 0) {
			srcFile.Write(srcCode)
			srcFile.Close()
			Sleep 100
		} else {
			errorMsg := "Failed to open file: " . srcFileToOverwrite
		}
	} else {
		errorMsg := "User folder is not set."
	}
	if (errorMsg != "") {
		MsgBox, % (0x0 + 0x10)
			, % "Error in " . hsCaller . " Function Call: WriteCodeToFile(...)"
			, % errorMsg
	}
}

; --------------------------------------------------------------------------------------------------
; SORTING functions
; --------------------------------------------------------------------------------------------------

InsertionSort(ByRef arrayObj, l, r) {
	i := r
	while (i > l) {
		if (arrayObj[i] < arrayObj[i - 1]) {
			objCopy := arrayObj[i]
			arrayObj[i] := arrayObj[i - 1]
			arrayObj[i - 1] := objCopy
		}
		i--
	}
	i := l + 2
	while (i <= r) {
		j := i
		objItem := arrayObj[i]
		while (objItem < arrayObj[j - 1]) {
			arrayObj[j] := arrayObj[j - 1]
			j--
		}
		arrayObj[j] := objItem
		i++
	}
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

MergeSort(ByRef arrayObj, l, r) {
	if (r > l) {
		if (r - l <= 10) {
			InsertionSort(arrayObj, l, r)
		} else {
			m := floor((r + l) / 2)
			MergeSort(arrayObj, l, m)
			MergeSort(arrayObj, m + 1, r)
			Merge(arrayObj, l, m, r)
		}
	}
}

Merge(ByRef arrayObj, l, m, r) {
	arrayAux := Object()
	i := m + 1
	while (i > l) {
		arrayAux[i - 1] := arrayObj[i - 1]
		i--
	}
	j := m
	while (j < r) {
		arrayAux[r + m - j] := arrayObj[j + 1]
		j++
	}
	k := l
	while (k <= r) {
		if (arrayAux[j] < arrayAux[i]) {
			arrayObj[k] := arrayAux[j--]
		} else {
			arrayObj[k] := arrayAux[i++]
		}
		k++
	}
}

; --------------------------------------------------------------------------------------------------
; UTILITY FUNCTIONS: For working with AutoHotkey
; --------------------------------------------------------------------------------------------------

:*:@checkIsUnicode::
	AppendAhkCmd(":*:@checkIsUnicode")
	Msgbox % "v" . A_AhkVersion . " " . (A_PtrSize = 4 ? 32 : 64) . "-bit " 
		. (A_IsUnicode ? "Unicode" : "ANSI") . " " . (A_IsAdmin ? "(Admin mode)" : "(Not Admin)")
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getCurrentVersion::
	MsgBox % "Current installed version of AHK: " . A_AhkVersion
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getLastHotStrTime::
	MsgBox % "The last hotstring took " . (hotStrEndTime - hotStrStartTime) . "ms to run."
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getMousePos::
	AppendAhkCmd(":*:@getMousePos")
	MouseGetPos, windowMousePosX, windowMousePosY
	MsgBox % "The mouse cursor is at {x = " . windowMousePosX . ", y = " . windowMousePosY 
		. "} relative to the window."
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getWinHwnd::
	AppendAhkCmd(":*:@getWinHwnd")
	WinGet, thisHwnd, ID, A
	MsgBox, % "The active window ID (HWND) is " . thisHwnd
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getWinPID::
	AppendAhkCmd(":*:@getWinPID")
	WinGet, thisPID, PID, A
	MsgBox, % "The active window PID is " . thisPID
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getWinPos::
	AppendAhkCmd(":*:@getWinPos")
	WinGetPos, thisX, thisY, thisW, thisH, A
	MsgBox, % "The active window is at coordinates " . thisX . ", " . thisY . "`rWindow's width = " 
		. thisW . ", height = " . thisH
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getWinStyle::
	AppendAhkCmd(A_ThisLabel)
	WinGet, hexStyle, Style, A
	hasThickBorder := (hexStyle & 0x40000) != 0
	MsgBox, % "The active window's styles = " . hexStyle
Return

:*:@getWinExStyle::
	AppendAhkCmd(A_ThisLabel)
	WinGet, hexExStyle, ExStyle, A
	;hasThickBorder := (hexStyle & 0x40000) != 0
	MsgBox, % "The active window's extended styles = " . hexExStyle
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getWinInfo::
	AppendAhkCmd(A_ThisLabel)
	WinGet, hwnd, ID, A
	winInfo := API_GetWindowInfo(hwnd)
	if(!IsObject(winInfo)) {
		MsgBox, 0, WINDOWINFO, ERROR - ErrorLevel: %ErrorLevel%
	} else {
		MsgBox, % "Window Rect = " . winInfo.Window.Left . ", " . winInfo.Window.Top . ", "
			. winInfo.Window.Right . ", " . winInfo.Window.Bottom . "`nClient Rect = " 
			. winInfo.Client.Left . ", " . winInfo.Client.Top . ", " . winInfo.Client.Right 
			. ", " . winInfo.Client.Bottom . "`nStyles = " . winInfo.Styles . "`nExStyles = " 
			. winInfo.ExStyles . "`nStatus = " . winInfo.Status . "`nXBorders = " 
			. winInfo.XBorders . "`nYBorders = " . winInfo.YBorders . "`nType = " . winInfo.Type
			. "`nVersion = " . winInfo.Version
	}
Return

:*:@getWinBorders::
	AppendAhkCmd(A_ThisLabel)
	WinGet, hwnd, ID, A
	winInfo := API_GetWindowInfo(hwnd)
	if(!IsObject(winInfo)) {
		MsgBox, 0, WINDOWINFO, ERROR - ErrorLevel: %ErrorLevel%
	} else {
		MsgBox, % "XBorders = " . winInfo.XBorders . "`nYBorders = " . winInfo.YBorders
	}
Return

; Determines the active window's border width from its left and bottom edges, and then assumes the 
; window has the same width of borders on its right and top edges.
;
; Additional Notes on Approach:
;     Current approach was adopted because for PowerShell, the width of the right-hand scroll bar 
; is deducted from the client rectangle. Moreover, for Sublime Text 3, the height of the menu is 
; deducted from the client rectangle. No cases have encountered so far where the width of a 
; window's border is not equal among all of its edges. Since the windows documentation treats 
; horizintal and vertical window borders separately, however, I decided that this function will 
; stay consistent with that convention.
GetActiveWindowBorderWidths() {
	WinGet, hwnd, ID, A
	winInfo := API_GetWindowInfo(hwnd)
	borderWidth := {}
	borderWidth.Horz := abs(winInfo.Window.Left - winInfo.Client.Left)
	if (borderWidth.Horz > winInfo.XBorders) {
		borderWidth.Horz := winInfo.XBorders
	}
	borderWidth.Vert := abs(winInfo.Window.Bottom - winInfo.Client.Bottom)
	if (borderWidth.Vert > winInfo.YBorders) {
		borderWidth.Vert := winInfo.YBorders
	}
	return borderWidth
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getWinProcess::
	AppendAhkCmd(":*:@getWinProcess")
	WinGet, thisProcess, ProcessName, A
	MsgBox, % "The active window process name is " . thisProcess
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getWinTitle::
	AppendAhkCmd(":*:@getWinTitle")
	WinGetTitle, thisTitle, A
	MsgBox, The active window is "%thisTitle%"
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^+F1::
^!Numpad1::
	clpbrdLngth := StrLen(clipboard)
	MsgBox % "The clipboard is " . clpbrdLngth . " characters long."
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^+F2::
^!Numpad2::
	clpbrdLngth := StrLen(clipboard)
	SendInput, +{Right %clpbrdLngth%}
	Sleep, 20
	SendInput, ^v
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!q::
	IfWinExist % "Untitled - Notepad"
		WinActivate % "Untitled - Notepad"
	else
		Run Notepad
Return

; --------------------------------------------------------------------------------------------------
; Desktop Management Functions
; --------------------------------------------------------------------------------------------------

GetActiveMonitorWorkArea(ByRef monitorFound, ByRef monitorALeft, ByRef monitorATop
		, ByRef monitorARight, ByRef monitorABottom) {
	global
	local winCoords := {}
	local x
	local y
	local w
	local h
	local whichVertex

	monitorFound := false
	RemoveMinMaxStateForActiveWin()
	WinGetPos, x, y, w, h, A
	whichVertex := 0
	RemoveWinBorderFromRectCoordinate(whichVertex, x, y)
	winCoords.x := x
	winCoords.y := y
	winCoords.w := w
	winCoords.h := h
	Loop, %sysNumMonitors% {
		if (winCoords.x >= mon%A_Index%Bounds_Left && winCoords.y >= mon%A_Index%Bounds_Top
				&& winCoords.x < mon%A_Index%Bounds_Right
				&& winCoords.y < mon%A_Index%Bounds_Bottom) {
			monitorFound := true
			monitorALeft := mon%A_Index%WorkArea_Left
			monitorATop := mon%A_Index%WorkArea_Top
			monitorARight := mon%A_Index%WorkArea_Right
			monitorABottom := mon%A_Index%WorkArea_Bottom
			break
		}
	}
	if (monitorFound = false) {
		ResolveActiveMonitorWorkArea(monitorFound, monitorALeft, monitorATop, monitorARight
			, monitorABottom, winCoords)
	} else {
		AddWinBordersToMonitorWorkArea(monitorALeft, monitorATop, monitorARight, monitorABottom)
	}
}

RemoveMinMaxStateForActiveWin() {
	WinGet, thisMinMax, MinMax, A
	if (thisMinMax != 0) {
		WinRestore, A
		Sleep 60
	}
}

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
