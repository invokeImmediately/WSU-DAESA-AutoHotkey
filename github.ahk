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
	Return varDeclared
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

GetGitHubFolder()
{
	global userAccountFolder
	Return userAccountFolder . "\Documents\GitHub"
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

ToEscapedPath(path)
{
	escapedPath := StrReplace(path, "\", "\\")
	Return escapedPath
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

GetCurrentDirFromPS()
{
	copyDirCmd := "(get-location).ToString() | clip`r`n"
	PasteTextIntoGitShell("", copyDirCmd)
	while(Clipboard = copyDirCmd) {
		Sleep 100
	}
	Return Clipboard
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
	Return cmd
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
	Return shellActivated
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

IsGitShellActive()
{
	WinGet, thisProcess, ProcessName, A
	shellIsActive := thisProcess = "PowerShell.exe"
	Return shellIsActive
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI DRIVEN HOTSTRINGS --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@postMinCss::
	AppendAhkCmd(":*:@postMinCss")
	CheckForCmdEntryGui()
	
	if(!sgIsPostingMinCss) {
		Gui, guiPostMinCss: New,, % "Post Minified CSS to OUE Websites"
		Gui, guiPostMinCss: Add, Text,, % "Which OUE Websites would you like to update?"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToCr, % "https://c&ommonreading.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToDsp Checked, % "https://&distinguishedscholarships.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToFye Checked, % "https://&firstyear.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToFyf Checked, % "https://&learningcommunities.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToPbk Checked, % "https://&phibetakappa.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToSurca Checked, % "https://&surca.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToSumRes Checked, % "https://su&mmerresearch.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToXfer, % "https://&transfercredit.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUgr Checked, % "https://&undergraduateresearch.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUcore Checked, % "https://uco&re.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUcrAss Checked, % "https://ucore.wsu.edu/&assessment"
		Gui, guiPostMinCss: Add, Button, Default gHandlePostMinCssOK, &OK
		Gui, guiPostMinCss: Add, Button, gHandlePostMinCssCancel X+5, &Cancel
		Gui, guiPostMinCss: Add, Button, gHandlePostCssCheckAllSites X+15, C&heck All
		Gui, guiPostMinCss: Add, Button, gHandlePostCssUncheckAllSites X+5, Unchec&k All
		Gui, guiPostMinCss: Show
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@postMinJs::
	AppendAhkCmd(":*:@postMinJs")
	CheckForCmdEntryGui()
	
	if(!sgIsPostingMinJs) {
		Gui, guiPostMinJs: New,, % "Post Minified JS to OUE Websites"
		Gui, guiPostMinJs: Add, Text,, % "Which OUE Websites would you like to update?"
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToCr, % "https://c&ommonreading.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToDsp Checked, % "https://&distinguishedscholarships.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToFye Checked, % "https://&firstyear.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToFyf Checked, % "https://&learningcommunities.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToPbk Checked, % "https://&phibetakappa.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToSurca Checked, % "https://&surca.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToSumRes Checked, % "https://su&mmerresearch.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToXfer, % "https://&transfercredit.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToUgr Checked, % "https://&undergraduateresearch.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToUcore Checked, % "https://uco&re.wsu.edu"		
		Gui,guiPostMinJs: Add, CheckBox, vPostMinJsToUcrAss Checked, % "https://ucore.wsu.edu/&assessment"
		Gui,guiPostMinJs: Add, Button, Default gHandlePostMinJsOK, &OK
		Gui,guiPostMinJs: Add, Button, gHandlePostMinJsCancel X+5, &Cancel
		Gui, guiPostMinJs: Add, Button, gHandlePostJsCheckAllSites X+15, C&heck All
		Gui, guiPostMinJs: Add, Button, gHandlePostJsUncheckAllSites X+5, Unchec&k All
		Gui,guiPostMinJs: Show
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI DRIVING FUNCTIONS --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostCssCheckAllSites:
	GuiControl, guiPostMinCss:, PostMinCssToCr, 1
	GuiControl, guiPostMinCss:, PostMinCssToDsp, 1
	GuiControl, guiPostMinCss:, PostMinCssToFye, 1
	GuiControl, guiPostMinCss:, PostMinCssToFyf, 1
	GuiControl, guiPostMinCss:, PostMinCssToPbk, 1
	GuiControl, guiPostMinCss:, PostMinCssToSurca, 1
	GuiControl, guiPostMinCss:, PostMinCssToSumRes, 1
	GuiControl, guiPostMinCss:, PostMinCssToXfer, 1
	GuiControl, guiPostMinCss:, PostMinCssToUgr, 1
	GuiControl, guiPostMinCss:, PostMinCssToUcore, 1
	GuiControl, guiPostMinCss:, PostMinCssToUcrAss, 1
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostJsCheckAllSites:
	GuiControl, guiPostMinJs:, PostMinJsToCr, 1
	GuiControl, guiPostMinJs:, PostMinJsToDsp, 1
	GuiControl, guiPostMinJs:, PostMinJsToFye, 1
	GuiControl, guiPostMinJs:, PostMinJsToFyf, 1
	GuiControl, guiPostMinJs:, PostMinJsToPbk, 1
	GuiControl, guiPostMinJs:, PostMinJsToSurca, 1
	GuiControl, guiPostMinJs:, PostMinJsToSumRes, 1
	GuiControl, guiPostMinJs:, PostMinJsToXfer, 1
	GuiControl, guiPostMinJs:, PostMinJsToUgr, 1
	GuiControl, guiPostMinJs:, PostMinJsToUcore, 1
	GuiControl, guiPostMinJs:, PostMinJsToUcrAss, 1
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostMinCssOK:
	Gui, guiPostMinCss: Submit
	Gui, guiPostMinCss: Destroy ;Doing this now implicitly allows us to Return to the previously active window.
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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostMinJsOK:
	Gui, Submit
	Gui, Destroy ;Doing this now implicitly allows us to Return to the previously active window.
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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostMinCssCancel:
	Gui, guiPostMinCss: Destroy ;Doing this now implicitly allows us to Return to the previously active window.
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostCssUncheckAllSites:
	GuiControl, guiPostMinCss:, PostMinCssToCr, 0
	GuiControl, guiPostMinCss:, PostMinCssToDsp, 0
	GuiControl, guiPostMinCss:, PostMinCssToFye, 0
	GuiControl, guiPostMinCss:, PostMinCssToFyf, 0
	GuiControl, guiPostMinCss:, PostMinCssToPbk, 0
	GuiControl, guiPostMinCss:, PostMinCssToSurca, 0
	GuiControl, guiPostMinCss:, PostMinCssToSumRes, 0
	GuiControl, guiPostMinCss:, PostMinCssToXfer, 0
	GuiControl, guiPostMinCss:, PostMinCssToUgr, 0
	GuiControl, guiPostMinCss:, PostMinCssToUcore, 0
	GuiControl, guiPostMinCss:, PostMinCssToUcrAss, 0
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostCssUncheckAllSites:
	GuiControl, guiPostMinJs:, PostMinJsToCr, 0
	GuiControl, guiPostMinJs:, PostMinJsToDsp, 0
	GuiControl, guiPostMinJs:, PostMinJsToFye, 0
	GuiControl, guiPostMinJs:, PostMinJsToFyf, 0
	GuiControl, guiPostMinJs:, PostMinJsToPbk, 0
	GuiControl, guiPostMinJs:, PostMinJsToSurca, 0
	GuiControl, guiPostMinJs:, PostMinJsToSumRes, 0
	GuiControl, guiPostMinJs:, PostMinJsToXfer, 0
	GuiControl, guiPostMinJs:, PostMinJsToUgr, 0
	GuiControl, guiPostMinJs:, PostMinJsToUcore, 0
	GuiControl, guiPostMinJs:, PostMinJsToUcrAss, 0
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
	Sleep, 5000
	proceed := false
	WinGetTitle, thisTitle, A
	IfNotInString, thisTitle, % "New Tab"
		proceed := true
	while (!proceed) {
		Sleep 1000
		WinGetTitle, thisTitle, A
		IfNotInString, thisTitle, % "New Tab"
			proceed := true
	}
	Sleep, 2000
	Gosub, ExecuteCssPasteCmds
	Sleep, 2000
}

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
		Sleep 1000
		WinGetTitle, thisTitle, A
		IfNotInString, thisTitle, % "New Tab"
			proceed := true
	}
	Sleep, 3000
	Gosub, ExecuteJsPasteCmds
	Sleep, 2000
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostMinJsCancel:
	Gui, Destroy ;Doing this now implicitly allows us to Return to the previously active window.
Return

; ------------------------------------------------------------------------------------------------------------
; FILE SYSTEM NAVIGATION
; ------------------------------------------------------------------------------------------------------------

:*:@gotoGhCr::
	InsertFilePath(":*:@gotoGhCr", GetGitHubFolder() . "\commonreading.wsu.edu") 
Return

:*:@gotoGhDsp::
	InsertFilePath(":*:@gotoGhDsp", GetGitHubFolder() . "\distinguishedscholarships.wsu.edu") 
Return

:*:@gotoGhFye::
	InsertFilePath(":*:@gotoGhFye", GetGitHubFolder() . "\firstyear.wsu.edu")
Return

:*:@gotoGhFyf::
	InsertFilePath(":*:@gotoGhFyf", GetGitHubFolder() . "\learningcommunities.wsu.edu")
Return

:*:@gotoGhPbk::
	InsertFilePath(":*:@gotoGhPbk", GetGitHubFolder() . "\phibetakappa.wsu.edu")
Return

:*:@gotoGhSurca::
	InsertFilePath(":*:@gotoGhSurca", GetGitHubFolder() . "\surca.wsu.edu")
Return

:*:@gotoGhSumRes::
	InsertFilePath(":*:@gotoGhSumRes", GetGitHubFolder() . "\summerresearch.wsu.edu")
Return

:*:@gotoGhXfer::
	InsertFilePath(":*:@gotoGhXfer", GetGitHubFolder() . "\transfercredit.wsu.edu")
Return

:*:@gotoGhUgr::
	InsertFilePath(":*:@gotoGhUgr", GetGitHubFolder() . "\undergraduateresearch.wsu.edu")
Return

:*:@gotoGhUcore::
	InsertFilePath(":*:@gotoGhUcore", GetGitHubFolder() . "\ucore.wsu.edu")
Return

:*:@gotoGhUcrAss::
	InsertFilePath(":*:@gotoGhUcrAss", GetGitHubFolder() . "\ucore.wsu.edu-assessment")
Return

:*:@gotoGhCSS::
	InsertFilePath(":*:@gotoGhCSS", GetGitHubFolder() . "\WSU-UE---CSS")
Return

:*:@gotoGhJS::
	InsertFilePath(":*:@gotoGhJS", GetGitHubFolder() . "\WSU-UE---JS")
Return

:*:@gotoGhAhk::
	InsertFilePath(":*:@gotoGhAhk", GetGitHubFolder() . "\WSU-OUE-AutoHotkey")
Return

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
Return

:*:@dogc::
	Gosub, :*:@doGitCommit
Return

:*:@doSnglGitCommit::
	AppendAhkCmd(":*:@doSnglGitCommit")
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput git commit -m ""{Left 1}
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doSnglGitCommit" . "): Could Not Locate Git PowerShell", % "The Git PowerShell process could not be located and activated."
	}
Return

:*:@dosgc::
	Gosub, :*:@doSnglGitCommit
Return

:*:@doGitStatus::
	AppendAhkCmd(":*:@doGitStatus")
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput % "git status{enter}"
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doGitStatus" . "): Could Not Locate Git PowerShell", % "The Git PowerShell process could not be located and activated."
	}
Return

:*:@dogs::
	Gosub, :*:@doGitStatus
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@pasteGitCommitMsg::
	AppendAhkCmd(":*:@pasteGitCommitMsg")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "PowerShell.exe") {
		commitText := RegExReplace(clipboard, Chr(0x2026) "\R" Chr(0x2026), "")
		clipboard = %commitText%
		Click right 44, 55
	}
