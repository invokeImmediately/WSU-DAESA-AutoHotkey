; ============================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ============================================================================================================
; IMPORT DEPENDENCIES
;   Global Variable Name    Purpose
;   -·-·-·-·-·-·-·-·-·-     -·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·
;   userAccountFolder       Contains the path to the Windows user folder for the script runner
; ------------------------------------------------------------------------------------------------------------
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

GetCmdForMoveToCSSFolder(curDir) {
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

; ············································································································

GetCurrentDirFromPS() {
	copyDirCmd := "(get-location).ToString() | clip`r`n"
	PasteTextIntoGitShell("", copyDirCmd)
	while(Clipboard = copyDirCmd) {
		Sleep 100
	}
	Return Clipboard
}

; ············································································································

GetGitHubFolder() {
	global userAccountFolderSSD
	Return userAccountFolderSSD . "\Documents\GitHub"
}

; ············································································································

UserFolderIsSet() {
	global userAccountFolderSSD
	varDeclared := userAccountFolderSSD != thisIsUndeclared
	if (!varDeclared) {
		MsgBox, % (0x0 + 0x10), % "ERROR: Upstream dependency missing in github.ahk"
			, % "The global variable specifying the user's account folder has not been declared and set "
			. "upstream."
	}
	Return varDeclared
}

; ------------------------------------------------------------------------------------------------------------
; FUNCTIONS for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

ActivateGitShell() {
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

; ············································································································

CommitAfterBuild(ahkBuildCmd, ahkCommitCmd) {
	ahkFuncName := "github.ahk: CommitAfterBuild"
	errorMsg := ""
	qcAhkBuildCmd := IsLabel(ahkBuildCmd)
	qcAhkCommitCmd := IsLabel(ahkCommitCmd)
	if (qcAhkBuildCmd && qcAhkCommitCmd) {
		MsgBox, % (0x4 + 0x20)
			, % ahkBuildCmd . ": Proceed with commit?"
			, % "Would you like to proceed with the commit command " . ahkCommitCmd . "?"
		IfMsgBox Yes
			Gosub, %ahkCommitCmd%
	} else {
		if (!qcAhkBuildCmd) {
			errorMsg .= "Function was called with an invalid argument for the calling build command: "
				. ahkBuildCmd . "."
			if (!qcAhkCommitCmd) {
				errorMsg .= "The argument for the commit command to call next was also invalid: "
					. ahkCommitCmd . "."
			}		
		} else {
			errorMsg .= "Function was called from the build command " . ahkBuildCmd
				. ", but an invalid argument for the commit command was found: " . ahkCommitCmd . "."
		}
	}
	if (errorMsg != "") {
		MsgBox, % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
}

; ············································································································

; Sets up a GUI to automate committing of CSS build files.
CommitCssBuild(ahkCmdName, fpGitFolder, fnLessSrcFile, fnCssbuild, fnMinCssBuild) {
	; Global variable declarations
	global commitCssVars := Object()
	global ctrlCommitCssAlsoCommitLessSrc
	global ctrlCommitCssLessChangesOnly
	global ctrlCommitCss1stMsg
	global ctrlCommitCss1stMsgCharCount
	global ctrlCommitCss2ndMsg
	global ctrlCommitCss2ndMsgCharCount
	global ctrlCommitCss1stLessMsg
	global ctrlCommitCss1stLessMsgCharCount
	global commitCssDflt1stCommitMsg
	global ctrlCommitCss2ndLessMsg
	global ctrlCommitCss2ndLessMsgCharCount
	
	; Variable initializations
	commitCssVars.ahkCmdName := ahkCmdName
	commitCssVars.fpGitFolder := fpGitFolder
	commitCssVars.fnLessSrcFile := fnLessSrcFile
	commitCssVars.fnCssbuild := fnCssbuild
	commitCssVars.fnMinCssBuild := fnMinCssBuild
	commitCssVars.dflt1stCommitMsg := "Updating custom CSS build with recent submodule changes"
	commitCssVars.dflt1stCommitMsgAlt := "Updating custom CSS build w/ source & submodule changes"
	commitCssVars.dflt1stCommitMsgAlt2 := "Updating custom CSS build w/ site-specific source changes"
	commitCssVars.dflt2ndCommitMsg := "Rebuilding custom CSS production files to incorporate recent changes "
		. "to OUE-wide build dependencies."
	commitCssVars.dflt2ndCommitMsgAlt := "Rebuilding custom CSS production files to incorporate recent "
		. "changes to site-specific and OUE-wide build dependencies."
	commitCssVars.dflt2ndCommitMsgAlt2 := "Rebuilding custom CSS production files to incorporate recent "
		. "changes to site-specific build dependency; please see matching " . commitCssVars.fnLessSrcFile . " commit for more details."
	msgLen1st := StrLen(commitCssVars.dflt1stCommitMsg)
	msgLen2nd := StrLen(commitCssVars.dflt2ndCommitMsg)
	
	
	; GUI initialization & display to user
	Gui, guiCommitCssBuild: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCommitCssBuild: Add, Text, , % "&Primary commit message:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss1stMsg gHandleCommitCss1stMsgChange X+5 W606, % commitCssVars.dflt1stCommitMsg
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss1stMsgCharCount Y+1 W500, % "Length = " . msgLen1st . " characters"
	Gui, guiCommitCssBuild: Add, Text, xm Y+12, % "&Secondary commit message:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss2ndMsg gHandleCommitCss2ndMsgChange X+5 W589, % commitCssVars.dflt2ndCommitMsg
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss2ndMsgCharCount Y+1 W500, % "Length = " . msgLen2nd . " characters"
	Gui, guiCommitCssBuild: Add, Checkbox
		, vctrlCommitCssAlsoCommitLessSrc gHandleCommitCssCheckLessFileCommit xm Y+12
		, % "&Also commit less source " . commitCssVars.fnLessSrcFile . "?"
	Gui, guiCommitCssBuild: Add, Checkbox
		, vctrlCommitCssLessChangesOnly gHandleCommitCssCheckLessChangesOnly xm Disabled
		, % "Less source &is only changed dependency"
	Gui, guiCommitCssBuild: Add, Text, xm, % "Message for &LESS file changes:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss1stLessMsg gHandleCommitCss1stLessMsgChange X+5 W573 Disabled
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss1stLessMsgCharCount Y+1 W500, % "Length = 0 characters"
	Gui, guiCommitCssBuild: Add, Text, xm Y+12, % "Secondary L&ESS message (optional):"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss2ndLessMsg gHandleCommitCss2ndLessMsgChange X+5 W549 Disabled
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss2ndLessMsgCharCount Y+1 W500, % "Length = 0 characters"
	Gui, guiCommitCssBuild: Add, Button, Default gHandleCommitCssOk xm, &Ok
	Gui, guiCommitCssBuild: Add, Button, gHandleCommitCssCancel X+5, &Cancel
	Gui, guiCommitCssBuild: Show
}

; Triggered when the primary git commit message for the updated CSS builds is changed.
HandleCommitCss1stMsgChange() {
	; Make global variable declarations.
	global ctrlCommitCss1stMsg
	global ctrlCommitCss1stMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitCss1stMsg)
	GuiControl, , ctrlCommitCss1stMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered when the secondary git commit message for the updated CSS builds is changed.
HandleCommitCss2ndMsgChange() {
	; Make global variable declarations.
	global ctrlCommitCss2ndMsg
	global ctrlCommitCss2ndMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitCss2ndMsg)
	GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered by state changes in checkbox control in guiCommitCssBuild GUI.
HandleCommitCssCheckLessFileCommit() {
	; Make global variable declarations.
	global commitCssVars
	global ctrlCommitCss1stMsg
	global ctrlCommitCss1stMsgCharCount
	global ctrlCommitCss2ndMsg
	global ctrlCommitCss2ndMsgCharCount
	global ctrlCommitCss1stLessMsg
	global ctrlCommitCss2ndLessMsg
	global ctrlCommitCssAlsoCommitLessSrc
	global ctrlCommitCssLessChangesOnly
	
	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Respond to user input.
	if (ctrlCommitCssAlsoCommitLessSrc) {
		GuiControl, Enable, ctrlCommitCss1stLessMsg
		GuiControl, Enable, ctrlCommitCss2ndLessMsg
		GuiControl, Enable, ctrlCommitCssLessChangesOnly
		if (ctrlCommitCss1stMsg == commitCssVars.dflt1stCommitMsg) {
			GuiControl, , ctrlCommitCss1stMsg, % commitCssVars.dflt1stCommitMsgAlt
			msgLen := StrLen(commitCssVars.dflt1stCommitMsgAlt)
			GuiControl, , ctrlCommitCss1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitCss2ndMsg == commitCssVars.dflt2ndCommitMsg) {
			GuiControl, , ctrlCommitCss2ndMsg, % commitCssVars.dflt2ndCommitMsgAlt
			msgLen := StrLen(commitCssVars.dflt2ndCommitMsgAlt)
			GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	} else {
		GuiControl, Disable, ctrlCommitCss1stLessMsg
		GuiControl, Disable, ctrlCommitCss2ndLessMsg
		GuiControl, Disable, ctrlCommitCssLessChangesOnly
		if (ctrlCommitCss1stMsg == commitCssVars.dflt1stCommitMsgAlt) {
			GuiControl, , ctrlCommitCss1stMsg, % commitCssVars.dflt1stCommitMsg
			msgLen := StrLen(commitCssVars.dflt1stCommitMsg)
			GuiControl, , ctrlCommitCss1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitCss2ndMsg == commitCssVars.dflt2ndCommitMsgAlt) {
			GuiControl, , ctrlCommitCss2ndMsg, % commitCssVars.dflt2ndCommitMsg
			msgLen := StrLen(commitCssVars.dflt2ndCommitMsg)
			GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	}
}

; Triggered by state changes in checkbox control in guiCommitCssBuild GUI.
HandleCommitCssCheckLessChangesOnly() {
	; Make global variable declarations.
	global commitCssVars
	global ctrlCommitCss1stMsg
	global ctrlCommitCss1stMsgCharCount
	global ctrlCommitCss2ndMsg
	global ctrlCommitCss2ndMsgCharCount
	global ctrlCommitCssAlsoCommitLessSrc
	global ctrlCommitCssLessChangesOnly
	
	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Respond to user input.
	if (ctrlCommitCssLessChangesOnly) {
		GuiControl, Disable, ctrlCommitCssAlsoCommitLessSrc
		if (ctrlCommitCss1stMsg == commitCssVars.dflt1stCommitMsgAlt) {
			GuiControl, , ctrlCommitCss1stMsg, % commitCssVars.dflt1stCommitMsgAlt2
			msgLen := StrLen(commitCssVars.dflt1stCommitMsgAlt2)
			GuiControl, , ctrlCommitCss1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitCss2ndMsg == commitCssVars.dflt2ndCommitMsgAlt) {
			GuiControl, , ctrlCommitCss2ndMsg, % commitCssVars.dflt2ndCommitMsgAlt2
			msgLen := StrLen(commitCssVars.dflt2ndCommitMsgAlt2)
			GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	} else {
		GuiControl, Enable, ctrlCommitCssAlsoCommitLessSrc
		if (ctrlCommitCss1stMsg == commitCssVars.dflt1stCommitMsgAlt2) {
			GuiControl, , ctrlCommitCss1stMsg, % commitCssVars.dflt1stCommitMsgAlt
			msgLen := StrLen(commitCssVars.dflt1stCommitMsgAlt)
			GuiControl, , ctrlCommitCss1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitCss2ndMsg == commitCssVars.dflt2ndCommitMsgAlt2) {
			GuiControl, , ctrlCommitCss2ndMsg, % commitCssVars.dflt2ndCommitMsgAlt
			msgLen := StrLen(commitCssVars.dflt2ndCommitMsgAlt)
			GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	}
}

; Triggered when the primary git commit message for the updated LESS source is changed.
HandleCommitCss1stLessMsgChange() {
	; Make global variable declarations.
	global ctrlCommitCss1stLessMsg
	global ctrlCommitCss1stLessMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitCss1stLessMsg)
	GuiControl, , ctrlCommitCss1stLessMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered when the secondary git commit message for the updated LESS source is changed.
HandleCommitCss2ndLessMsgChange() {
	; Make global variable declarations.
	global ctrlCommitCss2ndLessMsg
	global ctrlCommitCss2ndLessMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitCss2ndLessMsg)
	GuiControl, , ctrlCommitCss2ndLessMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered by OK button in guiCommitCssBuild GUI.
HandleCommitCssOk() {
	global commitCssVars
	global ctrlCommitCss1stMsg
	global ctrlCommitCss2ndMsg
	global ctrlCommitCssAlsoCommitLessSrc
	global ctrlCommitCss1stLessMsg
	global ctrlCommitCss2ndLessMsg
	
	; Submit GUI to finalize variables storing user input.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Ensure that state of global variables is consistent with a valid GUI submission.
	gVarCheck := commitCssVars.ahkCmdName == undefined
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fpGitFolder == undefined)
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fnLessSrcFile == undefined)
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fnCssbuild == undefined)
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fnMinCssBuild == undefined)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitCss1stMsg == undefined)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitCssAlsoCommitLessSrc && ctrlCommitCss1stLessMsg == undefined)
	
	if (!gVarCheck) {
		; Close the GUI since the condition of our variables passed muster.
		Gui, guiCommitCssBuild: Destroy
		
		; Build the command line inputs for commiting the code to the appropriate git repository.
		commandLineInput := "cd """ . GetGitHubFolder() . "\" . commitCssVars.fpGitFolder . "\""`r"
			. "git add CSS\" . commitCssVars.fnCssBuild . "`r"
			. "git add CSS\" . commitCssVars.fnMinCssBuild . "`r"
			. "git commit -m """ . ctrlCommitCss1stMsg . """"
		if (ctrlCommitCss2ndMsg != "") {
			commandLineInput .= " -m """ . ctrlCommitCss2ndMsg . """ `r"
		} else {
			commandLineInput .= "`r"
		}
		commandLineInput .= "git push`r"
		if (ctrlCommitCssAlsoCommitLessSrc) {
			commandLineInput .= "git add CSS\" . commitCssVars.fnLessSrcFile . "`r"
				. "git commit -m """ . ctrlCommitCss1stLessMsg . """"
			if (ctrlCommitCss2ndLessMsg != "") {
				commandLineInput .= " -m """ . ctrlCommitCss2ndLessMsg . """ `r"
			} else {
				commandLineInput .= "`r"
			}
			commandLineInput .= "git push`r"			
		}
		commandLineInput .= "[console]::beep(2000,150)`r"
			. "[console]::beep(2000,150)`r"

		; Paste the code into the command console.
		PasteTextIntoGitShell(commitCssVars.ahkCmdName, commandLineInput)
	} else {
		; Determine what went wrong, notify user, and handle accordingly.
		ProcessHandleCommitCssOkError(gVarCheck)
	}
}

