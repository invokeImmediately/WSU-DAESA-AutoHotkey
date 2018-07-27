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
; Table of Contents  (Lines 19–251)
; ---------------------------------
;   §1: SETTINGS accessed via functions for this imported file...................................258
;     >>> §1.1: GetCmdForMoveToCSSFolder — Function..............................................262
;     >>> §1.2: GetCurrentDirFrom — Function.....................................................277
;     >>> §1.3: GetGitHubFolder — Function.......................................................289
;     >>> §1.4: UserFolderIsSet — Function.......................................................297
;   §2: FUNCTIONS for working with GitHub Desktop................................................311
;     >>> §2.1: ActivateGitShell - Function......................................................315
;     >>> §2.2: CommitAfterBuild - Function......................................................334
;     >>> §2.3: EscapeCommitMessage - Function...................................................369
;     >>> §2.4: Git commit GUI — Imports.........................................................379
;       →→→ §2.4.1: For committing CSS builds....................................................382
;       →→→ §2.4.2: For committing JS builds.....................................................387
;       →→→ §2.4.3: For committing any type of file..............................................392
;     >>> §2.5: CopySrcFileToClipboard - Function................................................397
;     >>> §2.6: IsGitShellActive - Function......................................................418
;     >>> §2.7: PasteTextIntoGitShell - Function.................................................427
;     >>> §2.8: ToEscapedPath - Function.........................................................453
;     >>> §2.9: VerifyCopiedCode - Function......................................................461
;   §3: FUNCTIONS for interacting with online WEB DESIGN INTERFACES..............................475
;     >>> §3.1: LoadWordPressSiteInChrome - Function.............................................479
;   §4: GUI FUNCTIONS for handling user interactions with scripts................................515
;     >>> §4.1: @postMinCss — Hotstring..........................................................519
;       →→→ §4.1.1: HandlePostCssCheckAllSites — Supporting function.............................559
;       →→→ §4.1.2: HandlePostCssUncheckAllSites — Supporting function...........................579
;       →→→ §4.1.3: HandlePostMinCssCancel — Supporting function.................................599
;       →→→ §4.1.4: HandlePostMinCssOK — Supporting function.....................................606
;       →→→ §4.1.5: PasteMinCssToWebsite — Supporting function...................................673
;     >>> §4.2: @postBackupCss — Hotstring.......................................................684
;       →→→ §4.2.1: HandlePostBackupCssCheckAllSites — Supporting function.......................729
;       →→→ §4.2.2: HandlePostBackupCssUncheckAllSites — Supporting function.....................749
;       →→→ §4.2.3: HandlePostBackupCssCancel — Supporting function..............................769
;       →→→ §4.2.4: HandlePostBackupCssOK — Supporting function..................................776
;     >>> §4.3: @postMinJs — Hotstring...........................................................839
;       →→→ §4.3.1: HandlePostJsCheckAllSites — Supporting function..............................890
;       →→→ §4.3.2: HandlePostJsUncheckAllSites — Supporting function............................910
;       →→→ §4.3.3: HandlePostMinJsCancel — Supporting function..................................930
;       →→→ §4.3.4: HandlePostMinJsOK — Supporting function......................................937
;       →→→ §4.3.5: PasteMinJsToWebsite — Supporting function...................................1004
;   §5: FILE SYSTEM NAVIGATION Hotstrings.......................................................1019
;     >>> §5.1: Navigation within GitHub directories............................................1023
;       →→→ §5.1.1: @gotoGhAscc.................................................................1026
;       →→→ §5.1.2: @gotoGhCr...................................................................1033
;       →→→ §5.1.3: @gotoGhDsp..................................................................1041
;       →→→ §5.1.4: @gotoGhFye..................................................................1049
;       →→→ §5.1.5: @gotoGhFyf..................................................................1056
;       →→→ §5.1.6: @gotoGhNse..................................................................1064
;       →→→ §5.1.7: @gotoGhOue..................................................................1071
;       →→→ §5.1.8: @gotoGhPbk..................................................................1078
;       →→→ §5.1.9: @gotoGhRsp..................................................................1086
;       →→→ §5.1.10: @gotoGhSurca...............................................................1094
;       →→→ §5.1.11: @gotoGhSumRes..............................................................1101
;       →→→ §5.1.12: @gotoGhXfer................................................................1109
;       →→→ §5.1.13: @gotoGhUgr.................................................................1117
;       →→→ §5.1.14: @gotoGhUcore...............................................................1125
;       →→→ §5.1.15: @gotoGhUcrAss..............................................................1132
;       →→→ §5.1.16: @gotoGhCSS.................................................................1140
;       →→→ §5.1.17: @gotoGhJS..................................................................1147
;       →→→ §5.1.18: @gotoGhAhk.................................................................1154
;       →→→ §5.1.19: cdcss......................................................................1161
;       →→→ §5.1.20: cdjs.......................................................................1166
;   §6: UTILITY HOTSTRINGS for working with GitHub Desktop......................................1171
;     >>> §6.1: FILE COMMITTING.................................................................1175
;     >>> §6.2: STATUS CHECKING.................................................................1325
;     >>> §6.3: Automated PASTING OF CSS into online web interfaces.............................1347
;   §7: COMMAND LINE INPUT GENERATION SHORTCUTS.................................................1513
;     >>> §7.1: Shortucts for backing up custom CSS builds......................................1517
;       →→→ §7.1.1: @backupCssAscc — Hotstring..................................................1520
;       →→→ §7.1.2: @backupCssCr — Hotstring....................................................1535
;       →→→ §7.1.3: @backupCssDsp — Hotstring...................................................1553
;       →→→ §7.1.4: @backupCssFye — Hotstring...................................................1571
;       →→→ §7.1.5: @backupCssFyf — Hotstring...................................................1588
;       →→→ §7.1.6: @backupCssNse — Hotstring...................................................1606
;       →→→ §7.1.7: @backupCssOue — Hotstring...................................................1623
;       →→→ §7.1.8: @backupCssPbk — Hotstring...................................................1640
;       →→→ §7.1.9: @backupCssSurca — Hotstring.................................................1657
;       →→→ §7.1.10: @backupCssSumRes — Hotstring...............................................1674
;       →→→ §7.1.11: @backupCssXfer — Hotstring.................................................1692
;       →→→ §7.1.12: @backupCssUgr — Hotstring..................................................1710
;       →→→ §7.1.13: @backupCssXfer — Hotstring.................................................1728
;       →→→ §7.1.14: @backupCssUcrAss — Hotstring...............................................1745
;       →→→ §7.1.15: @backupCssAll — Hotstring..................................................1763
;       →→→ §7.1.16: CopyCssFromWebsite — Function..............................................1786
;       →→→ §7.1.16: CopyCssFromWebsite — Function..............................................1796
;     >>> §7.2: Shortcuts for rebuilding & committing custom CSS files..........................1815
;       →→→ §7.2.1: @rebuildCssHere — Hotstring.................................................1818
;       →→→ §7.2.2: @rebuildCssAscc — Hotstring.................................................1828
;       →→→ §7.2.3: @commitCssAscc — Hotstring..................................................1840
;       →→→ §7.2.4: @rebuildCssCr — Hotstring...................................................1855
;       →→→ §7.2.5: @commitCssCr — Hotstring....................................................1867
;       →→→ §7.2.6: @rebuildCssDsp — Hotstring..................................................1882
;       →→→ §7.2.7: @commitCssDsp — Hotstring...................................................1894
;       →→→ §7.2.8: @rebuildCssFye — Hotstring..................................................1909
;       →→→ §7.2.9: @commitCssFye — Hotstring...................................................1921
;       →→→ §7.2.10: @rebuildCssFyf — Hotstring.................................................1937
;       →→→ §7.2.11: @commitCssFyf — Hotstring..................................................1949
;       →→→ §7.2.12: @rebuildCssNse — Hotstring.................................................1965
;       →→→ §7.2.13: @commitCssNse — Hotstring..................................................1977
;       →→→ §7.2.14: @rebuildCssOue — Hotstring.................................................1992
;       →→→ §7.2.15: @commitCssOue — Hotstring..................................................2004
;       →→→ §7.2.16: @rebuildCssPbk — Hotstring.................................................2020
;       →→→ §7.2.17: @commitCssPbk — Hotstring..................................................2032
;       →→→ §7.2.18: @rebuildCssSurca — Hotstring...............................................2048
;       →→→ §7.2.19: @commitCssSurca — Hotstring................................................2060
;       →→→ §7.2.20: @rebuildCssSumRes — Hotstring..............................................2075
;       →→→ §7.2.21: @commitCssSumRes — Hotstring...............................................2087
;       →→→ §7.2.22: @rebuildCssXfer — Hotstring................................................2102
;       →→→ §7.2.23: @commitCssXfer — Hotstring.................................................2114
;       →→→ §7.2.24: @rebuildCssUgr — Hotstring.................................................2130
;       →→→ §7.2.25: @commitCssUgr — Hotstring..................................................2142
;       →→→ §7.2.26: @commitCssSumRes — Hotstring...............................................2157
;       →→→ §7.2.27: @commitCssUcore — Hotstring................................................2169
;       →→→ §7.2.28: @rebuildCssUcrAss — Hotstring..............................................2184
;       →→→ §7.2.29: @commitCssUcrAss — Hotstring...............................................2196
;       →→→ §7.2.30: @rebuildCssAll — Hotstring.................................................2211
;     >>> §7.3: Shortcuts for updating CSS submodules...........................................2236
;       →→→ §7.3.1: @updateCssSubmoduleAscc — Hotstring.........................................2239
;       →→→ §7.3.2: @updateCssSubmoduleCr — Hotstring...........................................2256
;       →→→ §7.3.3: @updateCssSubmoduleDsp — Hotstring..........................................2273
;       →→→ §7.3.4: @updateCssSubmoduleFye — Hotstring..........................................2290
;       →→→ §7.3.5: @updateCssSubmoduleFyf — Hotstring..........................................2307
;       →→→ §7.3.6: @updateCssSubmoduleNse — Hotstring..........................................2324
;       →→→ §7.3.7: @updateCssSubmoduleOue — Hotstring..........................................2341
;       →→→ §7.3.8: @updateCssSubmodulePbk — Hotstring..........................................2358
;       →→→ §7.3.9: @updateCssSubmoduleSurca — Hotstring........................................2375
;       →→→ §7.3.10: @updateCssSubmoduleSumRes — Hotstring......................................2392
;       →→→ §7.3.11: @updateCssSubmoduleXfer — Hotstring........................................2409
;       →→→ §7.3.12: @updateCssSubmoduleUgr — Hotstring.........................................2426
;       →→→ §7.3.13: @updateCssSubmoduleUcore — Hotstring.......................................2443
;       →→→ §7.3.14: @updateCssSubmoduleUcrAss — Hotstring......................................2460
;       →→→ §7.3.15: @updateCssSubmoduleAll — Hotstring.........................................2477
;     >>> §7.4: For copying minified, backup css files to clipboard.............................2503
;       →→→ §7.4.1: @copyMinCssAscc — Hotstring.................................................2506
;       →→→ §7.4.2: @copyBackupCssAscc — Hotstring..............................................2518
;       →→→ §7.4.3: @copyMinCssCr — Hotstring...................................................2528
;       →→→ §7.4.4: @copyBackupCssCr — Hotstring................................................2540
;       →→→ §7.4.5: @copyMinCssDsp — Hotstring..................................................2550
;       →→→ §7.4.6: @copyBackupCssDsp — Hotstring...............................................2560
;       →→→ §7.4.7: @copyMinCssFye — Hotstring..................................................2570
;       →→→ §7.4.8: @copyBackupCssFye — Hotstring...............................................2582
;       →→→ §7.4.9: @copyMinCssFyf — Hotstring..................................................2592
;       →→→ §7.4.10: @copyBackupCssFyf — Hotstring..............................................2604
;       →→→ §7.4.11: @copyMinCssNse — Hotstring.................................................2614
;       →→→ §7.4.12: @copyBackupCssNse — Hotstring..............................................2624
;       →→→ §7.4.13: @copyMinCssOue — Hotstring.................................................2634
;       →→→ §7.4.14: @copyMinCssPbk — Hotstring.................................................2644
;       →→→ §7.4.15: @copyBackupCssPbk — Hotstring..............................................2654
;       →→→ §7.4.16: @copyMinCssSurca — Hotstring...............................................2664
;       →→→ §7.4.17: @copyBackupCssSurca — Hotstring............................................2676
;       →→→ §7.4.18: @copyMinCssSumRes — Hotstring..............................................2686
;       →→→ §7.4.19: @copyBackupCssSumRes — Hotstring...........................................2696
;       →→→ §7.4.20: @copyMinCssXfer — Hotstring................................................2706
;       →→→ §7.4.21: @copyBackupCssXfer — Hotstring.............................................2716
;       →→→ §7.4.22: @copyMinCssUgr — Hotstring.................................................2726
;       →→→ §7.4.23: @copyBackupCssUgr — Hotstring..............................................2737
;       →→→ §7.4.24: @copyMinCssUcore — Hotstring...............................................2747
;       →→→ §7.4.25: @copyBackupCssUcore — Hotstring............................................2757
;       →→→ §7.4.26: @copyMinCssUcrAss — Hotstring..............................................2767
;       →→→ §7.4.27: @copyBackupCssUcrAss — Hotstring...........................................2777
;     >>> §7.5: FOR BACKING UP CUSTOM JS BUILDS.................................................2787
;       →→→ §7.5.1: @backupJsAscc — Hotstring...................................................2790
;       →→→ §7.5.2: @backupJsCr — Hotstring.....................................................2805
;       →→→ §7.5.3: @backupJsDsp — Hotstring....................................................2821
;       →→→ §7.5.4: @backupJsFye — Hotstring....................................................2837
;       →→→ §7.5.5: @backupJsFyf — Hotstring....................................................2853
;       →→→ §7.5.6: @backupJsNse — Hotstring....................................................2869
;       →→→ §7.5.7: @backupJsOue — Hotstring....................................................2883
;       →→→ §7.5.8: @backupJsPbk — Hotstring....................................................2897
;       →→→ §7.5.9: @backupJsSurca — Hotstring..................................................2913
;       →→→ §7.5.10: @backupJsSumRes — Hotstring................................................2928
;       →→→ §7.5.11: @commitBackupJsSumRes — Hotstring..........................................2940
;       →→→ §7.5.12: @backupJsXfer — Hotstring..................................................2952
;       →→→ §7.5.13: @backupJsUgr — Hotstring...................................................2968
;       →→→ §7.5.14: @backupJsUcore — Hotstring.................................................2984
;       →→→ §7.5.15: @backupJsUcrAss — Hotstring................................................2999
;       →→→ §7.5.16: @backupJsAll — Hotstring...................................................3015
;       →→→ §7.5.17: CopyJsFromWebsite — Function...............................................3041
;       →→→ §7.5.18: ExecuteJsCopyCmds — Function...............................................3050
;     >>> §7.6: FOR REBUILDING JS SOURCE FILES..................................................3066
;       →→→ §7.6.1: @rebuildJsAscc — Hotstring..................................................3069
;       →→→ §7.6.2: @rebuildJsCr — Hotstring....................................................3088
;       →→→ §7.6.3: @rebuildJsDsp — Hotstring...................................................3107
;       →→→ §7.6.4: @commitJsDsp — Hotstring....................................................3122
;       →→→ §7.6.5: @rebuildJsFye — Hotstring...................................................3134
;       →→→ §7.6.6: @rebuildJsFyf — Hotstring...................................................3153
;       →→→ §7.6.7: @rebuildJsNse — Hotstring...................................................3172
;       →→→ §7.6.8: @rebuildJsOue — Hotstring...................................................3191
;       →→→ §7.6.9: @rebuildJsPbk — Hotstring...................................................3210
;       →→→ §7.6.10: @rebuildJsSurca — Hotstring................................................3229
;       →→→ §7.6.11: @rebuildJsSumRes — Hotstring...............................................3248
;       →→→ §7.6.12: @rebuildJsXfer — Hotstring.................................................3269
;       →→→ §7.6.13: @commitJsXfer — Hotstring..................................................3282
;       →→→ §7.6.14: @rebuildJsUgr — Hotstring..................................................3294
;       →→→ §7.6.15: @rebuildJsUcore — Hotstring................................................3313
;       →→→ §7.6.16: @rebuildJsUcrAss — Hotstring...............................................3332
;     >>> §7.7: FOR UPDATING JS SUBMODULES......................................................3351
;       →→→ §7.7.1: @updateJsSubmoduleAscc — Hotstring..........................................3354
;       →→→ §7.7.2: @updateJsSubmoduleCr — Hotstring............................................3372
;       →→→ §7.7.3: @updateJsSubmoduleDsp — Hotstring...........................................3390
;       →→→ §7.7.4: @updateJsSubmoduleFye — Hotstring...........................................3408
;       →→→ §7.7.5: @updateJsSubmoduleFyf — Hotstring...........................................3426
;       →→→ §7.7.6: @updateJsSubmoduleNse — Hotstring...........................................3444
;       →→→ §7.7.7: @updateJsSubmoduleOue — Hotstring...........................................3462
;       →→→ §7.7.8: @updateJsSubmodulePbk — Hotstring...........................................3480
;       →→→ §7.7.9: @updateJsSubmoduleSurca — Hotstring.........................................3498
;       →→→ §7.7.10: @updateJsSubmoduleSumRes — Hotstring.......................................3516
;       →→→ §7.7.11: @updateJsSubmoduleXfer — Hotstring.........................................3534
;       →→→ §7.7.12: @updateJsSubmoduleUgr — Hotstring..........................................3552
;       →→→ §7.7.13: @updateJsSubmoduleUcore — Hotstring........................................3570
;       →→→ §7.7.14: @updateJsSubmoduleUcrAss — Hotstring.......................................3588
;       →→→ §7.7.15: @updateJsSubmoduleAll — Hotstring..........................................3606
;     >>> §7.8: Shortcuts for copying minified JS to clipboard..................................3633
;       →→→ §7.8.1: @copyMinJsAscc — Hotstring..................................................3638
;       →→→ §7.8.2: @copyMinJsCr — Hotstring....................................................3649
;       →→→ §7.8.3: @copyMinJsDsp — Hotstring...................................................3660
;       →→→ §7.8.4: @copyMinJsFye — Hotstring...................................................3671
;       →→→ §7.8.5: @copyMinJsFyf — Hotstring...................................................3682
;       →→→ §7.8.6: @copyMinJsNse — Hotstring...................................................3693
;       →→→ §7.8.7: @copyMinJsOue — Hotstring...................................................3704
;       →→→ §7.8.8: @copyBackupJsOue — Hotstring................................................3715
;       →→→ §7.8.9: @copyMinJsPbk — Hotstring...................................................3726
;       →→→ §7.8.10: @copyMinJsSurca — Hotstring................................................3737
;       →→→ §7.8.11: @copyMinJsSumRes — Hotstring...............................................3748
;       →→→ §7.8.12: @copyMinJsXfer — Hotstring.................................................3759
;       →→→ §7.8.13: @copyMinJsUgr — Hotstring..................................................3770
;       →→→ §7.8.14: @copyMinJsUcore — Hotstring................................................3781
;       →→→ §7.8.15: @copyBackupJsUcore — Hotstring.............................................3792
;       →→→ §7.8.16: @copyMinJsUcrAss — Hotstring...............................................3803
;     >>> §7.9: FOR CHECKING GIT STATUS ON ALL PROJECTS ........................................3814
;   §8: KEYBOARD SHORTCUTS FOR POWERSHELL.......................................................3899
;     >>> §8.1: SHORTCUTS.......................................................................3903
;     >>> §8.2: SUPPORTING FUNCTIONS............................................................3929
; ==================================================================================================

