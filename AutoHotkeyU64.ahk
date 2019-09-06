; ==================================================================================================
; AutoHotkeyU64.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Automate coding, opearting system, and file management tasks commonly peformed during
; front-end web development work for the WSU Office of Undergraduate Education (OUE).
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
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: Global variables........................................................................66
;     >>> §1.1: System property globals.........................................................70
;     >>> §1.2: Operation timing globals........................................................93
;     >>> §1.3: Globals for locations of important folders & files.............................102
;     >>> §1.4: Pomodoro work timer globals....................................................112
;     >>> §1.5: Desktop arrangement auditory cue globals.......................................123
;     >>> §1.6: Simulated memory of user actions...............................................135
;     >>> §1.7: Keyboard overriding............................................................153
;     >>> §1.8: Missing AutoHotkey constants...................................................165
;   §2: Set up script & call main subroutine...................................................175
;   §3: Common functions & classes.............................................................197
;   §4: Command history........................................................................213
;   §5: AutoHotkey script writing shortcuts....................................................219
;     >>> §5.1: Hotstrings for inserting code-documentation headers............................223
;   §6: Workspace management...................................................................281
;   §7: File system navigation.................................................................325
;   §8: Program/file launching shortcuts.......................................................331
;     >>> §8.1: Notepad/text editor program....................................................335
;     >>> §8.2: Miscellaneous files............................................................346
;   §9: Powershell scripting...................................................................355
;   §10: Github scripting......................................................................361
;   §11: Google chrome scripting...............................................................367
;   §12: Front-end coding......................................................................424
;   §13: Text replacement & input..............................................................430
;     >>> §13.1: Text Replacement hotkeys......................................................434
;     >>> §13.2: Text Replacement hotstrings...................................................439
;     >>> §13.3: Text Input hotstrings.........................................................536
;   §14: Other shortcuts.......................................................................543
;   §15: Work timer............................................................................556
;   §16: Custom hotstrings & hotkeys...........................................................562
;   §17: Execution entry point.................................................................634
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GLOBAL VARIABLES
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: SYSTEM PROPERTY GLOBALS

global SM_CMONITORS 	:= 80		; Constant needed for retreiving the number of display monitors 
									;  on the desktop via SysGet(...).

global SM_CXSIZEFRAME	:= 32		; SysGet(...) constant needed for retreiving the default window 
									;  border width.

global SM_CYSIZEFRAME 	:= 33		; SysGet(...) constant needed for retreiving the default window 
									;  border height.

global sysNumMonitors				; Number of display monitors on this system.

global sysWinBorderW				; Default border width.

global sysWinBorderH				; Default border height.

global g_maxTries 		:= 10		; Number of attempts at an open-ended goal, such as making a
									; target window active.

global g_osDesktopWinTitle := "ahk_class WorkerW ahk_exe explorer.exe"

;   ································································································
;     >>> §1.2: OPERATION TIMING GLOBALS

global g_delayQuantum		:= 15.6		; Min. amt. of time the Sleep command can wait; 0.0156s
global g_extraShortDelay	:= 3		; An extra short delay of .0468s
global g_shortDelay			:= 7		; A short delay of .1092s
global g_mediumDelay		:= 21		; A medium delay of .3276s
global g_longDelay			:= 63		; A long delay of around 0.9828s

;   ································································································
;     >>> §1.3: GLOBALS FOR LOCATIONS OF IMPORTANT FOLDERS & FILES

global userAccountFolderSSD := "C:"
global userAccountFolderHDD := "E:\Users\CamilleandDaniel"
global relWorkFolder := "\Documents\Daniel"
global ssdWorkFolder := userAccountFolderSSD . relWorkFolder
global hhdWorkFolder := userAccountFolderHDD . relWorkFolder
global webDevFolder := hhdWorkFolder . "\{^}WSU-Web-Dev"

;   ································································································
;     >>> §1.4: POMODORO WORK TIMER GLOBALS