; Called by HandleCommitCssOk() to handle error processing.
ProcessHandleCommitCssOkError(gVarCheck) {
	functionName := "github.ahk / HandleCommitCssOk()"
	if (gVarCheck == 1) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the LESS source file.")
	} else if (gVarCheck == 2) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the CSS builds.")	
	} else if (gVarCheck == 3) {
		ErrorBox(functionName
			, "Please enter primary git commit messages regarding changes in the CSS builds and the LESS source file.")
	} else {
		Gui, guiCommitCssBuild: Destroy
		ErrorBox(functionName
			, "An undefined global variable was encountered; function terminating. Variable checking bitmask was equal to " . gVarCheck . ".")
	}
}

HandleCommitCssCancel() {
	Gui, guiCommitCssBuild: Destroy
}

; ············································································································

CopySrcFileToClipboard(ahkCmdName, srcFileToCopy, strToPrepend, errorMsg) {
	if (UserFolderIsSet()) {
		srcFile := FileOpen(srcFileToCopy, "r")
		if (srcFile != 0) {
			contents := srcFile.Read()
			srcFile.Close()
			clipboard := strToPrepend . contents
		}
		else {
			MsgBox, % (0x0 + 0x10), % "ERROR (" . ahkCmdName . ")", % errorMsg
				. "`rCAUSE = Failed to open file: " . srcFile
		}
	} else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . ahkCmdName . ")", % errorMsg
			. "`rCAUSE = User folder is not set."
	}
}

; ············································································································

IsGitShellActive() {
	WinGet, thisProcess, ProcessName, A
	shellIsActive := thisProcess = "PowerShell.exe"
	Return shellIsActive
}

; ············································································································

PasteTextIntoGitShell(ahkCmdName, shellText) {
	errorMsg := ""
	if (UserFolderIsSet()) {
		proceedWithPaste := ActivateGitShell()
		if (proceedWithPaste) {
			MouseGetPos, curPosX, curPosY
			MoveCursorIntoActiveWindow(curPosX, curPosY)
			clipboard = %shellText%
			Click right %curPosX%, %curPosY%
		} else {
			errorMsg := "Was unable to activate GitHub Powershell; aborting hotstring."
		}
	} else {
		errorMsg := "Because user folder is not set, location of GitHub is unknown."
	}
	if (errorMsg != "") {
		MsgBox, % (0x0 + 0x10)
			, % ahkCmdName . ": Error in Call to PasteTextIntoGitShell"
			, % errorMsg
	}
}

; ············································································································

