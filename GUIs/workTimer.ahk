; ==================================================================================================
; ▐   ▌▄▀▀▄ █▀▀▄ █ ▄▀ ▐▀█▀▌▀█▀ ▐▀▄▀▌█▀▀▀ █▀▀▄    ▄▀▀▄ █  █ █ ▄▀ 
; ▐ █ ▌█  █ █▄▄▀ █▀▄    █   █  █ ▀ ▌█▀▀  █▄▄▀    █▄▄█ █▀▀█ █▀▄  
;  ▀ ▀  ▀▀  ▀  ▀▄▀  ▀▄  █  ▀▀▀ █   ▀▀▀▀▀ ▀  ▀▄ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Implementation of a pomodoro timer.
;
; @version 1.0.2
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/GUIs/workTimer.ahk
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
; TABLE OF CONTENTS:
; -----------------
;   §1: WORK TIMER HOTSTRINGS...................................................................42
;     >>> §1.1: @checkWorkTimer.................................................................46
;     >>> §1.2: @setupWorkTimer.................................................................64
;     >>> §1.3: @stopWorkTimer.................................................................220
;   §2: WORK TIMER FUNCTIONS & LABELS..........................................................249
;     >>> §2.1: ChimeMinuteBell................................................................253
;     >>> §2.2: CloseGuiWorkTimer..............................................................272
;     >>> §2.3: HandleGuiWorkTimerHide.........................................................284
;     >>> §2.4: PostWorkBreakMessage...........................................................291
;     >>> §2.5: ShowWorkTimerGui...............................................................344
;     >>> §2.6: UpdateWorkTimerGui.............................................................375
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: WORK TIMER HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: @checkWorkTimer

:*?:@checkWorkTimer::
	AppendAhkCmd(":*?:@checkWorkTimer")
	if (workTimerRunning) {
		timerTimeLeft := A_Now
		EnvSub, timerTimeLeft, %latestTimerStartTime%, seconds
		if (workTimeLeftOver != 0) {
			timerTimeLeft := (-1 * workTimeLeftOver / 1000 - timerTimeLeft) / 60
		} else {
			timerTimeLeft := (-1 * workTimerCountdownTime / 1000 - timerTimeLeft) / 60
		}
		MsgBox % 1, % "Check Work Timer", % "There are " . timerTimeLeft . " minutes left on the wo"
			. "rk timer."
	}
Return

;   ································································································
;     >>> §1.2: @setupWorkTimer

:*?:@setupWorkTimer::
	AppendAhkCmd(":*?:@setupWorkTimer")
	
	; TODO: Break up the task into mulitple functions
	 := 
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
		MsgBox % 3, % "Continue Tracking Time?"
			, % "It looks like work time was already logged for today. Would you like to restart th"
. "e timer, counting the intervening time as a break?"
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
					timerEndTime := A_YYYY . A_MM . A_DD . SubStr(logFileLines[lineSubIndex], 33
						, 2) . SubStr(logFileLines[lineSubIndex], 36, 2)
						. SubStr(logFileLines[lineSubIndex], 39, 2)
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
					timerStartTime := A_YYYY . A_MM . A_DD . SubStr(logFileLines[lineSubIndex]
						, 35, 2) . SubStr(logFileLines[lineSubIndex], 38, 2)
						. SubStr(logFileLines[lineSubIndex], 41, 2)
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
			logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Restarted work timer at "
				. A_Hour . ":" . A_Min . ":" . A_Sec)
			logFile.Close()
			workTimeLeftOver := workTimerCountdownTime + Mod(timerTimeWorked * 1000
				, -1 * workTimerCountdownTime)
			SetTimer, PostWorkBreakMessage, %workTimeLeftOver%
			latestTimerStartTime := A_Now
			workTimerRunning := true
			Sleep, 1000
			SetTimer, ChimeMinuteBell, % (1000 * 60)
			ShowWorkTimerGui("Current progress toward "
				. Round(workTimerCountdownTime * -1 / 1000 / 60) . " minute work period:"
				, workTimerCountdownTime * -1
				, A_ScriptDir . "\Images\pomodoro-timer.jpg"
				, 0, (timerTimeWorked - Floor(timerTimeWorked / (-1 * workTimerCountdownTime
					/ 1000)) * (-1 * workTimerCountdownTime / 1000)) * 1000)
			SetTimer, UpdateWorkTimerGui, % (workTimerCountdownTime * -1 / 1000)
		}
		Else IfMsgBox No
		{
			MsgBox, 1, % "Starting New Pomodoro Timer"
				, % "A new pomodoro timer will be set to run for " . (-1 * workTimerCountdownTime
				/ 1000 / 60) . " minutes to indicate when you should next take a break."
			IfMsgBox OK
			{
				logFile := FileOpen(logFileName, "a `n")
				timerStartTime := A_Now
				timerTotalBreakTime := 0
				logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Started work timer at "
					. A_Hour . ":" . A_Min . ":" . A_Sec )
				logFile.Close()
				SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
				latestTimerStartTime := A_Now
				workTimerRunning := true
				Sleep, 1000
				SetTimer, ChimeMinuteBell, % (1000 * 60)
				ShowWorkTimerGui("Current progress toward " . Round(workTimerCountdownTime * -1
					/ 1000 / 60) . " minute work period:", workTimerCountdownTime * -1
					, A_ScriptDir . "\Images\pomodoro-timer.jpg" )
				SetTimer, UpdateWorkTimerGui, % (workTimerCountdownTime * -1 / 1000)
			}			
		}
	} else {
		MsgBox, 1, % "Starting Pomodoro Timer"
			, % "A pomodoro timer will be set to run for " . (-1 * workTimerCountdownTime / 1000
			/ 60) . " minutes to indicate when you should next take a break."
		IfMsgBox OK
		{
			logFile := FileOpen(logFileName, "a `n")
			timerStartTime := A_Now
			timerTotalBreakTime := 0
			logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Started work timer at "
				. A_Hour . ":" . A_Min . ":" . A_Sec )
			logFile.Close()
			SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
			latestTimerStartTime := A_Now
			workTimerRunning := true
			Sleep, 1000
			SetTimer, ChimeMinuteBell, % (1000 * 60)
			ShowWorkTimerGui("Current progress toward " . Round(workTimerCountdownTime * -1 / 1000
				/ 60) . " minute work period:", workTimerCountdownTime * -1
				, A_ScriptDir . "\Images\pomodoro-timer.jpg" )
			SetTimer, UpdateWorkTimerGui, % (workTimerCountdownTime * -1 / 1000)
		}
	}
