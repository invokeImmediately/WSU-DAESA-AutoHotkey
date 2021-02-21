; ==================================================================================================
; ▄▀▀▀ ▄▀▀▄ ▐▀▄▀▌▐▀▄▀▌▀█▀▐▀█▀▌▄▀▀▄ ▐▀▀▄ █  █ █▀▀▀ ▀█▀ █    █▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; █    █  █ █ ▀ ▌█ ▀ ▌ █   █  █▄▄█ █  ▐ ▀▄▄█ █▀▀▀  █  █  ▄ █▀▀    █▄▄█ █▀▀█ █▀▄  
;  ▀▀▀  ▀▀  █   ▀█   ▀▀▀▀  █  █  ▀ ▀  ▐ ▄▄▄▀ ▀    ▀▀▀ ▀▀▀  ▀▀▀▀ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Creates a GUI to support the committing any type of file to a git repository.
;
; @version 1.0.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/master…→
;   ←…/GitHub/CommitAnyFile.ahk
; @license MIT Copyright (c) 2021 Daniel C. Rieck.
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;     and associated documentation files (the “Software”), to deal in the Software without
;     restriction, including without limitation the rights to use, copy, modify, merge, publish,
;     distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;     Software is furnished to do so, subject to the following conditions:
;   The above copyright notice and this permission notice shall be included in all copies or
;     substantial portions of the Software.
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;     BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;     DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================
; Table of Contents:
; -----------------
;   §1: GUI triggering hotstring................................................................54
;     >>> §1.1: @gcAnyFile......................................................................58
;     >>> §1.2: gcAnyFile_GetRepoPath..........................................................107
;       →→→ §1.2.1: gcAnyFile_GetRepoPath_PowerShell...........................................122
;       →→→ §1.2.2: gcAnyFile_GetRepoPath_ST3..................................................139
;   §2: GUI supporting functions...............................................................158
;     >>> §2.1: CAF_CommitAnyFile..............................................................162
;     >>> §2.2: HandleCafAddFiles..............................................................251
;     >>> §2.3: HandleCafRemoveFiles...........................................................308
;     >>> §2.4: HandleCafGitDiff...............................................................360
;     >>> §2.5: HandleCafGitLog................................................................397
;     >>> §2.6: HandleCaf1stMsgChange..........................................................438
;     >>> §2.7: HandleCaf2ndMsgChange..........................................................456
;     >>> §2.8: HandleCafOk....................................................................470
;     >>> §2.9: CheckAnyFilePrimaryMsgChanged..................................................541
;     >>> §2.10: ProcessHandleCafOkError.......................................................566
;     >>> §2.11: HandleCafCancel...............................................................593
;     >>> §2.12: SaveCafMsgHistory.............................................................602
;     >>> §2.13: LoadCafMsgHistory.............................................................644
;     >>> §2.14: ReadKeyForAnyFileCommitMsgHistory.............................................692
;     >>> §2.15: ReadPrimaryCommitMsgForFileKey................................................719
;     >>> §2.16: ReadPrimaryCommitMsgForFileKey................................................738
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GUI triggering hotstring
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: @gcAnyFile