ToEscapedPath(path) {
	escapedPath := StrReplace(path, "\", "\\")
	Return escapedPath
}

; ------------------------------------------------------------------------------------------------------------
; FUNCTIONS for interacting with online WEB DESIGN INTERFACES
; ------------------------------------------------------------------------------------------------------------

LoadWordPressSiteInChrome(websiteUrl) {
	WinGet, thisProcess, ProcessName, A
	if (thisProcess != "chrome.exe") {
		WinActivate, % "ahk_exe chrome.exe"
		WinGet, thisProcess, ProcessName, A
	}
	if (thisProcess = "chrome.exe") {
		WinRestore, A
		WinGetPos, thisX, thisY, thisW, thisH, A
		if (thisX != -1830 or thisY != 0 or thisW != 1700 or thisH != 1040) {
			WinMove, A, , -1830, 0, 1700, 1040
		}
		Sleep, 330
		SendInput, ^t
		Sleep, 1000
		SendInput, !d
		Sleep, 200
		SendInput, % websiteUrl . "{Enter}"
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
	}
}

; ------------------------------------------------------------------------------------------------------------
; GUI FUNCTIONS for handling user interactions with scripts
; ------------------------------------------------------------------------------------------------------------

; ············································································································
; >>> GUI DRIVEN HOTSTRINGS --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@postMinCss::
	AppendAhkCmd(":*:@postMinCss")
	if(!sgIsPostingMinCss) {
		Gui, guiPostMinCss: New,, % "Post Minified CSS to OUE Websites"
		Gui, guiPostMinCss: Add, Text,, % "Which OUE Websites would you like to update?"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToAscc, % "https://&ascc.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToCr, % "https://commonread&ing.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToDsp Checked
			, % "https://&distinguishedscholarships.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToFye Checked, % "https://&firstyear.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToFyf Checked, % "https://&learningcommunities.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToNse Checked, % "https://&nse.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToPbk Checked, % "https://&phibetakappa.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToSurca Checked, % "https://&surca.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToSumRes Checked, % "https://su&mmerresearch.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToXfer, % "https://&transfercredit.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUgr Checked
			, % "https://&undergraduateresearch.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUcore Checked, % "https://uco&re.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUcrAss Checked, % "https://ucor&e.wsu.edu/assessment"
		Gui, guiPostMinCss: Add, Button, Default gHandlePostMinCssOK, &OK
		Gui, guiPostMinCss: Add, Button, gHandlePostMinCssCancel X+5, &Cancel
		Gui, guiPostMinCss: Add, Button, gHandlePostCssCheckAllSites X+15, C&heck All
		Gui, guiPostMinCss: Add, Button, gHandlePostCssUncheckAllSites X+5, Unchec&k All
		Gui, guiPostMinCss: Show
	}
Return

; ············································································································

:*:@postBackupCss::
	AppendAhkCmd(":*:@postBackupCss")
	if(!sgIsPostingBackupCss) {
		Gui, guiPostBackupCss: New,
			, % "Post Minified CSS to OUE Websites"
		Gui, guiPostBackupCss: Add, Text,
			, % "Which OUE Websites would you like to update?"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToAscc
			, % "https://&ascc.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToCr
			, % "https://commonread&ing.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToDsp Checked
			, % "https://&distinguishedscholarships.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToFye Checked
			, % "https://&firstyear.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToFyf Checked
			, % "https://&learningcommunities.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToNse Checked
			, % "https://&nse.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToPbk Checked
			, % "https://&phibetakappa.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToSurca Checked
			, % "https://&surca.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToSumRes Checked
			, % "https://su&mmerresearch.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToXfer
			, % "https://&transfercredit.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToUgr Checked
			, % "https://&undergraduateresearch.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToUcore Checked
			, % "https://uco&re.wsu.edu"
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToUcrAss Checked
			, % "https://ucor&e.wsu.edu/assessment"
		Gui, guiPostBackupCss: Add, Button, Default gHandlePostBackupCssOK, &OK
		Gui, guiPostBackupCss: Add, Button, gHandlePostBackupCssCancel X+5, &Cancel
		Gui, guiPostBackupCss: Add, Button, gHandlePostBackupCssCheckAllSites X+15, C&heck All
		Gui, guiPostBackupCss: Add, Button, gHandlePostBackupCssUncheckAllSites X+5, Unchec&k All
		Gui, guiPostBackupCss: Show
	}
Return

; ············································································································

:*:@postMinJs::
	AppendAhkCmd(":*:@postMinJs")
	if(!sgIsPostingMinJs) {
		Gui, guiPostMinJs: New,
			, % "Post Minified JS to OUE Websites"
		Gui, guiPostMinJs: Add, Text,
			, % "Which OUE Websites would you like to update?"
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToAscc
			, % "https://&ascc.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToCr
			, % "https://commonread&ing.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToDsp Checked
			, % "https://&distinguishedscholarships.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToFye Checked
			, % "https://&firstyear.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToFyf Checked
			, % "https://&learningcommunities.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToNse Checked
			, % "https://&nse.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToPbk Checked
			, % "https://&phibetakappa.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToSurca Checked
			, % "https://&surca.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToSumRes Checked
			, % "https://su&mmerresearch.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToXfer
			, % "https://&transfercredit.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToUgr Checked
			, % "https://&undergraduateresearch.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToUcore Checked
			, % "https://uco&re.wsu.edu"		
		Gui, guiPostMinJs: Add, CheckBox, vPostMinJsToUcrAss Checked
			, % "https://ucore.wsu.edu/&assessment"
		Gui, guiPostMinJs: Add, Button, Default gHandlePostMinJsOK, &OK
		Gui, guiPostMinJs: Add, Button, gHandlePostMinJsCancel X+5, &Cancel
		Gui, guiPostMinJs: Add, Button, gHandlePostJsCheckAllSites X+15, C&heck All
		Gui, guiPostMinJs: Add, Button, gHandlePostJsUncheckAllSites X+5, Unchec&k All
		Gui, guiPostMinJs: Show
	}
Return

; ············································································································
; >>> GUI DRIVING FUNCTIONS --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandlePostCssCheckAllSites() {
	global
	GuiControl, guiPostMinCss:, PostMinCssToAscc, 1
	GuiControl, guiPostMinCss:, PostMinCssToCr, 1
	GuiControl, guiPostMinCss:, PostMinCssToDsp, 1
	GuiControl, guiPostMinCss:, PostMinCssToFye, 1
	GuiControl, guiPostMinCss:, PostMinCssToFyf, 1
	GuiControl, guiPostMinCss:, PostMinCssToNse, 1
	GuiControl, guiPostMinCss:, PostMinCssToPbk, 1
	GuiControl, guiPostMinCss:, PostMinCssToSurca, 1
	GuiControl, guiPostMinCss:, PostMinCssToSumRes, 1
	GuiControl, guiPostMinCss:, PostMinCssToXfer, 1
	GuiControl, guiPostMinCss:, PostMinCssToUgr, 1
	GuiControl, guiPostMinCss:, PostMinCssToUcore, 1
	GuiControl, guiPostMinCss:, PostMinCssToUcrAss, 1
}

; ············································································································

HandlePostBackupCssCheckAllSites() {
	global
	GuiControl, guiPostBackupCss:, PostBackupCssToAscc, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToCr, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToDsp, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToFye, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToFyf, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToNse, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToPbk, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToSurca, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToSumRes, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToXfer, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToUgr, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToUcore, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToUcrAss, 1
}

; ············································································································

HandlePostCssUncheckAllSites() {
	global
	GuiControl, guiPostMinCss:, PostMinCssToAscc, 0
	GuiControl, guiPostMinCss:, PostMinCssToCr, 0
	GuiControl, guiPostMinCss:, PostMinCssToDsp, 0
	GuiControl, guiPostMinCss:, PostMinCssToFye, 0
	GuiControl, guiPostMinCss:, PostMinCssToFyf, 0
	GuiControl, guiPostMinCss:, PostMinCssToNse, 0
	GuiControl, guiPostMinCss:, PostMinCssToPbk, 0
	GuiControl, guiPostMinCss:, PostMinCssToSurca, 0
	GuiControl, guiPostMinCss:, PostMinCssToSumRes, 0
	GuiControl, guiPostMinCss:, PostMinCssToXfer, 0
	GuiControl, guiPostMinCss:, PostMinCssToUgr, 0
	GuiControl, guiPostMinCss:, PostMinCssToUcore, 0
	GuiControl, guiPostMinCss:, PostMinCssToUcrAss, 0
}

; ············································································································

HandlePostBackupCssUncheckAllSites() {
	global
	GuiControl, guiPostBackupCss:, PostBackupCssToAscc, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToCr, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToDsp, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToFye, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToFyf, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToNse, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToPbk, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToSurca, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToSumRes, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToXfer, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToUgr, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToUcore, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToUcrAss, 0
}

; ············································································································

HandlePostJsCheckAllSites() {
	global
	GuiControl, guiPostMinJs:, PostMinJsToAscc, 1
	GuiControl, guiPostMinJs:, PostMinJsToCr, 1
	GuiControl, guiPostMinJs:, PostMinJsToDsp, 1
	GuiControl, guiPostMinJs:, PostMinJsToFye, 1
	GuiControl, guiPostMinJs:, PostMinJsToFyf, 1
	GuiControl, guiPostMinJs:, PostMinJsToNse, 1
	GuiControl, guiPostMinJs:, PostMinJsToPbk, 1
	GuiControl, guiPostMinJs:, PostMinJsToSurca, 1
	GuiControl, guiPostMinJs:, PostMinJsToSumRes, 1
	GuiControl, guiPostMinJs:, PostMinJsToXfer, 1
	GuiControl, guiPostMinJs:, PostMinJsToUgr, 1
	GuiControl, guiPostMinJs:, PostMinJsToUcore, 1
	GuiControl, guiPostMinJs:, PostMinJsToUcrAss, 1
}

; ············································································································

HandlePostJsUncheckAllSites() {
	global
	GuiControl, guiPostMinJs:, PostMinJsToAscc, 0
	GuiControl, guiPostMinJs:, PostMinJsToCr, 0
	GuiControl, guiPostMinJs:, PostMinJsToDsp, 0
	GuiControl, guiPostMinJs:, PostMinJsToFye, 0
	GuiControl, guiPostMinJs:, PostMinJsToFyf, 0
	GuiControl, guiPostMinJs:, PostMinJsToNse, 0
	GuiControl, guiPostMinJs:, PostMinJsToPbk, 0
	GuiControl, guiPostMinJs:, PostMinJsToSurca, 0
	GuiControl, guiPostMinJs:, PostMinJsToSumRes, 0
	GuiControl, guiPostMinJs:, PostMinJsToXfer, 0
	GuiControl, guiPostMinJs:, PostMinJsToUgr, 0
	GuiControl, guiPostMinJs:, PostMinJsToUcore, 0
	GuiControl, guiPostMinJs:, PostMinJsToUcrAss, 0
}

; ············································································································

HandlePostMinCssCancel() {
	Gui, guiPostMinCss: Destroy
}

; ············································································································

HandlePostMinCssOK() {
	global
	Gui, guiPostMinCss: Submit
	Gui, guiPostMinCss: Destroy
	sgIsPostingMinCss := true
	if (PostMinCssToAscc) {
		PasteMinCssToWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssAscc")
	}
	if (PostMinCssToCr) {
		PasteMinCssToWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssCr")
	}
	if (PostMinCssToDsp) {
		PasteMinCssToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssDsp")
	}
	if (PostMinCssToFye) {
		PasteMinCssToWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssFye")
	}
	if (PostMinCssToFyf) {
		PasteMinCssToWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssFyf")
	}
	if (PostMinCssToNse) {
		PasteMinCssToWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssNse")
	}
	if (PostMinCssToPbk) {
		PasteMinCssToWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssPbk")
	}
	if (PostMinCssToSurca) {
		PasteMinCssToWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssSurca")
	}
	if (PostMinCssToSumRes) {
		PasteMinCssToWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssSumRes")
	}
	if (PostMinCssToXfer) {
		PasteMinCssToWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssXfer")
	}
	if (PostMinCssToUgr) {
		PasteMinCssToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssUgr")
	}
	if (PostMinCssToUcore) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssUcore")
	}
	if (PostMinCssToUcrAss) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssUcrAss")
	}
	sgIsPostingMinCss := false
}

; ············································································································

HandlePostBackupCssCancel() {
	Gui, guiPostBackupCss: Destroy
}

; ············································································································

