; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;    GLOBAL VARIABLES ........................................................................... 26
;    SET UP SCRIPT & CALL MAIN SUBROUTINE ...................................................... 103
;    COMMON FUNCTIONS & CLASSES ................................................................ 124
;    COMMAND HISTORY ........................................................................... 136
;    WORKSPACE MANAGEMENT ...................................................................... 142
;    WORK TIMER ................................................................................ 190
;    TEXT REPLACEMENT & INPUT .................................................................. 196
;    PROGRAM/FILE LAUNCHING SHORTCUTS .......................................................... 384
;    FILE SYSTEM NAVIGATION .................................................................... 406
;    AUTOHOTKEY SCRIPT WRITING SHORTCUTS ....................................................... 412
;    GOOGLE CHROME SHORTCUTS ................................................................... 484
;    NOTEPAD++ SHORTCUTS ....................................................................... 516
;    GITHUB SHORTCUTS .......................................................................... 522
;    OTHER SHORTCUTS ........................................................................... 528
;    CUSTOM HOTSTRINGS & HOTKEYS ............................................................... 541
;    MAIN SUBROUTINE ........................................................................... 615

; --------------------------------------------------------------------------------------------------
;   GLOBAL VARIABLES
; --------------------------------------------------------------------------------------------------

; ··································································································
; >>> SYSTEM PROPERTY GLOBALS

global SM_CMONITORS := 80		; Constant needed for retreiving the number of display monitors on 
								;  the desktop via SysGet(...).

global SM_CXSIZEFRAME := 32		; SysGet(...) constant needed for retreiving the default window 
								;  border width.

global SM_CYSIZEFRAME := 33		; SysGet(...) constant needed for retreiving the default window 
								;  border height.

global sysNumMonitors			; Number of display monitors on this system.

global sysWinBorderW			; Default border width.

global sysWinBorderH			; Default border height.

; ··································································································
; >>> GLOBALS FOR LOCATIONS OF IMPORTANT FOLDERS & FILES
global userAccountFolderSSD := "C:\Users\CamilleandDaniel"
global userAccountFolderHDD := "F:\Users\CamilleandDaniel"
global relWorkFolder := "\Documents\Daniel"
global ssdWorkFolder := userAccountFolderSSD . relWorkFolder
global hhdWorkFolder := userAccountFolderHDD . relWorkFolder
global webDevFolder := hhdWorkFolder . "\{^}WSU-Web-Dev"

; ··································································································
; >>> POMODORO WORK TIMER GLOBALS
global logFileName := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\Work-log.txt"
global workTimerCountdownTime := -1500000
global workTimeLeftOver := 0
global workTimerMinuteCount := 0
global workTimerNotificationSound := ssdWorkFolder . "\Sound Library\chinese-gong-daniel_simon.wav"
global workTimerMinutesound := ssdWorkFolder . "\Sound Library\Bell-tone_C-4.wav"
global workTimer5MinuteSound := ssdWorkFolder . "\Sound Library\Metal_Gong-Dianakc-109711828.wav"

; ··································································································
; >>> DESKTOP ARRANGEMENT AUDITORY CUE GLOBALS
global windowMovementSound := ssdWorkFolder . "\Sound Library\323413__sethroph__glass-slide-3_-12.5"
	. "db_faster.wav"
global windowSizingSound := ssdWorkFolder . "\Sound Library\68222__xtyl33__paper3_-7.5db_faster.wav"
global windowShiftingSound := ssdWorkFolder . "\Sound Library\185849__lloydevans09__warping.wav"
global desktopSwitchingSound := ssdWorkFolder . "\Sound Library\352719__dalesome__woosh-stick-swung"
	. "-in-the-air_-15db.wav"
global scriptLoadedSound := ssdWorkFolder . "\Sound Library\Storm_exclamation.wav"
global desktopArrangedSound := ssdWorkFolder . "\Sound Library\zelda_lttp-mstr-swrd.wav"

; ··································································································
; >>> SIMULATED MEMORY OF USER ACTIONS
global cmdHistoryLog := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\ahk-cmd-history.txt"
global ahkCmds := Array()
global ahkCmdLimit := 140
global CmdChosen
global savedMouseX := 0
global savedMouseY := 0
global lineLength := 125

global commitCssLessMsgLog := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\commit-css-less-msg-hi"
	. "story.txt"
global commitAnyFileMsgLog := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\commit-any-file-msg-hi"
	. "story.txt"

; ··································································································
; >>> KEYBOARD OVERRIDING
global bitNumpadSubToggle := false
global numpadSubOverwrite := "{U+00b7}"
global bitNumpadDivToggle := false
global numpadDivOverwrite := "{U+00b7}"

global hotstrStartTime := 0
global hotstrEndTime := 0

; --------------------------------------------------------------------------------------------------
;   SET UP SCRIPT & CALL MAIN SUBROUTINE
; --------------------------------------------------------------------------------------------------

