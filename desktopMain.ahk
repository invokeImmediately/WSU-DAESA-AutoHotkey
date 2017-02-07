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
	ListAhkFiles()
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

ListAhkFiles() {
	FileList := Object()
	
	;Get list of file paths to AHK files
	Loop, % GetGitHubFolder() . "\WSU-OUE-AutoHotkey\*.ahk" {
		FileList.push(A_LoopFileFullPath)
	}
	
	;Find all hotstrings within files and store to an array
	allHotStrings := Object()
	Loop, % FileList.Length() {
		filePath := FileList.RemoveAt(1)
		fileObj := FileOpen(filePath, "r")
		if (fileObj != 0) {
			fileContents := fileObj.Read()
			fileObj.Close()
			foundPos := 1
			foundLen := 0
			while (foundPos > 0) {
				foundPos := RegExMatch(fileContents, "Pm)^:\*:@([^:]+)::$", match, foundPos + foundLen)
				if (foundPos > 0) {
					foundLen := match
					foundHotString := SubStr(fileContents, matchPos1, matchLen1)
					allHotStrings.Push("@" . foundHotString)
				}
			}
		}
	}
	;MsgBox, % allHotStrings.Length() . " hotstrings found."
	
	MergeSort(allHotStrings, 1, allHotStrings.Length())
	hsList := allHotStrings.RemoveAt(1)
	while (allHotstrings.Length() > 0) {
		hsList .= "`n" . allHotStrings.RemoveAt(1)
	}
	
	hsFile := GetGitHubFolder() . "\WSU-OUE-AutoHotkey\hotstrings.txt"
	fileObj := FileOpen(hsFile, "w")
	if (fileObj != 0) {
		fileObj.Write(hsList)
		fileObj.Close()
	}
	
	;TODO: Build a trie object for use with an autocomplete function.
}
