; ==================================================================================================
; GUI FOR COMMITTING CSS BUILDS & ASSOCIATED SITE-SPECIFIC CUSTOM LESS FILES
; ==================================================================================================
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents:
; -----------------
;   §1: GUI CREATION FUNCTION: CommitJsBuild....................................................34
;   §2: GUI EVENT HANDLERS.....................................................................158
;     >>> §2.1: HandleCommitJs1stMsgChange.....................................................162
;     >>> §2.2: HandleCommitJs2ndMsgChange.....................................................179
;     >>> §2.3: HandleCommitJsAddFiles.........................................................196
;     >>> §2.4: HandleCommitJsRemoveFiles......................................................238
;     >>> §2.5: HandleCommitJsGitDiff..........................................................250
;     >>> §2.6: HandleCommitJsGitLog...........................................................287
;     >>> §2.7: HandleCommitJsCheckJsFileCommit................................................326
;     >>> §2.8: HandleCommitJsCheckJsChangesOnly...............................................389
;     >>> §2.9: HandleCommitJs1stJsMsgChange...................................................432
;     >>> §2.10: HandleCommitJs2ndJsMsgChange..................................................449
;     >>> §2.11: HandleCommitJsOk..............................................................466
;       →→→ §2.11.1: ProcessHandleCommitJsOkError..............................................546
;     >>> §2.12: HandleCommitJsCancel..........................................................574
;   §3: GUI PERSISTENCE FUNCTIONS..............................................................582
;     >>> §3.1: SaveCommitJsCustomJsMsgHistory.................................................586
;     >>> §3.2: LoadCommitJsCustomJsMsgHistory.................................................624
;     >>> §3.3: ReadKeyForCustonJsMsgHistory...................................................661
;     >>> §3.4: ReadPrimaryMsgForCustomJsFileKey...............................................679
;     >>> §3.5: ReadSecondaryMsgForCustomJsFileKey.............................................696
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GUI CREATION FUNCTION: CommitJsBuild
; --------------------------------------------------------------------------------------------------

