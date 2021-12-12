; ==================================================================================================
; ▄▀▀▀ ▄▀▀▄ ▐▀▄▀▌▐▀▄▀▌▄▀▀▄ ▐▀▀▄ █▀▀▄ █  █ ▀█▀ ▄▀▀▀▐▀█▀▌▄▀▀▄ █▀▀▄ █  █   ▄▀▀▄ █  █ █ ▄▀ 
; █    █  █ █ ▀ ▌█ ▀ ▌█▄▄█ █  ▐ █  █ █▀▀█  █  ▀▀▀█  █  █  █ █▄▄▀ ▀▄▄█   █▄▄█ █▀▀█ █▀▄  
;  ▀▀▀  ▀▀  █   ▀█   ▀█  ▀ ▀  ▐ ▀▀▀  █  ▀ ▀▀▀ ▀▀▀   █   ▀▀  ▀  ▀▄▄▄▄▀ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Provides an interface that tracks the history of the hotstring-based commands employed by the
;   user of the script for the purpose of enabling the user to rapidly search through and repeat
;   previous commands.
;
; @version 1.1.2
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/Functions/trie.ahk
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
;   §1: GUI for entering script commands without affecting the active window....................39
;   §2: Functions for creating and maintaining a history of script commands.....................65
;   §3: Lookup and triggering of commands stored in the script command history.................158
;   §4: Repetition of script commands..........................................................299
;     >>> §4.1: Repeat the latest script command...............................................303
;     >>> §4.2: Repeat specified script command multiple times.................................320
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GUI for entering script commands without affecting the active window
; --------------------------------------------------------------------------------------------------

global sgCmdBeingEntered := false

^!x::
	sgCmdBeingEntered = true
	Gui, AhkGuiEnterCmd:New,, % "Enter AutoHotkey Hotstring"
	Gui, AhkGuiEnterCmd:Add, Text,, % "Enter the hotstring you would like to run:"
	Gui, AhkGuiEnterCmd:Add, Edit, r1 w500 vCmdEntryBox
	Gui, AhkGuiEnterCmd:Add, Button, Default gHandleEnterCmdCancel, &Cancel
	Gui, AhkGuiEnterCmd:Show
Return

HandleEnterCmdCancel() {
	sgCmdBeingEntered := false
	Gui, AhkGuiEnterCmd:Destroy
}

CheckForCmdEntryGui() {
	if (sgCmdBeingEntered) {
		HandleEnterCmdCancel()
	}
}

; --------------------------------------------------------------------------------------------------
;   §2: Functions for creating and maintaining a history of script commands
; --------------------------------------------------------------------------------------------------

AppendAhkCmd(whatCmd) {
	CheckForCmdEntryGui()
	if (whatCmd != "") {
		if IsLabel(whatCmd) {
			ahkCmds.Push(whatCmd)
			while ahkCmds.Length() > 0 && ahkCmds.Length() > ahkCmdLimit {
				ahkCmds.RemoveAt(1)
			}
		}
		else {
			ErrorBox(A_ThisFunc, "Failed to append purported command: " . whatCmd)
		}
	}
}

LoadAhkCmdHistory() {
	global cmdHistoryLog
	global ahkCmds
	
	while(ahkCmds.Length() > 0) {
		ahkCmds.Pop()
	}
	logFile := FileOpen(cmdHistoryLog, "r `n")
	if (logFile) {
		Loop
		{
			logFileLine := logFile.ReadLine()
			if (logFileLine = "") {
				break
			} else {
				logFileLine := StrReplace(logFileLine, "`n", "")
				if (logFileLine != "") {
					ahkCmds.Push(logFileLine)
				}
			}
		}
		logFile.Close()
	} else {
		ErrorBox(A_ThisFunc, "Could not open command history log file '" . cmdHistoryLog
			. "'. Error code reported by FileOpen: '" . A_LastError . "'")
	}
}

SaveAhkCmdHistory() {
	global cmdHistoryLog
	global ahkCmds
	
	logFile := FileOpen(cmdHistoryLog, "w `n")
	if (logFile) {
		idx := 1 
		while (idx <= ahkCmds.Length())
		{
			numBytes := logFile.WriteLine(ahkCmds[idx])
			if (!numBytes) {
				ErrorBox(A_ThisFunc, "Attempt to write line '" . ahkCmds[idx] . "' to '" 
					. cmdHistoryLog . "' failed; aborting function.")
				break
			}
			idx++
		}
		logFile.Close()
	} else {
		ErrorBox(A_ThisFunc, "Could not open command history log file '" . cmdHistoryLog
			. "'. Error code reported by FileOpen: '" . A_LastError . "'")
	}
}

