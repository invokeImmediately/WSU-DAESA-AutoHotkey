; ==================================================================================================
; ▄▀▀▄ █  █▐▀█▀▌▄▀▀▄ █  █ ▄▀▀▄▐▀█▀▌█ ▄▀ █▀▀▀ █  █ █  █ ▄▀▀▄ ▄▀█   ▄▀▀▄ █  █ █ ▄▀ 
; █▄▄█ █  █  █  █  █ █▀▀█ █  █  █  █▀▄  █▀▀  ▀▄▄█ █  █ █▄▄ ▐▄▄█▌  █▄▄█ █▀▀█ █▀▄  
; █  ▀  ▀▀   █   ▀▀  █  ▀  ▀▀   █  ▀  ▀▄▀▀▀▀ ▄▄▄▀  ▀▀  ▀▄▄▀   █ ▀ █  ▀ █  ▀ ▀  ▀▄
; --------------------------------------------------------------------------------------------------
; AutoHotkey script for automation of coding, operating system control, window management, and file
;   management tasks commonly peformed during front-end web development work for the Division of
;   Academic Engagement and Student Achievement (DAESA) at WSU.
;
; Formerly, this project was conducted by the Office of Undergraduate Education (OUE), which was
;   combined with the Office of Academic Engagement to form DAESA.
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey
; @license MIT Copyright (c) 2020 Daniel C. Rieck.
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
;   §1: Global variables........................................................................65
;     >>> §1.1: System property globals.........................................................69
;     >>> §1.2: Operation timing globals........................................................92
;     >>> §1.3: Globals for locations of important folders & files.............................101
;     >>> §1.4: Pomodoro work timer globals....................................................125
;     >>> §1.5: Desktop arrangement auditory cue globals.......................................136
;     >>> §1.6: Simulated memory of user actions...............................................148
;     >>> §1.7: Keyboard overriding............................................................159
;     >>> §1.8: Missing AutoHotkey constants...................................................171
;   §2: Set up script & call main subroutine...................................................181
;   §3: Common functions & classes.............................................................203
;   §4: Command history........................................................................214
;   §5: AutoHotkey script writing shortcuts....................................................220
;     >>> §5.1: Hotstrings for inserting code-documentation headers............................224
;   §6: Workspace management...................................................................282
;   §7: File system navigation.................................................................326
;   §8: Program/file launching shortcuts.......................................................332
;     >>> §8.1: Notepad/text editor program....................................................336
;     >>> §8.2: Miscellaneous files............................................................347
;   §9: Powershell scripting...................................................................356
;   §10: Github scripting......................................................................362
;   §11: Google chrome scripting...............................................................368
;   §12: Front-end coding......................................................................425
;   §13: Text replacement & input..............................................................431
;     >>> §13.1: Text Replacement hotkeys......................................................435
;     >>> §13.2: Text Replacement hotstrings...................................................440
;     >>> §13.3: Text Input hotstrings.........................................................447
;   §14: Other shortcuts.......................................................................454
;   §15: Work timer............................................................................467
;   §16: Custom hotstrings & hotkeys...........................................................473
;   §17: Execution entry point.................................................................545
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GLOBAL VARIABLES
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: SYSTEM PROPERTY GLOBALS

; Constant needed for retreiving the number of display monitors on the desktop via SysGet(...).
global SM_CMONITORS 	:= 80		

; SysGet(...) constants needed for retreiving the default window border width and height.
global SM_CXSIZEFRAME	:= 32
global SM_CYSIZEFRAME 	:= 33

; Number of display monitors on this system.
global sysNumMonitors

; Default border width and height.
global sysWinBorderW
global sysWinBorderH

; Number of attempts at an open-ended goal, such as making a target window active.
global g_maxTries := 10

; WinTitle parameter for identifying when the desktop process is the active window.
global g_osDesktopWinTitle := "ahk_class WorkerW ahk_exe explorer.exe"

;   ································································································
;     >>> §1.2: OPERATION TIMING GLOBALS

global g_delayQuantum			:= 15.6		; Min. amt. of time the Sleep command can wait; 0.0156s
global g_extraShortDelay	:= 3			; An extra short delay of .0468s
global g_shortDelay				:= 7			; A short delay of .1092s
global g_mediumDelay			:= 21			; A medium delay of .3276s
global g_longDelay				:= 63			; A long delay of around 0.9828s

;   ································································································
;     >>> §1.3: GLOBALS FOR LOCATIONS OF IMPORTANT FOLDERS & FILES