global logFileName := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\Work-log.txt"
global workTimerCountdownTime := -1500000
global workTimeLeftOver := 0
global workTimerMinuteCount := 0
global workTimerNotificationSound := ssdWorkFolder . "\Sound Library\chinese-gong-daniel_simon.wav"
global workTimerMinutesound := ssdWorkFolder . "\Sound Library\Bell-tone_C-4.wav"
global workTimer5MinuteSound := ssdWorkFolder . "\Sound Library\Metal_Gong-Dianakc-109711828.wav"

;   ································································································
;     >>> §1.5: DESKTOP ARRANGEMENT AUDITORY CUE GLOBALS

global windowMovementSound := ssdWorkFolder . "\Sound Library\323413__sethroph__glass-slide-3_-12.5"
. "db_faster.wav"
global windowSizingSound := ssdWorkFolder . "\Sound Library\68222__xtyl33__paper3_-7.5db_faster.wav"
global windowShiftingSound := ssdWorkFolder . "\Sound Library\185849__lloydevans09__warping.wav"
global desktopSwitchingSound := ssdWorkFolder . "\Sound Library\352719__dalesome__woosh-stick-swung"
. "-in-the-air_-15db.wav"
global scriptLoadedSound := ssdWorkFolder . "\Sound Library\Storm_exclamation.wav"
global desktopArrangedSound := ssdWorkFolder . "\Sound Library\zelda_lttp-mstr-swrd.wav"

;   ································································································
;     >>> §1.6: SIMULATED MEMORY OF USER ACTIONS

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
global commitJsCustomJsMsgLog := hhdWorkFolder . "\^WSU-Web-Dev\^Personnel-File\commit-js-custom-js-ms"
. "g-history.txt"

;   ································································································
;     >>> §1.7: KEYBOARD OVERRIDING

global bitNumpadSubToggle := false
global numpadSubOverwrite := "{U+00b7}"
global bitNumpadDivToggle := false
global numpadDivOverwrite := "{U+00b7}"
global npModeExpirationTime := 5 * 60 * 1000

global hotstrStartTime := 0
global hotstrEndTime := 0

;   ································································································
;     >>> §1.8: Missing AutoHotkey Constants

global cmClient
global cmRelative
global cmWindow
global mmFast
global mmRegex
global mmSlow

; --------------------------------------------------------------------------------------------------
;   §2: SET UP SCRIPT & CALL MAIN SUBROUTINE
; --------------------------------------------------------------------------------------------------

#NoEnv
#SingleInstance
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
Process, Priority, , High
SetTitleMatchMode, 2
CoordMode, Mouse, Client
FileEncoding, UTF-8
StartScript()

; --------------------------------------------------------------------------------------------------
;   §3: COMMON FUNCTIONS & CLASSES
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GUIs\guiControlHandler.ahk

#Include %A_ScriptDir%\GUIs\guiMsgBox.ahk

#Include %A_ScriptDir%\Functions\API_GetWindowInfo.ahk

#Include %A_ScriptDir%\Functions\functions.ahk

#Include %A_ScriptDir%\Functions\trie.ahk

#Include %A_ScriptDir%\Functions\cfgFile.ahk

; --------------------------------------------------------------------------------------------------
;   §4: COMMAND HISTORY
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\Functions\commandHistory.ahk

; --------------------------------------------------------------------------------------------------
;   §5: AUTOHOTKEY SCRIPT WRITING SHORTCUTS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: Hotstrings for inserting code-documentation headers

:*:@insAhkCommentSection::
	AppendAhkCmd(A_ThisLabel)
	editor := "sublime_text.exe"
	if (isTargetProcessActive(editor, A_ThisLabel, "An AutoHotkey comment section can only be inser"
			. "ted if [" . editor . "] is the active process. Currently, the active process is ["
			. getActiveProcessName() . "].")) {
		commentTxt := "; --------------------------------------------------------------------------"
			. "----------------------------------`r;   ***EDIT COMMENT TEXT HERE***`r; ------------"
			. "------------------------------------------------------------------------------------"
			. "------------`r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
			Sleep % delay
		}
		SendInput, % "^v"
		execDelayer.Wait( "xShort" )
		SendInput, % "{Up 3}{Right 2}"
	}
