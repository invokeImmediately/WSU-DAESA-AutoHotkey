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

UserFolderIsSet()
{
    global userAccountFolder
    varDeclared := userAccountFolder != thisIsUndeclared
    if (!varDeclared) {
        MsgBox, % (0x0 + 0x10), % "ERROR: Upstream dependency missing in github.ahk", % "The global variable specifying the user's account folder has not been declared and set upstream."
    }
    return varDeclared
}

GetGitHubFolder()
{
    global userAccountFolder
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

CopySrcFileToClipboard(ahkCmdName, srcFileToCopy, strToPrepend, errorMsg) {
    AppendAhkCmd(ahkCmdName)
    if (UserFolderIsSet()) {
        srcFile := FileOpen(srcFileToCopy, "r")
        if (srcFile != 0) {
            contents := srcFile.Read()
            srcFile.Close()
            clipboard := strToPrepend . contents
        }
        else {
            MsgBox, % (0x0 + 0x10), % errorMsg, % "Failed to open file: " . fileToOpen
        }
    }
}

IsGitShellActive()
{
    WinGet, thisProcess, ProcessName, A
    shellIsActive := thisProcess = "PowerShell.exe"
    return shellIsActive
}

InsertFilePath(ahkCmdName, filePath) {
    AppendAhkCmd(ahkCmdName)
    if (UserFolderIsSet()) {
        if (IsGitShellActive()) {
            SendInput % "cd """ . filePath . """{Enter}"
        }
        else {
            SendInput % filePath . "{Enter}"
        }
    }
}

PasteTextIntoGitShell(ahkCmdName, shellText) {
    AppendAhkCmd(ahkCmdName)
    if (UserFolderIsSet()) {
        proceedWithPaste := ActivateGitShell()
        if (proceedWithPaste) {
            clipboard = %shellText%
            Click right 44, 55
        }
        else {
            MsgBox, % (0x0 + 0x10), % "ERROR (" . ahkCmdName . "): GitHub process not found", % "Was unable to activate GitHub Powershell; aborting hotstring."
        }
    }
}

; ------------------------------------------------------------------------------------------------------------
; FILE SYSTEM NAVIGATION
; ------------------------------------------------------------------------------------------------------------

:*:@gotoGhDsp::
    InsertFilePath(":*:@gotoGhDsp", GetGitHubFolder() . "\distinguishedscholarships.wsu.edu") 
return

:*:@gotoGhFye::
    InsertFilePath(":*:@gotoGhFye", GetGitHubFolder() . "\firstyear.wsu.edu")
return

:*:@gotoGhFyf::
    InsertFilePath(":*:@gotoGhFyf", GetGitHubFolder() . "\learningcommunities.wsu.edu")
return

:*:@gotoGhSurca::
    InsertFilePath(":*:@gotoGhSurca", GetGitHubFolder() . "\surca.wsu.edu")
return

:*:@gotoGhUgr::
    InsertFilePath(":*:@gotoGhUgr", GetGitHubFolder() . "\undergraduateresearch.wsu.edu")
return

:*:@gotoGhXfer::
    InsertFilePath(":*:@gotoGhXfer", GetGitHubFolder() . "\transfercredit.wsu.edu")
return

:*:@gotoGhSumRes::
    InsertFilePath(":*:@gotoGhSumRes", GetGitHubFolder() . "\summerresearch.wsu.edu")
return

:*:@gotoGhCSS::
    InsertFilePath(":*:@gotoGhCSS", GetGitHubFolder() . "\WSU-UE---CSS")
return

:*:@gotoGhJS::
    InsertFilePath(":*:@gotoGhJS", GetGitHubFolder() . "\WSU-UE---JS")
return

:*:@gotoGhAhk::
    InsertFilePath(":*:@gotoGhAhk", GetGitHubFolder() . "\WSU-OUE-AutoHotkey")
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
        MsgBox, % (0x0 + 0x10), % "ERROR: Clipboard does not contain valid file name", % "Please select the file within NotePad++.exe that you would like to create a 'git add …' "
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
    PasteTextIntoGitShell(":*:@rebuildCssDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS""`r"
        . "lessc dsp-custom.less dsp-custom.css`r"
        . "lessc --clean-css dsp-custom.less dsp-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
        . "git add CSS\dsp-custom.css`r"
        . "git add CSS\dsp-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildCssFye::
    PasteTextIntoGitShell(":*:@rebuildCssFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\CSS""`r"
        . "lessc fye-custom.less fye-custom.css`r"
        . "lessc --clean-css fye-custom.less fye-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
        . "git add CSS\fye-custom.css`r"
        . "git add CSS\fye-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildCssSurca::
    PasteTextIntoGitShell(":*:@rebuildCssSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\CSS""`r"
        . "lessc surca-custom.less surca-custom.css`r"
        . "lessc --clean-css surca-custom.less surca-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
        . "git add CSS\surca-custom.css`r"
        . "git add CSS\surca-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildCssUgr::
    PasteTextIntoGitShell(":*:@rebuildCssUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS""`r"
        . "lessc undergraduate-research-custom.less undergraduate-research-custom.css`r"
        . "lessc --clean-css undergraduate-research-custom.less undergraduate-research-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
        . "git add CSS\undergraduate-research-custom.css`r"
        . "git add CSS\undergraduate-research-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildCssXfer::
    PasteTextIntoGitShell(":*:@rebuildCssXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\CSS""`r"
        . "lessc xfercredit-custom.less xfercredit-custom.css`r"
        . "lessc --clean-css xfercredit-custom.less xfercredit-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
        . "git add CSS\xfercredit-custom.css`r"
        . "git add CSS\xfercredit-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildCssFyf::
    PasteTextIntoGitShell(":*:@rebuildCssFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS""`r"
        . "lessc learningcommunities-custom.less learningcommunities-custom.css`r"
        . "lessc --clean-css learningcommunities-custom.less learningcommunities-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
        . "git add CSS\learningcommunities-custom.css`r"
        . "git add CSS\learningcommunities-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildCssSumRes::
    PasteTextIntoGitShell(":*:@rebuildCssSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\CSS""`r"
        . "lessc summerresearch-custom.less summerresearch-custom.css`r"
        . "lessc --clean-css summerresearch-custom.less summerresearch-custom.min.css`r"
        . "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
        . "git add CSS\summerresearch-custom.css`r"
        . "git add CSS\summerresearch-custom.min.css`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateCssSubmoduleDsp::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssDsp
return

:*:@updateCssSubmoduleFye::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssFye
return

:*:@updateCssSubmoduleSurca::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssSurca
return

:*:@updateCssSubmoduleUgr::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssUgr
return

:*:@updateCssSubmoduleXfer::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssXfer
return

:*:@updateCssSubmoduleFyf::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssFyf
return

:*:@updateCssSubmoduleSumRes::
    PasteTextIntoGitShell(":*:@updateCssSubmoduleSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---CSS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---CSS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master CSS submodule to incorporate recent chang"
        . "es in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildCssSumRes
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
    CopySrcFileToClipboard(":*:@copyMinCssDsp"
        , GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\CSS\dsp-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/firstyear.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't Copy Minified CSS for DSP Website")
return

:*:@copyMinCssFye::
    CopySrcFileToClipboard(":*:@copyMinCssFye"
        , GetGitHubFolder() . "\firstyear.wsu.edu\CSS\fye-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/firstyear.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't Copy Minified CSS for FYE Website")
return

:*:@copyMinCssUgr::
    CopySrcFileToClipboard(":*:@copyMinCssUgr"
        , GetGitHubFolder() . "\undergraduateresearch.wsu.edu\CSS\undergraduate-research-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/undergraduateresearch.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't Copy Minified CSS for UGR Website")
return

:*:@copyMinCssSurca::
    CopySrcFileToClipboard(":*:@copyMinCssSurca"
        , GetGitHubFolder() . "\surca.wsu.edu\CSS\surca-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/surca.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't Copy Minified CSS for SURCA Website")
return

:*:@copyMinCssXfer::
    CopySrcFileToClipboard(":*:@copyMinCssXfer"
        , GetGitHubFolder() . "\transfercredit.wsu.edu\CSS\xfercredit-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/transfercredit.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't Copy Minified CSS for Transfer Credit Website")
return

:*:@copyMinCssFyf::
    CopySrcFileToClipboard(":*:@copyMinCssFyf"
        , GetGitHubFolder() . "\learningcommunities.wsu.edu\CSS\learningcommunities-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/learningcommunities.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't Copy Minified CSS for First-Year Focus Website")
return

:*:@copyMinCssSumRes::
    CopySrcFileToClipboard(":*:@copyMinCssSumRes"
        , GetGitHubFolder() . "\summerresearch.wsu.edu\CSS\summerresearch-custom.min.css"
        , "/* Built with the LESS CSS preprocessor [http://lesscss.org/]. Please see [https://github.com/invo"
        . "keImmediately/summerresearch.wsu.edu] for a repository of source code. */`r`n"
        , "ERROR: Couldn't Copy Minified CSS for Summer Research Website")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@rebuildJsDsp::
    PasteTextIntoGitShell(":*:@rebuildJsDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-javascript-source.dsp.js --output wp-custom-js-source.min.dsp.js`r"
        . "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\""`r"
        . "git add JS\wp-custom-javascript-source.dsp.js`r"
        . "git add JS\wp-custom-js-source.min.dsp.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildJsFye::
    PasteTextIntoGitShell(":*:@rebuildJsFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildJsFyf::
    PasteTextIntoGitShell(":*:@rebuildJsFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js -mt`r"
        . "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code""`r"
        . "git push`r")
return

:*:@rebuildJsSurca::
    PasteTextIntoGitShell(":*:@rebuildJsSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js`r"
        . "cd """ . GetGitHubFolder() . "\surca.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildJsUgr::
    PasteTextIntoGitShell(":*:@rebuildJsUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js --output wp-custom-js-source.min.js`r"
        . "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code"" `r"
        . "git push`r")
return

:*:@rebuildJsXfer::
    PasteTextIntoGitShell(":*:@rebuildJsXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js -m --output wp-custom-js-source.min.js`r"
        . "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

:*:@rebuildJsSumRes::
    PasteTextIntoGitShell(":*:@rebuildJsSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\JS""`r"
        . "node build-production-file.js`r"
        . "uglifyjs wp-custom-js-source.js -m --output wp-custom-js-source.min.js`r"
        . "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\""`r"
        . "git add JS\wp-custom-js-source.js`r"
        . "git add JS\wp-custom-js-source.min.js`r"
        . "git commit -m ""Updating build"" -m ""Rebuilt production files to incorporate recent changes to so"
        . "urce code."" `r"
        . "git push`r")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@updateJsSubmoduleDsp::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleDsp"
        , "cd """ . GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent change"
        . "s in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsDsp
return

:*:@updateJsSubmoduleFye::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleFye"
        , "cd """ . GetGitHubFolder() . "\firstyear.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent change"
        . "s in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsFye
return

:*:@updateJsSubmoduleFyf::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleFyf"
        , "cd """ . GetGitHubFolder() . "\learningcommunities.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent change"
        . "s in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsFyf
return

:*:@updateJsSubmoduleSurca::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleSurca"
        , "cd """ . GetGitHubFolder() . "\surca.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsSurca
return

:*:@updateJsSubmoduleUgr::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleUgr"
        , "cd """ . GetGitHubFolder() . "\undergraduateresearch.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsUgr
return

:*:@updateJsSubmoduleXfer::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleXfer"
        , "cd """ . GetGitHubFolder() . "\transfercredit.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsXfer
return

:*:@updateJsSubmoduleSumRes::
    PasteTextIntoGitShell(":*:@updateJsSubmoduleSumRes"
        , "cd """ . GetGitHubFolder() . "\summerresearch.wsu.edu\WSU-UE---JS""`r"
        . "git fetch`r"
        . "git merge origin/master`r"
        . "cd ..`r"
        . "git add WSU-UE---JS`r"
        . "git commit -m ""Updating submodule"" -m ""Updated master JS submodule to incorporate recent changes in project source code""`r"
        . "git push`r")
    Gosub :*:@rebuildJsSumRes
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
    CopySrcFileToClipboard(":*:@copyMinJsDsp"
        , GetGitHubFolder() . "\distinguishedscholarships.wsu.edu\JS\wp-custom-js-source.min.dsp.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/distinguishedscholarship.wsu.edu] for "
        . "a repository of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   cycle2, (c) 2012-2014 M. Alsup. | https://github.com/malsup/cycle2 | MIT license -- http://ma"
        . "lsup.github.io/mit-license.txt && GPL license -- http://malsup.github.io/gpl-license-v2.txt`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   imagesLoaded, (c) David DeSandro 2016 | http://imagesloaded.desandro.com/ | MIT license -- ht"
        . "tp://desandro.mit-license.org/`r`n"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   jQuery Media Plugin, (c) 2007-2010 M. Alsup. | http://malsup.com/jquery/media/ | MIT license "
        . "-- https://opensource.org/licenses/mit-license.php  && GPL license -- http://www.gnu.org/licenses/"
        . "gpl.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for DSP Website")
return

:*:@copyMinJsFye::
    CopySrcFileToClipboard(":*:@copyMinJsFye"
        , GetGitHubFolder() . "\firstyear.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/firstyear.wsu.edu] for a repository of"
        . "source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for FYE Website")
return

:*:@copyMinJsFyf::
    CopySrcFileToClipboard(":*:@copyMinJsFyf"
        , GetGitHubFolder() . "\learningcommunities.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/learningcommunities.wsu.edu] for a rep"
        . "ository of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for FYF Website")
return

:*:@copyMinJsUgr::
    CopySrcFileToClipboard(":*:@copyMinJsUgr"
        , GetGitHubFolder() . "\undergraduateresearch.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/undergraduateresearch.wsu.edu] for a r"
        . "epository of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for UGR Website")
return

:*:@copyMinJsXfer::
    CopySrcFileToClipboard(":*:@copyMinJsXfer"
        , GetGitHubFolder() . "\transfercredit.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/transfercredit.wsu.edu] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "Text.js | GNU GPLv2 -- http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for WSU Transfer Credit Website")
return

:*:@copyMinJsSumRes::
    CopySrcFileToClipboard(":*:@copyMinJsSumRes"
        , GetGitHubFolder() . "\summerresearch.wsu.edu\JS\wp-custom-js-source.min.js"
        , "// Built with Node.js [https://nodejs.org/] using the UglifyJS library [https://github.com/mishoo/"
        . "UglifyJS]. Please see [https://github.com/invokeImmediately/summerresearch.wsu.edu] for a reposito"
        . "ry of source code.`r`n"
        . "// Third-party, open-source JavaScript plugins used by this website:`r`n"
        . "//   FitText.js, (c) 2011, Dave Rupert http://daverupert.com | https://github.com/davatron5000/Fit"
        . "//   Masonry JS, (c) David DeSandro 2016 | http://masonry.desandro.com/ | MIT license -- http://de"
        . "sandro.mit-license.org/`r`n"
        . "//   qTip2, (c) Craig Thompson 2013 | http://qtip2.com/ | CC Attribution 3.0 license -- http://cre"
        . "ativecommons.org/licenses/by/3.0/`r`n"
        , "ERROR: Couldn't Copy Minified JS for WSU Summer Research Website")
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
:*:@checkGitStatus::
    PasteTextIntoGitShell(":*:@checkGitStatus"
        , "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-OUE-AutoHotkey\""`r`n"
        . "write-host ""``n----------------------------------------------WSU-OUE-AutoHotkey------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---CSS\""`r`n"
        . "write-host ""``n------------------------------------------------WSU-OUE---CSS---------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\WSU-UE---JS\""`r`n"
        . "write-host ""``n-------------------------------------------------WSU-OUE---JS---------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\distinguishedscholarships.wsu.edu\""`r`n"
        . "write-host ""``n--------------------------------------distinguishedscholarships.wsu.edu-----------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\firstyear.wsu.edu\""`r`n"
        . "write-host ""``n----------------------------------------------firstyear.wsu.edu-------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\surca.wsu.edu\""`r`n"
        . "write-host ""``n------------------------------------------------surca.wsu.edu---------------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\undergraduateresearch.wsu.edu\""`r`n"
        . "write-host ""``n----------------------------------------undergraduateresearch.wsu.edu-------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\transfercredit.wsu.edu\""`r`n"
        . "write-host ""``n--------------------------------------------transfercredit.wsu.edu----------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n"
        . "cd ""C:\Users\CamilleandDaniel\Documents\GitHub\summerresearch.wsu.edu\""`r`n"
        . "write-host ""``n--------------------------------------------summerresearch.wsu.edu----------------"
        . "----------------------------"" -foreground ""green""`r`n"
        . "git status`r`n")
return
