; ==================================================================================================
; execEntryPoint.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Entry point at which execution of the script begins.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck. (Please refer to AutoHotkeyU64.ahk for full
; license text.)
; ==================================================================================================

; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: Entry point: StartScript()..............................................................41
;   §2: Script initialization functions.........................................................62
;     >>> §2.1: CheckMonitorWorkAreas().........................................................66
;     >>> §2.2: ListAhkFiles()..................................................................87
;     >>> §2.3: LoadScriptConfiguration()......................................................164
;     >>> §2.4: PrintHsTrie()..................................................................176
;       →→→ §2.4.1: For committing CSS builds..................................................185
;     >>> §2.5: ReportMonitorDimensions()......................................................192
;     >>> §2.6: SetAhkConstants()..............................................................214
;     >>> §2.7: SetAppliedDPI()................................................................222
;     >>> §2.8: SetCoordModeConstants()........................................................234
;     >>> §2.9: SetGlobalVariables()...........................................................254
;     >>> §2.10: SetMatchModeConstants().......................................................268
;     >>> §2.11: SetMinMonitorWorkAreas()......................................................299
;     >>> §2.12: SetModules()..................................................................326
;     >>> §2.13: SetMonitorBounds()............................................................336
;     >>> §2.14: SetMonitorBounds()............................................................360
;     >>> §2.14: SetMonitorWorkAreas().........................................................389
;     >>> §2.15: SetWinBorders()...............................................................397
;     >>> §2.16: SetupLogAutoSaving()..........................................................406
; ==================================================================================================


; --------------------------------------------------------------------------------------------------
;   §1: Entry point: StartScript()
; --------------------------------------------------------------------------------------------------

StartScript() {
	SetGlobalVariables()
	LoadScriptConfiguration()
	ListAhkFiles()
	LoadAhkCmdHistory()
	LoadCommitCssLessMsgHistory()
	LoadCommitJsCustomJsMsgHistory()
	LoadCafMsgHistory()
	SetupLogAutoSaving()
	MapDesktopsFromRegistry()
	OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
	OnExit("ScriptExitFunc")
	SoundPlay, %scriptLoadedSound%
	newMsgBox := New GuiMsgBox("Script has been loaded.", "ScriptLoaded")
	newMsgBox.ShowGui()
}

; --------------------------------------------------------------------------------------------------
;   §2: Script initialization functions
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: CheckMonitorWorkAreas()

CheckMonitorWorkAreas() {
	global

	if ( sysNumMonitors < 2 ) {
		mon2WorkArea_Left = mon1WorkArea_Left
		mon2WorkArea_Top = mon1WorkArea_Top
		mon2WorkArea_Right = mon1WorkArea_Right
		mon2WorkArea_Bottom = mon1WorkArea_Bottom
	}
	if ( sysNumMonitors < 3 ) {
		mon3WorkArea_Left = mon2WorkArea_Left
		mon3WorkArea_Top = mon2WorkArea_Top
		mon3WorkArea_Right = mon2WorkArea_Right
		mon3WorkArea_Bottom = mon2WorkArea_Bottom
	}
}


;   ································································································
;     >>> §2.2: ListAhkFiles()

ListAhkFiles() {
	global hsListPiped
	global hsCount
	global hsTrie := New Trie("", False)
	FileList := Object()

	; Get list of file paths to AHK files used in the script
	Loop, Files, % A_ScriptDir . "\*.ahk"
	{
		if ( !InStr( A_LoopFileName, ".refactor" ) ) {
			FileList.push(A_LoopFileFullPath)
		}
	}
	Loop, Files, % A_ScriptDir . "\*", D
	{
		if ( A_LoopFileName != "Local" ) {
			folderPath := A_LoopFileFullPath
			Loop, Files, % folderPath . "\*.ahk"
			{
				if ( !InStr( A_LoopFileName, ".refactor" ) ) {
					FileList.push(A_LoopFileFullPath)
				}
			}
		}
	}

	; Find all hotstrings within files and store to an array
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

	; Sort the array of hotstrings, then enter them into a trie.
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

		; Store list of hotstrings to a backup file.
		hsFile := A_ScriptDir . "\hotstrings.txt"
		fileObj := FileOpen(hsFile, "w")
		if (fileObj != 0) {
			fileObj.Write(hsList)
			fileObj.Close()
		}
	}
}

;   ································································································
;     >>> §2.3: LoadScriptConfiguration()

LoadScriptConfiguration() {
	global scriptCfg := {}

	scriptCfg.backupJs := new CfgFile( A_ScriptDir . "\Config\backupJs.ahk.cfg" )
	scriptCfg.cssBuilds := new CfgFile( A_ScriptDir . "\Config\cssBuilds.ahk.cfg" )
	scriptCfg.daesaRepos := new CfgFile( A_ScriptDir . "\Config\daesaRepos.ahk.cfg" )
	scriptCfg.gitStatus := new CfgFile( A_ScriptDir . "\Config\gitStatus.ahk.cfg" )
}

;   ································································································
;     >>> §2.4: PrintHsTrie()

