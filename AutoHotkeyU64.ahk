; ==================================================================================================
; AutoHotkeyU64.ahk: Script for automating tasks peformed during WSU OUE web development.
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: GLOBAL VARIABLES........................................................................39
;     >>> §1.1: SYSTEM PROPERTY GLOBALS.........................................................43
;     >>> §1.2: OPERATOIN TIMING GLOBALS........................................................65
;     >>> §1.3: GLOBALS FOR LOCATIONS OF IMPORTANT FOLDERS & FILES..............................74
;     >>> §1.4: POMODORO WORK TIMER GLOBALS.....................................................84
;     >>> §1.5: DESKTOP ARRANGEMENT AUDITORY CUE GLOBALS........................................95
;     >>> §1.6: SIMULATED MEMORY OF USER ACTIONS...............................................107
;     >>> §1.7: KEYBOARD OVERRIDING............................................................125
;   §2: SET UP SCRIPT & CALL MAIN SUBROUTINE...................................................136
;   §3: COMMON FUNCTIONS & CLASSES.............................................................157
;   §4: COMMAND HISTORY........................................................................169
;   §5: AUTOHOTKEY SCRIPT WRITING SHORTCUTS....................................................175
;     >>> §5.1: Hotstrings for inserting code-documentation headers............................179
;     >>> §5.2: Hotstrings for inserting AHK-related RegEx find/replace strings................248
;   §6: WORKSPACE MANAGEMENT...................................................................268
;   §7: FILE SYSTEM NAVIGATION.................................................................312
;   §8: PROGRAM/FILE LAUNCHING SHORTCUTS.......................................................318
;   §9: GITHUB SHORTCUTS.......................................................................340
;   §10: GOOGLE CHROME SHORTCUTS...............................................................346
;   §11: HTML EDITING..........................................................................405
;   §12: TEXT REPLACEMENT & INPUT..............................................................411
;     >>> §12.1: Text Replacement HOTKEYS......................................................415
;     >>> §12.2: Text Replacement HOTSTRINGS...................................................420
;     >>> §12.3: Text Input HOTSTRINGS.........................................................511
;   §13: OTHER SHORTCUTS.......................................................................518
;   §14: WORK TIMER............................................................................531
;   §15: CUSTOM HOTSTRINGS & HOTKEYS...........................................................537
;   §16: MAIN SUBROUTINE.......................................................................609
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


;   ································································································
;     >>> §1.2: OPERATION TIMING GLOBALS

global g_delayQuantum		:= 15.6		; Minimum amount of time the Sleep command can wait.
global g_extraShortDelay	:= 3		; An extra short delay of around .05 s
global g_shortDelay			:= 7		; A short delay of around .1 s
global g_mediumDelay		:= 21		; A medium delay of around .3 s
global g_longDelay			:= 63		; A long delay of around 1 s

;   ································································································
;     >>> §1.3: GLOBALS FOR LOCATIONS OF IMPORTANT FOLDERS & FILES

global userAccountFolderSSD := "C:\Users\CamilleandDaniel"
global userAccountFolderHDD := "F:\Users\CamilleandDaniel"
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

global hotstrStartTime := 0
global hotstrEndTime := 0

; --------------------------------------------------------------------------------------------------
;   §2: SET UP SCRIPT & CALL MAIN SUBROUTINE
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
;   §3: COMMON FUNCTIONS & CLASSES
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\guiMsgBox.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\API_GetWindowInfo.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\functions.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\trie.ahk

; --------------------------------------------------------------------------------------------------
;   §4: COMMAND HISTORY
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\commandHistory.ahk

; --------------------------------------------------------------------------------------------------
;   §5: AUTOHOTKEY SCRIPT WRITING SHORTCUTS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: Hotstrings for inserting code-documentation headers

:*:@insAhkCommentSection::
	AppendAhkCmd(":*:@insAhkCommentSection")
	editor := "sublime_text.exe"
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = editor) {
		commentTxt := "; --------------------------------------------------------------------------"
			. "----------------------------------`r;   ***EDIT COMMENT TEXT HERE***`r; ------------"
			. "------------------------------------------------------------------------------------"
			. "------------`r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
		Sleep 60
		SendInput, % "{Up 3}{Right 2}"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSection"
			, % "An AutoHotkey comment section can only be inserted if [" . editor . "] is the "
			. "active process. Unfortunately, the currently active process is [" . thisProcess 
			. "]."
	}
