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

; ------------------------------------------------------------------------------------------------------------
; SETTINGS accessed via functions for this imported file
; ------------------------------------------------------------------------------------------------------------

GetGitHubFolder()
{
    return userAccountFolder . "\Documents\GitHub"
}

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
    return shellActivated
}

IsGitShellActive()
{
    WinGet, thisProcess, ProcessName, A
    shellIsActive := thisProcess = "PowerShell.exe"
    return shellIsActive
}

; ------------------------------------------------------------------------------------------------------------
; FILE SYSTEM NAVIGATION
; ------------------------------------------------------------------------------------------------------------

:*:@gotoGhDsp::
    AppendAhkCmd(":*:@gotoGhDsp")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\distinguishedscholarships.wsu.edu{Enter}"
    }
return

:*:@gotoGhFye::
    AppendAhkCmd(":*:@gotoGhFye")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\firstyear.wsu.edu{Enter}"
    }
return

:*:@gotoGhSurca::
    AppendAhkCmd(":*:@gotoGhSurca")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\surca.wsu.edu""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\surca.wsu.edu{Enter}"
    }
return

:*:@gotoGhUgr::
    AppendAhkCmd(":*:@gotoGhUgr")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\undergraduateresearch.wsu.edu{Enter}"
    }
return

:*:@gotoGhXfer::
    AppendAhkCmd(":*:@gotoGhXfer")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\transfercredit.wsu.edu{Enter}"
    }
return

:*:@gotoGhSumRes::
    AppendAhkCmd(":*:@gotoGhSumRes")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\summerresearch.wsu.edu{Enter}"
    }
return

:*:@gotoGhCSS::
    AppendAhkCmd(":*:@gotoGhCSS")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\WSU-UE---CSS""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\WSU-UE---CSS{Enter}"
    }
return

:*:@gotoGhJS::
    AppendAhkCmd(":*:@gotoGhJS")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\WSU-UE---JS""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\WSU-UE---JS{Enter}"
    }
return

:*:@gotoGhAhk::
    AppendAhkCmd(":*:@gotoGhAhk")
    if (isGitShellActive()) {
        SendInput % "cd """ . GetGitHubFolder() . "\WSU-OUE-AutoHotkey""{Enter}"
    }
    else {
        SendInput % GetGitHubFolder() . "\WSU-OUE-AutoHotkey{Enter}"
    }
return

; ------------------------------------------------------------------------------------------------------------
; UTILITY HOTSTRINGS for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