:*?:@saveAhkCmdHistory::
	CheckForCmdEntryGui()
	SaveAhkCmdHistory()
Return

:*?:@clearCmdHistory::
	CheckForCmdEntryGui()
	while ahkCmds.Length() > 0 {
		ahkCmds.Pop()
	}
Return

:*?:@showLastCmd::
	CheckForCmdEntryGui()
	if (ahkCmds.Length() > 0) {
		MsgBox % "Last command entered into history: `r" . ahkCmds[ahkCmds.Length()]
	}
	else {
		MsgBox % "The command history is currently empty."
	}
Return

; --------------------------------------------------------------------------------------------------
;   §3: Lookup and triggering of commands stored in the script command history
; --------------------------------------------------------------------------------------------------

:*?:@getAhkCmdCount::
	thisAhkCmd := A_ThisLabel 
	AppendAhkCmd(thisAhkCmd)
	GetAhkCmdCount()
Return

GetAhkCmdCount() {
	global hsTrie
	global hsCount
	wordCount := hsTrie.CalculateWordCount()
	MsgBox, % "A total of " hsCount . " AHK commands were counted upon loading of the script.`n"
		. "Moreover, " . wordCount . " commands are logged in the AHK command Trie. "
}

:*?:@findAhkCmd::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	CreateFindCmdGUI()
Return

^!f::
	Gosub, :*?:@findAhkCmd
Return

CreateFindCmdGUI() {
	global hsListPiped
	global hsCount
	global FindCmdEditBox
	global FindCmdListBox
	global FindCmdEditBoxHwnd
	;global FindCmdComboBox
	WM_KEYUP := 0x101
	
	if (hsListPiped != undefined && hsCount > 0) {
		; First, determine which monitor the command entry window should spawn on.
		gH := 680
		gW := 426
		aMon := FindNearestActiveMonitor()
		gX := ( mon%aMon%WorkArea_Right - mon%aMon%WorkArea_Left ) / 2 - gW / 2
			+ mon%aMon%WorkArea_Left
		gY := ( mon%aMon%WorkArea_Bottom - mon%aMon%WorkArea_Top ) / 2 - gH / 2
			+ mon%aMon%WorkArea_Top

		; Now, set up the GUI.
		Gui, AhkGuiFindCmd:New,, % "AutoHotkey Hotstring Lookup Utility"
		Gui, AhkGuiFindCmd:Add, Text, w400, % "Select a command from the list of " . hsCount 
			. " currently available hotstrings below. The edit box can be used to quickly search "
			. "through existing commands."
		Gui, AhkGuiFindCmd:Add, Edit
			, w400 vFindCmdEditBox HwndFindCmdEditBoxHwnd gFindCmdEditBoxChanged
		Gui, AhkGuiFindCmd:Add, ListBox, w400 h550 vFindCmdListBox gFindCmdListBoxClick, %hsListPiped%
		Gui, AhkGuiFindCmd:Add, Button, Default gHandleFindCmdOk, &Ok
		Gui, AhkGuiFindCmd:Add, Button, gHandleFindCmdCancel X+5, &Cancel
		Gui, AhkGuiFindCmd:Show, X%gX% Y%gY%
		OnMessage(WM_KEYUP, "FindCmdEditBoxKeyup")
	} else {
		ErrorBox(A_ThisFunc, "Could not create the find command GUI because the list of available A"
			. "HK hotstrings was undefined.")
	}
}

FindCmdEditBoxChanged() {
	global FindCmdEditBox
	global FindCmdListBox
	global hsTrie
	global hsTrieArray

	Gui, AhkGuiFindCmd:Submit, NoHide

	cmdsAutoCompleteList := hsTrie.GetPipedWordsList(FindCmdEditBox)

	GuiControl, , FindCmdListBox, % cmdsAutoCompleteList
	GuiControl, Choose, FindCmdListBox, 1
	GuiControl, Focus, FindCmdEditBox
}

FindCmdEditBoxKeyup(wParam, lParam, msg, hwnd) {
	global FindCmdEditBoxHwnd
	global FindCmdListBox
	VK_DOWN := 0x28
	VK_UP := 0x26

	if (hwnd == FindCmdEditBoxHwnd && wParam == VK_DOWN) {
		GuiControl, +AltSubmit, FindCmdListBox
		Gui, AhkGuiFindCmd:Submit, NoHide
		cmdToSelect := FindCmdListBox + 1
		GuiControl, -AltSubmit, FindCmdListBox
		GuiControl, Choose, FindCmdListBox, %cmdToSelect%
		GuiControl, Focus, FindCmdListBox
	} else if (hwnd == FindCmdEditBoxHwnd && wParam == VK_UP) {
		GuiControl, +AltSubmit, FindCmdListBox
		Gui, AhkGuiFindCmd:Submit, NoHide
		GuiControl, -AltSubmit, FindCmdListBox
		if ( FindCmdListBox > 1 ) {
			cmdToSelect := FindCmdListBox - 1
			GuiControl, Choose, FindCmdListBox, %cmdToSelect%
		}
		GuiControl, Focus, FindCmdListBox
	}
}

