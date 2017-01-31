; ============================================================================================================
; DESKTOP: MAIN SUBROUTINE
; ============================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

; ------------------------------------------------------------------------------------------------------------
; MAIN SUBROUTINE
; ------------------------------------------------------------------------------------------------------------

MainSubroutine:
	SetGlobalVariables()
	MsgBox, % "Script has been loaded."
Return

; ------------------------------------------------------------------------------------------------------------
; STARTUP FUNCTIONS CALLED BY MAIN SUBROUTINE
; ------------------------------------------------------------------------------------------------------------

ReportMonitorDimensions() {
	global
	local msg := "The system has " . sysNumMonitors . " monitors."
	Loop, % sysNumMonitors {
		msg := msg . "`rMonitor #" . A_Index . " bounds: (" . mon%A_Index%Bounds_Left . ", " . mon%A_Index%Bounds_Top . "), (" . mon%A_Index%Bounds_Right . ", " . mon%A_Index%Bounds_Bottom . ")"
		msg := msg . "`rMonitor #" . A_Index . " work area: (" . mon%A_Index%WorkArea_Left . ", " . mon%A_Index%WorkArea_Top . "), (" . mon%A_Index%WorkArea_Right . ", " . mon%A_Index%WorkArea_Bottom . ")"
	}
	msg := msg . "`rWindow border thickness: (" . sysWinBorderW . "," . sysWinBorderH . ")"
	MsgBox, % msg
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

SetGlobalVariables() {
	SetNumMonitors()
	SetMonitorBounds()
	SetMonitorWorkAreas()
	SetWinBorders()
	;ReportMonitorDimensions() ; Diagnostic function
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

SetMonitorBounds() {
	global
	Loop, % sysNumMonitors {
		SysGet, mon%A_Index%Bounds_, Monitor, %A_Index%
	}
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

SetMonitorWorkAreas() {
	global
	Loop, % sysNumMonitors {
		SysGet, mon%A_Index%WorkArea_, MonitorWorkArea, %A_Index%
	}
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

SetNumMonitors() {
	global SM_CMONITORS
	global sysNumMonitors
	SysGet, sysNumMonitors, %SM_CMONITORS%
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

SetWinBorders() {
	global SM_CXSIZEFRAME
	global SM_CYSIZEFRAME
	global sysWinBorderW
	global sysWinBorderH
	
	SysGet, sysWinBorderW, %SM_CXSIZEFRAME%
	SysGet, sysWinBorderH, %SM_CYSIZEFRAME%
}
