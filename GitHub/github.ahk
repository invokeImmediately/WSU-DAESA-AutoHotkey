; ==================================================================================================
; █▀▀▀ ▀█▀▐▀█▀▌█  █ █  █ █▀▀▄   ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀▄  █   █  █▀▀█ █  █ █▀▀▄   █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀ ▀▀▀  █  █  ▀  ▀▀  ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
; --------------------------------------------------------------------------------------------------
; Automate tasks for working with git in Windows 10 via PowerShell and posting code from git
;  repositories to WordPress.
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-AutoHotkey
; @license: MIT Copyright (c) 2020 Daniel C. Rieck.
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
; TABLE OF CONTENTS:
; -----------------
;   §1: SETTINGS accessed via functions for this imported file.................................138
;     >>> §1.1: GetCmdForMoveToCSSFolder.......................................................142
;     >>> §1.2: GetCurrentDirFrom..............................................................157
;     >>> §1.3: GetGitHubFolder................................................................169
;     >>> §1.4: UserFolderIsSet................................................................177
;   §2: FUNCTIONS for working with GitHub Desktop..............................................191
;     >>> §2.1: ActivateGitShell...............................................................195
;     >>> §2.2: CommitAfterBuild...............................................................233
;     >>> §2.3: EscapeCommitMessage............................................................267
;     >>> §2.4: Git commit GUI — Imports.......................................................277
;       →→→ §2.4.1: For committing CSS builds..................................................280
;       →→→ §2.4.2: For committing JS builds...................................................285
;       →→→ §2.4.3: For committing any type of file............................................290
;     >>> §2.5: CopySrcFileToClipboard.........................................................295
;     >>> §2.6: IsGitShellActive...............................................................316
;     >>> §2.7: PasteTextIntoGitShell..........................................................323
;     >>> §2.8: ToEscapedPath..................................................................356
;     >>> §2.9: VerifyCopiedCode...............................................................364
;   §3: FUNCTIONS for interacting with online WEB DESIGN INTERFACES............................378
;     >>> §3.1: LoadWordPressSiteInChrome......................................................382
;   §4: GUI FUNCTIONS for handling user interactions with scripts..............................425
;     >>> §4.1: @postMinCss....................................................................429
;       →→→ §4.1.1: HandlePostCssCheckAllSites.................................................469
;       →→→ §4.1.2: HandlePostCssUncheckAllSites...............................................490
;       →→→ §4.1.3: HandlePostMinCssCancel.....................................................511
;       →→→ §4.1.4: HandlePostMinCssOK.........................................................518
;       →→→ §4.1.5: PasteMinCssToWebsite.......................................................590
;     >>> §4.2: @postCssFromRepo...............................................................601
;     >>> §4.3: @postPrevCssFromRepo...........................................................610
;     >>> §4.4: @postBackupCss.................................................................619
;       →→→ §4.4.1: HandlePostBackupCssCheckAllSites...........................................665
;       →→→ §4.4.2: HandlePostBackupCssUncheckAllSites.........................................686
;       →→→ §4.4.3: HandlePostBackupCssCancel..................................................707
;       →→→ §4.4.4: HandlePostBackupCssOK......................................................714
;     >>> §4.4: @postMinJs.....................................................................781
;       →→→ §4.4.1: HandlePostJsCheckAllSites..................................................831
;       →→→ §4.4.2: HandlePostJsUncheckAllSites................................................851
;       →→→ §4.4.3: HandlePostMinJsCancel......................................................871
;       →→→ §4.4.4: HandlePostMinJsOK..........................................................878
;       →→→ §4.4.5: PasteMinJsToWebsite........................................................945
;   §5: UTILITY HOTSTRINGS for working with GitHub Desktop.....................................960
;     >>> §5.1: FILE COMMITTING................................................................964
;     >>> §5.2: STATUS CHECKING...............................................................1089
;       →→→ §5.2.1: @doGitStataus & @dogs.....................................................1092
;       →→→ §5.2.2: @doGitDiff & @dogd........................................................1112
;       →→→ §5.2.3: @doGitLog & @dogl.........................................................1132
;       →→→ §5.2.4: @doGitNoFollowLog & @donfgl...............................................1153
;     >>> §5.3: Automated PASTING OF CSS/JS into online web interfaces........................1173
;       →→→ §5.3.1: @initCssPaste.............................................................1176
;       →→→ §5.3.2: @doCssPaste...............................................................1201
;       →→→ §5.3.3: @pasteGitCommitMsg........................................................1250
;       →→→ §5.3.4: ExecuteCssPasteCmds.......................................................1268
;       →→→ §5.3.5: ExecuteJsPasteCmds........................................................1316
;   §6: COMMAND LINE INPUT GENERATION SHORTCUTS...............................................1369
;     >>> §6.1: GUIs for automating generation of command line input..........................1373
;     >>> §6.2: BACKING UP builds of files containing custom CSS code.........................1382
;       →→→ §6.2.1: @backupCssInRepo..........................................................1385
;       →→→ §6.2.2: @backupCssAll.............................................................1394
;       →→→ §6.2.3: CopyCssFromWebsite........................................................1418
;       →→→ §6.2.4: ExecuteCssCopyCmds........................................................1428
;     >>> §6.3: REBUILDING files containing custom CSS code...................................1451
;       →→→ §6.3.1: @rebuildCssInRepo.........................................................1454
;       →→→ §6.3.2: @rebuildCssAll............................................................1463
;     >>> §6.4: COMMITTING files produced by or involved in CSS build processes...............1490
;       →→→ §6.4.1: @commitCssInRepo..........................................................1493
;     >>> §6.5: UPDATING SUBMODULES containing CSS dev dependencies...........................1502
;       →→→ §6.5.1: @updateCssSubmoduleInRepo.................................................1505
;       →→→ §6.5.2: @updateCssSubmoduleAll....................................................1514
;     >>> §6.6: COPYING built CSS code for deployment.........................................1542
;       →→→ §6.6.1: @copyMinCssFromRepo.......................................................1545
;       →→→ §6.6.2: @copyBackupCssFromRepo....................................................1554
;     >>> §6.7: BACKING UP builds of files containing custom JS code..........................1564
;       →→→ §6.7.1: BackupJs..................................................................1567
;       →→→ §6.7.2: @backupJsRepo.............................................................1584
;       →→→ §6.7.3: @backupJsAll..............................................................1593
;       →→→ §6.7.4: CopyJsFromWebsite.........................................................1620
;       →→→ §6.7.5: ExecuteJsCopyCmds.........................................................1631
;     >>> §6.8: REBUILDING files containing custom JS code....................................1652
;       →→→ §6.8.1: @rebuildJsInRepo..........................................................1655
;     >>> §6.9: FOR UPDATING JS SUBMODULES....................................................1664
;       →→→ §6.9.1: @commitJsInRepo...........................................................1667
;     >>> §6.10: FOR UPDATING JS SUBMODULES...................................................1676
;       →→→ §6.10.1: @updateJsSubmoduleInRepo.................................................1679
;       →→→ §6.10.2: @updateJsSubmoduleAll....................................................1688
;     >>> §6.11: Shortcuts for copying minified JS to clipboard...............................1715
;       →→→ §6.11.1: @copyMinJsAscc...........................................................1720
;       →→→ §6.11.2: @copyMinJsCr.............................................................1730
;       →→→ §6.11.3: @copyMinJsDsp............................................................1740
;       →→→ §6.11.4: @copyMinJsFye............................................................1750
;       →→→ §6.11.5: @copyMinJsFyf............................................................1760
;       →→→ §6.11.6: @copyMinJsNse............................................................1770
;       →→→ §6.11.7: @copyMinJsOue............................................................1780
;       →→→ §6.11.8: @copyBackupJsOue.........................................................1790
;       →→→ §6.11.9: @copyMinJsPbk............................................................1800
;       →→→ §6.11.10: @copyMinJsSurca.........................................................1810
;       →→→ §6.11.11: @copyMinJsSumRes........................................................1820
;       →→→ §6.11.12: @copyMinJsXfer..........................................................1830
;       →→→ §6.11.13: @copyMinJsUgr...........................................................1840
;       →→→ §6.11.14: @copyMinJsUcore.........................................................1850
;       →→→ §6.11.15: @copyBackupJsUcore......................................................1860
;       →→→ §6.11.16: @copyMinJsUcrAss........................................................1870
;     >>> §6.12: FOR CHECKING GIT STATUS ON ALL PROJECTS......................................1880
;   §7: KEYBOARD SHORTCUTS FOR POWERSHELL.....................................................1938
;     >>> §7.1: SHORTCUTS.....................................................................1942
;     >>> §7.2: SUPPORTING FUNCTIONS..........................................................1969
; ==================================================================================================

