; ==================================================================================================
; GUI FOR COMMITTING CSS BUILDS & ASSOCIATED SITE-SPECIFIC CUSTOM LESS FILES
; ==================================================================================================
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

:*:@gcAnyFile::
	AppendAhkCmd(A_ThisLabel)
	subFolder := ""
	gitFolderLen := StrLen(GetGitHubFolder() . "\")
	FileSelectFile, selectedFiles, M3, , % "Select (a) file(s) to be committed."
	if (selectedFiles != "") {
		filesToCommit := Object()
		Loop, Parse, selectedFiles, `n
		{
			if (a_index = 1) {
				gitFolder := A_LoopField . "\"
				if (InStr(gitFolder, GetGitHubFolder() . "\")) {
					subFolder := SubStr(gitFolder, gitFolderLen + 1)
				}
				if (StrLen(subFolder)) {
					subFolderPos := InStr(subFolder, "\")
					gitFolder := SubStr(gitFolder, 1, gitFolderLen + subFolderPos)
					subFolder := SubStr(subFolder, subFolderPos + 1)
				}
			} else {
				filesToCommit.Push(subFolder . A_LoopField)
			}
		}

		; Verify that the file is contained within a valid git repository
		isGitFolder := (gitFolder = GetGitHubFolder() . "\")
			? 0
			: InStr(gitFolder, GetGitHubFolder())
		if (isGitFolder) {
			; Adjust folders
			CommitAnyFile(A_ThisLabel, gitFolder, filesToCommit)
		} else {
			ErrorBox(ahkCmdName, "Unfortunately, you did not select a file contained within a "
				. "valid git repository folder. Canceling hotkey; please try again.")
		}
	}
Return

; Sets up a GUI to automate committing of CSS build files.
CommitAnyFile(ahkCmdName, gitFolder, filesToCommit) {
	global commitAnyFileVars := Object()
	global commitAnyFileLastMsg
	global ctrlCommitAnyFilesLV
	global ctrlCommitAnyFile1stMsg
	global ctrlCommitAnyFile1stMsgCharCount
	global ctrlCommitAnyFile2ndMsg
	global ctrlCommitAnyFile2ndMsgCharCount

	; Variable initialization section
	commitAnyFileVars.ahkCmdName := ahkCmdName
	commitAnyFileVars.gitFolder := gitFolder
	commitAnyFileVars.filesToCommit := filesToCommit
	commitAnyFileVars.primaryMsgChanged := false
	lastAnyFileMsg1st := ""
	msgLenAnyFile1st := 0
	lastAnyFileMsg2nd := ""
	msgLenAnyFile2nd := 0
	if (commitAnyFileLastMsg != undefined) {
		lastMsgs := commitAnyFileLastMsg[commitAnyFileVars.gitFolder 
			. commitAnyFileVars.filesToCommit[1]]
		if (lastMsgs != undefined) {
			lastAnyFileMsg1st := lastMsgs.primary
			msgLenAnyFile1st := StrLen(lastAnyFileMsg1st)
			lastAnyFileMsg2nd := lastMsgs.secondary
			msgLenAnyFile2nd := StrLen(lastAnyFileMsg2nd)
		}
	}

	; Begin initialization of GUI
	Gui, guiCommitAnyFile: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCommitAnyFile: Font, bold
	Gui, guiCommitAnyFile: Add, Text, , % "File(s) to be committed: "
	Gui, guiCommitAnyFile: Font
	Gui, guiCommitAnyFile: Font, italic
	Gui, guiCommitAnyFile: Add, Text, Y+3, % "Git folder: "
	Gui, guiCommitAnyFile: Font
	Gui, guiCommitAnyFile: Add, Text, X+3, % commitAnyFileVars.gitFolder
	Gui, guiCommitAnyFile: Add, ListView
		, vctrlCommitAnyFilesLV grid BackgroundEBF8FE NoSortHdr r5 W728 xm+1 Y+3
		, % "File Name"

	; Add files to be committed to ListView control
	fileCount := commitAnyFileVars.filesToCommit.Length()
	Loop, %fileCount%
	{
		LV_Add(, commitAnyFileVars.filesToCommit[A_Index])
	}

	;Continue adding controls to GUI
	Gui, guiCommitAnyFile: Add, Button, gHandleCommitAnyFileAddFiles xm Y+3, &Add More Files
	Gui, guiCommitAnyFile: Font, bold
	Gui, guiCommitAnyFile: Add, Text, Y+12, % "Message(s) to be used for commit: "
	Gui, guiCommitAnyFile: Font
	Gui, guiCommitAnyFile: Add, Text, Y+3, % "&Primary commit message:"
	Gui, guiCommitAnyFile: Add, Edit
		, vctrlCommitAnyFile1stMsg gHandleCommitAnyFile1stMsgChange X+5 W606, % lastAnyFileMsg1st
	Gui, guiCommitAnyFile: Add, Text, vctrlCommitAnyFile1stMsgCharCount Y+1 W500
		, % "Length = " . msgLenAnyFile1st . " characters"
	Gui, guiCommitAnyFile: Add, Text, xm Y+12, % "&Secondary commit message:"
	Gui, guiCommitAnyFile: Add, Edit
		, vctrlCommitAnyFile2ndMsg gHandleCommitAnyFile2ndMsgChange X+5 W589, % lastAnyFileMsg2nd
	Gui, guiCommitAnyFile: Add, Text, vctrlCommitAnyFile2ndMsgCharCount Y+1 W500
		, % "Length = " . msgLenAnyFile2nd . " characters"
	Gui, guiCommitAnyFile: Add, Button, Default gHandleCommitAnyFileOk xm, &Ok
	Gui, guiCommitAnyFile: Add, Button, gHandleCommitAnyFileCancel X+5, &Cancel
	Gui, guiCommitAnyFile: Default
	Gui, guiCommitAnyFile: Show
}

; Triggered when the primary git commit message for the selected file is changed by user input
HandleCommitAnyFileAddFiles() {
	global commitAnyFileVars
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
		posWhereFound := InStr(gitSubFolder, commitAnyFileVars.gitFolder)
		if (posWhereFound) {

			; Remove the root folder path from the subfolder path, leaving a relative path
			gitSubFolder := StrReplace(gitSubFolder, commitAnyFileVars.gitFolder, "")

			; Ensure the proper GUI is default to LV_Add function works as expected
			Gui, guiCommitAnyFile: Default

			fileCount := newFilesToCommit.Length()
			Loop, %fileCount%
			{
				(commitAnyFileVars.filesToCommit).Push(gitSubFolder . newFilesToCommit[A_Index])
				LV_Add(, gitSubFolder . newFilesToCommit[A_Index])
			}

		} else {
			ErrorBox(A_ThisFunc, "Unfortunately, you did not select files contained within the "
				. "root folder of the git repository you previously selected. Please try again.")
		}
	}
}

; Triggered when the primary git commit message for the selected file is changed by user input
HandleCommitAnyFile1stMsgChange() {
	global commitAnyFileVars
	global ctrlCommitAnyFile1stMsg
	global ctrlCommitAnyFile1stMsgCharCount

	if (commitAnyFileVars.primaryMsgChanged != True) {
		commitAnyFileVars.primaryMsgChanged := True
	}
	Gui, guiCommitAnyFile: Submit, NoHide
	msgLen := StrLen(ctrlCommitAnyFile1stMsg)
	GuiControl, , ctrlCommitAnyFile1stMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered when the secondary git commit message for the selected file is changed by user input
HandleCommitAnyFile2ndMsgChange() {
	global ctrlCommitAnyFile2ndMsg
	global ctrlCommitAnyFile2ndMsgCharCount

	Gui, guiCommitAnyFile: Submit, NoHide
	msgLen := StrLen(ctrlCommitAnyFile2ndMsg)
	GuiControl, , ctrlCommitAnyFile2ndMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered by activation of OK button in guiCommitAnyFile GUI
HandleCommitAnyFileOk() {
	global commitAnyFileVars
	global commitAnyFileLastMsg
	global ctrlCommitAnyFile1stMsg
	global ctrlCommitAnyFile2ndMsg

	; Submit GUI to finalize variables storing user input
	Gui, guiCommitAnyFile: Submit, NoHide

	; Ensure that state of global variables is consistent with a valid GUI submission
	gVarCheck := commitAnyFileVars.ahkCmdName == undefined
	gVarCheck := (gVarCheck << 1) | (commitAnyFileVars.gitFolder == undefined)
	gVarCheck := (gVarCheck << 1) | (commitAnyFileVars.filesToCommit == undefined)
	gVarCheck := (gVarCheck << 1) | (ctrlCommitAnyFile1stMsg == undefined)

	if (!gVarCheck && CheckAnyFilePrimaryMsgChanged()) {
		commitMsgTxt := """" . ctrlCommitAnyFile1stMsg . """"
		if (ctrlCommitAnyFile2ndMsg) {
			commitMsgTxt .= "`n`nSECONDARY MESSAGE:`n""" . ctrlCommitAnyFile2ndMsg . """"
		}
		MsgBox, 4, % "Ready to Proceed?", % "Are you sure you want to push the git commit "
			. "message:`n`nPRIMARY MESSAGE:`n" . commitMsgTxt 
		IfMsgBox, Yes
		{

			; Close the GUI since the condition of our variables passed muster
			Gui, guiCommitAnyFile: Destroy

			; Build the command line inputs for commiting the code to the appropriate git repository
			commandLineInput := "cd '" . commitAnyFileVars.gitFolder . "'`r"
			Loop % commitAnyFileVars.filesToCommit.Length()
				commandLineInput .= "git add " . commitAnyFileVars.filesToCommit[A_Index] . "`r"
			escaped1stMsg := EscapeCommitMessage(ctrlCommitAnyFile1stMsg)
			commandLineInput .= "git commit -m """ . escaped1stMsg . """"
			if (ctrlCommitAnyFile2ndMsg != "") {
				escaped2ndMsg := EscapeCommitMessage(ctrlCommitAnyFile2ndMsg)
				commandLineInput .= " -m """ . escaped2ndMsg . """ `r"
			} else {
				commandLineInput .= "`r"
			}
			commandLineInput .= "git push`r"

			; Store commit for later use as a guide
			if (commitAnyFileLastMsg == undefined) {
				commitAnyFileLastMsg := Object()
			}
			Loop % commitAnyFileVars.filesToCommit.Length()
			{
				key := commitAnyFileVars.gitFolder . commitAnyFileVars.filesToCommit[A_Index]
				commitAnyFileLastMsg[key] := Object()
				commitAnyFileLastMsg[key].primary := ctrlCommitAnyFile1stMsg
				commitAnyFileLastMsg[key].secondary := ctrlCommitAnyFile2ndMsg
			}
			commandLineInput .= "[console]::beep(2000,150)`r"
				. "[console]::beep(2000,150)`r"

			; Paste the code into the command console.
			PasteTextIntoGitShell(commitAnyFileVars.ahkCmdName, commandLineInput)

		}
	} else {

		; Determine what went wrong, notify user, and handle accordingly.
		ProcessHandleCommitAnyFileOkError(gVarCheck)

	}
}

CheckAnyFilePrimaryMsgChanged() {
	global commitAnyFileVars
	proceed := commitAnyFileVars.primaryMsgChanged
	if (!proceed) {
		MsgBox, 4, % "Are You Sure?", % "I noticed you didn't change the primary commit message. "
			. "Do you still want to proceed?"
		IfMsgBox, Yes
		{
			proceed := True
		}
	}
	return proceed
}

; Called by HandleCommitAnyFileOk() to handle error processing.
ProcessHandleCommitAnyFileOkError(gVarCheck) {
	functionName := "CommitAnyFile.ahk / ProcessHandleCommitAnyFileOk()"
	if (gVarCheck == 1) {
		ErrorBox(functionName
			, "Please enter a primary git commit message regarding changes in the LESS source "
			. "file.")
	} else if (gVarCheck != 0) {
		Gui, guiCommitAnyFile: Destroy
		ErrorBox(functionName
			, "An undefined global variable was encountered; function terminating. Variable "
			. "checking bitmask was equal to " . gVarCheck . ".")
	}
}

; Triggered by Cancel button in guiCommitAnyFile GUI.
HandleCommitAnyFileCancel() {
	Gui, guiCommitAnyFile: Destroy
}

; Record git commit messages collected through the GUI so they are remembered between scripting
; sessions
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
							ErrorBox(A_ThisFunc, "Could not write the secondary commit message for "
								. key . ".")
						}
					} else {
						ErrorBox(A_ThisFunc, "Could not write the primary commit message for "
							. key . ".")
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
	; TODO: Rewrite code below to avoid wiping out the log if an error occurs; e.g., can use a 
	; global variable:
	; global commitAnyFileLogLoadError := false

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
					ErrorBox(A_ThisFunc, "Log file abruptly stopped after reading a file key. "
						. "Aborting further reading of log.")
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
		ErrorBox(A_ThisFunc, "Could not open commit message history log file '" 
			. commitAnyFileMsgLog . "'. Error code reported by FileOpen: '" . A_LastError . "'")
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
			ErrorBox(A_ThisFunc, "Blank line encountered when attempting to read the next file "
				. "path in the log. Aborting further reading of log.")
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