HandlePostBackupCssOK() {
	global
	Gui, guiPostBackupCss: Submit
	Gui, guiPostBackupCss: Destroy
	sgIsPostingBackupCss := true
	if (PostMinCssToAscc) {
		PasteMinCssToWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssAscc")
	}
	if (PostMinCssToCr) {
		PasteMinCssToWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssCr")
	}
	if (PostBackupCssToDsp) {
		PasteMinCssToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssDsp")
	}
	if (PostBackupCssToFye) {
		PasteMinCssToWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssFye")
	}
	if (PostBackupCssToFyf) {
		PasteMinCssToWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssFyf")
	}
	if (PostBackupCssToFyf) {
		PasteMinCssToWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssNse")
	}
	if (PostBackupCssToPbk) {
		PasteMinCssToWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssPbk")
	}
	if (PostBackupCssToSurca) {
		PasteMinCssToWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssSurca")
	}
	if (PostBackupCssToSumRes) {
		PasteMinCssToWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssSumRes")
	}
	if (PostBackupCssToXfer,) {
		PasteMinCssToWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssXfer")
	}
	if (PostBackupCssToUgr) {
		PasteMinCssToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssUgr")
	}
	if (PostBackupCssToUcore) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssUcore")
	}
	if (PostBackupCssToUcrAss) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=editcss"
			, ":*:@copyBackupCssUcrAss")
	}
	sgIsPostingBackupCss := false
}

; ············································································································

HandlePostMinJsCancel() {
	Gui, Destroy
}

; ············································································································

HandlePostMinJsOK() {
	global
	Gui, Submit
	Gui, Destroy
	sgIsPostingMinJs := true
	if (PostMinJsToAscc) {
		PasteMinJsToWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsAscc")
	}
	if (PostMinJsToCr) {
		PasteMinJsToWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsCr")
	}
	if (PostMinJsToDsp) {
		PasteMinJsToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsDsp")
	}
	if (PostMinJsToFye) {
		PasteMinJsToWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsFye")
	}
	if (PostMinJsToFyf) {
		PasteMinJsToWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsFyf")
	}
	if (PostMinJsToNse) {
		PasteMinJsToWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsNse")
	}
	if (PostMinJsToPbk) {
		PasteMinJsToWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsPbk")
	}
	if (PostMinJsToSurca) {
		PasteMinJsToWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsSurca")
	}
	if (PostMinJsToSumRes) {
		PasteMinJsToWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsSumRes")
	}
	if (PostMinJsToXfer,) {
		PasteMinJsToWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsXfer")
	}
	if (PostMinJsToUgr) {
		PasteMinJsToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsUgr")
	}
	if (PostMinJsToUcore) {
		PasteMinJsToWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsUcore")
	}
	if (PostMinJsToUcrAss) {
		PasteMinJsToWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsUcrAss")
	}
	sgIsPostingMinJs := false
}

; ············································································································

PasteMinCssToWebsite(websiteUrl, cssCopyCmd) {
	LoadWordPressSiteInChrome(websiteUrl)
	Gosub, %cssCopyCmd%
	Sleep, 100
	ExecuteCssPasteCmds()
}

; ············································································································

PasteMinJsToWebsite(websiteUrl, jsCopyCmd) {
	LoadWordPressSiteInChrome(websiteUrl)
	Sleep, 1000
	Gosub, %jsCopyCmd%
	Sleep, 120
	ExecuteJsPasteCmds()
}

; ------------------------------------------------------------------------------------------------------------
; FILE SYSTEM NAVIGATION Hotstrings
; ------------------------------------------------------------------------------------------------------------

; ············································································································
; >>> Navigation within GITHUB DIRECTORIES
; ············································································································

:*:@gotoGhAscc::
	InsertFilePath(":*:@gotoGhAscc", GetGitHubFolder() . "\ascc.wsu.edu", "ascc.wsu.edu") 
Return

; ············································································································

:*:@gotoGhCr::
	InsertFilePath(":*:@gotoGhCr", GetGitHubFolder() . "\commonreading.wsu.edu", "commonreading.wsu.edu") 
Return

; ············································································································

:*:@gotoGhDsp::
	InsertFilePath(":*:@gotoGhDsp", GetGitHubFolder() . "\distinguishedscholarships.wsu.edu"
		, "distinguishedscholarships.wsu.edu") 
Return

; ············································································································

:*:@gotoGhFye::
	InsertFilePath(":*:@gotoGhFye", GetGitHubFolder() . "\firstyear.wsu.edu", "firstyear.wsu.edu")
Return

; ············································································································

:*:@gotoGhFyf::
	InsertFilePath(":*:@gotoGhFyf", GetGitHubFolder() . "\learningcommunities.wsu.edu"
		, "learningcommunities.wsu.edu")
Return

; ············································································································

:*:@gotoGhNse::
	InsertFilePath(":*:@gotoGhNse", GetGitHubFolder() . "\nse.wsu.edu", "nse.wsu.edu")
Return

; ············································································································

:*:@gotoGhOue::
	InsertFilePath(":*:@gotoGhPbk", GetGitHubFolder() . "\oue.wsu.edu", "oue.wsu.edu")
Return

; ············································································································

:*:@gotoGhPbk::
	InsertFilePath(":*:@gotoGhPbk", GetGitHubFolder() . "\phibetakappa.wsu.edu", "phibetakappa.wsu.edu")
Return

; ············································································································

:*:@gotoGhRsp::
	InsertFilePath(":*:@gotoGhRsp", GetGitHubFolder() . "\admissions.wsu.edu-research-scholars"
		, "admissions.wsu.edu/research-scholars")
Return

; ············································································································

:*:@gotoGhSurca::
	InsertFilePath(":*:@gotoGhSurca", GetGitHubFolder() . "\surca.wsu.edu", "surca.wsu.edu")
Return

; ············································································································

:*:@gotoGhSumRes::
	InsertFilePath(":*:@gotoGhSumRes", GetGitHubFolder() . "\summerresearch.wsu.edu"
		, "summerresearch.wsu.edu")
Return

; ············································································································

:*:@gotoGhXfer::
	InsertFilePath(":*:@gotoGhXfer", GetGitHubFolder() . "\transfercredit.wsu.edu", "transfercredit.wsu.edu")
Return

; ············································································································

:*:@gotoGhUgr::
	InsertFilePath(":*:@gotoGhUgr", GetGitHubFolder() . "\undergraduateresearch.wsu.edu"
		, "undergraduateresearch.wsu.edu")
Return

; ············································································································

:*:@gotoGhUcore::
	InsertFilePath(":*:@gotoGhUcore", GetGitHubFolder() . "\ucore.wsu.edu", "ucore.wsu.edu")
Return

; ············································································································

:*:@gotoGhUcrAss::
	InsertFilePath(":*:@gotoGhUcrAss", GetGitHubFolder() . "\ucore.wsu.edu-assessment"
		, "ucore.wsu.edu-assessment")
Return

; ············································································································

:*:@gotoGhCSS::
	InsertFilePath(":*:@gotoGhCSS", GetGitHubFolder() . "\WSU-UE---CSS", "WSU-UE---CSS")
Return

; ············································································································

:*:@gotoGhJS::
	InsertFilePath(":*:@gotoGhJS", GetGitHubFolder() . "\WSU-UE---JS", "WSU-UE---JS")
Return

; ············································································································

:*:@gotoGhAhk::
	InsertFilePath(":*:@gotoGhAhk", GetGitHubFolder() . "\WSU-OUE-AutoHotkey", "WSU-OUE-AutoHotkey")
Return

; ············································································································

:*:cdcss::cd wsu-ue---css

; ············································································································

:*:cdjs::cd wsu-ue---js

; ------------------------------------------------------------------------------------------------------------
; UTILITY HOTSTRINGS for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

; ············································································································
; >>> FILE COMMITTING
; ············································································································

:*:@gitAddThis::
	AppendAhkCmd(":*:@gitAddThis")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		SendInput !e
		Sleep 100
		SendInput {Down 8}
		Sleep 100
		SendInput {Right}
		Sleep 100
		SendInput {Down}
		Sleep 100
		SendInput {Enter}
		Sleep 100
		commitText := RegExReplace(clipboard, "^(.*)", "git add $1")
		clipboard = %commitText%
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR: Clipboard does not contain valid file name"
			, % "Please select the file within NotePad++.exe that you would like to create a 'git add …' "
			. " string for."
	}
Return

; ············································································································

:*:@doGitCommit::
	AppendAhkCmd(":*:@doGitCommit")
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput git commit -m "" -m ""{Left 7}
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doGitCommit" . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

; ············································································································

:*:@dogc::
	Gosub, :*:@doGitCommit
Return

; ············································································································

:*:@doSnglGitCommit::
	AppendAhkCmd(":*:@doSnglGitCommit")
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput git commit -m ""{Left 1}
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doSnglGitCommit" . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

; ············································································································

:*:@dosgc::
	Gosub, :*:@doSnglGitCommit
Return

; ············································································································

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

; ············································································································
; >>> STATUS CHECKING
; ············································································································

:*:@doGitStatus::
	hsName := ":*:@doGitStatus"
	AppendAhkCmd(hsName)
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput % "git status{enter}"
	} else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . hsName . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

; ············································································································

:*:@dogs::
	Gosub, :*:@doGitStatus
Return

; ············································································································
; >>> Automated PASTING OF CSS into online web interfaces
; ············································································································

:*:@initCssPaste::
;	prevTitleMatchMode := A_TitleMatchMode
;	SetTitleMatchMode, RegEx
;	SetTitleMatchMode, prevTitleMatchMode
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
	AppendAhkCmd(":*:@initCssPaste")
	WinGetTitle, thisTitle, A
	posFound := RegExMatch(thisTitle, "i)^CSS[^" . Chr(0x2014) . "]+" . Chr(0x2014)
		. " WordPress - Google Chrome$")
	if(posFound) {
		WinGet, hwndCssPasteWindow, ID, A
		titleCssPasteWindowTab := thisTitle
		MsgBox, % "HWND for window containing CSS stylsheet editor set to " . hwndCssPasteWindow
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (:*:@setCssPasteWindow): CSS Stylesheet Editor Not Active"
			, % "Please select your CSS stylesheet editor tab in Chrome as the currently active window."
	}
Return

; ············································································································

