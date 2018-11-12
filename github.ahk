; ==================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ==================================================================================================
; IMPORT DEPENDENCIES
;   Global Variable Name    Purpose
;   -·-·-·-·-·-·-·-·-·-     -·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·
;   userAccountFolder       Contains the path to the Windows user folder for the script runner
; --------------------------------------------------------------------------------------------------
; IMPORT ASSUMPTIONS
;   Environmental Property           State
;   ----------------------------     ---------------------------------------------------------------
;   Location of GitHub               …userAccountFolder (see above dependency)…\Documents\GitHub
;   Repositories locally present     All those from https://github.com/invokeImmediately 
; ==================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents
; -----------------
;   §1: SETTINGS accessed via functions for this imported file.................................254
;     >>> §1.1: GetCmdForMoveToCSSFolder.......................................................258
;     >>> §1.2: GetCurrentDirFrom..............................................................273
;     >>> §1.3: GetGitHubFolder................................................................285
;     >>> §1.4: UserFolderIsSet................................................................293
;   §2: FUNCTIONS for working with GitHub Desktop..............................................307
;     >>> §2.1: ActivateGitShell...............................................................311
;     >>> §2.2: CommitAfterBuild...............................................................330
;     >>> §2.3: EscapeCommitMessage............................................................365
;     >>> §2.4: Git commit GUI — Imports.......................................................375
;       →→→ §2.4.1: For committing CSS builds..................................................378
;       →→→ §2.4.2: For committing JS builds...................................................383
;       →→→ §2.4.3: For committing any type of file............................................388
;     >>> §2.5: CopySrcFileToClipboard.........................................................393
;     >>> §2.6: IsGitShellActive...............................................................414
;     >>> §2.7: PasteTextIntoGitShell..........................................................421
;     >>> §2.8: ToEscapedPath..................................................................447
;     >>> §2.9: VerifyCopiedCode...............................................................455
;   §3: FUNCTIONS for interacting with online WEB DESIGN INTERFACES............................469
;     >>> §3.1: LoadWordPressSiteInChrome......................................................473
;   §4: GUI FUNCTIONS for handling user interactions with scripts..............................509
;     >>> §4.1: @postMinCss....................................................................513
;       →→→ §4.1.1: HandlePostCssCheckAllSites.................................................553
;       →→→ §4.1.2: HandlePostCssUncheckAllSites...............................................573
;       →→→ §4.1.3: HandlePostMinCssCancel.....................................................593
;       →→→ §4.1.4: HandlePostMinCssOK.........................................................600
;       →→→ §4.1.5: PasteMinCssToWebsite.......................................................667
;     >>> §4.2: @postBackupCss.................................................................678
;       →→→ §4.2.1: HandlePostBackupCssCheckAllSites...........................................723
;       →→→ §4.2.2: HandlePostBackupCssUncheckAllSites.........................................743
;       →→→ §4.2.3: HandlePostBackupCssCancel..................................................763
;       →→→ §4.2.4: HandlePostBackupCssOK......................................................770
;     >>> §4.3: @postMinJs.....................................................................833
;       →→→ §4.3.1: HandlePostJsCheckAllSites..................................................884
;       →→→ §4.3.2: HandlePostJsUncheckAllSites................................................904
;       →→→ §4.3.3: HandlePostMinJsCancel......................................................924
;       →→→ §4.3.4: HandlePostMinJsOK..........................................................931
;       →→→ §4.3.5: PasteMinJsToWebsite.......................................................998
;   §5: UTILITY HOTSTRINGS for working with GitHub Desktop....................................1013
;     >>> §5.1: FILE COMMITTING...............................................................1017
;     >>> §5.2: STATUS CHECKING...............................................................1167
;       →→→ §5.2.1: @doGitStataus & @dogs.....................................................1170
;       →→→ §5.2.2: @doGitDiff & @dogd........................................................1190
;       →→→ §5.2.3: @doGitLog & @dogl.........................................................1210
;     >>> §5.3: Automated PASTING OF CSS/JS into online web interfaces........................1231
;       →→→ §5.3.1: @initCssPaste.............................................................1234
;       →→→ §5.3.2: @doCssPaste...............................................................1262
;       →→→ §5.3.3: @pasteGitCommitMsg........................................................1323
;       →→→ §5.3.4: ExecuteCssPasteCmds.......................................................1339
;       →→→ §5.3.5: ExecuteJsPasteCmds........................................................1373
;   §6: COMMAND LINE INPUT GENERATION SHORTCUTS...............................................1414
;     >>> §6.1: Shortucts for backing up custom CSS builds....................................1418
;       →→→ §6.1.1: @BackupCss................................................................1421
;       →→→ §6.1.2: @backupCssAscc............................................................1434
;       →→→ §6.1.3: @backupCssCr..............................................................1443
;       →→→ §6.1.4: @backupCssDsp.............................................................1452
;       →→→ §6.1.5: @backupCssFye.............................................................1461
;       →→→ §6.1.6: @backupCssFyf.............................................................1478
;       →→→ §6.1.7: @backupCssNse.............................................................1496
;       →→→ §6.1.8: @backupCssOue.............................................................1513
;       →→→ §6.1.9: @backupCssPbk.............................................................1530
;       →→→ §6.1.10: @backupCssSurca..........................................................1547
;       →→→ §6.1.11: @backupCssSumRes.........................................................1564
;       →→→ §6.1.12: @backupCssXfer...........................................................1582
;       →→→ §6.1.13: @backupCssUgr............................................................1600
;       →→→ §6.1.14: @backupCssXfer...........................................................1610
;       →→→ §6.1.15: @backupCssUcrAss.........................................................1627
;       →→→ §6.1.16: @backupCssAll............................................................1645
;       →→→ §6.1.17: CopyCssFromWebsite.......................................................1668
;       →→→ §6.1.18: ExecuteCssCopyCmds.......................................................1678
;     >>> §6.2: Shortcuts for rebuilding & committing custom CSS files........................1697
;       →→→ §6.2.1: @rebuildCssHere...........................................................1700
;       →→→ §6.2.2: @rebuildCssAscc...........................................................1710
;       →→→ §6.2.3: @commitCssAscc............................................................1722
;       →→→ §6.2.4: @rebuildCssCr.............................................................1737
;       →→→ §6.2.5: @commitCssCr..............................................................1749
;       →→→ §6.2.6: @rebuildCssDsp............................................................1764
;       →→→ §6.2.7: @commitCssDsp.............................................................1776
;       →→→ §6.2.8: @rebuildCssFye............................................................1791
;       →→→ §6.2.9: @commitCssFye.............................................................1803
;       →→→ §6.2.10: @rebuildCssFyf...........................................................1819
;       →→→ §6.2.11: @commitCssFyf............................................................1831
;       →→→ §6.2.12: @rebuildCssNse...........................................................1844
;       →→→ §6.2.13: @commitCssNse............................................................1856
;       →→→ §6.2.14: @rebuildCssOue...........................................................1871
;       →→→ §6.2.15: @commitCssOue............................................................1883
;       →→→ §6.2.16: @rebuildCssPbk...........................................................1899
;       →→→ §6.2.17: @commitCssPbk............................................................1911
;       →→→ §6.2.18: @rebuildCssSurca.........................................................1927
;       →→→ §6.2.19: @commitCssSurca..........................................................1939
;       →→→ §6.2.20: @rebuildCssSumRes........................................................1954
;       →→→ §6.2.21: @commitCssSumRes.........................................................1966
;       →→→ §6.2.22: @rebuildCssXfer..........................................................1981
;       →→→ §6.2.23: @commitCssXfer...........................................................1993
;       →→→ §6.2.24: @rebuildCssUgr...........................................................2009
;       →→→ §6.2.25: @commitCssUgr............................................................2021
;       →→→ §6.2.26: @rebuildCssUcore.........................................................2036
;       →→→ §6.2.27: @commitCssUcore..........................................................2048
;       →→→ §6.2.28: @rebuildCssUcrAss........................................................2063
;       →→→ §6.2.29: @commitCssUcrAss.........................................................2075
;       →→→ §6.2.30: @rebuildCssAll...........................................................2090
;     >>> §6.3: Shortcuts for updating CSS submodules.........................................2115
;       →→→ §6.3.1: @updateCssSubmoduleAscc...................................................2118
;       →→→ §6.3.2: @updateCssSubmoduleCr.....................................................2135
;       →→→ §6.3.3: @updateCssSubmoduleDsp....................................................2152
;       →→→ §6.3.4: @updateCssSubmoduleFye....................................................2169
;       →→→ §6.3.5: @updateCssSubmoduleFyf....................................................2186
;       →→→ §6.3.6: @updateCssSubmoduleNse....................................................2203
;       →→→ §6.3.7: @updateCssSubmoduleOue....................................................2220
;       →→→ §6.3.8: @updateCssSubmodulePbk....................................................2237
;       →→→ §6.3.9: @updateCssSubmoduleSurca..................................................2254
;       →→→ §6.3.10: @updateCssSubmoduleSumRes................................................2271
;       →→→ §6.3.11: @updateCssSubmoduleXfer..................................................2288
;       →→→ §6.3.12: @updateCssSubmoduleUgr...................................................2305
;       →→→ §6.3.13: @updateCssSubmoduleUcore.................................................2322
;       →→→ §6.3.14: @updateCssSubmoduleUcrAss................................................2339
;       →→→ §6.3.15: @updateCssSubmoduleAll...................................................2356
;     >>> §6.4: For copying minified, backup css files to clipboard...........................2382
;       →→→ §6.4.1: @copyMinCssAscc...........................................................2385
;       →→→ §6.4.2: @copyBackupCssAscc........................................................2395
;       →→→ §6.4.3: @copyMinCssCr.............................................................2405
;       →→→ §6.4.4: @copyBackupCssCr..........................................................2415
;       →→→ §6.4.5: @copyMinCssDsp............................................................2425
;       →→→ §6.4.6: @copyBackupCssDsp.........................................................2435
;       →→→ §6.4.7: @copyMinCssFye............................................................2445
;       →→→ §6.4.8: @copyBackupCssFye.........................................................2457
;       →→→ §6.4.9: @copyMinCssFyf............................................................2467
;       →→→ §6.4.10: @copyBackupCssFyf........................................................2477
;       →→→ §6.4.11: @copyMinCssNse...........................................................2487
;       →→→ §6.4.12: @copyBackupCssNse........................................................2497
;       →→→ §6.4.13: @copyMinCssOue...........................................................2507
;       →→→ §6.4.14: @copyMinCssPbk...........................................................2517
;       →→→ §6.4.15: @copyBackupCssPbk........................................................2527
;       →→→ §6.4.16: @copyMinCssSurca.........................................................2537
;       →→→ §6.4.17: @copyBackupCssSurca......................................................2547
;       →→→ §6.4.18: @copyMinCssSumRes........................................................2557
;       →→→ §6.4.19: @copyBackupCssSumRes.....................................................2567
;       →→→ §6.4.20: @copyMinCssXfer..........................................................2577
;       →→→ §6.4.21: @copyBackupCssXfer.......................................................2587
;       →→→ §6.4.22: @copyMinCssUgr...........................................................2597
;       →→→ §6.4.23: @copyBackupCssUgr........................................................2608
;       →→→ §6.4.24: @copyMinCssUcore.........................................................2618
;       →→→ §6.4.25: @copyBackupCssUcore......................................................2628
;       →→→ §6.4.26: @copyMinCssUcrAss........................................................2638
;       →→→ §6.4.27: @copyBackupCssUcrAss.....................................................2648
;     >>> §6.5: FOR BACKING UP CUSTOM JS BUILDS...............................................2658
;       →→→ §6.5.1: BackupJs..................................................................2661
;       →→→ §6.5.2: @backupJsAscc.............................................................2675
;       →→→ §6.5.3: @backupJsCr...............................................................2690
;       →→→ §6.5.4: @backupJsDsp..............................................................2706
;       →→→ §6.5.5: @backupJsFye..............................................................2716
;       →→→ §6.5.6: @backupJsFyf..............................................................2732
;       →→→ §6.5.7: @backupJsNse..............................................................2748
;       →→→ §6.5.8: @backupJsOue..............................................................2762
;       →→→ §6.5.9: @backupJsPbk..............................................................2776
;       →→→ §6.5.10: @backupJsSurca...........................................................2792
;       →→→ §6.5.11: @backupJsSumRes..........................................................2807
;       →→→ §6.5.12: @commitBackupJsSumRes....................................................2819
;       →→→ §6.5.13: @backupJsXfer............................................................2831
;       →→→ §6.5.14: @backupJsUgr.............................................................2847
;       →→→ §6.5.15: @backupJsUcore...........................................................2857
;       →→→ §6.5.16: @backupJsUcrAss..........................................................2872
;       →→→ §6.5.17: @backupJsAll.............................................................2888
;       →→→ §6.5.18: CopyJsFromWebsite........................................................2914
;       →→→ §6.5.19: ExecuteJsCopyCmds........................................................2925
;     >>> §6.6: FOR REBUILDING JS SOURCE FILES................................................2941
;       →→→ §6.6.1: RebuildJs.................................................................2944
;       →→→ §6.6.2: @rebuildJsAscc............................................................2954
;       →→→ §6.6.3: @rebuildJsCr..............................................................2961
;       →→→ §6.6.4: @rebuildJsDsp.............................................................2980
;       →→→ §6.6.5: @rebuildJsFye.............................................................2995
;       →→→ §6.6.6: @rebuildJsFyf.............................................................3014
;       →→→ §6.6.7: @rebuildJsNse.............................................................3033
;       →→→ §6.6.8: @rebuildJsOue.............................................................3052
;       →→→ §6.6.9: @rebuildJsPbk.............................................................3071
;       →→→ §6.6.10: @rebuildJsSurca..........................................................3090
;       →→→ §6.6.11: @rebuildJsSumRes.........................................................3097
;       →→→ §6.6.12: @rebuildJsXfer...........................................................3109
;       →→→ §6.6.13: @rebuildJsUgr............................................................3121
;       →→→ §6.6.14: @rebuildJsUcore..........................................................3133
;       →→→ §6.6.15: @rebuildJsUcrAss.........................................................3146
;     >>> §6.7: FOR UPDATING JS SUBMODULES....................................................3165
;       →→→ §6.7.1: @commitJsAscc.............................................................3168
;       →→→ §6.7.2: @commitJsDsp..............................................................3177
;       →→→ §6.7.3: @commitJsSurca............................................................3186
;       →→→ §6.7.4: @commitJsSumRes...........................................................3195
;       →→→ §6.7.5: @commitJsXfer.............................................................3204
;       →→→ §6.7.6: @commitJsUgr..............................................................3213
;       →→→ §6.7.7: @commitJsUcore............................................................3222
;     >>> §6.8: FOR UPDATING JS SUBMODULES....................................................3231
;       →→→ §6.8.1: UpdateJsSubmodule.........................................................3234
;       →→→ §6.8.2: @updateJsSubmoduleAscc....................................................3248
;       →→→ §6.8.3: @updateJsSubmoduleCr......................................................3255
;       →→→ §6.8.4: @updateJsSubmoduleDsp.....................................................3263
;       →→→ §6.8.5: @updateJsSubmoduleFye.....................................................3271
;       →→→ §6.8.6: @updateJsSubmoduleFyf.....................................................3278
;       →→→ §6.8.7: @updateJsSubmoduleNse.....................................................3286
;       →→→ §6.8.8: @updateJsSubmoduleOue.....................................................3293
;       →→→ §6.8.9: @updateJsSubmodulePbk.....................................................3300
;       →→→ §6.8.10: @updateJsSubmoduleSurca..................................................3307
;       →→→ §6.8.11: @updateJsSubmoduleSumRes.................................................3314
;       →→→ §6.8.12: @updateJsSubmoduleXfer...................................................3322
;       →→→ §6.8.13: @updateJsSubmoduleUgr....................................................3330
;       →→→ §6.8.14: @updateJsSubmoduleUcore..................................................3337
;       →→→ §6.8.15: @updateJsSubmoduleUcrAss.................................................3344
;       →→→ §6.8.16: @updateJsSubmoduleAll....................................................3352
;     >>> §6.9: Shortcuts for copying minified JS to clipboard................................3379
;       →→→ §6.9.1: @copyMinJsAscc............................................................3384
;       →→→ §6.9.2: @copyMinJsCr..............................................................3395
;       →→→ §6.9.3: @copyMinJsDsp.............................................................3406
;       →→→ §6.9.4: @copyMinJsFye.............................................................3417
;       →→→ §6.9.5: @copyMinJsFyf.............................................................3428
;       →→→ §6.9.6: @copyMinJsNse.............................................................3439
;       →→→ §6.9.7: @copyMinJsOue.............................................................3450
;       →→→ §6.9.8: @copyBackupJsOue..........................................................3461
;       →→→ §6.9.9: @copyMinJsPbk.............................................................3472
;       →→→ §6.9.10: @copyMinJsSurca..........................................................3483
;       →→→ §6.9.11: @copyMinJsSumRes.........................................................3494
;       →→→ §6.9.12: @copyMinJsXfer...........................................................3505
;       →→→ §6.9.13: @copyMinJsUgr............................................................3516
;       →→→ §6.9.14: @copyMinJsUcore..........................................................3526
;       →→→ §6.9.15: @copyBackupJsUcore.......................................................3537
;       →→→ §6.9.16: @copyMinJsUcrAss.........................................................3548
;     >>> §6.10: FOR CHECKING GIT STATUS ON ALL PROJECTS .....................................3559
;   §7: KEYBOARD SHORTCUTS FOR POWERSHELL.....................................................3645
;     >>> §7.1: SHORTCUTS.....................................................................3649
;     >>> §7.2: SUPPORTING FUNCTIONS..........................................................3676
; ==================================================================================================

