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
	LoadAhkCmdHistory()
	LoadCommitCssLessMsgHistory()
	LoadCommitAnyFileMsgHistory()
	SetupLogAutoSaving()
	mapDesktopsFromRegistry()
	OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
	OnExit("ScriptExitFunc")
	SoundPlay, %scriptLoadedSound%
	MsgBox, % "Script has been loaded."
Return

; ------------------------------------------------------------------------------------------------------------
; STARTUP FUNCTIONS CALLED BY MAIN SUBROUTINE
; ------------------------------------------------------------------------------------------------------------

SetGlobalVariables() {
	SetNumMonitors()
	SetMonitorBounds()
	SetMonitorWorkAreas()
	SetWinBorders()
	;ReportMonitorDimensions() ; Diagnostic function
}

SetNumMonitors() {
	global SM_CMONITORS
	global sysNumMonitors
	SysGet, sysNumMonitors, %SM_CMONITORS%
}

SetMonitorBounds() {
	global
	Loop, % sysNumMonitors {
		SysGet, mon%A_Index%Bounds_, Monitor, %A_Index%
	}
}

SetMonitorWorkAreas() {
	global
	Loop, % sysNumMonitors {
		SysGet, mon%A_Index%WorkArea_, MonitorWorkArea, %A_Index%
	}
}

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
	global hsListPiped
	global hsCount
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
				foundPos := RegExMatch(fileContents, "Pm)^:R?\*:(@[^:]+)::", match, foundPos + foundLen)
				if (foundPos > 0) {
					foundLen := match
					foundHotString := SubStr(fileContents, matchPos1, matchLen1)
					allHotStrings.Push(foundHotString)
				}
			}
		}
	}
	hsCount := allHotStrings.Length()
	
	if (hsCount > 0) {
		MergeSort(allHotStrings, 1, allHotStrings.Length())
		nextHotStr := allHotStrings.RemoveAt(1)
		hsList := SubStr(nextHotStr, 2, StrLen(nextHotStr) - 1)
		while (allHotstrings.Length() > 0) {
			nextHotStr := allHotStrings.RemoveAt(1)
			hsList .= "`n" . SubStr(nextHotStr, 2, StrLen(nextHotStr) - 1)
		}
		hsListPiped := StrReplace(hsList, "`n", "|")
		
		hsFile := GetGitHubFolder() . "\WSU-OUE-AutoHotkey\hotstrings.txt"
		fileObj := FileOpen(hsFile, "w")
		if (fileObj != 0) {
			fileObj.Write(hsList)
			fileObj.Close()
		}
	}
	
	;TODO: Build a trie object for use with an autocomplete function.
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

SetupLogAutoSaving() {
	SetTimer, PerformScriptShutdownTasks, 900000 ; 1000 * 60 * 15 = 15 minutes
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