:*:@doGitCommit::
    AppendAhkCmd(":*:@doGitCommit")
    SendInput git commit -m "" -m ""{Left 7}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@pasteGitCommitMsg::
    AppendAhkCmd(":*:@pasteGitCommitMsg")
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "PowerShell.exe") {
        commitText := RegExReplace(clipboard, Chr(0x2026) "\R" Chr(0x2026), "")
        clipboard = %commitText%
        Click right 44, 55
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gitAddThis::
    AppendAhkCmd(":*:@gitAddThis")
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
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@swapSlashes::
    ;DESCRIPTION: For reversing forward slashes within a copied file name reported by 'git status' in
    ; PowerShell and then pasting the result into PowerShell.
    AppendAhkCmd(":*:@swapSlashes")
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "PowerShell.exe") {
        newText := RegExReplace(clipboard, "/", "\")
        clipboard := newText
        Click right 44, 55 ;TODO: Check to see if the mouse cursor is already within the PowerShell bounding rectangle 
    }    
return

; ------------------------------------------------------------------------------------------------------------
; COMMAND LINE INPUT GENERATION as triggered by HotStrings for working with GitHub Desktop
; ------------------------------------------------------------------------------------------------------------

:*:@rebuildCssDsp::
    AppendAhkCmd(":*:@rebuildCssDsp")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS""`r"
            . "lessc distinguished-scholarships-program.less distinguished-scholarships-program.css`r"
            . "lessc --clean-css distinguished-scholarships-program.less distinguished-scholarships-program.min.css`r"
            . "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
            . "git add CSS\distinguished-scholarships-program.css`r"
            . "git add CSS\distinguished-scholarships-program.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildCssFye::
    AppendAhkCmd(":*:@rebuildCssFye")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\CSS""`r"
            . "lessc fye-custom.less fye-custom.css`r"
            . "lessc --clean-css fye-custom.less fye-custom.min.css`r"
            . "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
            . "git add CSS\fye-custom.css`r"
            . "git add CSS\fye-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildCssSurca::
    AppendAhkCmd(":*:@rebuildCssSurca")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\surca.wsu.edu\CSS""`r"
            . "lessc surca-custom.less surca-custom.css`r"
            . "lessc --clean-css surca-custom.less surca-custom.min.css`r"
            . "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
            . "git add CSS\surca-custom.css`r"
            . "git add CSS\surca-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code"" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildCssUgr::
    AppendAhkCmd(":*:@rebuildCssUgr")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS""`r"
            . "lessc undergraduate-research-custom.less undergraduate-research-custom.css`r"
            . "lessc --clean-css undergraduate-research-custom.less undergraduate-research-custom.min.css`r"
            . "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
            . "git add CSS\undergraduate-research-custom.css`r"
            . "git add CSS\undergraduate-research-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code"" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildCssXfer::
    AppendAhkCmd(":*:@rebuildCssXfer")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\CSS""`r"
            . "lessc transfer-central-custom.less transfer-central-custom.css`r"
            . "lessc --clean-css transfer-central-custom.less transfer-central-custom.min.css`r"
            . "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
            . "git add CSS\transfer-central-custom.css`r"
            . "git add CSS\transfer-central-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code."" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildCssFyf::
    AppendAhkCmd(":*:@rebuildCssFyf")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS""`r"
            . "lessc learningcommunities-custom.less learningcommunities-custom.css`r"
            . "lessc --clean-css learningcommunities-custom.less learningcommunities-custom.min.css`r"
            . "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
            . "git add CSS\learningcommunities-custom.css`r"
            . "git add CSS\learningcommunities-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code."" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildCssSumRes::
    AppendAhkCmd(":*:@rebuildCssSumRes")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\CSS""`r"
            . "lessc summerresearch-custom.less summerresearch-custom.css`r"
            . "lessc --clean-css summerresearch-custom.less summerresearch-custom.min.css`r"
            . "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
            . "git add CSS\summerresearch-custom.css`r"
            . "git add CSS\summerresearch-custom.min.css`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code."" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleDsp::
    AppendAhkCmd(":*:@updateCssSubmoduleDsp")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---CSS""`r"
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
return

:*:@updateCssSubmoduleFye::
    AppendAhkCmd(":*:@updateCssSubmoduleFye")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---CSS""`r"
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
return

:*:@updateCssSubmoduleSurca::
    AppendAhkCmd(":*:@updateCssSubmoduleSurca")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---CSS""`r"
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
return

:*:@updateCssSubmoduleUgr::
    AppendAhkCmd(":*:@updateCssSubmoduleUgr")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---CSS""`r"
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
return

:*:@updateCssSubmoduleXfer::
    AppendAhkCmd(":*:@updateCssSubmoduleXfer")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---CSS""`r"
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
return

:*:@updateCssSubmoduleFyf::
    AppendAhkCmd(":*:@updateCssSubmoduleFyf")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---CSS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---CSS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildCssFyf
    }
return

:*:@updateCssSubmoduleSumRes::
    AppendAhkCmd(":*:@updateCssSubmoduleSumRes")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---CSS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---CSS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildCssSumRes
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleAll::
    AppendAhkCmd(":*:@updateCssSubmoduleAll")
    Gosub :*:@updateCssSubmoduleDsp
    Gosub :*:@updateCssSubmoduleFye
    Gosub :*:@updateCssSubmoduleSurca
    Gosub :*:@updateCssSubmoduleUgr
    Gosub :*:@updateCssSubmoduleXfer
    Gosub :*:@updateCssSubmoduleFyf
    Gosub :*:@updateCssSubmoduleSumRes
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinCssDsp::
    AppendAhkCmd(":*:@copyMinCssDsp")
    fileToOpen := GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\distinguished-scholarships-program.min.css"
    minCssFile := FileOpen(fileToOpen, "r")
    if (minCssFile != 0) {
        contents := minCssFile.Read()
        minCssFile.Close()
        clipboard := "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invokeImmediately/firstyear.wsu.edu] for a repository of source code. */`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified CSS for DSP Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinCssFye::
    AppendAhkCmd(":*:@copyMinCssFye")
    fileToOpen := GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.min.css"
    minCssFile := FileOpen(fileToOpen, "r")
    if (minCssFile != 0) {
        contents := minCssFile.Read()
        minCssFile.Close()
        clipboard := "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invokeImmediately/firstyear.wsu.edu] for a repository of source code. */`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified CSS for FYE Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinCssUgr::
    AppendAhkCmd(":*:@copyMinCssUgr")
    fileToOpen := GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.min.css"
    minCssFile := FileOpen(fileToOpen, "r")
    if (minCssFile != 0) {
        contents := minCssFile.Read()
        minCssFile.Close()
        clipboard := "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invokeImmediately/undergraduateresearch.wsu.edu] for a repository of source code. */`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified CSS for UGR Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinCssSurca::
    AppendAhkCmd(":*:@copyMinCssSurca")
    fileToOpen := GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.min.css"
    minCssFile := FileOpen(fileToOpen, "r")
    if (minCssFile != 0) {
        contents := minCssFile.Read()
        minCssFile.Close()
        clipboard := "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invokeImmediately/surca.wsu.edu] for a repository of source code. */`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified CSS for SURCA Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinCssXfer::
    AppendAhkCmd(":*:@copyMinCssXfer")
    fileToOpen := GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\transfer-central-custom.min.css"
    minCssFile := FileOpen(fileToOpen, "r")
    if (minCssFile != 0) {
        contents := minCssFile.Read()
        minCssFile.Close()
        clipboard := "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invokeImmediately/transfercredit.wsu.edu] for a repository of source code. */`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified CSS for Transfer Credit Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinCssFyf::
    AppendAhkCmd(":*:@copyMinCssFyf")
    fileToOpen := GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.min.css"
    minCssFile := FileOpen(fileToOpen, "r")
    if (minCssFile != 0) {
        contents := minCssFile.Read()
        minCssFile.Close()
        clipboard := "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invokeImmediately/learningcommunities.wsu.edu] for a repository of source code. */`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified CSS for First-Year Focus Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinCssSumRes::
    AppendAhkCmd(":*:@copyMinCssSumRes")
    fileToOpen := GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.min.css"
    minCssFile := FileOpen(fileToOpen, "r")
    if (minCssFile != 0) {
        contents := minCssFile.Read()
        minCssFile.Close()
        clipboard := "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invokeImmediately/summerresearch.wsu.edu] for a repository of source code. */`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified CSS for Summer Research Website", % "Failed to open file: " . fileToOpen
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@rebuildJsDsp::
    AppendAhkCmd(":*:@rebuildJsDsp")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS""`r"
            . "node build-production-file.js`r"
            . "uglifyjs wp-custom-javascript-source.dsp.js --output wp-custom-js-source.min.dsp.js`r"
            . "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
            . "git add JS\wp-custom-javascript-source.dsp.js`r"
            . "git add JS\wp-custom-js-source.min.dsp.js`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildJsFye::
    AppendAhkCmd(":*:@rebuildJsFye")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\JS""`r"
            . "node build-production-file.js`r"
            . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js`r"
            . "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
            . "JS\wp-custom-js-source.js`r"
            . "git add JS\wp-custom-js-source.min.js`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildJsSurca::
    AppendAhkCmd(":*:@rebuildJsSurca")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\surca.wsu.edu\JS""`r"
            . "node build-production-file.js`r"
            . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js`r"
            . "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
            . "git add JS\wp-custom-js-source.js`r"
            . "git add JS\wp-custom-js-source.min.js`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code"" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildJsUgr::
    AppendAhkCmd(":*:@rebuildJsUgr")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS""`r"
            . "node build-production-file.js`r"
            . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js`r"
            . "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
            . "git add JS\wp-custom-js-source.js`r"
            . "git add JS\wp-custom-js-source.min.js`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code"" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildJsXfer::
    AppendAhkCmd(":*:@rebuildJsXfer")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\JS""`r"
            . "node build-production-file.js`r"
            . "uglifyjs wp-custom-js-source.js -m --output wp-custom-js-source.min.js`r"
            . "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
            . "git add JS\wp-custom-js-source.js`r"
            . "git add JS\wp-custom-js-source.min.js`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code."" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

:*:@rebuildJsSumRes::
    AppendAhkCmd(":*:@rebuildJsXfer")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\JS""`r"
            . "node build-production-file.js`r"
            . "uglifyjs wp-custom-js-source.js -m --output wp-custom-js-source.min.js`r"
            . "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
            . "git add JS\wp-custom-js-source.js`r"
            . "git add JS\wp-custom-js-source.min.js`r"
            . "git commit -m ""Updating build"" -m ""Rebuilt production file to incorporate recent changes to source code."" `r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateJsSubmoduleDsp::
    AppendAhkCmd(":*:@updateJsSubmoduleDsp")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---JS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---JS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildJsDsp
    }
return

:*:@updateJsSubmoduleFye::
    AppendAhkCmd(":*:@updateJsSubmoduleFye")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---JS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---JS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildJsFye
    }
return

:*:@updateJsSubmoduleSurca::
    AppendAhkCmd(":*:@updateJsSubmoduleSurca")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---JS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---JS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildJsSurca
    }
return

:*:@updateJsSubmoduleUgr::
    AppendAhkCmd(":*:@updateJsSubmoduleUgr")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---JS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---JS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildJsUgr
    }
return

:*:@updateJsSubmoduleXfer::
    AppendAhkCmd(":*:@updateJsSubmoduleXfer")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---JS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---JS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildJsXfer
    }
return

:*:@updateJsSubmoduleSumRes::
    AppendAhkCmd(":*:@updateJsSubmoduleSumRes")
    proceedWithBuild := ActivateGitShell()
    if (proceedWithBuild) {
        shellText := "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---JS""`r"
            . "git fetch`r"
            . "git merge origin/master`r"
            . "cd ..`r"
            . "git add WSU-UE---JS`r"
            . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
            . "git push`r"
        clipboard = %shellText%
        Click right 44, 55
        Gosub :*:@rebuildJsSumRes
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateJsSubmoduleAll::
    AppendAhkCmd(":*:@updateJsSubmoduleAll")
    Gosub :*:@updateJsSubmoduleDsp
    Gosub :*:@updateJsSubmoduleFye
    Gosub :*:@updateJsSubmoduleSurca
    Gosub :*:@updateJsSubmoduleUgr
    Gosub :*:@updateJsSubmoduleXfer
    Gosub :*:@updateJsSubmoduleSumRes
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@copyMinJsDsp::
    AppendAhkCmd(":*:@copyMinJsDsp")
    fileToOpen := GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS\wp-custom-js-source.min.dsp.js"
    minJsFile := FileOpen(fileToOpen, "r")
    if (minJsFile != 0) {
        contents := minJsFile.Read()
        minJsFile.Close()
        Clipboard := "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/UglifyJS]. Please see [https://github.com/invokeImmediately/distinguishedscholarship.wsu.edu] for a repository of source code.`r`n"
            . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
            . "//   cycle2, (c) 2012-2014 M. Alsup. | https://github.com/malsup/cycle2 | MIT license -- http://malsup.github.io/mit-license.txt && GPL license -- http://malsup.github.io/gpl-license-v2.txt`r`n"
            . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/FitText.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
            . "//   imagesLoaded, (c) David DeSandro 2016 | http://imagesloaded.desandro.com/ | MIT license -- http://desandro.mit-license.org/`r`n"
            . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://desandro.mit-license.org/`r`n"
            . "//   jQuery Media Plugin, (c) 2007-2010 M. Alsup. | http://malsup.com/jquery/media/ | MIT license -- https://opensource.org/licenses/mit-license.php  && GPL license -- http://www.gnu.org/licenses/gpl.html`r`n"
            . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://creativecommons.org/licenses/by/3.0/`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified JS for DSP Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinJsFye::
    AppendAhkCmd(":*:@copyMinJsFye")
    fileToOpen := GetGitHubFolder() . "\firstyear.wsu.edu\JS\wp-custom-js-source.min.js"
    minJsFile := FileOpen(fileToOpen, "r")
    if (minJsFile != 0) {
        contents := minJsFile.Read()
        minJsFile.Close()
        Clipboard := "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/UglifyJS]. Please see [https://github.com/invokeImmediately/distinguishedscholarship.wsu.edu] for a repository of source code.`r`n"
            . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
            . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://creativecommons.org/licenses/by/3.0/`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified JS for DSP Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinJsUgr::
    AppendAhkCmd(":*:@copyMinJsUgr")
    fileToOpen := GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS\wp-custom-js-source.min.js"
    minJsFile := FileOpen(fileToOpen, "r")
    if (minJsFile != 0) {
        contents := minJsFile.Read()
        minJsFile.Close()
        Clipboard := "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/UglifyJS]. Please see [https://github.com/invokeImmediately/undergraduateresearch.wsu.edu] for a repository of source code.`r`n"
            . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
            . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/FitText.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
            . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://creativecommons.org/licenses/by/3.0/`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified JS for UGR Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinJsXfer::
    AppendAhkCmd(":*:@copyMinJsXfer")
    fileToOpen := GetGitHubFolder() . "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.js"
    minJsFile := FileOpen(fileToOpen, "r")
    if (minJsFile != 0) {
        contents := minJsFile.Read()
        minJsFile.Close()
        Clipboard := "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/UglifyJS]. Please see [https://github.com/invokeImmediately/transfercredit.wsu.edu] for a repository of source code.`r`n"
            . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
            . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://creativecommons.org/licenses/by/3.0/`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified JS for WSU Transfer Credit Website", % "Failed to open file: " . fileToOpen
    }
return

:*:@copyMinJsSumRes::
    AppendAhkCmd(":*:@copyMinJsSumRes")
    fileToOpen := GetGitHubFolder() . "\summerresearch.wsu.edu\JS\wp-custom-js-source.min.js"
    minJsFile := FileOpen(fileToOpen, "r")
    if (minJsFile != 0) {
        contents := minJsFile.Read()
        minJsFile.Close()
        Clipboard := "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/UglifyJS]. Please see [https://github.com/invokeImmediately/transfercredit.wsu.edu] for a repository of source code.`r`n"
            . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
            . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://desandro.mit-license.org/`r`n"
            . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://creativecommons.org/licenses/by/3.0/`r`n" . contents
    }
    else {
        MsgBox , 0x0, % "Error: Couldn't Copy Minified JS for WSU Summer Research Website", % "Failed to open file: " . fileToOpen
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@checkGitStatus::
    AppendAhkCmd(":*:@checkGitStatus")
    proceedWithCheck := ActivateGitShell()
    if (proceedWithCheck) {
        Clipboard := "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---CSS\""`r`n"
            . "git status`r`n"
            . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---JS\""`r`n"
            . "git status`r`n"
            . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\distinguishedscholarships.wsu.edu\""`r`n"
            . "git status`r`n"
            . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\firstyear.wsu.edu\""`r`n"
            . "git status`r`n"
            . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\surca.wsu.edu\""`r`n"
            . "git status`r`n"
            . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\undergraduateresearch.wsu.edu\""`r`n"
            . "git status`r`n"
            . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\transfercredit.wsu.edu\""`r`n"
            . "git status`r`n"
        Click right 44, 55
    }
return