sgIsPostingMinCss := false
sgIsPostingMinJs := false

; --------------------------------------------------------------------------------------------------
;   §1: SETTINGS accessed via functions for this imported file
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: GetCmdForMoveToCSSFolder — Function

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
;     >>> §1.2: GetCurrentDirFrom — Function

GetCurrentDirFromPS() {
	copyDirCmd := "(get-location).ToString() | clip`r`n"
	PasteTextIntoGitShell("", copyDirCmd)
	while(Clipboard = copyDirCmd) {
		Sleep 100
	}
	Return Clipboard
}

;   ································································································
;     >>> §1.3: GetGitHubFolder — Function

GetGitHubFolder() {
	global userAccountFolderSSD
	Return userAccountFolderSSD . "\Documents\GitHub"
}

;   ································································································
;     >>> §1.4: UserFolderIsSet — Function

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
;     >>> §2.1: ActivateGitShell - Function

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
;     >>> §2.2: CommitAfterBuild - Function

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
;     >>> §2.3: EscapeCommitMessage - Function
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

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\CommitCssBuild.ahk

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.2: For committing JS builds

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\CommitJsBuild.ahk

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.4.3: For committing any type of file

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\CommitAnyFile.ahk

;   ································································································
;     >>> §2.5: CopySrcFileToClipboard - Function

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
;     >>> §2.6: IsGitShellActive - Function

