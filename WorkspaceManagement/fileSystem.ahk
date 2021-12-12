; ==================================================================================================
; █▀▀▀ ▀█▀ █    █▀▀▀ ▄▀▀▀ █  █ ▄▀▀▀▐▀█▀▌█▀▀▀ ▐▀▄▀▌   ▄▀▀▄ █  █ █ ▄▀ 
; █▀▀▀  █  █  ▄ █▀▀  ▀▀▀█ ▀▄▄█ ▀▀▀█  █  █▀▀  █ ▀ ▌   █▄▄█ █▀▀█ █▀▄  
; ▀    ▀▀▀ ▀▀▀  ▀▀▀▀ ▀▀▀  ▄▄▄▀ ▀▀▀   █  ▀▀▀▀ █   ▀ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; File system navigation.
;
; @version 0.0.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/WorkspaceManagement/file
;   System.ahk
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
;   §1: Current temporary shortcut.............................................................41
;   §2: Torah study............................................................................50
;   §3: Documents folders......................................................................59
;   §4: GitHub repository folders..............................................................77
;   §5: Web development folders...............................................................183
;   §6: Coding resource folders...............................................................260
;   §7: Photo folders.........................................................................274
;   §8: Project folders.......................................................................286
;   §9: @gotoFL: Goto file location...........................................................295
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Current temporary shortcut
; --------------------------------------------------------------------------------------------------

:*?:@gotoCurrent::
	AppendAhkCmd(A_ThisLabel)
	InsertFilePath(A_ThisLabel, "C:\Documents\GitHub (Old)\")
Return

; --------------------------------------------------------------------------------------------------
;   §2: Torah study
; --------------------------------------------------------------------------------------------------

:*?:@gotoTorah::
	AppendAhkCmd(A_ThisLabel)
	SendInput %hhdWorkFolder%\{^}Derek-Haqodesh\{Enter}
Return

; --------------------------------------------------------------------------------------------------
;   §3: Documents folders
; --------------------------------------------------------------------------------------------------

:*?:@gotoDocs::
	AppendAhkCmd(A_ThisLabel)
	SendInput %userAccountFolderHDD%\Documents\{Enter}
Return

:*?:@gotoDaniel::
	InsertFilePath(A_ThisLabel, userAccountFolderHDD . "\Documents\Daniel\")
Return

:*?:@gotoSsdDocs::
	AppendAhkCmd(A_ThisLabel)
	SendInput %userAccountFolderSSD%\Documents\{Enter}
Return

; --------------------------------------------------------------------------------------------------
;   §4: GitHub repository folders
; --------------------------------------------------------------------------------------------------

:*?:@gotoGithub::
	InsertFilePath(A_ThisLabel, GetGitHubFolder())
Return

:*?:@gotoGhAscc::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\ascc.wsu.edu", "ascc.wsu.edu") 
Return

:*?:@gotoGhCr::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\commonreading.wsu.edu"
		, "commonreading.wsu.edu") 
Return

:*?:@gotoGhDsp::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu"
		, "distinguishedscholarships.wsu.edu") 
Return

:*?:@gotoGhFye::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\firstyear.wsu.edu", "firstyear.wsu.edu")
Return

:*?:@gotoGhFyf::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\learningcommunities.wsu.edu"
		, "learningcommunities.wsu.edu")
Return

:*?:@gotoGhLsamp::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\lsamp.wsu.edu", "lsamp.wsu.edu")
Return

:*?:@gotoGhNse::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\nse.wsu.edu", "nse.wsu.edu")
Return

:*?:@gotoGhNsse::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\nsse.wsu.edu", "nsse.wsu.edu")
Return

:*?:@gotoGhOue::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\oue.wsu.edu", "oue.wsu.edu")
Return

:*?:@gotoGhPbk::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\phibetakappa.wsu.edu"
		, "phibetakappa.wsu.edu")
Return

:*?:@gotoGhRsp::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\admissions.wsu.edu-research-scholars"
		, "admissions.wsu.edu/research-scholars")
Return

:*?:@gotoGhSurca::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\surca.wsu.edu", "surca.wsu.edu")
Return

:*?:@gotoGhSumRes::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\summerresearch.wsu.edu"
		, "summerresearch.wsu.edu")
Return

:*?:@gotoGhXfer::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\transfercredit.wsu.edu"
		, "transfercredit.wsu.edu")
Return

:*?:@gotoGhTAcad::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\teachingacademy.wsu.edu"
		, "teachingacademy.wsu.edu")
Return

:*?:@gotoGhUgr::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\undergraduateresearch.wsu.edu"
		, "undergraduateresearch.wsu.edu")
Return

:*?:@gotoGhUcore::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\ucore.wsu.edu", "ucore.wsu.edu")
Return

:*?:@gotoGhUcrAss::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\ucore.wsu.edu-assessment"
		, "ucore.wsu.edu-assessment")
Return

:*?:@gotoGhCSS::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\WSU-UE---CSS", "WSU-UE---CSS")
Return

:*?:@gotoGhJS::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\WSU-DAESA-JS", "WSU-DAESA-JS")
Return

