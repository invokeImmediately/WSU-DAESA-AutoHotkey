; ==================================================================================================
; fileSystem.ahk: file system navigation
; ==================================================================================================
; Table of Contents
; ---------------------------------
;   §1: Current temporary shortcut.............................................................15
;   §2: Torah study............................................................................24
;   §3: Documents folders......................................................................33
;   §4: GitHub repository folders..............................................................49
;   §5: Web development folders...............................................................143
;   §6: Coding resource folders...............................................................216
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Current temporary shortcut
; --------------------------------------------------------------------------------------------------

:*:@gotoCurrent::
	AppendAhkCmd(A_ThisLabel)
	SendInput %hhdWorkFolder%\{^}Derek-Haqodesh\TheMessage.cc\Messages\Message_The-Man-from-Heaven_2015-12-06{Enter}
Return

; --------------------------------------------------------------------------------------------------
;   §2: Torah study
; --------------------------------------------------------------------------------------------------

:*:@gotoTorah::
	AppendAhkCmd(A_ThisLabel)
	SendInput %hhdWorkFolder%\{^}Derek-Haqodesh\{Enter}
Return

; --------------------------------------------------------------------------------------------------
;   §3: Documents folders
; --------------------------------------------------------------------------------------------------

:*:@gotoTorah::

:*:@gotoDocs::
	AppendAhkCmd(A_ThisLabel)
	SendInput %userAccountFolderHDD%\Documents\{Enter}
Return

:*:@gotoSsdDocs::
	AppendAhkCmd(A_ThisLabel)
	SendInput %userAccountFolderSSD%\Documents\{Enter}
Return

; --------------------------------------------------------------------------------------------------
;   §4: GitHub repository folders
; --------------------------------------------------------------------------------------------------

:*:@gotoGithub::
	AppendAhkCmd(A_ThisLabel)
	SendInput %userAccountFolderSSD%\Documents\GitHub{Enter}
Return

:*:@gotoGhAscc::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\ascc.wsu.edu", "ascc.wsu.edu") 
Return

:*:@gotoGhCr::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\commonreading.wsu.edu"
		, "commonreading.wsu.edu") 
Return

:*:@gotoGhDsp::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\distinguishedscholarships.wsu.edu"
		, "distinguishedscholarships.wsu.edu") 
Return

:*:@gotoGhFye::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\firstyear.wsu.edu", "firstyear.wsu.edu")
Return

:*:@gotoGhFyf::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\learningcommunities.wsu.edu"
		, "learningcommunities.wsu.edu")
Return

:*:@gotoGhNse::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\nse.wsu.edu", "nse.wsu.edu")
Return

:*:@gotoGhOue::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\oue.wsu.edu", "oue.wsu.edu")
Return

:*:@gotoGhPbk::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\phibetakappa.wsu.edu"
		, "phibetakappa.wsu.edu")
Return

:*:@gotoGhRsp::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\admissions.wsu.edu-research-scholars"
		, "admissions.wsu.edu/research-scholars")
Return

:*:@gotoGhSurca::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\surca.wsu.edu", "surca.wsu.edu")
Return

:*:@gotoGhSumRes::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\summerresearch.wsu.edu"
		, "summerresearch.wsu.edu")
Return

:*:@gotoGhXfer::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\transfercredit.wsu.edu"
		, "transfercredit.wsu.edu")
Return

:*:@gotoGhUgr::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\undergraduateresearch.wsu.edu"
		, "undergraduateresearch.wsu.edu")
Return

:*:@gotoGhUcore::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\ucore.wsu.edu", "ucore.wsu.edu")
Return

:*:@gotoGhUcrAss::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\ucore.wsu.edu-assessment"
		, "ucore.wsu.edu-assessment")
Return

:*:@gotoGhCSS::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\WSU-UE---CSS", "WSU-UE---CSS")
Return

:*:@gotoGhJS::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\WSU-UE---JS", "WSU-UE---JS")
Return

:*:@gotoGhAhk::
	InsertFilePath(A_ThisLabel, GetGitHubFolder() . "\WSU-OUE-AutoHotkey", "WSU-OUE-AutoHotkey")
Return

:*:cdcss::cd wsu-ue---css

:*:cdjs::cd wsu-ue---js

; --------------------------------------------------------------------------------------------------
;   §5: Web development folders
; --------------------------------------------------------------------------------------------------

:*:@gotoWebDev::
	AppendAhkCmd(A_ThisLabel)
	SendInput %webDevFolder%{Enter}
Return

:*:@gotoWdAscc::
    InsertFilePath(A_ThisLabel, webDevFolder . "\ASCC") 
Return

:*:@gotoWdCr::
    InsertFilePath(A_ThisLabel, webDevFolder . "\CR") 
Return

:*:@gotoWdDsp::
    InsertFilePath(A_ThisLabel, webDevFolder . "\DSP") 
Return

:*:@gotoWdFye::
    InsertFilePath(A_ThisLabel, webDevFolder . "\FYE & FYF")
Return

:*:@gotoWdFyf::
    InsertFilePath(A_ThisLabel, webDevFolder . "\FYE & FYF")
Return

:*:@gotoWdMstr::
    InsertFilePath(A_ThisLabel, webDevFolder . "\{^}Master-VPUE")
Return

:*:@gotoWdNse::
    InsertFilePath(A_ThisLabel, webDevFolder . "\NSE")
Return

:*:@gotoWdOue::
    InsertFilePath(A_ThisLabel, webDevFolder . "\OUE") 
Return

:*:@gotoWdPf::
    InsertFilePath(A_ThisLabel, webDevFolder . "\{^}Personnel-File")
Return

:*:@gotoWdSurca::
    InsertFilePath(A_ThisLabel, webDevFolder . "\SURCA")
Return

:*:@gotoWdSumRes::
    InsertFilePath(A_ThisLabel, webDevFolder . "\Summer-Res")
Return

:*:@gotoWdUcrAss::
    InsertFilePath(A_ThisLabel, webDevFolder . "\UCORE-Assessment")
Return

:*:@gotoWdUcore::
    InsertFilePath(A_ThisLabel, webDevFolder . "\UCORE")
Return

:*:@gotoWdUgr::
    InsertFilePath(A_ThisLabel, webDevFolder . "\UGR")
Return

:*:@gotoWdVpue::
    InsertFilePath(A_ThisLabel, webDevFolder . "\VPUE")
Return

:*:@gotoWdXfer::
    InsertFilePath(A_ThisLabel, webDevFolder . "\xfer")
Return

; --------------------------------------------------------------------------------------------------
;   §6: Coding resource folders
; --------------------------------------------------------------------------------------------------

:*:@openNodeCodes::
	AppendAhkCmd(A_ThisLabel)
	SendInput %webDevFolder%\{^}Master-VPUE\Node\node-commands.bat{Enter}
Return

:*:@openGitCodes::
	AppendAhkCmd(A_ThisLabel)
	SendInput %webDevFolder%\GitHub\git-codes.bat{Enter}
Return