sgIsPostingMinCss := false
sgIsPostingMinJs := false

; --------------------------------------------------------------------------------------------------
;   §1: SETTINGS accessed via functions for this imported file
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: GetCmdForMoveToCSSFolder

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

;   ································································································
;     >>> §1.2: GetCurrentDirFrom

GetCurrentDirFromPS() {
	copyDirCmd := "(get-location).ToString() | clip`r`n"
	PasteTextIntoGitShell("", copyDirCmd)
	while(Clipboard = copyDirCmd) {
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
	if (!varDeclared) {
		MsgBox, % (0x0 + 0x10), % "ERROR: Upstream dependency missing in github.ahk"
			, % "The global variable specifying the user's account folder has not been declared "
			. "and set upstream."
	}
	Return varDeclared
}

; --------------------------------------------------------------------------------------------------
;   §2: FUNCTIONS for working with GitHub Desktop
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: ActivateGitShell

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

;   ································································································
;     >>> §2.2: CommitAfterBuild

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
			errorMsg .= "Function was called with an invalid argument for the calling build "
				. "command: " . ahkBuildCmd . "."
			if (!qcAhkCommitCmd) {
				errorMsg .= "The argument for the commit command to call next was also invalid: "
					. ahkCommitCmd . "."
			}		
		} else {
			errorMsg .= "Function was called from the build command " . ahkBuildCmd
				. ", but an invalid argument for the commit command was found: " . ahkCommitCmd
				. "."
		}
	}
	if (errorMsg != "") {
		MsgBox, % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
}

