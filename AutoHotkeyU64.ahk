; ============================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; TABLE OF CONTENTS
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
;   Global Variables: 19  •  Workspace Management: 27  •  Utility Functions: 289  •  Text Replacement: 517
;   Program/File Launching Shortcuts: 577  •  File System Navigation: 595  •  Google Chrome Shorctuts: 645
;   Github Shortcuts: 670
; ============================================================================================================

Gosub, MainSubroutine

;   --------------------------------------------------------------------------------------------------------
;   GLOBAL VARIABLES
;   --------------------------------------------------------------------------------------------------------

global userAccountFolder := "C:\Users\CamilleandDaniel"
global logFileName := userAccountFolder . "\Documents\Daniel\^WSU-Web-Dev\^Personnel-File\Work-log.txt"
global workTimerCountdownTime := -1200000
global workTimeLeftOver := 0
global workTimerNotificationSound := userAccountFolder . "\Documents\Daniel\Sound Library\foghorn.wav"
global windowMovementSound := userAccountFolder . "\Documents\Daniel\Sound Library\323413__sethroph__glass-slide-3_-12.5db_faster.wav"
global windowSizingSound := userAccountFolder . "\Documents\Daniel\Sound Library\68222__xtyl33__paper3_-7.5db_faster.wav"
global windowShiftingSound := userAccountFolder . "\Documents\Daniel\Sound Library\185849__lloydevans09__warping.wav"
global desktopSwitchingSound := userAccountFolder . "\Documents\Daniel\Sound Library\352719__dalesome__woosh-stick-swung-in-the-air_-15db.wav"
global bitAccentToggle := false
global accentOverwrite := "{U+00b7}"
global ahkCmds := Array()
global ahkCmdLimit := 36
global CmdChosen
global hotstrStartTime := 0
global hotstrEndTime := 0
global savedMouseX := 0
global savedMouseY := 0

#NoEnv
#SingleInstance

If not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\functions.ahk

;   --------------------------------------------------------------------------------------------------------
;   COMMAND HISTORY
;   --------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\commandHistory.ahk

;   --------------------------------------------------------------------------------------------------------
;   WORKSPACE MANAGEMENT
;   --------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\workspaceMngmnt.ahk

;   --------------------------------------------------------------------------------------------------------
;   WORK TIMER scripts for tracking hours and indicating when breaks should be taken
;   --------------------------------------------------------------------------------------------------------

