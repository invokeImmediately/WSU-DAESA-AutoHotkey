; ============================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ============================================================================================================
; IMPORT DEPENDENCIES
;   Global Variable Name    Purpose
;   --------------------    ------------------------------------------------------------------------------
;   userAccountFolder       Contains the path to the Windows user folder for the script runner
; ============================================================================================================
; IMPORT ASSUMPTIONS
;   Environmental Property           State
;   ----------------------------     ---------------------------------------------------------------------
;   Location of GitHub               …userAccountFolder (see above dependency)…\Documents\GitHub
;   Repositories locally present     All those from https://github.com/invokeImmediately 
; ============================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

sgIsPostingMinCss := false
sgIsPostingMinJs := false

; ------------------------------------------------------------------------------------------------------------
; SETTINGS accessed via functions for this imported file
; ------------------------------------------------------------------------------------------------------------

UserFolderIsSet()
{
    global userAccountFolder
    varDeclared := userAccountFolder != thisIsUndeclared
    if (!varDeclared) {
        MsgBox, % (0x0 + 0x10), % "ERROR: Upstream dependency missing in github.ahk", % "The global variable specifying the user's account folder has not been declared and set upstream."
    }
    return varDeclared
}

GetGitHubFolder()
{
    global userAccountFolder
    return userAccountFolder . "\Documents\GitHub"
}

ToEscapedPath(path)
{
	escapedPath := StrReplace(path, "\", "\\")
    return escapedPath
}

GetCurrentDirFromPS()
{
	copyDirCmd := "(get-location).ToString() | clip`r`n"
	PasteTextIntoGitShell("", copyDirCmd)
	while(Clipboard = copyDirCmd) {
		Sleep 100
	}
	return Clipboard
}

GetCmdForMoveToCSSFolder(curDir)
{
	cmd := ""
	needleStr := "^" . ToEscapedPath(GetGitHubFolder()) . "(.+)"
	posFound := RegExMatch(curDir, needleStr, matches)
	if(posFound > 0) {
		if(doesVarExist(matches1) && !doesVarExist(matches2)) {
			cmd := "awesome!"
		}
	}
	return cmd
}

; ------------------------------------------------------------------------------------------------------------
; FUNCTIONS for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

ActivateGitShell()
{
    WinGet, thisProcess, ProcessName, A
    shellActivated := false
    if (thisProcess != "PowerShell.exe") {
        IfWinExist, % "ahk_exe PowerShell.exe"
        {
            WinActivate, % "ahk_exe PowerShell.exe"
            shellActivated := true
        }
    }
    else {
        shellActivated := true
    }
    return shellActivated
}

CopySrcFileToClipboard(ahkCmdName, srcFileToCopy, strToPrepend, errorMsg) {
    AppendAhkCmd(ahkCmdName)
    if (UserFolderIsSet()) {
        srcFile := FileOpen(srcFileToCopy, "r")
        if (srcFile != 0) {
            contents := srcFile.Read()
            srcFile.Close()
            clipboard := strToPrepend . contents
        }
        else {
            MsgBox, % (0x0 + 0x10), % errorMsg, % "Failed to open file: " . fileToOpen
        }
    }
}

IsGitShellActive()
{
    WinGet, thisProcess, ProcessName, A
    shellIsActive := thisProcess = "PowerShell.exe"
    return shellIsActive
}

PasteTextIntoGitShell(ahkCmdName, shellText) {
	AppendAhkCmd(ahkCmdName)
    if (UserFolderIsSet()) {
        proceedWithPaste := ActivateGitShell()
        if (proceedWithPaste) {
			MouseGetPos, curPosX, curPosY
			MoveCursorIntoActiveWindow(curPosX, curPosY)
            clipboard = %shellText%
            Click right %curPosX%, %curPosY%
        }
        else {
            MsgBox, % (0x0 + 0x10), % "ERROR (" . ahkCmdName . "): GitHub process not found", % "Was unable to activate GitHub Powershell; aborting hotstring."
        }
    }
}

; ------------------------------------------------------------------------------------------------------------
; GUI FUNCTIONS for handling user interactions with scripts
; ------------------------------------------------------------------------------------------------------------

PasteMinCssToWebsite(websiteUrl, cssCopyCmd)
{
    WinGet, thisProcess, ProcessName, A
	if (thisProcess != "chrome.exe") {
		WinActivate, % "ahk_exe chrome.exe"
		WinGetPos, thisX, thisY, thisW, thisH, A
		if (thisX != -1830 or thisY != 0 or thisW != 1700 or thisH != 1040) {
			WinMove, A, , -1830, 0, 1700, 1040
		}
	}
	Sleep, 330
	SendInput, ^t
	Sleep, 1000
	SendInput, !d
	Sleep, 200
	SendInput, % websiteUrl . "{Enter}"
	Sleep, 200
	Gosub, %cssCopyCmd%
	Sleep, 7500
	proceed := false
	WinGetTitle, thisTitle, A
	IfNotInString, thisTitle, % "New Tab"
		proceed := true
	while (!proceed) {
		Sleep 2000
		WinGetTitle, thisTitle, A
		IfNotInString, thisTitle, % "New Tab"
			proceed := true
	}
	Gosub, ExecuteCssPasteCmds
	Sleep, 1000
}

HandlePostMinCssOK:
    Gui, Submit
    Gui, Destroy ;Doing this now implicitly allows us to return to the previously active window.
	sgIsPostingMinCss := true
	if (PostMinCssToCr) {
		PasteMinCssToWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssCr")
	}
	if (PostMinCssToDsp) {
		PasteMinCssToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssDsp")
	}
	if (PostMinCssToFye) {
		PasteMinCssToWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssFye")
	}
	if (PostMinCssToFyf) {
		PasteMinCssToWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssFyf")
	}
	if (PostMinCssToPbk) {
		PasteMinCssToWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssPbk")
	}
	if (PostMinCssToSurca) {
		PasteMinCssToWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssSurca")
	}
	if (PostMinCssToSumRes) {
		PasteMinCssToWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssSumRes")
	}
	if (PostMinCssToXfer,) {
		PasteMinCssToWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssXfer")
	}
	if (PostMinCssToUgr) {
		PasteMinCssToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssUgr")
	}
	if (PostMinCssToUcore) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=editcss", ":*:@copyMinCssUcore")
	}
	if (PostMinCssToUcrAss) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=editcss", ":*:@copyMinCssUcrAss")
	}
	sgIsPostingMinCss := false
