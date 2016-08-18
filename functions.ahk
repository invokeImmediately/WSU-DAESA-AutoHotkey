; ============================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ============================================================================================================
; IMPORT DEPENDENCIES
;   This file has no import dependencies.
; ============================================================================================================
; IMPORT ASSUMPTIONS
;   This file makes no import assumptions.
; ============================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

; ------------------------------------------------------------------------------------------------------------
; General FUNCTIONS used for multiple purposes
; ------------------------------------------------------------------------------------------------------------

doesVarExist(ByRef v) { ; Requires 1.0.46+ 
    return &v = &undeclared ? 0 : 1 
}

isVarEmpty(ByRef v) { ; Requires 1.0.46+ 
    return v = "" ? 1 : 0 
}

isVarDeclared(ByRef v) { ; Requires 1.0.46+ 
    return &v = &undeclared ? 0 : v = "" ? 0 : 1
}

LaunchApplicationPatiently(path, title)
{
    Run % path
    isReady := false
    while !isReady
    {
        IfWinExist, % title
        {
            isReady := true
            Sleep, 500
        }
        else
        {
            Sleep, 250
        }
    }
}

InsertFilePath(ahkCmdName, filePath) {
	AppendAhkCmd(ahkCmdName)
    if (UserFolderIsSet()) {
        if (IsGitShellActive()) {
            SendInput % "cd """ . filePath . """{Enter}"
        }
        else {
            SendInput % filePath . "{Enter}"
        }
    }
}

MoveCursorIntoActiveWindow(ByRef curPosX, ByRef curPosY)
{
	WinGetPos, winPosX, winPosY, winW, winH, A
	if (curPosX < 0) {
		curPosX := 50
	}
	else if(curPosX > winW) {
		curPosX := winW - 50
	}
	if (curPosY < 0) {
		curPosY := 100
	}
	else if(curPosY > winH) {
		curPosY := winH - 50
	}
}

WaitForApplicationPatiently(title)
{
    isReady := false
    while !isReady
    {
        IfWinExist, % title
        {
            isReady := true
            Sleep, 500
        }
        else
        {
            Sleep, 250
        }
    }
}
