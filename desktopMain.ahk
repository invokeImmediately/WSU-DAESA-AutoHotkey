; ==================================================================================================
; scriptEntryPoint.ahk
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
;   §1: Entry point: StartScript()..............................................................66
;     >>> §1.1: System property globals.........................................................70
;     >>> §1.2: Operation timing globals........................................................92
;     >>> §1.3: Globals for locations of important folders & files.............................101
;     >>> §1.4: Pomodoro work timer globals....................................................111
;     >>> §1.5: Desktop arrangement auditory cue globals.......................................122
;     >>> §1.6: Simulated memory of user actions...............................................134
;     >>> §1.7: Keyboard overriding............................................................152
;     >>> §1.8: Missing AutoHotkey constants...................................................164
;   §2: Set up script & call main subroutine...................................................174
;   §3: Common functions & classes.............................................................195
;   §4: Command history........................................................................211
;   §5: AutoHotkey script writing shortcuts....................................................217
;     >>> §5.1: Hotstrings for inserting code-documentation headers............................221
;   §6: Workspace management...................................................................279
;   §7: File system navigation.................................................................323
;   §8: Program/file launching shortcuts.......................................................329
;     >>> §8.1: Notepad/text editor program....................................................333
;     >>> §8.2: Miscellaneous files............................................................344
;   §9: Powershell scripting...................................................................353
;   §10: Github scripting......................................................................359
;   §11: Google chrome scripting...............................................................365
;   §12: Front-end coding......................................................................422
;   §13: Text replacement & input..............................................................428
;     >>> §13.1: Text Replacement hotkeys......................................................432
;     >>> §13.2: Text Replacement hotstrings...................................................437
;     >>> §13.3: Text Input hotstrings.........................................................534
;   §14: Other shortcuts.......................................................................541
;   §15: Work timer............................................................................554
;   §16: Custom hotstrings & hotkeys...........................................................560
;   §17: Script entry point....................................................................632
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
; STARTUP FUNCTIONS CALLED BY MAIN SUBROUTINE
; --------------------------------------------------------------------------------------------------

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
		hsFile := GetGitHubFolder() . "\WSU-OUE-AutoHotkey\hotstrings.txt"
		fileObj := FileOpen(hsFile, "w")
		if (fileObj != 0) {
			fileObj.Write(hsList)
			fileObj.Close()
		}
	}
}

LoadScriptConfiguration() {
	global scriptCfg := {}

	scriptCfg.backupJs := new CfgFile( "C:\GitHub\WSU-OUE-AutoHotkey\Config\backupJs.ahk.cfg" )
}

:*:@PrintHsTrie::
	PrintHsTrie()
Return

PrintHsTrie() {
	global hsTrie
	hsWordsArray := hsTrie.GetWordsArray()
	MsgBox, % hsWordsArray[1]
}

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

SetAhkConstants() {
	SetCoordModeConstants()
	SetMatchModeConstants()
}

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

SetGlobalVariables() {
	SetAhkConstants()
	SetWinBorders()
	SetNumMonitors()
	SetMonitorBounds()
	SetMonitorWorkAreas()
	SetModules()
	; ReportMonitorDimensions() ; Diagnostic function
}

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

SetModules() {
	global
	checkType := new TypeChecker
	execDelayer := new ExecutionDelayer( checkType, g_delayQuantum, g_extraShortDelay, g_shortDelay
		, g_mediumDelay, g_longDelay)
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
	local monWorkAreaW
	local monWorkAreaH

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
}

SetNumMonitors() {
	global
	SysGet, sysNumMonitors, %SM_CMONITORS%
}

SetWinBorders() {
	global
	SysGet, sysWinBorderW, %SM_CXSIZEFRAME%
	SysGet, sysWinBorderH, %SM_CYSIZEFRAME%
}

SetupLogAutoSaving() {
	SetTimer, PerformScriptShutdownTasks, 900000 ; 1000 * 60 * 15 = 15 minutes
}
