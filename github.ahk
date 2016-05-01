; ============================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ============================================================================================================
; IMPORT DEPENDENCIES
;   Global Variable Name    Purpose
;   --------------------    ------------------------------------------------------------------------------
;   userAccountFolder       Contains the path to the Windows user folder for the script runner
; ============================================================================================================
; IMPORT ASSUMPTIONS
;   Environmental Property           State
;   ----------------------------     ---------------------------------------------------------------------
;   Location of GitHub               …userAccountFolder (see above dependency)…\Documents\GitHub
;   Repositories locally present     All those from https://github.com/invokeImmediately 
; ============================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

global gitHubFolder := userAccountFolder . "\Documents\GitHub"

; ------------------------------------------------------------------------------------------------------------
; FUNCTIONS for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

ActivateGitShell()
{
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

IsGitShellActive()
{
    WinGet, thisProcess, ProcessName, A
    shellIsActive := thisProcess = "PowerShell.exe"
    Return shellIsActive
}

; ------------------------------------------------------------------------------------------------------------
; FILE SYSTEM NAVIGATION
; ------------------------------------------------------------------------------------------------------------

:*:@gotoGhDsp::
    if (isGitShellActive()) {
        SendInput % "cd """ . gitHubFolder . "\distinguishedscholarships.wsu.edu""{Enter}"
    }
Return

:*:@gotoGhFye::
    if (isGitShellActive()) {
        SendInput % "cd """ . gitHubFolder . "\firstyear.wsu.edu""{Enter}"
    }
Return

:*:@gotoGhSurca::
    if (isGitShellActive()) {
        SendInput % "cd """ . gitHubFolder . "\surca.wsu.edu""{Enter}"
    }
Return

:*:@gotoGhUgr::
    if (isGitShellActive()) {
        SendInput % "cd """ . gitHubFolder . "\undergraduateresearch.wsu.edu""{Enter}"
    }
Return

:*:@gotoGhXfer::
    if (isGitShellActive()) {
        SendInput % "cd """ . gitHubFolder . "\transfercredit.wsu.edu""{Enter}"
    }
Return

:*:@gotoGhCSS::
    if (isGitShellActive()) {
        SendInput % "cd """ . gitHubFolder . "\WSU-UE---CSS""{Enter}"
    }
Return

:*:@gotoGhJS::
    if (isGitShellActive()) {
        SendInput % "cd """ . gitHubFolder . "\WSU-UE---JS""{Enter}"
    }
Return

; ------------------------------------------------------------------------------------------------------------
; UTILITY HOTSTRINGS for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

:*:@doGitCommit::
    SendInput git commit -m "" -m ""{Left 7}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@pasteGitCommitMsg::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "PowerShell.exe") {
        commitText := RegExReplace(clipboard, Chr(0x2026) "\R" Chr(0x2026), "")
        clipboard = %commitText%
        Click right 44, 55
    }
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gitAddThis::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "notepad++.exe") {
        SendInput !e
        Sleep 20
        SendInput {Down 8}
        Sleep 20
        SendInput {Right}
        Sleep 20
        SendInput {Down}
        Sleep 20
        SendInput {Enter}
        Sleep 20
        commitText := RegExReplace(clipboard, "^(.*)", "git add $1")
        clipboard = %commitText%
    }
    else {
        MsgBox % "Please select the file within NotePad++.exe that you would like to create a 'git add …' "
         . "string for."
    }
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@swapSlashes::
    ;DESCRIPTION: For reversing forward slashes within a copied file name reported by 'git status' in
    ; PowerShell and then pasting the result into PowerShell.
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "PowerShell.exe") {
        newText := RegExReplace(clipboard, "/", "\")
        clipboard := newText
        Click right 44, 55 ;TODO: Check to see if the mouse cursor is already within the PowerShell bounding rectangle 
    }    
Return

; ------------------------------------------------------------------------------------------------------------
; COMMAND LINE INPUT GENERATION as triggered by HotStrings for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

:*:@rebuildCssDsp::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\distinguishedscholarships.wsu.edu\CSS""`r"
            . "lessc distinguished-scholarships-program.less distinguished-scholarships-program.css`r"
            . "lessc --clean-css distinguished-scholarships-program.less distinguished-scholarships-program.min.css`r"
            . "cd """ . gitHubFolder . "\distinguishedscholarships.wsu.edu\""`r"
            . "git add CSS\distinguished-scholarships-program.css`r"
            . "git add CSS\distinguished-scholarships-program.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
Return

:*:@rebuildCssFye::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\firstyear.wsu.edu\CSS""`r"
            . "lessc fye-custom.less fye-custom.css`r"
            . "lessc --clean-css fye-custom.less fye-custom.min.css`r"
            . "cd """ . gitHubFolder . "\firstyear.wsu.edu\""`r"
            . "git add CSS\fye-custom.css`r"
            . "git add CSS\fye-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
Return

:*:@rebuildCssSurca::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\surca.wsu.edu\CSS""`r"
            . "lessc surca-custom.less surca-custom.css`r"
            . "lessc --clean-css surca-custom.less surca-custom.min.css`r"
            . "cd """ . gitHubFolder . "\surca.wsu.edu\""`r"
            . "git add CSS\surca-custom.css`r"
            . "git add CSS\surca-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code"" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
Return

:*:@rebuildCssUgr::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\undergraduateresearch.wsu.edu\CSS""`r"
            . "lessc undergraduate-research-custom.less undergraduate-research-custom.css`r"
            . "lessc --clean-css undergraduate-research-custom.less undergraduate-research-custom.min.css`r"
            . "cd """ . gitHubFolder . "\undergraduateresearch.wsu.edu\""`r"
            . "git add CSS\undergraduate-research-custom.css`r"
            . "git add CSS\undergraduate-research-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code"" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
Return

:*:@rebuildCssXfer::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\transfercredit.wsu.edu\CSS""`r"
            . "lessc transfer-central-custom.less transfer-central-custom.css`r"
            . "lessc --clean-css transfer-central-custom.less transfer-central-custom.min.css`r"
            . "cd """ . gitHubFolder . "\transfercredit.wsu.edu\""`r"
            . "git add CSS\transfer-central-custom.css`r"
            . "git add CSS\transfer-central-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code."" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleDsp::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\distinguishedscholarships.wsu.edu\WSU-UE---CSS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---CSS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildCssDsp
    }
Return

:*:@updateCssSubmoduleFye::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\firstyear.wsu.edu\WSU-UE---CSS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---CSS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildCssFye
    }
Return

:*:@updateCssSubmoduleSurca::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\surca.wsu.edu\WSU-UE---CSS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---CSS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildCssSurca
    }
Return

:*:@updateCssSubmoduleUgr::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\undergraduateresearch.wsu.edu\WSU-UE---CSS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---CSS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildCssUgr
    }
Return

:*:@updateCssSubmoduleXfer::
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . gitHubFolder . "\transfercredit.wsu.edu\WSU-UE---CSS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---CSS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildCssXfer
    }
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleAll::
    Gosub :*:@updateCssSubmoduleDsp
    Gosub :*:@updateCssSubmoduleFye
    Gosub :*:@updateCssSubmoduleSurca
    Gosub :*:@updateCssSubmoduleUgr
    Gosub :*:@updateCssSubmoduleXfer
Return
