; ---------------------------------------------------------------------------------------------------------------------------
;   FILE SYSTEM NAVIGATION
; ---------------------------------------------------------------------------------------------------------------------------

:*:@gotoTorah::
	AppendAhkCmd(":*:@gotoTorah")
	SendInput, %hhdWorkFolder%\{^}Derek-Haqodesh\{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoCurrent::
	AppendAhkCmd(":*:@gotoCurrent")
	SendInput, %hhdWorkFolder%\{^}Derek-Haqodesh\TheMessage.cc\Messages\Message_The-Man-from-Heaven_2015-12-06{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoDocs::
	AppendAhkCmd(":*:@gotoDocs")
	SendInput, %userAccountFolderHDD%\Documents\{Enter}
Return

:*:@gotoSsdDocs::
	AppendAhkCmd(":*:@gotoSsdDocs")
	SendInput, %userAccountFolderSSD%\Documents\{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoGithub::
	AppendAhkCmd(":*:@gotoGithub")
	SendInput, %userAccountFolderSSD%\Documents\GitHub{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWebDev::
	AppendAhkCmd(":*:@gotoWebDev")
	SendInput, %webDevFolder%{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdAscc::
    InsertFilePath(":*:@gotoWdCr", webDevFolder . "\ASCC") 
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdCr::
    InsertFilePath(":*:@gotoWdCr", webDevFolder . "\CR") 
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdDsp::
    InsertFilePath(":*:@gotoWdDsp", webDevFolder . "\DSP") 
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdFye::
    InsertFilePath(":*:@gotoWdFye", webDevFolder . "\FYE & FYF")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdFyf::
    InsertFilePath(":*:@gotoWdFyf", webDevFolder . "\FYE & FYF")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdMstr::
    InsertFilePath(":*:@gotoWdPf", webDevFolder . "\{^}Master-VPUE")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdNse::
    InsertFilePath(":*:@gotoWdNse", webDevFolder . "\NSE")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdOue::
    InsertFilePath(":*:@gotoWdOue", webDevFolder . "\OUE") 
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdPf::
    InsertFilePath(":*:@gotoWdPf", webDevFolder . "\{^}Personnel-File")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdSurca::
    InsertFilePath(":*:@gotoWdSurca", webDevFolder . "\SURCA")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdSumRes::
    InsertFilePath(":*:@gotoWdSumRes", webDevFolder . "\Summer-Res")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdUcrAss::
    InsertFilePath(":*:@gotoWdUcrAss", webDevFolder . "\UCORE-Assessment")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdUcore::
    InsertFilePath(":*:@gotoWdUcore", webDevFolder . "\UCORE")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdUgr::
    InsertFilePath(":*:@gotoWdUgr", webDevFolder . "\UGR")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoWdXfer::
    InsertFilePath(":*:@gotoWdXfer", webDevFolder . "\xfer")
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@openNodeCodes::
	AppendAhkCmd(":*:@openNodeCodes")
	SendInput, %webDevFolder%\{^}Master-VPUE\Node\node-commands.bat{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@openGitCodes::
	AppendAhkCmd(":*:@openGitCodes")
	SendInput, %webDevFolder%\GitHub\git-codes.bat{Enter}
Return
