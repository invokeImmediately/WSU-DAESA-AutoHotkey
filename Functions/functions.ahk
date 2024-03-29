﻿; ==================================================================================================
; █▀▀▀ █  █ ▐▀▀▄ ▄▀▀▀▐▀█▀▌▀█▀ ▄▀▀▄ ▐▀▀▄ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; █▀▀▀ █  █ █  ▐ █     █   █  █  █ █  ▐ ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
; ▀     ▀▀  ▀  ▐  ▀▀▀  █  ▀▀▀  ▀▀  ▀  ▐ ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Functions used throughout the script for performing common tasks involving communication,
;   state checking or changing, window interaction, and input automation.
;
; @version 1.0.3
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/Functions/functions.ahk
; @license MIT - Copyright (c) 2021 Daniel C. Rieck.
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;     and associated documentation files (the “Software”), to deal in the Software without
;     restriction, including without limitation the rights to use, copy, modify, merge, publish,
;     distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;     Software is furnished to do so, subject to the following conditions:
;   The above copyright notice and this permission notice shall be included in all copies or
;     portions of the Software.
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;     BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;     DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================
; Table of Contents:
; -----------------
;   §1: Active window status checks.............................................................92
;   §2: Variable type & state checks............................................................98
;   §3: Error reporting........................................................................106
;     >>> §3.1: ErrorBox.......................................................................110
;   §4: Operating system manipulation..........................................................117
;     >>> §4.1: Functions......................................................................121
;       →→→ §4.1.1: CloseSplashProgress()......................................................124
;       →→→ §4.1.2: DismissSplashProgress()....................................................131
;       →→→ §4.1.3: DismissSplashText()........................................................138
;       →→→ §4.1.4: DisplaySplashProgress(…)...................................................145
;       →→→ §4.1.5: DisplaySplashText(…).......................................................166
;       →→→ §4.1.6: FallbackWinActivate(…).....................................................253
;       →→→ §4.1.7: GetActiveWindowBorderWidths()..............................................271
;       →→→ §4.1.8: GetCursorCoordsToCenterInActiveWindow()....................................289
;       →→→ §4.1.9: GetWindowBorderWidths(…)...................................................299
;       →→→ §4.1.10: InsertFilePath............................................................318
;       →→→ §4.1.11: IsMouseAtCoord............................................................347
;       →→→ §4.1.12: LaunchApplicationPatiently................................................359
;       →→→ §4.1.13: LaunchStdApplicationPatiently.............................................391
;       →→→ §4.1.14: MoveCursorIntoActiveWindow................................................423
;       →→→ §4.1.15: PasteText.................................................................441
;       →→→ §4.1.16: RemoveMinMaxStateForActiveWin.............................................452
;       →→→ §4.1.17: SafeSend..................................................................465
;       →→→ §4.1.18 SafeSendInput..............................................................474
;       →→→ §4.1.19: SafeWinActivate...........................................................483
;       →→→ §4.1.20: WaitForApplicationPatiently...............................................512
;       →→→ §4.1.21: WriteCodeToFile...........................................................533
;     >>> §4.2: Hotkeys........................................................................561
;       →→→ §4.2.1: ^+F1, ^!Numpad1............................................................565
;       →→→ §4.2.2: ^+F2, ^!Numpad2............................................................574
;       →→→ §4.2.3: ^!q........................................................................585
;     >>> §4.3: Hotstrings.....................................................................595
;       →→→ §4.3.1: @getMousePos...............................................................598
;       →→→ §4.3.2: @getWinBorders.............................................................608
;       →→→ §4.3.3: @getWinExStyle.............................................................622
;       →→→ §4.3.4: @get/copyWinHwnd...........................................................632
;       →→→ §4.5.: @getWinInfo.................................................................647
;       →→→ §4.3.6: @getWinPID.................................................................674
;       →→→ §4.3.7: @getWinPos.................................................................683
;       →→→ §4.3.8: @getWinStyle...............................................................693
;       →→→ §4.3.9: @getWinProcess.............................................................703
;       →→→ §4.3.10: @get/copyWinTitle.........................................................715
;   §5: AutoHotkey state inquiry and manipulation..............................................730
;     >>> §5.1: Functions......................................................................736
;       →→→ §5.1.1: ChangeMatchMode............................................................739
;       →→→ §5.1.2: ChangeMouseCoordMode.......................................................758
;       →→→ §5.1.3: GetDelay...................................................................776
;       →→→ §5.1.4: RestoreMatchMode...........................................................826
;       →→→ §5.1.5: RestoreMouseCoordMode......................................................842
;     >>> §5.2: Hotstrings.....................................................................857
;       →→→ §5.2.1: @checkIsUnicode............................................................860
;       →→→ §5.2.2: @getCurrentVersion.........................................................869
;       →→→ §5.2.3: @getLastHotStrTime.........................................................877
;   §6: Sorting functions......................................................................885
;     >>> §6.1: InsertionSort..................................................................889
;     >>> §6.2: Merge..........................................................................915
;     >>> §6.3: MergeSort......................................................................941
;     >>> §6.4: SwapValues.....................................................................957
;   §7: Desktop management functions...........................................................966
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Active window status checks
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\Functions\activeWindowStatusChecks.ahk