; Sets up a GUI to automate committing of CSS build files.
CommitJsBuild(ahkCmdName, fpGitFolder, fnJsSrcFile, fnJsbuild, fnMinJsBuild) {
	; Global variable declarations
	global commitJsVars := Object()
	global commitJsLastCustomJsCommit
	global ctrlCommitJsAlsoCommitJsSrc
	global ctrlCommitJsJsChangesOnly
	global ctrlCommitJsLV
	global ctrlCommitJsAddFiles
	global ctrlCommitJsRemoveFiles
	global ctrlCommitJsGitDiff
	global ctrlCommitJs1stMsg
	global ctrlCommitJs1stMsgCharCount
	global ctrlCommitJs2ndMsg
	global ctrlCommitJs2ndMsgCharCount
	global ctrlCommitJs1stJsMsg ; Remove?
	global ctrlCommitJs1stJsMsgCharCount ; Remove?
	global commitJsDflt1stCommitMsg ; Remove?
	global ctrlCommitJs2ndJsMsg
	global ctrlCommitJs2ndJsMsgCharCount

	; Variable initializations
	commitJsVars.ahkCmdName := ahkCmdName
	commitJsVars.fpGitFolder := fpGitFolder
	commitJsVars.fnJsSrcFile := fnJsSrcFile
	commitJsVars.fnJsbuild := fnJsbuild
	commitJsVars.fnMinJsBuild := fnMinJsBuild
	commitJsVars.dflt1stCommitMsg := "Update dev dependencies for and builds of custom JS code"
	commitJsVars.dflt1stCommitMsgAlt := "Update dev dependencies for and builds of custom JS code"
	commitJsVars.dflt1stCommitMsgAlt2 := "Update dev dependencies for and builds of custom JS code"
	commitJsVars.dflt2ndCommitMsg := "First, update the WSU-UE---JS submodule, which holds "
		. "universal dev dependencies used to build custom JS code in every DAESA website "
		. "development project. Next, rebuild the files containing custom JS code that is ready to "
		. "be deployed on the website associated with this project."
	commitJsVars.dflt2ndCommitMsgAlt := "Next, update the WSU-UE---JS submodule, which holds "
		. "universal dev dependencies used to build custom JS code in every DAESA website "
		. "development project. Finally, rebuild the files containing custom JS code that is ready "
 		. "to be deployed on the website associated with this project."
	commitJsVars.dflt2ndCommitMsgAlt2 := "Then rebuild the files containing custom JS code that is "
		. "ready to be deployed on the website associated with this project."
	msgLen1st := StrLen(commitJsVars.dflt1stCommitMsg)
	msgLen2nd := StrLen(commitJsVars.dflt2ndCommitMsg)
	lastJsMsg1st := ""
	msgLenJs1st := 0
	lastJsMsg2nd := ""
	msgLenJs2nd := 0
	if (commitJsLastCustomJsCommit != undefined) {
		jsMsgs := commitJsLastCustomJsCommit[commitJsVars.fnJsSrcFile]
		if (jsMsgs != undefined) {
			lastJsMsg1st := jsMsgs.primary
			msgLenJs1st := StrLen(lastJsMsg1st)
			lastJsMsg2nd := jsMsgs.secondary
			msgLenJs2nd := StrLen(lastJsMsg2nd)
		}
	}

	; GUI initialization & display to user
	Gui, guiCommitJsBuild: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCommitJsBuild: Add
		, Text, , % "&Primary commit message:"
	Gui, guiCommitJsBuild: Add
		, Edit, vctrlCommitJs1stMsg gHandleCommitJs1stMsgChange X+5 W606
		, % commitJsVars.dflt1stCommitMsg
	Gui, guiCommitJsbuild: Add
		, Text, vctrlCommitJs1stMsgCharCount Y+1 W500
		, % "Length = " . msgLen1st . " characters"
	Gui, guiCommitJsBuild: Add
		, Checkbox, vctrlCommitJsAlsoCommitJsSrc gHandleCommitJsCheckJsFileCommit xm Y+12
		, % "&Also commit local dev dependencies, e.g., " . commitJsVars.fnJsSrcFile . "?"
	Gui, guiCommitJsBuild: Add, Checkbox
		, vctrlCommitJsJsChangesOnly gHandleCommitJsCheckJsChangesOnly xm Disabled
		, % "Custom JS code rebuild &involves only changes to local dev dependencyies"
	Gui, guiCommitJsBuild: Font, italic
	Gui, guiCommitJsBuild: Add
		, Text, Y+12, % "Site-specific JS source(s): "
	Gui, guiCommitJsBuild: Font
	Gui, guiCommitJsBuild: Add
		, ListView, vctrlCommitJsLV grid BackgroundEBF8FE NoSortHdr r5 W700 xm+1 Y+3
		, % "File Name"
	LV_Add(, "JS\" . commitJsVars.fnJsSrcFile)
	Gui, guiCommitJsBuild: Add
		, Button, gHandleCommitJsAddFiles vctrlCommitJsAddFiles xm Y+3 Disabled, Add &More Files
	Gui, guiCommitJsBuild: Add
		, Button, gHandleCommitJsRemoveFiles vctrlCommitJsRemoveFiles X+3  Disabled
		, &Remove selected file
	Gui, guiCommitJsBuild: Add
		, Button, gHandleCommitJsGitDiff vctrlCommitJsGitDiff X+3 Disabled, &Git diff selection
	Gui, guiCommitJsBuild: Add
		, Button, gHandleCommitJsGitLog vctrlCommitJsGitLog X+3 Disabled, Gi&t log selection
	Gui, guiCommitJsBuild: Add
		, Text, xm Y+12, % "Secondary commit message, part &1 (RE: local dev dependency changes):"	
	Gui, guiCommitJsBuild: Add
		, Edit, vctrlCommitJs2ndJsMsg gHandleCommitJs2ndJsMsgChange xm Y+3 W549 Disabled
		, % lastJsMsg2nd
	Gui, guiCommitJsbuild: Add
		, Text, vctrlCommitJs2ndMsgCharCount Y+1 W500
		, % "Length = " . msgLen2nd . " characters"
	Gui, guiCommitJsBuild: Add
		, Text, xm Y+12, % "&Secondary commit message, part 2 (RE: dev dependencies submodule "
		. "changes & rebuild):"
	Gui, guiCommitJsBuild: Add, Edit
		, vctrlCommitJs2ndMsg gHandleCommitJs2ndMsgChange xm Y+3 W589
		, % commitJsVars.dflt2ndCommitMsg
	Gui, guiCommitJsbuild: Add
		, Text, vctrlCommitJs2ndJsMsgCharCount Y+1 W500
		, % "Length = " . msgLenJs2nd . " characters"
	Gui, guiCommitJsBuild: Add
		, Button, Default gHandleCommitJsOk xm, &Ok
	Gui, guiCommitJsBuild: Add
		, Button, gHandleCommitJsCancel X+5, &Cancel
	Gui, guiCommitJsBuild: Show
}

; --------------------------------------------------------------------------------------------------
;   §2: GUI EVENT HANDLERS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: HandleCommitJs1stMsgChange

; Triggered when the primary git commit message for the updated CSS builds is changed.
HandleCommitJs1stMsgChange() {
	; Make global variable declarations.
	global ctrlCommitJs1stMsg
	global ctrlCommitJs1stMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitJsBuild: Submit, NoHide

	; Update character count field
	msgLen := StrLen(ctrlCommitJs1stMsg)
	GuiControl, , ctrlCommitJs1stMsgCharCount, % "Length = " . msgLen . " characters"
}

;   ································································································
;     >>> §2.2: HandleCommitJs2ndMsgChange

; Triggered when the secondary git commit message for the updated CSS builds is changed.
HandleCommitJs2ndMsgChange() {
	; Make global variable declarations.
	global ctrlCommitJs2ndMsg
	global ctrlCommitJs2ndMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitJsBuild: Submit, NoHide

	; Update character count field
	msgLen := StrLen(ctrlCommitJs2ndMsg)
	GuiControl, , ctrlCommitJs2ndMsgCharCount, % "Length = " . msgLen . " characters"
}

;   ································································································
;     >>> §2.3: HandleCommitJsAddFiles

HandleCommitJsAddFiles() {
	global commitJsVars

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
		gitRepositoryPath := commitJsVars.fpGitFolder
		posWhereFound := InStr(gitSubFolder, gitRepositoryPath)
		if (posWhereFound) {

			; Remove the root folder path from the subfolder path, leaving a relative path
			gitSubFolder := StrReplace(gitSubFolder, gitRepositoryPath, "")

			; Ensure the proper GUI is default to LV_Add function works as expected
			Gui, guiCommitJsBuild: Default

			fileCount := newFilesToCommit.Length()
			Loop, %fileCount%
			{
				LV_Add(, gitSubFolder . newFilesToCommit[A_Index])
			}

		} else {
			ErrorBox(A_ThisFunc, "Unfortunately, you did not select files contained within the git "
				. "repository you indicated. Please try again.")
		}
	}
}

