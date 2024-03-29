﻿; ==================================================================================================
; ▄▀▀▀ ▄▀▀▀ ▄▀▀▀ █▀▀▄ █    █▀▀▄ █▀▀▄ ▄▀▀▀ ▄▀▀▄ █▀▀▄ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; █    ▀▀▀█ ▀▀▀█ █▀▀▄ █  ▄ █  █ █▄▄▀ ▀▀▀█ █  █ █▄▄▀ ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
;  ▀▀▀ ▀▀▀  ▀▀▀  ▀▀▀  ▀▀▀  ▀▀▀  █    ▀▀▀   ▀▀  █    ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Object-oriented implementation of GUI for automating CSS build operations in PowerShell to
;   support the production of custom CSS files to be utilized on WSUWP websites.
;
; This script depends on other functions from the AutoHotkey scripting project that supports
;   development and coordination of WSU DAESA's websites while working on a Windows platform.
;
; @version 1.1.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/GitHub/CssBldPsOps.ahk
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

class CssBldPsOps extends GhGui {
	__New( cfgSettings
			, guiTheme
			, typer
			, delayer
			, guiType := "CssBldPsOps"
			, guiName := "Default"
			, guiTitle := "PowerShell Extender for Enhancing CSS Development"
			, updateSmBtnHdlr := "CssBldPsOpsUpdateSmBtnHdlr"
			, rbldCssBtnHdlr := "CssBldPsOpsRbldCssBtnHdlr"
			, cmtCssBtnHdlr := "CssBldPsOpsCmtCssBtnHdlr"
			, bakCssBtnHdlr := "CssBldPsOpsBakCssBtnHdlr"
			, postCssBtnHdlr := "CssBldPsOpsPostCssBtnHdlr"
			, copyCssBtnHdlr := "CssBldPsOpsCopyCssBtnHdlr"
			, postPrevCssBtnHdlr := "CssBldPsOpsPostPrevCssBtnHdlr"
			, copyPrevCssBtnHdlr := "CssBldPsOpsCopyPrevCssBtnHdlr"
			, cancelBtnHdlr := "CssBldPsOpsCancelHdlr" ) {
		base.__New( cfgSettings, guiTheme, typer, delayer, guiType, guiName, guiTitle, cancelBtnHdlr )
		this.updateSmBtnHdlr := new GuiControlHandler( updateSmBtnHdlr, this )
		this.rbldCssBtnHdlr := new GuiControlHandler( rbldCssBtnHdlr, this )
		this.cmtCssBtnHdlr := new GuiControlHandler( cmtCssBtnHdlr, this )
		this.bakCssBtnHdlr := new GuiControlHandler( bakCssBtnHdlr, this )
		this.postCssBtnHdlr := new GuiControlHandler( postCssBtnHdlr, this )
		this.copyCssBtnHdlr := new GuiControlHandler( copyCssBtnHdlr, this )
		this.postPrevCssBtnHdlr := new GuiControlHandler( postPrevCssBtnHdlr, this )
		this.copyPrevCssBtnHdlr := new GuiControlHandler( copyPrevCssBtnHdlr, this )
	}

	ChangeDefaultButton( dfltMode ) {
		global
		local guiName := this.name
		local guiType := this.type

		if ( dfltMode == "update" || dfltMode == "u" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%UpdateSM
		} else if ( dfltMode == "rebuild" || dfltMode == "r" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%RbldCss
		} else if ( dfltMode == "commit" || dfltMode == "m" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%CmtCss
		} else if ( dfltMode == "backup" || dfltMode == "b" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%BakCss
		} else if ( dfltMode == "post" || dfltMode == "p" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%PostCss
		} else if ( dfltMode == "copyCss" || dfltMode == "c" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%CopyCss
		} else if ( dfltMode == "postBackup" || dfltMode == "pb" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%PostPrevCss
		} else if ( dfltMode == "copyBackup" || dfltMode == "cb" ) {
			GuiControl, +Default, ahkGui%guiType%%guiName%CopyPrevCss
		}
	}

	HandleBakCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			LV_GetText( website, selRow, 3)
			LV_GetText( backup, selRow, 7)
			copiedCss := CopyCssFromWebsite(website)
			if ( VerifyCopiedCode( A_ThisFunc, copiedCss ) ) {
				success := WriteCodeToFile( A_ThisFunc, copiedCss, repository . "CSS\" . backup )
				if ( success ) {
					PasteTextIntoGitShell(caller, "cd '" . repository . "'`rgit add CSS\" . backup
						. "`rgit commit -m 'Updating backup of latest verified custom CSS build'`rg"
						. "it push`r")					
				}
			}
		} else {
			MsgBox % "Please select a GitHub repository within which the CSS build in use on the "
				. "repo's associated WSUWP-based website should be backed up."
		}
	}

	HandleCmtCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			LV_GetText( srcEntryPt, selRow, 4)
			LV_GetText( cssBld, selRow, 5)
			LV_GetText( minBld, selRow, 6)
			CommitCssBuild( A_ThisFunc, repository, srcEntryPt, cssBld, minBld )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Post CSS code to website", % "After committing files "
				. "involved in or produced by the build process that generates custom CSS code "
				. "meant for production use on the WSUWP-based website associated withthis GitHub "
				. "project, would you like to apply the code to the website via the CSS Stylesheet "
				. "Editor page in WSUWP?"
			IfMsgBox Yes
			{
				this.HandlePostCssBtn()
			}
		} else {
			MsgBox % "Please select a GitHub repository within which files related to the process "
				. "of building custom CSS code should be committed."
		}
	}

	HandleCopyCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repoPath, selRow, 2 )
			LV_GetText( minCssRelPath, selRow, 6 )
			LV_GetText( websiteUrl, selRow, 3 )
			LV_GetText( winTitle, selRow, 8 )
			fullPath := repoPath . "CSS\" . minCssRelPath
			CopySrcFileToClipboard( A_ThisFunc
				, fullPath
				, ""
				, "Couldn't copy minified CSS in repository " . repoPath )
			this.delayer.Wait( "l" )
			DisplaySplashText( minCssRelPath . " has been copied to the clipboard.", 3000 )
		} else {
			MsgBox % "Please select a repository from which its file containing built and minified "
				. "custom CSS will be copied to the clipboard."
		}
	}

	HandleCopyPrevCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repoPath, selRow, 2 )
			LV_GetText( prevCssRelPath, selRow, 7 )
			LV_GetText( websiteUrl, selRow, 3 )
			LV_GetText( winTitle, selRow, 8 )
			fullPath := repoPath . "CSS\" . prevCssRelPath
			CopySrcFileToClipboard( A_ThisFunc
				, fullPath
				, ""
				, "Couldn't copy backup CSS in repository " . repoPath )
			this.delayer.Wait( "l" )
			DisplaySplashText( prevCssRelPath . " has been copied to the clipboard.", 3000 )
		} else {
			MsgBox % "Please select a repository from which its file containing backed up custom "
				. "CSS code that has been verified for production usage will be copied to the "
				. "clipboard."
		}
	}

	HandlePostCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repoPath, selRow, 2 )
			LV_GetText( minCssRelPath, selRow, 6 )
			LV_GetText( websiteUrl, selRow, 3 )
			LV_GetText( winTitle, selRow, 8 )
			fullPath := repoPath . "CSS\" . minCssRelPath
			LoadWordPressSiteInChrome( websiteUrl, winTitle )
			this.delayer.Wait( "l" )
			CopySrcFileToClipboard( A_ThisFunc
				, fullPath
				, ""
				, "Couldn't copy minified CSS in repository " . repoPath )
			this.delayer.Wait( "l" )
			ExecuteCssPasteCmds()
		} else {
			MsgBox % "Please select a repository from which its file containing built and minified "
				. "custom CSS will be posted to its associated website created via WSUWP."
		}
	}

	HandlePostPrevCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repoPath, selRow, 2 )
			LV_GetText( prevCssRelPath, selRow, 7 )
			LV_GetText( websiteUrl, selRow, 3 )
			LV_GetText( winTitle, selRow, 8 )
			fullPath := repoPath . "CSS\" . prevCssRelPath
			LoadWordPressSiteInChrome( websiteUrl, winTitle )
			CopySrcFileToClipboard( A_ThisFunc
				, fullPath
				, ""
				, "Couldn't copy backup CSS in repository " . repoPath )
			this.delayer.Wait( "l" )
			ExecuteCssPasteCmds()
		} else {
			MsgBox % "Please select a repository from which its file containing backed up custom "
				. "CSS code that has been verified for production usage will be posted to its "
				. "associated website created via WSUWP."
		}
	}

	HandleRbldCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			PasteTextIntoGitShell( A_ThisFunc
				, "cd '" . repository . "'`r"
				. "gulp buildMinCss`r"
				. "[console]::beep(1500,300)`r" )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Proceed with code commit?", % "After rebuilding files "
				. "containing custom CSS code for use on the WSUWP-based website associated with "
				. "the current GitHub project, would you like to proceed with committing files "
				. "involved in or produced by the build process?"
			IfMsgBox Yes
			{
				this.HandleCmtCssBtn()
				Return
			}
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Post custom CSS to website?", % "After rebuilding files "
				. "containing custom CSS code meant for production usage, would you like to apply "
				. "the minified build to the website associated with the current GitHub project "
				. "via the CSS Stylesheet Editor page in WSUWP?"
			IfMsgBox Yes
			{
				this.HandlePostCssBtn()
			}
		} else {
			MsgBox % "Please select a repository in which to rebuild files containing custom CSS "
				. "code meant for production usage on the repo's associated WSUWP-based website."
		}
	}

	HandleUpdateSmBtn() {
		guiType := this.type
		guiName := this.name
		Gui, ahkGui%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, ahkGui%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			PasteTextIntoGitShell( A_ThisFunc, "cd '" . repository . "WSU-UE---CSS'`rgit checkout "
				. "master`rgit pull`rcd ..`rgit submodule update --remote --merge WSU-UE---CSS`r" )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Proceed with CSS rebuild?", % "After updating the submodule "
				. "containing universal dependencies for building custom CSS code to be used on "
				. "DAESA's websites, would you like to proceed with a production CSS rebuild?"
			IfMsgBox Yes
			{
				this.HandleRbldCssBtn()
			}
		} else {
			MsgBox % "Please select a repository in which the submodule containing universal build "
				. "dependencies for generating production CSS code should be updated."
		}
	}

	ShowGui( dfltMode := "" ) {
		global
		local guiName := this.name
		local guiType := this.type
		local guiCallback
		local numRepos
		local repoName
		local repoPath
		local siteUrl
		local lessSrcFile
		local cssBuildFile
		local minBuildFile
		local prevBuildFile
		local tCBgc

		; Start by creating an empty template for the GUI
		Gui, ahkGui%guiType%%guiName%: New, , % this.title
		this.ApplyTheme()
		tCBgc := this.tCBgc

		; Set up ListView control for viewing repositories for OUE websites.
		Gui, ahkGui%guiType%%guiName%: Add, Text, w480 y16
			, % "Select a repository and a CSS-build related PowerShell operation:"
		Gui, ahkGui%guiType%%guiName%: Add, ListView
			, vctrlGh%guiType%%guiName%LV Background%tCBgc% NoSortHdr -Multi r15 W1440 xm+1 Y+3
			, % "Repo Name|Local Path|Site URL|Build Entry Point|Built CSS|Minified|Backup|Editor "
			. "Title"
		numRepos := this.repos.cfgSettings.Length()
		Loop %numRepos% {
			repoName := this.repos.cfgSettings[ A_Index ][ "name" ]
			repoPath := this.repos.cfgSettings[ A_Index ][ "repository" ]
			siteUrl := this.repos.cfgSettings[ A_Index ][ "url" ]
			lessSrcFile := this.repos.cfgSettings[ A_Index ][ "lessSrcFile" ]
			cssBuildFile := this.repos.cfgSettings[ A_Index ][ "cssBuildFile" ]
			minBuildFile := this.repos.cfgSettings[ A_Index ][ "minBuildFile" ]
			prevBuildFile := this.repos.cfgSettings[ A_Index ][ "prevBuildFile" ]
			winTitle := this.repos.cfgSettings[ A_Index ][ "cssIntfTitle" ]
			LV_Add( , repoName, repoPath, siteUrl, lessSrcFile, cssBuildFile, minBuildFile
				, prevBuildfile, winTitle )
		}
		LV_Modify( 1, "Focus" )
		LV_ModifyCol( 1, "AutoHdr" )
		LV_ModifyCol( 2, 192 )
		LV_ModifyCol( 3, 192 )
		LV_ModifyCol( 4, "AutoHdr" )
		LV_ModifyCol( 5, "AutoHdr" )
		LV_ModifyCol( 6, "AutoHdr" )

		; Set up button for updating submodule containing universal CSS build dependencies
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%UpdateSM Default Y+16
			, % "&Update Dependency Submodule"
		guiCallback := this.updateSmBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%UpdateSM, %guiCallback%

		; Set up button for rebuilding files containing production custom CSS code
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%RbldCss X+5
			, % "&Rebuild CSS"
		guiCallback := this.rbldCssBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%RbldCss, %guiCallback%

		; Set up button for committing files related to the production CSS build process
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%CmtCss X+5
			, % "Co&mmit Files"
		guiCallback := this.cmtCssBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%CmtCss, %guiCallback%

		; Set up button for backing up live custom CSS file in use on the website
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%BakCss X+5
			, % "&Backup from website"
		guiCallback := this.bakCssBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%BakCss, %guiCallback%

		; Set up button for posting CSS to appropriate website
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%PostCss X+5
			, % "&Post to website"
		guiCallback := this.postCssBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%PostCss, %guiCallback%

		; Set up button for copying minified CSS to the clipboard
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%CopyCss X+5
			, % "Cop&y CSS"
		guiCallback := this.copyCssBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%CopyCss, %guiCallback%

		; Set up button for posting backed up CSS to appropriate website
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%PostPrevCss X+5
			, % "Post &backup"
		guiCallback := this.postPrevCssBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%PostPrevCss, %guiCallback%

		; Set up button for copying backed up CSS to the clipboard
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%CopyPrevCss X+5
			, % "Copy bac&kup"
		guiCallback := this.copyPrevCssBtnHdlr.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%CopyPrevCss, %guiCallback%

		; Set up cancel button
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%%guiName%Cancel X+5
			, % "&Close"
		guiCallback := this.cancelBtnHandler.handlerRef
		GuiControl, +g, ahkGui%guiType%%guiName%Cancel, %guiCallback%

		this.ChangeDefaultButton( dfltMode )

		; Display the completed GUI to the user
		Gui, ahkGui%guiType%%guiName%: Show
	}
}

CssBldPsOpsBakCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleBakCssBtn()
}

CssBldPsOpsCancelHdlr( args* ) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}

CssBldPsOpsCmtCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleCmtCssBtn()
}

CssBldPsOpsPostCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandlePostCssBtn()
}

CssBldPsOpsCopyCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleCopyCssBtn()
}

CssBldPsOpsPostPrevCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandlePostPrevCssBtn()
}

CssBldPsOpsCopyPrevCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleCopyPrevCssBtn()
}

CssBldPsOpsRbldCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleRbldCssBtn()
}

CssBldPsOpsUpdateSmBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleUpdateSmBtn()
}