:*?:@gcAnyFile::
	AppendAhkCmd( A_ThisLabel )
	subFolder := ""
	gitFolderLen := StrLen( GetGitHubFolder() . "\" )
	path := gcAnyFile_GetRepoPath()
	if ( path != "" ) {
		FileSelectFile, selectedFiles, M3, %path%, % "Select (a) file(s) to be committed."
	} else {
		FileSelectFile, selectedFiles, M3, , % "Select (a) file(s) to be committed."
	}
	if ( selectedFiles != "" ) {
		filesToCommit := Object()
		Loop, Parse, selectedFiles, `n
		{
			if ( a_index = 1 ) {
				gitFolder := A_LoopField . "\"
				if ( InStr( gitFolder, GetGitHubFolder() . "\" ) ) {
					subFolder := SubStr( gitFolder, gitFolderLen + 1 )
				}
				if ( StrLen( subFolder ) ) {
					subFolderPos := InStr( subFolder, "\" )
					gitFolder := SubStr( gitFolder, 1, gitFolderLen + subFolderPos )
					subFolder := SubStr( subFolder, subFolderPos + 1 )
				}
			} else {
				filesToCommit.Push( subFolder . A_LoopField )
			}
		}

		; Verify that the file is contained within a valid git repository
		isGitFolder := ( gitFolder = GetGitHubFolder() . "\" )
			? 0
			: InStr( gitFolder, GetGitHubFolder() )
		if ( isGitFolder ) {
			; Adjust folders
			CAF_CommitAnyFile( A_ThisLabel, gitFolder, filesToCommit )
		} else {
			ErrorBox( ahkCmdName, 
( Join
"Unfortunately, you did not select a file contained within a valid git repository folder. Canceling 
hotkey; please try again."
) )
		}
	}
Return

;   ································································································
;     >>> §1.2: gcAnyFile_GetRepoPath
;
;	If applicable, get the current path that the user is working in.

gcAnyFile_GetRepoPath() {
	path := ""
	if ( IsGitShellActive() ) {
		path := gcAnyFile_GetRepoPath_PowerShell()
	} else if ( isTargetProcessActive( "sublime_text.exe" ) ) {
		path := gcAnyFile_GetRepoPath_ST3()
	}
	return path
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.1: gcAnyFile_GetRepoPath_PowerShell
;
;	Get the active repository's path from within PowerShell using the clipboard.

gcAnyFile_GetRepoPath_PowerShell() {
	global execDelayer

	SendInput, % "{Esc}"
	execDelayer.Wait( "m" )
	consoleStr := "Set-Clipboard(Get-Item -Path "".\"").FullName`r"
	PasteTextIntoGitShell( A_ThisLabel, consoleStr )
	execDelayer.Wait( "m" )

	return Clipboard
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.2: gcAnyFile_GetRepoPath_ST3
;
;	Get the active repository's path from within Sublime Text 3 using the clipboard.

gcAnyFile_GetRepoPath_ST3() {
	global execDelayer

	keyDelay := execDelayer.InterpretDelayString( "xs" )
	oldKeyDelay := A_KeyDelay
	SetKeyDelay, %keyDelay%
	Send, % "^+p{Backspace}Copy File Path{Enter}"
	execDelayer.Wait( "m" )
	path := Clipboard
	SetKeyDelay, %oldKeyDelay%

	return path
}

; --------------------------------------------------------------------------------------------------
;   §2: GUI supporting functions
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: CAF_CommitAnyFile
;
;   Build and display a GUI for automating the committing of changed files to git through
;   Powershell.
;
;   The GUI allows the user to select multiple files within a git repository, which are later
;   processed into one or more 'git add …' shell commands. Primary and secondary git commit messages
;   can also be set, and the GUI displays the length of each message. These messages are later
;   processed into a 'git commit -m "…" (-m "…")' command. Moreover, the previous git commit message
;   for a file is remembered by the GUI on future commits.
;
;   @param {string}			ahkCmdName		The hotstring/label that called the function.
;   @param {string}			gitFolder		File system folder containing the local git repo.
;   @param {simple array}	filesToCommit	Array of files to be committed.

CAF_CommitAnyFile( ahkCmdName, gitFolder, filesToCommit ) {
	global cafVars := Object()
	global cafLastMsg
	global ctrlCafLV
	global ctrlCaf1stMsg
	global ctrlCaf1stMsgCharCount
	global ctrlCaf2ndMsg
	global ctrlCaf2ndMsgCharCount

	; Variable initialization section
	cafVars.ahkCmdName := ahkCmdName
	cafVars.gitFolder := gitFolder
	cafVars.filesToCommit := filesToCommit
	cafVars.primaryMsgChanged := false
	lastAnyFileMsg1st := ""
	msgLenAnyFile1st := 0
	lastAnyFileMsg2nd := ""
	msgLenAnyFile2nd := 0
	if ( cafLastMsg != undefined ) {
		lastMsgs := cafLastMsg[cafVars.gitFolder 
			. cafVars.filesToCommit[1]]
		if ( lastMsgs != undefined ) {
			lastAnyFileMsg1st := lastMsgs.primary
			msgLenAnyFile1st := StrLen( lastAnyFileMsg1st )
			lastAnyFileMsg2nd := lastMsgs.secondary
			msgLenAnyFile2nd := StrLen( lastAnyFileMsg2nd )
		}
	}

	; Begin initialization of GUI
	Gui, guiCaf: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCaf: Font, italic
	Gui, guiCaf: Add, Text, Y+3, % "Git folder: "
	Gui, guiCaf: Font
	Gui, guiCaf: Add, Text, X+3, % cafVars.gitFolder
	Gui, guiCaf: Font, bold
	Gui, guiCaf: Add, Text, xm, % "&File(s) to be committed: "
	Gui, guiCaf: Font
	Gui, guiCaf: Add, ListView
		, vctrlCafLV grid BackgroundEBF8FE NoSortHdr r5 W728 xm+1 Y+3
		, % "File Name"

	; Add files to be committed to ListView control
	fileCount := cafVars.filesToCommit.Length()
	Loop, %fileCount%
	{
		LV_Add( , cafVars.filesToCommit[A_Index] )
	}

	;Continue adding controls to GUI
	Gui, guiCaf: Add, Button, gHandleCafAddFiles xm Y+3, &Add More Files
	Gui, guiCaf: Add, Button, gHandleCafRemoveFiles X+5, &Remove File( s )
	Gui, guiCaf: Add, Button, gHandleCafGitDiff X+5, &Git diff selection
	Gui, guiCaf: Add, Button, gHandleCafGitLog X+5, Git &log selection
	Gui, guiCaf: Font, bold
	Gui, guiCaf: Add, Text, xm Y+12, % "Message(s) to be used for commit: "
	Gui, guiCaf: Font
	Gui, guiCaf: Add, Text, Y+3, % "&Primary commit message:"
	Gui, guiCaf: Add, Edit
		, vctrlCaf1stMsg gHandleCaf1stMsgChange X+5 W606, % lastAnyFileMsg1st
	Gui, guiCaf: Add, Text, vctrlCaf1stMsgCharCount Y+1 W500
		, % "Length = " . msgLenAnyFile1st . " characters"
	Gui, guiCaf: Add, Text, xm Y+12, % "&Secondary commit message:"
	Gui, guiCaf: Add, Edit
		, vctrlCaf2ndMsg gHandleCaf2ndMsgChange X+5 W589, % lastAnyFileMsg2nd
	Gui, guiCaf: Add, Text, vctrlCaf2ndMsgCharCount Y+1 W500
		, % "Length = " . msgLenAnyFile2nd . " characters"
	Gui, guiCaf: Add, Button, Default gHandleCafOk xm, &Ok
	Gui, guiCaf: Add, Button, gHandleCafCancel X+5, &Cancel
	Gui, guiCaf: Default
	Gui, guiCaf: Show
}

;   ································································································
;     >>> §2.2: HandleCafAddFiles
;
;   Function handler for activation of the button used to add more files to be committed.

HandleCafAddFiles() {
	global cafVars
	FileSelectFile, selectedFiles, M3, , % "Select (a) file(s) to be committed."
	if ( selectedFiles != "" ) {
		newFilesToCommit := Object()
		Loop, Parse, selectedFiles, `n
		{
			if ( a_index = 1 ) {
				gitSubFolder := A_LoopField . "\"
			} else {
				newFilesToCommit.Push( A_LoopField )
			}
		}

		; Verify that we are in a sub folder of the original git folder
		posWhereFound := InStr( gitSubFolder, cafVars.gitFolder )
		if ( posWhereFound ) {

			; Remove the root folder path from the subfolder path, leaving a relative path
			gitSubFolder := StrReplace( gitSubFolder, cafVars.gitFolder, "" )

			; Ensure the proper GUI is default to LV_Add function works as expected
			Gui, guiCaf: Default

			fileCount := newFilesToCommit.Length()
			Loop, %fileCount%
			{
				fileAlreadyPresent := False
				outerIdx := A_Index
				Loop % LV_GetCount()
				{
					LV_GetText( retrievedFile, A_Index )
					if ( retrievedFile == gitSubFolder . newFilesToCommit[outerIdx] ) {
						fileAlreadyPresent := True
					}
				}
				if ( !fileAlreadyPresent ) {
					( cafVars.filesToCommit ).Push( gitSubFolder . newFilesToCommit[A_Index] )
					LV_Add( , gitSubFolder . newFilesToCommit[A_Index] )
				}
			}

		} else {
			ErrorBox( A_ThisFunc, "
( Join
Unfortunately, you did not select files contained within the root folder of the git repository you p
reviously selected. Please try again.
)" )
		}
	}
}

;   ································································································
;     >>> §2.3: HandleCafRemoveFiles
;
;   Function handler for activation of the button used to remove selected files to be committed.

HandleCafRemoveFiles() {
	global cafVars
	global execDelayer

	; Make sure the user doesn't try to remove all files.
	numRows := LV_GetCount()
	triedToRemoveAllFiles := False
	if ( numRows > 1 ) {
		numSelectedRows := LV_GetCount( "Selected" )
		if ( numSelectedRows < numRows ) {
			rowNumber := 1
			Loop
			{
				rowNumber := LV_GetNext( rowNumber - 1 )
				if ( rowNumber ) {
					LV_GetText( removedFile, rowNumber )
					LV_Delete( rowNumber )
					numFilesLeft := cafVars.filesToCommit.Length()
					Loop % numFilesLeft
					{
						if ( cafVars.filesToCommit[A_Index] == removedFile ) {
							cafVars.filesToCommit.RemoveAt( A_Index )
							break
						}
					}
					execDelayer.Wait( "s" )
				} else {
					break
				}
			}
		} else {
			triedToRemoveAllFiles := True
		}
	} else {
		triedToRemoveAllFiles := True
	}

	; If necessary, inform the user that removal of all files from the list view is not permitted.
	if ( triedToRemoveAllFiles ) {
			ErrorBox( A_ThisFunc, 
( Join
"Unfortunately, I cannot remove the file(s); at least one file must be entered for the commit proces
s."
) )
	}
}

;   ································································································
;     >>> §2.4: HandleCafGitDiff
;
;   Function handler for activation of the button used to perform a git diff command on selected
;   files.

HandleCafGitDiff() {
	global cafVars
	global execDelayer

	numSelectedRows := LV_GetCount( "Selected" )
	consoleStr := "cd " . cafVars.gitFolder . "`r"
	if ( numSelectedRows > 0 ) {
		rowNumber := 0
		Loop
		{
			rowNumber := LV_GetNext( rowNumber )
			if ( rowNumber ) {
				LV_GetText( fileName, rowNumber )
				consoleStr .= "git --no-pager diff " . fileName . "`r"
				execDelayer.Wait( "xs" )
			} else {
				break
			}
		}		
	} else {
		rowNumber := 1
		numRows := LV_GetCount()
		while ( rowNumber <= numRows ) {
			LV_GetText( fileName, rowNumber )
			consoleStr .= "git --no-pager diff " . fileName . "`r"
			rowNumber++
		}
	}
	PasteTextIntoGitShell( A_ThisLabel, consoleStr )
}

;   ································································································
;     >>> §2.5: HandleCafGitLog
;
;   Function handler for activation of the button used to perform a git log command on selected
;   files.

HandleCafGitLog() {
	global cafVars
	global execDelayer

	cmdStr :=
( Join
"git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s%n  ╘═> %b"" --max-count=20 "
)
	numSelectedRows := LV_GetCount( "Selected" )
	consoleStr := "cd " . cafVars.gitFolder . "`r"
	if ( numSelectedRows > 0 ) {
		rowNumber := 0
		Loop
		{
			rowNumber := LV_GetNext( rowNumber )
			if ( rowNumber ) {
				LV_GetText( fileName, rowNumber )
				consoleStr .= cmdStr . fileName . "`r"
				execDelayer.Wait( "s" )
			} else {
				break
			}
		}
	} else {
		rowNumber := 1
		numRows := LV_GetCount()
		while ( rowNumber <= numRows ) {
			LV_GetText( fileName, rowNumber )
			consoleStr .= cmdStr . fileName . "`r"
			rowNumber++
		}
	}
	PasteTextIntoGitShell( A_ThisLabel, consoleStr )
}

;   ································································································
;     >>> §2.6: HandleCaf1stMsgChange
;
;   Function handler for changes to the primary git commit message for the selected file(s).

HandleCaf1stMsgChange() {
	global cafVars
	global ctrlCaf1stMsg
	global ctrlCaf1stMsgCharCount

	if ( cafVars.primaryMsgChanged != True ) {
		cafVars.primaryMsgChanged := True
	}
	Gui, guiCaf: Submit, NoHide
	msgLen := StrLen( ctrlCaf1stMsg )
	GuiControl, , ctrlCaf1stMsgCharCount, % "Length = " . msgLen . " characters"
}

;   ································································································
;     >>> §2.7: HandleCaf2ndMsgChange
;
;   Function handler for changes to the secondary git commit message for the selected file(s).

HandleCaf2ndMsgChange() {
	global ctrlCaf2ndMsg
	global ctrlCaf2ndMsgCharCount

	Gui, guiCaf: Submit, NoHide
	msgLen := StrLen( ctrlCaf2ndMsg )
	GuiControl, , ctrlCaf2ndMsgCharCount, % "Length = " . msgLen . " characters"
}

;   ································································································
;     >>> §2.8: HandleCafOk
;
;   Function handler for activation of the 'OK' button.

HandleCafOk() {
	global cafVars
	global cafLastMsg
	global ctrlCaf1stMsg
	global ctrlCaf2ndMsg

	; Submit GUI to finalize variables storing user input
	Gui, guiCaf: Submit, NoHide

	; Ensure that state of global variables is consistent with a valid GUI submission
	gVarCheck := cafVars.ahkCmdName == undefined
	gVarCheck := ( gVarCheck << 1 ) | ( cafVars.gitFolder == undefined )
	gVarCheck := ( gVarCheck << 1 ) | ( cafVars.filesToCommit == undefined )
	gVarCheck := ( gVarCheck << 1 ) | ( ctrlCaf1stMsg == undefined )

	if ( !gVarCheck && CheckAnyFilePrimaryMsgChanged() ) {
		commitMsgTxt := """" . ctrlCaf1stMsg . """"
		if ( ctrlCaf2ndMsg ) {
			commitMsgTxt .= "`n`nSECONDARY MESSAGE:`n""" . ctrlCaf2ndMsg . """"
		}
		MsgBox, 4, % "Ready to Proceed?",
( Join
% "Are you sure you want to commit with the message:`n`nPRIMARY MESSAGE:`n"
) . commitMsgTxt 
		IfMsgBox, Yes
		{

			; Close the GUI since the condition of our variables passed muster
			Gui, guiCaf: Destroy

			; Build the command line inputs for commiting the code to the appropriate git repository
			commandLineInput := "cd '" . cafVars.gitFolder . "'`r"
			Loop % cafVars.filesToCommit.Length()
				commandLineInput .= "git add " . cafVars.filesToCommit[A_Index] . "`r"
			escaped1stMsg := EscapeCommitMessage( ctrlCaf1stMsg )
			commandLineInput .= "git commit -m """ . escaped1stMsg . """"
			if ( ctrlCaf2ndMsg != "" ) {
				escaped2ndMsg := EscapeCommitMessage( ctrlCaf2ndMsg )
				commandLineInput .= " -m """ . escaped2ndMsg . """ `r"
			} else {
				commandLineInput .= "`r"
			}

			; Store commit for later use as a guide
			if ( cafLastMsg == undefined ) {
				cafLastMsg := Object()
			}
			Loop % cafVars.filesToCommit.Length()
			{
				key := cafVars.gitFolder . cafVars.filesToCommit[A_Index]
				cafLastMsg[key] := Object()
				cafLastMsg[key].primary := ctrlCaf1stMsg
				cafLastMsg[key].secondary := ctrlCaf2ndMsg
			}
			commandLineInput .= "[console]::beep(2000,150)`r[console]::beep(2000,150)`r"

			; Paste the code into the command console.
			PasteTextIntoGitShell( cafVars.ahkCmdName, commandLineInput )
		}
	} else {

		; Determine what went wrong, notify user, and handle accordingly.
		ProcessHandleCafOkError( gVarCheck )
	}
}

;   ································································································
;     >>> §2.9: CheckAnyFilePrimaryMsgChanged
;
;   Quality control function to prevent accidentally repeated git commits.
;
;   Ensures that the user is aware that the primary commit message was left unchanged compared to
;   the previous commit for the selected file(s). Since it is possible that this was intended, the
;   user has an opportunity to allow the commit to be posted.

CheckAnyFilePrimaryMsgChanged() {
	global cafVars
	proceed := cafVars.primaryMsgChanged
	if ( !proceed ) {
		MsgBox, 4, % "Are You Sure?", % "
( Join
I noticed you didn't change the primary commit message. Do you still want to proceed?
)"
		IfMsgBox, Yes
		{
			proceed := True
		}
	}
	return proceed
}

;   ································································································
;     >>> §2.10: ProcessHandleCafOkError
;
;	Called by the HandleCafOk function to handle error processing.
;
;   @param {bitmask}	gVarCheck		Represents the correctness of global variables associated
;   									with the GUI.

ProcessHandleCafOkError( gVarCheck ) {
	functionName := "Caf.ahk / ProcessHandleCafOk()"
	if ( gVarCheck == 1 ) {
		ErrorBox( functionName
			,
( Join
"Please enter a primary git commit message regarding changes in the LESS source file."
) )
	} else if ( gVarCheck != 0 ) {
		Gui, guiCaf: Destroy
		ErrorBox( functionName
			,
( Join 
"An undefined global variable was encountered; function terminating. Variable checking bitmask was e
qual to "
) . gVarCheck . "." )
	}
}

;   ································································································
;     >>> §2.11: HandleCafCancel
;
;	Function handler for activation of the GUI's "Cancel" button.

HandleCafCancel() {
	Gui, guiCaf: Destroy
}

;   ································································································
;     >>> §2.12: SaveCafMsgHistory
;
;	Record git commit messages so they are remembered between scripting sessions.
;
;   Specifically, this function stores the associative array of previous commit messages to a log
;   file.

SaveCafMsgHistory() {
	global cafLastMsg
	global commitAnyFileMsgLog

	if ( cafLastMsg != undefined ) {
		logFile := FileOpen( commitAnyFileMsgLog, "w `n" )
		if ( logFile ) {
			For key, value in cafLastMsg {
				numBytes := logFile.WriteLine( key )
				if ( numBytes ) {
					numBytes := logFile.WriteLine( value.primary )
					if ( numBytes ) {
						numBytes := logFile.WriteLine( value.secondary )
						if ( !numBytes ) {
							ErrorBox( A_ThisFunc, "Could not write the secondary commit message for "
								. key . "." )
						}
					} else {
						ErrorBox( A_ThisFunc, "Could not write the primary commit message for "
							. key . "." )
					}
				} else {
					ErrorBox( A_ThisFunc, "Could not record the next LESS file name, " . key . "." )
				}
			}
			logFile.Close()
		} else {
			ErrorBox( A_ThisFunc, "Could not open any file commit message history log file '"
				. commitAnyFileMsgLog . "'. Error code reported by FileOpen: '" . A_LastError
				. "'" )
		}
	}
}

;   ································································································
;     >>> §2.13: LoadCafMsgHistory
;
;	Load git commit messages recorded from previous scripting sessions.

LoadCafMsgHistory() {
	; TODO: Rewrite code below to avoid wiping out the log if an error occurs; e.g., can use a 
	; global variable:
	; global cafLogLoadError := false

	global cafLastMsg
	global commitAnyFileMsgLog

	if ( cafLastMsg == undefined ) {
		cafLastMsg := Object()
	}

	logFile := FileOpen( commitAnyFileMsgLog, "r `n" )
	if ( logFile ) {
		Loop {
			key := ReadKeyForAnyFileCommitMsgHistory( logFile )
			if ( key == "" ) {
				break
			} else {
				if ( !ReadPrimaryCommitMsgForFileKey( logFile, cafLastMsg, key ) ) {
					ErrorBox( A_ThisFunc,
( Join
"Log file abruptly stopped after reading a file key. Aborting further reading of log."
) )
					break
				} else if( !ReadSecondaryCommitMsgForFileKey( logFile, cafLastMsg, key ) ) {
					ErrorBox( A_ThisFunc,
( Join
"Log file abruptly stopped after reading a file key and primary git commit message. Aborting further
 reading of log."
) )
					break
				}
			}
		}
		logFile.Close()
	} else {
		ErrorBox( A_ThisFunc, "Could not open commit message history log file '" 
			. commitAnyFileMsgLog . "'. Error code reported by FileOpen: '" . A_LastError . "'" )
	}

}

;   ································································································
;     >>> §2.14: ReadKeyForAnyFileCommitMsgHistory
;
;   Reads a key from the next line in the commit message history log file.
;
;   The key is a string containing the complete path to file. The encountering of a blank line is
;   treated as an error condition, as this would otherwise result in a nonsensical blank string
;   being used as a key.

ReadKeyForAnyFileCommitMsgHistory( ByRef logFile ) {
	key := ""
	logFileLine := logFile.ReadLine()
	if ( logFileLine != "" ) {
		logFileLine := StrReplace( logFileLine, "`n", "" )
		if ( logFileLine != "" ) {
			key := logFileLine
		} else {
			ErrorBox( A_ThisFunc,
( Join
"Blank line encountered when attempting to read the next file path in the log. Aborting further read
ing of log."
) )
		}
	}
	return key
}

;   ································································································
;     >>> §2.15: ReadPrimaryCommitMsgForFileKey
;
;   Reads a primary commit message from the next line in the commit message history log file.

ReadPrimaryCommitMsgForFileKey( ByRef logFile, ByRef commitMsgArray, key ) {
	success := false
	logFileLine := logFile.ReadLine()
	if ( logFileLine != "" ) {
		logFileLine := StrReplace( logFileLine, "`n", "" )
		if ( logFileLine != "" ) {
			success := true
			commitMsgArray[key] := Object()
			commitMsgArray[key].primary := logFileLine
		}
	}
	return success
}

;   ································································································
;     >>> §2.16: ReadPrimaryCommitMsgForFileKey
;
;   Reads a secondary commit message from the next line in the commit message history log file.

ReadSecondaryCommitMsgForFileKey( ByRef logFile, ByRef commitMsgArray, key ) {
	success := false
	logFileLine := logFile.ReadLine()
	if ( logFileLine != "" ) {
		success := true
		logFileLine := StrReplace( logFileLine, "`n", "" )
		commitMsgArray[key].secondary := logFileLine
	}
	return success
}
