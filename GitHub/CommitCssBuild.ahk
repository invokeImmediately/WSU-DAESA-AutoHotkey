; ==================================================================================================
; GUI FOR COMMITTING CSS BUILDS & ASSOCIATED SITE-SPECIFIC CUSTOM LESS FILES
; ==================================================================================================
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents
; -----------------
;   §1: GUI CREATION FUNCTION: CommitCssBuild...................................................34
;   §2: GUI EVENT HANDLERS.....................................................................156
;     >>> §2.1: HandleCommitCss1stMsgChange....................................................160
;     >>> §2.2: HandleCommitCss2ndMsgChange....................................................177
;     >>> §2.3: HandleCommitCssAddFiles........................................................194
;     >>> §2.4: HandleCommitCssRemoveFiles.....................................................236
;     >>> §2.5: HandleCommitCssGitDiff.........................................................248
;     >>> §2.6: HandleCommitCssGitLog..........................................................358
;     >>> §2.7: HandleCommitCssCheckLessFileCommit.............................................322
;     >>> §2.8: HandleCommitCssCheckLessChangesOnly............................................385
;     >>> §2.9: HandleCommitCss1stLessMsgChange................................................428
;     >>> §2.10: HandleCommitCss2ndLessMsgChange...............................................425
;     >>> §2.11: HandleCommitCssOk.............................................................462
;       →→→ §2.11.1: ProcessHandleCommitCssOkError.............................................542
;     >>> §2.12: HandleCommitCssCancel.........................................................570
;   §3: GUI PERSISTENCE FUNCTIONS..............................................................578
;     >>> §3.1: SaveCommitCssLessMsgHistory....................................................582
;     >>> §3.2: LoadCommitCssLessMsgHistory....................................................619
;     >>> §3.3: ReadKeyForLessMsgHistory.......................................................656
;     >>> §3.4: ReadPrimaryMsgForLessFileKey...................................................674
;     >>> §3.5: ReadSecondaryMsgForLessFileKey.................................................691
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GUI CREATION FUNCTION: CommitCssBuild
; --------------------------------------------------------------------------------------------------