; --------------------------------------------------------------------------------------------------
;   §2: Variable type & state checks
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\Functions\typeChecker.ahk

#Include %A_ScriptDir%\Functions\variableStateChecks.ahk

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
;       →→→ §4.1.1: CloseSplashProgress()

CloseSplashProgress() {
	Progress, Off
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.2: DismissSplashProgress()

DismissSplashProgress( delay := -1000 ) {
	SetTimer CloseSplashProgress, % delay
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.3: DismissSplashText()

DismissSplashText() {
	SplashTextOff
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.4: DisplaySplashProgress(…)

DisplaySplashProgress( normProg, mainText := "Progress for current operation" ) {
	global g_dpiScalar
	if ( normProg == 0 ) {
		SysGet, primaryMon, MonitorWorkArea
		progWinX := primaryMonRight - 488 * g_dpiScalar
		progWinY := primaryMonBottom - 90 * g_dpiScalar
		progWinW := 480
		progWinH := 60
		Progress, W%progWinW% H%progWinH% X%progWinX% Y%progWinY%, , %mainText%, %A_ScriptName%
	} else {
		Progress, %normProg%
	}
	if ( normProg >= 100 ) {
		Sleep, 200
		CloseSplashProgress()
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.5: DisplaySplashText(…)

DisplaySplashText(msg, displayTime := 1000, waitForMsg := False) {
	global g_dpiScalar
	splashMsg := new SplashTextMsg( msg )
	splashGui := new GuiSplashText( splashMsg.msg, displayTime, waitForMsg )
	splashGui.ShowGui()
	; SplashTextOn % splashMsg.maxLineLen * 8 * g_dpiScalar
	; 	, ( splashMsg.numLines * 19 + 3 ) * g_dpiScalar
	; 	, % A_ScriptName
	; 	, % splashMsg.msg
	; SetTimer DismissSplashText, % -1 * displayTime
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.6: FallbackWinActivate(…)

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
;       →→→ §4.1.7: GetActiveWindowBorderWidths()

; Determines the active window's border width from its left and bottom edges, and then assumes the 
;  window has the same width of borders on its right and top edges.
;
; Additional Notes on Approach:
;  Current approach was adopted because for PowerShell, the width of the right-hand scroll bar is
;   deducted from the client rectangle. Moreover, for Sublime Text 3, the height of the menu is 
;   deducted from the client rectangle. No cases have encountered so far where the width of a 
;   window's border is not equal among all of its edges. Since the windows documentation treats 
;   horizintal and vertical window borders separately, however, I decided that this function will 
;   stay consistent with that convention.
GetActiveWindowBorderWidths() {
	WinGet, hwnd, ID, A
	return GetWindowBorderWidths(hwnd)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.8: GetCursorCoordsToCenterInActiveWindow(…)

GetCursorCoordsToCenterInActiveWindow(ByRef newPosX, ByRef newPosY)
{
	WinGetPos, winPosX, winPosY, winW, winH, A
	newPosX := winW / 2
	newPosY := winH / 2
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.9: GetWindowBorderWidths(…)

; Finds the specified window's border width from its left and bottom edges, and then assumes the 
; window has the same width of borders on its right and top edges.
GetWindowBorderWidths(hwnd) {
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
;       →→→ §4.1.10: InsertFilePath

InsertFilePath(ahkCmdName, filePath, headerStr:="") {
	global lineLength
	AppendAhkCmd( ahkCmdName )
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
;       →→→ §4.1.11: IsMouseAtCoord

IsMouseAtCoord( coordX, coordY ) {
	CoordMode, Mouse, Screen
	MouseGetPos, actMouseX, actMouseY
	pixTol := 8
	atCurCoord := ( Abs( actMouseX - coordX ) <= pixTol )
		&& ( Abs( actMouseY - coordY ) <= pixTol )
	return atCurCoord
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.12: LaunchApplicationPatiently

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
;       →→→ §4.1.13: LaunchStdApplicationPatiently

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
;       →→→ §4.1.14: MoveCursorIntoActiveWindow

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
;       →→→ §4.1.15: PasteText

PasteText(txtToPaste) {
	if (clipboard != txtToPaste) {
		clipboard := txtToPaste
	}
	Sleep, 60
	SendInput, % "^v"
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.16: RemoveMinMaxStateForActiveWin

RemoveMinMaxStateForActiveWin() {
	delay := GetDelay("short")
	WinGet, thisMinMax, MinMax, A
	if (thisMinMax != 0) {
		WinRestore, A
		Sleep % delay
	}
	return thisMinMax
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.17: SafeSend

SafeSend( dvcInput ) {
	Suspend, On
	Send % dvcInput
	Suspend, Off
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.18: SafeWinActivate

SafeSendInput( dvcInput ) {
	Suspend, On
	SendInput % dvcInput
	Suspend, Off
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.19: SafeWinActivate

SafeWinActivate(winTitle, matchMode := 2, maxTries := 0) {
	global g_maxTries
	global g_delayQuantum

	oldMatchMode := ChangeMatchMode(matchMode)
	delay := g_delayQuantum * 7
	counter := 0
	if (maxTries == 0) {
		maxTries := g_maxTries
	}
	WinActivate, %winTitle%
	Sleep, % delay * 2
	success := WinActive(winTitle)
	while (!success && counter < maxTries) {
		WinActivate, %winTitle%
		Sleep, % delay * 2
		success := WinActive(winTitle)
		counter++
	}
	RestoreMatchMode(oldMatchMode)
	if (!success) {
		success := FallbackWinActivate(titleToMatch, matchMode)
	}
	return success
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.20: WaitForApplicationPatiently

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
;       →→→ §4.1.21: WriteCodeToFile

WriteCodeToFile(hsCaller, srcCode, srcFileToOverwrite) {
	success := false
	errorMsg := ""
	if (UserFolderIsSet()) {
		srcFile := FileOpen(srcFileToOverwrite, "w")
		if (srcFile != 0) {
			srcFile.Write(srcCode)
			srcFile.Close()
			Sleep 100
			success := true
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

	return success
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

:*?:@getMousePos::
	AppendAhkCmd( A_ThisLabel )
	MouseGetPos, windowMousePosX, windowMousePosY
	MsgBox % "The mouse cursor is at {x = " . windowMousePosX . ", y = " . windowMousePosY 
		. "} relative to the window."
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.2: @getWinBorders

:*?:@getWinBorders::
	AppendAhkCmd( A_ThisLabel )
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

:*?:@getWinExStyle::
	AppendAhkCmd( A_ThisLabel )
	WinGet, hexExStyle, ExStyle, A
	;hasThickBorder := (hexStyle & 0x40000) != 0
	MsgBox, % "The active window's extended styles = " . hexExStyle
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.4: @get/copyWinHwnd

:*?:@getWinHwnd::
	AppendAhkCmd( A_ThisLabel )
	WinGet, thisHwnd, ID, A
	MsgBox, % "The active window ID (HWND) is " . thisHwnd
Return

:*?:@copyWinHwnd::
	AppendAhkCmd( A_ThisLabel )
	WinGet, thisHwnd, ID, A
	Clipboard := thisHwnd
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.5.: @getWinInfo

:*?:@getWinInfo::
	AppendAhkCmd( A_ThisLabel )
	WinGet, hwnd, ID, A
	WinGetTitle, thisTitle, A
	WinGet, thisProcess, ProcessName, A
	winInfo := API_GetWindowInfo(hwnd)
	if(!IsObject(winInfo)) {
		MsgBox, 0, WINDOWINFO, ERROR - ErrorLevel: %ErrorLevel%
	} else {
		MsgBox, % "Title = " . thisTitle . "`nhWnd = " . hwnd . "`nProcess = " . thisProcess
			. "`nWindow Rect = " . winInfo.Window.Left . ", " . winInfo.Window.Top . ", "
			. winInfo.Window.Right . ", " . winInfo.Window.Bottom . "`nClient Rect = " 
			. winInfo.Client.Left . ", " . winInfo.Client.Top . ", " . winInfo.Client.Right 
			. ", " . winInfo.Client.Bottom . "`nStyles = " . winInfo.Styles . "`nExStyles = " 
			. winInfo.ExStyles . "`nStatus = " . winInfo.Status . "`nXBorders = " 
			. winInfo.XBorders . "`nYBorders = " . winInfo.YBorders . "`nType = " . winInfo.Type
			. "`nVersion = " . winInfo.Version
	}
Return

^!+F1::
	Gosub :*?:@getWinInfo
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.6: @getWinPID

:*?:@getWinPID::
	AppendAhkCmd( A_ThisLabel )
	WinGet, thisPID, PID, A
	MsgBox, % "The active window PID is " . thisPID
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.7: @getWinPos

:*?:@getWinPos::
	AppendAhkCmd( A_ThisLabel )
	WinGetPos, thisX, thisY, thisW, thisH, A
	MsgBox, % "The active window is at coordinates " . thisX . ", " . thisY . "`rWindow's width = " 
		. thisW . ", height = " . thisH
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.8: @getWinStyle

:*?:@getWinStyle::
	AppendAhkCmd( A_ThisLabel )
	WinGet, hexStyle, Style, A
	hasThickBorder := (hexStyle & 0x40000) != 0
	MsgBox, % "The active window's styles = " . hexStyle
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.9: @getWinProcess

:*?:@getWinProcess::
	AppendAhkCmd( A_ThisLabel )
	WinGet, thisProcess, ProcessName, A
	WinGet, thisHwnd, ID, A
	WinGetClass, thisWinClass, A
	MsgBox, % "The active window process name is " . thisProcess . "`rHWND = " . thisHwnd
		. "`rClass name = " . thisWinClass
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.10: @get/copyWinTitle

:*?:@getWinTitle::
	AppendAhkCmd( A_ThisLabel )
	WinGetTitle, thisTitle, A
	MsgBox, The active window is "%thisTitle%"
Return

:*?:@copyWinTitle::
	AppendAhkCmd( A_ThisLabel )
	WinGetTitle, thisTitle, A
	Clipboard := thisTitle
Return

; --------------------------------------------------------------------------------------------------
;   §5: AutoHotkey state inquiry and manipulation
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\Functions\executionDelayer.ahk

;   ································································································
;     >>> §5.1: Functions

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.1: ChangeMatchMode

ChangeMatchMode(newMatchMode) {
	global mmRegEx

	oldMatchMode := 0
	argValid := (newMatchMode == 1) || (newMatchMode == 2) || (newMatchMode == 3)
		|| (newMatchMode == mmRegEx)
	if (argValid && A_TitleMatchMode != newMatchMode) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode % newMatchMode
	} else if (!argValid) {
		ErrorBox(A_ThisFunc, "I was passed an invalid argument, which contains the value: "
			. newMatchMode)
	}
	return oldMatchMode
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.2: ChangeMouseCoordMode

ChangeMouseCoordMode(newCoordMode) {
	global cmClient
	oldCoordMode := 0
	argValid := (newCoordMode == Screen) || (newCoordMode == Relative) || (newCoordMode == Window)
		|| (newCoordMode == cmClient)
	if (argValid && A_CoordModeMouse != newCoordMode) {
		oldCoordMode := A_CoordModeMouse
		CoordMode Mouse, % newCoordMode
	} else if (!argValid) {
		ErrorBox(A_ThisFunc, "I was passed an invalid argument, which contains the value: "
			. newCoordMode)
	}
	return oldCoordMode
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.3: GetDelay
;
;   Allows for operational delays to be semantically set across scripts.
;
;   Concepts such as short, medium, and long delays are interpreted into consistent values. An
;   optional multiplier may also be applied, allowing the function to achieve any value of delay.
;
;   @param {string}         delayLength     Can have values of "xShort", "short", "medium", and
;												"long".
;   @param {number}			multiplier		Must be >=0; optional.

GetDelay(delayLength, multiplier := 0) {
	global
	local delay

	; Process delayLength into a scalar multiplier of the script's delay quantum
	if (delayLength == "shortest") {
		delay := 1
	} else if (delayLength == "xShort") {
		delay := g_extraShortDelay
	} else if (delayLength == "short") {
		delay := g_shortDelay
	} else if (delayLength == "medium") {
		delay := g_mediumDelay
	} else if (delayLength == "long") {
		delay := g_longDelay
	} else {
		delay := g_shortDelay
		ErrorBox(A_ThisLabel, "I was called with an incorrectly specified delayLength parameter, wh"
			. "ich had a value of: " . delayLength . ". I will assume a short delay is appropriate "
			. "and allow script execution to proceed.")
	}

	; If applicable, apply an additional multiplier to the basal scalar multiplier
	if (multiplier > 0) {
		delay *= multiplier
	} else if (multiplier < 0) {
		ErrorBox(A_ThisLabel, "I was called with an incorrectly specified multiplier parameter, whi"
			. "ich had a value of: " . multiplier . ". I will ignore it and allow execution to proc"
			. "eed.")
	}

	; Multiply by the script's delay quantum to produce the actual delay
	delay *= g_delayQuantum

	; Return processed delay for use in calling function
	return delay
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.4: RestoreMatchMode

RestoreMatchMode(oldMatchMode) {
	global mmRegEx

	argValid := (oldMatchMode == 0) || (oldMatchMode == 1) || (oldMatchMode == 2)
		|| (oldMatchMode == 3) || (newMatchMode == mmRegEx)
	if (argValid && oldMatchMode && A_TitleMatchMode != oldMatchMode) {
		SetTitleMatchMode % oldMatchMode
	} else if (!argValid) {
		ErrorBox(A_ThisFunc, "I was passed an invalid argument, which contains the value: "
			. oldMatchMode)
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.5: RestoreMouseCoordMode

RestoreMouseCoordMode(oldCoordMode) {
	global cmClient
	argValid := (oldCoordMode == 0) || (oldCoordMode == Screen) || (oldCoordMode == cmClient)
		|| (oldCoordMode == Relative) || (oldCoordMode == Window)
	if (argValid && oldCoordMode && A_CoordModeMouse != oldCoordMode) {
		CoordMode Mouse, % oldCoordMode
	} else if (!argValid) {
		ErrorBox(A_ThisFunc, "I was passed an invalid argument, which contains the value: "
			. oldCoordMode)
	}
}

;   ································································································
;     >>> §5.2: Hotstrings

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.1: @checkIsUnicode

:*?:@checkIsUnicode::
	AppendAhkCmd( A_ThisLabel )
	Msgbox % "v" . A_AhkVersion . " " . (A_PtrSize = 4 ? 32 : 64) . "-bit " 
		. (A_IsUnicode ? "Unicode" : "ANSI") . " " . (A_IsAdmin ? "(Admin mode)" : "(Not Admin)")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.2: @getCurrentVersion

:*?:@getCurrentVersion::
	AppendAhkCmd( A_ThisLabel )
	MsgBox % "Current installed version of AHK: " . A_AhkVersion
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.3: @getLastHotStrTime

:*?:@getLastHotStrTime::
	AppendAhkCmd( A_ThisLabel )
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

#Include %A_ScriptDir%\Functions\monitorWorkAreas.ahk
