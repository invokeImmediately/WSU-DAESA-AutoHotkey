; ==================================================================================================
; activeWindowStatusChecks.ahk
; ==================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents:
; -----------------
;   §1: areTargetProcessActive..................................................................16
;   §2: getActiveProcessName....................................................................40
;   §3: isTargetProcessActive...................................................................50
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