return

HandlePostMinCssCancel:
    Gui, Destroy ;Doing this now implicitly allows us to return to the previously active window.
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

PasteMinJsToWebsite(websiteUrl, jsCopyCmd)
{
    WinGet, thisProcess, ProcessName, A
	if (thisProcess != "chrome.exe") {
		WinActivate, % "ahk_exe chrome.exe"
		WinGetPos, thisX, thisY, thisW, thisH, A
		if (thisX != -1830 or thisY != 0 or thisW != 1700 or thisH != 1040) {
			WinMove, A, , -1830, 0, 1700, 1040
		}
	}
	Sleep, 330
	SendInput, ^t
	Sleep, 1000
	SendInput, !d
	Sleep, 200
	SendInput, % websiteUrl . "{Enter}"
	Sleep, 200
	Gosub, %jsCopyCmd%
	Sleep, 7500
	proceed := false
	WinGetTitle, thisTitle, A
	IfNotInString, thisTitle, % "New Tab"
		proceed := true
	while (!proceed) {
		Sleep 2000
		WinGetTitle, thisTitle, A
		IfNotInString, thisTitle, % "New Tab"
			proceed := true
	}
	Gosub, ExecuteJsPasteCmds
	Sleep, 1000
}

HandlePostMinJsOK:
    Gui, Submit
    Gui, Destroy ;Doing this now implicitly allows us to return to the previously active window.
	sgIsPostingMinJs := true
	if (PostMinJsToCr) {
		PasteMinJsToWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsCr")
	}
	if (PostMinJsToDsp) {
		PasteMinJsToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsDsp")
	}
	if (PostMinJsToFye) {
		PasteMinJsToWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsFye")
	}
	if (PostMinJsToFyf) {
		PasteMinJsToWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsFyf")
	}
	if (PostMinJsToPbk) {
		PasteMinJsToWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsPbk")
	}
	if (PostMinJsToSurca) {
		PasteMinJsToWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsSurca")
	}
	if (PostMinJsToSumRes) {
		PasteMinJsToWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsSumRes")
	}
	if (PostMinJsToXfer,) {
		PasteMinJsToWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsXfer")
	}
	if (PostMinJsToUgr) {
		PasteMinJsToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsUgr")
	}
	if (PostMinJsToUcore) {
		PasteMinJsToWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsUcore")
	}
	if (PostMinJsToUcrAss) {
		PasteMinJsToWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=custom-javascript", ":*:@copyMinJsUcrAss")
	}
	sgIsPostingMinJs := false
return

HandlePostMinJsCancel:
    Gui, Destroy ;Doing this now implicitly allows us to return to the previously active window.
return

