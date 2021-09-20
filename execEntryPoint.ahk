; ==================================================================================================
; █▀▀▀▐▄ ▄▌█▀▀▀ ▄▀▀▀ █▀▀▀ ▐▀▀▄▐▀█▀▌█▀▀▄ █  █ █▀▀▄ ▄▀▀▄ ▀█▀ ▐▀▀▄▐▀█▀▌  ▄▀▀▄ █  █ █ ▄▀ 
; █▀▀   █  █▀▀  █    █▀▀  █  ▐  █  █▄▄▀ ▀▄▄█ █▄▄▀ █  █  █  █  ▐  █    █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀▐▀ ▀▌▀▀▀▀  ▀▀▀ ▀▀▀▀ ▀  ▐  █  ▀  ▀▄▄▄▄▀ █     ▀▀  ▀▀▀ ▀  ▐  █  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Entry point at which execution of the script begins.
;
; @version 1.1.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-AutoHotkey/blob/master/execEntryPoint.ahk
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
;   §1: Entry point: StartScript()..............................................................52
;   §2: Script initialization functions.........................................................79
;     >>> §2.1: CheckMonitorWorkAreas().........................................................83
;     >>> §2.2: ListAhkFiles().................................................................104
;     >>> §2.3: LoadScriptConfiguration()......................................................181
;     >>> §2.4: PrintHsTrie()..................................................................196
;       →→→ §2.4.1: For committing CSS builds..................................................205
;     >>> §2.5: ReportMonitorDimensions()......................................................212
;     >>> §2.6: SetAhkConstants()..............................................................234
;     >>> §2.7: SetAppliedDPI()................................................................242
;     >>> §2.8: SetCoordModeConstants()........................................................254
;     >>> §2.9: SetGlobalVariables()...........................................................274
;     >>> §2.10: SetMatchModeConstants().......................................................288
;     >>> §2.11: SetMinMonitorWorkAreas()......................................................319
;     >>> §2.12: SetModules()..................................................................346
;     >>> §2.13: SetMonitorBounds()............................................................356
;     >>> §2.14: SetMonitorBounds()............................................................397
;     >>> §2.15: SetMonitorWorkAreas().........................................................450
;     >>> §2.16: SetWinBorders()...............................................................458
;     >>> §2.17: SetupLogAutoSaving()..........................................................467
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
	OnExit("ScriptExitFunc")
	ShowStartupGui()
}