Return

:*:@insAhkCommentSubSection::
	AppendAhkCmd(A_ThisLabel)
	editor := "sublime_text.exe"
	if (isTargetProcessActive(editor, A_ThisLabel, "An AutoHotkey comment section can only be inser"
			. "ted if [" . editor . "] is the "
			. "active process. Unfortunately, the currently active process is ["
			. getActiveProcessName() . "].")) {
		commentTxt := "; ··········································································"
			. "························`r;   >>> ***EDIT COMMENT TEXT HERE`r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
			execDelayer.Wait( "xShort" )
		}
		SendInput, % "^v"
		execDelayer.Wait( "xShort" )
		SendInput, % "{Up 2}{Right 6}"
	}
Return

:*:@insAhkCommentSeparator::
	AppendAhkCmd(":*:@insAhkCommentSeparator")
	editor := "sublime_text.exe"
	if (isTargetProcessActive(editor, A_ThisLabel, "An AutoHotkey comment separator can only be ins"
			. "erted if [" . editor . "] is the active process. Unfortunately, the currently active"
			. " process is [" . getActiveProcessName() . "].")) {
		commentTxt := ";  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·"
			. " · · · · · · · · · · · · `r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
			execDelayer.Wait( "xShort" )
		}
		SendInput, % "^v"
	}
Return

; --------------------------------------------------------------------------------------------------
;   §6: WORKSPACE MANAGEMENT
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\WorkspaceManagement\virtualDesktops.ahk

#Include %A_ScriptDir%\WorkspaceManagement\workspaceManagement.ahk

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
;   §7: FILE SYSTEM NAVIGATION
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\WorkspaceManagement\fileSystem.ahk

; --------------------------------------------------------------------------------------------------
;   §8: PROGRAM/FILE LAUNCHING SHORTCUTS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §8.1: NOTEPAD/TEXT EDITOR PROGRAM

:*:@runZoom::
	Run C:\Users\danie\AppData\Roaming\Zoom\bin\Zoom.exe
Return

#z::
	Gosub :*:@runZoom
Return

;   ································································································
;     >>> §8.2: MISCELLANEOUS FILES

:*:@checkHTMLSpec::
	AppendAhkCmd(":*:@checkHTMLSpec")
	Run % userAccountFolderHHD . "\Documents\Daniel\^WSU-Web-Dev\^Master-VPUE\Anatomy of an HTML5 "
		. "Document_2016-03-16.jpg"
Return

; --------------------------------------------------------------------------------------------------
;   §9: POWERSHELL SCRIPTING
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\PowerShell\PowerShell.ahk

; --------------------------------------------------------------------------------------------------
;   §10: GITHUB SCRIPTING
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\github.ahk

; --------------------------------------------------------------------------------------------------
;   §11: GOOGLE CHROME SCRIPTING
; --------------------------------------------------------------------------------------------------

^!o::
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "chrome.exe") {
		WinGet, chromeHwnd, ID, A
		WinGet, minMaxState, minMax, A
		if (minMaxState == 0) {
			ctrlAltO_OpenChromeBookmarks(chromeHwnd)
		} else if (minMaxState == 1) {
			ctrlAltO_OpenMaxedChromeBookmarks(chromeHwnd)
		}
	} else {
		GoSub, PerformBypassingCtrlAltO
	}
Return

ctrlAltO_OpenChromeBookmarks(chromeHwnd) {
	waitingBeat := 100
	WinGetPos, x, y, w, h, % "ahk_id " . chromeHwnd
	Sleep, % waitingBeat
	SendInput, ^n
	Sleep, % waitingBeat * 3
	WinMove, A, , %x%, %y%, %w%, %h%
	Sleep, % waitingBeat * 2
	SendInput, ^+o
	Sleep, % waitingBeat
	SendInput, ^!m
	Sleep, % waitingBeat * 2
	ClipActiveWindowToMonitor()
}