:*:@doCssPaste::		;Paste copied CSS into WordPress window
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
	AppendAhkCmd(":*:@doCssPaste")
	if(isVarDeclared(hwndCssPasteWindow)) {
		; Attempt to switch to chrome
		WinActivate, % "ahk_id " . hwndCssPasteWindow
		WinWaitActive, % "ahk_id " . hwndCssPasteWindow, , 1
		if (ErrorLevel) {
			MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): Could Not Find Process"
				, % "The HWND set for the chrome window containing the tab in which the CSS stylesheet"
				. " editor was loaded can no longer be found."
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
					MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): Couldn't Find Tab"
						, % "Could not locate the tab containing the CSS stylesheet editor."
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
				WinRestore, A
				WinGetPos, thisX, thisY, thisW, thisH, A
				if (thisX != -1830 or thisY != 0 or thisW != 1700 or thisH != 1040) {
					WinMove, A, , -1830, 0, 1700, 1040
				}
				ExecuteCssPasteCmds()
			}
		}
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): HWND Not Set Yet"
			, % "You haven't yet used the @setCssPasteWindow hotstring to set the HWND for the Chrome window"
			. " containing a tab with the CSS stylsheet editor."
	}
Return

; ············································································································

:*:@pasteGitCommitMsg::
	AppendAhkCmd(":*:@pasteGitCommitMsg")
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "PowerShell.exe") {
		commitText := RegExReplace(clipboard, Chr(0x2026) "\R" Chr(0x2026), "")
		clipboard = %commitText%
		Click right 44, 55
	}
Return

; ············································································································

ExecuteCssPasteCmds() {
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch(clipboard, "^/\*!? Built with the LESS CSS")
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
		Sleep, 2000
	} else {
		MsgBox, % (0x0 + 0x10)
			, % "ERROR (:*:@doCssPaste): Clipboard Has Unexpected Contents"
			, % "The clipboard does not begin with the expected '@import ...,' and thus may not contain"
			. " minified CSS."
	}			
}

; ············································································································

ExecuteJsPasteCmds() {
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
		MsgBox, % (0x0 + 0x10)
			, % "ERROR (:*:@doJsPaste): Clipboard Has Unexpected Contents"
			, % "The clipboard does not begin with the expected '// Built with Node.js ...,' and thus may"
			. " not contain minified JS."
	}			
}

; ------------------------------------------------------------------------------------------------------------
; COMMAND LINE INPUT GENERATION as triggered by HotStrings for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

; ············································································································
; >>> FOR BACKING UP CUSTOM CSS BUILDS -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@backupCssAscc::
	hsName := ":*:@backupCssAscc"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\ascc.wsu.edu\CSS\ascc-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\ascc.wsu.edu\""`r"
		. "git add CSS\ascc-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssCr::
	hsName := ":*:@backupCssCr"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\""`r"
		. "git add CSS\cr-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssDsp::
	hsName := ":*:@backupCssDsp"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=editcss"
		, copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder()
		. "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
		. "git add CSS\dsp-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssFye::
	hsName := ":*:@backupCssFye"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
		. "git add CSS\fye-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssFyf::
	hsName := ":*:@backupCssFyf"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder()
		. "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
		. "git add CSS\learningcommunities-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssNse::
	hsName := ":*:@backupCssNse"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\nse.wsu.edu\""`r"
		. "git add CSS\nse-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssOue::
	hsName := ":*:@backupCssOue"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://oue.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\oue.wsu.edu\CSS\oue-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\oue.wsu.edu\""`r"
		. "git add CSS\oue-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssPbk::
	hsName := ":*:@backupCssPbk"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\""`r"
		. "git add CSS\pbk-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssSurca::
	hsName := ":*:@backupCssSurca"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
		. "git add CSS\surca-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssSumRes::
	hsName := ":*:@backupCssSumRes"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder()
		. "\summerresearch.wsu.edu\CSS\summerresearch-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
		. "git add CSS\summerresearch-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssXfer::
	hsName := ":*:@backupCssXfer"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder()
		. "\transfercredit.wsu.edu\CSS\xfercredit-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
		. "git add CSS\xfercredit-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssUgr::
	hsName := ":*:@backupCssUgr"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder()
		. "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
		. "git add CSS\undergraduate-research-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssUcore::
	hsName := ":*:@backupCssUcore"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\""`r"
		. "git add CSS\ucore-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssUcrAss::
	hsName := ":*:@backupCssUcrAss"
	AppendAhkCmd(hsName)
	CopyCssFromWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=editcss", copiedCss)
	WriteCodeToFile(hsName, copiedCss, GetGitHubFolder()
		. "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.prev.css")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\""`r"
		. "git add CSS\ucore-assessment-custom.prev.css`r"
		. "git commit -m ""Updating backup of latest verified custom CSS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupCssAll::
	hsName := ":*:@backupCssAll"
	AppendAhkCmd(hsName)
	Gosub, :*:@backupCssAscc
	Gosub, :*:@backupCssCr
	Gosub, :*:@backupCssDsp
	Gosub, :*:@backupCssFye
	Gosub, :*:@backupCssFyf
	Gosub, :*:@backupCssNse
	Gosub, :*:@backupCssPbk
	Gosub, :*:@backupCssSurca
	Gosub, :*:@backupCssSumRes
	Gosub, :*:@backupCssXfer
	Gosub, :*:@backupCssUgr
	Gosub, :*:@backupCssUcore
	Gosub, :*:@backupCssUcrAss
	PasteTextIntoGitShell(hsName
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,300)`r")
Return

; ············································································································

CopyCssFromWebsite(websiteUrl, ByRef copiedCss)
{
	LoadWordPressSiteInChrome(websiteUrl)
	ExecuteCssCopyCmds(copiedCss)
}

; ············································································································

ExecuteCssCopyCmds(ByRef copiedCss) {
	CoordMode, Mouse, Client
	Click, 768, 570
	Sleep, 100
	SendInput, ^a
	Sleep, 100
	SendInput, ^c
	Sleep, 1000
	SendInput, ^w
	copiedCss := clipboard
	Sleep, 2000
}

; ············································································································
; >>> FOR REBUILDING & COMMITTING CUSTOM CSS FILES  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@rebuildCssHere::
	currentDir := GetCurrentDirFromPS()
	if (GetCmdForMoveToCSSFolder(currentDir) = "awesome!") {
		MsgBox % "Current location: " . currentDir
	}
Return

; ············································································································

:*:@rebuildCssAscc::
	ahkCmdName := ":*:@rebuildCssAscc"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ascc.wsu.edu\CSS""`r"
		. "lessc ascc-custom.less ascc-custom.css`r"
		. "lessc --clean-css ascc-custom.less ascc-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssAscc")
Return

; ············································································································

:*:@commitCssAscc::
	; Variable declarations
	ahkCmdName := ":*:@commitCssAscc"
	fpGitFolder := "ascc.wsu.edu" ; fp = file path
	fnLessSrcFile := "ascc-custom_new.less" ; fn = file name
	fnCssBuild := "ascc-custom.css"
	fnMinCssBuild := "ascc-custom.min.css"
	
	; Register this hotkey with command history interface & process instructions for committomg the CSS build. 
	AppendAhkCmd(ahkCmdName)
	CommitCssBuild(ahkCmdName, fpGitFolder, fnLessSrcFile, fnCssBuild, fnMinCssBuild)
Return

; ············································································································

:*:@rebuildCssCr::
	ahkCmdName := ":*:@rebuildCssCr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\CSS""`r"
		. "lessc cr-custom.less cr-custom.css`r"
		. "lessc --clean-css cr-custom.less cr-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssCr")
Return

; ············································································································

:*:@commitCssCr::
	; Variable declarations
	ahkCmdName := ":*:@commitCssCr"
	fpGitFolder := "commonreading.wsu.edu" ; fp = file path
	fnLessSrcFile := "src_cr-new.less" ; fn = file name
	fnCssBuild := "cr-custom.css"
	fnMinCssBuild := "cr-custom.min.css"
	
	; Register this hotkey with command history interface & process instructions for committomg the CSS build. 
	AppendAhkCmd(ahkCmdName)
	CommitCssBuild(ahkCmdName, fpGitFolder, fnLessSrcFile, fnCssBuild, fnMinCssBuild)
Return

; ············································································································

:*:@rebuildCssDsp::
	ahkCmdName := ":*:@rebuildCssDsp"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssDsp")
Return

; ············································································································

:*:@commitCssDsp::
	ahkCmdName := ":*:@commitCssDsp"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
		. "git add CSS\dsp-custom.css`r"
		. "git add CSS\dsp-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssFye::
	ahkCmdName := ":*:@rebuildCssFye"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\CSS""`r"
		. "lessc fye-custom.less fye-custom.css`r"
		. "lessc --clean-css fye-custom.less fye-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssFye")	
Return

; ············································································································

:*:@commitCssFye::
	ahkCmdName := ":*:@commitCssFye"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
		. "git add CSS\fye-custom.css`r"
		. "git add CSS\fye-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssFyf::
	ahkCmdName := ":*:@rebuildCssFyf"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS""`r"
		. "lessc learningcommunities-custom.less learningcommunities-custom.css`r"
		. "lessc --clean-css learningcommunities-custom.less learningcommunities-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssFyf")
Return

; ············································································································

:*:@commitCssFyf::
	ahkCmdName := ":*:@commitCssFyf"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
		. "git add CSS\learningcommunities-custom.css`r"
		. "git add CSS\learningcommunities-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssNse::
	ahkCmdName := ":*:@rebuildCssNse"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\nse.wsu.edu\CSS""`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssNse")
Return

; ············································································································

:*:@commitCssNse::
	; Variable declarations
	ahkCmdName := ":*:@commitCssNse"
	fpGitFolder := "nse.wsu.edu" ; fp = file path
	fnLessSrcFile := "nse-custom.less" ; fn = file name
	fnCssBuild := "nse-custom.css"
	fnMinCssBuild := "nse-custom.min.css"
	
	; Register this hotkey with command history interface & process instructions for committomg the CSS build. 
	AppendAhkCmd(ahkCmdName)
	CommitCssBuild(ahkCmdName, fpGitFolder, fnLessSrcFile, fnCssBuild, fnMinCssBuild)
Return

; ············································································································

:*:@rebuildCssOue::
	ahkCmdName := ":*:@rebuildCssOue"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\oue.wsu.edu\""`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssOue")