FindCmdListBoxClick() {
	if (A_GuiEvent == "DoubleClick") {
		HandleFindCmdOk()
	}
}

HandleFindCmdOk() {
	global FindCmdListBox
	WM_KEYUP := 0x101

	Gui, AhkGuiFindCmd:Submit, NoHide
	if (FindCmdListBox != "") {
		Gui, AhkGuiFindCmd:Destroy
		OnMessage(WM_KEYUP, "")
		cmdSelected := ":*?:@" . FindCmdListBox
		if (IsLabel(cmdSelected)) {
			Gosub, %cmdSelected%
		} else {
			cmdSelected := ":R*:@" . FindCmdListBox
			if (IsLabel(cmdSelected)) {
				ErrorBox(A_ThisFunc, "The hotstring you selected, " . cmdSelected 
					. ", is a replacement hotstring; you must trigger it manually.")
			}
			else {
				ErrorBox(A_ThisFunc, "Could not find the selected hotstring: " . cmdSelected)
			}
		}
	} else {
		MsgBox, % "Please select a command from the list before proceeding."
	}
}

HandleFindCmdCancel() {
	Gui, AhkGuiFindCmd:Destroy
}

; --------------------------------------------------------------------------------------------------
;   §4: Repetition of script commands
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §4.1: Repeat the latest script command

>^>+r::
	Gosub % ":*?:@doLastCmd"
Return

:*?:@doLastCmd::
	CheckForCmdEntryGui()
	if (ahkCmds.Length() > 0) {
		if IsLabel(ahkCmds[ahkCmds.Length()]) {
			GoSub % ahkCmds[ahkCmds.Length()]
		}
	}
Return


;   ································································································
;     >>> §4.2: Repeat specified script command multiple times

^!r::
	Gosub % ":*?:@rptCmd"
Return

:*?:@rptCmd::
	CheckForCmdEntryGui()
	if (ahkCmds.Length() > 0) {
		index := 1
		cmdList := index . ") " . ahkCmds[ahkCmds.Length() - index + 1] . "|"
		index := index + 1
		while index <= ahkCmds.Length() {
			if (index - 1 > 9) {
				indexMod := Mod(index - 10, 26)
				if (indexMod = 0) {
					indexMod := 26
				}
				cmdList := cmdList . "|" . Chr(indexMod + 96) . ") "
					. ahkCmds[ahkCmds.Length() - index + 1]
			} else {
				if (index - 1 < 9) {
					cmdList := cmdList . "|" . index . ") " . ahkCmds[ahkCmds.Length() - index + 1]
				} else {
					cmdList := cmdList . "|0) " . ahkCmds[ahkCmds.Length() - index + 1]
				}
			}
			index := index + 1
		}
		Gui, AhkGuiRptCmd:New,, % "AutoHotkey Command History"
		Gui, AhkGuiRptCmd:Add, Text,, % "Choose a command from the history:"
		Gui, AhkGuiRptCmd:Add, ListBox, AltSubmit vCmdChosen H500 W250, % cmdList
		Gui, AhkGuiRptCmd:Add, Button, Default gHandleCmdRptOK, &OK
		Gui, AhkGuiRptCmd:Add, Button, gHandleCmdRptCancel X+5, &Cancel
		aMon := FindNearestActiveMonitor()
		guiX := ( mon%aMon%WorkArea_Right - mon%aMon%WorkArea_Left ) / 2 - 250 / 2
			+ mon%aMon%WorkArea_Left
		Gui, AhkGuiRptCmd:Show, X%guiX%
	} else {
		MsgBox % "The command history is currently empty; there are no commands to repeat."
	}
Return

HandleCmdRptOK() {
	global
	Gui, AhkGuiRptCmd:Submit

	; Doing this now implicitly allows us to return to the previously active window.
	Gui, AhkGuiRptCmd:Destroy

	if (CmdChosen > 0 && CmdChosen <= ahkCmds.Length()) {
		if IsLabel(ahkCmds[ahkCmds.Length()]) {

			; Run hotstring on window that was active when ":*?:@rptCmd" was triggered.
			GoSub % ahkCmds[ahkCmds.Length() - CmdChosen + 1]

		}
	}
}

HandleCmdRptCancel() {
	Gui, AhkGuiRptCmd:Destroy
}