:*:@setupWorkTimer::
	AppendAhkCmd(":*:@setupWorkTimer")
	
	logFile := FileOpen(logFileName, "r `n")
	lineCount := 0
	logFileLines := Object()
	Loop
	{
		logFileLines[lineCount] := logFile.ReadLine()
		if (logFileLines[lineCount] = "") {
			break
		}
		lineCount := lineCount + 1
	}
	logFile.Close()
	FormatTime, todaysDate, A_Now, yyyy-MM-dd
	lineIndex := lineCount - 1
	dateFoundInFile := false
	Loop
	{
		if (lineIndex < 0) {
			break
		}
		dateOfLine := SubStr(logFileLines[lineIndex], 1, 10)
		if (dateOfLine = todaysDate) {
			dateFoundInFile := true
			break
		} else if (dateOfLine < todaysDate) {
			break
		}
		lineIndex := lineIndex - 1
	}
	if (dateFoundInFile) {
		MsgBox % 3, % "Continue Tracking Time?", % "It looks like work time was already logged for today. Would you like to restart the timer, counting the intervening time as a break?"
		IfMsgBox Yes
		{
			; Find the end time, use that for break time.
			lineSubIndex := lineIndex
			Loop
			{
				if (lineSubIndex < 0) {
					break
				}
				lineSubStr := SubStr(logFileLines[lineSubIndex], 13, 20)
				if (lineSubStr = "Ended work timer at ") {
					timerEndTime := A_YYYY . A_MM . A_DD . SubStr(logFileLines[lineSubIndex], 33, 2) . SubStr(logFileLines[lineSubIndex], 36, 2) . SubStr(logFileLines[lineSubIndex], 39, 2)
					timerTimeWorked := SubStr(logFileLines[lineSubIndex], 73, 8) * 3600
					break
				} else if (dateOfLine < todaysDate) {
					break
				}
				lineSubIndex := lineSubIndex - 1
			}
			
			; Find the start time, continuing from before.
			Loop
			{
				if (lineSubIndex < 0) {
					break
				}
				lineSubStr := SubStr(logFileLines[lineSubIndex], 13, 22)
				if (lineSubStr = "Started work timer at ") {
					timerStartTime := A_YYYY . A_MM . A_DD . SubStr(logFileLines[lineSubIndex], 35, 2) . SubStr(logFileLines[lineSubIndex], 38, 2) . SubStr(logFileLines[lineSubIndex], 41, 2)
					break
				} else if (dateOfLine < todaysDate) {
					break
				}
				lineSubIndex := lineSubIndex - 1
			}
			
			; Back-calculate the total break time, and proceed with the timer.
			timeElapsed := timerEndTime
			EnvSub, timeElapsed, %timerStartTime%, seconds
			timerTotalBreakTime := timeElapsed - timerTimeWorked
			timerBreakTime := A_Now
			EnvSub, timerBreakTime, %timerEndTime%, seconds
			EnvAdd, timerTotalBreakTime, %timerBreakTime%
			logFile := FileOpen(logFileName, "a `n")
			logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Restarted work timer at " . A_Hour . ":" . A_Min . ":" . A_Sec )
			logFile.Close()
			workTimeLeftOver := workTimerCountdownTime + Mod(timerTimeWorked * 1000, -1 * workTimerCountdownTime)
			SetTimer, PostWorkBreakMessage, %workTimeLeftOver%
			latestTimerStartTime := A_Now
			workTimerRunning := true
		}
		Else IfMsgBox No
		{
			MsgBox, 1, Starting New Work Timer, A new work timer will be set to run for 20 minutes to indicate when you should next take a break.
			IfMsgBox OK
			{
				logFile := FileOpen(logFileName, "a `n")
				timerStartTime := A_Now
				timerTotalBreakTime := 0
				logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Started work timer at " . A_Hour . ":" . A_Min . ":" . A_Sec )
				logFile.Close()
				SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
				latestTimerStartTime := A_Now
				workTimerRunning := true
			}			
		}
	} else {
		MsgBox, 1, Starting Work Timer, A work timer will be set to run for 20 minutes to indicate when you should next take a break.
		IfMsgBox OK
		{
			logFile := FileOpen(logFileName, "a `n")
			timerStartTime := A_Now
			timerTotalBreakTime := 0
			logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Started work timer at " . A_Hour . ":" . A_Min . ":" . A_Sec )
			logFile.Close()
			SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
			latestTimerStartTime := A_Now
			workTimerRunning := true
		}
	}
Return

PostWorkBreakMessage:
	timerEndTime := A_Now
	timerTimeWorked := timerEndTime
	EnvSub, timerTimeWorked, %timerStartTime%, seconds
	timerTimeWorked := timerTimeWorked / 3600 - timerTotalBreakTime / 3600    
	SoundPlay, %workTimerNotificationSound%
	MsgBox, 4, Work Break Timer, % "You have spent the last 20 minutes working; it's time to take a break.`nTime worked so far: " . timerTimeWorked  . " hours.`nWould you like to start another 20 minute timer?"
	logFile := FileOpen(logFileName, "a `n")
	IfMsgBox Yes
	{
		timerBreakTime := A_Now
		EnvSub, timerBreakTime, %timerEndTime%, seconds
		EnvAdd, timerTotalBreakTime, %timerBreakTime%
		FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
		logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended break at " . timerEndTimeHMS . " for " . (timerBreakTime / 60) . " minutes. Cumulative time worked today: " . timerTimeWorked . " hours")
		FormatTime, timerRestartHMS, , HH:mm:ss
		logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Restarted work timer at " . timerRestartHMS )
		logFile.Close()
		SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
		latestTimerStartTime := A_Now
		workTimerRunning := true
	}
	Else {
		timerBreakTime := timerTimeWorked
		EnvSub, timerBreakTime, %timerEndTime%, seconds
		EnvAdd, timerTotalBreakTime, %timerBreakTime%
		FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
		logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended work timer at " . timerEndTimeHMS . ". Cumulative time worked today: " . timerTimeWorked . " hours")
		logFile.Close()    
		workTimerRunning := false
	}
	workTimeLeftOver := 0