; Sets up a GUI to automate committing of CSS build files.
CommitCssBuild(ahkCmdName, fpGitFolder, fnLessSrcFile, fnCssbuild, fnMinCssBuild) {
	; Global variable declarations
	global commitCssVars := Object()
	global commitCssLastLessCommit
	global ctrlCommitCssAlsoCommitLessSrc
	global ctrlCommitCssLessChangesOnly
	global ctrlCommitCssLV
	global ctrlCommitCssAddFiles
	global ctrlCommitCssRemoveFiles
	global ctrlCommitCssGitDiff
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
	commitCssVars.dflt1stCommitMsgAlt2 := "Updating custom CSS build w/ site-specific source change"
. "s"
	commitCssVars.dflt2ndCommitMsg := "Rebuilding custom CSS production files to incorporate recent"
. " changes to submodules containing OUE-wide build dependencies."
	commitCssVars.dflt2ndCommitMsgAlt := "Rebuilding custom CSS production files to incorporate rec"
. "ent changes to site-specific source files and submodules containing OUE-wide build dependencies."
. " Please see the next commit for more details."
	commitCssVars.dflt2ndCommitMsgAlt2 := "Rebuilding custom CSS production files to incorporate re"
. "cent changes to site-specific source files; please see the next commit for more details."
	msgLen1st := StrLen(commitCssVars.dflt1stCommitMsg)
	msgLen2nd := StrLen(commitCssVars.dflt2ndCommitMsg)
	lastLessMsg1st := ""
	msgLenLess1st := 0
	lastLessMsg2nd := ""
	msgLenLess2nd := 0
	if (commitCssLastLessCommit != undefined) {
		lessMsgs := commitCssLastLessCommit[commitCssVars.fnLessSrcFile]
		if (lessMsgs != undefined) {
			lastLessMsg1st := lessMsgs.primary
			msgLenLess1st := StrLen(lastLessMsg1st)
			lastLessMsg2nd := lessMsgs.secondary
			msgLenLess2nd := StrLen(lastLessMsg2nd)
		}
	}

	; GUI initialization & display to user
	Gui, guiCommitCssBuild: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCommitCssBuild: Add
		, Text, , % "&Primary commit message:"
	Gui, guiCommitCssBuild: Add
		, Edit, vctrlCommitCss1stMsg gHandleCommitCss1stMsgChange X+5 W606
		, % commitCssVars.dflt1stCommitMsg
	Gui, guiCommitCssbuild: Add
		, Text, vctrlCommitCss1stMsgCharCount Y+1 W500
		, % "Length = " . msgLen1st . " characters"
	Gui, guiCommitCssBuild: Add
		, Text, xm Y+12, % "&Secondary commit message:"
	Gui, guiCommitCssBuild: Add, Edit
		, vctrlCommitCss2ndMsg gHandleCommitCss2ndMsgChange X+5 W589
		, % commitCssVars.dflt2ndCommitMsg
	Gui, guiCommitCssbuild: Add
		, Text, vctrlCommitCss2ndMsgCharCount Y+1 W500
		, % "Length = " . msgLen2nd . " characters"
	Gui, guiCommitCssBuild: Add
		, Checkbox, vctrlCommitCssAlsoCommitLessSrc gHandleCommitCssCheckLessFileCommit xm Y+12
		, % "&Also commit site-specific Less source(s), e.g., " . commitCssVars.fnLessSrcFile . "?"
	Gui, guiCommitCssBuild: Add, Checkbox
		, vctrlCommitCssLessChangesOnly gHandleCommitCssCheckLessChangesOnly xm Disabled
		, % "Site-specific less source(s) &is/are only changed dependency(ies)"
	Gui, guiCommitCssBuild: Font, italic
	Gui, guiCommitCssBuild: Add
		, Text, Y+12, % "Site-specific less source(s): "
	Gui, guiCommitCssBuild: Font
	Gui, guiCommitCssBuild: Add
		, ListView, vctrlCommitCssLV grid BackgroundEBF8FE NoSortHdr r5 W700 xm+1 Y+3
		, % "File Name"
	LV_Add(, "CSS\" . commitCssVars.fnLessSrcFile)
	Gui, guiCommitCssBuild: Add
		, Button, gHandleCommitCssAddFiles vctrlCommitCssAddFiles xm Y+3 Disabled, Add &More Files
	Gui, guiCommitCssBuild: Add
		, Button, gHandleCommitCssRemoveFiles vctrlCommitCssRemoveFiles X+3 Disabled
		, &Remove selected file
	Gui, guiCommitCssBuild: Add
		, Button, gHandleCommitCssGitDiff vctrlCommitCssGitDiff X+3 Disabled, &Git diff selection
	Gui, guiCommitCssBuild: Add
		, Button, gHandleCommitCssGitLog vctrlCommitCssGitLog X+3 Disabled, Gi&t log selection
	Gui, guiCommitCssBuild: Add
		, Text, xm Y+12, % "Message for &Less file changes:"
	Gui, guiCommitCssBuild: Add
		, Edit, vctrlCommitCss1stLessMsg gHandleCommitCss1stLessMsgChange X+5 W573 Disabled
		, % lastLessMsg1st
	Gui, guiCommitCssbuild: Add
		, Text, vctrlCommitCss1stLessMsgCharCount Y+1 W500
		, % "Length = " . msgLenLess1st . " characters"
	Gui, guiCommitCssBuild: Add
		, Text, xm Y+12, % "Secondary L&ess message (optional):"
	Gui, guiCommitCssBuild: Add
		, Edit, vctrlCommitCss2ndLessMsg gHandleCommitCss2ndLessMsgChange X+5 W549 Disabled
		, % lastLessMsg2nd
	Gui, guiCommitCssbuild: Add
		, Text, vctrlCommitCss2ndLessMsgCharCount Y+1 W500
		, % "Length = " . msgLenLess2nd . " characters"
	Gui, guiCommitCssBuild: Add
		, Button, Default gHandleCommitCssOk xm, &Ok
	Gui, guiCommitCssBuild: Add
		, Button, gHandleCommitCssCancel X+5, &Cancel
	Gui, guiCommitCssBuild: Show
}

; --------------------------------------------------------------------------------------------------
;   §2: GUI EVENT HANDLERS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: HandleCommitCss1stMsgChange

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

;   ································································································
;     >>> §2.2: HandleCommitCss2ndMsgChange

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

;   ································································································
;     >>> §2.3: HandleCommitCssAddFiles

HandleCommitCssAddFiles() {
	global commitCssVars

	FileSelectFile, selectedFiles, M3, , % "Select (a) file(s) to be committed."
	if (selectedFiles != "") {
		newFilesToCommit := Object()
		Loop, Parse, selectedFiles, `n
		{
			if (a_index = 1) {
				gitSubFolder := A_LoopField . "\"
			} else {
				newFilesToCommit.Push(A_LoopField)
			}
		}

		; Verify that we are in a sub folder of the original git folder
		gitRepositoryPath := commitCssVars.fpGitFolder
		posWhereFound := InStr(gitSubFolder, gitRepositoryPath)
		if (posWhereFound) {

			; Remove the root folder path from the subfolder path, leaving a relative path
			gitSubFolder := StrReplace(gitSubFolder, gitRepositoryPath, "")

			; Ensure the proper GUI is default to LV_Add function works as expected
			Gui, guiCommitCssBuild: Default

			fileCount := newFilesToCommit.Length()
			Loop, %fileCount%
			{
				LV_Add(, gitSubFolder . newFilesToCommit[A_Index])
			}

		} else {
			ErrorBox(A_ThisFunc, "Unfortunately, you did not select files contained within the "
				. "git repository you are working with. Please try again.")
		}
	}
}

;   ································································································
;     >>> §2.4: HandleCommitCssRemoveFiles

HandleCommitCssRemoveFiles() {
	Gui, guiCommitCssBuild: Default
	Loop % LV_GetCount("Selected")
	{
		rowToRemove := LV_GetNext()
		LV_Delete(rowToRemove)
	}
}

;   ································································································
;     >>> §2.5: HandleCommitCssGitDiff
;
;   Function handler for activation of the button used to perform a git diff command on selected
;   site-specific CSS build dependencies.

HandleCommitCssGitDiff() {
	global commitCssVars
	global execDelayer

	numSelectedRows := LV_GetCount("Selected")
	consoleStr := "cd " . commitCssVars.fpGitFolder . "`r"
	if (numSelectedRows > 0) {
		rowNumber := 0
		Loop
		{
			rowNumber := LV_GetNext(rowNumber)
			if (rowNumber) {
				LV_GetText(fileName, rowNumber)
				consoleStr .= "git --no-pager diff " . fileName . "`r"
				execDelayer.wait( "xs" )
			} else {
				break
			}
		}		
	} else {
		rowNumber := 1
		numRows := LV_GetCount()
		while (rowNumber <= numRows) {
			LV_GetText(fileName, rowNumber)
			consoleStr .= "git --no-pager diff " . fileName . "`r"
			rowNumber++
		}
	}
	PasteTextIntoGitShell(A_ThisLabel, consoleStr)
}

;   ································································································
;     >>> §2.6: HandleCommitCssGitLog
;
;   Function handler for activation of the button used to perform a git log command on selected
;   files.

HandleCommitCssGitLog() {
	global commitCssVars
	global execDelayer

	cmdStr := "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s | %b"" --max-count"
		. "=20 "
	numSelectedRows := LV_GetCount("Selected")
	consoleStr := "cd " . commitCssVars.fpGitFolder . "`r"
	if (numSelectedRows > 0) {
		rowNumber := 0
		Loop
		{
			rowNumber := LV_GetNext(rowNumber)
			if (rowNumber) {
				LV_GetText(fileName, rowNumber)
				consoleStr .= cmdStr . fileName . "`r"
				execDelayer.Wait( "s" )
			} else {
				break
			}
		}
	} else {
		rowNumber := 1
		numRows := LV_GetCount()
		while (rowNumber <= numRows) {
			LV_GetText(fileName, rowNumber)
			consoleStr .= cmdStr . fileName . "`r"
			rowNumber++
		}
	}
	PasteTextIntoGitShell(A_ThisLabel, consoleStr)
}

;   ································································································
;     >>> §2.7: HandleCommitCssCheckLessFileCommit

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
	global ctrlCommitCssAddFiles
	global ctrlCommitCssRemoveFiles
	global ctrlCommitCssGitDiff
	global ctrlCommitCssGitLog

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide

	; Respond to user input.
	if (ctrlCommitCssAlsoCommitLessSrc) {
		GuiControl, Enable, ctrlCommitCssAddFiles
		GuiControl, Enable, ctrlCommitCssRemoveFiles
		GuiControl, Enable, ctrlCommitCssGitDiff
		GuiControl, Enable, ctrlCommitCssGitLog
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
		GuiControl, Disable, ctrlCommitCssAddFiles
		GuiControl, Disable, ctrlCommitCssRemoveFiles
		GuiControl, Disable, ctrlCommitCssGitDiff
		GuiControl, Disable, ctrlCommitCssGitLog
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

;   ································································································
;     >>> §2.8: HandleCommitCssCheckLessChangesOnly

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

;   ································································································
;     >>> §2.9: HandleCommitCss1stLessMsgChange

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

;   ································································································
;     >>> §2.10: HandleCommitCss2ndLessMsgChange

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

;   ································································································
;     >>> §2.11: HandleCommitCssOk

; Triggered by OK button in guiCommitCssBuild GUI.
HandleCommitCssOk() {
	global commitCssVars
	global commitCssLastLessCommit
	global ctrlCommitCss1stMsg
	global ctrlCommitCss2ndMsg
	global ctrlCommitCssAlsoCommitLessSrc
	global ctrlCommitCss1stLessMsg
	global ctrlCommitCss2ndLessMsg

	; Submit GUI to finalize variables storing user input.
	Gui, guiCommitCssBuild: Default
	Gui, guiCommitCssBuild: Submit, NoHide

	numFilesToCommit := LV_GetCount()

	; Ensure that state of global variables is consistent with a valid GUI submission.
	gVarCheck := commitCssVars.ahkCmdName == undefined
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fpGitFolder == undefined)
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fnLessSrcFile == undefined)
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fnCssbuild == undefined)
	gVarCheck := (gVarCheck << 1) | (commitCssVars.fnMinCssBuild == undefined)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitCssAlsoCommitLessSrc && numFilesToCommit == 0)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitCss1stMsg == undefined)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitCssAlsoCommitLessSrc
		&& ctrlCommitCss1stLessMsg == undefined)

	if (!gVarCheck) {
		; Build the command line inputs for commiting the code to the appropriate git repository.
		escaped1stCssMsg := EscapeCommitMessage(ctrlCommitCss1stMsg)
		commandLineInput := "cd '" . commitCssVars.fpGitFolder . "'`r"
			. "git add CSS\" . commitCssVars.fnCssBuild . "`r"
			. "git add CSS\" . commitCssVars.fnMinCssBuild . "`r"
			. "git commit -m """ . escaped1stCssMsg . """"
		if (ctrlCommitCss2ndMsg != "") {
			escaped2ndCssMsg := EscapeCommitMessage(ctrlCommitCss2ndMsg)
			commandLineInput .= " -m """ . escaped2ndCssMsg . """`r"
		} else {
			commandLineInput .= "`r"
		}
		commandLineInput .= "git push`r"
		if (ctrlCommitCssAlsoCommitLessSrc) {
			escaped1stLessMsg := EscapeCommitMessage(ctrlCommitCss1stLessMsg)
			Loop % numFilesToCommit {
				LV_GetText(nextFileToCommit, A_Index)
				commandLineInput .= "git add " . nextFileToCommit . "`r"
			}
			commandLineInput .= "git commit -m """ . escaped1stLessMsg . """"
			if (ctrlCommitCss2ndLessMsg != "") {
				escaped2ndLessMsg := EscapeCommitMessage(ctrlCommitCss2ndLessMsg)
				commandLineInput .= " -m """ . escaped2ndLessMsg . """`r"
			} else {
				commandLineInput .= "`r"
			}
			commandLineInput .= "git push`r"

			; Store commit for later use as a guide
			if (commitCssLastLessCommit == undefined) {
				commitCssLastLessCommit := Object()
			}
			commitCssLastLessCommit[commitCssVars.fnLessSrcFile] := Object()
			commitCssLastLessCommit[commitCssVars.fnLessSrcFile].primary := ctrlCommitCss1stLessMsg
			commitCssLastLessCommit[commitCssVars.fnLessSrcFile].secondary := ctrlCommitCss2ndLessMsg
		}
		commandLineInput .= "[console]::beep(2000,150)`r"
			. "[console]::beep(2000,150)`r"

		Gui, guiCommitCssBuild: Destroy

		; Paste the code into the command console.
		PasteTextIntoGitShell(commitCssVars.ahkCmdName, commandLineInput)
	} else {
		; Determine what went wrong, notify user, and handle accordingly.
		ProcessHandleCommitCssOkError(gVarCheck)
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.11.1: ProcessHandleCommitCssOkError

; Called by HandleCommitCssOk() to handle error processing.
ProcessHandleCommitCssOkError(gVarCheck) {
	functionName := "CommitCssBuild.ahk / HandleCommitCssOk()"
	if (gVarCheck == 1) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the LESS source"
. " file.")
	} else if (gVarCheck == 2) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the CSS builds.")
	} else if (gVarCheck == 3) {
		ErrorBox(functionName
			, "Please enter primary git commit messages regarding changes in the CSS builds and"
. " the LESS source file.")
	} else if (gVarCheck & 4) {
		ErrorBox(functionName
			, "Please select at least one site-specific Less file to be committed.")
	} else {
		Gui, guiCommitCssBuild: Destroy
		ErrorBox(functionName
			, "An undefined global variable was encountered; function terminating. Variable"
. " checking bitmask was equal to " . gVarCheck . ".")
	}
}

;   ································································································
;     >>> §2.12: HandleCommitCssCancel

; Triggered by Cancel button in guiCommitCssBuild GUI.
HandleCommitCssCancel() {
	Gui, guiCommitCssBuild: Destroy
}

; --------------------------------------------------------------------------------------------------
;   §3: GUI PERSISTENCE FUNCTIONS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: SaveCommitCssLessMsgHistory

; Used to grant permanence to LESS commit message history functionality between scripting sessions
SaveCommitCssLessMsgHistory() {
	global commitCssLastLessCommit
	global commitCssLessMsgLog

	if (commitCssLastLessCommit != undefined) {
		logFile := FileOpen(commitCssLessMsgLog, "w `n")
		if (logFile) {
			For key, value in commitCssLastLessCommit {
				numBytes := logFile.WriteLine(key)
				if (numBytes) {
					numBytes := logFile.WriteLine(value.primary)
					if (numBytes) {
						numBytes := logFile.WriteLine(value.secondary)
						if (!numBytes) {
							ErrorBox(A_ThisFunc, "Could not write the secondary LESS commit message"
. " for " . key . ".")
						}
					} else {
						ErrorBox(A_ThisFunc, "Could not write the primary LESS commit message for "
. key . ".")
					}
				} else {
					ErrorBox(A_ThisFunc, "Could not record the next LESS file name, " . key . ".")
				}
			}
			logFile.Close()
		} else {
			ErrorBox(A_ThisFunc, "Could not open less commit message history log file '"
. commitCssLessMsgLog . "'. Error code reported by FileOpen: '" . A_LastError . "'")
		}
	}
}

;   ································································································
;     >>> §3.2: LoadCommitCssLessMsgHistory

LoadCommitCssLessMsgHistory() {
	; TODO: Rewrite code below
	global commitCssLastLessCommit
	global commitCssLessMsgLog

	if (commitCssLastLessCommit == undefined) {
		commitCssLastLessCommit := Object()
	}

	logFile := FileOpen(commitCssLessMsgLog, "r `n")
	if (logFile) {
		Loop {
			key := ReadKeyForLessMsgHistory(logFile)
			if (key == "") {
				break
			} else {
				if (!ReadPrimaryMsgForLessFileKey(logFile, commitCssLastLessCommit, key)) {
					ErrorBox(A_ThisFunc, "Log file abruptly stopped after reading a LESS file key. "
. "Aborting further reading of log.")
					break
				} else if(!ReadSecondaryMsgForLessFileKey(logFile, commitCssLastLessCommit, key)) {
					ErrorBox(A_ThisFunc, "Log file abruptly stopped after reading a LESS file key a"
. "nd primary git commit message. Aborting further reading of log.")
					break
				}
			}
		}
		logFile.Close()
	} else {
		ErrorBox(A_ThisFunc, "Could not open less commit message history log file '"
			. commitCssLessMsgLog . "'. Error code reported by FileOpen: '" . A_LastError . "'")
	}
}

;   ································································································
;     >>> §3.3: ReadKeyForLessMsgHistory

ReadKeyForLessMsgHistory(ByRef logFile) {
	key := ""
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		logFileLine := StrReplace(logFileLine, "`n", "")
		if (logFileLine != "") {
			key := logFileLine
		} else {
			ErrorBox(A_ThisFunc, "Blank line encountered when attempting to read the next LESS file"
. " name in the log. Aborting further reading of log.")
		}
	}
	return key
}

;   ································································································
;     >>> §3.4: ReadPrimaryMsgForLessFileKey

ReadPrimaryMsgForLessFileKey(ByRef logFile, ByRef lessMsgArray, key) {
	success := false
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		logFileLine := StrReplace(logFileLine, "`n", "")
		if (logFileLine != "") {
			success := true
			lessMsgArray[key] := Object()
			lessMsgArray[key].primary := logFileLine
		}
	}
	return success
}

;   ································································································
;     >>> §3.5: ReadSecondaryMsgForLessFileKey

ReadSecondaryMsgForLessFileKey(ByRef logFile, ByRef lessMsgArray, key) {
	success := false
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		success := true
		logFileLine := StrReplace(logFileLine, "`n", "")
		lessMsgArray[key].secondary := logFileLine
	}
	return success
}