PrintHsTrie() {
	global hsTrie
	hsWordsArray := hsTrie.GetWordsArray()
	MsgBox, % hsWordsArray[1]
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.1: For committing CSS builds

:*:@PrintHsTrie::
	PrintHsTrie()
Return

;   ································································································
;     >>> §2.5: ReportMonitorDimensions()

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

:*:@reportMonitorDimensions::
	ReportMonitorDimensions()
Return

;   ································································································
;     >>> §2.6: SetAhkConstants()

SetAhkConstants() {
	SetCoordModeConstants()
	SetMatchModeConstants()
}

;   ································································································
;     >>> §2.7: SetAppliedDPI()

SetAppliedDPI() {
	global g_dpiScalar
	RegRead, systemDpi, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
	if (errorlevel == 1) {
		systemDpi := 96
	}
	g_dpiScalar := systemDpi / 96
}

;   ································································································
;     >>> §2.8: SetCoordModeConstants()

SetCoordModeConstants() {
	global cmClient
	global cmRelative
	global cmWindow

	oldCoordMode := A_CoordModeMouse
	CoordMode Mouse, Client
	cmClient := A_CoordModeMouse
	CoordMode Mouse, Relative
	cmRelative := A_CoordModeMouse
	CoordMode Mouse, Window
	cmWindow := A_CoordModeMouse
	if (oldCoordMode != A_CoordModeMouse) {
		CoordMode Mouse, % oldCoordMode
	}
}

;   ································································································
;     >>> §2.9: SetGlobalVariables()

SetGlobalVariables() {
	SetAhkConstants()
	SetWinBorders()
	SetNumMonitors()
	SetMonitorBounds()
	SetMonitorWorkAreas()
	SetAppliedDPI()
	SetModules()
	; ReportMonitorDimensions() ; Diagnostic function
}

;   ································································································
;     >>> §2.10: SetMatchModeConstants()

SetMatchModeConstants() {
	global execDelayer
	global mmFast
	global mmRegEx
	global mmSlow

	oldMatchMode := A_TitleMatchMode
	execDelayer.Wait( "s" )
	SetTitleMatchMode RegEx
	execDelayer.Wait( "s" )
	mmRegEx := A_TitleMatchMode
	execDelayer.Wait( "s" )
	if (oldMatchMode != A_TitleMatchMode) {
		SetTitleMatchMode % oldMatchMode
	}

	oldMatchModeSpeed := A_TitleMatchModeSpeed
	SetTitleMatchMode Slow
	execDelayer.Wait( "s" )
	mmSlow := A_TitleMatchModeSpeed
	SetTitleMatchMode Fast
	execDelayer.Wait( "s" )
	mmFast := A_TitleMatchModeSpeed
	if (oldMatchModeSpeed != A_TitleMatchModeSpeed) {
		SetTitleMatchMode % oldMatchModeSpeed
	}
}

;   ································································································
;     >>> §2.11: SetMinMonitorWorkAreas()

SetMinMonitorWorkAreas() {
	global
	local monWorkAreaW
	local monWorkAreaH

	minMonWorkAreaW := 0
	minMonWorkAreaH := 0
	Loop, % sysNumMonitors {
		monWorkAreaW := Round( (mon%A_Index%WorkArea_Right) - (mon%A_Index%WorkArea_Left) )
		monWorkAreaH := Round( (mon%A_Index%WorkArea_Bottom) - (mon%A_Index%WorkArea_Top) )
		if ( minMonWorkAreaW == 0 || monWorkAreaW < minMonWorkAreaW ) {
			minMonWorkAreaW := monWorkAreaW
		}
		if ( minMonWorkAreaH == 0 || monWorkAreaH < minMonWorkAreaH ) {
			minMonWorkAreaH := monWorkAreaH
		}
	}
	if ( minMonWorkAreaW < minMonWorkAreaH ) {
		minMonWorkAreaDim := minMonWorkAreaW
	} else {
		minMonWorkAreaDim := minMonWorkAreaH		
	}
}

;   ································································································
;     >>> §2.12: SetModules()

SetModules() {
	global
	checkType := new TypeChecker
	execDelayer := new ExecutionDelayer( checkType, g_delayQuantum, g_extraShortDelay, g_shortDelay
		, g_mediumDelay, g_longDelay)
}

;   ································································································
;     >>> §2.13: SetMonitorBounds()

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

;   ································································································
;     >>> §2.14: SetMonitorWorkAreas()

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

	SetMinMonitorWorkAreas()
	CheckMonitorWorkAreas()
}

;   ································································································
;     >>> §2.14: SetNumMonitors()

SetNumMonitors() {
	global
	SysGet, sysNumMonitors, %SM_CMONITORS%
}

;   ································································································
;     >>> §2.15: SetWinBorders()

SetWinBorders() {
	global
	SysGet, sysWinBorderW, %SM_CXSIZEFRAME%
	SysGet, sysWinBorderH, %SM_CYSIZEFRAME%
}

;   ································································································
;     >>> §2.16: SetupLogAutoSaving()

SetupLogAutoSaving() {
	SetTimer, PerformScriptShutdownTasks, 900000 ; 1000 * 60 * 15 = 15 minutes
}