:*?:@gotoGhAhk::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\WSU-DAESA-AutoHotkey", "WSU-DAESA-AutoHotkey")
Return

:*:cdcss::cd WSU-UE---CSS

:*:cdjs::cd WSU-DAESA-JS

; --------------------------------------------------------------------------------------------------
;   §5: Web development folders
; --------------------------------------------------------------------------------------------------

:*?:@gotoWebDev::
	AppendAhkCmd(A_ThisLabel)
	SendInput %webDevFolder%{Enter}
Return

:*?:@gotoWdAscc::
    InsertFilePath(A_ThisLabel, webDevFolder . "\ASCC") 
Return

:*?:@gotoWdCr::
    InsertFilePath(A_ThisLabel, webDevFolder . "\CR") 
Return

:*?:@gotoWdDsp::
    InsertFilePath(A_ThisLabel, webDevFolder . "\DSP") 
Return

:*?:@gotoWdFye::
    InsertFilePath(A_ThisLabel, webDevFolder . "\FYE & FYF")
Return

:*?:@gotoWdFyf::
    InsertFilePath(A_ThisLabel, webDevFolder . "\FYE & FYF")
Return

:*?:@gotoWdLsamp::
    InsertFilePath(A_ThisLabel, webDevFolder . "\LSAMP")
Return

:*?:@gotoWdMstr::
    InsertFilePath(A_ThisLabel, webDevFolder . "\{^}Master-VPUE")
Return

:*?:@gotoWdNse::
    InsertFilePath(A_ThisLabel, webDevFolder . "\NSE")
Return

:*?:@gotoWdOue::
    InsertFilePath(A_ThisLabel, webDevFolder . "\OUE") 
Return

:*?:@gotoWdPf::
    InsertFilePath(A_ThisLabel, webDevFolder . "\{^}Personnel-File")
Return

:*?:@gotoWdSurca::
    InsertFilePath(A_ThisLabel, webDevFolder . "\SURCA")
Return

:*?:@gotoWdSumRes::
    InsertFilePath(A_ThisLabel, webDevFolder . "\Summer-Res")
Return

:*?:@gotoWdUcrAss::
    InsertFilePath(A_ThisLabel, webDevFolder . "\UCORE-Assessment")
Return

:*?:@gotoWdUcore::
    InsertFilePath(A_ThisLabel, webDevFolder . "\UCORE")
Return

:*?:@gotoWdUgr::
    InsertFilePath(A_ThisLabel, webDevFolder . "\UGR")
Return

:*?:@gotoWdVpue::
    InsertFilePath(A_ThisLabel, webDevFolder . "\VPUE")
Return

:*?:@gotoWdXfer::
    InsertFilePath(A_ThisLabel, webDevFolder . "\xfer")
Return

; --------------------------------------------------------------------------------------------------
;   §6: Coding resource folders
; --------------------------------------------------------------------------------------------------

:*?:@openNodeCodes::
	AppendAhkCmd(A_ThisLabel)
	SendInput %webDevFolder%\{^}Master-VPUE\Node\node-commands.bat{Enter}
Return

:*?:@openGitCodes::
	AppendAhkCmd(A_ThisLabel)
	SendInput %webDevFolder%\GitHub\git-codes.bat{Enter}
Return

; --------------------------------------------------------------------------------------------------
;   §7: Photo folders
; --------------------------------------------------------------------------------------------------

:*?:@gotoPhotos::
	InsertFilePath(A_ThisLabel, userAccountFolderHDD . "\Pictures")
Return

:*?:@gotoGraphics::
	InsertFilePath(A_ThisLabel, userAccountFolderHDD . "\Documents\Daniel\Graphics")
Return

; --------------------------------------------------------------------------------------------------
;   §8: Project folders
; --------------------------------------------------------------------------------------------------

:*?:@gotoProjects::
	InsertFilePath(A_ThisLabel, userAccountFolderHDD . "\Documents\Daniel\{^}Projects")
Return


; --------------------------------------------------------------------------------------------------
;   §9: @gotoFL: Goto file location
; --------------------------------------------------------------------------------------------------

:*?:@gotoFL::
	MsgBox % A_ThisLabel . ": This hotstring is still being designed."
	; TODO: Design log file structure.
	; TODO: Write log file from the above locations.
	; TODO: Decide: Object-oriented approach?
	; TODO: Decide: Is there a need to preserve meaning of global variables such as
	;	userAccountFolderHDD?
	; TODO: Decide: Incorporate trie functionality when searching for file locations?
	; TODO: Write function: gtfl_CreateGUI - Start the GUI.
	; TODO: Write function: gtfl_CheckLog - See if the file location log has already been loaded.
	; TODO: Write function: gtfl_CheckLogFile - See if log file exists and respond accordingly
	; TODO: Write function: gtfl_LoadLogFromFile - Open log file and use RegEx to parse it into
	;	file locations and shorthand strings.
	; TODO: Write function: gtfl_CheckFileLocation
	; TODO: Write function: gtfl_SaveLogToFile
	; TODO: Write function: gtfl_AddLocationToLog
	; TODO: Write function: gtfl_RemoveLocationFromLog
	; TODO: Write functions: GUI handlers.
Return
