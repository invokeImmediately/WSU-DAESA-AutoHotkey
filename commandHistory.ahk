global sgCmdBeingEntered := false

; ============================================================================================================
; FUNCTIONS
; ============================================================================================================

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
			MsgBox % "Failed to append purported command: " . whatCmd
		}
	}
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

CheckForCmdEntryGui() {
    if (sgCmdBeingEntered) {
        HandleEnterCmdCancel()
    }
}

; ============================================================================================================
; HOTSTRINGS
; ============================================================================================================

:*:@clearCmdHistory::
    CheckForCmdEntryGui()
    while ahkCmds.Length() > 0 {
        ahkCmds.Pop()
    }
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@doLastCmd::
    CheckForCmdEntryGui()
    if (ahkCmds.Length() > 0) {
        if IsLabel(ahkCmds[ahkCmds.Length()]) {
            GoSub % ahkCmds[ahkCmds.Length()]
        }
    }
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@findAhkCmd::
	AppendAhkCmd(":*:@findAhkCmd")
	CreateFindCmdGUI()
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@rptCmd::
    CheckForCmdEntryGui()
    if (ahkCmds.Length() > 0) {
        index := 1
        cmdList := index . ") " . ahkCmds[ahkCmds.Length() - index + 1] . "|"
        index := index + 1
        while index <= ahkCmds.Length() {
            if (index - 1 > 9) {
                cmdList := cmdList . "|" . Chr(index + 86) . ") " . ahkCmds[ahkCmds.Length() - index + 1]
            }
            else {
				if (index - 1 < 9) {
					cmdList := cmdList . "|" . index . ") " . ahkCmds[ahkCmds.Length() - index + 1]
				}
				else {
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
    }
    else {
        MsgBox % "The command history is currently empty; there are no commands to repeat."
    }
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@showLastCmd::
    CheckForCmdEntryGui()
    if (ahkCmds.Length() > 0) {
        MsgBox % "Last command entered into history: `r" . ahkCmds[ahkCmds.Length()]
    }
    else {
        MsgBox % "The command history is currently empty."
    }
Return

; ============================================================================================================
; HOTKEYS
; ============================================================================================================

>^>+r::
    Gosub % ":*:@doLastCmd"
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!r::
    Gosub % ":*:@rptCmd"
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!x::
    sgCmdBeingEntered = true
    Gui, AhkGuiEnterCmd:New,, % "Enter AutoHotkey Hotstring"
    Gui, AhkGuiEnterCmd:Add, Text,, % "Enter the hotstring you would like to run:"
    Gui, AhkGuiEnterCmd:Add, Edit, r1 w500 vCmdEntryBox
    Gui, AhkGuiEnterCmd:Add, Button, Default gHandleEnterCmdCancel, &Cancel
    Gui, AhkGuiEnterCmd:Show
Return

; ============================================================================================================
; Functions/Labels associated with GUIs
; ============================================================================================================

;   --------------------------------------------------------------------------------------------------------
;   GUI: AhkGuiEnterCmd
;   --------------------------------------------------------------------------------------------------------

HandleEnterCmdCancel() {
    sgCmdBeingEntered := false
    Gui, AhkGuiEnterCmd:Destroy
}

;   --------------------------------------------------------------------------------------------------------
;   GUI: AhkGuiEnterCmd
;   --------------------------------------------------------------------------------------------------------

CreateFindCmdGUI() {
	global hsListPiped
	global hsCount
	global FindCmdListBox
	
	if (hsListPiped != undefined && hsCount > 0) {
		Gui, AhkGuiFindCmd:New,, % "AutoHotkey Hotstring Lookup Utility"
		Gui, AhkGuiFindCmd:Add, Text,, % "Select a command from the list of " . hsCount .  " currently available hotstrings below."
		Gui, AhkGuiFindCmd:Add, ListBox, w400 h550 vFindCmdListBox, %hsListPiped%
		Gui, AhkGuiFindCmd:Add, Button, Default gHandleFindCmdOk, &Ok
		Gui, AhkGuiFindCmd:Add, Button, gHandleFindCmdCancel X+5, &Cancel
		Gui, AhkGuiFindCmd:Show
	} else {
		MsgBox, % 0x10, % "Error in commandHistory.ahk: CreateFindCmdGUI"
			, % "Could not create the find command GUI because the list of available AHK hotstrings was undefined."
	}
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleFindCmdOk() {
	global FindCmdListBox
	Gui, AhkGuiFindCmd:Submit, NoHide
	if (FindCmdListBox != "") {
		Gui, AhkGuiFindCmd:Destroy
		cmdSelected := ":*:@" . FindCmdListBox
		if (IsLabel(cmdSelected)) {
			Gosub, %cmdSelected%
		} else {
			MsgBox, % 0x10, "Error in commandHistory.ahk: HandleFindCmdOk()"
				, "Could not find the selected hotstring: " . cmdSelected
		}
	} else {
		MsgBox, % "Please select a command from the list before proceeding."
	}
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleFindCmdCancel() {
    Gui, AhkGuiFindCmd:Destroy
}
;   --------------------------------------------------------------------------------------------------------
;   GUI: AhkGuiRptCmd
;   --------------------------------------------------------------------------------------------------------

HandleCmdRptOK() {
    Gui, AhkGuiRptCmd:Submit
    Gui, AhkGuiRptCmd:Destroy ;Doing this now implicitly allows us to return to the previously active window.
    if (CmdChosen > 0 && CmdChosen <= ahkCmds.Length()) {
        if IsLabel(ahkCmds[ahkCmds.Length()]) {
            GoSub % ahkCmds[ahkCmds.Length() - CmdChosen + 1] ;Run hotstring on window that was active when ":*:@rptCmd" was triggered.
        }
    }
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleCmdRptCancel() {
    Gui, AhkGuiRptCmd:Destroy ;Doing this now implicitly allows us to return to the previously active window.
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