;   ································································································
;     >>> §2.3: EscapeCommitMessage
;       Escape commit message strings for use in PowerShell. Assumes that double quotes are used to
;       enclose the string.

EscapeCommitMessage(msgToEscape) {
	escapedMsg := RegExReplace(msgToEscape, "m)("")", "`$1")
	return escapedMsg
}

;   ································································································
;     >>> §2.4: Git commit GUI — Imports

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.1: For committing CSS builds

#Include %A_ScriptDir%\CommitCssBuild.ahk

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.2: For committing JS builds

#Include %A_ScriptDir%\CommitJsBuild.ahk

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.3: For committing any type of file

#Include %A_ScriptDir%\CommitAnyFile.ahk

;   ································································································
;     >>> §2.5: CopySrcFileToClipboard

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

;   ································································································
;     >>> §2.6: IsGitShellActive

IsGitShellActive() {
	Return IsPowerShellActive()
}

;   ································································································
;     >>> §2.7: PasteTextIntoGitShell

PasteTextIntoGitShell(ahkCmdName, shellText) {
	errorMsg := ""
	if (UserFolderIsSet()) {
		proceedWithPaste := ActivateGitShell()
		if (proceedWithPaste) {
			SendInput, {Esc}
			Sleep, 20
			GetCursorCoordsToCenterInActiveWindow(newPosX, newPosY)
			clipboard = %shellText%
			Click right %newPosX%, %newPosY%
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

;   ································································································
;     >>> §2.8: ToEscapedPath

ToEscapedPath(path) {
	escapedPath := StrReplace(path, "\", "\\")
	Return escapedPath
}

;   ································································································
;     >>> §2.9: VerifyCopiedCode

VerifyCopiedCode(callerStr, copiedCss) {
	proceed := False
	title := "VerifyCopiedCode(...)"
	msg := "Here's what I copied:`n" . SubStr(copiedCss, 1, 320) . "..."
		. "`n`nProceed with git commit?"
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
		Sleep, 500
		proceed := false
		WinGetTitle, thisTitle, A
		IfNotInString, thisTitle, % "New Tab"
			proceed := true
		while (!proceed) {
			Sleep 500
			WinGetTitle, thisTitle, A
			IfNotInString, thisTitle, % "New Tab"
				proceed := true
		}
		Sleep, 500
	}
}

; --------------------------------------------------------------------------------------------------
;   §4: GUI FUNCTIONS for handling user interactions with scripts
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §4.1: @postMinCss

:*:@postMinCss::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	if(!sgIsPostingMinCss) {
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

HandlePostMinCssOK() {
	global
	Gui, guiPostMinCss: Submit
	Gui, guiPostMinCss: Destroy
	sgIsPostingMinCss := true
	local postMinCssAutoMode := false
	if (RadioGroupPostMinCssAutoMode == 2) {
		postMinCssAutoMode := true
	}
	if (PostMinCssToAscc) {
		PasteMinCssToWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssAscc", postMinCssAutoMode)
	}
	if (PostMinCssToCr) {
		PasteMinCssToWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssCr", postMinCssAutoMode)
	}
	if (PostMinCssToDsp) {
		PasteMinCssToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/"
			. "themes.php?page=editcss", ":*:@copyMinCssDsp", postMinCssAutoMode)
	}
	if (PostMinCssToFye) {
		PasteMinCssToWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssFye", postMinCssAutoMode)
	}
	if (PostMinCssToFyf) {
		PasteMinCssToWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssFyf", postMinCssAutoMode)
	}
	if (PostMinCssToNse) {
		PasteMinCssToWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssNse", postMinCssAutoMode)
	}
	if (PostMinCssToPbk) {
		PasteMinCssToWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssPbk", postMinCssAutoMode)
	}
	if (PostMinCssToSurca) {
		PasteMinCssToWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssSurca", postMinCssAutoMode)
	}
	if (PostMinCssToSumRes) {
		PasteMinCssToWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssSumRes", postMinCssAutoMode)
	}
	if (PostMinCssToXfer) {
		PasteMinCssToWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssXfer", postMinCssAutoMode)
	}
	if (PostMinCssToUgr) {
		PasteMinCssToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/"
			. "themes.php?page=editcss", ":*:@copyMinCssUgr", postMinCssAutoMode)
	}
	if (PostMinCssToUcore) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssUcore", postMinCssAutoMode)
	}
	if (PostMinCssToUcrAss) {
		PasteMinCssToWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=editcss"
			, ":*:@copyMinCssUcrAss", postMinCssAutoMode)
	}
	sgIsPostingMinCss := false
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.5: PasteMinCssToWebsite

PasteMinCssToWebsite(websiteUrl, cssCopyCmd, manualProcession := false) {
	delay := 1000
	LoadWordPressSiteInChrome(websiteUrl)
	Gosub, %cssCopyCmd%
	Sleep, % delay
	ExecuteCssPasteCmds(manualProcession)
}

;   ································································································
;     >>> §4.2: @postBackupCss

:*:@postBackupCss::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.1: HandlePostBackupCssCheckAllSites

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.2: HandlePostBackupCssUncheckAllSites

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.3: HandlePostBackupCssCancel

HandlePostBackupCssCancel() {
	Gui, guiPostBackupCss: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.4: HandlePostBackupCssOK

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
		PasteMinCssToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/"
		. "themes.php?page=editcss", ":*:@copyBackupCssDsp")
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
		PasteMinCssToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/"
			. "themes.php?page=editcss", ":*:@copyBackupCssUgr")
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

;   ································································································
;     >>> §4.3: @postMinJs