IsGitShellActive() {
	WinGet, thisProcess, ProcessName, A
	shellIsActive := thisProcess = "PowerShell.exe"
	Return shellIsActive
}

;   ································································································
;     >>> §2.7: PasteTextIntoGitShell - Function

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
;     >>> §2.8: ToEscapedPath - Function

ToEscapedPath(path) {
	escapedPath := StrReplace(path, "\", "\\")
	Return escapedPath
}

;   ································································································
;     >>> §2.9: VerifyCopiedCode - Function

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
;     >>> §3.1: LoadWordPressSiteInChrome - Function

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
;     >>> §4.1: @postMinCss — Hotstring

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
;       →→→ §4.1.1: HandlePostCssCheckAllSites — Supporting function

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
;       →→→ §4.1.2: HandlePostCssUncheckAllSites — Supporting function

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
;       →→→ §4.1.3: HandlePostMinCssCancel — Supporting function

HandlePostMinCssCancel() {
	Gui, guiPostMinCss: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.1.4: HandlePostMinCssOK — Supporting function

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
;       →→→ §4.1.5: PasteMinCssToWebsite — Supporting function

PasteMinCssToWebsite(websiteUrl, cssCopyCmd, manualProcession := false) {
	delay := 1000
	LoadWordPressSiteInChrome(websiteUrl)
	Gosub, %cssCopyCmd%
	Sleep, % delay
	ExecuteCssPasteCmds(manualProcession)
}

;   ································································································
;     >>> §4.2: @postBackupCss — Hotstring

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
;       →→→ §4.2.1: HandlePostBackupCssCheckAllSites — Supporting function

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
;       →→→ §4.2.2: HandlePostBackupCssUncheckAllSites — Supporting function

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
;       →→→ §4.2.3: HandlePostBackupCssCancel — Supporting function

HandlePostBackupCssCancel() {
	Gui, guiPostBackupCss: Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.2.4: HandlePostBackupCssOK — Supporting function

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
;     >>> §4.3: @postMinJs — Hotstring

:*:::
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
;       →→→ §4.3.1: HandlePostJsCheckAllSites — Supporting function

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
;       →→→ §4.3.2: HandlePostJsUncheckAllSites — Supporting function

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
;       →→→ §4.3.3: HandlePostMinJsCancel — Supporting function

HandlePostMinJsCancel() {
	Gui, Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §4.3.4: HandlePostMinJsOK — Supporting function

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
;       →→→ §4.3.5: PasteMinJsToWebsite — Supporting function

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
;   §5: FILE SYSTEM NAVIGATION Hotstrings
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: Navigation within GitHub directories

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.1: @gotoGhAscc

:*:@gotoGhAscc::
	InsertFilePath(":*:@gotoGhAscc", GetGitHubFolder() . "\ascc.wsu.edu", "ascc.wsu.edu") 
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.2: @gotoGhCr

:*:@gotoGhCr::
	InsertFilePath(":*:@gotoGhCr", GetGitHubFolder() . "\commonreading.wsu.edu"
		, "commonreading.wsu.edu") 
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.3: @gotoGhDsp

:*:@gotoGhDsp::
	InsertFilePath(":*:@gotoGhDsp", GetGitHubFolder() . "\distinguishedscholarships.wsu.edu"
		, "distinguishedscholarships.wsu.edu") 
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.4: @gotoGhFye

:*:@gotoGhFye::
	InsertFilePath(":*:@gotoGhFye", GetGitHubFolder() . "\firstyear.wsu.edu", "firstyear.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.5: @gotoGhFyf

:*:@gotoGhFyf::
	InsertFilePath(":*:@gotoGhFyf", GetGitHubFolder() . "\learningcommunities.wsu.edu"
		, "learningcommunities.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.6: @gotoGhNse

:*:@gotoGhNse::
	InsertFilePath(":*:@gotoGhNse", GetGitHubFolder() . "\nse.wsu.edu", "nse.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.7: @gotoGhOue

:*:@gotoGhOue::
	InsertFilePath(":*:@gotoGhPbk", GetGitHubFolder() . "\oue.wsu.edu", "oue.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.8: @gotoGhPbk

:*:@gotoGhPbk::
	InsertFilePath(":*:@gotoGhPbk", GetGitHubFolder() . "\phibetakappa.wsu.edu"
		, "phibetakappa.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.9: @gotoGhRsp

:*:@gotoGhRsp::
	InsertFilePath(":*:@gotoGhRsp", GetGitHubFolder() . "\admissions.wsu.edu-research-scholars"
		, "admissions.wsu.edu/research-scholars")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.10: @gotoGhSurca

:*:@gotoGhSurca::
	InsertFilePath(":*:@gotoGhSurca", GetGitHubFolder() . "\surca.wsu.edu", "surca.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.11: @gotoGhSumRes

:*:@gotoGhSumRes::
	InsertFilePath(":*:@gotoGhSumRes", GetGitHubFolder() . "\summerresearch.wsu.edu"
		, "summerresearch.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.12: @gotoGhXfer

:*:@gotoGhXfer::
	InsertFilePath(":*:@gotoGhXfer", GetGitHubFolder() . "\transfercredit.wsu.edu"
		, "transfercredit.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.13: @gotoGhUgr

:*:@gotoGhUgr::
	InsertFilePath(":*:@gotoGhUgr", GetGitHubFolder() . "\undergraduateresearch.wsu.edu"
		, "undergraduateresearch.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.14: @gotoGhUcore

:*:@gotoGhUcore::
	InsertFilePath(":*:@gotoGhUcore", GetGitHubFolder() . "\ucore.wsu.edu", "ucore.wsu.edu")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.15: @gotoGhUcrAss

:*:@gotoGhUcrAss::
	InsertFilePath(":*:@gotoGhUcrAss", GetGitHubFolder() . "\ucore.wsu.edu-assessment"
		, "ucore.wsu.edu-assessment")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.16: @gotoGhCSS

:*:@gotoGhCSS::
	InsertFilePath(":*:@gotoGhCSS", GetGitHubFolder() . "\WSU-UE---CSS", "WSU-UE---CSS")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.17: @gotoGhJS

:*:@gotoGhJS::
	InsertFilePath(":*:@gotoGhJS", GetGitHubFolder() . "\WSU-UE---JS", "WSU-UE---JS")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.18: @gotoGhAhk

:*:@gotoGhAhk::
	InsertFilePath(":*:@gotoGhAhk", GetGitHubFolder() . "\WSU-OUE-AutoHotkey", "WSU-OUE-AutoHotkey")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.19: cdcss

:*:cdcss::cd wsu-ue---css

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §5.1.20: cdjs

:*:cdjs::cd wsu-ue---js

; --------------------------------------------------------------------------------------------------
;   §6: UTILITY HOTSTRINGS for working with GitHub Desktop
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §6.1: FILE COMMITTING
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
	SendInput, % "{^}(?:[{^}\n \-].*| (?{!} {{}7{}}).*|-(?{!}-{{}7{}}).*)?$(?:\n)"
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
;     >>> §6.2: STATUS CHECKING
; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@dogs::
	Gosub, :*:@doGitStatus
Return

;   ································································································
;     >>> §6.3: Automated PASTING OF CSS into online web interfaces
; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

ExecuteCssPasteCmds(manualProcession := false) {
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch(clipboard, "^/\*!? Built with the LESS CSS")
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
		Click, 1565, 410
		Sleep, 60
		Click, 1565, 455
		Sleep, 1000
	} else {
		MsgBox, % (0x0 + 0x10)
			, % "ERROR (" . A_ThisFunc .  "): Clipboard Has Unexpected Contents"
			, % "The clipboard does not begin with the expected '@import ...,' and thus may not "
			. "contain minified CSS."
	}			
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

ExecuteJsPasteCmds(manualProcession := false) {
	; Add check for correct CSS in clipboard — the first line is a font import.
	posFound := RegExMatch(clipboard, "^// Built with Node.js")
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
;   §7: COMMAND LINE INPUT GENERATION SHORTCUTS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §7.1: Shortucts for backing up custom CSS builds

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.1: @backupCssAscc — Hotstring

:*:@backupCssAscc::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://ascc.wsu.edu/wp-admin/themes.php?page=editcss")
	WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
		. "\ascc.wsu.edu\CSS\ascc-custom.prev.css")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ascc.wsu.edu\'`r"
		. "git add CSS\ascc-custom.prev.css`r"
		. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.2: @backupCssCr — Hotstring

:*:@backupCssCr::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://commonreading.wsu.edu/wp-admin/themes.php?"
		. "page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\commonreading.wsu.edu\CSS\cr-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu\'`r"
			. "git add CSS\cr-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.3: @backupCssDsp — Hotstring

:*:@backupCssDsp::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?"
		. "page=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\'`r"
			. "git add CSS\dsp-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.4: @backupCssFye — Hotstring

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
;       →→→ §7.1.5: @backupCssFyf — Hotstring

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
;       →→→ §7.1.6: @backupCssNse — Hotstring

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
;       →→→ §7.1.7: @backupCssOue — Hotstring

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
;       →→→ §7.1.8: @backupCssPbk — Hotstring

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
;       →→→ §7.1.9: @backupCssSurca — Hotstring

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
;       →→→ §7.1.10: @backupCssSumRes — Hotstring

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
;       →→→ §7.1.11: @backupCssXfer — Hotstring

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
;       →→→ §7.1.12: @backupCssUgr — Hotstring

:*:@backupCssUgr::
	AppendAhkCmd(A_ThisLabel)
	copiedCss := CopyCssFromWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page"
		. "=editcss")
	if (VerifyCopiedCode(A_ThisLabel, copiedCss)) {
		WriteCodeToFile(A_ThisLabel, copiedCss, GetGitHubFolder()
			. "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.prev.css")
		PasteTextIntoGitShell(A_ThisLabel
			, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\'`r"
			. "git add CSS\undergraduate-research-custom.prev.css`r"
			. "git commit -m 'Updating backup of latest verified custom CSS build'`r"
			. "git push`r")
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.13: @backupCssXfer — Hotstring

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
;       →→→ §7.1.14: @backupCssUcrAss — Hotstring

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
;       →→→ §7.1.15: @backupCssAll — Hotstring

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
;       →→→ §7.1.16: CopyCssFromWebsite — Function

CopyCssFromWebsite(websiteUrl)
{
	LoadWordPressSiteInChrome(websiteUrl)
	copiedCss := ExecuteCssCopyCmds()
	return copiedCss
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.1.16: CopyCssFromWebsite — Function

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
;     >>> §7.2: Shortcuts for rebuilding & committing custom CSS files

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.1: @rebuildCssHere — Hotstring

:*:@rebuildCssHere::
	currentDir := GetCurrentDirFromPS()
	if (GetCmdForMoveToCSSFolder(currentDir) = "awesome!") {
		MsgBox % "Current location: " . currentDir
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.2: @rebuildCssAscc — Hotstring

:*:@rebuildCssAscc::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ascc.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssAscc")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.3: @commitCssAscc — Hotstring

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
;       →→→ §7.2.4: @rebuildCssCr — Hotstring

:*:@rebuildCssCr::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssCr")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.5: @commitCssCr — Hotstring

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
;       →→→ §7.2.6: @rebuildCssDsp — Hotstring

:*:@rebuildCssDsp::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssDsp")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.7: @commitCssDsp — Hotstring

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
;       →→→ §7.2.8: @rebuildCssFye — Hotstring

:*:@rebuildCssFye::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssFye")	
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.9: @commitCssFye — Hotstring

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
;       →→→ §7.2.10: @rebuildCssFyf — Hotstring

:*:@rebuildCssFyf::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssFyf")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.11: @commitCssFyf — Hotstring

:*:@commitCssFyf::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu'`r"
		. "git add CSS\learningcommunities-custom.css`r"
		. "git add CSS\learningcommunities-custom.min.css`r"
		. "git commit -m 'Updating custom CSS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies.' `r"
		. "git push`r"
		. "[console]::beep(2000,150)`r"
		. "[console]::beep(2000,150)`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.12: @rebuildCssNse — Hotstring

:*:@rebuildCssNse::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\nse.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssNse")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.13: @commitCssNse — Hotstring

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
;       →→→ §7.2.14: @rebuildCssOue — Hotstring

:*:@rebuildCssOue::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\oue.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssOue")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.15: @commitCssOue — Hotstring

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
;       →→→ §7.2.16: @rebuildCssPbk — Hotstring

:*:@rebuildCssPbk::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssPbk")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.17: @commitCssPbk — Hotstring

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
;       →→→ §7.2.18: @rebuildCssSurca — Hotstring

:*:@rebuildCssSurca::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\surca.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssSurca")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.19: @commitCssSurca — Hotstring

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
;       →→→ §7.2.20: @rebuildCssSumRes — Hotstring

:*:@rebuildCssSumRes::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssSumRes")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.21: @commitCssSumRes — Hotstring

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
;       →→→ §7.2.22: @rebuildCssXfer — Hotstring

:*:@rebuildCssXfer::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssXfer")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.23: @commitCssXfer — Hotstring

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
;       →→→ §7.2.24: @rebuildCssUgr — Hotstring

:*:@rebuildCssUgr::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssUgr")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.25: @commitCssUgr — Hotstring

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
;       →→→ §7.2.26: @commitCssSumRes — Hotstring

:*:@rebuildCssUcore::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssUcore")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.27: @commitCssUcore — Hotstring

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
;       →→→ §7.2.28: @rebuildCssUcrAss — Hotstring

:*:@rebuildCssUcrAss::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment'`r"
		. "gulp buildMinCss`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(A_ThisLabel, ":*:@commitCssUcrAss")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.2.29: @commitCssUcrAss — Hotstring

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
;       →→→ §7.2.30: @rebuildCssAll — Hotstring

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
;     >>> §7.3: Shortcuts for updating CSS submodules

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.3.1: @updateCssSubmoduleAscc — Hotstring

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
;       →→→ §7.3.2: @updateCssSubmoduleCr — Hotstring

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
;       →→→ §7.3.3: @updateCssSubmoduleDsp — Hotstring

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
;       →→→ §7.3.4: @updateCssSubmoduleFye — Hotstring

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
;       →→→ §7.3.5: @updateCssSubmoduleFyf — Hotstring

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
;       →→→ §7.3.6: @updateCssSubmoduleNse — Hotstring

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
;       →→→ §7.3.7: @updateCssSubmoduleOue — Hotstring

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
;       →→→ §7.3.8: @updateCssSubmodulePbk — Hotstring

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
;       →→→ §7.3.9: @updateCssSubmoduleSurca — Hotstring

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
;       →→→ §7.3.10: @updateCssSubmoduleSumRes — Hotstring

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
;       →→→ §7.3.11: @updateCssSubmoduleXfer — Hotstring

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
;       →→→ §7.3.12: @updateCssSubmoduleUgr — Hotstring

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
;       →→→ §7.3.13: @updateCssSubmoduleUcore — Hotstring

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
;       →→→ §7.3.14: @updateCssSubmoduleUcrAss — Hotstring

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
;       →→→ §7.3.15: @updateCssSubmoduleAll — Hotstring

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
;     >>> §7.4: For copying minified, backup css files to clipboard

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.1: @copyMinCssAscc — Hotstring

:*:@copyMinCssAscc::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ascc.wsu.edu\CSS\ascc-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see "
		. "[https://github.com/invokeImmediately/ascc.wsu.edu] for a repository of source code. "
		. "*/`r`n`r`n", "Couldn't copy minified CSS for ASCC website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.2: @copyBackupCssAscc — Hotstring

:*:@copyBackupCssAscc::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ascc.wsu.edu\CSS\ascc-custom.min.prev.css"
		, "", "Couldn't copy backup CSS for ASCC Reading website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.3: @copyMinCssCr — Hotstring

:*:@copyMinCssCr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see "
		. "[https://github.com/invokeImmediately/commonreading.wsu.edu] for a repository of source "
		. "code. */`r`n`r`n", "Couldn't copy minified CSS for Common Reading website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.4: @copyBackupCssCr — Hotstring

:*:@copyBackupCssCr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\commonreading.wsu.edu\CSS\cr-custom.min.prev.css"
		, "", "Couldn't copy backup CSS for Common Reading website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.5: @copyMinCssDsp — Hotstring

:*:@copyMinCssDsp::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.min.css"
		, "", "Couldn't copy minified CSS for DSP Website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.6: @copyBackupCssDsp — Hotstring

:*:@copyBackupCssDsp::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.prev.css"
		, "", "Couldn't copy backup CSS for DSP Website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.7: @copyMinCssFye — Hotstring

:*:@copyMinCssFye::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see "
		. "[https://github.com/invokeImmediately/firstyear.wsu.edu] for a repository of source "
		. "code. */`r`n`r`n", "Couldn't copy minified CSS for FYE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.8: @copyBackupCssFye — Hotstring

:*:@copyBackupCssFye::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.prev.css"
		, "", "Couldn't copy backup CSS for FYE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.9: @copyMinCssFyf — Hotstring

:*:@copyMinCssFyf::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see "
		. "[https://github.com/invokeImmediately/learningcommunities.wsu.edu] for a repository of "
		. "source code. */`r`n`r`n", "Couldn't copy minified CSS for First-Year Focus website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.10: @copyBackupCssFyf — Hotstring

:*:@copyBackupCssFyf::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.prev.css"
		, "", "Couldn't copy backup CSS for First-Year Focus website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.11: @copyMinCssNse — Hotstring

:*:@copyMinCssNse::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.min.css"
		, "", "Couldn't copy minified CSS for NSE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.12: @copyBackupCssNse — Hotstring

:*:@copyBackupCssNse::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\nse.wsu.edu\CSS\nse-custom.prev.css"
		, "", "Couldn't copy backup CSS for NSE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.13: @copyMinCssOue — Hotstring

:*:@copyMinCssOue::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\oue.wsu.edu\CSS\oue-custom.min.css"
		, "", "Couldn't copy minified CSS for OUE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.14: @copyMinCssPbk — Hotstring

:*:@copyMinCssPbk::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.min.css"
		, "", "Couldn't copy minified CSS for Phi Beta Kappa website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.15: @copyBackupCssPbk — Hotstring

:*:@copyBackupCssPbk::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\CSS\pbk-custom.prev.css"
		, "", "Couldn't copy backup CSS for Phi Beta Kappa website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.16: @copyMinCssSurca — Hotstring

:*:@copyMinCssSurca::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.min.css"
		, "/*! Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see "
		. "[https://github.com/invokeImmediately/surca.wsu.edu] for a repository of source code. "
		. "*/`r`n`r`n", "Couldn't copy minified CSS for SURCA website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.17: @copyBackupCssSurca — Hotstring

:*:@copyBackupCssSurca::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.prev.css"
		, "", "Couldn't copy backup CSS for SURCA website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.18: @copyMinCssSumRes — Hotstring

:*:@copyMinCssSumRes::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.min.css", ""
		, "Couldn't copy minified CSS for Summer Research website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.19: @copyBackupCssSumRes — Hotstring

:*:@copyBackupCssSumRes::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.prev.css"
		, "", "Couldn't copy backup CSS for Summer Research website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.20: @copyMinCssXfer — Hotstring

:*:@copyMinCssXfer::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.min.css"
		, "", "Couldn't copy minified CSS for Transfer Credit website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.21: @copyBackupCssXfer — Hotstring

:*:@copyBackupCssXfer::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.prev.css"
		, "", "Couldn't copy backup CSS for Transfer Credit website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.22: @copyMinCssUgr — Hotstring

:*:@copyMinCssUgr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\"
		. "undergraduate-research-custom.min.css", "/*! Built with the LESS CSS preprocessor "
		. "", "Couldn't copy minified CSS for UGR website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.23: @copyBackupCssUgr — Hotstring

:*:@copyBackupCssUgr::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.pre"
		. "v.css", "", "Couldn't copy backup CSS for UGR website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.24: @copyMinCssUcore — Hotstring

:*:@copyMinCssUcore::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.min.css"
		, "", "Couldn't copy minified CSS for UCORE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.25: @copyBackupCssUcore — Hotstring

:*:@copyBackupCssUcore::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu\CSS\ucore-custom.prev.css"
		, "", "Couldn't copy backup CSS for UCORE website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.26: @copyMinCssUcrAss — Hotstring

:*:@copyMinCssUcrAss::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
		, "", "Couldn't copy minified CSS for UCORE Assessment website.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.4.27: @copyBackupCssUcrAss — Hotstring

:*:@copyBackupCssUcrAss::
	AppendAhkCmd(A_ThisLabel)
	CopySrcFileToClipboard(A_ThisLabel
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\CSS\ucore-assessment-custom.min.css"
		, "", "Couldn't copy backup CSS for UCORE Assessment website.")
Return

;   ································································································
;     >>> §7.5: FOR BACKING UP CUSTOM JS BUILDS

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.1: @backupJsAscc — Hotstring

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
;       →→→ §7.5.2: @backupJsCr — Hotstring

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
;       →→→ §7.5.3: @backupJsDsp — Hotstring

:*:@backupJsDsp::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://distinguishedscholarships.wsu.edu/wp-admin/themes.php?page=custom-ja"
		. "vascript", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\distinguishedscholarships.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.4: @backupJsFye — Hotstring

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
;       →→→ §7.5.5: @backupJsFyf — Hotstring

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
;       →→→ §7.5.6: @backupJsNse — Hotstring

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
;       →→→ §7.5.7: @backupJsOue — Hotstring

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
;       →→→ §7.5.8: @backupJsPbk — Hotstring

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
;       →→→ §7.5.9: @backupJsSurca — Hotstring

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
;       →→→ §7.5.10: @backupJsSumRes — Hotstring

:*:@backupJsSumRes::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript"
		, copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\summerresearch.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	GoSub, :*:@commitBackupJsSumRes
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.11: @commitBackupJsSumRes — Hotstring

:*:@commitBackupJsSumRes::
	AppendAhkCmd(A_ThisLabel)
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.12: @backupJsXfer — Hotstring

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
;       →→→ §7.5.13: @backupJsUgr — Hotstring

:*:@backupJsUgr::
	AppendAhkCmd(A_ThisLabel)
	CopyJsFromWebsite("https://undergraduateresearch.wsu.edu/wp-admin/themes.php?page=custom-javasc"
		. "ript", copiedJs)
	WriteCodeToFile(A_ThisLabel, copiedJs, GetGitHubFolder()
		. "\undergraduateresearch.wsu.edu\JS\wp-custom-js-source.min.prev.js")
	PasteTextIntoGitShell(A_ThisLabel
		, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.min.prev.js`r"
		. "git commit -m 'Updating backup of latest verified custom JS build'`r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.14: @backupJsUcore — Hotstring

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
;       →→→ §7.5.15: @backupJsUcrAss — Hotstring

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
;       →→→ §7.5.16: @backupJsAll — Hotstring

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
;       →→→ §7.5.17: CopyJsFromWebsite — Function

CopyJsFromWebsite(websiteUrl, ByRef copiedJs)
{
	LoadWordPressSiteInChrome(websiteUrl)
	ExecuteJsCopyCmds(copiedJs)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.5.18: ExecuteJsCopyCmds — Function

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
;     >>> §7.6: FOR REBUILDING JS SOURCE FILES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.1: @rebuildJsAscc — Hotstring

:*:@rebuildJsAscc::
	ahkCmdName := ":*:@rebuildJsAscc"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\ascc.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs ascc-custom.js --output ascc-custom.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\ascc.wsu.edu\'`r"
		. "git add JS\ascc-custom.js`r"
		. "git add JS\ascc-custom.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.2: @rebuildJsCr — Hotstring

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
;       →→→ §7.6.3: @rebuildJsDsp — Hotstring

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
;       →→→ §7.6.4: @commitJsDsp — Hotstring

:*:@commitJsDsp::
	gitFolder := "distinguishedscholarships.wsu.edu" ; fp = file path
	jsSrcFile := "dsp-custom.js" ; fn = file name
	jsBuildFile := "dsp-custom-build.js"
	minJsBuildFile := "dsp-custom-build.min.js"
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, gitFolder, jsSrcFile, jsBuildFile, minJsBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.5: @rebuildJsFye — Hotstring

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
;       →→→ §7.6.6: @rebuildJsFyf — Hotstring

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
;       →→→ §7.6.7: @rebuildJsNse — Hotstring

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
;       →→→ §7.6.8: @rebuildJsOue — Hotstring

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
;       →→→ §7.6.9: @rebuildJsPbk — Hotstring

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
;       →→→ §7.6.10: @rebuildJsSurca — Hotstring

:*:@rebuildJsSurca::
	ahkCmdName := ":*:@rebuildJsSurca"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\surca.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\surca.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.11: @rebuildJsSumRes — Hotstring

:*:@rebuildJsSumRes::
	ahkCmdName := ":*:@rebuildJsSumRes"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "Start-Sleep -s 1`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`"
		. " --comments /^!/`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.12: @rebuildJsXfer — Hotstring

:*:@rebuildJsXfer::
	ahkCmdName := ":*:@rebuildJsXfer"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu\'`r"
		. "gulp buildMinJs`r"
		. "[console]::beep(1500,300)`r")
	CommitAfterBuild(ahkCmdName, ":*:@commitJsXfer")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.13: @commitJsXfer — Hotstring

:*:@commitJsXfer::
	gitFolder := "transfercredit.wsu.edu" ; fp = file path
	jsSrcFile := "transfer-central-custom.js" ; fn = file name
	jsBuildFile := "transfer-central-custom-build.js"
	minJsBuildFile := "transfer-central-custom-build.min.js"
	AppendAhkCmd(A_ThisLabel)
	CommitJsBuild(A_ThisLabel, gitFolder, jsSrcFile, jsBuildFile, minJsBuildFile)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.14: @rebuildJsUgr — Hotstring

:*:@rebuildJsUgr::
	ahkCmdName := ":*:@rebuildJsUgr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.15: @rebuildJsUcore — Hotstring

:*:@rebuildJsUcore::
	ahkCmdName := ":*:@rebuildJsUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu\JS'`r"
		. "node build-production-file.js`r"
		. "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
		. "[console]::beep(1500,300)`r"
		. "cd '" . GetGitHubFolder() . "\ucore.wsu.edu\'`r"
		. "git add JS\wp-custom-js-source.js`r"
		. "git add JS\wp-custom-js-source.min.js`r"
		. "git commit -m 'Updating custom JS build' -m 'Rebuilt production files to incorporate "
		. "recent changes to source code and/or dependencies' `r"
		. "git push`r")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.6.16: @rebuildJsUcrAss — Hotstring

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
;     >>> §7.7: FOR UPDATING JS SUBMODULES

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.1: @updateJsSubmoduleAscc — Hotstring

:*:@updateJsSubmoduleAscc::
	ahkCmdName := ":*:@updateJsSubmoduleAscc"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\ascc.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsAscc
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.2: @updateJsSubmoduleCr — Hotstring

:*:@updateJsSubmoduleCr::
	ahkCmdName := ":*:@updateJsSubmoduleCr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\commonreading.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsCr
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.3: @updateJsSubmoduleDsp — Hotstring

:*:@updateJsSubmoduleDsp::
	ahkCmdName := ":*:@updateJsSubmoduleDsp"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsDsp
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.4: @updateJsSubmoduleFye — Hotstring

:*:@updateJsSubmoduleFye::
	ahkCmdName := ":*:@updateJsSubmoduleFye"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsFye
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.5: @updateJsSubmoduleFyf — Hotstring

:*:@updateJsSubmoduleFyf::
	ahkCmdName := ":*:@updateJsSubmoduleFyf"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsFyf
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.6: @updateJsSubmoduleNse — Hotstring

:*:@updateJsSubmoduleNse::
	ahkCmdName := ":*:@updateJsSubmoduleNse"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\nse.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsFyf
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.7: @updateJsSubmoduleOue — Hotstring

:*:@updateJsSubmoduleOue::
	ahkCmdName := ":*:@updateJsSubmoduleOue"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\oue.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsOue
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.8: @updateJsSubmodulePbk — Hotstring

:*:@updateJsSubmodulePbk::
	ahkCmdName := ":*:@updateJsSubmodulePbk"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\phibetakappa.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsPbk
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.9: @updateJsSubmoduleSurca — Hotstring

:*:@updateJsSubmoduleSurca::
	ahkCmdName := ":*:@updateJsSubmoduleSurca"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsSurca
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.10: @updateJsSubmoduleSumRes — Hotstring

:*:@updateJsSubmoduleSumRes::
	ahkCmdName := ":*:@updateJsSubmoduleSumRes"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsSumRes
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.11: @updateJsSubmoduleXfer — Hotstring

:*:@updateJsSubmoduleXfer::
	ahkCmdName := ":*:@updateJsSubmoduleXfer"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsXfer
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.12: @updateJsSubmoduleUgr — Hotstring

:*:@updateJsSubmoduleUgr::
	ahkCmdName := ":*:@updateJsSubmoduleUgr"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsUgr
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.13: @updateJsSubmoduleUcore — Hotstring

:*:@updateJsSubmoduleUcore::
	ahkCmdName := ":*:@updateJsSubmoduleUcore"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsUcore
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.14: @updateJsSubmoduleUcrAss — Hotstring

:*:@updateJsSubmoduleUcrAss::
	ahkCmdName := ":*:@updateJsSubmoduleUcrAss"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd '" . GetGitHubFolder() . "\ucore.wsu.edu-assessment\WSU-UE---JS'`r"
		. "git fetch`r"
		. "git merge origin/master`r"
		. "cd ..`r"
		. "git add WSU-UE---JS`r"
		. "git commit -m 'Updating custom JS master submodule for OUE websites' -m 'Incorporating "
		. "recent changes in project source code'`r"
		. "git push`r")
	Gosub, :*:@rebuildJsUcrAss
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.7.15: @updateJsSubmoduleAll — Hotstring

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
;     >>> §7.8: Shortcuts for copying minified JS to clipboard

;TODO: Add scripts for copying JS backups to clipboard (see CSS backup-copying scripts above)

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.1: @copyMinJsAscc — Hotstring

:*:@copyMinJsAscc::
	ahkCmdName := ":*:@copyMinJsAscc"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ascc.wsu.edu\JS\ascc-custom.min.js"
		, "", "Couldn't Copy Minified JS for ASCC Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.2: @copyMinJsCr — Hotstring

:*:@copyMinJsCr::
	ahkCmdName := ":*:@copyMinJsCr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\commonreading.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for CR Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.3: @copyMinJsDsp — Hotstring

:*:@copyMinJsDsp::
	ahkCmdName := ":*:@copyMinJsDsp"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS\wp-custom-js-source.min.dsp.js"
		, "", "Couldn't Copy Minified JS for DSP Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.4: @copyMinJsFye — Hotstring

:*:@copyMinJsFye::
	ahkCmdName := ":*:@copyMinJsFye"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\firstyear.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for FYE Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.5: @copyMinJsFyf — Hotstring

:*:@copyMinJsFyf::
	ahkCmdName := ":*:@copyMinJsFyf"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\learningcommunities.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for FYF Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.6: @copyMinJsNse — Hotstring

:*:@copyMinJsNse::
	ahkCmdName := ":*:@copyMinJsNse"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\nse.wsu.edu\JS\nse-custom.min.js"
		, "", "Couldn't Copy Minified JS for Nse Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.7: @copyMinJsOue — Hotstring

:*:@copyMinJsOue::
	ahkCmdName := ":*:@copyMinJsOue"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\oue-custom.min.js"
		, "", "Couldn't Copy Minified JS for WSU OUE Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.8: @copyBackupJsOue — Hotstring

:*:@copyBackupJsOue::
	ahkCmdName := ":*:@copyBackupJsOue"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\oue.wsu.edu\JS\oue-custom.min.prev.js"
		, "", "Couldn't copy backup copy of minified JS for WSU OUE website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.9: @copyMinJsPbk — Hotstring

:*:@copyMinJsPbk::
	ahkCmdName := ":*:@copyMinJsPbk"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\phibetakappa.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Phi Beta Kappa Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.10: @copyMinJsSurca — Hotstring

:*:@copyMinJsSurca::
	ahkCmdName := ":*:@copyMinJsSurca"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\surca.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for SURCA Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.11: @copyMinJsSumRes — Hotstring

:*:@copyMinJsSumRes::
	ahkCmdName := ":*:@copyMinJsSumRes"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\summerresearch.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Summer Research Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.12: @copyMinJsXfer — Hotstring

:*:@copyMinJsXfer::
	ahkCmdName := ":*:@copyMinJsXfer"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Transfer Credit Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.13: @copyMinJsUgr — Hotstring

:*:@copyMinJsUgr::
	ahkCmdName := ":*:@copyMinJsUgr"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for UGR Website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.14: @copyMinJsUcore — Hotstring

:*:@copyMinJsUcore::
	ahkCmdName := ":*:@copyMinJsUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.min.js"
		, "", "Couldn't copy minified JS for UCORE website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.15: @copyBackupJsUcore — Hotstring

:*:@copyBackupJsUcore::
	ahkCmdName := ":*:@copyBackupJsUcore"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu\JS\wp-custom-js-source.min.prev.js"
		, ""		, "Couldn't copy backup copy of minified JS for UCORE website")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §7.8.16: @copyMinJsUcrAss — Hotstring

:*:@copyMinJsUcrAss::
	ahkCmdName := ":*:@copyMinJsUcrAss"
	AppendAhkCmd(ahkCmdName)
	CopySrcFileToClipboard(ahkCmdName
		, GetGitHubFolder() . "\ucore.wsu.edu-assessment\JS\wp-custom-js-source.min.js"
		, "", "Couldn't Copy Minified JS for WSU Summer Research Website")
Return

;   ································································································
;     >>> §7.9: FOR CHECKING GIT STATUS ON ALL PROJECTS 

:*:@checkGitStatus::
	ahkCmdName := ":*:@checkGitStatus"
	AppendAhkCmd(ahkCmdName)
	PasteTextIntoGitShell(ahkCmdName
		, "cd 'C:\Users\CamilleandDaniel\Documents\GitHub\'`r`n"
		. "Write-Host ""``n----------------------------------------------WSU-OUE-AutoHotkey--------"
		. "---------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-OUE-AutoHotkey\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n------------------------------------------------WSU-OUE---CSS-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---CSS\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------------WSU-OUE---JS-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---JS\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------------ascc.wsu.edu-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ascc.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------------commonreading.wsu.edu-------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\commonreading.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------distinguishedscholarships.wsu.edu-"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\distinguishedscholarships.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n----------------------------------------------firstyear.wsu.edu---------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\firstyear.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-----------------------------------------learningcommunities.wsu.edu----"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\learningcommunities.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------------oue.wsu.edu------------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\oue.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n------------------------------------------------surca.wsu.edu-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\surca.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n----------------------------------------undergraduateresearch.wsu.edu---"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\undergraduateresearch.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------------transfercredit.wsu.edu------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\transfercredit.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n--------------------------------------------summerresearch.wsu.edu------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\summerresearch.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n------------------------------------------------ucore.wsu.edu-----------"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ucore.wsu.edu\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n"
		. "Write-Host ""``n-------------------------------------------ucore.wsu.edu/assessment-----"
		. "--------------------------------------"" -ForegroundColor ""green""`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\ucore.wsu.edu-assessment\""`r`n"
		. "git status`r`n"
		. "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\""`r`n")
Return

; --------------------------------------------------------------------------------------------------
;   §8: KEYBOARD SHORTCUTS FOR POWERSHELL
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §8.1: SHORTCUTS

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
;     >>> §8.2: SUPPORTING FUNCTIONS

PerformBypassingCtrlShftV:
	Suspend
	Sleep 10
	SendInput ^+v
	Sleep 10
	Suspend, Off
Return