sgIsPostingMinCss := false
sgIsPostingMinJs := false

; --------------------------------------------------------------------------------------------------
;   §1: SETTINGS accessed via functions for this imported file
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: GetCmdForMoveToCSSFolder

GetCmdForMoveToCSSFolder( curDir ) {
	cmd := ""
	needleStr := "^" . ToEscapedPath( GetGitHubFolder() ) . "(.+)"
	posFound := RegExMatch( curDir, needleStr, matches )
	if( posFound > 0 ) {
		if( doesVarExist( matches1 ) && !doesVarExist( matches2 ) ) {
			cmd := "cd CSS"
		}
	}
	Return cmd
}

;   ································································································
;     >>> §1.2: GetCurrentDirFrom

GetCurrentDirFromPS() {
	copyDirCmd := "(get-location).ToString() | clip`r`n"
	PasteTextIntoGitShell( "", copyDirCmd )
	while( Clipboard = copyDirCmd ) {
		Sleep 100
	}
	Return Clipboard
}

;   ································································································
;     >>> §1.3: GetGitHubFolder

GetGitHubFolder() {
	global userAccountFolderSSD
	Return userAccountFolderSSD . "\GitHub"
}

;   ································································································
;     >>> §1.4: UserFolderIsSet

UserFolderIsSet() {
	global userAccountFolderSSD
	varDeclared := userAccountFolderSSD != thisIsUndeclared
	if ( !varDeclared ) {
		MsgBox, % ( 0x0 + 0x10 ), % "ERROR: Upstream dependency missing in github.ahk"
			, % "The global variable specifying the user's account folder has not been declared and"
. " set upstream."
	}
	Return varDeclared
}

; --------------------------------------------------------------------------------------------------
;   §2: FUNCTIONS for working with GitHub Desktop
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: ActivateGitShell

ActivateGitShell() {
	global execDelayer
	global mmRegEx

	DetectHiddenWindows, On
	oldMatchMode := ChangeMatchMode( mmRegEx )
	WinGet, thisProcess, ProcessName, A
	shellActivated := false
	if ( !( thisProcess == "PowerShell.exe" || thisProcess == "powershell.exe" ) ) {
		IfWinExist, % "ahk_exe [Pp]ower[Ss]hell.exe"
		{
			execDelayer.SetUpNewProcess( 24, A_ThisFunc )
			WinActivate, % "ahk_exe [Pp]ower[Ss]hell.exe"
			checkCount := 0
			while( checkCount < 12 && !shellActivated ) {
				checkCount++
				execDelayer.Wait( "medium" )
				WinGet, thisProcess, ProcessName, A
				execDelayer.Wait( "medium" )
				shellActivated := thisProcess == "PowerShell.exe" || thisProcess == "powershell.exe"
				if ( !shellActivated && Mod( checkCount, 3 ) == 0 ) {
					WinActivate, % "ahk_exe [Pp]ower[Ss]hell.exe"
				}
			}
			execDelayer.CompleteCurrentProcess()
		}
	}
	else {
		shellActivated := true
	}
	RestoreMatchMode( oldMatchMode )
	DetectHiddenWindows, Off
	Return shellActivated
}

;   ································································································
;     >>> §2.2: CommitAfterBuild