Return

;   ································································································
;     >>> §1.3: @stopWorkTimer

:*?:@stopWorkTimer::
	AppendAhkCmd(":*?:@stopWorkTimer")
	if (workTimerRunning) {
		MsgBox % 3, % "Stop work timer?", % "Would you like to stop your "
			. (-1 * workTimerCountdownTime / 1000 / 60) . " minute work timer prematurely?"
		IfMsgBox Yes
		{
			SetTimer, ChimeMinuteBell, Delete
			CloseGuiWorkTimer()
			workTimerMinuteCount := 0
			logFile := FileOpen(logFileName, "a `n")
			timerTimeWorked := A_Now
			EnvSub, timerTimeWorked, %timerStartTime%, seconds
			timerTimeWorked := timerTimeWorked / 3600 - timerTotalBreakTime / 3600
			FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
			logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended work timer at "
				. timerEndTimeHMS . ". Cumulative time worked today: " . timerTimeWorked . " hours")
			logFile.Close()    
			SetTimer, PostWorkBreakMessage, Delete
			workTimerRunning := false
		}
	} else {
		MsgBox % 1, % "Stop work timer?", % "No work timer is currently running."
	}
Return

; --------------------------------------------------------------------------------------------------
;   §2: WORK TIMER FUNCTIONS & LABELS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: ChimeMinuteBell

ChimeMinuteBell() {
	global workTimerMinutesound
	global workTimer5MinuteSound
	global workTimerMinuteCount
	
	workTimerMinuteCount++
	if (workTimerMinuteCount >= 25) {
		workTimerMinuteCount := 1
	}
	if (Mod(workTimerMinuteCount, 5) == 0) {
		SoundPlay, %workTimer5Minutesound%
	} else {
		SoundPlay, %workTimerMinutesound%
	}
}

;   ································································································
;     >>> §2.2: CloseGuiWorkTimer

CloseGuiWorkTimer() {
	global guiWorkTimer_Hwnd
	global guiWorkTimer_X
	global guiWorkTimer_Y
	WinGetPos, guiWorkTimer_X, guiWorkTimer_Y, w, h, % "ahk_id " . guiWorkTimer_Hwnd
	Gui, guiWorkTimer: Destroy
	SetTimer, UpdateWorkTimerGui, Delete
}

;   ································································································
;     >>> §2.3: HandleGuiWorkTimerHide

HandleGuiWorkTimerHide() {
	Gui, guiWorkTimer: Submit
}

;   ································································································
;     >>> §2.4: PostWorkBreakMessage

