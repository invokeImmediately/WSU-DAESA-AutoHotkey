; TODO: Copied from CommitAnyfile.ahk; revise entire file to contain PowerShell shortcuts.
; TODO: Move appropriate commands from github.ahk to this file.

; ==================================================================================================
; GUI FOR COMMITTING CSS BUILDS & ASSOCIATED SITE-SPECIFIC CUSTOM LESS FILES
; ==================================================================================================
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents
; -----------------
;   §1: Functions for working with PowerShell...................................................19
;     >>> §1.1: IsPowerShellActive..............................................................21
;   §2: Hotstrings for PowerShell scripting.....................................................34
;     >>> §2.1: @closePsScripting...............................................................38
;     >>> §2.2: @openPsScripting................................................................51
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Functions for working with PowerShell
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: IsPowerShellActive

IsPowerShellActive() {
	WinGet, thisProcess, ProcessName, A
	psIsActive := thisProcess = "PowerShell.exe"
	Return psIsActive
}

; --------------------------------------------------------------------------------------------------
;   §2: Hotstrings for PowerShell scripting
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: @closePsScripting

:*?:@closePsScripting::
	AppendAhkCmd(A_ThisLabel)
	delay := GetDelay("medium")
	if (IsPowerShellActive()) {
		SendInput % "Set-ExecutionPolicy Restricted -Scope Process{Enter}"
		Sleep % delay
		SendInput % "y{Enter}"
	}
Return

;   ································································································
;     >>> §2.2: @openPsScripting

:*?:@openPsScripting::
	AppendAhkCmd(A_ThisLabel)
	delay := GetDelay("medium")
	if (IsPowerShellActive()) {
		SendInput % "Set-ExecutionPolicy RemoteSigned -Scope Process{Enter}"
		Sleep % delay
		SendInput % "y{Enter}"
	}
Return