:*:@postMinJs::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	if(!sgIsPostingMinJs) {
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
;       →→→ §4.3.1: HandlePostJsCheckAllSites

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
;       →→→ §4.3.2: HandlePostJsUncheckAllSites

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
;       →→→ §4.3.3: HandlePostMinJsCancel

HandlePostMinJsCancel() {
	Gui, Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.4: HandlePostMinJsOK

HandlePostMinJsOK() {
	global
	Gui, Submit
	Gui, Destroy
	sgIsPostingMinJs := true
	local postMinJsAutoMode := false
	if (RadioGroupPostMinJsAutoMode == 2) {
		postMinJsAutoMode := true
	}
	if (PostMinJsToAscc) {
		PasteMinJsToWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsAscc", postMinJsAutoMode)
	}
	if (PostMinJsToCr) {
		PasteMinJsToWebsite("https://commonreading.wsu.edu/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsCr", postMinJsAutoMode)
	}
	if (PostMinJsToDsp) {
		PasteMinJsToWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsDsp", postMinJsAutoMode)
	}
	if (PostMinJsToFye) {
		PasteMinJsToWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsFye", postMinJsAutoMode)
	}
	if (PostMinJsToFyf) {
		PasteMinJsToWebsite("https://learningcommunities.wsu.edu/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsFyf", postMinJsAutoMode)
	}
	if (PostMinJsToNse) {
		PasteMinJsToWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsNse", postMinJsAutoMode)
	}
	if (PostMinJsToPbk) {
		PasteMinJsToWebsite("https://phibetakappa.wsu.edu/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsPbk", postMinJsAutoMode)
	}
	if (PostMinJsToSurca) {
		PasteMinJsToWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsSurca", postMinJsAutoMode)
	}
	if (PostMinJsToSumRes) {
		PasteMinJsToWebsite("https://summerresearch.wsu.edu/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsSumRes", postMinJsAutoMode)
	}
	if (PostMinJsToXfer) {
		PasteMinJsToWebsite("https://transfercredit.wsu.edu/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsXfer", postMinJsAutoMode)
	}
	if (PostMinJsToUgr) {
		PasteMinJsToWebsite("https://undergraduateresearch.wsu.edu/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsUgr", postMinJsAutoMode)
	}
	if (PostMinJsToUcore) {
		PasteMinJsToWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=custom-javascript"
			, ":*:@copyMinJsUcore", postMinJsAutoMode)
	}
	if (PostMinJsToUcrAss) {
		PasteMinJsToWebsite("https://ucore.wsu.edu/assessment/wp-admin/"
			. "themes.php?page=custom-javascript", ":*:@copyMinJsUcrAss", postMinJsAutoMode)
	}
	sgIsPostingMinJs := false
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.5: PasteMinJsToWebsite

PasteMinJsToWebsite(websiteUrl, jsCopyCmd, manualProcession := false) {
	LoadWordPressSiteInChrome(websiteUrl)
	if (manualProcession) {
		MsgBox, 48, % "ExecuteJsPasteCmds", % "Press OK to proceed with " . jsCopyCmd . " command."
	} else {
		Sleep, 1000
	}
	Gosub, %jsCopyCmd%
	Sleep, 120
	ExecuteJsPasteCmds(manualProcession)
}

; --------------------------------------------------------------------------------------------------
;   §5: UTILITY HOTSTRINGS for working with GitHub Desktop
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: FILE COMMITTING
; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@getGitCommitLog::
	thisAhkCmd := A_ThisLabel

	AppendAhkCmd(thisAhkCmd)
	PasteTextIntoGitShell(thisAhkCmd, "git log -p --since='last month' "
		. "--pretty=format:'%h|%an|%ar|%s|%b' > git-log.txt`r")
Return

:*:@getNoDiffGitCommitLog::
	thisAhkCmd := A_ThisLabel

	AppendAhkCmd(thisAhkCmd)
	PasteTextIntoGitShell(thisAhkCmd, "git log --since='last month' "
		. "--pretty=format:'%h|%an|%ar|%s|%b' > git-log.txt`r")
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@findGitChangesRegEx::
	thisAhkCmd := A_ThisLabel
	targetProcesses := ["notepad++.exe", "sublime_text.exe"]
	notActiveErrMsg := "Please ensure Notepad++ or Sublime Text are active before activating this "
		. "hotstring."

	AppendAhkCmd(thisAhkCmd)
	activeProcessName := areTargetProcessesActive(targetProcesses, thisAhkCmd, notActiveErrMsg)
	if (activeProcessName == targetProcess[1]) {
		FindGitChangesRegExNotepadPp()
	} else {
		FindGitChangesRegExSublimeText()		
	}
Return

FindGitChangesRegExNotepadPp() {
	SendInput, % "^h"
	Sleep, 200
	SendInput, % "{^}(?:[{^} -].*| (?{!} {{}7{}}).*|-(?{!}-{{}7{}}).*)?$(?:\r\n)?"
	Sleep, 20
	SendInput, % "{Tab}"
	Sleep, 20
	SendInput, % "{Del}"
}

FindGitChangesRegExSublimeText() {
	delay := 60
	SendInput, % "{Esc}"
	Sleep, % delay
	SendInput, % "^h"
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

:*:@gitAddThis::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
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
	} else {
		MsgBox, % (0x0 + 0x10), % "ERROR: Notepad++ Not Active"
			, % "Please activate Notepad++ and ensure the correct file is selected before "
			. "attempting to utilize this hotstring, which is designed to create a 'git add' "
			. "command for pasting into PowerShell based on Notepad++'s Edit > Copy to Clipboard "
			. "> Current Full File Path to Clipboard menu command."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@doGitCommit::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput git commit -m '' -m ''{Left 7}
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doGitCommit" . "): Could Not Locate Git "
			. "PowerShell", % "The Git PowerShell process could not be located and activated."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@dogc::
	Gosub, :*:@doGitCommit
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@doSnglGitCommit::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput git commit -m ''{Left 1}
	}
	else {
		MsgBox, % (0x0 + 0x10), % "ERROR (" . ":*:@doSnglGitCommit" . "): Could Not Locate Git "
			. "PowerShell", % "The Git PowerShell process could not be located and activated."
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@dosgc::
	Gosub, :*:@doSnglGitCommit
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

; For reversing forward slashes within a copied file name reported by 'git status' in PowerShell 
; and then pasting the result into PowerShell.
:*:@swapSlashes::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "PowerShell.exe") {
		newText := RegExReplace(clipboard, "/", "\")
		clipboard := newText

		;TODO: Check to see if the mouse cursor is already within the PowerShell bounding rectangle 
		Click right 44, 55

	}    
Return

;   ································································································
;     >>> §5.2: STATUS CHECKING

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.1: @doGitStataus & @dogs
;
;	Shortcut for "git status" command in PowerShell.

:*:@doGitStatus::
	AppendAhkCmd(A_ThisLabel)
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput % "git status{enter}"
	} else {
		MsgBox % (0x0 + 0x10), % "ERROR (" . A_ThisLabel . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

:*:@dogs::
	Gosub :*:@doGitStatus
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.2: @doGitDiff & @dogd
;
;	Shortcut for "git diff" command in PowerShell.

:*:@doGitDiff::
	AppendAhkCmd(A_ThisLabel)
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput % "git --no-pager diff "
	} else {
		MsgBox % (0x0 + 0x10), % "ERROR (" . A_ThisLabel . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

:*:@dogd::
	Gosub :*:@doGitDiff
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.2.3: @doGitLog & @dogl
;
;	Shortcut for "git log" command in PowerShell.


:*:@doGitLog::
	AppendAhkCmd(A_ThisLabel)
	proceedWithCmd := ActivateGitShell()
	if(proceedWithCmd) {
		SendInput % "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s | %b"" "
	} else {
		MsgBox % (0x0 + 0x10), % "ERROR (" . A_ThisLabel . "): Could Not Locate Git PowerShell"
			, % "The Git PowerShell process could not be located and activated."
	}
Return

:*:@dogl::
	Gosub :*:@doGitLog
Return

;   ································································································
;     >>> §5.3: Automated PASTING OF CSS/JS into online web interfaces

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.1: @initCssPaste
;
;	Initialize a tab in Chrome for automated repeated CSS pasting.

:*:@initCssPaste::
;	prevTitleMatchMode := A_TitleMatchMode
;	SetTitleMatchMode, RegEx
;	SetTitleMatchMode, prevTitleMatchMode
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
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
			, % "Please select your CSS stylesheet editor tab in Chrome as the currently active "
			. "window."
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.2: @doCssPaste
;
;	Paste CSS into a tab in Chrome previously initialized by the @initCssPaste command.

:*:@doCssPaste::		;Paste copied CSS into WordPress window
	global hwndCssPasteWindow
	global titleCssPasteWindowTab
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	if(isVarDeclared(hwndCssPasteWindow)) {
		; Attempt to switch to chrome
		WinActivate, % "ahk_id " . hwndCssPasteWindow
		WinWaitActive, % "ahk_id " . hwndCssPasteWindow, , 1
		if (ErrorLevel) {
			MsgBox, % (0x0 + 0x10), % "ERROR (:*:@doCssPaste): Could Not Find Process"
				, % "The HWND set for the chrome window containing the tab in which the CSS "
				. "stylesheet editor was loaded can no longer be found."
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
				; Add check for expected client coordinates; if not correct, then reset window 
				; position
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
			, % "You haven't yet used the @setCssPasteWindow hotstring to set the HWND for the "
			. "Chrome window containing a tab with the CSS stylsheet editor."
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.3: @pasteGitCommitMsg
;
;	Paste commit messages copied from GitHub.com into PowerShell with proper formatting.

:*:@pasteGitCommitMsg::
	thisAhkCmd := A_ThisLabel
	AppendAhkCmd(thisAhkCmd)
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "PowerShell.exe") {
		commitText := RegExReplace(clipboard, Chr(0x2026) "\R" Chr(0x2026), "")
		clipboard = %commitText%
		Click right 44, 55
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.4: ExecuteCssPasteCmds
;
;	Perform the steps necessary to paste built CSS into a Chrome tab loaded with a WSUWP CSS
;	Stylesheet Editor page and apply it to the according website.

ExecuteCssPasteCmds(manualProcession := false) {
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch(clipboard, "^/\*! Built with the Less CSS preprocessor")
	if (posFound != 0) {
		Click, 768, 570
		Sleep, 100
		SendInput, ^a
		Sleep 330
		if (manualProcession) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with paste command."
		}
		SendInput, ^v
		Sleep 330
		if (manualProcession) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with update button selection."
		}
		Click, 1565, 370
		Sleep, 60
		Click, 1565, 405
		Sleep, 60
	} else {
		MsgBox, % (0x0 + 0x10)
			, % "ERROR (" . A_ThisFunc .  "): Clipboard Has Unexpected Contents"
			, % "The clipboard does not begin with the expected '@import ...,' and thus may not "
			. "contain minified CSS."
	}			
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.3.5: ExecuteJsPasteCmds
;
;	Perform the steps necessary to paste built JS into a Chrome tab loaded with a WSUWP Custom
;	Javascript Editor page and apply it to the according website.

ExecuteJsPasteCmds(manualProcession := false) {
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch(clipboard, "^(?:// Built with Node.js)|(?:/\*!\*+`n \* jQuery.oue-custom"
		. ".js)")
	if (posFound != 0) {
		Click, 461, 371
		Sleep, 330
		SendInput, ^a
		if (manualProcession) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with paste command."
			Sleep 330
		} else {
			Sleep, 2500
		}
		SendInput, ^v
		if (manualProcession) {
			MsgBox, 48, % A_ThisFunc, % "Press OK to proceed with update button "
				. "selection."
			Sleep 330
		} else {
			Sleep, 10000
		}
		Click, 214, 565
		Sleep, 60
		Click, 214, 615
		Sleep 1000
	}
	else {
		MsgBox, % (0x0 + 0x10)
			, % "ERROR (" . A_ThisFunc . "): Clipboard Has Unexpected Contents"
			, % "The clipboard does not begin with the expected '// Built with Node.js ...,' and "
			. "thus may not contain minified JS."
	}			
}

; --------------------------------------------------------------------------------------------------
;   §6: COMMAND LINE INPUT GENERATION SHORTCUTS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §6.1: Shortucts for backing up custom CSS builds

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.1: @BackupCss

BackupCss(caller, website, repository, backupFile) {
	AppendAhkCmd(caller)
	copiedCss := CopyCssFromWebsite(website)
	if (VerifyCopiedCode(caller, copiedCss)) {
		WriteCodeToFile(caller, copiedCss, repository . backupFile)
		PasteTextIntoGitShell(caller, "cd '" . repository . "'`rgit add " . backupFile
			. "`rgit commit -m 'Updating backup of latest verified custom CSS build'`rgit push`r")
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.2: @backupCssAscc

:*:@backupCssAscc::
	BackupCss(A_ThisLabel
		, "https://ascc.wsu.edu/wp-admin/themes.php?page=editcss"
		, GetGitHubFolder() . "\ascc.wsu.edu\", "CSS\ascc-custom.prev.css")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.3: @backupCssCr

:*:@backupCssCr::
	BackupCss(A_ThisLabel
		, "https://commonreading.wsu.edu/wp-admin/themes.php?page=editcss"
		, GetGitHubFolder() . "\commonreading.wsu.edu\", "CSS\cr-custom.prev.css")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.4: @backupCssDsp

:*:@backupCssDsp::
	BackupCss(A_ThisLabel
		, "https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=editcss"
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\", "CSS\dsp-custom.prev.css")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.5: @backupCssFye

:*:@backupCssFye::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\firstyear.wsu.edu\CSS\fye-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu\'`r"
			. "git add CSS\fye-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.6: @backupCssFyf

:*:@backupCssFyf::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=e"
		. "ditcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu\'`r"
			. "git add CSS\learningcommunities-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.7: @backupCssNse

:*:@backupCssNse::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.pr"
			. "ev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\nse.wsu.edu\'`r"
			. "git add CSS\nse-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.8: @backupCssOue

:*:@backupCssOue::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://oue.wsu.edu/wp-admin/themes.php?page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder() . "\oue.wsu.edu\CSS\oue-custom.pr"
			. "ev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\oue.wsu.edu\'`r"
			. "git add CSS\oue-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.9: @backupCssPbk

:*:@backupCssPbk::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\phibetakappa.wsu.edu\CSS\pbk-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu\'`r"
			. "git add CSS\pbk-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.10: @backupCssSurca

:*:@backupCssSurca::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\surca.wsu.edu\CSS\surca-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\surca.wsu.edu\'`r"
			. "git add CSS\surca-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.11: @backupCssSumRes

:*:@backupCssSumRes::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcs"
		. "s")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\summerresearch.wsu.edu\CSS\summerresearch-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\'`r"
			. "git add CSS\summerresearch-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.12: @backupCssXfer

:*:@backupCssXfer::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=editcs"
		. "s")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\transfercredit.wsu.edu\CSS\xfercredit-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu\'`r"
			. "git add CSS\xfercredit-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.13: @backupCssUgr

:*:@backupCssUgr::
	BackupCss(A_ThisLabel
		, "https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=editcss"
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\"
		, "CSS\undergraduate-research-custom.prev.css")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.14: @backupCssXfer

:*:@backupCssUcore::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\ucore.wsu.edu\CSS\ucore-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu\'`r"
			. "git add CSS\ucore-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.15: @backupCssUcrAss

:*:@backupCssUcrAss::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=edit"
		. "css")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment\'`r"
			. "git add CSS\ucore-assessment-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.16: @backupCssAll

:*:@backupCssAll::
	AppendAhkCmd(A_ThisLabel)
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
	PasteTextIntoGitShell(A_ThisLabel
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,300)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.17: CopyCssFromWebsite

CopyCssFromWebsite(websiteUrl)
{
	LoadWordPressSiteInChrome(websiteUrl)
	copiedCss := ExecuteCssCopyCmds()
	return copiedCss
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.1.18: ExecuteCssCopyCmds

ExecuteCssCopyCmds() {
	delay := 200
	Sleep, % delay * 10
	CoordMode, Mouse, Client
	Click, 768, 570
	Sleep, % delay
	SendInput, ^a
	Sleep, % delay
	SendInput, ^c
	Sleep, % delay * 3
	copiedCss := SubStr(clipboard, 1)
	SendInput, ^w
	Sleep, % delay * 10
	return copiedCss
}

;   ································································································
;     >>> §6.2: Shortcuts for rebuilding & committing custom CSS files

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.1: @rebuildCssHere

:*:@rebuildCssHere::
	currentDir := GetCurrentDirFromPS()
	if (GetCmdForMoveToCSSFolder(currentDir) = "awesome!") {
		MsgBox % "Current location: " . currentDir
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.2: @rebuildCssAscc

:*:@rebuildCssAscc::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ascc.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssAscc")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.3: @commitCssAscc

:*:@commitCssAscc::
	gitFolder := "ascc.wsu.edu" ; fp = file path
	lessSrcFile := "ascc-custom_new.less" ; fn = file name
	cssBuildFile := "ascc-custom.css"
	minCssBuildFile := "ascc-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the 
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.4: @rebuildCssCr

:*:@rebuildCssCr::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssCr")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.5: @commitCssCr

:*:@commitCssCr::
	gitFolder := "commonreading.wsu.edu" ; fp = file path
	lessSrcFile := "src_cr-new.less" ; fn = file name
	cssBuildFile := "cr-custom.css"
	minCssBuildFile := "cr-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the 
	;CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.6: @rebuildCssDsp

:*:@rebuildCssDsp::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssDsp")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.7: @commitCssDsp

:*:@commitCssDsp::
	gitFolder := "distinguishedscholarships.wsu.edu" ; fp = file path
	lessSrcFile := "dsp-custom.less" ; fn = file name
	cssBuildFile := "dsp-custom.css"
	minCssBuildFile := "dsp-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.8: @rebuildCssFye

:*:@rebuildCssFye::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssFye")	
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.9: @commitCssFye

:*:@commitCssFye::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu'`r"
		. "git add CSS\fye-custom.css`r"
		. "git add CSS\fye-custom.min.css`r"
		. "git commit -m 'Updating custom CSS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies.' `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.10: @rebuildCssFyf

:*:@rebuildCssFyf::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssFyf")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.11: @commitCssFyf

:*:@commitCssFyf::
	gitFolder := "learningcommunities.wsu.edu"
	lessSrcFile := "learningcommunities-custom.less"
	cssBuildFile := "learningcommunities-custom.css"
	minCssBuildFile := "learningcommunities-custom.min.css"

	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.12: @rebuildCssNse

:*:@rebuildCssNse::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\nse.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssNse")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.13: @commitCssNse

:*:@commitCssNse::
	gitFolder := "nse.wsu.edu" ; fp = file path
	lessSrcFile := "nse-custom.less" ; fn = file name
	cssBuildFile := "nse-custom.css"
	minCssBuildFile := "nse-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.14: @rebuildCssOue

:*:@rebuildCssOue::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\oue.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssOue")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.15: @commitCssOue

:*:@commitCssOue::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\oue.wsu.edu'`r"
		. "git add CSS\oue-custom.css`r"
		. "git add CSS\oue-custom.min.css`r"
		. "git commit -m 'Updating custom CSS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies.' `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.16: @rebuildCssPbk

:*:@rebuildCssPbk::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssPbk")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.17: @commitCssPbk

:*:@commitCssPbk::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu'`r"
		. "git add CSS\pbk-custom.css`r"
		. "git add CSS\pbk-custom.min.css`r"
		. "git commit -m 'Updating custom CSS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies.' `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.18: @rebuildCssSurca

:*:@rebuildCssSurca::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\surca.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssSurca")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.19: @commitCssSurca

:*:@commitCssSurca::
	gitFolder := "surca.wsu.edu" ; fp = file path
	lessSrcFile := "surca-custom.less" ; fn = file name
	cssBuildFile := "surca-custom.css"
	minCssBuildFile := "surca-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.20: @rebuildCssSumRes

:*:@rebuildCssSumRes::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssSumRes")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.21: @commitCssSumRes

:*:@commitCssSumRes::
	gitFolder := "summerresearch.wsu.edu" ; fp = file path
	lessSrcFile := "summerresearch-custom.less" ; fn = file name
	cssBuildFile := "summerresearch-custom.css"
	minCssBuildFile := "summerresearch-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.22: @rebuildCssXfer

:*:@rebuildCssXfer::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssXfer")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.23: @commitCssXfer

:*:@commitCssXfer::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu'`r"
		. "git add CSS\xfercredit-custom.css`r"
		. "git add CSS\xfercredit-custom.min.css`r"
		. "git commit -m 'Updating custom CSS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies.' `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.24: @rebuildCssUgr

:*:@rebuildCssUgr::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssUgr")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.25: @commitCssUgr

:*:@commitCssUgr::
	gitFolder := "undergraduateresearch.wsu.edu" ; fp = file path
	lessSrcFile := "undergraduate-research-custom.less" ; fn = file name
	cssBuildFile := "undergraduate-research-custom.css"
	minCssBuildFile := "undergraduate-research-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.26: @rebuildCssUcore

:*:@rebuildCssUcore::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssUcore")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.27: @commitCssUcore

:*:@commitCssUcore::
	gitFolder := "ucore.wsu.edu" ; fp = file path
	lessSrcFile := "ucore-custom.less" ; fn = file name
	cssBuildFile := "ucore-custom.css"
	minCssBuildFile := "ucore-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.28: @rebuildCssUcrAss

:*:@rebuildCssUcrAss::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssUcrAss")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.29: @commitCssUcrAss

:*:@commitCssUcrAss::
	gitFolder := "ucore.wsu.edu-assessment" ; fp = file path
	lessSrcFile := "ucore-assessment-custom.less" ; fn = file name
	cssBuildFile := "ucore-assessment-custom.css"
	minCssBuildFile := "ucore-assessment-custom.min.css"

	; Register this hotkey with command history interface & process instructions for committing the
	; CSS build
	AppendAhkCmd(A_ThisLabel)
	CommitCssBuild(A_ThisLabel, gitFolder, lessSrcFile, cssBuildFile, minCssBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.2.30: @rebuildCssAll

:*:@rebuildCssAll::
	AppendAhkCmd(A_ThisLabel)
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
	PasteTextIntoGitShell(A_ThisLabel
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r")
Return

;   ································································································
;     >>> §6.3: Shortcuts for updating CSS submodules

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.1: @updateCssSubmoduleAscc

:*:@updateCssSubmoduleAscc::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ascc.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssAscc
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.2: @updateCssSubmoduleCr

:*:@updateCssSubmoduleCr::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssCr
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.3: @updateCssSubmoduleDsp

:*:@updateCssSubmoduleDsp::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating"
		. " recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssDsp
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.4: @updateCssSubmoduleFye

:*:@updateCssSubmoduleFye::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssFye
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.5: @updateCssSubmoduleFyf

:*:@updateCssSubmoduleFyf::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssFyf
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.6: @updateCssSubmoduleNse

:*:@updateCssSubmoduleNse::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\nse.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssNse
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.7: @updateCssSubmoduleOue

:*:@updateCssSubmoduleOue::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\oue.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssOue
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.8: @updateCssSubmodulePbk

:*:@updateCssSubmodulePbk::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssPbk
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.9: @updateCssSubmoduleSurca

:*:@updateCssSubmoduleSurca::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssSurca
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.10: @updateCssSubmoduleSumRes

:*:@updateCssSubmoduleSumRes::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssSumRes
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.11: @updateCssSubmoduleXfer

:*:@updateCssSubmoduleXfer::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssXfer
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.12: @updateCssSubmoduleUgr

:*:@updateCssSubmoduleUgr::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssUgr
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.13: @updateCssSubmoduleUcore

:*:@updateCssSubmoduleUcore::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssUcore
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.14: @updateCssSubmoduleUcrAss

:*:@updateCssSubmoduleUcrAss::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment\WSU-UE---CSS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---CSS`r"
		. "git commit -m 'Updating custom CSS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildCssUcrAss
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.15: @updateCssSubmoduleAll

:*:@updateCssSubmoduleAll::
	AppendAhkCmd(A_ThisLabel)
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
	PasteTextIntoGitShell(A_ThisLabel
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r")
Return

;   ································································································
;     >>> §6.4: For copying minified, backup css files to clipboard

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.1: @copyMinCssAscc

:*:@copyMinCssAscc::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ascc.wsu.edu\CSS\ascc-custom.min.css"
		, "", "Couldn't copy minified CSS for ASCC website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.2: @copyBackupCssAscc

:*:@copyBackupCssAscc::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ascc.wsu.edu\CSS\ascc-custom.min.prev.css"
		, "", "Couldn't copy backup CSS for ASCC Reading website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.3: @copyMinCssCr

:*:@copyMinCssCr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.css"
		, "", "Couldn't copy minified CSS for Common Reading website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.4: @copyBackupCssCr

:*:@copyBackupCssCr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.prev.css"
		, "", "Couldn't copy backup CSS for Common Reading website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.5: @copyMinCssDsp

:*:@copyMinCssDsp::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.min.css"
		, "", "Couldn't copy minified CSS for DSP Website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.6: @copyBackupCssDsp

:*:@copyBackupCssDsp::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.prev.css"
		, "", "Couldn't copy backup CSS for DSP Website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.7: @copyMinCssFye

:*:@copyMinCssFye::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see "
		. "[https://github.com/invokeImmediately/firstyear.wsu.edu] for a repository of source "
		. "code. */`r`n`r`n", "Couldn't copy minified CSS for FYE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.8: @copyBackupCssFye

:*:@copyBackupCssFye::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.prev.css"
		, "", "Couldn't copy backup CSS for FYE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.9: @copyMinCssFyf

:*:@copyMinCssFyf::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.min.css"
		, "", "Couldn't copy minified CSS for First-Year Focus website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.10: @copyBackupCssFyf

:*:@copyBackupCssFyf::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.prev.css"
		, "", "Couldn't copy backup CSS for First-Year Focus website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.11: @copyMinCssNse

:*:@copyMinCssNse::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.min.css"
		, "", "Couldn't copy minified CSS for NSE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.12: @copyBackupCssNse

:*:@copyBackupCssNse::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.prev.css"
		, "", "Couldn't copy backup CSS for NSE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.13: @copyMinCssOue

:*:@copyMinCssOue::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\oue.wsu.edu\CSS\oue-custom.min.css"
		, "", "Couldn't copy minified CSS for OUE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.14: @copyMinCssPbk

:*:@copyMinCssPbk::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.min.css"
		, "", "Couldn't copy minified CSS for Phi Beta Kappa website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.15: @copyBackupCssPbk

:*:@copyBackupCssPbk::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.prev.css"
		, "", "Couldn't copy backup CSS for Phi Beta Kappa website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.16: @copyMinCssSurca

:*:@copyMinCssSurca::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.min.css"
		, "", "Couldn't copy minified CSS for SURCA website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.17: @copyBackupCssSurca

:*:@copyBackupCssSurca::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.prev.css"
		, "", "Couldn't copy backup CSS for SURCA website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.18: @copyMinCssSumRes

:*:@copyMinCssSumRes::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.min.css", ""
		, "Couldn't copy minified CSS for Summer Research website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.19: @copyBackupCssSumRes

:*:@copyBackupCssSumRes::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.prev.css"
		, "", "Couldn't copy backup CSS for Summer Research website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.20: @copyMinCssXfer

:*:@copyMinCssXfer::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.min.css"
		, "", "Couldn't copy minified CSS for Transfer Credit website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.21: @copyBackupCssXfer

:*:@copyBackupCssXfer::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.prev.css"
		, "", "Couldn't copy backup CSS for Transfer Credit website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.22: @copyMinCssUgr

:*:@copyMinCssUgr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\"
		. "undergraduate-research-custom.min.css", ""
		, "Couldn't copy minified CSS for UGR website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.23: @copyBackupCssUgr

:*:@copyBackupCssUgr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.pre"
		. "v.css", "", "Couldn't copy backup CSS for UGR website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.24: @copyMinCssUcore

:*:@copyMinCssUcore::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.min.css"
		, "", "Couldn't copy minified CSS for UCORE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.25: @copyBackupCssUcore

:*:@copyBackupCssUcore::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.prev.css"
		, "", "Couldn't copy backup CSS for UCORE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.26: @copyMinCssUcrAss

:*:@copyMinCssUcrAss::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
		, "", "Couldn't copy minified CSS for UCORE Assessment website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.4.27: @copyBackupCssUcrAss

:*:@copyBackupCssUcrAss::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
		, "", "Couldn't copy backup CSS for UCORE Assessment website.")
Return

;   ································································································
;     >>> §6.5: FOR BACKING UP CUSTOM JS BUILDS

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.1: BackupJs

BackupJs(caller, website, repository, backupFile) {
	AppendAhkCmd(caller)
	CopyJsFromWebsite(website, copiedJs)
	if (VerifyCopiedCode(caller, copiedJs)) {
		WriteCodeToFile(caller, copiedJs, repository . backupFile)
		PasteTextIntoGitShell(caller, "cd '" . repository . "'`rgit add " . backupFile
			. "`rgit commit -m 'Updating backup of latest verified custom JS build'`rgit push`r")
	}
}


;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.2: @backupJsAscc

:*:@backupJsAscc::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\ascc.wsu.edu\JS\ascc-custom.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ascc.wsu.edu\'`r"
		. "git add JS\ascc-custom.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.3: @backupJsCr

:*:@backupJsCr::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\commonreading.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.4: @backupJsDsp

:*:@backupJsDsp::
	BackupJs(A_ThisLabel
		, "https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\"
		, "JS\wp-custom-js-source.min.prev.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.5: @backupJsFye

:*:@backupJsFye::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://firstyear.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\firstyear.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.6: @backupJsFyf

:*:@backupJsFyf::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://learningcommunities.wsu.edu/wp-admin/themes.php?page=custom-javascri"
		. "pt", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\learningcommunities.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.7: @backupJsNse

:*:@backupJsNse::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://nse.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder() . "\nse.wsu.edu\JS\nse-custom.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\nse.wsu.edu\'`r"
		. "git add JS\nse-custom.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.8: @backupJsOue

:*:@backupJsOue::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://oue.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder() . "\oue.wsu.edu\JS\oue-custom.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\oue.wsu.edu\'`r"
		. "git add JS\oue-custom.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.9: @backupJsPbk

:*:@backupJsPbk::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://phibetakappa.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\phibetakappa.wsu.edu\JS\pbk-custom.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu\'`r"
		. "git add JS\pbk-custom.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.10: @backupJsSurca

:*:@backupJsSurca::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://surca.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\surca.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\surca.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.11: @backupJsSumRes

:*:@backupJsSumRes::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\summerresearch.wsu.edu\JS\sumres-build.min.prev.js")
	GoSub, :*:@commitBackupJsSumRes
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.12: @commitBackupJsSumRes

:*:@commitBackupJsSumRes::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\'`r"
		. "git add JS\sumres-build.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.13: @backupJsXfer

:*:@backupJsXfer::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://transfercredit.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.14: @backupJsUgr

:*:@backupJsUgr::
	BackupJs(A_ThisLabel
		, "https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\"
		, "JS\wp-custom-js-source.min.prev.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.15: @backupJsUcore

:*:@backupJsUcore::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://ucore.wsu.edu/wp-admin/themes.php?page=custom-javascript", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.mi"
		. "n.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.16: @backupJsUcrAss

:*:@backupJsUcrAss::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://ucore.wsu.edu/assessment/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\ucore.wsu.edu-assessment\JS\wp-custom-js-source.min.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment\'`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.17: @backupJsAll

:*:@backupJsAll::
	AppendAhkCmd(A_ThisLabel)
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
	PasteTextIntoGitShell(A_ThisLabel
		, "[console]::beep(750,600)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r"
		. "[console]::beep(375,150)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.18: CopyJsFromWebsite

CopyJsFromWebsite(websiteUrl, ByRef copiedJs)
{
	delay := GetDelay("long", 3)
	LoadWordPressSiteInChrome(websiteUrl)
	Sleep % delay
	ExecuteJsCopyCmds(copiedJs)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.5.19: ExecuteJsCopyCmds

ExecuteJsCopyCmds(ByRef copiedJs) {
	CoordMode, Mouse, Client
	Click, 461, 371
	Sleep, 330
	SendInput, ^a
	Sleep, 2500
	SendInput, ^c
	Sleep, 2500
	SendInput, ^w
	copiedJs := SubStr(clipboard, 1)
	Sleep, 2000
}

;   ································································································
;     >>> §6.6: FOR REBUILDING JS SOURCE FILES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.1: RebuildJs

RebuildJs(caller, repository, commitCommand) {
	AppendAhkCmd(caller)
	PasteTextIntoGitShell(caller
		, "cd '" . repository . "'`rgulp buildMinJs`rStart-Sleep -s 1`r[console]::beep(1500,300)`r")
	CommitAfterBuild(caller, commitCommand)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.2: @rebuildJsAscc

:*:@rebuildJsAscc::
	RebuildJs(A_ThisLabel, GetGitHubFolder() . "\ascc.wsu.edu\", ":*:@commitJsAscc")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.3: @rebuildJsCr

:*:@rebuildJsCr::
	ahkCmdName := ":*:@rebuildJsCr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.4: @rebuildJsDsp

:*:@rebuildJsDsp::
	ahkCmdName := ":*:@rebuildJsDsp"
	AppendAhkCmd(ahkCmdName)
	; TODO: Add AHK function for creating a JS build string
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\'`r"
		. "gulp buildMinJs`r"
		. "Start-Sleep -s 1`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitJsDsp")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.5: @rebuildJsFye

:*:@rebuildJsFye::
	ahkCmdName := ":*:@rebuildJsFye"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.6: @rebuildJsFyf

:*:@rebuildJsFyf::
	ahkCmdName := ":*:@rebuildJsFyf"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.7: @rebuildJsNse

:*:@rebuildJsNse::
	ahkCmdName := ":*:@rebuildJsNse"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\nse.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs nse-custom.js --output nse-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\nse.wsu.edu\'`r"
		. "git add JS\nse-custom.js`r"
		. "git add JS\nse-custom.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.8: @rebuildJsOue

:*:@rebuildJsOue::
	ahkCmdName := ":*:@rebuildJsOue"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\oue.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs oue-custom.js --output oue-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\oue.wsu.edu\'`r"
		. "git add JS\oue-custom.js`r"
		. "git add JS\oue-custom.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.9: @rebuildJsPbk

:*:@rebuildJsPbk::
	ahkCmdName := ":*:@rebuildJsPbk"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs pbk-custom.js --output pbk-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu\'`r"
		. "git add JS\pbk-custom.js`r"
		. "git add JS\pbk-custom.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.10: @rebuildJsSurca

:*:@rebuildJsSurca::
	RebuildJs(A_ThisLabel, GetGitHubFolder() . "\surca.wsu.edu\", ":*:@commitJsSurca")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.11: @rebuildJsSumRes

:*:@rebuildJsSumRes::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\JS'`r"
		. "gulp buildMinJs`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitJsSumRes")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.12: @rebuildJsXfer

:*:@rebuildJsXfer::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu\'`r"
		. "gulp buildMinJs`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitJsXfer")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.13: @rebuildJsUgr

:*:@rebuildJsUgr::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS'`r"
		. "gulp buildMinJs`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitJsUgr")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.14: @rebuildJsUcore

:*:@rebuildJsUcore::
	ahkCmdName := ":*:@rebuildJsUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu\JS'`r"
		. "gulp buildMinJs`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitJsUcore")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.6.15: @rebuildJsUcrAss

:*:@rebuildJsUcrAss::
	ahkCmdName := ":*:@rebuildJsUcrAss"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;   ································································································
;     >>> §6.7: FOR UPDATING JS SUBMODULES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.1: @commitJsAscc

:*:@commitJsAscc::
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, "ascc.wsu.edu", "ascc-specific.js", "ascc-custom.js"
		, "ascc-custom.min.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.2: @commitJsDsp

:*:@commitJsDsp::
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, "distinguishedscholarships.wsu.edu", "dsp-custom.js"
		, "dsp-custom-build.js", "dsp-custom-build.min.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.3: @commitJsSurca

:*:@commitJsSurca::
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, "surca.wsu.edu", "surca-custom.js", "surca-build.js"
		, "surca-build.min.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.4: @commitJsSumRes

:*:@commitJsSumRes::
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, "summerresearch.wsu.edu", "sumres-custom.js", "sumres-build.js"
		, "sumres-build.min.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.5: @commitJsXfer

:*:@commitJsXfer::
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, "transfercredit.wsu.edu", "transfer-central-custom.js"
		, "transfer-central-custom-build.js", "transfer-central-custom-build.min.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.6: @commitJsUgr

:*:@commitJsUgr::
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, "undergraduateresearch.wsu.edu", "ugr-custom.js", "ugr-build.js"
		, "ugr-build.min.js")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.7.7: @commitJsUcore

:*:@commitJsUcore::
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, "ucore.wsu.edu", "ucore-custom.js", "ucore-build.js"
		, "ucore-build.min.js")
Return

;   ································································································
;     >>> §6.8: FOR UPDATING JS SUBMODULES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.1: UpdateJsSubmodule

UpdateJsSubmodule(caller, repository, rebuildCommand) {
	AppendAhkCmd(caller)
	if (SubStr(repository, StrLen(repository), 1) != "\") {
		repository .= "\"
	}
	PasteTextIntoGitShell(caller, "cd '" . repository . "WSU-UE---JS'`rgit fetch`rgit merge origin/"
		. "master`rcd ..`rgit add WSU-UE---JS`rgit commit -m 'Updating custom JS master submodule f"
		. "or OUE websites' -m 'Incorporating recent changes in project source code'`rgit push`r")
	Gosub % rebuildCommand
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.2: @updateJsSubmoduleAscc

:*:@updateJsSubmoduleAscc::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\ascc.wsu.edu\", ":*:@rebuildJsAscc")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.3: @updateJsSubmoduleCr

:*:@updateJsSubmoduleCr::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\commonreading.wsu.edu\"
		, ":*:@rebuildJsCr")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.4: @updateJsSubmoduleDsp

:*:@updateJsSubmoduleDsp::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\"
		, ":*:@rebuildJsDsp")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.5: @updateJsSubmoduleFye

:*:@updateJsSubmoduleFye::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\firstyear.wsu.edu\", ":*:@rebuildJsFye")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.6: @updateJsSubmoduleFyf

:*:@updateJsSubmoduleFyf::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\learningcommunities.wsu.edu\"
		, ":*:@rebuildJsFyf")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.7: @updateJsSubmoduleNse

:*:@updateJsSubmoduleNse::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\nse.wsu.edu\", ":*:@rebuildJsNse")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.8: @updateJsSubmoduleOue

:*:@updateJsSubmoduleOue::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\oue.wsu.edu\", ":*:@rebuildJsOue")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.9: @updateJsSubmodulePbk

:*:@updateJsSubmodulePbk::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\phibetakappa.wsu.edu\", ":*:@rebuildJsPbk")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.10: @updateJsSubmoduleSurca

:*:@updateJsSubmoduleSurca::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\surca.wsu.edu\", ":*:@rebuildJsSurca")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.11: @updateJsSubmoduleSumRes

:*:@updateJsSubmoduleSumRes::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\summerresearch.wsu.edu\"
		, ":*:@rebuildJsSumRes")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.12: @updateJsSubmoduleXfer

:*:@updateJsSubmoduleXfer::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\transfercredit.wsu.edu\"
		, ":*:@rebuildJsXfer")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.13: @updateJsSubmoduleUgr

:*:@updateJsSubmoduleUgr::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\", ":*:@rebuildJsUgr")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.14: @updateJsSubmoduleUcore

:*:@updateJsSubmoduleUcore::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\ucore.wsu.edu\", ":*:@rebuildJsUcore")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.15: @updateJsSubmoduleUcrAss

:*:@updateJsSubmoduleUcrAss::
	UpdateJsSubmodule(A_ThisLabel, GetGitHubFolder() . "\ucore.wsu.edu-assessment\"
		, ":*:@rebuildJsUcrAss")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.8.16: @updateJsSubmoduleAll

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

;   ································································································
;     >>> §6.9: Shortcuts for copying minified JS to clipboard

;TODO: Add scripts for copying JS backups to clipboard (see CSS backup-copying scripts above)

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.1: @copyMinJsAscc

:*:@copyMinJsAscc::
	ahkCmdName := ":*:@copyMinJsAscc"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ascc.wsu.edu\JS\ascc-custom.min.js"
		, "", "Couldn't Copy Minified JS for ASCC Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.2: @copyMinJsCr

:*:@copyMinJsCr::
	ahkCmdName := ":*:@copyMinJsCr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\commonreading.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for CR Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.3: @copyMinJsDsp

:*:@copyMinJsDsp::
	ahkCmdName := ":*:@copyMinJsDsp"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS\dsp-custom-build.min.js"
		, "", "Couldn't Copy Minified JS for DSP Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.4: @copyMinJsFye

:*:@copyMinJsFye::
	ahkCmdName := ":*:@copyMinJsFye"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\firstyear.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for FYE Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.5: @copyMinJsFyf

:*:@copyMinJsFyf::
	ahkCmdName := ":*:@copyMinJsFyf"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for FYF Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.6: @copyMinJsNse

:*:@copyMinJsNse::
	ahkCmdName := ":*:@copyMinJsNse"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\nse.wsu.edu\JS\nse-custom.min.js"
		, "", "Couldn't Copy Minified JS for Nse Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.7: @copyMinJsOue

:*:@copyMinJsOue::
	ahkCmdName := ":*:@copyMinJsOue"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\oue-custom.min.js"
		, "", "Couldn't Copy Minified JS for WSU OUE Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.8: @copyBackupJsOue

:*:@copyBackupJsOue::
	ahkCmdName := ":*:@copyBackupJsOue"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\oue.wsu.edu\JS\oue-custom.min.prev.js"
		, "", "Couldn't copy backup copy of minified JS for WSU OUE website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.9: @copyMinJsPbk

:*:@copyMinJsPbk::
	ahkCmdName := ":*:@copyMinJsPbk"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Phi Beta Kappa Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.10: @copyMinJsSurca

:*:@copyMinJsSurca::
	ahkCmdName := ":*:@copyMinJsSurca"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\surca.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for SURCA Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.11: @copyMinJsSumRes

:*:@copyMinJsSumRes::
	ahkCmdName := ":*:@copyMinJsSumRes"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\summerresearch.wsu.edu\JS\sumres-build.min.js"
		, "", "Couldn't Copy Minified JS for WSU Summer Research Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.12: @copyMinJsXfer

:*:@copyMinJsXfer::
	ahkCmdName := ":*:@copyMinJsXfer"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Transfer Credit Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.13: @copyMinJsUgr

:*:@copyMinJsUgr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS\ugr-build.min.js"
		, "", "Couldn't Copy Minified JS for UGR Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.14: @copyMinJsUcore

:*:@copyMinJsUcore::
	ahkCmdName := ":*:@copyMinJsUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu\JS\ucore-build.min.js"
		, "", "Couldn't copy minified JS for UCORE website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.15: @copyBackupJsUcore

:*:@copyBackupJsUcore::
	ahkCmdName := ":*:@copyBackupJsUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.min.prev.js"
		, ""		, "Couldn't copy backup copy of minified JS for UCORE website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.9.16: @copyMinJsUcrAss

:*:@copyMinJsUcrAss::
	ahkCmdName := ":*:@copyMinJsUcrAss"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Summer Research Website")
Return

;   ································································································
;     >>> §6.10: FOR CHECKING GIT STATUS ON ALL PROJECTS

:*:@checkGitStatus::
	ahkCmdName := ":*:@checkGitStatus"
	AppendAhkCmd(ahkCmdName)
	gitHubFolder := GetGitHubFolder()
	PasteTextIntoGitShell(ahkCmdName
		, "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n----------------------------------------------WSU-OUE-AutoHotkey--------"
		. "---------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\WSU-OUE-AutoHotkey\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n------------------------------------------------WSU-OUE---CSS-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\WSU-UE---CSS\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n-------------------------------------------------WSU-OUE---JS-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\WSU-UE---JS\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n-------------------------------------------------ascc.wsu.edu-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\ascc.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n--------------------------------------------commonreading.wsu.edu-------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\commonreading.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n--------------------------------------distinguishedscholarships.wsu.edu-"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\distinguishedscholarships.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n----------------------------------------------firstyear.wsu.edu---------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\firstyear.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n-----------------------------------------learningcommunities.wsu.edu----"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\learningcommunities.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n-------------------------------------------------oue.wsu.edu------------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\oue.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n------------------------------------------------surca.wsu.edu-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\surca.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n----------------------------------------undergraduateresearch.wsu.edu---"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\undergraduateresearch.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n--------------------------------------------transfercredit.wsu.edu------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\transfercredit.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n--------------------------------------------summerresearch.wsu.edu------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\summerresearch.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n------------------------------------------------ucore.wsu.edu-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\ucore.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n"
		. "Write-Host ""``n-------------------------------------------ucore.wsu.edu/assessment-----"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd """ . gitHubFolder . "\ucore.wsu.edu-assessment\""`r`n"
		. "git status`r`n"
		. "cd """ . gitHubFolder . "\""`r`n")
Return

; --------------------------------------------------------------------------------------------------
;   §7: KEYBOARD SHORTCUTS FOR POWERSHELL
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §7.1: SHORTCUTS

^+v::	
	if (IsGitShellActive()) {
		PasteTextIntoGitShell("", clipboard)
	} else {
		Gosub, PerformBypassingCtrlShftV
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~^+Backspace::
	if (IsGitShellActive()) {
		SendInput {Backspace 120}
	}
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

~^+Delete::
	if (IsGitShellActive()) {
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
