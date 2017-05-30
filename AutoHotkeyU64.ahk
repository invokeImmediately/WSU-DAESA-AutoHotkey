; ===========================================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; TABLE OF CONTENTS
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
;   Global Variables: 19  •  Workspace Management: 27  •  Utility Functions: 289  •  Text Replacement: 517
;   Program/File Launching Shortcuts: 577  •  File System Navigation: 595  •  Google Chrome Shorctuts: 645
;   Github Shortcuts: 670
; ===========================================================================================================================

; ---------------------------------------------------------------------------------------------------------------------------
; GLOBAL VARIABLES
; ---------------------------------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GLOBAL VARIABLES DEFINED THROUGH SYSGET  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
global SM_CMONITORS := 80		;Constant needed for retreiving the number of display monitors on the desktop via SysGet(...)
global SM_CXSIZEFRAME := 32			;SysGet(...) constant needed for retreiving the default window border width
global SM_CYSIZEFRAME := 33			;SysGet(...) constant needed for retreiving the default window border height
global sysNumMonitors			;Number of display monitors on this system
global sysWinBorderW			;Default border width
global sysWinBorderH			;Default border height

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> OTHER GLOBAL VARIABLES -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
global userAccountFolderSSD := "C:\Users\CamilleandDaniel"
global userAccountFolderHDD := "F:\Users\CamilleandDaniel"
global relWorkFolder := "\Documents\Daniel"
global ssdWorkFolder := userAccountFolderSSD . relWorkFolder
global hhdWorkFolder := userAccountFolderHDD . relWorkFolder
global webDevFolder := hhdWorkFolder . "\{^}WSU-Web-Dev"
global logFileName := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\Work-log.txt"
global cmdHistoryLog := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\ahk-cmd-history.txt"
global workTimerCountdownTime := -1500000
global workTimeLeftOver := 0
global workTimerMinuteCount := 0
global workTimerNotificationSound := ssdWorkFolder . "\Sound Library\chinese-gong-daniel_simon.wav"
global workTimerMinutesound := ssdWorkFolder . "\Sound Library\Bell-tone_C-4.wav"
global workTimer5MinuteSound := ssdWorkFolder . "\Sound Library\Metal_Gong-Dianakc-109711828.wav"
global windowMovementSound := ssdWorkFolder . "\Sound Library\323413__sethroph__glass-slide-3_-12.5db_faster.wav"
global windowSizingSound := ssdWorkFolder . "\Sound Library\68222__xtyl33__paper3_-7.5db_faster.wav"
global windowShiftingSound := ssdWorkFolder . "\Sound Library\185849__lloydevans09__warping.wav"
global desktopSwitchingSound := ssdWorkFolder . "\Sound Library\352719__dalesome__woosh-stick-swung-in-the-air_-15db.wav"
global scriptLoadedSound := ssdWorkFolder . "\Sound Library\Storm_exclamation.wav"
global desktopArrangedSound := ssdWorkFolder . "\Sound Library\zelda_lttp-mstr-swrd.wav"
global bitNumpadSubToggle := false
global numpadSubOverwrite := "{U+00b7}"
global ahkCmds := Array()
global ahkCmdLimit := 36
global CmdChosen
global hotstrStartTime := 0
global hotstrEndTime := 0
global savedMouseX := 0
global savedMouseY := 0
global lineLength := 125

SetTitleMatchMode, 2
FileEncoding, UTF-8
Gosub, MainSubroutine

#NoEnv
#SingleInstance

If not A_IsAdmin
{
	;" https://autohotkey.com/docs/commands/Run.htm#RunAs: For an executable file, the *RunAs verb is equivalent to selecting Run as administrator from the right-click menu of the file."
	MsgBox, % 0x30
		, % "Error: Admin Privileges Not Detected"
		, % "AutoHotkeyU64.ahk was started without Admin privileges; now reloading."
	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
}

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\functions.ahk

; ---------------------------------------------------------------------------------------------------------------------------
;   COMMAND HISTORY
; ---------------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\commandHistory.ahk

; ---------------------------------------------------------------------------------------------------------------------------
;   WORKSPACE MANAGEMENT
; ---------------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\workspaceMngmnt.ahk

