; ==================================================================================================
; ENTER AHK COMMAND WITHOUT AFFECTING ACTIVE WINDOW
; ==================================================================================================

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

; ==================================================================================================
; AHK COMMAND HISTORY
; ==================================================================================================

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

; ==================================================================================================
; FIND A SPECIFIC AHK COMMAND FROM THE LIST OF THOSE AVAILABLE
; ==================================================================================================

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
		Gui, AhkGuiFindCmd:New,, % "AutoHotkey Hotstring Lookup Utility"
		Gui, AhkGuiFindCmd:Add, Text, w400, % "Select a command from the list of " . hsCount 
			. " currently available hotstrings below. The edit box can be used to quickly search "
			. "through existing commands."
		Gui, AhkGuiFindCmd:Add, Edit
			, w400 vFindCmdEditBox HwndFindCmdEditBoxHwnd gFindCmdEditBoxChanged
		Gui, AhkGuiFindCmd:Add, ListBox, w400 h550 vFindCmdListBox gFindCmdListBoxClick, %hsListPiped%
		;Gui, AhkGuiFindCmd:Add, ComboBox, w400 h550 vFindCmdComboBox Simple, %hsListPiped%
		Gui, AhkGuiFindCmd:Add, Button, Default gHandleFindCmdOk, &Ok
		Gui, AhkGuiFindCmd:Add, Button, gHandleFindCmdCancel X+5, &Cancel
		Gui, AhkGuiFindCmd:Show
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

; ==================================================================================================
; REPEAT PREVIOUS AHK COMMANDS
; ==================================================================================================

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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
		Gui, AhkGuiRptCmd:Show
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