; TODO: Currently, the following variables are based on the author's idiosyncratic approach to
;  organizing files on his local system. In his current scheme, the OS is installed on a SSD,
;  whereas file storage is relegated to a HDD. Consequently, the following global variables were
;  originally created as file path components for use in the script to build paths to specific file
;  system locations based on a developer-changeable root specification. However, this approach is
;  not ideal due to the issue of the system-specific nature of the underlying scheme; a better
;  method would be to use a script configuration file containing paths to specific components that
;  can more be easily updated for use on a different system.
global userAccountFolderSSD := "C:"
global userAccountFolderHDD := "E:\Users\CamilleandDaniel"
global relWorkFolder := "\Documents\Daniel"
global ssdWorkFolder := userAccountFolderSSD . relWorkFolder
global hhdWorkFolder := userAccountFolderHDD . relWorkFolder
global webDevFolder := hhdWorkFolder . "\{^}WSU-Web-Dev"

; File system locations of git message logs
global commitCssLessMsgLog		:= A_ScriptDir . "\Config\commit-css-less-msg-history.txt"
global commitAnyFileMsgLog		:= A_ScriptDir . "\Config\commit-any-file-msg-history.txt"
global commitJsCustomJsMsgLog	:= A_ScriptDir . "\Config\commit-js-custom-js-msg-history.txt"
global g_VimyModeIconPath := A_ScriptDir . "\Images\Vim-logo_64w64h.png"

;   ································································································
;     >>> §1.4: POMODORO WORK TIMER GLOBALS

global logFileName								:= A_ScriptDir . "\Config\workTimerLog.txt"
global workTimerCountdownTime			:= -1500000
global workTimeLeftOver						:= 0
global workTimerMinuteCount				:= 0
global workTimerNotificationSound	:= A_ScriptDir . "\Sounds\chinese-gong-daniel_simon.wav"
global workTimerMinutesound				:= A_ScriptDir . "\Sounds\Bell-tone_C-4.wav"
global workTimer5MinuteSound			:= A_ScriptDir . "\Sounds\Metal_Gong-Dianakc-109711828.wav"

;   ································································································
;     >>> §1.5: DESKTOP ARRANGEMENT AUDITORY CUE GLOBALS

global windowMovementSound		:= A_ScriptDir . "\Sounds\323413__sethroph__glass-slide-3_-12.5"
																. "db_faster.wav"
global windowSizingSound			:= A_ScriptDir . "\Sounds\68222__xtyl33__paper3_-7.5db_faster.wav"
global windowShiftingSound		:= A_ScriptDir . "\Sounds\185849__lloydevans09__warping.wav"
global desktopSwitchingSound	:= A_ScriptDir . "\Sounds\352719__dalesome__woosh-stick-swung"
																. "-in-the-air_-15db.wav"
global scriptLoadedSound			:= A_ScriptDir . "\Sounds\Storm_exclamation.wav"
global desktopArrangedSound		:= A_ScriptDir . "\Sounds\zelda_lttp-mstr-swrd.wav"

;   ································································································
;     >>> §1.6: SIMULATED MEMORY OF USER ACTIONS

global cmdHistoryLog	:= A_ScriptDir . "\Config\ahk-cmd-history.txt"
global ahkCmds				:= Array()
global ahkCmdLimit		:= 140
global CmdChosen
global savedMouseX		:= 0
global savedMouseY		:= 0
global lineLength			:= 125

;   ································································································
;     >>> §1.7: KEYBOARD OVERRIDING

global bitNumpadSubToggle		:= false
global numpadSubOverwrite		:= "{U+00b7}"
global bitNumpadDivToggle		:= false
global numpadDivOverwrite		:= "{U+00b7}"
global npModeExpirationTime	:= 5 * 60 * 1000

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

:*?:@insAhkCommentSection::
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

:*?:@insAhkCommentSubSection::
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

:*?:@insAhkCommentSeparator::
	AppendAhkCmd(":*?:@insAhkCommentSeparator")
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

:*?:@toggleOverlayMode::
	AppendAhkCmd(":*?:@toggleOverlayMode")
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

:*?:@toggleAOT::
	AppendAhkCmd(":*?:@toggleAOT")
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

:*?:@runZoom::
	Run C:\Users\danie\AppData\Roaming\Zoom\bin\Zoom.exe
Return

#z::
	Gosub :*?:@runZoom
Return

;   ································································································
;     >>> §8.2: MISCELLANEOUS FILES

:*?:@checkHTMLSpec::
	AppendAhkCmd(":*?:@checkHTMLSpec")
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

#Include %A_ScriptDir%\TextInput\textReplacement.ahk

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

#Include %A_ScriptDir%\GUIs\workTimer.ahk

; --------------------------------------------------------------------------------------------------
;   §16: CUSTOM HOTSTRINGS & HOTKEYS
; --------------------------------------------------------------------------------------------------

#Include *i %A_ScriptDir%\localOnly.ahk

:*?:@copyFromExcel::
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

:*?:@testTabRpt::
	AppendAhkCmd(":*?:@testTabRpt")
	numRpts := 3
	Send !{TAB %numRpts%}
Return

:*?:@deleteSectionBreak::
	AppendAhkCmd(":*?:@deleteSectionBreak")
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