:*:@toggleOverlayMode::
	AppendAhkCmd(":*:@toggleOverlayMode")
	WinGet, currentWindowID, ID, A
	WinGet, ExStyle, ExStyle, ahk_id %currentWindowID%
	if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
	{
		Winset, AlwaysOnTop, off, ahk_id %currentWindowID%
		Winset, Transparent, 255, ahk_id %currentWindowID%
		SplashImage,, x0 y0 b fs12, OFF always on top.
		Sleep, 1500
		SplashImage, Off
	}
	else
	{
		WinSet, AlwaysOnTop, on, ahk_id %currentWindowID%
		Winset, Transparent, 128, ahk_id %currentWindowID%
		SplashImage,,x0 y0 b fs12, ON always on top.
		Sleep, 1500
		SplashImage, Off
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@toggleAOT::
	AppendAhkCmd(":*:@toggleAOT")
	WinGet, currentWindowID, ID, A
	WinGet, ExStyle, ExStyle, ahk_id %currentWindowID%
	if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
	{
		Winset, AlwaysOnTop, off, ahk_id %currentWindowID%
	}
	else
	{
		WinSet, AlwaysOnTop, on, ahk_id %currentWindowID%
	}
Return

; ---------------------------------------------------------------------------------------------------------------------------
;   WORK TIMER scripts for tracking hours and indicating when breaks should be taken
; ---------------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\workTimer.ahk

; ---------------------------------------------------------------------------------------------------------------------------
;   TEXT REPLACEMENT
; ---------------------------------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> Text Replacement HOTKEYS  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

NumpadSub::
	if (bitNumpadSubToggle) {
		SendInput, % numpadSubOverwrite
	}
	else {
		SendInput, -
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^NumpadSub::
	Gosub :*:@toggleNumpadSub
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^+NumpadSub::
	Gosub :*:@changeNumpadSub
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> Text Replacement HOTSTRINGS -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@add5lineshere::
	AppendAhkCmd(":*:@add5lineshere")
	SendInput, {Enter 5}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@addClass::class=""{Space}{Left 2}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@addNrml::{Space}class="oue-normal"

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@changeNumpadSub::
	AppendAhkCmd(":*:@changeNumpadSub")
	Inputbox, inputEntered
		, % "@changeNumpadSub: Change Numpad- Overwrite"
		, % "Enter a character/string that the Numpad- key will now represent once alternative input is toggled on."
	if (!ErrorLevel) {
		numpadSubOverwrite := inputEntered
	} else {
		MsgBox, % (0x0 + 0x40)
			, % "@changeNumpadSub: Numpad- Overwrite Canceled"
			, % "Alternative input for Numpad- will remain as " . numpadSubOverwrite
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@datetime::
	AppendAhkCmd(":*:@datetime")
	FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm:ss
	SendInput, %CurrentDateTime%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@ddd::
	AppendAhkCmd(":*:@ddd")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, %CurrentDateTime%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@doRGBa::
	AppendAhkCmd(":*:@doRGBa")
	SendInput, rgba(@rval, @gval, @bval, );{Left 2}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:R*:@findStrFnctns::^[^{\r\n]+{$\r\n(?:^(?<!\}).+$\r\n)+^\}$

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@ppp::
	AppendAhkCmd(":*:@ppp")
	SendInput, news-events_events_.html{Left 5}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@toggleNumpadSub::
	AppendAhkCmd(":*:@toggleNumpadSub")
	toggleMsg := "The NumPad- key has been toggled to "
	bitNumpadSubToggle := !bitNumpadSubToggle
	if (bitNumpadSubToggle) {
		toggleMsg .= numpadSubOverwrite
	} else {
		toggleMsg .=  "-"
	}
	MsgBox, % (0x0 + 0x40)
		, % "@toggleNumpadSub: NumPad- Toggled"
		, % toggleMsg
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@xccc::
	AppendAhkCmd(":*:@xccc")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, / Completed %CurrentDateTime%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@xsss::
	AppendAhkCmd(":*:@xsss")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, (Started %CurrentDateTime%)
Return

; ---------------------------------------------------------------------------------------------------------------------------
;   PROGRAM/FILE LAUNCHING SHORTCUTS
; ---------------------------------------------------------------------------------------------------------------------------

:R*?:runNotepad::
	Run C:\Program Files (x86)\Notepad++\notepad++.exe
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

#z::
	Run notepad++.exe, C:\Program Files (x86)\Notepad++, Max
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@checkHTMLSpec::
	AppendAhkCmd(":*:@checkHTMLSpec")
	Run % userAccountFolderHHD . "\Documents\Daniel\^WSU-Web-Dev\^Master-VPUE\Anatomy of an HTML5 Document_2016-03-16.jpg"
Return

; ---------------------------------------------------------------------------------------------------------------------------
;   FILE SYSTEM NAVIGATION
; ---------------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\fileSystem.ahk

; ---------------------------------------------------------------------------------------------------------------------------
;   AUTOHOTKEY SCRIPT WRITING SHORTCUTS
; ---------------------------------------------------------------------------------------------------------------------------

:*:@insAhkCommentSection::
	AppendAhkCmd(":*:@insAhkCommentSection")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := "; ------------------------------------------------------------------------------------------------------------`r"
			. "; ***EDIT COMMENT TEXT HERE***`r"
			. "; ------------------------------------------------------------------------------------------------------------`r"
			. "`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
		Sleep 60
		SendInput, % "{Up 3}{Right 2}"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSection" ; Title
			, % "An AutoHotkey comment section can only be inserted if [Notepad++.exe] is the active process. Unfortunately, the currently active process is [" . thisProcess . "]." ; Message
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@insAhkCommentSubSection::
	AppendAhkCmd(":*:@insAhkCommentSubSection")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := "; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---`r"
			. "; >>> ***EDIT COMMENT TEXT HERE ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---`r"
			. "`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
		Sleep 60
		SendInput, % "{Up 2}{Right 6}"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSection" ; Title
			, % "An AutoHotkey comment section can only be inserted if [Notepad++.exe] is the active process. Unfortunately, the currently active process is [" . thisProcess . "]." ; Message
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@insAhkCommentSeparator::
	AppendAhkCmd(":*:@insAhkCommentSeparator")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := "; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---`r"
			. "`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSeparator" ; Title
			, % "An AutoHotkey comment separator can only be inserted if [Notepad++.exe] is the active process. Unfortunately, the currently active process is [" . thisProcess . "]."			; Message
	}
Return

; ---------------------------------------------------------------------------------------------------------------------------
;   GOOGLE CHROME SHORTCUTS
; ---------------------------------------------------------------------------------------------------------------------------

^!o::
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "chrome.exe") {
		SendInput, ^n
		Sleep, 333
		SendInput, ^+o
		Sleep, 100
		SendInput, ^!m
	} else {
		GoSub, PerformBypassingCtrlAltO
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

PerformBypassingCtrlAltO:
	Suspend
	Sleep, 10
	SendInput, ^!o
	Sleep, 10
	Suspend, Off
Return

; ---------------------------------------------------------------------------------------------------------------------------
;   NOTEPAD++ SHORTCUTS
; ---------------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\htmlEditing.ahk

; ---------------------------------------------------------------------------------------------------------------------------
;   OTHER SHORTCUTS
; ---------------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\github.ahk

; Shift + Wheel for horizontal scrolling
;+WheelDown::WheelRight
;+WheelUp::WheelLeft

#+X::
	SetKeyDelay, 160, 100
	Send {SPACE 16}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^#!r::
	SaveAhkCmdHistory()
	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
Return

; ---------------------------------------------------------------------------------------------------------------------------
;   CUSTOM HOTSTRINGS
; ---------------------------------------------------------------------------------------------------------------------------

:*:@copyFromExcel::
	AppendAhkCmd(":*:@copyFromExcel")
	CopyTitleFromExcel(1)
Return

CopyTitleFromExcel(cumulativeCount) {
	if (cumulativeCount <= 10) {
		Sleep, 200
		SendInput, !{Tab}
		Sleep, 200
		SendInput, ^c
		Sleep, 200
		SendInput, {Down}
		Sleep, 200
		SendInput, !{Tab}
		Sleep, 200
		SendInput, !h
		Sleep, 200
		SendInput, v
		Sleep, 100
		SendInput, t
		Sleep, 100
		SendInput, ^h
		Sleep, 100
		SendInput, {Enter}
		Sleep, 100
		SendInput, {Esc}
		Sleep, 100
		SendInput, {Right}
		Sleep, 300
		cumulativeCount++
		CopyTitleFromExcel(cumulativeCount)
	}
}

; ---------------------------------------------------------------------------------------------------------------------------
;   MAIN SUBROUTINE
; ---------------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\desktopMain.ahk

:*:@testTabRpt::
	AppendAhkCmd(":*:@testTabRpt")
	numRpts := 3
	Send !{TAB %numRpts%}
Return