Return

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

; ------------------------------------------------------------------------------------------------------------
; COMMAND LINE INPUT GENERATION as triggered by HotStrings for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> FOR REBUILDING CSS SOURCE FILES --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@rebuildCssHere::
	currentDir := GetCurrentDirFromPS()
	if (GetCmdForMoveToCSSFolder(currentDir) = "awesome!") {
		MsgBox % "Current location: " . currentDir
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> FOR UPDATING CSS SUBMODULES -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> FOR COPYING MINIFIED CSS TO CLIPBOARD -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssCr::
	CopySrcFileToClipboard(":*:@copyMinCssCr"
		, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/commonreading.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for Common Reading website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssDsp::
	CopySrcFileToClipboard(":*:@copyMinCssDsp"
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/distinguishedscholarships.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for DSP Website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssFye::
	CopySrcFileToClipboard(":*:@copyMinCssFye"
		, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/firstyear.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for FYE website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssFyf::
	CopySrcFileToClipboard(":*:@copyMinCssFyf"
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/learningcommunities.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for First-Year Focus website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssPbk::
	CopySrcFileToClipboard(":*:@copyMinCssPbk"
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/phibetakappa.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for Phi Beta Kappa website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssSurca::
	CopySrcFileToClipboard(":*:@copyMinCssSurca"
		, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/surca.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for SURCA website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssSumRes::
	CopySrcFileToClipboard(":*:@copyMinCssSumRes"
		, GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/summerresearch.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for Summer Research website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssXfer::
	CopySrcFileToClipboard(":*:@copyMinCssXfer"
		, GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/transfercredit.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for Transfer Credit website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssUgr::
	CopySrcFileToClipboard(":*:@copyMinCssUgr"
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/undergraduateresearch.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for UGR website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssUcore::
	CopySrcFileToClipboard(":*:@copyMinCssUcore"
		, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/ucore.wsu.edu] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for UCORE website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssUcrAss::
	CopySrcFileToClipboard(":*:@copyMinCssUcrAss"
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
		, "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/ucore.wsu.edu-assessment] for a repository of source code. */`r`n"
		, "ERROR: Couldn't copy minified CSS for UCORE Assessment website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> FOR REBUILDING JS SOURCE FILES ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> FOR UPDATING JS SUBMODULES --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> FOR COPYING MINIFIED CSS TO CLIPBOARD -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinJsCr::
	CopySrcFileToClipboard(":*:@copyMinJsCr"
		, GetGitHubFolder() . "\commonreading.wsu.edu\JS\wp-custom-js-source.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/commonreading.wsu.edu] for "
		. "a repository of source code.`r`n"
		, "ERROR: Couldn't Copy Minified JS for CR Website")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> FOR CHECKING GIT STATUS ON ALL PROJECTS  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
Return

; ------------------------------------------------------------------------------------------------------------
; KEYBOARD SHORTCUTS FOR POWERSHELL
; ------------------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> SHORTCUTS  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^+v::
	if (IsGitShellActive()) {
		PasteTextIntoGitShell("", clipboard)
	} else {
		GoSub, PerformBypassingCtrlShftV
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!Backspace::
	if (IsGitShellActive()) {
		SendInput {Backspace 120}
	} else {
		GoSub, PerformBypassingCtrlAltBS
	}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> SUPPORTING FUNCTIONS ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

PerformBypassingCtrlShftV:
	Suspend
	Sleep 10
	SendInput ^+v
	Sleep 10
	Suspend, Off
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

PerformBypassingCtrlAltBS:
	Suspend
	Sleep 10
	SendInput ^!{Backspace}
	Sleep 10
	Suspend, Off
Return