; ------------------------------------------------------------------------------------------------------------
; FILE SYSTEM NAVIGATION
; ------------------------------------------------------------------------------------------------------------

:*:@gotoGhCr::
    InsertFilePath(":*:@gotoGhCr", GetGitHubFolder() . "\commonreading.wsu.edu") 
return

:*:@gotoGhDsp::
    InsertFilePath(":*:@gotoGhDsp", GetGitHubFolder() . "\distinguishedscholarships.wsu.edu") 
return

:*:@gotoGhFye::
    InsertFilePath(":*:@gotoGhFye", GetGitHubFolder() . "\firstyear.wsu.edu")
return

:*:@gotoGhFyf::
    InsertFilePath(":*:@gotoGhFyf", GetGitHubFolder() . "\learningcommunities.wsu.edu")
return

:*:@gotoGhPbk::
    InsertFilePath(":*:@gotoGhPbk", GetGitHubFolder() . "\phibetakappa.wsu.edu")
return

:*:@gotoGhSurca::
    InsertFilePath(":*:@gotoGhSurca", GetGitHubFolder() . "\surca.wsu.edu")
return

:*:@gotoGhSumRes::
    InsertFilePath(":*:@gotoGhSumRes", GetGitHubFolder() . "\summerresearch.wsu.edu")
return

:*:@gotoGhXfer::
    InsertFilePath(":*:@gotoGhXfer", GetGitHubFolder() . "\transfercredit.wsu.edu")
return

:*:@gotoGhUgr::
    InsertFilePath(":*:@gotoGhUgr", GetGitHubFolder() . "\undergraduateresearch.wsu.edu")
return

:*:@gotoGhUcore::
    InsertFilePath(":*:@gotoGhUcore", GetGitHubFolder() . "\ucore.wsu.edu")
return

:*:@gotoGhUcrAss::
    InsertFilePath(":*:@gotoGhUcrAss", GetGitHubFolder() . "\ucore.wsu.edu-assessment")
return

:*:@gotoGhCSS::
    InsertFilePath(":*:@gotoGhCSS", GetGitHubFolder() . "\WSU-UE---CSS")
return

:*:@gotoGhJS::
    InsertFilePath(":*:@gotoGhJS", GetGitHubFolder() . "\WSU-UE---JS")
return

:*:@gotoGhAhk::
    InsertFilePath(":*:@gotoGhAhk", GetGitHubFolder() . "\WSU-OUE-AutoHotkey")
return

; ------------------------------------------------------------------------------------------------------------
; UTILITY HOTSTRINGS for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

:*:@doGitCommit::
    AppendAhkCmd(":*:@doGitCommit")
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput git commit -m "" -m ""{Left 7}
	}
	else {
        MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doGitCommit" . "): Could Not Locate Git PowerShell", % "The Git PowerShell process could not be located and activated."
	}
return

:*:@dogc::
	Gosub, :*:@doGitCommit
return

:*:@doSnglGitCommit::
    AppendAhkCmd(":*:@doSnglGitCommit")
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput git commit -m ""{Left 1}
	}
	else {
        MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doSnglGitCommit" . "): Could Not Locate Git PowerShell", % "The Git PowerShell process could not be located and activated."
	}
return

:*:@dosgc::
	Gosub, :*:@doSnglGitCommit
return

:*:@doGitStatus::
    AppendAhkCmd(":*:@doGitStatus")
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput % "git status{enter}"
	}
	else {
        MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doGitStatus" . "): Could Not Locate Git PowerShell", % "The Git PowerShell process could not be located and activated."
	}
return