ctrlAltO_OpenMaxedChromeBookmarks(chromeHwnd) {
	waitingBeat := 100
	Sleep, % waitingBeat
	SendInput, ^n
	Sleep, % waitingBeat * 3
	SendInput, ^+o
	Sleep, % waitingBeat * 3
	activeMon := FindNearestActiveMonitor()
	if (activeMon == 1) {
		SendInput, +#{Right}
	} else {
		SendInput, +#{Left}
	}
}

PerformBypassingCtrlAltO:
	Suspend
	Sleep, 10
	SendInput, ^!o
	Sleep, 10
	Suspend, Off
Return

; --------------------------------------------------------------------------------------------------
;   §12: FRONT-END CODING
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\Coding\frontEndCoding.ahk

; --------------------------------------------------------------------------------------------------
;   §13: TEXT REPLACEMENT & INPUT
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §13.1: Text Replacement HOTKEYS

#Include %A_ScriptDir%\TextInput\numpadModifier.ahk

;   ································································································
;     >>> §13.2: Text Replacement HOTSTRINGS

#Include %A_ScriptDir%\TextInput\regExStrings.ahk

:*:@a5lh::
	AppendAhkCmd(A_ThisLabel)
	SendInput, {Enter 5}
Return

:*:@addClass::class=""{Space}{Left 2}

:*:@addNrml::{Space}class="oue-normal"

:*:@changeNumpadDiv::
	AppendAhkCmd(A_ThisLabel)
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

:*:@changeNumpadSub::
	AppendAhkCmd(A_ThisLabel)
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

:*:@datetime::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm:ss
	SendInput, %CurrentDateTime%
Return

:*:@ddd::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime, , yyyy-MM-dd
	SendInput, %CurrentDateTime%
Return

:*:@doRGBa::
	AppendAhkCmd(A_ThisLabel)
	SendInput, rgba(@rval, @gval, @bval, );{Left 2}
Return

:R*:@findStrFnctns::^[^{\r\n]+{$\r\n(?:^(?<!\}).+$\r\n)+^\}$

:*:@ppp::
	AppendAhkCmd(A_ThisLabel)
	SendInput, news-events_events_.html{Left 5}
Return

:*:@shrug::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "¯\_(·_·)_/¯"
Return

:*:@ttt::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime, , HH-mm-ss
	SendInput, %CurrentDateTime%
Return

:*:@ttc::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime, , HH:mm:ss
	SendInput, %CurrentDateTime%
Return

:*:@xccc::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, / Completed %CurrentDateTime%
Return

:*:@xsss::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, (Started %CurrentDateTime%)
Return

;   ································································································
;     >>> §13.3: Text Input HOTSTRINGS

#Include %A_ScriptDir%\TextInput\guiRepeatChars.ahk

#Include %A_ScriptDir%\TextInput\guiRepeatInputs.ahk

; --------------------------------------------------------------------------------------------------
;   §14: OTHER SHORTCUTS
; --------------------------------------------------------------------------------------------------

; Shift + Wheel for horizontal scrolling
;+WheelDown::WheelRight
;+WheelUp::WheelLeft

#+X::
	SetKeyDelay, 160, 100
	Send {SPACE 16}
Return

; --------------------------------------------------------------------------------------------------
;   §15: WORK TIMER
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\workTimer.ahk

; --------------------------------------------------------------------------------------------------
;   §16: CUSTOM HOTSTRINGS & HOTKEYS
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\localOnly.ahk

:*:@copyFromExcel::
	AppendAhkCmd(A_ThisLabel)
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
;   §17: EXECUTION ENTRY POINT
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\execEntryPoint.ahk
