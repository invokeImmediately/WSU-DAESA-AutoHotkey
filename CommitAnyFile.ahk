; ===========================================================================================================================
; GUI FOR COMMITTING CSS BUILDS & ASSOCIATED SITE-SPECIFIC CUSTOM LESS FILES
; ===========================================================================================================================
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ===========================================================================================================================

:*:@gcAnyFile::
	ahkCmdName := ":*:@gcAnyFile"
	AppendAhkCmd(ahkCmdName)
	FileSelectFile, fnFileToCommit, 1, , % "Select a file to be committed."
	if (fnFileToCommit) {
		; Extract file path from output
		filePathEndPos := RegExMatch(fnFileToCommit, "\\(?![A-Za-z0-9\-\.'^()]*\\)")
		fpGitfolder := SubStr(fnFileToCommit, 1, filePathEndPos)
		fnFileToCommit := SubStr(fnFileToCommit, filePathEndPos + 1)
		
		; Verify that the file is contained within a valid git folder
		gitFolderPos := (fpGitFolder = GetGitHubFolder() . "\")
			? 0
			: InStr(fpGitFolder, GetGitHubFolder())
		if (gitFolderPos) {
			CommitAnyFile(ahkCmdName, fpGitFolder, fnFileToCommit)
		} else {
			ErrorBox(ahkCmdName, "Unfortunately, you did not select a file contained within a valid git "
				. "repository folder. Canceling hotkey; please try again.")
		}
		; Proceed with git commit interface
	}
Return

; Sets up a GUI to automate committing of CSS build files.
CommitAnyFile(ahkCmdName, fpGitFolder, fnFileToCommit) {
	; Global variable declarations
	global commitAnyFileVars := Object()
	global commitAnyFileLastMsg
	global ctrlCommitAnyFile1stMsg
	global ctrlCommitAnyFile1stMsgCharCount
	global ctrlCommitAnyFile2ndMsg
	global ctrlCommitAnyFile2ndMsgCharCount
	
	; Variable initializations
	commitAnyFileVars.ahkCmdName := ahkCmdName
	commitAnyFileVars.fpGitFolder := fpGitFolder
	commitAnyFileVars.fnFileToCommit := fnFileToCommit
	lastAnyFileMsg1st := ""
	msgLenAnyFile1st := 0
	lastAnyFileMsg2nd := ""
	msgLenAnyFile2nd := 0
	if (commitAnyFileLastMsg != undefined) {
		lastMsgs := commitAnyFileLastMsg[commitAnyFileVars.fpGitFolder . commitAnyFileVars.fnFileToCommit]
		if (lastMsgs != undefined) {
			lastAnyFileMsg1st := lastMsgs.primary
			msgLenAnyFile1st := StrLen(lastAnyFileMsg1st)
			lastAnyFileMsg2nd := lastMsgs.secondary
			msgLenAnyFile2nd := StrLen(lastAnyFileMsg2nd)
		}
	}
	
	; GUI initialization & display to user
	Gui, guiCommitAnyFile: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCommitAnyFile: Font, bold
	Gui, guiCommitAnyFile: Add, Text, , % "File to be committed: "
	Gui, guiCommitAnyFile: Font
	Gui, guiCommitAnyFile: Add, Text, Y+1, % commitAnyFileVars.fpGitFolder . commitAnyFileVars.fnFileToCommit
	Gui, guiCommitAnyFile: Font, bold
	Gui, guiCommitAnyFile: Add, Text, Y+12, % "Message(s) to be used for commit: "
	Gui, guiCommitAnyFile: Font
	Gui, guiCommitAnyFile: Add, Text, Y+3, % "&Primary commit message:"
	Gui, guiCommitAnyFile: Add, Edit, vctrlCommitAnyFile1stMsg gHandleCommitAnyFile1stMsgChange X+5 W606, % lastAnyFileMsg1st
	Gui, guiCommitAnyFile: Add, Text, vctrlCommitAnyFile1stMsgCharCount Y+1 W500, % "Length = " . msgLenAnyFile1st . " characters"
	Gui, guiCommitAnyFile: Add, Text, xm Y+12, % "&Secondary commit message:"
	Gui, guiCommitAnyFile: Add, Edit, vctrlCommitAnyFile2ndMsg gHandleCommitAnyFile2ndMsgChange X+5 W589, % lastAnyFileMsg2nd
	Gui, guiCommitAnyFile: Add, Text, vctrlCommitAnyFile2ndMsgCharCount Y+1 W500, % "Length = " . msgLenAnyFile2nd . " characters"
	Gui, guiCommitAnyFile: Add, Button, Default gHandleCommitAnyFileOk xm, &Ok
	Gui, guiCommitAnyFile: Add, Button, gHandleCommitAnyFileCancel X+5, &Cancel
	Gui, guiCommitAnyFile: Show
}


; Triggered when the primary git commit message for the selected file is changed.
HandleCommitAnyFile1stMsgChange() {
	; Make global variable declarations.
	global ctrlCommitAnyFile1stMsg
	global ctrlCommitAnyFile1stMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitAnyFile: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitAnyFile1stMsg)
	GuiControl, , ctrlCommitAnyFile1stMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered when the secondary git commit message for the selected file is changed.
HandleCommitAnyFile2ndMsgChange() {
	; Make global variable declarations.
	global ctrlCommitAnyFile2ndMsg
	global ctrlCommitAnyFile2ndMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitAnyFile: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitAnyFile2ndMsg)
	GuiControl, , ctrlCommitAnyFile2ndMsgCharCount, % "Length = " . msgLen . " characters"
}


