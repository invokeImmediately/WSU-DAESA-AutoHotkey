:*:@clearCmdHistory::
    while ahkCmds.Length() > 0 {
        ahkCmds.Pop()
    }
return

:*:@doLastCmd::
    if (ahkCmds.Length() > 0) {
        if IsLabel(ahkCmds[ahkCmds.Length()]) {
            GoSub % ahkCmds[ahkCmds.Length()]
        }
    }
return

:*:@rptCmd::
    if (ahkCmds.Length() > 0) {
        index := 1
        cmdList := "1: " . ahkCmds[1]
        index := index + 1
        while index <= ahkCmds.Length() {
            cmdList := cmdList . "|" . index . ": " . ahkCmds[index]
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

HandleCmdRptOK:
    Gui, Submit
    Gui, Destroy
    if (CmdChosen > 0 && CmdChosen <= ahkCmds.Length()) {
        GoSub % ahkCmds[CmdChosen]
    }
return

:*:@showLastCmd::
    if (ahkCmds.Length() > 0) {
        MsgBox % "Last command entered into history: `r" . ahkCmds[ahkCmds.Length()]
    }
    else {
        MsgBox % "The command history is currently empty."
    }
return

AppendAhkCmd(whatCmd) {
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