ShowStartupGui() {
	global checkType
	global execDelayer
	global scriptCfg
	SoundPlay, %scriptLoadedSound%
	startupNotice := New StartupGui( scriptCfg.guiThemes.cfgSettings[ 1 ], checkType, execDelayer )
	startupNotice.ShowGui()
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
				foundPos := RegExMatch(fileContents, "Pm)^:R?\*\?:(@[^:]+)::", match
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

	; TODO: Check to see if this can be removed thanks to addition of JsBldPsOps.ahk.
	scriptCfg.backupJs := new CfgFile( A_ScriptDir . "\Config\backupJs.ahk.cfg" )
	scriptCfg.cssBuilds := new CfgFile( A_ScriptDir . "\Config\cssBuilds.ahk.cfg" )
	scriptCfg.jsBuilds := new CfgFile( A_ScriptDir . "\Config\jsBuilds.ahk.cfg" )
	scriptCfg.daesaRepos := new CfgFile( A_ScriptDir . "\Config\daesaRepos.ahk.cfg" )
	scriptCfg.gitStatus := new CfgFile( A_ScriptDir . "\Config\gitStatus.ahk.cfg" )
	scriptCfg.guiThemes := new CfgFile( A_ScriptDir . "\Config\guiThemes.ahk.cfg" )
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

:*?:@PrintHsTrie::
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

:*?:@reportMonitorDimensions::
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

	; Begin sorting bounds so that monitor identifier order reflects spatial order; first, sort based
	;   on vertical position with top-most monitors arranged first in the order.
	Loop, % sysNumMonitors {
		outerIdx := A_Index
		Loop, % sysNumMonitors - outerIdx {
			innerIdx := outerIdx + A_Index
			if ( mon%innerIdx%Bounds_Top < mon%outerIdx%Bounds_Top ) {
				SwapValues(mon%innerIdx%Bounds_Left, mon%outerIdx%Bounds_Left)
				SwapValues(mon%innerIdx%Bounds_Top, mon%outerIdx%Bounds_Top)
				SwapValues(mon%innerIdx%Bounds_Right, mon%outerIdx%Bounds_Right)
				SwapValues(mon%innerIdx%Bounds_Bottom, mon%outerIdx%Bounds_Bottom)
			}
		}
	}

	; Continue sorting bounds so that monitor identifier order reflects spatial order; next, sort
	;   based on horizontal position with left-most monitors arranged first in the order.
	Loop, % sysNumMonitors {
		outerIdx := A_Index
		Loop, % sysNumMonitors - outerIdx {
			innerIdx := outerIdx + A_Index
			if ( mon%innerIdx%Bounds_Left < mon%outerIdx%Bounds_Left
					&& mon%innerIdx%Bounds_Top == mon%outerIdx%Bounds_Top ) {
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

	; All the variables that will be declared over the course of this function's represent
	;   monitor work areas to be used throughout the script; therefore, they should be global.
	global

	; Start by getting the monitor work areas following whatever order the operating system happened
	;   to assign to the system's monitors.
	Loop, % sysNumMonitors {
		SysGet, mon%A_Index%WorkArea_, MonitorWorkArea, %A_Index%
	}

	; Begin sorting work areas so that monitor identifier order reflects spatial order; first, sort
	;   based on vertical position with top-most monitors arranged first in the order.
	Loop, % sysNumMonitors {
		outerIdx := A_Index
		Loop, % sysNumMonitors - outerIdx {
			innerIdx := outerIdx + A_Index
			if ( mon%innerIdx%WorkArea_Top < mon%outerIdx%WorkArea_Top ) {
				SwapValues(mon%innerIdx%WorkArea_Left, mon%outerIdx%WorkArea_Left)
				SwapValues(mon%innerIdx%WorkArea_Top, mon%outerIdx%WorkArea_Top)
				SwapValues(mon%innerIdx%WorkArea_Right, mon%outerIdx%WorkArea_Right)
				SwapValues(mon%innerIdx%WorkArea_Bottom, mon%outerIdx%WorkArea_Bottom)
			}
		}
	}

	; Continue sorting work areas so that monitor identifier order reflects spatial order; next, sort
	;   based on horizontal position with left-most monitors arranged first in the order.
	Loop, % sysNumMonitors {
		outerIdx := A_Index
		Loop, % sysNumMonitors - outerIdx {
			innerIdx := outerIdx + A_Index
			if ( mon%innerIdx%WorkArea_Left < mon%outerIdx%WorkArea_Left
					&& mon%innerIdx%WorkArea_Top == mon%outerIdx%WorkArea_Top ) {
				SwapValues(mon%innerIdx%WorkArea_Left, mon%outerIdx%WorkArea_Left)
				SwapValues(mon%innerIdx%WorkArea_Top, mon%outerIdx%WorkArea_Top)
				SwapValues(mon%innerIdx%WorkArea_Right, mon%outerIdx%WorkArea_Right)
				SwapValues(mon%innerIdx%WorkArea_Bottom, mon%outerIdx%WorkArea_Bottom)
			}
		}
	}

	; Now that global variables representing monitor work areas are properly arranged, establish some
	;   additional settings that concern monitor work areas.
	SetMinMonitorWorkAreas()
	CheckMonitorWorkAreas()
}

;   ································································································
;     >>> §2.15: SetNumMonitors()

SetNumMonitors() {
	global
	SysGet, sysNumMonitors, %SM_CMONITORS%
}

;   ································································································
;     >>> §2.16: SetWinBorders()

SetWinBorders() {
	global
	SysGet, sysWinBorderW, %SM_CXSIZEFRAME%
	SysGet, sysWinBorderH, %SM_CYSIZEFRAME%
}

;   ································································································
;     >>> §2.17: SetupLogAutoSaving()

SetupLogAutoSaving() {
	SetTimer, PerformScriptShutdownTasks, 900000 ; 1000 * 60 * 15 = 15 minutes
}