PostWorkBreakMessage:
	SetTimer, ChimeMinuteBell, Delete
	CloseGuiWorkTimer()
	workTimerMinuteCount := 0
	timerEndTime := A_Now
	timerTimeWorked := timerEndTime
	EnvSub, timerTimeWorked, %timerStartTime%, seconds
	timerTimeWorked := timerTimeWorked / 3600 - timerTotalBreakTime / 3600    
	SoundPlay, %workTimerNotificationSound%
	workTimerInMins := (-1 * workTimerCountdownTime / 1000 / 60)
	MsgBox, 4, Work Break Timer, % "You have spent the last " . workTimerInMins . " minutes working"
		. "; it's time to take a break.`nTime worked so far: " . timerTimeWorked  . " hours.`nWould"
		. " you like to start another " . workTimerInMins . " minute timer?"
	logFile := FileOpen(logFileName, "a `n")
	IfMsgBox Yes
	{
		timerBreakTime := A_Now
		EnvSub, timerBreakTime, %timerEndTime%, seconds
		EnvAdd, timerTotalBreakTime, %timerBreakTime%
		FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
		logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended break at " . timerEndTimeHMS
			. " for " . (timerBreakTime / 60) . " minutes. Cumulative time worked today: "
			. timerTimeWorked . " hours")
		FormatTime, timerRestartHMS, , HH:mm:ss
		logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Restarted work timer at "
			. timerRestartHMS )
		logFile.Close()
		SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
		latestTimerStartTime := A_Now
		workTimerRunning := true
		Sleep, 1000
		SetTimer, ChimeMinuteBell, % (1000 * 60)
		ShowWorkTimerGui("Current progress toward " . Round(workTimerCountdownTime * -1 / 1000 / 60)
			. " minute work period:", workTimerCountdownTime * -1
			, A_ScriptDir . "\Images\pomodoro-timer.jpg" )
		SetTimer, UpdateWorkTimerGui, % (workTimerCountdownTime * -1 / 1000)
	}
	Else {
		timerBreakTime := timerTimeWorked
		EnvSub, timerBreakTime, %timerEndTime%, seconds
		EnvAdd, timerTotalBreakTime, %timerBreakTime%
		FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
		logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended work timer at "
			. timerEndTimeHMS . ". Cumulative time worked today: " . timerTimeWorked . " hours")
		logFile.Close()    
		workTimerRunning := false
	}
	workTimeLeftOver := 0
Return

;   ································································································
;     >>> §2.5: ShowWorkTimerGui

ShowWorkTimerGui(introMsg, totalTime, iconPath, currentTime := 0, timeAlreadyWorked:= 0
		, guiTitle := "Work Timer Progress") {
	global
	guiWorkTimer_totalTime := totalTime
	guiWorkTimer_currentTime := currentTime
	guiWorkTimer_timeAlreadyWorked := timeAlreadyWorked
	Gui, guiWorkTimer: New, +HwndguiWorkTimer_Hwnd, % guiTitle
	Gui, guiWorkTimer: Add, Text
		, w310 y16, % introMsg
	Gui, guiWorkTimer: Add, Picture
		, x+118 w96 h-1, % iconPath
	Gui, guiWorkTimer: Add, Text
		, xm+6 y+-47 w320 vGuiWorkTimerTimeElapsedText
		, % Round((currentTime + timeAlreadyWorked) / 1000 / 60, 2) . " mins."
	Gui, guiWorkTimer: Add, Progress
		, xm w416 h20 y+5 Range0-1000 cRed BackgroundWhite vGuiWorkTimerProgressCtrl Border
		, % Round((currentTime + timeAlreadyWorked) / totalTime * 1000)
	Gui, guiWorkTimer: Add, Button
		, gHandleGuiWorkTimerHide Default w80 xm y+16, % "&Hide"
	if (guiWorkTimer_X != undefined && guiWorkTimer_Y != undefined) {
		Gui, guiWorkTimer: Show, X%guiWorkTimer_X% Y%guiWorkTimer_Y%
	} else {
		Gui, guiWorkTimer: Show
	}
	GuiControlGet, guiWorkTimer_progressBarId, Hwnd, GuiWorkTimerProgressCtrl
	GuiControlGet, guiWorkTimer_timeElapsedId, Hwnd, GuiWorkTimerTimeElapsedText
}

;   ································································································
;     >>> §2.6: UpdateWorkTimerGui

UpdateWorkTimerGui() {
	global latestTimerStartTime
	global guiWorkTimer_timeAlreadyWorked
	global guiWorkTimer_totalTime
	global guiWorkTimer_currentTime
	global guiWorkTimer_progressBarId
	global guiWorkTimer_timeElapsedId
	elapsedTime := A_Now
	EnvSub, elapsedTime, %latestTimerStartTime%, seconds
	elapsedTime *= 1000
	if (elapsedTime + guiWorkTimer_timeAlreadyWorked > guiWorkTimer_totalTime) {
		elapsedTime := guiWorkTimer_totalTime - guiWorkTimer_timeAlreadyWorked
	} else if (elapsedTime < 0) {
		elapsedTime := 0
	}
	guiWorkTimer_currentTime := elapsedTime
	newProgress := Round((guiWorkTimer_currentTime + guiWorkTimer_timeAlreadyWorked)
		/ guiWorkTimer_totalTime * 1000)
	GuiControl,, %guiWorkTimer_progressBarId%, %newProgress%
	newElapsedTime := Round((guiWorkTimer_currentTime + guiWorkTimer_timeAlreadyWorked) / 1000 / 60
		, 2)
	GuiControl,, %guiWorkTimer_timeElapsedId%, % newElapsedTime . " mins."
}
