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
; Table of Contents
; ------------------------------------------------------------------------------------------------
;   §1: Window state checks.....................................................................83
;     >>> §1.1: isTargetProcessActive...........................................................87
;     >>> §1.2: areTargetProcessActive..........................................................99
;   §2: Variable state checks..................................................................122
;     >>> §2.1: doesVarExist...................................................................126
;     >>> §2.2: isVarEmpty.....................................................................133
;     >>> §2.3: isVarDeclared..................................................................140
;   §3: Error reporting........................................................................147
;     >>> §3.1: ErrorBox.......................................................................151
;   §4: Operating system manipulation..........................................................158
;     >>> §4.1: Functions......................................................................162
;       →→→ §4.1.1: DismissSplashText..........................................................165
;       →→→ §4.1.2: DisplaySplashText..........................................................172
;       →→→ §4.1.3: FallbackWinActivate........................................................180
;       →→→ §4.1.4: GetActiveWindowBorderWidths................................................198
;       →→→ §4.1.5: GetCursorCoordsToCenterInActiveWindow......................................226
;       →→→ §4.1.6: InsertFilePath.............................................................236
;       →→→ §4.1.7: LaunchApplicationPatiently.................................................265
;       →→→ §4.1.8: LaunchStdApplicationPatiently..............................................297
;       →→→ §4.1.9: MoveCursorIntoActiveWindow.................................................329
;       →→→ §4.1.10: PasteText.................................................................347
;       →→→ §4.1.11: RemoveMinMaxStateForActiveWin.............................................358
;       →→→ §4.1.12: SafeWinActivate...........................................................369
;       →→→ §4.1.13: WaitForApplicationPatiently...............................................390
;       →→→ §4.1.14: WriteCodeToFile...........................................................411
;     >>> §4.2: Hotkeys........................................................................435
;       →→→ §4.2.1: ^+F1, ^!Numpad1............................................................439
;       →→→ §4.2.2: ^+F2, ^!Numpad2............................................................448
;       →→→ §4.2.3: ^!q........................................................................459
;     >>> §4.3: Hotstrings.....................................................................469
;       →→→ §4.3.1: @getMousePos...............................................................472
;       →→→ §4.3.2: @getWinBorders.............................................................482
;       →→→ §4.3.3: @getWinExStyle.............................................................496
;       →→→ §4.3.4: @getWinHwnd................................................................506
;       →→→ §4.5.: @getWinInfo.................................................................515
;       →→→ §4.3.6: @getWinPID.................................................................535
;       →→→ §4.3.7: @getWinPos.................................................................544
;       →→→ §4.3.8: @getWinStyle...............................................................554
;       →→→ §4.3.9: @getWinProcess.............................................................564
;       →→→ §4.3.10: @getWinTitle..............................................................576
;   §5: AutoHotkey state inquiry and manipulation..............................................585
;     >>> §5.1: Functions......................................................................589
;       →→→ §5.1.1: ChangeMatchMode............................................................592
;       →→→ §5.1.2: RestoreMatchMode...........................................................605
;     >>> §5.2: Hotstrings.....................................................................615
;       →→→ §5.2.1: @checkIsUnicode............................................................618
;       →→→ §5.2.2: @getCurrentVersion.........................................................627
;       →→→ §5.2.3: @getLastHotStrTime.........................................................635
;   §6: Sorting functions......................................................................643
;     >>> §6.1: InsertionSort..................................................................647
;     >>> §6.2: Merge..........................................................................673
;     >>> §6.3: MergeSort......................................................................699
;     >>> §6.4: SwapValues.....................................................................715
;   §7: Desktop management functions...........................................................724
;     >>> §7.1: Functions......................................................................728
;       →→→ §7.1.1: AddWinBordersToMonitorWorkArea.............................................731
;       →→→ §7.1.2: ClipActiveWindowToMonitor..................................................746
;       →→→ §7.1.3: FindActiveMonitor..........................................................778
;       →→→ §7.1.4: FindNearestActiveMonitor...................................................798
;       →→→ §7.1.5: GetActiveMonitorWorkArea...................................................825
;       →→→ §7.1.6: RemoveWinBorderFromRectCoordinate..........................................866
;       →→→ §7.1.8: ResolveActiveMonitorWorkArea...............................................905
;     >>> §7.2: Hotstrings.....................................................................940
;       →→→ §7.2.1: @clipActiveWindowToMonitor.................................................943
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Window state checks
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: isTargetProcessActive

isTargetProcessActive(targetProcess, caller := "", notActiveErrMsg := "") {
	WinGet, thisWin, ProcessName, A
	targetProcessIsActive := thisWin = targetProcess
	if (!targetProcessIsActive && caller != "" && notActiveErrMsg != "") {
		ErrorBox(caller, notActiveErrMsg)
	}
	return targetProcessIsActive
}

;   ································································································
;     >>> §1.2: areTargetProcessActive

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

; --------------------------------------------------------------------------------------------------
;   §2: Variable state checks
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: doesVarExist