#NoEnv
#SingleInstance
SetTitleMatchMode, 2
CoordMode, Mouse, Client
FileEncoding, UTF-8
Gosub, MainSubroutine
If not A_IsAdmin
{
	;" https://autohotkey.com/docs/commands/Run.htm#RunAs: For an executable file, the *RunAs verb 
	; is equivalent to selecting Run as administrator from the right-click menu of the file."
	MsgBox, % 0x30
		, % "Error: Admin Privileges Not Detected"
		, % "AutoHotkeyU64.ahk was started without Admin privileges; now reloading."
	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
}

; --------------------------------------------------------------------------------------------------
;   COMMON FUNCTIONS & CLASSES
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\guiMsgBox.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\API_GetWindowInfo.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\functions.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\trie.ahk

; --------------------------------------------------------------------------------------------------
;   COMMAND HISTORY
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\commandHistory.ahk

; --------------------------------------------------------------------------------------------------
;   WORKSPACE MANAGEMENT
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\virtualDesktops.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\workspaceMngmnt.ahk

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; --------------------------------------------------------------------------------------------------
;   WORK TIMER
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\workTimer.ahk

; --------------------------------------------------------------------------------------------------
;   TEXT REPLACEMENT & INPUT
; --------------------------------------------------------------------------------------------------

; ··································································································
; >>> Text Replacement HOTKEYS