Return

:*:@stopWorkTimer::
	AppendAhkCmd(":*:@stopWorkTimer")
	if (workTimerRunning) {
		MsgBox % 3, % "Stop work timer?", % "Would you like to stop your 20 minute work timer prematurely?"
		IfMsgBox Yes
		{
			logFile := FileOpen(logFileName, "a `n")
			timerTimeWorked := A_Now
			EnvSub, timerTimeWorked, %timerStartTime%, seconds
			timerTimeWorked := timerTimeWorked / 3600 - timerTotalBreakTime / 3600
			FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
			logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended work timer at " . timerEndTimeHMS . ". Cumulative time worked today: " . timerTimeWorked . " hours")
			logFile.Close()    
			SetTimer, PostWorkBreakMessage, Delete
			workTimerRunning := false
		}
	} else {
		MsgBox % 1, % "Stop work timer?", % "No work timer is currently running."
	}
Return

:*:@checkWorkTimer::
	AppendAhkCmd(":*:@checkWorkTimer")
	if (workTimerRunning) {
		timerTimeLeft := A_Now
		EnvSub, timerTimeLeft, %latestTimerStartTime%, seconds
		if (workTimeLeftOver != 0) {
			timerTimeLeft := (-1 * workTimeLeftOver / 1000 - timerTimeLeft) / 60
		}
		else {
			timerTimeLeft := (-1 * workTimerCountdownTime / 1000 - timerTimeLeft) / 60
		}
		MsgBox % 1, % "Check Work Timer", % "There are " . timerTimeLeft . " minutes left on the work timer."
	}
Return

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


;   --------------------------------------------------------------------------------------------------------
;   TEXT REPLACEMENT
;   --------------------------------------------------------------------------------------------------------

:*:@ddd::
	AppendAhkCmd(":*:@ddd")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, %CurrentDateTime%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@datetime::
	AppendAhkCmd(":*:@datetime")
	FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm:ss
	SendInput, %CurrentDateTime%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@xsss::
	AppendAhkCmd(":*:@xsss")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, (Started %CurrentDateTime%)
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@xccc::
	AppendAhkCmd(":*:@xccc")
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, / Completed %CurrentDateTime%
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@ppp::
	AppendAhkCmd(":*:@ppp")
	SendInput, news-events_events_.html{Left 5}
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@add5lineshere::
	AppendAhkCmd(":*:@add5lineshere")
	SendInput, {Enter 5}
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@doRGBa::
	AppendAhkCmd(":*:@doRGBa")
	SendInput, rgba(@rval, @gval, @bval, );{Left 2}
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@addNrml::{Space}class="oue-normal"

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@addClass::class=""{Space}{Left 2}

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@toggleAccentKey::
	AppendAhkCmd(":*:@toggleAccentKey")
	bitAccentToggle := !bitAccentToggle
Return