; Triggered by OK button in guiCommitAnyFile GUI.
HandleCommitAnyFileOk() {
	global commitAnyFileVars
	global commitAnyFileLastMsg
	global ctrlCommitAnyFile1stMsg
	global ctrlCommitAnyFile2ndMsg
	
	; Submit GUI to finalize variables storing user input.
	Gui, guiCommitAnyFile: Submit, NoHide
	
	; Ensure that state of global variables is consistent with a valid GUI submission.
	gVarCheck := commitAnyFileVars.ahkCmdName == undefined
	gVarCheck := (gVarCheck << 1) | (commitAnyFileVars.fpGitFolder == undefined)
	gVarCheck := (gVarCheck << 1) | (commitAnyFileVars.fnFileToCommit == undefined)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitAnyFile1stMsg == undefined)

	if (!gVarCheck) {
		; Close the GUI since the condition of our variables passed muster.
		Gui, guiCommitAnyFile: Destroy
		
		; Build the command line inputs for commiting the code to the appropriate git repository.
		commandLineInput := "cd """ . commitAnyFileVars.fpGitFolder . """`r"
			. "git add " . commitAnyFileVars.fnFileToCommit . "`r"
			. "git commit -m """ . ctrlCommitAnyFile1stMsg . """"
		if (ctrlCommitAnyFile2ndMsg != "") {
			commandLineInput .= " -m """ . ctrlCommitAnyFile2ndMsg . """ `r"
		} else {
			commandLineInput .= "`r"
		}
		commandLineInput .= "git push`r"

		; Store commit for later use as a guide
		if (commitAnyFileLastMsg == undefined) {
			commitAnyFileLastMsg := Object()
		}
		key := commitAnyFileVars.fpGitFolder . commitAnyFileVars.fnFileToCommit
		commitAnyFileLastMsg[key] := Object()
		commitAnyFileLastMsg[key].primary := ctrlCommitAnyFile1stMsg
		commitAnyFileLastMsg[key].secondary := ctrlCommitAnyFile2ndMsg
		commandLineInput .= "[console]::beep(2000,150)`r"
			. "[console]::beep(2000,150)`r"

		; Paste the code into the command console.
		PasteTextIntoGitShell(commitAnyFileVars.ahkCmdName, commandLineInput)
	} else {
		; Determine what went wrong, notify user, and handle accordingly.
		ProcessHandleCommitAnyFileOkError(gVarCheck)
	}
}

; Called by HandleCommitAnyFileOk() to handle error processing.
ProcessHandleCommitAnyFileOkError(gVarCheck) {
	functionName := "CommitAnyFile.ahk / ProcessHandleCommitAnyFileOk()"
	if (gVarCheck == 1) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the LESS source file.")
	} else {
		Gui, guiCommitAnyFile: Destroy
		ErrorBox(functionName
			, "An undefined global variable was encountered; function terminating. Variable checking bitmask "
			. "was equal to " . gVarCheck . ".")
	}
}

; Triggered by Cancel button in guiCommitAnyFile GUI.
HandleCommitAnyFileCancel() {
	Gui, guiCommitAnyFile: Destroy
}

; Used to grant permanence to commit message history functionality between scripting sessions
SaveCommitAnyFileMsgHistory() {
	global commitAnyFileLastMsg
	global commitAnyFileMsgLog

	if (commitAnyFileLastMsg != undefined) {
		logFile := FileOpen(commitAnyFileMsgLog, "w `n")
		if (logFile) {
			For key, value in commitAnyFileLastMsg {
				numBytes := logFile.WriteLine(key)
				if (numBytes) {
					numBytes := logFile.WriteLine(value.primary)
					if (numBytes) {
						numBytes := logFile.WriteLine(value.secondary)
						if (!numBytes) {
							ErrorBox(A_ThisFunc, "Could not write the secondary commit message for " . key
								. ".")
						}
					} else {
						ErrorBox(A_ThisFunc, "Could not write the primary commit message for " . key . ".")
					}
				} else {
					ErrorBox(A_ThisFunc, "Could not record the next LESS file name, " . key . ".")
				}				
			}
			logFile.Close()
		} else {
			ErrorBox(A_ThisFunc, "Could not open any file commit message history log file '"
				. commitAnyFileMsgLog . "'. Error code reported by FileOpen: '" . A_LastError . "'")
		}
	}
}

LoadCommitAnyFileMsgHistory() {
	; TODO: Rewrite code below
	global commitAnyFileLastMsg
	global commitAnyFileMsgLog

	if (commitAnyFileLastMsg == undefined) {
		commitAnyFileLastMsg := Object()
	}
	
	logFile := FileOpen(commitAnyFileMsgLog, "r `n")
	if (logFile) {
		Loop {
			key := ReadKeyForAnyFileCommitMsgHistory(logFile)
			if (key == "") {
				break
			} else {
				if (!ReadPrimaryCommitMsgForFileKey(logFile, commitAnyFileLastMsg, key)) {
					ErrorBox(A_ThisFunc, "Log file abruptly stopped after reading a file key. Aborting "
						. "further reading of log.")
					break
				} else if(!ReadSecondaryCommitMsgForFileKey(logFile, commitAnyFileLastMsg, key)) {
					ErrorBox(A_ThisFunc, "Log file abruptly stopped after reading a file key and "
						. "primary git commit message. Aborting further reading of log.")
					break
				}
			}
		}
		logFile.Close()
	} else {
		ErrorBox(A_ThisFunc, "Could not open commit message history log file '" . commitAnyFileMsgLog
			. "'. Error code reported by FileOpen: '" . A_LastError . "'")
	}
}

ReadKeyForAnyFileCommitMsgHistory(ByRef logFile) {
	key := ""
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		logFileLine := StrReplace(logFileLine, "`n", "")
		if (logFileLine != "") {
			key := logFileLine
		} else {
			ErrorBox(A_ThisFunc, "Blank line encountered when attempting to read the next file path in "
				. "the log. Aborting further reading of log.")
		}
	}
	return key
}

ReadPrimaryCommitMsgForFileKey(ByRef logFile, ByRef commitMsgArray, key) {
	success := false
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		logFileLine := StrReplace(logFileLine, "`n", "")
		if (logFileLine != "") {
			success := true
			commitMsgArray[key] := Object()
			commitMsgArray[key].primary := logFileLine
		}
	}
	return success
}

ReadSecondaryCommitMsgForFileKey(ByRef logFile, ByRef commitMsgArray, key) {
	success := false
	logFileLine := logFile.ReadLine()
	if (logFileLine != "") {
		success := true
		logFileLine := StrReplace(logFileLine, "`n", "")
		commitMsgArray[key].secondary := logFileLine
	}
	return success
}