:*:@dogs::
	Gosub, :*:@doGitStatus
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@pasteGitCommitMsg::
    AppendAhkCmd(":*:@pasteGitCommitMsg")
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "PowerShell.exe") {
        commitText := RegExReplace(clipboard, Chr(0x2026) "\R" Chr(0x2026), "")
        clipboard = %commitText%
        Click right 44, 55
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gitAddThis::
    AppendAhkCmd(":*:@gitAddThis")
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "notepad++.exe") {
        SendInput !e
        Sleep 20
        SendInput {Down 8}
        Sleep 20
        SendInput {Right}
        Sleep 20
        SendInput {Down}
        Sleep 20
        SendInput {Enter}
        Sleep 20
        commitText := RegExReplace(clipboard, "^(.*)", "git add $1")
        clipboard = %commitText%
    }
    else {
        MsgBox, % (0x0 + 0x10), % "ERROR: Clipboard does not contain valid file name", % "Please select the file within NotePad++.exe that you would like to create a 'git add …' "
         . "string for."
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@swapSlashes::
    ; DESCRIPTION: For reversing forward slashes within a copied file name reported by 'git status' in
    ;  PowerShell and then pasting the result into PowerShell.
    AppendAhkCmd(":*:@swapSlashes")
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "PowerShell.exe") {
        newText := RegExReplace(clipboard, "/", "\")
        clipboard := newText
        Click right 44, 55 ;TODO: Check to see if the mouse cursor is already within the PowerShell bounding rectangle 
    }    
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@initCssPaste::
;	prevTitleMatchMode := A_TitleMatchMode
;	SetTitleMatchMode, RegEx
;	SetTitleMatchMode, prevTitleMatchMode
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
    AppendAhkCmd(":*:@initCssPaste")
	WinGetTitle, thisTitle, A
	posFound := RegExMatch(thisTitle, "i)^CSS[^" . Chr(0x2014) . "]+" . Chr(0x2014) . " WordPress - Google Chrome$")
	if(posFound) {
		WinGet, hwndCssPasteWindow, ID, A
		titleCssPasteWindowTab := thisTitle
		MsgBox, % "HWND for window containing CSS stylsheet editor set to " . hwndCssPasteWindow
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (:*:@setCssPasteWindow): CSS Stylesheet Editor Not Active", % "Please select your CSS stylesheet editor tab in Chrome as the currently active window."
	}
return

ExecuteCssPasteCmds:
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch(clipboard, "^/\* Built with the LESS CSS")
	if (posFound != 0) {
		CoordMode, Mouse, Client
		Click, 768, 570
		Sleep, 100
		SendInput, ^a
		Sleep, 100
		SendInput, ^v
		Sleep, 1000
		Click, 1565, 370
		Sleep, 60
		Click, 1565, 410
		Sleep, 60
		Click, 1565, 455
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): Clipboard Has Unexpected Contents", % "The clipboard does not begin with the expected '@import ...,' and thus may not contain minified CSS."
	}			
return

:*:@doCssPaste::
    ; DESCRIPTION: Paste copied CSS into WordPress window
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
    AppendAhkCmd(":*:@doCssPaste")
	if(isVarDeclared(hwndCssPasteWindow)) {
		; Attempt to switch to chrome
		WinActivate, % "ahk_id " . hwndCssPasteWindow
		WinWaitActive, % "ahk_id " . hwndCssPasteWindow, , 1
		if (ErrorLevel) {
			MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): Could Not Find Process", % "The HWND set for the chrome window containing the tab in which the CSS stylesheet editor was loaded can no longer be found."
		}
		else {
			WinGetTitle, thisTitle, A
			if(thisTitle != titleCssPasteWindowTab) {
				startingTitle := thistTitle
				SendInput, ^{Tab}
				Sleep 100
				WinGetTitle, currentTitle, A
				while (currentTitle != startingTitle and currentTitle != titleCssPasteWindowTab) {
					SendInput, ^{Tab}
					Sleep 100
					WinGetTitle, currentTitle, A
				}
				if(currentTitle != titleCssPasteWindowTab) {
					MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): Couldn't Find Tab", % "Could not locate the tab containing the CSS stylesheet editor."
				}
				else {
					proceedWithPaste := true
				}
			}
			else {
				proceedWithPaste := true
			}
			if (proceedWithPaste) {
				; Add check for expected client coordinates; if not correct, then reset window position
				WinGetPos, thisX, thisY, thisW, thisH, A
				if (thisX != -1830 or thisY != 0 or thisW != 1700 or thisH != 1040) {
					WinMove, A, , -1830, 0, 1700, 1040
				}
				Gosub, ExecuteCssPasteCmds
			}
		}
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): HWND Not Set Yet", % "You haven't yet used the @setCssPasteWindow hotstring to set the HWND for the Chrome window containing a tab with the CSS stylsheet editor."
	}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

ExecuteJsPasteCmds:
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch(clipboard, "^// Built with Node.js")
	if (posFound != 0) {
		CoordMode, Mouse, Client
		Click, 461, 371
		Sleep, 330
		SendInput, ^a
		Sleep, 2500
		SendInput, ^v
		Sleep, 10000
		Click, 214, 565
		Sleep, 60
		Click, 214, 615
		Sleep 2500
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doJsPaste): Clipboard Has Unexpected Contents", % "The clipboard does not begin with the expected '// Built with Node.js ...,' and thus may not contain minified JS."
	}			
return

; ------------------------------------------------------------------------------------------------------------
; COMMAND LINE INPUT GENERATION as triggered by HotStrings for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