;   ································································································
;     >>> §2.4: HandleCommitJsRemoveFiles

HandleCommitJsRemoveFiles() {
	Gui, guiCommitJsBuild: Default
	Loop % LV_GetCount("Selected")
	{
		rowToRemove := LV_GetNext()
		LV_Delete(rowToRemove)
	}
}

;   ································································································
;     >>> §2.5: HandleCommitJsGitDiff
;
;   Function handler for activation of the button used to perform a git diff command on selected
;   site-specific JS build dependencies.

HandleCommitJsGitDiff() {
	global commitJsVars
	global execDelayer

	numSelectedRows := LV_GetCount("Selected")
	consoleStr := "cd " . commitJsVars.fpGitFolder . "`r"
	if (numSelectedRows > 0) {
		rowNumber := 0
		Loop
		{
			rowNumber := LV_GetNext(rowNumber)
			if (rowNumber) {
				LV_GetText(fileName, rowNumber)
				consoleStr .= "git --no-pager diff " . fileName . "`r"
				execDelayer.Wait( "xs" )
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
;     >>> §2.6: HandleCommitJsGitLog
;
;   Function handler for activation of the button used to perform a git log command on selected
;   files.

HandleCommitJsGitLog() {
	global commitJsVars
	global execDelayer

	cmdStr := "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s%n  ╘═> %b"" --max-"
	 . "count=20 "
	numSelectedRows := LV_GetCount("Selected")
	consoleStr := "cd " . commitJsVars.fpGitFolder . "`r"
	if (numSelectedRows > 0) {
		rowNumber := 0
		Loop
		{
			rowNumber := LV_GetNext(rowNumber)
			if (rowNumber) {
				LV_GetText(fileName, rowNumber)
				consoleStr .= cmdStr . fileName . "`r"
				execDelayer.Wait( "xs" )
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
;     >>> §2.7: HandleCommitJsCheckJsFileCommit

; Triggered by state changes in checkbox control in guiCommitJsBuild GUI.
HandleCommitJsCheckJsFileCommit() {
	; Make global variable declarations.
	global commitJsVars
	global ctrlCommitJs1stMsg
	global ctrlCommitJs1stMsgCharCount
	global ctrlCommitJs2ndMsg
	global ctrlCommitJs2ndMsgCharCount
	global ctrlCommitJs2ndJsMsg
	global ctrlCommitJsAlsoCommitJsSrc
	global ctrlCommitJsJsChangesOnly
	global ctrlCommitJsAddFiles
	global ctrlCommitJsRemoveFiles
	global ctrlCommitJsGitDiff
	global ctrlCommitJsGitLog

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitJsBuild: Submit, NoHide

	; Respond to user input.
	if ( ctrlCommitJsAlsoCommitJsSrc ) {
		GuiControl, Enable, ctrlCommitJsAddFiles
		GuiControl, Enable, ctrlCommitJsRemoveFiles
		GuiControl, Enable, ctrlCommitJsGitDiff
		GuiControl, Enable, ctrlCommitJsGitLog
		GuiControl, Enable, ctrlCommitJs2ndJsMsg
		GuiControl, Enable, ctrlCommitJsJsChangesOnly
		if ( ctrlCommitJs1stMsg == commitJsVars.dflt1stCommitMsg ) {
			GuiControl, , ctrlCommitJs1stMsg, % commitJsVars.dflt1stCommitMsgAlt
			msgLen := StrLen(commitJsVars.dflt1stCommitMsgAlt)
			GuiControl, , ctrlCommitJs1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if ( ctrlCommitJs2ndMsg == commitJsVars.dflt2ndCommitMsg ) {
			GuiControl, , ctrlCommitJs2ndMsg, % commitJsVars.dflt2ndCommitMsgAlt
			msgLen := StrLen( commitJsVars.dflt2ndCommitMsgAlt )
			GuiControl, , ctrlCommitJs2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	} else {
		GuiControl, Disable, ctrlCommitJsAddFiles
		GuiControl, Disable, ctrlCommitJsRemoveFiles
		GuiControl, Disable, ctrlCommitJsGitDiff
		GuiControl, Disable, ctrlCommitJsGitLog
		GuiControl, Disable, ctrlCommitJs2ndJsMsg
		GuiControl, Disable, ctrlCommitJsJsChangesOnly
		if (ctrlCommitJs1stMsg == commitJsVars.dflt1stCommitMsgAlt) {
			GuiControl, , ctrlCommitJs1stMsg, % commitJsVars.dflt1stCommitMsg
			msgLen := StrLen(commitJsVars.dflt1stCommitMsg)
			GuiControl, , ctrlCommitJs1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitJs2ndMsg == commitJsVars.dflt2ndCommitMsgAlt) {
			GuiControl, , ctrlCommitJs2ndMsg, % commitJsVars.dflt2ndCommitMsg
			msgLen := StrLen(commitJsVars.dflt2ndCommitMsg)
			GuiControl, , ctrlCommitJs2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	}
}

;   ································································································
;     >>> §2.8: HandleCommitJsCheckJsChangesOnly

; Triggered by state changes in checkbox control in guiCommitJsBuild GUI.
HandleCommitJsCheckJsChangesOnly() {
	; Make global variable declarations.
	global commitJsVars
	global ctrlCommitJs1stMsg
	global ctrlCommitJs1stMsgCharCount
	global ctrlCommitJs2ndMsg
	global ctrlCommitJs2ndMsgCharCount
	global ctrlCommitJsAlsoCommitJsSrc
	global ctrlCommitJsJsChangesOnly

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitJsBuild: Submit, NoHide

	; Respond to user input.
	if (ctrlCommitJsJsChangesOnly) {
		if (ctrlCommitJs1stMsg == commitJsVars.dflt1stCommitMsgAlt) {
			GuiControl, , ctrlCommitJs1stMsg, % commitJsVars.dflt1stCommitMsgAlt2
			msgLen := StrLen(commitJsVars.dflt1stCommitMsgAlt2)
			GuiControl, , ctrlCommitJs1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitJs2ndMsg == commitJsVars.dflt2ndCommitMsgAlt) {
			GuiControl, , ctrlCommitJs2ndMsg, % commitJsVars.dflt2ndCommitMsgAlt2
			msgLen := StrLen(commitJsVars.dflt2ndCommitMsgAlt2)
			GuiControl, , ctrlCommitJs2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	} else {
		if (ctrlCommitJs1stMsg == commitJsVars.dflt1stCommitMsgAlt2) {
			GuiControl, , ctrlCommitJs1stMsg, % commitJsVars.dflt1stCommitMsgAlt
			msgLen := StrLen(commitJsVars.dflt1stCommitMsgAlt)
			GuiControl, , ctrlCommitJs1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitJs2ndMsg == commitJsVars.dflt2ndCommitMsgAlt2) {
			GuiControl, , ctrlCommitJs2ndMsg, % commitJsVars.dflt2ndCommitMsgAlt
			msgLen := StrLen(commitJsVars.dflt2ndCommitMsgAlt)
			GuiControl, , ctrlCommitJs2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	}
}

;   ································································································
;     >>> §2.10: HandleCommitJs2ndJsMsgChange

; Triggered when the secondary git commit message for the updated LESS source is changed.
HandleCommitJs2ndJsMsgChange() {
	; Make global variable declarations.
	global ctrlCommitJs2ndJsMsg
	global ctrlCommitJs2ndJsMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitJsBuild: Submit, NoHide

	; Update character count field
	msgLen := StrLen(ctrlCommitJs2ndJsMsg)
	GuiControl, , ctrlCommitJs2ndJsMsgCharCount, % "Length = " . msgLen . " characters"
}

;   ································································································
;     >>> §2.11: HandleCommitJsOk

; Triggered by OK button in guiCommitJsBuild GUI.
HandleCommitJsOk() {
	global commitJsVars
	global commitJsLastCustomJsCommit
	global ctrlCommitJs1stMsg
	global ctrlCommitJs2ndMsg
	global ctrlCommitJsAlsoCommitJsSrc
	global ctrlCommitJsJsChangesOnly
	global ctrlCommitJs2ndJsMsg

	; Submit GUI to finalize variables storing user input.
	Gui, guiCommitJsBuild: Default
	Gui, guiCommitJsBuild: Submit, NoHide

	numFilesToCommit := LV_GetCount()

	; Ensure that state of global variables is consistent with a valid GUI submission.
	gVarCheck := commitJsVars.ahkCmdName == undefined
	gVarCheck := (gVarCheck << 1) | (commitJsVars.fpGitFolder == undefined)
	gVarCheck := (gVarCheck << 1) | (commitJsVars.fnJsSrcFile == undefined)
	gVarCheck := (gVarCheck << 1) | (commitJsVars.fnJsbuild == undefined)
	gVarCheck := (gVarCheck << 1) | (commitJsVars.fnMinJsBuild == undefined)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitJsAlsoCommitJsSrc && numFilesToCommit == 0)

	if (!gVarCheck) {
		; Build the command line inputs for commiting the code to the appropriate git repository.
		; First, have the shell enter the project's directory.
		commandLineInput := "cd '" . commitJsVars.fpGitFolder . "'`r"

		; Add the universal dev dependencies submodule to the commit if it has changed.
		if ( !ctrlCommitJsJsChangesOnly ) {
			commandLineInput .= "git add WSU-UE---JS`r"
		}

		; Add any changed local dependencies to the commit, if appropriate.
		if ( ctrlCommitJsAlsoCommitJsSrc ) {
			Loop % numFilesToCommit {
				LV_GetText( nextFileToCommit, A_Index )
				commandLineInput .= "git add " . nextFileToCommit . "`r"
			}
 		}

		; Add the JS builds to the commit.
		commandLineInput .= "git add JS\" . commitJsVars.fnJsBuild . "`rgit add JS\"
			. commitJsVars.fnMinJsBuild . "`r"

		; Now build the commit command, starting with the first commit message.
		escaped1stJsMsg := EscapeCommitMessage( ctrlCommitJs1stMsg )
		commandLineInput .= "git commit -m """ . escaped1stJsMsg . """"

		; Next, add the second commit message according to GUI's settings.
		if ( ctrlCommitJs2ndMsg != "" ) {
			commandLineInput .= " -m """
			if ( ctrlCommitJsAlsoCommitJsSrc && ctrlCommitJs2ndJsMsg != "" ) {
				escaped2ndJsMsg := EscapeCommitMessage( ctrlCommitJs2ndJsMsg )
				commandLineInput .= escaped2ndJsMsg . " "
			}
			escaped2ndJsMsg := EscapeCommitMessage( ctrlCommitJs2ndMsg )
			commandLineInput .= escaped2ndJsMsg . """`r"
		} else if ( ctrlCommitJsAlsoCommitJsSrc && ctrlCommitJs2ndJsMsg != "" ) {
			escaped2ndJsMsg := EscapeCommitMessage( ctrlCommitJs2ndJsMsg )
			commandLineInput .= " -m """ . escaped2ndJsMsg . """`r"
		} else {
			commandLineInput .= "`r"
		}

		; Finally, add in the push command & an auditory cue.
		commandLineInput .= "git push`r[console]::beep(2000,150)`r[console]::beep(2000,150)`r"

		; If appropriate, store commit for later use as a guide
		if ( ctrlCommitJsAlsoCommitJsSrc ) {
			if ( commitJsLastJsCommit == undefined ) {
				commitJsLastJsCommit := Object()
			}
			commitJsLastJsCommit[ commitJsVars.fnJsSrcFile ] := Object()
			commitJsLastJsCommit[ commitJsVars.fnJsSrcFile ].primary := ctrlCommitJs1stMsg
			commitJsLastJsCommit[ commitJsVars.fnJsSrcFile ].secondary := ctrlCommitJs2ndJsMsg
		}

		Gui, guiCommitJsBuild: Destroy

		; Paste the code into the command console.
		PasteTextIntoGitShell(commitJsVars.ahkCmdName, commandLineInput)
	} else {
		; Determine what went wrong, notify user, and handle accordingly.
		ProcessHandleCommitJsOkError(gVarCheck)
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.11.1: ProcessHandleCommitJsOkError

; Called by HandleCommitJsOk() to handle error processing.
ProcessHandleCommitJsOkError(gVarCheck) {
	functionName := "CommitJsBuild.ahk / HandleCommitJsOk()"
	if (gVarCheck == 1) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the custom JS source "
			. "file.")
	} else if (gVarCheck == 2) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the JS builds.")
	} else if (gVarCheck == 3) {
		ErrorBox(functionName
			, "Please enter primary git commit messages regarding changes in the JS builds and the "
			. "project-specific dev dependency file(s).")
	} else if (gVarCheck & 4) {
		ErrorBox(functionName
			, "Please select at least one site-specific Less file to be committed.")
	} else {
		Gui, guiCommitJsBuild: Destroy
		ErrorBox(functionName
			, "An undefined global variable was encountered; function terminating. Variable "
			. "checking bitmask was equal to " . gVarCheck . ".")
	}
}

;   ································································································
;     >>> §2.12: HandleCommitJsCancel

; Triggered by Cancel button in guiCommitJsBuild GUI.
HandleCommitJsCancel() {
	Gui, guiCommitJsBuild: Destroy
}

; --------------------------------------------------------------------------------------------------
;   §3: GUI PERSISTENCE FUNCTIONS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: SaveCommitJsCustomJsMsgHistory

; Used to grant permanence to LESS commit message history functionality between scripting sessions
SaveCommitJsCustomJsMsgHistory() {
	global commitJsLastCustomJsCommit
	global commitJsCustomJsMsgLog

	if (commitJsLastCustomJsCommit != undefined) {
		logFile := FileOpen(commitJsCustomJsMsgLog, "w `n")
		if (logFile) {
			For key, value in commitJsLastCustomJsCommit {
				numBytes := logFile.WriteLine(key)
				if (numBytes) {
					numBytes := logFile.WriteLine(value.primary)
					if (numBytes) {
						numBytes := logFile.WriteLine(value.secondary)
						if (!numBytes) {
							ErrorBox(A_ThisFunc, "Could not write the secondary JS commit message f"
. "or " . key . ".")
						}
					} else {
						ErrorBox(A_ThisFunc, "Could not write the primary JS commit message for "
							. key . ".")
					}
				} else {
					ErrorBox(A_ThisFunc, "Could not record the next JS file name, " . key . ".")
				}
			}
			logFile.Close()
		} else {
			ErrorBox(A_ThisFunc, "Could not open custom JS commit message history log file '"
				. commitJsCustomJsMsgLog . "'. Error code reported by FileOpen: '"
				. A_LastError . "'")
		}
	}
}

;   ································································································
;     >>> §3.2: LoadCommitJsCustomJsMsgHistory

LoadCommitJsCustomJsMsgHistory() {
	; TODO: Rewrite code below
	global commitJsLastCustomJsCommit
	global commitJsCustomJsMsgLog

	if (commitJsLastCustomJsCommit == undefined) {
		commitJsLastCustomJsCommit := Object()
	}

	logFile := FileOpen(commitJsCustomJsMsgLog, "r `n")
	if (logFile) {
		Loop {
			key := ReadKeyForCustonJsMsgHistory(logFile)
			if (key == "") {
				break
			} else {
				if (!ReadPrimaryMsgForCustomJsFileKey(logFile, commitJsLastCustomJsCommit, key)) {
					ErrorBox(A_ThisFunc, "Log file abruptly stopped after reading a LESS file key. "
. "Aborting further reading of log.")
					break
				} else if(!ReadSecondaryMsgForCustomJsFileKey(logFile, commitJsLastCustomJsCommit, key)) {
					ErrorBox(A_ThisFunc, "Log file abruptly stopped after reading a LESS file key a"
. "nd primary git commit message. Aborting further reading of log.")
					break
				}
			}
		}
		logFile.Close()
	} else {
		ErrorBox(A_ThisFunc, "Could not open less commit message history log file '"
			. commitJsCustomJsMsgLog . "'. Error code reported by FileOpen: '" . A_LastError . "'")
	}
}

;   ································································································
;     >>> §3.3: ReadKeyForCustonJsMsgHistory

ReadKeyForCustonJsMsgHistory(ByRef logFile) {
	key := ""
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		logFileLine := StrReplace(logFileLine, "`n", "")
		if (logFileLine != "") {
			key := logFileLine
		} else {
			ErrorBox(A_ThisFunc, "Blank line encountered when attempting to read the next custom JS"
. " file name in the log. Aborting further reading of log.")
		}
	}
	return key
}

;   ································································································
;     >>> §3.4: ReadPrimaryMsgForCustomJsFileKey

ReadPrimaryMsgForCustomJsFileKey(ByRef logFile, ByRef custonJsMsgArray, key) {
	success := false
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		logFileLine := StrReplace(logFileLine, "`n", "")
		if (logFileLine != "") {
			success := true
			custonJsMsgArray[key] := Object()
			custonJsMsgArray[key].primary := logFileLine
		}
	}
	return success
}

;   ································································································
;     >>> §3.5: ReadSecondaryMsgForCustomJsFileKey

ReadSecondaryMsgForCustomJsFileKey(ByRef logFile, ByRef custonJsMsgArray, key) {
	success := false
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		success := true
		logFileLine := StrReplace(logFileLine, "`n", "")
		custonJsMsgArray[key].secondary := logFileLine
	}
	return success
}