Return

:*:@insAhkCommentSubSection::
	AppendAhkCmd(":*:@insAhkCommentSubSection")
	editor := "sublime_text.exe"
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = editor) {
		commentTxt := "; ··········································································"
			. "························`r;   >>> ***EDIT COMMENT TEXT HERE`r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
		Sleep 60
		SendInput, % "{Up 2}{Right 6}"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSection"
			, % "An AutoHotkey comment section can only be inserted if [" . editor . "] is the "
			. "active process. Unfortunately, the currently active process is [" 
			. thisProcess . "]."
	}
Return

:*:@insAhkCommentSeparator::
	AppendAhkCmd(":*:@insAhkCommentSeparator")
	editor := "sublime_text.exe"
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = editor) {
		commentTxt := ";  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·"
			. " · · · · · · · · · · · · `r`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSeparator"
			, % "An AutoHotkey comment separator can only be inserted if [" . editor . "] is the "
			. "active process. Unfortunately, the currently active process is [" 
			. thisProcess . "]."
	}
Return

;   ································································································
;     >>> §5.2: Hotstrings for inserting AHK-related RegEx find/replace strings

:*:@findStrAhkTocSections1::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "(?:{^}; -{{}98{}}$\n; {{}3{}}.{+}$\n{^}; -{{}98{}}$)|(?:{^}; {{}3{}}·{{}96{}}$\n{"
		. "^}; {{}5{}}>>> .*$)|(?:{^}; {{}5{}}(?: ·){{}47{}}$\n{^}; {{}7{}}→→→ .*$)"
Return

:*:@findStrAhkTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "{^} {{}1,{}}([0-9]{{}1,{}}): (; {{}3{}}.*§.{+})$"
Return

:*:@replStrAhkTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "\1\2............................................................................."
		. ".........."
Return

; --------------------------------------------------------------------------------------------------
;   §6: WORKSPACE MANAGEMENT
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\virtualDesktops.ahk

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

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\fileSystem.ahk

; --------------------------------------------------------------------------------------------------
;   §8: PROGRAM/FILE LAUNCHING SHORTCUTS
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
;   §9: GITHUB SHORTCUTS
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\github.ahk

; --------------------------------------------------------------------------------------------------
;   §10: GOOGLE CHROME SHORTCUTS
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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

PerformBypassingCtrlAltO:
	Suspend
	Sleep, 10
	SendInput, ^!o
	Sleep, 10
	Suspend, Off
Return

; --------------------------------------------------------------------------------------------------
;   §11: HTML EDITING
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\htmlEditing.ahk

; --------------------------------------------------------------------------------------------------
;   §12: TEXT REPLACEMENT & INPUT
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §12.1: Text Replacement HOTKEYS

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\numpadModifier.ahk

;   ································································································
;     >>> §12.2: Text Replacement HOTSTRINGS

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\regExStrings.ahk

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
	SendInput, % "¯\_(ツ)_/¯"
Return

:*:@ttt::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime, , HH-mm-ss
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
;     >>> §12.3: Text Input HOTSTRINGS

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\guiRepeatChars.ahk

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\guiRepeatInputs.ahk

; --------------------------------------------------------------------------------------------------
;   §13: OTHER SHORTCUTS
; --------------------------------------------------------------------------------------------------

; Shift + Wheel for horizontal scrolling
;+WheelDown::WheelRight
;+WheelUp::WheelLeft

#+X::
	SetKeyDelay, 160, 100
	Send {SPACE 16}
Return

; --------------------------------------------------------------------------------------------------
;   §14: WORK TIMER
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\workTimer.ahk

; --------------------------------------------------------------------------------------------------
;   §15: CUSTOM HOTSTRINGS & HOTKEYS
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\localOnly.ahk

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
;   §16: MAIN SUBROUTINE
; --------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\desktopMain.ahk
