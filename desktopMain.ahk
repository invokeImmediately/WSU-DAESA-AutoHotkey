; ==================================================================================================
; DESKTOP: MAIN SUBROUTINE
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
; MAIN SUBROUTINE
; --------------------------------------------------------------------------------------------------

MainSubroutine:
	SetGlobalVariables()
	ListAhkFiles()
	LoadAhkCmdHistory()
	LoadCommitCssLessMsgHistory()
	LoadCommitJsCustomJsMsgHistory()
	LoadCommitAnyFileMsgHistory()
	SetupLogAutoSaving()
	MapDesktopsFromRegistry()
	OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
	OnExit("ScriptExitFunc")
	SoundPlay, %scriptLoadedSound%
	newMsgBox := New GuiMsgBox("Script has been loaded.", Func("HandleGuiMsgBoxOk"), "ScriptLoaded")
	newMsgBox.ShowGui()
Return

; --------------------------------------------------------------------------------------------------
; STARTUP FUNCTIONS CALLED BY MAIN SUBROUTINE
; --------------------------------------------------------------------------------------------------

SetGlobalVariables() {
	SetWinBorders()
	SetNumMonitors()
	SetMonitorBounds()
	SetMonitorWorkAreas()
	;ReportMonitorDimensions() ; Diagnostic function
}

SetWinBorders() {
	global
	SysGet, sysWinBorderW, %SM_CXSIZEFRAME%
	SysGet, sysWinBorderH, %SM_CYSIZEFRAME%
}

SetNumMonitors() {
	global
	SysGet, sysNumMonitors, %SM_CMONITORS%
}

SetMonitorBounds() {
	global
	Loop, % sysNumMonitors {
		SysGet, mon%A_Index%Bounds_, Monitor, %A_Index%
	}

	; Sort bounds so that monitor identifier order reflects spatial order.
	Loop, % sysNumMonitors {
		outerIdx := A_Index
		Loop, % sysNumMonitors - outerIdx {
			innerIdx := outerIdx + A_Index
			if (mon%innerIdx%Bounds_Left < mon%outerIdx%Bounds_Left) {
				SwapValues(mon%innerIdx%Bounds_Left, mon%outerIdx%Bounds_Left)
				SwapValues(mon%innerIdx%Bounds_Top, mon%outerIdx%Bounds_Top)
				SwapValues(mon%innerIdx%Bounds_Right, mon%outerIdx%Bounds_Right)
				SwapValues(mon%innerIdx%Bounds_Bottom, mon%outerIdx%Bounds_Bottom)
			}
		}
	}
}

; Assumes window has a resizable border.
SetMonitorWorkAreas() {
	global
	Loop, % sysNumMonitors {
		SysGet, mon%A_Index%WorkArea_, MonitorWorkArea, %A_Index%
	}

	; Sort bounds so that monitor identifier order reflects spatial order.
	Loop, % sysNumMonitors {
		outerIdx := A_Index
		Loop, % sysNumMonitors - outerIdx {
			innerIdx := outerIdx + A_Index
			if (mon%innerIdx%WorkArea_Left < mon%outerIdx%WorkArea_Left) {
				SwapValues(mon%innerIdx%WorkArea_Left, mon%outerIdx%WorkArea_Left)
				SwapValues(mon%innerIdx%WorkArea_Top, mon%outerIdx%WorkArea_Top)
				SwapValues(mon%innerIdx%WorkArea_Right, mon%outerIdx%WorkArea_Right)
				SwapValues(mon%innerIdx%WorkArea_Bottom, mon%outerIdx%WorkArea_Bottom)
			}
		}
	}
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

ListAhkFiles() {
	global hsListPiped
	global hsCount
	global hsTrie := New Trie("", False)
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
				foundPos := RegExMatch(fileContents, "Pm)^:R?\*:(@[^:]+)::", match
					, foundPos + foundLen)
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
		nextHotStr := SubStr(nextHotStr, 2, StrLen(nextHotStr) - 1)
		hsList := nextHotStr
		hsTrie.Insert(nextHotStr)
		while (allHotstrings.Length() > 0) {
			nextHotStr := allHotStrings.RemoveAt(1)
			nextHotStr := SubStr(nextHotStr, 2, StrLen(nextHotStr) - 1)
			hsList .= "`n" . nextHotStr
			hsTrie.Insert(nextHotStr)
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

:*:@PrintHsTrie::
	PrintHsTrie()
Return

PrintHsTrie() {
	global hsTrie
	hsWordsArray := hsTrie.GetWordsArray()
	MsgBox, % hsWordsArray[1]
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

SetupLogAutoSaving() {
	SetTimer, PerformScriptShutdownTasks, 900000 ; 1000 * 60 * 15 = 15 minutes
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

ReportMonitorDimensions() {
	global
	local msg := "The system has " . sysNumMonitors . " monitors."
	Loop, % sysNumMonitors {
		msg .= "`rMonitor #" . A_Index . " bounds: (" . mon%A_Index%Bounds_Left . ", " 
			. mon%A_Index%Bounds_Top . "), (" . mon%A_Index%Bounds_Right . ", " 
			. mon%A_Index%Bounds_Bottom . ")"
		msg .= "`rMonitor #" . A_Index . " work area: (" . mon%A_Index%WorkArea_Left . ", " 
			. mon%A_Index%WorkArea_Top . "), (" . mon%A_Index%WorkArea_Right . ", " 
			. mon%A_Index%WorkArea_Bottom . ")"
	}
	msg := msg . "`rWindow border thickness: (" . sysWinBorderW . "," . sysWinBorderH . ")"
	MsgBox, % msg
}