^+`::
	Gosub :*:@toggleAccentKey
Return

:*:``::
	if (bitAccentToggle) {
		SendInput, % accentOverwrite
	}
	else {
		SendInput, ``
	}
Return

:*:@changeAccentOverwrite::
	AppendAhkCmd(":*:@changeAccentOverwrite")
	Inputbox, inputEntered, % "Change Accent Overwrite", % "Enter a character/string that the accent key will now represent when alternative input is toggled."
	if (!ErrorLevel) {
		accentOverwrite := inputEntered
	}
Return

;   --------------------------------------------------------------------------------------------------------
;   PROGRAM/FILE LAUNCHING SHORTCUTS
;   --------------------------------------------------------------------------------------------------------

:R*?:runNotepad::
	Run C:\Program Files (x86)\Notepad++\notepad++.exe
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

#z::
	Run notepad++.exe, C:\Program Files (x86)\Notepad++, Max
Return

:*:@checkHTMLSpec::
	AppendAhkCmd(":*:@checkHTMLSpec")
	Run % userAccountFolder . "\Documents\Daniel\^WSU-Web-Dev\^Master-VPUE\Anatomy of an HTML5 Document_2016-03-16.jpg"
Return

;   --------------------------------------------------------------------------------------------------------
;   FILE SYSTEM NAVIGATION
;   --------------------------------------------------------------------------------------------------------

:*:@gotoTorah::
	AppendAhkCmd(":*:@gotoTorah")
	SendInput, C:\Users\CamilleandDaniel\Documents\Daniel\{^}Derek-Haqodesh\{Enter}
Return

:*:@gotoCurrent::
	AppendAhkCmd(":*:@gotoCurrent")
	SendInput, C:\Users\CamilleandDaniel\Documents\Daniel\{^}Derek-Haqodesh\TheMessage.cc\Messages\Message_The-Man-from-Heaven_2015-12-06{Enter}
Return


:*:@gotoGithub::
	AppendAhkCmd(":*:@gotoGithub")
	SendInput, C:\Users\CamilleandDaniel\Documents\GitHub{Enter}
Return

:*:@gotoWebdev::
	AppendAhkCmd(":*:@gotoWebdev")
	SendInput, C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev{Enter}
Return

:*:@gotoWdDsp::
    InsertFilePath(":*:@gotoGhDsp", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\DSP") 
Return

:*:@gotoWdFye::
    InsertFilePath(":*:@gotoGhFye", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\FYE & FYF")
Return

:*:@gotoWdFyf::
    InsertFilePath(":*:@gotoGhFyf", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\FYE & FYF")
Return

:*:@gotoWdSurca::
    InsertFilePath(":*:@gotoGhSurca", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\SURCA")
Return

:*:@gotoWdSumRes::
    InsertFilePath(":*:@gotoGhSumRes", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\Summer-Res")
Return

:*:@gotoWdUcrAss::
    InsertFilePath(":*:@gotoGhUcrAss", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\UCORE-Assessment")
Return

:*:@gotoWdUcore::
    InsertFilePath(":*:@gotoGhUcore", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\UCORE")
Return

:*:@gotoWdUgr::
    InsertFilePath(":*:@gotoGhUgr", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\UGR")
Return

:*:@gotoWdXfer::
    InsertFilePath(":*:@gotoGhXfer", "C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev" . "\xfer")
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@openNodeCodes::
	AppendAhkCmd(":*:@openNodeCodes")
	SendInput, C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev\{^}Master-VPUE\Node\node-commands.bat{Enter}
Return

:*:@openGitCodes::
	AppendAhkCmd(":*:@openGitCodes")
	SendInput, C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev\GitHub\git-codes.bat{Enter}
Return

;   --------------------------------------------------------------------------------------------------------
;   AUTOHOTKEY SCRIPT WRITING SHORTCUTS
;   --------------------------------------------------------------------------------------------------------

:*:@insAhkCommentSection::
	AppendAhkCmd(":*:@insAhkCommentSection")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := ";   --------------------------------------------------------------------------------------------------------`r"
			. ";   ***EDIT COMMENT TEXT HERE***`r"
			. ";   --------------------------------------------------------------------------------------------------------`r"
		if (clipboard != commentTxt) {
			clipboard := commentTxt
		}
		SendInput, % "^v"
	} else {
		MsgBox, 0
			, % "Error in AHK hotstring: @insAhkCommentSection" ; Title
			, % "An AutoHotkey comment section can only be inserted if [Notepad++.exe] is the active process. Unfortunately, the currently active process is [" . thisProcess . "]." ; Message
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@insAhkCommentSeparator::
	AppendAhkCmd(":*:@insAhkCommentSeparator")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		commentTxt := "; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---`r"
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

;   --------------------------------------------------------------------------------------------------------
;   GOOGLE CHROME SHORTCUTS
;   --------------------------------------------------------------------------------------------------------

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

PerformBypassingCtrlAltO:
	Suspend
	Sleep, 10
	SendInput, ^!o
	Sleep, 10
	Suspend, Off
Return

;   --------------------------------------------------------------------------------------------------------
;   OTHER SHORTCUTS
;   --------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\github.ahk

; Shift + Wheel for horizontal scrolling
;+WheelDown::WheelRight
;+WheelUp::WheelLeft

#+X::
	SetKeyDelay, 160, 100
	Send {SPACE 16}
Return

;   --------------------------------------------------------------------------------------------------------
;   MAIN SUBROUTINE
;   --------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\desktopMain.ahk