doesVarExist(ByRef v) { ; Requires 1.0.46+ 
	return &v = &undeclared ? 0 : 1 
}

;   ································································································
;     >>> §2.2: isVarEmpty

isVarEmpty(ByRef v) { ; Requires 1.0.46+ 
	return v = "" ? 1 : 0 
}

;   ································································································
;     >>> §2.3: isVarDeclared

isVarDeclared(ByRef v) { ; Requires 1.0.46+ 
	return &v = &undeclared ? 0 : v = "" ? 0 : 1
}

; --------------------------------------------------------------------------------------------------
;   §3: Error reporting
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: ErrorBox

ErrorBox(whichFunc, errorMsg) {
	MsgBox, % 0x10, % "Error in " . whichFunc, % errorMsg
}

; --------------------------------------------------------------------------------------------------
;   §4: Operating system manipulation
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §4.1: Functions

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.1: DismissSplashText

DismissSplashText() {
	SplashTextOff
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.2: DisplaySplashText

DisplaySplashText(msg) {
	SplashTextOn, % StrLen(msg) * 8, 24, % A_ScriptName, % msg
	SetTimer, DismissSplashText, -1000
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.3: FallbackWinActivate

FallbackWinActivate(titleToMatch, matchMode := 2) {
	global g_delayQuantum
	delay := g_delayQuantum * 7
	oldMatchMode := ChangeMatchMode(matchMode)

	WinGet, hWnd, ID, % titleToMatch
	if (hWnd) {
		DllCall("SetForegroundWindow", UInt, hWnd)
		Sleep, % delay
	}
	RestoreMatchMode(oldMatchMode)

	return WinActive(titleToMatch)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.4: GetActiveWindowBorderWidths

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.5: GetCursorCoordsToCenterInActiveWindow

GetCursorCoordsToCenterInActiveWindow(ByRef newPosX, ByRef newPosY)
{
	WinGetPos, winPosX, winPosY, winW, winH, A
	newPosX := winW / 2
	newPosY := winH / 2
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.6: InsertFilePath

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.7: LaunchApplicationPatiently

LaunchApplicationPatiently(path, title, matchMode := 2)
{
	global g_delayQuantum
	delay := g_delayQuantum * 32
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
			Sleep, % delay
		}
		else
		{
			Sleep, % delay / 2
		}
	}
	Sleep, % delay
	if (oldMatchMode) {
		SetTitleMatchMode, % oldMatchMode
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.8: LaunchStdApplicationPatiently

LaunchStdApplicationPatiently(path, title, matchMode := 2)
{
	global g_delayQuantum
	delay := g_delayQuantum * 32
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
			Sleep, % delay
		}
		else
		{
			Sleep, % delay / 2
		}
	}
	Sleep, % delay
	if (oldMatchMode) {
		SetTitleMatchMode, % oldMatchMode
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.9: MoveCursorIntoActiveWindow

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.10: PasteText

PasteText(txtToPaste) {
	if (clipboard != txtToPaste) {
		clipboard := txtToPaste
	}
	Sleep, 60
	SendInput, % "^v"
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.11: RemoveMinMaxStateForActiveWin

RemoveMinMaxStateForActiveWin() {
	WinGet, thisMinMax, MinMax, A
	if (thisMinMax != 0) {
		WinRestore, A
		Sleep 60
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.12: SafeWinActivate

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
		success := FallbackWinActivate(titleToMatch, matchMode)
	}
	return success
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.13: WaitForApplicationPatiently

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.14: WriteCodeToFile

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

;   ································································································
;     >>> §4.2: Hotkeys


;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.1: ^+F1, ^!Numpad1

^+F1::
^!Numpad1::
	clpbrdLngth := StrLen(clipboard)
	MsgBox % "The clipboard is " . clpbrdLngth . " characters long."
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.2: ^+F2, ^!Numpad2

^+F2::
^!Numpad2::
	clpbrdLngth := StrLen(clipboard)
	SendInput, +{Right %clpbrdLngth%}
	Sleep, 20
	SendInput, ^v
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.3: ^!q

^!q::
	IfWinExist % "Untitled - Notepad"
		WinActivate % "Untitled - Notepad"
	else
		Run Notepad
Return

;   ································································································
;     >>> §4.3: Hotstrings

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.1: @getMousePos

:*:@getMousePos::
	AppendAhkCmd(":*:@getMousePos")
	MouseGetPos, windowMousePosX, windowMousePosY
	MsgBox % "The mouse cursor is at {x = " . windowMousePosX . ", y = " . windowMousePosY 
		. "} relative to the window."
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.2: @getWinBorders

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.3: @getWinExStyle

:*:@getWinExStyle::
	AppendAhkCmd(A_ThisLabel)
	WinGet, hexExStyle, ExStyle, A
	;hasThickBorder := (hexStyle & 0x40000) != 0
	MsgBox, % "The active window's extended styles = " . hexExStyle
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.4: @getWinHwnd

:*:@getWinHwnd::
	AppendAhkCmd(":*:@getWinHwnd")
	WinGet, thisHwnd, ID, A
	MsgBox, % "The active window ID (HWND) is " . thisHwnd
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.5.: @getWinInfo

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.6: @getWinPID

:*:@getWinPID::
	AppendAhkCmd(":*:@getWinPID")
	WinGet, thisPID, PID, A
	MsgBox, % "The active window PID is " . thisPID
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.7: @getWinPos

:*:@getWinPos::
	AppendAhkCmd(":*:@getWinPos")
	WinGetPos, thisX, thisY, thisW, thisH, A
	MsgBox, % "The active window is at coordinates " . thisX . ", " . thisY . "`rWindow's width = " 
		. thisW . ", height = " . thisH
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.8: @getWinStyle

:*:@getWinStyle::
	AppendAhkCmd(A_ThisLabel)
	WinGet, hexStyle, Style, A
	hasThickBorder := (hexStyle & 0x40000) != 0
	MsgBox, % "The active window's styles = " . hexStyle
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.9: @getWinProcess

:*:@getWinProcess::
	AppendAhkCmd(":*:@getWinProcess")
	WinGet, thisProcess, ProcessName, A
	WinGet, thisHwnd, ID, A
	WinGetClass, thisWinClass, A
	MsgBox, % "The active window process name is " . thisProcess . "`rHWND = " . thisHwnd
		. "`rClass name = " . thisWinClass
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.10: @getWinTitle

:*:@getWinTitle::
	AppendAhkCmd(":*:@getWinTitle")
	WinGetTitle, thisTitle, A
	MsgBox, The active window is "%thisTitle%"
Return

; --------------------------------------------------------------------------------------------------
;   §5: AutoHotkey state inquiry and manipulation
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: Functions

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.1: ChangeMatchMode

ChangeMatchMode(newMatchMode) {
	; TODO: refactor for improved safety
	oldMatchMode := 0
	if (A_TitleMatchMode != newMatchMode) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode, % newMatchMode
	}	
	return oldMatchMode
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.2: RestoreMatchMode

RestoreMatchMode(oldMatchMode) {
	; TODO: refactor for improved safety
	if (oldMatchMode) {
		SetTitleMatchMode, % oldMatchMode
	}	
}

;   ································································································
;     >>> §5.2: Hotstrings

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.1: @checkIsUnicode

:*:@checkIsUnicode::
	AppendAhkCmd(A_ThisLabel)
	Msgbox % "v" . A_AhkVersion . " " . (A_PtrSize = 4 ? 32 : 64) . "-bit " 
		. (A_IsUnicode ? "Unicode" : "ANSI") . " " . (A_IsAdmin ? "(Admin mode)" : "(Not Admin)")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.2: @getCurrentVersion

:*:@getCurrentVersion::
	AppendAhkCmd(A_ThisLabel)
	MsgBox % "Current installed version of AHK: " . A_AhkVersion
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.3: @getLastHotStrTime

:*:@getLastHotStrTime::
	AppendAhkCmd(A_ThisLabel)
	MsgBox % "The last hotstring took " . (hotStrEndTime - hotStrStartTime) . "ms to run."
Return

; --------------------------------------------------------------------------------------------------
;   §6: Sorting functions
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §6.1: InsertionSort

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

;   ································································································
;     >>> §6.2: Merge

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

;   ································································································
;     >>> §6.3: MergeSort

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

;   ································································································
;     >>> §6.4: SwapValues

SwapValues(ByRef val1, ByRef val2) {
	valTemp := val2
	val2 := val1
	val1 := valTemp
}

; --------------------------------------------------------------------------------------------------
;   §7: Desktop management functions
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §7.1: Functions

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.1: AddWinBordersToMonitorWorkArea

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.2: ClipActiveWindowToMonitor

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.3: FindActiveMonitor

FindActiveMonitor() {
	whichMon := 0

	WinGetPos, x, y, w, h, A
	RemoveWinBorderFromRectCoordinate(0, x, y)
	Loop, %sysNumMonitors% {
		if (winCoords.x >= mon%A_Index%Bounds_Left && winCoords.y >= mon%A_Index%Bounds_Top
				&& winCoords.x < mon%A_Index%Bounds_Right
				&& winCoords.y < mon%A_Index%Bounds_Bottom) {
			whichMon := A_Index
			break
		}
	}

	return whichMon
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.4: FindNearestActiveMonitor

FindNearestActiveMonitor() {
	minDistance := -1
	winMidpt := {}
	monMidpt := {}

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.5: GetActiveMonitorWorkArea

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
	whichMon := FindActiveMonitor()
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.6: RemoveWinBorderFromRectCoordinate

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.8: ResolveActiveMonitorWorkArea

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

;   ································································································
;     >>> §7.2: Hotstrings

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.1: @clipActiveWindowToMonitor

:*:@clipActiveWindowToMonitor::
	AppendAhkCmd(A_ThisLabel)
	ClipActiveWindowToMonitor()
Return