Return

; ············································································································

:*:@commitCssOue::
	ahkCmdName := ":*:@commitCssOue"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\oue.wsu.edu\""`r"
		. "git add CSS\oue-custom.css`r"
		. "git add CSS\oue-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssPbk::
	ahkCmdName := ":*:@rebuildCssPbk"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\""`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssPbk")
Return

; ············································································································

:*:@commitCssPbk::
	ahkCmdName := ":*:@commitCssPbk"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\""`r"
		. "git add CSS\pbk-custom.css`r"
		. "git add CSS\pbk-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssSurca::
	ahkCmdName := ":*:@rebuildCssSurca"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\surca.wsu.edu\CSS""`r"
		. "lessc surca-custom.less surca-custom.css`r"
		. "lessc --clean-css surca-custom.less surca-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssSurca")
Return

; ············································································································

:*:@commitCssSurca::
	ahkCmdName := ":*:@commitCssSurca"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
		. "git add CSS\surca-custom.css`r"
		. "git add CSS\surca-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssSumRes::
	ahkCmdName := ":*:@rebuildCssSumRes"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\CSS""`r"
		. "lessc summerresearch-custom.less summerresearch-custom.css`r"
		. "lessc --clean-css summerresearch-custom.less summerresearch-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssSumRes")
Return

; ············································································································

:*:@commitCssSumRes::
	ahkCmdName := ":*:@commitCssSumRes"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
		. "git add CSS\summerresearch-custom.css`r"
		. "git add CSS\summerresearch-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssXfer::
	ahkCmdName := ":*:@rebuildCssXfer"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\CSS""`r"
		. "lessc xfercredit-custom.less xfercredit-custom.css`r"
		. "lessc --clean-css xfercredit-custom.less xfercredit-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssXfer")
Return

; ············································································································

:*:@commitCssXfer::
	ahkCmdName := ":*:@commitCssXfer"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
		. "git add CSS\xfercredit-custom.css`r"
		. "git add CSS\xfercredit-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssUgr::
	ahkCmdName := ":*:@rebuildCssUgr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS""`r"
		. "lessc undergraduate-research-custom.less undergraduate-research-custom.css`r"
		. "lessc --clean-css undergraduate-research-custom.less undergraduate-research-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssUgr")
Return

; ············································································································

:*:@commitCssUgr::
	; Variable declarations
	ahkCmdName := ":*:@commitCssUgr"
	fpGitFolder := "undergraduateresearch.wsu.edu" ; fp = file path
	fnLessSrcFile := "undergraduate-research-custom.less" ; fn = file name
	fnCssBuild := "undergraduate-research-custom.css"
	fnMinCssBuild := "undergraduate-research-custom.min.css"
	
	; Register this hotkey with command history interface & process instructions for committomg the CSS build. 
	AppendAhkCmd(ahkCmdName)
	CommitCssBuild(ahkCmdName, fpGitFolder, fnLessSrcFile, fnCssBuild, fnMinCssBuild)
Return

; ············································································································

:*:@rebuildCssUcore::
	ahkCmdName := ":*:@rebuildCssUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\CSS""`r"
		. "lessc ucore-custom.less ucore-custom.css`r"
		. "lessc --clean-css ucore-custom.less ucore-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssUcore")
Return

; ············································································································

:*:@commitCssUcore::
	ahkCmdName := ":*:@commitCssUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\""`r"
		. "git add CSS\ucore-custom.css`r"
		. "git add CSS\ucore-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssUcrAss::
	ahkCmdName := ":*:@rebuildCssUcrAss"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS""`r"
		. "lessc ucore-assessment-custom.less ucore-assessment-custom.css`r"
		. "lessc --clean-css ucore-assessment-custom.less ucore-assessment-custom.min.css`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitCssUcrAss")
Return

; ············································································································

:*:@commitCssUcrAss::
	ahkCmdName := ":*:@commitCssUcrAss"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\""`r"
		. "git add CSS\ucore-assessment-custom.css`r"
		. "git add CSS\ucore-assessment-custom.min.css`r"
		. "git commit -m ""Updating custom CSS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies."" `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

; ············································································································

:*:@rebuildCssAll::
	ahkCmdName := ":*:@rebuildCssAll"
	AppendAhkCmd(ahkCmdName)
	Gosub, :*:@rebuildCssCr
	Gosub, :*:@rebuildCssDsp
	Gosub, :*:@rebuildCssFye
	Gosub, :*:@rebuildCssFyf
	Gosub, :*:@rebuildCssNse
	Gosub, :*:@rebuildCssOue
	Gosub, :*:@rebuildCssPbk
	Gosub, :*:@rebuildCssSurca
	Gosub, :*:@rebuildCssSumRes
	Gosub, :*:@rebuildCssXfer
	Gosub, :*:@rebuildCssUgr
	Gosub, :*:@rebuildCssUcore
	Gosub, :*:@rebuildCssUcrAss
	PasteTextIntoGitShell(ahkCmdName
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r")
Return

; ············································································································
; >>> FOR UPDATING CSS SUBMODULES -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleAscc::
	ahkCmdName := ":*:@updateCssSubmoduleAscc"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ascc.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssAscc
Return

; ············································································································

:*:@updateCssSubmoduleCr::
	ahkCmdName := ":*:@updateCssSubmoduleCr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssCr
Return

; ············································································································

:*:@updateCssSubmoduleDsp::
	ahkCmdName := ":*:@updateCssSubmoduleDsp"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating"
		. " recent changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssDsp
Return

; ············································································································

:*:@updateCssSubmoduleFye::
	ahkCmdName := ":*:@updateCssSubmoduleFye"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssFye
Return

; ············································································································

:*:@updateCssSubmoduleFyf::
	ahkCmdName := ":*:@updateCssSubmoduleFyf"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssFyf
Return

; ············································································································

:*:@updateCssSubmoduleNse::
	ahkCmdName := ":*:@updateCssSubmoduleNse"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\nse.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssNse
Return

; ············································································································

:*:@updateCssSubmoduleOue::
	ahkCmdName := ":*:@updateCssSubmoduleOue"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\oue.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssOue
Return

; ············································································································

:*:@updateCssSubmodulePbk::
	ahkCmdName := ":*:@updateCssSubmodulePbk"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssPbk
Return

; ············································································································

:*:@updateCssSubmoduleSurca::
	ahkCmdName := ":*:@updateCssSubmoduleSurca"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssSurca
Return

; ············································································································

:*:@updateCssSubmoduleSumRes::
	ahkCmdName := ":*:@updateCssSubmoduleSumRes"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssSumRes
Return

; ············································································································

:*:@updateCssSubmoduleXfer::
	ahkCmdName := ":*:@updateCssSubmoduleXfer"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssXfer
Return

; ············································································································

:*:@updateCssSubmoduleUgr::
	ahkCmdName := ":*:@updateCssSubmoduleUgr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssUgr
Return

; ············································································································

:*:@updateCssSubmoduleUcore::
	ahkCmdName := ":*:@updateCssSubmoduleUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssUcore
Return

; ············································································································

:*:@updateCssSubmoduleUcrAss::
	ahkCmdName := ":*:@updateCssSubmoduleUcrAss"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\WSU-UE---CSS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m ""Updating custom CSS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildCssUcrAss
Return

; ············································································································

:*:@updateCssSubmoduleAll::
	ahkCmdName := ":*:@updateCssSubmoduleAll"
	AppendAhkCmd(ahkCmdName)
	Gosub, :*:@updateCssSubmoduleAscc
	Gosub, :*:@updateCssSubmoduleCr
	Gosub, :*:@updateCssSubmoduleDsp
	Gosub, :*:@updateCssSubmoduleFye
	Gosub, :*:@updateCssSubmoduleFyf
	Gosub, :*:@updateCssSubmoduleNse
	Gosub, :*:@updateCssSubmoduleOue
	Gosub, :*:@updateCssSubmodulePbk
	Gosub, :*:@updateCssSubmoduleSurca
	Gosub, :*:@updateCssSubmoduleSumRes
	Gosub, :*:@updateCssSubmoduleXfer
	Gosub, :*:@updateCssSubmoduleUgr
	Gosub, :*:@updateCssSubmoduleUcore
	Gosub, :*:@updateCssSubmoduleUcrAss
	PasteTextIntoGitShell(ahkCmdName
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r")
Return

; ············································································································
; >>> FOR COPYING MINIFIED, BACKUP CSS FILES TO CLIPBOARD --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssAscc::
	ahkCmdName := ":*:@copyMinCssAscc"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ascc.wsu.edu\CSS\ascc-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/ascc.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for ASCC website.")
Return

; ············································································································

:*:@copyBackupCssAscc::
	ahkCmdName := ":*:@copyBackupCssAscc"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ascc.wsu.edu\CSS\ascc-custom.min.prev.css"
		, ""
		, "Couldn't copy backup CSS for ASCC Reading website.")
Return

; ············································································································

:*:@copyMinCssCr::
	ahkCmdName := ":*:@copyMinCssCr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/commonreading.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for Common Reading website.")
Return

; ············································································································

:*:@copyBackupCssCr::
	ahkCmdName := ":*:@copyBackupCssCr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.prev.css"
		, ""
		, "Couldn't copy backup CSS for Common Reading website.")
Return

; ············································································································

:*:@copyMinCssDsp::
	ahkCmdName := ":*:@copyMinCssDsp"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.min.css"
		, ""
		, "Couldn't copy minified CSS for DSP Website.")
Return

; ············································································································

:*:@copyBackupCssDsp::
	ahkCmdName := ":*:@copyBackupCssDsp"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for DSP Website.")
Return

; ············································································································

:*:@copyMinCssFye::
	ahkCmdName := ":*:@copyMinCssFye"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/firstyear.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for FYE website.")
Return

; ············································································································

:*:@copyBackupCssFye::
	ahkCmdName := ":*:@copyBackupCssFye"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for FYE website.")
Return

; ············································································································