:*:@rebuildCssHere::
	currentDir := GetCurrentDirFromPS()
	if (GetCmdForMoveToCSSFolder(currentDir) = "awesome!") {
		MsgBox % "Current location: " . currentDir
	}
return

:*:@rebuildCssCr::
    PasteTextIntoGitShell(":*:@rebuildCssCr"
        , "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\CSS""`r"
        . "lessc cr-custom.less cr-custom.css`r"
        . "lessc --clean-css cr-custom.less cr-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\""`r"
        . "git add CSS\cr-custom.css`r"
        . "git add CSS\cr-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildCssDsp::
    PasteTextIntoGitShell(":*:@rebuildCssDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS""`r"
        . "lessc dsp-custom.less dsp-custom.css`r"
        . "lessc --clean-css dsp-custom.less dsp-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
        . "git add CSS\dsp-custom.css`r"
        . "git add CSS\dsp-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildCssFye::
    PasteTextIntoGitShell(":*:@rebuildCssFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\CSS""`r"
        . "lessc fye-custom.less fye-custom.css`r"
        . "lessc --clean-css fye-custom.less fye-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
        . "git add CSS\fye-custom.css`r"
        . "git add CSS\fye-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildCssFyf::
    PasteTextIntoGitShell(":*:@rebuildCssFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS""`r"
        . "lessc learningcommunities-custom.less learningcommunities-custom.css`r"
        . "lessc --clean-css learningcommunities-custom.less learningcommunities-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
        . "git add CSS\learningcommunities-custom.css`r"
        . "git add CSS\learningcommunities-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildCssPbk::
    PasteTextIntoGitShell(":*:@rebuildCssPbk"
        , "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS""`r"
        . "lessc pbk-custom.less pbk-custom.css`r"
        . "gulp cmq`r"
        . "lessc --clean-css pbk-custom.less pbk-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\""`r"
        . "git add CSS\pbk-custom.css`r"
        . "git add CSS\pbk-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildCssSurca::
    PasteTextIntoGitShell(":*:@rebuildCssSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\CSS""`r"
        . "lessc surca-custom.less surca-custom.css`r"
        . "lessc --clean-css surca-custom.less surca-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
        . "git add CSS\surca-custom.css`r"
        . "git add CSS\surca-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildCssSumRes::
    PasteTextIntoGitShell(":*:@rebuildCssSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\CSS""`r"
        . "lessc summerresearch-custom.less summerresearch-custom.css`r"
        . "lessc --clean-css summerresearch-custom.less summerresearch-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
        . "git add CSS\summerresearch-custom.css`r"
        . "git add CSS\summerresearch-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildCssXfer::
    PasteTextIntoGitShell(":*:@rebuildCssXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\CSS""`r"
        . "lessc xfercredit-custom.less xfercredit-custom.css`r"
        . "lessc --clean-css xfercredit-custom.less xfercredit-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
        . "git add CSS\xfercredit-custom.css`r"
        . "git add CSS\xfercredit-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildCssUgr::
    PasteTextIntoGitShell(":*:@rebuildCssUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS""`r"
        . "lessc undergraduate-research-custom.less undergraduate-research-custom.css`r"
        . "lessc --clean-css undergraduate-research-custom.less undergraduate-research-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
        . "git add CSS\undergraduate-research-custom.css`r"
        . "git add CSS\undergraduate-research-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildCssUcore::
    PasteTextIntoGitShell(":*:@rebuildCssUcore"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\CSS""`r"
        . "lessc ucore-custom.less ucore-custom.css`r"
        . "lessc --clean-css ucore-custom.less ucore-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\""`r"
        . "git add CSS\ucore-custom.css`r"
        . "git add CSS\ucore-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildCssUcrAss::
    PasteTextIntoGitShell(":*:@rebuildCssUcrAss"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS""`r"
        . "lessc ucore-assessment-custom.less ucore-assessment-custom.css`r"
        . "lessc --clean-css ucore-assessment-custom.less ucore-assessment-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\""`r"
        . "git add CSS\ucore-assessment-custom.css`r"
        . "git add CSS\ucore-assessment-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleCr::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleCr"
        , "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssCr
return

:*:@updateCssSubmoduleDsp::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssDsp
return

:*:@updateCssSubmoduleFye::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssFye
return

:*:@updateCssSubmoduleFyf::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssFyf
return

:*:@updateCssSubmodulePbk::
    PasteTextIntoGitShell(":*:@updateCssSubmodulePbk"
        , "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssPbk
return

:*:@updateCssSubmoduleSurca::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssSurca
return

:*:@updateCssSubmoduleSumRes::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssSumRes
return

:*:@updateCssSubmoduleXfer::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssXfer
return

:*:@updateCssSubmoduleUgr::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssUgr
return

:*:@updateCssSubmoduleUcore::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleUcore"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssUcore
return

:*:@updateCssSubmoduleUcrAss::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleUcrAss"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssUcrAss
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleAll::
    AppendAhkCmd(":*:@updateCssSubmoduleAll")
	Gosub :*:@updateCssSubmoduleCr
    Gosub :*:@updateCssSubmoduleDsp
    Gosub :*:@updateCssSubmoduleFye
    Gosub :*:@updateCssSubmoduleFyf
    Gosub :*:@updateCssSubmodulePbk
    Gosub :*:@updateCssSubmoduleSurca
    Gosub :*:@updateCssSubmoduleSumRes
    Gosub :*:@updateCssSubmoduleXfer
    Gosub :*:@updateCssSubmoduleUgr
    Gosub :*:@updateCssSubmoduleUcore
    Gosub :*:@updateCssSubmoduleUcrAss
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@postMinCss::
    AppendAhkCmd(":*:@postMinCss")
    CheckForCmdEntryGui()
	
	if(!sgIsPostingMinCss) {
		Gui, New,, % "Post Minified CSS to OUE Websites"
		Gui, Add, Text,, % "Which OUE Websites would you like to update?"
		Gui, Add, CheckBox, vPostMinCssToCr Checked, % "https://commonreading.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToDsp Checked, % "https://distinguishedscholarships.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToFye Checked, % "https://firstyear.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToFyf Checked, % "https://learningcommunities.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToPbk Checked, % "https://phibetakappa.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToSurca Checked, % "https://surca.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToSumRes Checked, % "https://summerresearch.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToXfer, % "https://transfercredit.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToUgr Checked, % "https://undergraduateresearch.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToUcore Checked, % "https://ucore.wsu.edu"
		Gui, Add, CheckBox, vPostMinCssToUcrAss Checked, % "https://ucore.wsu.edu/assessment"
		Gui, Add, Button, Default gHandlePostMinCssOK, &OK
		Gui, Add, Button, gHandlePostMinCssCancel X+5, &Cancel
		Gui, Show
	}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@postMinJs::
    AppendAhkCmd(":*:@postMinJs")
    CheckForCmdEntryGui()
	
	if(!sgIsPostingMinJs) {
		Gui, New,, % "Post Minified JS to OUE Websites"
		Gui, Add, Text,, % "Which OUE Websites would you like to update?"
		Gui, Add, CheckBox, vPostMinJsToCr, % "https://commonreading.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToDsp Checked, % "https://distinguishedscholarships.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToFye Checked, % "https://firstyear.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToFyf Checked, % "https://learningcommunities.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToPbk Checked, % "https://phibetakappa.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToSurca Checked, % "https://surca.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToSumRes Checked, % "https://summerresearch.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToXfer, % "https://transfercredit.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToUgr Checked, % "https://undergraduateresearch.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToUcore Checked, % "https://ucore.wsu.edu"
		Gui, Add, CheckBox, vPostMinJsToUcrAss Checked, % "https://ucore.wsu.edu/assessment"
		Gui, Add, Button, Default gHandlePostMinJsOK, &OK
		Gui, Add, Button, gHandlePostMinJsCancel X+5, &Cancel
		Gui, Show
	}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssCr::
    CopySrcFileToClipboard(":*:@copyMinCssCr"
        , GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/commonreading.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for Common Reading website")
return

:*:@copyMinCssDsp::
    CopySrcFileToClipboard(":*:@copyMinCssDsp"
        , GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/distinguishedscholarships.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for DSP Website")
return

:*:@copyMinCssFye::
    CopySrcFileToClipboard(":*:@copyMinCssFye"
        , GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/firstyear.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for FYE website")
return

:*:@copyMinCssFyf::
    CopySrcFileToClipboard(":*:@copyMinCssFyf"
        , GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/learningcommunities.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for First-Year Focus website")
return

:*:@copyMinCssPbk::
    CopySrcFileToClipboard(":*:@copyMinCssPbk"
        , GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/phibetakappa.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for Phi Beta Kappa website")
return

:*:@copyMinCssSurca::
    CopySrcFileToClipboard(":*:@copyMinCssSurca"
        , GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/surca.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for SURCA website")
return

:*:@copyMinCssSumRes::
    CopySrcFileToClipboard(":*:@copyMinCssSumRes"
        , GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/summerresearch.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for Summer Research website")
return

:*:@copyMinCssXfer::
    CopySrcFileToClipboard(":*:@copyMinCssXfer"
        , GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/transfercredit.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for Transfer Credit website")
return

:*:@copyMinCssUgr::
    CopySrcFileToClipboard(":*:@copyMinCssUgr"
        , GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/undergraduateresearch.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for UGR website")
return

:*:@copyMinCssUcore::
    CopySrcFileToClipboard(":*:@copyMinCssUcore"
        , GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/ucore.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for UCORE website")
return

:*:@copyMinCssUcrAss::
    CopySrcFileToClipboard(":*:@copyMinCssUcrAss"
        , GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/ucore.wsu.edu-assessment] for a repository of source code. */`r`n"
        , "ERROR: Couldn't copy minified CSS for UCORE Assessment website")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@rebuildJsCr::
    PasteTextIntoGitShell(":*:@rebuildJsCr"
        , "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildJsDsp::
    PasteTextIntoGitShell(":*:@rebuildJsDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-javascript-source.dsp.js --output wp-custom-js-source.min.dsp.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
        . "git add JS\wp-custom-javascript-source.dsp.js`r"
        . "git add JS\wp-custom-js-source.min.dsp.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildJsFye::
    PasteTextIntoGitShell(":*:@rebuildJsFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildJsFyf::
    PasteTextIntoGitShell(":*:@rebuildJsFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildJsPbk::
    PasteTextIntoGitShell(":*:@rebuildJsPbk"
        , "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildJsSurca::
    PasteTextIntoGitShell(":*:@rebuildJsSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildJsSumRes::
    PasteTextIntoGitShell(":*:@rebuildJsSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildJsXfer::
    PasteTextIntoGitShell(":*:@rebuildJsXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildJsUgr::
    PasteTextIntoGitShell(":*:@rebuildJsUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildJsUcore::
    PasteTextIntoGitShell(":*:@rebuildJsUcore"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildJsUcrAss::
    PasteTextIntoGitShell(":*:@rebuildJsUcrAss"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateJsSubmoduleCr::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleCr"
        , "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent change"
        . "s in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsCr
return

:*:@updateJsSubmoduleDsp::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent change"
        . "s in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsDsp
return

:*:@updateJsSubmoduleFye::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent change"
        . "s in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsFye
return

:*:@updateJsSubmoduleFyf::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent change"
        . "s in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsFyf
return

:*:@updateJsSubmodulePbk::
    PasteTextIntoGitShell(":*:@updateJsSubmodulePbk"
        , "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsPbk
return

:*:@updateJsSubmoduleSurca::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsSurca
return

:*:@updateJsSubmoduleSumRes::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsSumRes
return

:*:@updateJsSubmoduleXfer::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsXfer
return

:*:@updateJsSubmoduleUgr::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsUgr
return

:*:@updateJsSubmoduleUcore::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleUcore"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsUcore
return

:*:@updateJsSubmoduleUcrAss::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleUcrAss"
        , "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsUcrAss
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateJsSubmoduleAll::
    AppendAhkCmd(":*:@updateJsSubmoduleAll")
    Gosub :*:@updateJsSubmoduleDsp
    Gosub :*:@updateJsSubmoduleFye
    Gosub :*:@updateJsSubmoduleFyf
    Gosub :*:@updateJsSubmodulePbk
    Gosub :*:@updateJsSubmoduleSurca
    Gosub :*:@updateJsSubmoduleSumRes
    Gosub :*:@updateJsSubmoduleXfer
    Gosub :*:@updateJsSubmoduleUgr
    Gosub :*:@updateJsSubmoduleUcore
    Gosub :*:@updateJsSubmoduleUcrAss
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinJsCr::
    CopySrcFileToClipboard(":*:@copyMinJsCr"
        , GetGitHubFolder() . "\commonreading.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/commonreading.wsu.edu] for "
        . "a repository of source code.`r`n"
		, "ERROR: Couldn't Copy Minified JS for CR Website")
return

:*:@copyMinJsDsp::
    CopySrcFileToClipboard(":*:@copyMinJsDsp"
        , GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS\wp-custom-js-source.min.dsp.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/distinguishedscholarship.wsu.edu] for "
        . "a repository of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   cycle2, (c) 2012-2014 M. Alsup. | https://github.com/malsup/cycle2 | MIT license -- http://ma"
        . "lsup.github.io/mit-license.txt && GPL license -- http://malsup.github.io/gpl-license-v2.txt`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   imagesLoaded, (c) David DeSandro 2016 | http://imagesloaded.desandro.com/ | MIT license -- ht"
        . "tp://desandro.mit-license.org/`r`n"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   jQuery Media Plugin, (c) 2007-2010 M. Alsup. | http://malsup.com/jquery/media/ | MIT license "
        . "-- https://opensource.org/licenses/mit-license.php  && GPL license -- http://www.gnu.org/licenses/"
        . "gpl.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for DSP Website")
return

:*:@copyMinJsFye::
    CopySrcFileToClipboard(":*:@copyMinJsFye"
        , GetGitHubFolder() . "\firstyear.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/firstyear.wsu.edu] for a repository of"
        . "source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for FYE Website")
return

:*:@copyMinJsFyf::
    CopySrcFileToClipboard(":*:@copyMinJsFyf"
        , GetGitHubFolder() . "\learningcommunities.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/learningcommunities.wsu.edu] for a rep"
        . "ository of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for FYF Website")
return

:*:@copyMinJsPbk::
    CopySrcFileToClipboard(":*:@copyMinJsPbk"
        , GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/phibetakappa.wsu.edu] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for WSU Phi Beta Kappa Website")
return

:*:@copyMinJsSurca::
    CopySrcFileToClipboard(":*:@copyMinJsSurca"
        , GetGitHubFolder() . "\surca.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/surca.wsu.edu] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for SURCA")
return

:*:@copyMinJsSumRes::
    CopySrcFileToClipboard(":*:@copyMinJsSumRes"
        , GetGitHubFolder() . "\summerresearch.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/summerresearch.wsu.edu] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for WSU Summer Research Website")
return

:*:@copyMinJsXfer::
    CopySrcFileToClipboard(":*:@copyMinJsXfer"
        , GetGitHubFolder() . "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/transfercredit.wsu.edu] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for WSU Transfer Credit Website")
return

:*:@copyMinJsUgr::
    CopySrcFileToClipboard(":*:@copyMinJsUgr"
        , GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/undergraduateresearch.wsu.edu] for a r"
        . "epository of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for UGR Website")
return

:*:@copyMinJsUcore::
    CopySrcFileToClipboard(":*:@copyMinJsUcore"
        , GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/ucore.wsu.edu] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for WSU Summer Research Website")
return

:*:@copyMinJsUcrAss::
    CopySrcFileToClipboard(":*:@copyMinJsUcrAss"
        , GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/ucore.wsu.edu-assessment] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for WSU Summer Research Website")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
:*:@checkGitStatus::
    PasteTextIntoGitShell(":*:@checkGitStatus"
        , "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "write-host ""``n----------------------------------------------WSU-OUE-AutoHotkey------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-OUE-AutoHotkey\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n------------------------------------------------WSU-OUE---CSS---------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---CSS\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n-------------------------------------------------WSU-OUE---JS---------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---JS\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n--------------------------------------distinguishedscholarships.wsu.edu-----------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\distinguishedscholarships.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n----------------------------------------------firstyear.wsu.edu-------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\firstyear.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n-----------------------------------------learningcommunities.wsu.edu--------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\learningcommunities.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n------------------------------------------------surca.wsu.edu---------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\surca.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n----------------------------------------undergraduateresearch.wsu.edu-------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\undergraduateresearch.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n--------------------------------------------transfercredit.wsu.edu----------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\transfercredit.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n--------------------------------------------summerresearch.wsu.edu----------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\summerresearch.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n------------------------------------------------ucore.wsu.edu---------------------"
        . "----------------------------"" -foreground ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ucore.wsu.edu\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
        . "write-host ""``n-------------------------------------------ucore.wsu.edu/assessment---------------"
        . "----------------------------"" -foreground ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ucore.wsu.edu-assessment\""`r`n"
        . "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n")
return

; ------------------------------------------------------------------------------------------------------------
; KEYBOARD SHORTCUTS FOR POWERSHELL
; ------------------------------------------------------------------------------------------------------------

^+v::
	if (IsGitShellActive()) {
		PasteTextIntoGitShell("", clipboard)
	} else {
		GoSub, PerformBypassingCtrlShftV
	}
return

PerformBypassingCtrlShftV:
	Suspend
	Sleep 10
	SendInput ^+v
	Sleep 10
	Suspend, Off
return

^!Backspace::
	if (IsGitShellActive()) {
		SendInput {Backspace 120}
	} else {
		GoSub, PerformBypassingCtrlAltBS
	}
return

PerformBypassingCtrlAltBS:
	Suspend
	Sleep 10
	SendInput ^!{Backspace}
	Sleep 10
	Suspend, Off
return
