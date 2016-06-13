global sgCmdBeingEntered := false

AppendAhkCmd(whatCmd) {
    CheckForCmdEntryGui()
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

CheckForCmdEntryGui() {
    if (sgCmdBeingEntered) {
        Gosub HandleEnterCmdCancel
    }
}

HandleEnterCmdCancel:
    sgCmdBeingEntered = false
    Gui, AhkGuiEnterCmd:Destroy
return

HandleCmdRptOK:
    Gui, Submit
    Gui, Destroy ;Doing this now implicitly allows us to return to the previously active window.
    if (CmdChosen > 0 && CmdChosen <= ahkCmds.Length()) {
        if IsLabel(ahkCmds[ahkCmds.Length()]) {
            GoSub % ahkCmds[ahkCmds.Length() - CmdChosen + 1] ;Run hotstring on window that was active when ":*:@rptCmd" was triggered.
        }
    }
return

:*:@clearCmdHistory::
    CheckForCmdEntryGui()
    while ahkCmds.Length() > 0 {
        ahkCmds.Pop()
    }
return

:*:@doLastCmd::
    CheckForCmdEntryGui()
    if (ahkCmds.Length() > 0) {
        if IsLabel(ahkCmds[ahkCmds.Length()]) {
            GoSub % ahkCmds[ahkCmds.Length()]
        }
    }
return

^!r::
    Gosub % ":*:@rptCmd"
return

:*:@rptCmd::
    CheckForCmdEntryGui()
    if (ahkCmds.Length() > 0) {
        index := 1
        cmdList := (index - 1) . ") " . ahkCmds[ahkCmds.Length() - index + 1]
        index := index + 1
        while index <= ahkCmds.Length() {
            if (index - 1 > 9) {
                cmdList := cmdList . "|" . Chr(index + 86) . ") " . ahkCmds[ahkCmds.Length() - index + 1]
            }
            else {
                cmdList := cmdList . "|" . (index - 1) . ") " . ahkCmds[ahkCmds.Length() - index + 1]
            }
            index := index + 1
        }
        Gui, New,, % "AutoHotkey Command History"
        Gui, Add, Text,, % "Choose a command from the history:"
        Gui, Add, ListBox, AltSubmit vCmdChosen H500, % cmdList
        Gui, Add, Button, Default gHandleCmdRptOK, &OK
        Gui, Show
    }
    else {
        MsgBox % "The command history is currently empty; there are no commands to repeat."
    }
return

:*:@showLastCmd::
    CheckForCmdEntryGui()
    if (ahkCmds.Length() > 0) {
        MsgBox % "Last command entered into history: `r" . ahkCmds[ahkCmds.Length()]
    }
    else {
        MsgBox % "The command history is currently empty."
    }
return

^!x::
    sgCmdBeingEntered = true
    Gui, AhkGuiEnterCmd:New,, % "Enter AutoHotkey Hotstring"
    Gui, AhkGuiEnterCmd:Add, Text,, % "Enter the hotstring you would like to run:"
    Gui, AhkGuiEnterCmd:Add, Edit, r1 w500 vCmdEntryBox
    Gui, AhkGuiEnterCmd:Add, Button, Default gHandleEnterCmdCancel, &Cancel
    Gui, AhkGuiEnterCmd:Show
return