:*:@copyMinCssFyf::
	ahkCmdName := ":*:@copyMinCssFyf"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/learningcommunities.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for First-Year Focus website.")
Return

; ············································································································

:*:@copyBackupCssFyf::
	ahkCmdName := ":*:@copyBackupCssFyf"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for First-Year Focus website.")
Return

; ············································································································

:*:@copyMinCssNse::
	ahkCmdName := ":*:@copyMinCssNse"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.min.css"
		, ""
		, "Couldn't copy minified CSS for NSE website.")
Return

; ············································································································

:*:@copyBackupCssNse::
	ahkCmdName := ":*:@copyBackupCssNse"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for NSE website.")
Return

; ············································································································

:*:@copyMinCssOue::
	ahkCmdName := ":*:@copyMinCssOue"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\oue.wsu.edu\CSS\oue-custom.min.css"
		, ""
		, "Couldn't copy minified CSS for OUE website.")
Return

; ············································································································

:*:@copyMinCssPbk::
	ahkCmdName := ":*:@copyMinCssPbk"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.min.css"
		, ""
		, "Couldn't copy minified CSS for Phi Beta Kappa website.")
Return

; ············································································································

:*:@copyBackupCssPbk::
	ahkCmdName := ":*:@copyBackupCssPbk"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for Phi Beta Kappa website.")
Return

; ············································································································

:*:@copyMinCssSurca::
	ahkCmdName := ":*:@copyMinCssSurca"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/surca.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for SURCA website.")
Return

; ············································································································

:*:@copyBackupCssSurca::
	ahkCmdName := ":*:@copyBackupCssSurca"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for SURCA website.")
Return

; ············································································································

:*:@copyMinCssSumRes::
	ahkCmdName := ":*:@copyMinCssSumRes"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/summerresearch.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for Summer Research website.")
Return

; ············································································································

:*:@copyBackupCssSumRes::
	ahkCmdName := ":*:@copyBackupCssSumRes"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for Summer Research website.")
Return

; ············································································································

:*:@copyMinCssXfer::
	ahkCmdName := ":*:@copyMinCssXfer"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/transfercredit.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for Transfer Credit website.")
Return

; ············································································································

:*:@copyBackupCssXfer::
	ahkCmdName := ":*:@copyBackupCssXfer"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for Transfer Credit website.")
Return

; ············································································································

:*:@copyMinCssUgr::
	ahkCmdName := ":*:@copyMinCssUgr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/undergraduateresearch.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for UGR website.")
Return

; ············································································································

:*:@copyBackupCssUgr::
	ahkCmdName := ":*:@copyBackupCssUgr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for UGR website.")
Return

; ············································································································

:*:@copyMinCssUcore::
	ahkCmdName := ":*:@copyMinCssUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
		. "keImmediately/ucore.wsu.edu] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for UCORE website.")
Return

; ············································································································

:*:@copyBackupCssUcore::
	ahkCmdName := ":*:@copyBackupCssUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.prev.css"
		, ""
		, "Couldn't copy backup CSS for UCORE website.")
Return

; ············································································································

:*:@copyMinCssUcrAss::
	ahkCmdName := ":*:@copyMinCssUcrAss"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/inv"
		. "okeImmediately/ucore.wsu.edu-assessment] for a repository of source code. */`r`n`r`n"
		, "Couldn't copy minified CSS for UCORE Assessment website.")
Return

; ············································································································

:*:@copyBackupCssUcrAss::
	ahkCmdName := ":*:@copyBackupCssUcrAss"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
		, ""
		, "Couldn't copy backup CSS for UCORE Assessment website.")
Return

; ············································································································
; >>> FOR BACKING UP CUSTOM JS BUILDS --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@backupJsAscc::
	hsName := ":*:@backupJsAscc"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\ascc.wsu.edu\JS\ascc-custom.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\ascc.wsu.edu\""`r"
		. "git add JS\ascc-custom.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsCr::
	hsName := ":*:@backupJsCr"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\commonreading.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsDsp::
	hsName := ":*:@backupJsDsp"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\distinguishedscholarships.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsFye::
	hsName := ":*:@backupJsFye"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\firstyear.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsFyf::
	hsName := hsName
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\learningcommunities.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsNse::
	hsName := hsName
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder() . "\nse.wsu.edu\JS\nse-custom.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\nse.wsu.edu\""`r"
		. "git add JS\nse-custom.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsOue::
	hsName := ":*:@backupJsOue"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://oue.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder() . "\oue.wsu.edu\JS\oue-custom.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\oue.wsu.edu\""`r"
		. "git add JS\oue-custom.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsPbk::
	hsName := ":*:@backupJsPbk"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\pbk-custom.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\""`r"
		. "git add JS\pbk-custom.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsSurca::
	hsName := ":*:@backupJsSurca"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder() . "\surca.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsSumRes::
	hsName := ":*:@backupJsSumRes"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\summerresearch.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	GoSub, :*:@commitBackupJsSumRes
Return

; ············································································································

:*:@commitBackupJsSumRes::
	hsName := ":*:@commitBackupJsSumRes"
	AppendAhkCmd(hsName)
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsXfer::
	hsName := ":*:@backupJsXfer"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsUgr::
	hsName := ":*:@backupJsUgr"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\undergraduateresearch.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsUcore::
	hsName := ":*:@backupJsUcore"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsUcrAss::
	hsName := ":*:@backupJsUcrAss"
	AppendAhkCmd(hsName)
	CopyJsFromWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(hsName, copiedJs, GetGitHubFolder()
		. "\ucore.wsu.edu-assessment\JS\wp-custom-js-source.min.js")
	PasteTextIntoGitShell(hsName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\""`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating backup of latest verified custom JS build""`r"
		. "git push`r")
Return

; ············································································································

:*:@backupJsAll::
	hsName := ":*:@backupJsAll"
	AppendAhkCmd(hsName)
	Gosub, :*:@backupJsAscc
	Gosub, :*:@backupJsCr
	Gosub, :*:@backupJsDsp
	Gosub, :*:@backupJsFye
	Gosub, :*:@backupJsFyf
	Gosub, :*:@backupJsNse
	Gosub, :*:@backupJsOue
	Gosub, :*:@backupJsPbk
	Gosub, :*:@backupJsSurca
	Gosub, :*:@backupJsSumRes
	Gosub, :*:@backupJsXfer
	Gosub, :*:@backupJsUgr
	Gosub, :*:@backupJsUcore
	Gosub, :*:@backupJsUcrAss
	PasteTextIntoGitShell(hsName
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r")
Return

; ············································································································

CopyJsFromWebsite(websiteUrl, ByRef copiedJs)
{
	LoadWordPressSiteInChrome(websiteUrl)
	ExecuteJsCopyCmds(copiedJs)
}

; ············································································································

ExecuteJsCopyCmds(ByRef copiedJs) {
	CoordMode, Mouse, Client
	Click, 461, 371
	Sleep, 330
	SendInput, ^a
	Sleep, 2500
	SendInput, ^c
	Sleep, 2500
	SendInput, ^w
	copiedJs := clipboard
	Sleep, 2000
}

; ············································································································
; >>> FOR REBUILDING JS SOURCE FILES ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@rebuildJsAscc::
	ahkCmdName := ":*:@rebuildJsAscc"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ascc.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs ascc-custom.js --output ascc-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\ascc.wsu.edu\""`r"
		. "git add JS\ascc-custom.js`r"
		. "git add JS\ascc-custom.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsCr::
	ahkCmdName := ":*:@rebuildJsCr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsDsp::
	ahkCmdName := ":*:@rebuildJsDsp"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-javascript-source.dsp.js --output wp-custom-js-source.min.dsp.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
		. "git add JS\wp-custom-javascript-source.dsp.js`r"
		. "git add JS\wp-custom-js-source.min.dsp.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsFye::
	ahkCmdName := ":*:@rebuildJsFye"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsFyf::
	ahkCmdName := ":*:@rebuildJsFyf"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsNse::
	ahkCmdName := ":*:@rebuildJsNse"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\nse.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs nse-custom.js --output nse-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\nse.wsu.edu\""`r"
		. "git add JS\nse-custom.js`r"
		. "git add JS\nse-custom.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsOue::
	ahkCmdName := ":*:@rebuildJsOue"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\oue.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs oue-custom.js --output oue-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\oue.wsu.edu\""`r"
		. "git add JS\oue-custom.js`r"
		. "git add JS\oue-custom.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsPbk::
	ahkCmdName := ":*:@rebuildJsPbk"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs pbk-custom.js --output pbk-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\""`r"
		. "git add JS\pbk-custom.js`r"
		. "git add JS\pbk-custom.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsSurca::
	ahkCmdName := ":*:@rebuildJsSurca"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\surca.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsSumRes::
	ahkCmdName := ":*:@rebuildJsSumRes"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsXfer::
	ahkCmdName := ":*:@rebuildJsXfer"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsUgr::
	ahkCmdName := ":*:@rebuildJsUgr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsUcore::
	ahkCmdName := ":*:@rebuildJsUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································

:*:@rebuildJsUcrAss::
	ahkCmdName := ":*:@rebuildJsUcrAss"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS""`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\""`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m ""Updating custom JS build"" -m ""Rebuilt production files to incorporate recent"
		. " changes to source code and/or dependencies"" `r"
		. "git push`r")
Return

; ············································································································
; >>> FOR UPDATING JS SUBMODULES --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateJsSubmoduleAscc::
	ahkCmdName := ":*:@updateJsSubmoduleAscc"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ascc.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsAscc
Return

; ············································································································

:*:@updateJsSubmoduleCr::
	ahkCmdName := ":*:@updateJsSubmoduleCr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\commonreading.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsCr
Return

; ············································································································

:*:@updateJsSubmoduleDsp::
	ahkCmdName := ":*:@updateJsSubmoduleDsp"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsDsp
Return

; ············································································································

:*:@updateJsSubmoduleFye::
	ahkCmdName := ":*:@updateJsSubmoduleFye"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsFye
Return

; ············································································································

:*:@updateJsSubmoduleFyf::
	ahkCmdName := ":*:@updateJsSubmoduleFyf"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsFyf
Return

; ············································································································

