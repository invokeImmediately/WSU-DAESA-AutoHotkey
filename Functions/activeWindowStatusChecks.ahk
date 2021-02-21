; ==================================================================================================
; ▄▀▀▄ ▄▀▀▀▐▀█▀▌▀█▀▐   ▌█▀▀▀▐   ▌▀█▀ ▐▀▀▄ █▀▀▄ ▄▀▀▄▐   ▌▄▀▀▀▐▀█▀▌▄▀▀▄▐▀█▀▌█  █ ▄▀▀▀      
; █▄▄█ █     █   █  █ █ █▀▀ ▐ █ ▌ █  █  ▐ █  █ █  █▐ █ ▌▀▀▀█  █  █▄▄█  █  █  █ ▀▀▀█      
; █  ▀  ▀▀▀  █  ▀▀▀  █  ▀▀▀▀ ▀ ▀ ▀▀▀ ▀  ▐ ▀▀▀   ▀▀  ▀ ▀ ▀▀▀   █  █  ▀  █   ▀▀  ▀▀▀  ▀ ▀ ▀
;
;          ▄▀▀▀ █  █ █▀▀▀ ▄▀▀▀ █ ▄▀ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
;          █    █▀▀█ █▀▀  █    █▀▄  ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
;    ▀ ▀ ▀  ▀▀▀ █  ▀ ▀▀▀▀  ▀▀▀ ▀  ▀▄▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Functions for supporting identification and verification of active windows and processes.
;
; @version 1.0.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/master…→
;   ←…/Functions/activeWindowStatusChecks.ahk
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
; Table of Contents:
; -----------------
;   §1: areTargetProcessActive..................................................................39
;   §2: getActiveProcessName....................................................................63
;   §3: isTargetProcessActive...................................................................73
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: areTargetProcessActive(…)
; --------------------------------------------------------------------------------------------------

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
;   §2: getActiveProcessName()
; --------------------------------------------------------------------------------------------------

getActiveProcessName() {
	WinGet, aProcName, ProcessName, A
	return aProcName
}


; --------------------------------------------------------------------------------------------------
;   §3: isTargetProcessActive(…)
; --------------------------------------------------------------------------------------------------

isTargetProcessActive(targetProcess, caller := "", notActiveErrMsg := "") {
	WinGet, thisWin, ProcessName, A
	targetProcessIsActive := thisWin = targetProcess
	if (!targetProcessIsActive && caller != "" && notActiveErrMsg != "") {
		ErrorBox(caller, notActiveErrMsg)
	}
	return targetProcessIsActive
}