NumpadDiv::
	if (bitNumpadDivToggle) {
		SendInput, % numpadDivOverwrite
	}
	else {
		SendInput, /
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^NumpadDiv::
	Gosub :*:@toggleNumpadDiv
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^+NumpadDiv::
	Gosub :*:@changeNumpadDiv
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

NumpadSub::
	if (bitNumpadSubToggle) {
		SendInput, % numpadSubOverwrite
	}
	else {
		SendInput, -
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^NumpadSub::
	Gosub :*:@toggleNumpadSub
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^+NumpadSub::
	Gosub :*:@changeNumpadSub
Return

; ··································································································
; >>> Text Replacement HOTSTRINGS

:*:@add5lineshere::
	AppendAhkCmd(":*:@add5lineshere")
	SendInput, {Enter 5}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@addClass::class=""{Space}{Left 2}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@addNrml::{Space}class="oue-normal"

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@changeNumpadDiv::
	AppendAhkCmd(":*:@changeNumpadDiv")
	Inputbox, inputEntered
		, % "@changeNumpadDiv: Change Numpad / Overwrite"
		, % "Enter a character/string that the Numpad- key will now represent once alternative "
		. "input is toggled on."
	if (!ErrorLevel) {
		numpadDivOverwrite := inputEntered
	} else {
		MsgBox, % (0x0 + 0x40)
			, % "@changeNumpadDiv: Numpad / Overwrite Canceled"
			, % "Alternative input for Numpad / will remain as " . numpadDivOverwrite
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@changeNumpadSub::
	AppendAhkCmd(":*:@changeNumpadSub")
	Inputbox, inputEntered
		, % "@changeNumpadSub: Change Numpad- Overwrite"
		, % "Enter a character/string that the Numpad- key will now represent once alternative "
		. "input is toggled on."
	if (!ErrorLevel) {
		numpadSubOverwrite := inputEntered
	} else {
		MsgBox, % (0x0 + 0x40)
			, % "@changeNumpadSub: Numpad- Overwrite Canceled"
			, % "Alternative input for Numpad- will remain as " . numpadSubOverwrite
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@datetime::
	AppendAhkCmd(":*:@datetime")
	FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm:ss
	SendInput, %CurrentDateTime%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@ddd::
	AppendAhkCmd(":*:@ddd")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, %CurrentDateTime%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@doRGBa::
	AppendAhkCmd(":*:@doRGBa")
	SendInput, rgba(@rval, @gval, @bval, );{Left 2}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:R*:@findStrFnctns::^[^{\r\n]+{$\r\n(?:^(?<!\}).+$\r\n)+^\}$

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@ppp::
	AppendAhkCmd(":*:@ppp")
	SendInput, news-events_events_.html{Left 5}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@toggleNumpadDiv::
	AppendAhkCmd(":*:@toggleNumpadDiv")
	toggleMsg := "The NumPad / key has been toggled to "
	bitNumpadDivToggle := !bitNumpadDivToggle
	if (bitNumpadDivToggle) {
		toggleMsg .= numpadDivOverwrite
	} else {
		toggleMsg .=  "/"
	}
	MsgBox, % (0x0 + 0x40)
		, % "@toggleNumpadDiv: NumPad / Toggled"
		, % toggleMsg
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@xccc::
	AppendAhkCmd(":*:@xccc")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, / Completed %CurrentDateTime%
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@xsss::
	AppendAhkCmd(":*:@xsss")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, (Started %CurrentDateTime%)
Return

; ··································································································
; >>> Text Input HOTSTRINGS

#Include, %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\guiRepeatChars.ahk

; --------------------------------------------------------------------------------------------------
;   PROGRAM/FILE LAUNCHING SHORTCUTS
; --------------------------------------------------------------------------------------------------

:R*?:runNotepad::
	Run C:\Program Files (x86)\Notepad++\notepad++.exe
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

#z::
	Run notepad++.exe, C:\Program Files (x86)\Notepad++, Max
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@checkHTMLSpec::
	AppendAhkCmd(":*:@checkHTMLSpec")
	Run % userAccountFolderHHD . "\Documents\Daniel\^WSU-Web-Dev\^Master-VPUE\Anatomy of an HTML5 "
		. "Document_2016-03-16.jpg"
Return

; --------------------------------------------------------------------------------------------------
;   FILE SYSTEM NAVIGATION
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\fileSystem.ahk

; --------------------------------------------------------------------------------------------------
;   AUTOHOTKEY SCRIPT WRITING SHORTCUTS
; --------------------------------------------------------------------------------------------------

:*:@insAhkCommentSection::
	AppendAhkCmd(":*:@insAhkCommentSection")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := "; --------------------------------------------------------------------------"
			. "----------------------------------`r; ***EDIT COMMENT TEXT HERE***`r; --------------"
			. "------------------------------------------------------------------------------------"
			. "----------`r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
		Sleep 60
		SendInput, % "{Up 3}{Right 2}"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSection"
			, % "An AutoHotkey comment section can only be inserted if [Notepad++.exe] is the "
			. "active process. Unfortunately, the currently active process is [" . thisProcess 
			. "]."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@insAhkCommentSubSection::
	AppendAhkCmd(":*:@insAhkCommentSubSection")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := "; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  --- "
			. " ---  ---  ---  ---  ---  ---  ---`r; >>> ***EDIT COMMENT TEXT HERE ---  ---  ---  -"
			. "--  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---`r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
		Sleep 60
		SendInput, % "{Up 2}{Right 6}"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSection"
			, % "An AutoHotkey comment section can only be inserted if [Notepad++.exe] is the "
			. "active process. Unfortunately, the currently active process is [" 
			. thisProcess . "]."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@insAhkCommentSeparator::
	AppendAhkCmd(":*:@insAhkCommentSeparator")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := "; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  --- "
			. " ---  ---  ---  ---  ---  ---  ---`r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSeparator"
			, % "An AutoHotkey comment separator can only be inserted if [Notepad++.exe] is the "
			. "active process. Unfortunately, the currently active process is [" 
			. thisProcess . "]."
	}
Return

; --------------------------------------------------------------------------------------------------
;   GOOGLE CHROME SHORTCUTS
; --------------------------------------------------------------------------------------------------

^!o::
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "chrome.exe") {
		WinGetPos, x, y, w, h, A
		SendInput, ^n
		Sleep, 333
		WinMove, A, , x, y, w, h
		Sleep, 200
		SendInput, ^+o
		Sleep, 100
		SendInput, ^!m
		Sleep, 200
		ClipActiveWindowToMonitor()
	} else {
		GoSub, PerformBypassingCtrlAltO
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

PerformBypassingCtrlAltO:
	Suspend
	Sleep, 10
	SendInput, ^!o
	Sleep, 10
	Suspend, Off
Return

; --------------------------------------------------------------------------------------------------
;   NOTEPAD++ SHORTCUTS
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\htmlEditing.ahk

; --------------------------------------------------------------------------------------------------
;   GITHUB SHORTCUTS
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\github.ahk

; --------------------------------------------------------------------------------------------------
;   OTHER SHORTCUTS
; --------------------------------------------------------------------------------------------------

; Shift + Wheel for horizontal scrolling
;+WheelDown::WheelRight
;+WheelUp::WheelLeft

#+X::
	SetKeyDelay, 160, 100
	Send {SPACE 16}
Return

; --------------------------------------------------------------------------------------------------
;   CUSTOM HOTSTRINGS & HOTKEYS
; --------------------------------------------------------------------------------------------------

:*:@copyFromExcel::
	AppendAhkCmd(":*:@copyFromExcel")
	CopyTitleFromExcel(1)
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@testTabRpt::
	AppendAhkCmd(":*:@testTabRpt")
	numRpts := 3
	Send !{TAB %numRpts%}
Return

:*:@deleteSectionBreak::
	AppendAhkCmd(":*:@deleteSectionBreak")
	SendInput, {Enter}
	Sleep, 200
	SendInput, !{Tab}
	Sleep, 200
	SendInput, {Delete}
	Sleep, 100
	SendInput, ^{Enter}
	Sleep, 100
	SendInput, {Left 2}
	Sleep, 100
	SendInput, {Delete}
	Sleep, 100
	SendInput, !{Tab}
	Sleep, 200
Return

^!y::
	Send, +d
	Sleep, 60
	Send, iampoor{Enter}
	Sleep, 60
Return

; --------------------------------------------------------------------------------------------------
;   MAIN SUBROUTINE
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\desktopMain.ahk