:*:@updateJsSubmoduleNse::
	ahkCmdName := ":*:@updateJsSubmoduleNse"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\nse.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsFyf
Return

; ············································································································

:*:@updateJsSubmoduleOue::
	ahkCmdName := ":*:@updateJsSubmoduleOue"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\oue.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsOue
Return

; ············································································································

:*:@updateJsSubmodulePbk::
	ahkCmdName := ":*:@updateJsSubmodulePbk"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\phibetakappa.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsPbk
Return

; ············································································································

:*:@updateJsSubmoduleSurca::
	ahkCmdName := ":*:@updateJsSubmoduleSurca"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsSurca
Return

; ············································································································

:*:@updateJsSubmoduleSumRes::
	ahkCmdName := ":*:@updateJsSubmoduleSumRes"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsSumRes
Return

; ············································································································

:*:@updateJsSubmoduleXfer::
	ahkCmdName := ":*:@updateJsSubmoduleXfer"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsXfer
Return

; ············································································································

:*:@updateJsSubmoduleUgr::
	ahkCmdName := ":*:@updateJsSubmoduleUgr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsUgr
Return

; ············································································································

:*:@updateJsSubmoduleUcore::
	ahkCmdName := ":*:@updateJsSubmoduleUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsUcore
Return

; ············································································································

:*:@updateJsSubmoduleUcrAss::
	ahkCmdName := ":*:@updateJsSubmoduleUcrAss"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . GetGitHubFolder() . "\ucore.wsu.edu-assessment\WSU-UE---JS""`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m ""Updating custom JS master submodule for OUE websites"" -m ""Incorporating recent"
		. " changes in project source code""`r"
		. "git push`r")
	Gosub, :*:@rebuildJsUcrAss
Return

; ············································································································

:*:@updateJsSubmoduleAll::
	ahkCmdName := ":*:@updateJsSubmoduleAll"
	AppendAhkCmd(ahkCmdName)
	Gosub, :*:@updateJsSubmoduleAscc
	Gosub, :*:@updateJsSubmoduleCr
	Gosub, :*:@updateJsSubmoduleDsp
	Gosub, :*:@updateJsSubmoduleFye
	Gosub, :*:@updateJsSubmoduleFyf
	Gosub, :*:@updateJsSubmoduleNse
	Gosub, :*:@updateJsSubmoduleOue
	Gosub, :*:@updateJsSubmodulePbk
	Gosub, :*:@updateJsSubmoduleSurca
	Gosub, :*:@updateJsSubmoduleSumRes
	Gosub, :*:@updateJsSubmoduleXfer
	Gosub, :*:@updateJsSubmoduleUgr
	Gosub, :*:@updateJsSubmoduleUcore
	Gosub, :*:@updateJsSubmoduleUcrAss
	PasteTextIntoGitShell(ahkCmdName
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r")
Return

; ············································································································
; >>> FOR COPYING MINIFIED CSS TO CLIPBOARD -  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

;TODO: Add scripts for copying JS backups to clipboard (see CSS backup-copying scripts above)
:*:@copyMinJsAscc::
	ahkCmdName := ":*:@copyMinJsAscc"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ascc.wsu.edu\JS\ascc-custom.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/commonreading.wsu.edu] for "
		. "a repository of source code.`r`n"
		, "Couldn't Copy Minified JS for ASCC Website")
Return

; ············································································································

:*:@copyMinJsCr::
	ahkCmdName := ":*:@copyMinJsCr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\commonreading.wsu.edu\JS\wp-custom-js-source.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/commonreading.wsu.edu] for "
		. "a repository of source code.`r`n"
		, "Couldn't Copy Minified JS for CR Website")
Return

; ············································································································

:*:@copyMinJsDsp::
	ahkCmdName := ":*:@copyMinJsDsp"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
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
		, "Couldn't Copy Minified JS for DSP Website")
Return

; ············································································································

:*:@copyMinJsFye::
	ahkCmdName := ":*:@copyMinJsFye"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\firstyear.wsu.edu\JS\wp-custom-js-source.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/firstyear.wsu.edu] for a repository of"
		. "source code.`r`n"
		. "// Third-party, open-source JavaScript plugins used by this website:`r`n"
		. "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
		. "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
		. "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
		. "ativecommons.org/licenses/by/3.0/`r`n"
		, "Couldn't Copy Minified JS for FYE Website")
Return

; ············································································································

:*:@copyMinJsFyf::
	ahkCmdName := ":*:@copyMinJsFyf"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
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
		, "Couldn't Copy Minified JS for FYF Website")
Return

; ············································································································

:*:@copyMinJsNse::
	ahkCmdName := ":*:@copyMinJsNse"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\nse.wsu.edu\JS\nse-custom.min.js"
		, "/*! Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo"
		. "/UglifyJS]. Please see [https://github.com/invokeImmediately/nse.wsu.edu] for a rep"
		. "ository of source code.`r`n`r`n"
		, "Couldn't Copy Minified JS for Nse Website")
Return

; ············································································································

:*:@copyMinJsOue::
	ahkCmdName := ":*:@copyMinJsOue"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\oue-custom.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/oue.wsu.edu] for a repository of sourc"
		. "e code.`r`n"
		, "Couldn't Copy Minified JS for WSU OUE Website")
Return

; ············································································································

:*:@copyBackupJsOue::
	ahkCmdName := ":*:@copyBackupJsOue"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\oue.wsu.edu\JS\oue-custom.min.prev.js"
		, ""
		, "Couldn't copy backup copy of minified JS for WSU OUE website")
Return

; ············································································································

:*:@copyMinJsPbk::
	ahkCmdName := ":*:@copyMinJsPbk"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
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
		, "Couldn't Copy Minified JS for WSU Phi Beta Kappa Website")
Return

; ············································································································

:*:@copyMinJsSurca::
	ahkCmdName := ":*:@copyMinJsSurca"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
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
		, "Couldn't Copy Minified JS for SURCA Website")
Return

; ············································································································

:*:@copyMinJsSumRes::
	ahkCmdName := ":*:@copyMinJsSumRes"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
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
		, "Couldn't Copy Minified JS for WSU Summer Research Website")
Return

; ············································································································

:*:@copyMinJsXfer::
	ahkCmdName := ":*:@copyMinJsXfer"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/transfercredit.wsu.edu] for a reposito"
		. "ry of source code.`r`n"
		. "// Third-party, open-source JavaScript plugins used by this website:`r`n"
		. "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
		. "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
		. "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
		. "ativecommons.org/licenses/by/3.0/`r`n"
		, "Couldn't Copy Minified JS for WSU Transfer Credit Website")
Return

; ············································································································

:*:@copyMinJsUgr::
	ahkCmdName := ":*:@copyMinJsUgr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS\wp-custom-js-source.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/undergraduateresearch.wsu.edu] for a r"
		. "epository of source code.`r`n"
		. "// Third-party, open-source JavaScript plugins used by this website:`r`n"
		. "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
		. "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
		. "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
		. "ativecommons.org/licenses/by/3.0/`r`n"
		, "Couldn't Copy Minified JS for UGR Website")
Return

; ············································································································

:*:@copyMinJsUcore::
	ahkCmdName := ":*:@copyMinJsUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
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
		, "Couldn't copy minified JS for UCORE website")
Return

; ············································································································

:*:@copyBackupJsUcore::
	ahkCmdName := ":*:@copyBackupJsUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.min.prev.js"
		, ""
		, "Couldn't copy backup copy of minified JS for UCORE website")
Return

; ············································································································

:*:@copyMinJsUcrAss::
	ahkCmdName := ":*:@copyMinJsUcrAss"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS\wp-custom-js-source.min.js"
		, "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
		. "UglifyJS]. Please see [https://github.com/invokeImmediately/ucore.wsu.edu-assessment] for a reposi"
		. "tory of source code.`r`n"
		. "// Third-party, open-source JavaScript plugins used by this website:`r`n"
		. "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
		. "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
		. "sandro.mit-license.org/`r`n"
		. "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
		. "ativecommons.org/licenses/by/3.0/`r`n"
		, "Couldn't Copy Minified JS for WSU Summer Research Website")
Return

; ············································································································
; >>> FOR CHECKING GIT STATUS ON ALL PROJECTS  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@checkGitStatus::
	ahkCmdName := ":*:@checkGitStatus"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n----------------------------------------------WSU-OUE-AutoHotkey------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-OUE-AutoHotkey\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n------------------------------------------------WSU-OUE---CSS---------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---CSS\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------------WSU-OUE---JS---------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---JS\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------------ascc.wsu.edu---------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ascc.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------------commonreading.wsu.edu-----------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\commonreading.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------distinguishedscholarships.wsu.edu-----------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\distinguishedscholarships.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n----------------------------------------------firstyear.wsu.edu-------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\firstyear.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-----------------------------------------learningcommunities.wsu.edu--------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\learningcommunities.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------------oue.wsu.edu----------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\oue.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n------------------------------------------------surca.wsu.edu---------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\surca.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n----------------------------------------undergraduateresearch.wsu.edu-------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\undergraduateresearch.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------------transfercredit.wsu.edu----------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\transfercredit.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------------summerresearch.wsu.edu----------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\summerresearch.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n------------------------------------------------ucore.wsu.edu---------------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ucore.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------ucore.wsu.edu/assessment---------------"
		. "----------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ucore.wsu.edu-assessment\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n")
Return

; ------------------------------------------------------------------------------------------------------------
; KEYBOARD SHORTCUTS FOR POWERSHELL
; ------------------------------------------------------------------------------------------------------------

; ············································································································
; >>> SHORTCUTS  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^+v::	
	if (IsGitShellActive()) {
		PasteTextIntoGitShell("", clipboard)
	} else {
		Gosub, PerformBypassingCtrlShftV
	}
Return

; ············································································································

~^+Backspace::
	if (IsGitShellActive()) {
		SendInput {Backspace 120}
	}
Return

; ············································································································

~^+Delete::
	if (IsGitShellActive()) {
		SendInput {Delete 120}
	}
Return

; ············································································································
; >>> SUPPORTING FUNCTIONS ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

PerformBypassingCtrlShftV:
	Suspend
	Sleep 10
	SendInput ^+v
	Sleep 10
	Suspend, Off
Return