CommitAfterBuild( ahkBuildCmd, ahkCommitCmd ) {
	ahkFuncName := "github.ahk: CommitAfterBuild"
	errorMsg := ""
	qcAhkBuildCmd := IsLabel( ahkBuildCmd )
	qcAhkCommitCmd := IsLabel( ahkCommitCmd )
	if ( qcAhkBuildCmd && qcAhkCommitCmd ) {
		MsgBox, % ( 0x4 + 0x20 )
			, % ahkBuildCmd . ": Proceed with commit?"
			, % "Would you like to proceed with the commit command " . ahkCommitCmd . "?"
		IfMsgBox Yes
			Gosub, %ahkCommitCmd%
	} else {
		if ( !qcAhkBuildCmd ) {
			errorMsg .= "Function was called with an invalid argument for the calling build command"
. ": " . ahkBuildCmd . "."
			if ( !qcAhkCommitCmd ) {
				errorMsg .= "The argument for the commit command to call next was also invalid: "
. ahkCommitCmd . "."
			}		
		} else {
			errorMsg .= "Function was called from the build command " . ahkBuildCmd . ", but an inv"
. "alid argument for the commit command was found: " . ahkCommitCmd . "."
		}
	}
	if ( errorMsg != "" ) {
		MsgBox, % ( 0x0 + 0x10 )
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
}

;   ································································································
;     >>> §2.3: EscapeCommitMessage
;       Escape commit message strings for use in PowerShell. Assumes that double quotes are used to
;       enclose the string.

EscapeCommitMessage( msgToEscape ) {
	escapedMsg := RegExReplace( msgToEscape, "m)("")", "`$1" )
	return escapedMsg
}

;   ································································································
;     >>> §2.4: Git commit GUI — Imports

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.1: For committing CSS builds

#Include %A_ScriptDir%\GitHub\CommitCssBuild.ahk

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.2: For committing JS builds

#Include %A_ScriptDir%\GitHub\CommitJsBuild.ahk

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.3: For committing any type of file

#Include %A_ScriptDir%\GitHub\CommitAnyFile.ahk

;   ································································································
;     >>> §2.5: CopySrcFileToClipboard

CopySrcFileToClipboard( ahkCmdName, srcFileToCopy, strToPrepend, errorMsg ) {
	if ( UserFolderIsSet() ) {
		srcFile := FileOpen( srcFileToCopy, "r" )
		if ( srcFile != 0 ) {
			contents := srcFile.Read()
			srcFile.Close()
			clipboard := strToPrepend . contents
		}
		else {
			MsgBox, % ( 0x0 + 0x10 ), % "ERROR (" . ahkCmdName . ")", % errorMsg . "`rCAUSE = Faile"
 . "d to open file: " . srcFile
		}
	} else {
		MsgBox, % ( 0x0 + 0x10 ), % "ERROR (" . ahkCmdName . ")", % errorMsg . "`rCAUSE = User fold"
 . "er is not set."
	}
}

;   ································································································
;     >>> §2.6: IsGitShellActive

IsGitShellActive() {
	Return IsPowerShellActive()
}

;   ································································································
;     >>> §2.7: PasteTextIntoGitShell

PasteTextIntoGitShell( ahkCmdName, shellText ) {
	global execDelayer

	errorMsg := ""

	if ( UserFolderIsSet() ) {
		proceedWithPaste := ActivateGitShell()
		if ( proceedWithPaste ) {
			execDelayer.SetUpNewProcess( 4, A_ThisFunc )
			SendInput, {Esc}
			execDelayer.Wait( "short" )
			GetCursorCoordsToCenterInActiveWindow( newPosX, newPosY )
			execDelayer.Wait( "medium" )
			clipboard = %shellText%
			execDelayer.Wait( "medium" )
			Click right, %newPosX%, 20
			execDelayer.Wait( "xShort" )
		} else {
			errorMsg := "Was unable to activate GitHub Powershell; aborting hotstring."
		}
	} else {
		errorMsg := "Because user folder is not set, location of GitHub is unknown."
	}
	if ( errorMsg != "" ) {
		MsgBox, % ( 0x0 + 0x10 )
			, % ahkCmdName . ": Error in Call to PasteTextIntoGitShell"
			, % errorMsg
	}
}

;   ································································································
;     >>> §2.8: ToEscapedPath

ToEscapedPath( path ) {
	escapedPath := StrReplace( path, "\", "\\" )
	Return escapedPath
}

;   ································································································
;     >>> §2.9: VerifyCopiedCode

VerifyCopiedCode( callerStr, copiedCss ) {
	proceed := False
	title := "VerifyCopiedCode(...)"
	msg := "Here's what I copied:`n" . SubStr( copiedCss, 1, 320 ) . "...`n`nProceed with git commi"
 . "t?"
	MsgBox, 33, % title, % msg
	IfMsgBox, OK
		proceed := True
	Return proceed
}

; --------------------------------------------------------------------------------------------------
;   §3: FUNCTIONS for interacting with online WEB DESIGN INTERFACES
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: LoadWordPressSiteInChrome

LoadWordPressSiteInChrome( websiteUrl, winTitle := "" ) {
	global execDelayer
	tabAlreadyLoaded := false
	WinGet, thisProcess, ProcessName, A
	if ( thisProcess != "chrome.exe" ) {
		if ( winTitle != "" && WinExist( winTitle . " ahk_exe chrome.exe" ) ) {
			WinActivate, % winTitle . " ahk_exe chrome.exe"
			tabAlreadyLoaded := true
		} else {
			WinActivate, % "ahk_exe chrome.exe"
		}
		WinGet, thisProcess, ProcessName, A
		execDelayer.Wait( "s", 2 )
	}
	if ( thisProcess = "chrome.exe" ) {
		execDelayer.Wait( "m" )
		if ( !tabAlreadyLoaded ) {		
			SendInput, ^t
			execDelayer.Wait( "l" )
			SendInput, !d
			execDelayer.Wait( "s", 2 )
			SafeSendInput( websiteUrl . "{Enter}" )
			execDelayer.Wait( "m", 1.5 )
		}
		proceed := false
		WinGetTitle, thisTitle, A
		if ( !InStr( thisTitle, "New Tab") && !InStr( thisTitle, "newtab") ) {
			proceed := true
		}
		while ( !proceed ) {
			execDelayer.Wait( "m", 1.5 )
			WinGetTitle, thisTitle, A
			if ( !InStr( thisTitle, "New Tab") && !InStr( thisTitle, "newtab") ) {
				proceed := true
			}
		}
		execDelayer.Wait( "m", 1.5 )
	}
}

; --------------------------------------------------------------------------------------------------
;   §4: GUI FUNCTIONS for handling user interactions with scripts
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §4.1: @postMinCss

:*?:@postMinCss::
	AppendAhkCmd( A_ThisLabel )
	if( !sgIsPostingMinCss ) {
		Gui, guiPostMinCss: New,, % "Post Minified CSS to OUE Websites"
		Gui, guiPostMinCss: Add, Text, , % "Post minified CSS in:"
		Gui, guiPostMinCss: Add, Radio, Checked Y+0 vRadioGroupPostMinCssAutoMode
			, % "Automatic mode (&1)`n"
		Gui, guiPostMinCss: Add, Radio, Y+0, % "Manual mode (&2)"
		Gui, guiPostMinCss: Add, Text,, % "Which OUE Websites would you like to update?"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToAscc, % "https://&ascc.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToCr, % "https://commonread&ing.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToDsp Checked
			, % "https://&distinguishedscholarships.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToFye Checked, % "https://&firstyear.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToFyf Checked
			, % "https://&learningcommunities.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToNse Checked, % "https://&nse.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToNsse Checked, % "https://nsse.wsu.edu (&b)"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToPbk Checked
			, % "https://&phibetakappa.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToSurca Checked, % "https://&surca.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToSumRes Checked
			, % "https://su&mmerresearch.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToXfer, % "https://&transfercredit.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUgr Checked
			, % "https://&undergraduateresearch.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUcore Checked, % "https://uco&re.wsu.edu"
		Gui, guiPostMinCss: Add, CheckBox, vPostMinCssToUcrAss Checked
			, % "https://ucor&e.wsu.edu/assessment"
		Gui, guiPostMinCss: Add, Button, Default gHandlePostMinCssOK, &OK
		Gui, guiPostMinCss: Add, Button, gHandlePostMinCssCancel X+5, &Cancel
		Gui, guiPostMinCss: Add, Button, gHandlePostCssCheckAllSites X+15, C&heck All
		Gui, guiPostMinCss: Add, Button, gHandlePostCssUncheckAllSites X+5, Unchec&k All
		Gui, guiPostMinCss: Show
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.1: HandlePostCssCheckAllSites

HandlePostCssCheckAllSites() {
	global
	GuiControl, guiPostMinCss:, PostMinCssToAscc, 1
	GuiControl, guiPostMinCss:, PostMinCssToCr, 1
	GuiControl, guiPostMinCss:, PostMinCssToDsp, 1
	GuiControl, guiPostMinCss:, PostMinCssToFye, 1
	GuiControl, guiPostMinCss:, PostMinCssToFyf, 1
	GuiControl, guiPostMinCss:, PostMinCssToNse, 1
	GuiControl, guiPostMinCss:, PostMinCssToNsse, 1
	GuiControl, guiPostMinCss:, PostMinCssToPbk, 1
	GuiControl, guiPostMinCss:, PostMinCssToSurca, 1
	GuiControl, guiPostMinCss:, PostMinCssToSumRes, 1
	GuiControl, guiPostMinCss:, PostMinCssToXfer, 1
	GuiControl, guiPostMinCss:, PostMinCssToUgr, 1
	GuiControl, guiPostMinCss:, PostMinCssToUcore, 1
	GuiControl, guiPostMinCss:, PostMinCssToUcrAss, 1
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.2: HandlePostCssUncheckAllSites

HandlePostCssUncheckAllSites() {
	global
	GuiControl, guiPostMinCss:, PostMinCssToAscc, 0
	GuiControl, guiPostMinCss:, PostMinCssToCr, 0
	GuiControl, guiPostMinCss:, PostMinCssToDsp, 0
	GuiControl, guiPostMinCss:, PostMinCssToFye, 0
	GuiControl, guiPostMinCss:, PostMinCssToFyf, 0
	GuiControl, guiPostMinCss:, PostMinCssToNse, 0
	GuiControl, guiPostMinCss:, PostMinCssToNsse, 0
	GuiControl, guiPostMinCss:, PostMinCssToPbk, 0
	GuiControl, guiPostMinCss:, PostMinCssToSurca, 0
	GuiControl, guiPostMinCss:, PostMinCssToSumRes, 0
	GuiControl, guiPostMinCss:, PostMinCssToXfer, 0
	GuiControl, guiPostMinCss:, PostMinCssToUgr, 0
	GuiControl, guiPostMinCss:, PostMinCssToUcore, 0
	GuiControl, guiPostMinCss:, PostMinCssToUcrAss, 0
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.3: HandlePostMinCssCancel

HandlePostMinCssCancel() {
	Gui, guiPostMinCss: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.4: HandlePostMinCssOK

; TODO: Refactor so that pasting is based on my new AHK configuration file paradigm.
HandlePostMinCssOK() {
	global
	Gui, guiPostMinCss: Submit
	Gui, guiPostMinCss: Destroy
	sgIsPostingMinCss := true
	local postMinCssAutoMode := false
	if ( RadioGroupPostMinCssAutoMode == 2 ) {
		postMinCssAutoMode := true
	}
	if ( PostMinCssToAscc ) {
		PasteMinCssToWebsite( "https://ascc.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssAscc", postMinCssAutoMode )
	}
	if ( PostMinCssToCr ) {
		PasteMinCssToWebsite( "https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssCr", postMinCssAutoMode )
	}
	if ( PostMinCssToDsp ) {
		PasteMinCssToWebsite( "https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=e"
 . "ditcss", ":*?:@copyMinCssDsp", postMinCssAutoMode )
	}
	if ( PostMinCssToFye ) {
		PasteMinCssToWebsite( "https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssFye", postMinCssAutoMode )
	}
	if ( PostMinCssToFyf ) {
		PasteMinCssToWebsite( "https://learningcommunities.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssFyf", postMinCssAutoMode )
	}
	if ( PostMinCssToNse ) {
		PasteMinCssToWebsite( "https://nse.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssNse", postMinCssAutoMode )
	}
	if ( PostMinCssToNsse ) {
		PasteMinCssToWebsite( "https://stage.web.wsu.edu/wsu-nsse/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssNsse", postMinCssAutoMode )
	}
	if ( PostMinCssToPbk ) {
		PasteMinCssToWebsite( "https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssPbk", postMinCssAutoMode )
	}
	if ( PostMinCssToSurca ) {
		PasteMinCssToWebsite( "https://surca.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssSurca", postMinCssAutoMode )
	}
	if ( PostMinCssToSumRes ) {
		PasteMinCssToWebsite( "https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssSumRes", postMinCssAutoMode )
	}
	if ( PostMinCssToXfer ) {
		PasteMinCssToWebsite( "https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssXfer", postMinCssAutoMode )
	}
	if ( PostMinCssToUgr ) {
		PasteMinCssToWebsite( "https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=editcs"
. "s", ":*?:@copyMinCssUgr", postMinCssAutoMode )
	}
	if ( PostMinCssToUcore ) {
		PasteMinCssToWebsite( "https://ucore.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssUcore", postMinCssAutoMode )
	}
	if ( PostMinCssToUcrAss ) {
		PasteMinCssToWebsite( "https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=editcss"
			, ":*?:@copyMinCssUcrAss", postMinCssAutoMode )
	}
	sgIsPostingMinCss := false
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.5: PasteMinCssToWebsite

PasteMinCssToWebsite( websiteUrl, cssCopyCmd, manualProcession := false ) {
	delay := 1000
	LoadWordPressSiteInChrome( websiteUrl )
	Gosub, %cssCopyCmd%
	Sleep, % delay
	ExecuteCssPasteCmds( manualProcession )
}

;   ································································································
;     >>> §4.2: @postCssFromRepo

:*?:@postCssFromRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui( "post" )
Return

;   ································································································
;     >>> §4.3: @postPrevCssFromRepo

:*?:@postPrevCssFromRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui( "postBackup" )
Return

;   ································································································
;     >>> §4.4: @postBackupCss

:*?:@postBackupCss::
	AppendAhkCmd( A_ThisLabel )
	if( !sgIsPostingBackupCss ) {
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
		Gui, guiPostBackupCss: Add, CheckBox, vPostBackupCssToNsse Checked
			, % "https://nsse.wsu.edu (&b)"
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.1: HandlePostBackupCssCheckAllSites

HandlePostBackupCssCheckAllSites() {
	global
	GuiControl, guiPostBackupCss:, PostBackupCssToAscc, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToCr, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToDsp, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToFye, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToFyf, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToNse, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToNsse, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToPbk, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToSurca, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToSumRes, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToXfer, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToUgr, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToUcore, 1
	GuiControl, guiPostBackupCss:, PostBackupCssToUcrAss, 1
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.2: HandlePostBackupCssUncheckAllSites

HandlePostBackupCssUncheckAllSites() {
	global
	GuiControl, guiPostBackupCss:, PostBackupCssToAscc, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToCr, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToDsp, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToFye, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToFyf, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToNse, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToNsse, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToPbk, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToSurca, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToSumRes, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToXfer, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToUgr, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToUcore, 0
	GuiControl, guiPostBackupCss:, PostBackupCssToUcrAss, 0
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.3: HandlePostBackupCssCancel

HandlePostBackupCssCancel() {
	Gui, guiPostBackupCss: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.4: HandlePostBackupCssOK

HandlePostBackupCssOK() {
	global
	Gui, guiPostBackupCss: Submit
	Gui, guiPostBackupCss: Destroy
	sgIsPostingBackupCss := true
	if ( PostMinCssToAscc ) {
		PasteMinCssToWebsite( "https://ascc.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssAscc" )
	}
	if ( PostMinCssToCr ) {
		PasteMinCssToWebsite( "https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssCr" )
	}
	if ( PostBackupCssToDsp ) {
		PasteMinCssToWebsite( "https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=e"
 . "ditcss", ":*?:@copyBackupCssDsp" )
	}
	if ( PostBackupCssToFye ) {
		PasteMinCssToWebsite( "https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssFye" )
	}
	if ( PostBackupCssToFyf ) {
		PasteMinCssToWebsite( "https://learningcommunities.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssFyf" )
	}
	if ( PostBackupCssToNse ) {
		PasteMinCssToWebsite( "https://nse.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssNse" )
	}
	if ( PostBackupCssToNsse ) {
		PasteMinCssToWebsite( "https://nse.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssNsse" )
	}
	if ( PostBackupCssToPbk ) {
		PasteMinCssToWebsite( "https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssPbk" )
	}
	if ( PostBackupCssToSurca ) {
		PasteMinCssToWebsite( "https://surca.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssSurca" )
	}
	if ( PostBackupCssToSumRes ) {
		PasteMinCssToWebsite( "https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssSumRes" )
	}
	if ( PostBackupCssToXfer, ) {
		PasteMinCssToWebsite( "https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssXfer" )
	}
	if ( PostBackupCssToUgr ) {
		PasteMinCssToWebsite( "https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=editc"
 . "ss", ":*?:@copyBackupCssUgr" )
	}
	if ( PostBackupCssToUcore ) {
		PasteMinCssToWebsite( "https://ucore.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssUcore" )
	}
	if ( PostBackupCssToUcrAss ) {
		PasteMinCssToWebsite( "https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=editcss"
			, ":*?:@copyBackupCssUcrAss" )
	}
	sgIsPostingBackupCss := false
}

;   ································································································
;     >>> §4.4: @postMinJs

:*?:@postMinJs::
	AppendAhkCmd( A_ThisLabel )
	if( !sgIsPostingMinJs ) {
		Gui, guiPostMinJs: New,
			, % "Post Minified JS to OUE Websites"
		Gui, guiPostMinJs: Add, Text,
			, % "Post minified JS in:"
		Gui, guiPostMinJs: Add, Radio, Checked Y+0 vRadioGroupPostMinJsAutoMode
			, % "Automatic mode (&1)`n"
		Gui, guiPostMinJs: Add, Radio, Y+0
			, % "Manual mode (&2)"
		Gui, guiPostMinJs: Add, Text, Y+16
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
		Gui, guiPostMinJs: Add, Button, Default Y+16 gHandlePostMinJsOK, &OK
		Gui, guiPostMinJs: Add, Button, gHandlePostMinJsCancel X+5, &Cancel
		Gui, guiPostMinJs: Add, Button, gHandlePostJsCheckAllSites X+15, C&heck All
		Gui, guiPostMinJs: Add, Button, gHandlePostJsUncheckAllSites X+5, Unchec&k All
		Gui, guiPostMinJs: Show
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.1: HandlePostJsCheckAllSites

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.2: HandlePostJsUncheckAllSites

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.3: HandlePostMinJsCancel

HandlePostMinJsCancel() {
	Gui, Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.4: HandlePostMinJsOK

HandlePostMinJsOK() {
	global
	Gui, Submit
	Gui, Destroy
	sgIsPostingMinJs := true
	local postMinJsAutoMode := false
	if ( RadioGroupPostMinJsAutoMode == 2 ) {
		postMinJsAutoMode := true
	}
	if ( PostMinJsToAscc ) {
		PasteMinJsToWebsite( "https://ascc.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*?:@copyMinJsAscc", postMinJsAutoMode )
	}
	if ( PostMinJsToCr ) {
		PasteMinJsToWebsite( "https://commonreading.wsu.edu/wp-admin/themes.php?page=custom-javascr"
 . "ipt", ":*?:@copyMinJsCr", postMinJsAutoMode )
	}
	if ( PostMinJsToDsp ) {
		PasteMinJsToWebsite( "https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=cu"
 . "stom-javascript", ":*?:@copyMinJsDsp", postMinJsAutoMode )
	}
	if ( PostMinJsToFye ) {
		PasteMinJsToWebsite( "https://firstyear.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*?:@copyMinJsFye", postMinJsAutoMode )
	}
	if ( PostMinJsToFyf ) {
		PasteMinJsToWebsite( "https://learningcommunities.wsu.edu/wp-admin/themes.php?page=custom-j"
 . "avascript", ":*?:@copyMinJsFyf", postMinJsAutoMode )
	}
	if ( PostMinJsToNse ) {
		PasteMinJsToWebsite( "https://nse.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*?:@copyMinJsNse", postMinJsAutoMode )
	}
	if ( PostMinJsToPbk ) {
		PasteMinJsToWebsite( "https://phibetakappa.wsu.edu/wp-admin/themes.php?page=custom-javascri"
 . "pt", ":*?:@copyMinJsPbk", postMinJsAutoMode )
	}
	if ( PostMinJsToSurca ) {
		PasteMinJsToWebsite( "https://surca.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*?:@copyMinJsSurca", postMinJsAutoMode )
	}
	if ( PostMinJsToSumRes ) {
		PasteMinJsToWebsite( "https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javasc"
 . "ript", ":*?:@copyMinJsSumRes", postMinJsAutoMode )
	}
	if ( PostMinJsToXfer ) {
		PasteMinJsToWebsite( "https://transfercredit.wsu.edu/wp-admin/themes.php?page=custom-javasc"
 . "ript", ":*?:@copyMinJsXfer", postMinJsAutoMode )
	}
	if ( PostMinJsToUgr ) {
		PasteMinJsToWebsite( "https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=custom"
 . "-javascript", ":*?:@copyMinJsUgr", postMinJsAutoMode )
	}
	if ( PostMinJsToUcore ) {
		PasteMinJsToWebsite( "https://ucore.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*?:@copyMinJsUcore", postMinJsAutoMode )
	}
	if ( PostMinJsToUcrAss ) {
		PasteMinJsToWebsite( "https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=custom-java"
 . "script", ":*?:@copyMinJsUcrAss", postMinJsAutoMode )
	}
	sgIsPostingMinJs := false
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.4.5: PasteMinJsToWebsite

PasteMinJsToWebsite( websiteUrl, jsCopyCmd, manualProcession := false ) {
	LoadWordPressSiteInChrome( websiteUrl )
	if ( manualProcession ) {
		MsgBox, 48, % "ExecuteJsPasteCmds", % "Press OK to proceed with " . jsCopyCmd . " command."
	} else {
		Sleep, 1000
	}
	Gosub, %jsCopyCmd%
	Sleep, 120
	ExecuteJsPasteCmds( manualProcession )
}

; --------------------------------------------------------------------------------------------------
;   §5: UTILITY HOTSTRINGS for working with GitHub Desktop
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: FILE COMMITTING
; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*?:@getGitCommitLog::
	AppendAhkCmd( A_ThisLabel )
	PasteTextIntoGitShell( A_ThisLabel, "git log -p --since='last month' --pretty=format:'%h|%an|%a"
 . "r|%s|%b' > git-log.txt`r" )
Return

:*?:@getNoDiffGitCommitLog::
	AppendAhkCmd( A_ThisLabel )
	PasteTextIntoGitShell( A_ThisLabel, "git log --since='last month' --pretty=format:'%h|%an|%ar|%"
 . "s|%b' > git-log.txt`r" )
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*?:@findGitChangesRegEx::
	targetProcesses := ["notepad++.exe", "sublime_text.exe"]
	notActiveErrMsg := "Please ensure Notepad++ or Sublime Text are active before activating this h"
 . "otstring."

	AppendAhkCmd( A_ThisLabel )
	activeProcessName := areTargetProcessesActive( targetProcesses, A_ThisLabel, notActiveErrMsg )
	if ( activeProcessName == targetProcess[1] ) {
		FindGitChangesRegExNotepadPp()
	} else {
		FindGitChangesRegExSublimeText()		
	}
Return

FindGitChangesRegExNotepadPp() {
	SafeSendInput( "^h" )
	Sleep, 200
	SafeSendInput( "{^}(?:[{^} -].*| (?{!} {{}7{}}).*|-(?{!}-{{}7{}}).*)?$(?:\r\n)?" )
	Sleep, 20
	SendInput, % "{Tab}"
	Sleep, 20
	SendInput, % "{Del}"
}

FindGitChangesRegExSublimeText() {
	delay := 60
	SendInput, % "{Esc}"
	Sleep, % delay
	SafeSendInput( "^h" )
	Sleep, % delay * 4
	SendInput, % "{^}(?:[{^}\n \-].*| (?{!} {{}7{}}).*|-(?{!}-{{}7{}}).*)?$(?:\n?)"
	Sleep, % delay
	SendInput, % "{Tab}"
	Sleep, % delay
	SendInput, % "^a"
	Sleep, % delay
	SendInput, % "{Del}"
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*?:@gitAddThis::
	AppendAhkCmd( A_ThisLabel )
	WinGet, thisProcess, ProcessName, A
	if ( thisProcess = "notepad++.exe" ) {
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
		commitText := RegExReplace( clipboard, "^(.*)", "git add $1" )
		clipboard = %commitText%
	} else {
		MsgBox, % ( 0x0 + 0x10 ), % "ERROR: Notepad++ Not Active"
			, % "Please activate Notepad++ and ensure the correct file is selected before attemptin"
 . "g to utilize this hotstring, which is designed to create a 'git add' command for pasting into P"
 . "owerShell based on Notepad++'s Edit > Copy to Clipboard > Current Full File Path to Clipboard m"
 . "enu command."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*?:@doGitCommit::
	AppendAhkCmd( A_ThisLabel )
	proceedWithCmd := ActivateGitShell()
	if( proceedWithCmd ) {
		SendInput git commit -m "" -m ""{Left 7}
	}
	else {
		MsgBox, % ( 0x0 + 0x10 ), % "ERROR (" . ":*?:@doGitCommit" . "): Could Not Locate Git PowerS"
 . "hell"
		, % "The Git PowerShell process could not be located and activated."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*?:@dogc::
	Gosub, :*?:@doGitCommit
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*?:@doSingleGitCommit::
	AppendAhkCmd( A_ThisLabel )
	proceedWithCmd := ActivateGitShell()
	if( proceedWithCmd ) {
		SendInput git commit -m ""{Left 1}
	} else {
		MsgBox, % ( 0x0 + 0x10 ), % "ERROR (" . ":*?:@doSnglGitCommit" . "): Could Not Locate Git Po"
 . "werShell"
		, % "The Git PowerShell process could not be located and activated."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*?:@dosgc::
	Gosub, :*?:@doSingleGitCommit
Return

;   ································································································
;     >>> §5.2: STATUS CHECKING

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.1: @doGitStataus & @dogs
;
;	Shortcut for "git status" command in PowerShell.

:*?:@doGitStatus::
	AppendAhkCmd( A_ThisLabel )
	proceedWithCmd := ActivateGitShell()
	if( proceedWithCmd ) {
		SafeSendInput( "git status{enter}" )
	} else {
		MsgBox % ( 0x0 + 0x10 ), % "ERROR (" . A_ThisLabel . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

:*?:@dogs::
	Gosub :*?:@doGitStatus
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.2: @doGitDiff & @dogd
;
;	Shortcut for "git diff" command in PowerShell.

:*?:@doGitDiff::
	AppendAhkCmd( A_ThisLabel )
	proceedWithCmd := ActivateGitShell()
	if( proceedWithCmd ) {
		SafeSendInput( "git --no-pager diff " )
	} else {
		MsgBox % ( 0x0 + 0x10 ), % "ERROR (" . A_ThisLabel . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

:*?:@dogd::
	Gosub :*?:@doGitDiff
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.3: @doGitLog & @dogl
;
;	Shortcut for "git log" command in PowerShell.

:*?:@doGitLog::
	AppendAhkCmd( A_ThisLabel )
	proceedWithCmd := ActivateGitShell()
	if( proceedWithCmd ) {
		SafeSendInput( "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s%n  ╘═> %b"" "
			. "-20 " )
	} else {
		MsgBox % ( 0x0 + 0x10 ), % "ERROR (" . A_ThisLabel . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

:*?:@dogl::
	Gosub :*?:@doGitLog
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.5: @doNoFollowGitLog & @donfgl
;
;	Shortcut for "git log" command in PowerShell, but without the follow directive.

:*?:@doNoFollowGitLog::
	AppendAhkCmd( A_ThisLabel )
	proceedWithCmd := ActivateGitShell()
	if( proceedWithCmd ) {
		SafeSendInput( "git --no-pager log --pretty=""format:%h | %cn | %cd | %s%n  ╘═> %b"" -20" )
	} else {
		MsgBox % ( 0x0 + 0x10 ), % "ERROR (" . A_ThisLabel . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

:*?:@donfgl::
	Gosub :*?:@doNoFollowGitLog
Return

;   ································································································
;     >>> §5.3: Automated PASTING OF CSS/JS into online web interfaces

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.1: @initCssPaste
;
;	Initialize a tab in Chrome for automated repeated CSS pasting.

:*?:@initCssPaste::
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
	AppendAhkCmd( A_ThisLabel )
	WinGetTitle, thisTitle, A
	posFound := RegExMatch( thisTitle, "i)^CSS[^" . Chr( 0x2014 ) . "]+" . Chr( 0x2014 ) . " WordPr"
 . "ess - Google Chrome$" )
	if( posFound ) {
		WinGet, hwndCssPasteWindow, ID, A
		titleCssPasteWindowTab := thisTitle
		MsgBox, % "HWND for window containing CSS stylsheet editor set to " . hwndCssPasteWindow
	}
	else {
		MsgBox, % ( 0x0 + 0x10 ), % "ERROR (:*?:@setCssPasteWindow): CSS Stylesheet Editor Not Activ"
 . "e"
 			, % "Please select your CSS stylesheet editor tab in Chrome as the currently active win"
 . "dow."
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.2: @doCssPaste
;
;	Paste CSS into a tab in Chrome previously initialized by the @initCssPaste command.

:*?:@doCssPaste::
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
	AppendAhkCmd( A_ThisLabel )
	if( isVarDeclared( hwndCssPasteWindow ) ) {
		; Attempt to switch to chrome
		WinActivate, % "ahk_id " . hwndCssPasteWindow
		WinWaitActive, % "ahk_id " . hwndCssPasteWindow, , 1
		if ( ErrorLevel ) {
			MsgBox, % ( 0x0 + 0x10 ), % "ERROR (:*?:@doCssPaste): Could Not Find Process"
				, % "The HWND set for the chrome window containing the tab in which the CSS stylesh"
 . "eet editor was loaded can no longer be found."
		} else {
			WinGetTitle, thisTitle, A
			if( thisTitle != titleCssPasteWindowTab ) {
				startingTitle := thistTitle
				SendInput, ^{Tab}
				Sleep 100
				WinGetTitle, currentTitle, A
				while ( currentTitle != startingTitle and currentTitle != titleCssPasteWindowTab ) {
					SendInput, ^{Tab}
					Sleep 100
					WinGetTitle, currentTitle, A
				}
				if( currentTitle != titleCssPasteWindowTab ) {
					MsgBox, % ( 0x0 + 0x10 ), % "ERROR (:*?:@doCssPaste): Couldn't Find Tab"
						, % "Could not locate the tab containing the CSS stylesheet editor."
				} else {
					proceedWithPaste := true
				}
			} else {
				proceedWithPaste := true
			}
			if ( proceedWithPaste ) {
				ExecuteCssPasteCmds()
			}
		}
	} else {
		MsgBox, % ( 0x0 + 0x10 ), % "ERROR (:*?:@doCssPaste): HWND Not Set Yet"
			, % "You haven't yet used the @setCssPasteWindow hotstring to set the HWND for the Chro"
. "me window containing a tab with the CSS stylsheet editor."
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.3: @pasteGitCommitMsg
;
;	Paste commit messages copied from GitHub.com into PowerShell with proper formatting.

:*?:@pasteGitCommitMsg::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd( thisAhkCmd )
	WinGet, thisProcess, ProcessName, A
	if ( thisProcess = "PowerShell.exe" ) {
		commitText := RegExReplace( clipboard, Chr( 0x2026 ) "\R" Chr( 0x2026 ), "" )
		clipboard = %commitText%
		cPosX := 44 * g_dpiScalar
		cPosY := 55 * g_dpiScalar
		Click right, %cPosX%, %cPosY%
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.4: ExecuteCssPasteCmds
;
;	Perform the steps necessary to paste built CSS into a Chrome tab loaded with a WSUWP CSS
;	Stylesheet Editor page and apply it to the according website.

ExecuteCssPasteCmds( manualProcession := false ) {
	; Add check for correct CSS in clipboard — the first line is a font import.
	global execDelayer
	global g_dpiScalar
	posFound := RegExMatch( clipboard
		, "im)/\*! .*built with the Less CSS preprocessor.*github\.com/invokeImmediately|/*! ======"
 . "==========================================================================================*** W"
 . "SU DAESA Styling Section" )
	if ( posFound != 0 ) {
		WinGet, hwnd, ID, A
		winInfo := API_GetWindowInfo( hwnd )
		editorX := 430 * g_dpiScalar
		editorY := 400 * g_dpiScalar
		Click, %editorX%, %editorY%
		execDelayer.Wait( "s" )
		SendInput, ^a
		execDelayer.Wait( "m" )
		if ( manualProcession ) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with paste command."
		}
		SendInput, ^v
		execDelayer.Wait( "m" )
		if ( manualProcession ) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with update button selection."
		}
		buttonX := ( winInfo.Client.Right - winInfo.Client.Left + winInfo.XBorders ) - 100
			* g_dpiScalar
		buttonY1 := 370 * g_dpiScalar
		buttonYDelta := 40 * g_dpiScalar
		buttonY2 := buttonY1 + buttonYDelta
		Click, %buttonX%, %buttonY1%
		execDelayer.Wait( "s" )
		Click, %buttonX%, %buttonY2%
		execDelayer.Wait( "s" )
	} else {
		MsgBox, % ( 0x0 + 0x10 )
			, % "ERROR (" . A_ThisFunc . "): Clipboard Has Unexpected Contents"
			, % "The clipboard does not begin with the expected inline documentation and thus may n"
 . "ot contain minified CSS."
	}			
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.5: ExecuteJsPasteCmds
;
;	Perform the steps necessary to paste built JS into a Chrome tab loaded with a WSUWP Custom
;	Javascript Editor page and apply it to the according website.

ExecuteJsPasteCmds( manualProcession := false ) {
	global execDelayer
	global g_dpiScalar
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch( clipboard, "^(?:// Built with Node.js)|(?:/\*!\*+`n \* jQuery.oue-custo"
		. "m.js)|(?:/\*!\*+`n \* (?:https://)?github.com/invokeImmediately/WSU-UE---JS/jQuery.oue-c"
		. "ustom.js)" )
	if ( posFound != 0 ) {
		; TODO: Add function for dpi scaled clicks, e.g., something like dsfClick or dpiSafeClick
		WinGet, hwnd, ID, A
		winInfo := API_GetWindowInfo( hwnd )
		editorX := 461 * g_dpiScalar
		editorY := 371 * g_dpiScalar
		Click, %editorX%, %editorY%
		execDelayer.Wait( "s" )
		SendInput, ^a
		execDelayer.Wait( "m" )
		if ( manualProcession ) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with paste command."
			execDelayer.Wait( 330 )
		} else {
			execDelayer.Wait( 2500 )
		}
		SendInput, ^v
		execDelayer.Wait( "m" )
		if ( manualProcession ) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with update button selection."
			execDelayer.Wait( 330 )
		} else {
			execDelayer.Wait( 5000 )
		}
		editorX := 214 * g_dpiScalar
		editorY := 565 * g_dpiScalar
		Click, %editorX%, %editorY%
		execDelayer.Wait( "s" )
		editorY := 615 * g_dpiScalar
		Click, %editorX%, %editorY%
		execDelayer.Wait( "l" )
	}
	else {
		MsgBox, % ( 0x0 + 0x10 )
			, % "ERROR (" . A_ThisFunc . "): Clipboard Has Unexpected Contents"
			, % "The clipboard does not begin with an expected substring that would indicate that "
			. "it contains minified JS from a DAESA web development project."
	}			
}

; --------------------------------------------------------------------------------------------------
;   §6: COMMAND LINE INPUT GENERATION SHORTCUTS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §6.1: GUIs for automating generation of command line input

#Include %A_ScriptDir%\GUIs\GhGui.ahk

#Include %A_ScriptDir%\GUIs\CssBldPsOps.ahk

#Include %A_ScriptDir%\GUIs\JsBldPsOps.ahk

;   ································································································
;     >>> §6.2: Shortucts for backing up custom CSS builds

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.1: @backupCssInRepo

:*?:@backupCssInRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui( "backup" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.2: @backupCssAll

:*?:@backupCssAll::
	AppendAhkCmd( A_ThisLabel )
	; TODO: Refactor command to rely on configuration settings
	; Gosub, :*?:@backupCssAscc
	; Gosub, :*?:@backupCssCr
	; Gosub, :*?:@backupCssDsp
	; Gosub, :*?:@backupCssFye
	; Gosub, :*?:@backupCssFyf
	; Gosub, :*?:@backupCssNse
	; Gosub, :*?:@backupCssPbk
	; Gosub, :*?:@backupCssSurca
	; Gosub, :*?:@backupCssSumRes
	; Gosub, :*?:@backupCssXfer
	; Gosub, :*?:@backupCssUgr
	; Gosub, :*?:@backupCssUcore
	; Gosub, :*?:@backupCssUcrAss
	PasteTextIntoGitShell( A_ThisLabel
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,300)`r" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.3: CopyCssFromWebsite

CopyCssFromWebsite( websiteUrl )
{
	LoadWordPressSiteInChrome( websiteUrl )
	copiedCss := ExecuteCssCopyCmds()
	return copiedCss
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.4: ExecuteCssCopyCmds

ExecuteCssCopyCmds() {
	global execDelayer
	global g_dpiScalar
	delay := 200
	execDelayer.Wait( delay, 10 )
	CoordMode, Mouse, Client
	edtrX := 768 * g_dpiScalar
	edtrY := 570 * g_dpiScalar
	Click, %edtrX%, %edtrY%
	execDelayer.Wait( delay )
	SendInput, ^a
	execDelayer.Wait( delay )
	SendInput, ^c
	execDelayer.Wait( delay, 3 )
	copiedCss := SubStr( clipboard, 1 )
	SendInput, ^w
	execDelayer.Wait( delay, 10 )
	return copiedCss
}

;   ································································································
;     >>> §6.3: Shortcuts for rebuilding files containing custom CSS code

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.1: @rebuildCssInRepo

:*?:@rebuildCssInRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui( "rebuild" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.2: @rebuildCssAll

:*?:@rebuildCssAll::
	AppendAhkCmd( A_ThisLabel )

	; TODO: Refactor command to rely on configuration settings
	; Gosub, :*?:@rebuildCssCr
	; Gosub, :*?:@rebuildCssDsp
	; Gosub, :*?:@rebuildCssFye
	; Gosub, :*?:@rebuildCssFyf
	; Gosub, :*?:@rebuildCssNse
	; Gosub, :*?:@rebuildCssOue
	; Gosub, :*?:@rebuildCssPbk
	; Gosub, :*?:@rebuildCssSurca
	; Gosub, :*?:@rebuildCssSumRes
	; Gosub, :*?:@rebuildCssXfer
	; Gosub, :*?:@rebuildCssUgr
	; Gosub, :*?:@rebuildCssUcore
	; Gosub, :*?:@rebuildCssUcrAss
	; PasteTextIntoGitShell(A_ThisLabel
	; 	, "[console]::beep(750,600)`r"
	; 	. "[console]::beep(375,150)`r"
	; 	. "[console]::beep(375,150)`r"
	; 	. "[console]::beep(375,150)`r")
Return

;   ································································································
;     >>> §6.4: Committing files produced by or involved in CSS build processes

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.1: @commitCssInRepo

:*?:@commitCssInRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui( "commit" )
Return

;   ································································································
;     >>> §6.5: Shortcuts for updating CSS submodules

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.1: @updateCssSubmoduleInRepo

:*?:@updateCssSubmoduleInRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.2: @updateCssSubmoduleAll

; TODO: Modify to rely on configuration settings
:*?:@updateCssSubmoduleAll::
	AppendAhkCmd( A_ThisLabel )
	MsgBox % "Currently, this hotstring is being modified and does not do anything yet."
	; Gosub, :*?:@updateCssSubmoduleAscc
	; Gosub, :*?:@updateCssSubmoduleCr
	; Gosub, :*?:@updateCssSubmoduleDsp
	; Gosub, :*?:@updateCssSubmoduleFye
	; Gosub, :*?:@updateCssSubmoduleFyf
	; Gosub, :*?:@updateCssSubmoduleNse
	; Gosub, :*?:@updateCssSubmoduleOue
	; Gosub, :*?:@updateCssSubmodulePbk
	; Gosub, :*?:@updateCssSubmoduleSurca
	; Gosub, :*?:@updateCssSubmoduleSumRes
	; Gosub, :*?:@updateCssSubmoduleXfer
	; Gosub, :*?:@updateCssSubmoduleUgr
	; Gosub, :*?:@updateCssSubmoduleUcore
	; Gosub, :*?:@updateCssSubmoduleUcrAss
	PasteTextIntoGitShell( A_ThisLabel
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r" )
Return

;   ································································································
;     >>> §6.6: For copying minified, backup css files to clipboard

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.1: @copyMinCssFromRepo

:*?:@copyMinCssFromRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui( "copyCss" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.2: @copyBackupCssFromRepo

:*?:@copyBackupCssFromRepo::
	AppendAhkCmd( A_ThisLabel )
	cssBldGui := new CssBldPsOps( scriptCfg.cssBuilds, checkType, execDelayer )
	cssBldGui.ShowGui( "copyBackup" )
Return


;   ································································································
;     >>> §6.7: FOR BACKING UP CUSTOM JS BUILDS

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.1: BackupJs

#Include %A_ScriptDir%\GUIs\BackupJsGui.ahk

BackupJs( caller, website, repository, backupFile ) {
	if ( caller != "" ) {
		AppendAhkCmd( caller )
	}
	CopyJsFromWebsite( website, copiedJs )
	if ( VerifyCopiedCode( caller, copiedJs ) ) {
		WriteCodeToFile( caller, copiedJs, repository . backupFile )
		PasteTextIntoGitShell( caller, "cd '" . repository . "'`rgit add " . backupFile
			. "`rgit commit -m 'Updating backup of latest verified custom JS build'`r" )
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.2: @backupJsInRepo

:*?:@backupJsRepo::
	AppendAhkCmd( A_ThisLabel )
	backupGui := new BackupJsGui( scriptCfg.backupJs, checkType )
	backupGui.ShowGui()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.3: @backupJsAll

:*?:@backupJsAll::
	AppendAhkCmd( A_ThisLabel )
	; TODO: Revise hotstring to rely on BackupJs function and configuration file settings.
	; Gosub, :*?:@backupJsAscc
	; Gosub, :*?:@backupJsCr
	; Gosub, :*?:@backupJsDsp
	; Gosub, :*?:@backupJsFye
	; Gosub, :*?:@backupJsFyf
	; Gosub, :*?:@backupJsNse
	; Gosub, :*?:@backupJsOue
	; Gosub, :*?:@backupJsPbk
	; Gosub, :*?:@backupJsSurca
	; Gosub, :*?:@backupJsSumRes
	; Gosub, :*?:@backupJsXfer
	; Gosub, :*?:@backupJsUgr
	; Gosub, :*?:@backupJsUcore
	; Gosub, :*?:@backupJsUcrAss
	; PasteTextIntoGitShell(A_ThisLabel
	; 	, "[console]::beep(750,600)`r"
	; 	. "[console]::beep(375,150)`r"
	; 	. "[console]::beep(375,150)`r"
	; 	. "[console]::beep(375,150)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.4: CopyJsFromWebsite

CopyJsFromWebsite( websiteUrl, ByRef copiedJs )
{
	delay := GetDelay( "long", 3 )
	LoadWordPressSiteInChrome( websiteUrl )
	Sleep % delay
	ExecuteJsCopyCmds( copiedJs )
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.5: ExecuteJsCopyCmds

; TODO: Fix issues with outdated aspects of this function's design.
ExecuteJsCopyCmds( ByRef copiedJs ) {
	global execDelayer
	global g_dpiScalar
	CoordMode, Mouse, Client
	edtrX := 461 * g_dpiScalar
	edtrY := 371 * g_dpiScalar
	Click, %edtrX%, %edtrY%
	execDelayer.Wait( 330 )
	SendInput, ^a
	execDelayer.Wait( 2500 )
	SendInput, ^c
	execDelayer.Wait( 2500 )
	SendInput, ^w
	copiedJs := SubStr( clipboard, 1 )
	execDelayer.Wait( 2000 )
}

;   ································································································
;     >>> §6.8: FOR REBUILDING JS SOURCE FILES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.1: @rebuildJsInRepo

:*?:@rebuildJsInRepo::
	AppendAhkCmd( A_ThisLabel )
	jsBldGui := new JsBldPsOps( scriptCfg.jsBuilds, checkType, execDelayer )
	jsBldGui.ShowGui( "rebuild" )
Return

;   ································································································
;     >>> §6.9: FOR UPDATING JS SUBMODULES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.1: @commitJsInRepo

:*?:@commitJsInRepo::
	AppendAhkCmd( A_ThisLabel )
	jsBldGui := new JsBldPsOps( scriptCfg.jsBuilds, checkType, execDelayer )
	jsBldGui.ShowGui( "commit" )
Return

;   ································································································
;     >>> §6.10: FOR UPDATING JS SUBMODULES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.10.1: @updateJsSubmoduleInRepo

:*?:@updateJsSubmoduleInRepo::
	AppendAhkCmd( A_ThisLabel )
	jsBldGui := new JsBldPsOps( scriptCfg.jsBuilds, checkType, execDelayer )
	jsBldGui.ShowGui( "update" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.10.2: @updateJsSubmoduleAll

:*?:@updateJsSubmoduleAll::
	AppendAhkCmd( A_ThisLabel )
	; TODO: Revise hotstring to rely on BackupJs function and configuration file settings.
	; Gosub, :*?:@updateJsSubmoduleAscc
	; Gosub, :*?:@updateJsSubmoduleCr
	; Gosub, :*?:@updateJsSubmoduleDsp
	; Gosub, :*?:@updateJsSubmoduleFye
	; Gosub, :*?:@updateJsSubmoduleFyf
	; Gosub, :*?:@updateJsSubmoduleNse
	; Gosub, :*?:@updateJsSubmoduleOue
	; Gosub, :*?:@updateJsSubmodulePbk
	; Gosub, :*?:@updateJsSubmoduleSurca
	; Gosub, :*?:@updateJsSubmoduleSumRes
	; Gosub, :*?:@updateJsSubmoduleXfer
	; Gosub, :*?:@updateJsSubmoduleUgr
	; Gosub, :*?:@updateJsSubmoduleUcore
	; Gosub, :*?:@updateJsSubmoduleUcrAss
	; PasteTextIntoGitShell( A_ThisLabel
	; 	, "[console]::beep(750,600)`r"
	; 	. "[console]::beep(375,150)`r"
	; 	. "[console]::beep(375,150)`r"
	; 	. "[console]::beep(375,150)`r" )
Return

;   ································································································
;     >>> §6.11: Shortcuts for copying minified JS to clipboard

;TODO: Add scripts for copying JS backups to clipboard (see CSS backup-copying scripts above)

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.1: @copyMinJsAscc

:*?:@copyMinJsAscc::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\ascc.wsu.edu\JS\ascc-custom.min.js"
		, "", "Couldn't Copy Minified JS for ASCC Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.2: @copyMinJsCr

:*?:@copyMinJsCr::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\commonreading.wsu.edu\JS\cr-build.min.js"
		, "", "Couldn't Copy Minified JS for CR Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.3: @copyMinJsDsp

:*?:@copyMinJsDsp::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS\dsp-custom-build.min.js"
		, "", "Couldn't Copy Minified JS for DSP Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.4: @copyMinJsFye

:*?:@copyMinJsFye::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\firstyear.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for FYE Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.5: @copyMinJsFyf

:*?:@copyMinJsFyf::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for FYF Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.6: @copyMinJsNse

:*?:@copyMinJsNse::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\nse.wsu.edu\JS\nse-custom.min.js"
		, "", "Couldn't Copy Minified JS for Nse Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.7: @copyMinJsOue

:*?:@copyMinJsOue::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\oue.wsu.edu\JS\oue-build.min.js"
		, "", "Couldn't Copy Minified JS for WSU OUE Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.8: @copyBackupJsOue

:*?:@copyBackupJsOue::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\oue.wsu.edu\JS\oue-custom.min.prev.js"
		, "", "Couldn't copy backup copy of minified JS for WSU OUE website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.9: @copyMinJsPbk

:*?:@copyMinJsPbk::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Phi Beta Kappa Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.10: @copyMinJsSurca

:*?:@copyMinJsSurca::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\surca.wsu.edu\JS\surca-build.min.js"
		, "", "Couldn't Copy Minified JS for SURCA Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.11: @copyMinJsSumRes

:*?:@copyMinJsSumRes::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\summerresearch.wsu.edu\JS\sumres-build.min.js"
		, "", "Couldn't Copy Minified JS for WSU Summer Research Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.12: @copyMinJsXfer

:*?:@copyMinJsXfer::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\transfercredit.wsu.edu\JS\xfercredit-build.min.js"
		, "", "Couldn't Copy Minified JS for WSU Transfer Credit Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.13: @copyMinJsUgr

:*?:@copyMinJsUgr::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS\ugr-build.min.js"
		, "", "Couldn't Copy Minified JS for UGR Website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.14: @copyMinJsUcore

:*?:@copyMinJsUcore::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu\JS\ucore-build.min.js"
		, "", "Couldn't copy minified JS for UCORE website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.15: @copyBackupJsUcore

:*?:@copyBackupJsUcore::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.min.prev.js"
		, ""		, "Couldn't copy backup copy of minified JS for UCORE website" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.11.16: @copyMinJsUcrAss

:*?:@copyMinJsUcrAss::
	AppendAhkCmd( A_ThisLabel )
	CopySrcFileToClipboard( A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Summer Research Website" )
Return

;   ································································································
;     >>> §6.12: FOR CHECKING GIT STATUS ON ALL PROJECTS

:*?:@checkGitStatus::
	AppendAhkCmd( A_ThisLabel )

	; Get the root GitHub folder where all repos are installed.
	shellTxt := ""
	numRepos := scriptCfg.gitStatus.cfgSettings.Length()
	repoRoot := scriptCfg.gitStatus.cfgSettings[ 1 ][ "repository" ]
	foundPos := RegExMatch( repoRoot, "^(.*\\)(.*\\)$", Match )
	repoRoot := Match1

	; Nofity user that hotstring is beginning its operation.
	DisplaySplashText( "Now checking the status of the " . numRepos . " Git Repositories that are "
		. "being tracked by this script.", 3000 )

	; Determine the width of the Git Shell.
	PasteTextIntoGitShell( A_ThisLabel, "Set-Clipboard -Value $Host.UI.RawUI.WindowSize.Width`r`n" )
	execDelayer.Wait( "l" )
	consoleWidth := Clipboard
	if ( consoleWidth <= 0 ) {
		consoleWidth := 211
	}
	escChar := "[char]0x1b"
	PasteTextIntoGitShell( A_ThisLabel, " Write-Output ( " . escChar . " + ""[3F"" + "
			. escChar . " + ""[30;40m"" + "" "" * 66 + ""``n"" + "" "" * 124 + " . escChar
			. " + ""[0m"")" )
	execDelayer.Wait( "l" )

	; Construct the string that will be pasted into the GitHub shell to check the status of all
	;  repos tracked through this script.
	Loop %numRepos% {
		repoName := scriptCfg.gitStatus.cfgSettings[ A_Index ][ "name" ]
		repoPath := scriptCfg.gitStatus.cfgSettings[ A_Index ][ "repository" ]
		shellTxt .= "cd """ . repoRoot . """`r`nWrite-Output ( " . escChar . " + ""["
			. ( Floor( 253 / consoleWidth ) + 1 ) . "A"" + " . escChar
			. " + ""[30;40m"" + "" "" * 253 + ""``r``n"" + " . escChar . " + ""[1;32m``n"
		subStr := ""
		subStrLen := Round( ( 110 - StrLen( repoName ) ) / 2 )
		Loop, %subStrLen%
		{
			subStr .= "-"
		}
		subStr .= repoName
		subStrLen := 110 - StrLen( subStr )
		Loop, %subStrLen%
		{
			subStr .= "-"
		}
		shellTxt .= subStr . """ + " . escChar . " + ""[0m"")`r`ncd """ . repoPath
			. """`r`ngit status`r`n"
	}
	shellTxt .= "cd """ . repoRoot . """`r`n`r`n`r`n"
	PasteTextIntoGitShell( A_ThisLabel, shellTxt )
	DisplaySplashText( "Git status commands have been pasted to PowerShell.", 3000 )
Return

; --------------------------------------------------------------------------------------------------
;   §7: KEYBOARD SHORTCUTS FOR POWERSHELL
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §7.1: SHORTCUTS

^+v::	
	if ( IsGitShellActive() ) {
		PasteTextIntoGitShell( "", clipboard )
	} else {
		Gosub, PerformBypassingCtrlShftV
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~^+Backspace::
	if ( IsGitShellActive() ) {
		SendInput {Backspace 120}
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~^+Delete::
	if ( IsGitShellActive() ) {
		SendInput {Delete 120}
	}
Return

;   ································································································
;     >>> §7.2: SUPPORTING FUNCTIONS

PerformBypassingCtrlShftV:
	Suspend
	Sleep 10
	SendInput ^+v
	Sleep 10
	Suspend, Off
Return
