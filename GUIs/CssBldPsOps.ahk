; ==================================================================================================
; CssBldPsOps.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Object-oriented implementation of GUI for automating CSS build operations in PowerShell
;   to support the production of custom CSS files to be utilized on WSUWP websites.
;
; DESCRIPTION: This script depends on other functions from the AutoHotkey scripting project that 
;   supports development and coordination of WSU DAESA's websites while working on a Windows
;   platform. The project is developed and maintained on GitHub at:
;   https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck.
;
;   Permission to use, copy, modify, and/or distribute this software for any purpose with or
;   without fee is hereby granted, provided that the above copyright notice and this permission
;   notice appear in all copies.
;
;   THE SOFTWARE IS PROVIDED "AS IS" AND DANIEL C. RIECK DISCLAIMS ALL WARRANTIES WITH REGARD TO
;   THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
;   DANIEL C. RIECK BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
;   DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
;   CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;   PERFORMANCE OF THIS SOFTWARE.
; ==================================================================================================

class CssBldPsOps extends GhGui {
	__New( cfgSettings
			, typer
			, delayer
			, guiType := "CssBldPsOps"
			, guiName := "Default"
			, guiTitle := ""
			, updateSmBtnHdlr := "CssBldPsOpsUpdateSmBtnHdlr"
			, rbldCssBtnHdlr := "CssBldPsOpsRbldCssBtnHdlr"
			, cmtCssBtnHdlr := "CssBldPsOpsCmtCssBtnHdlr"
			, bakCssBtnHdlr := "CssBldPsOpsBakCssBtnHdlr"
			, postCssBtnHdlr := "CssBldPsOpsPostCssBtnHdlr"
			, postPrevCssBtnHdlr := "CssBldPsOpsPostPrevCssBtnHdlr"
			, cancelBtnHdlr := "CssBldPsOpsCancelHdlr" ) {
		base.__New( cfgSettings, typer, guiType, guiName, guiTitle, cancelBtnHdlr )
		this.delayer := delayer
		this.updateSmBtnHdlr := new GuiControlHandler( updateSmBtnHdlr, this )
		this.rbldCssBtnHdlr := new GuiControlHandler( rbldCssBtnHdlr, this )
		this.cmtCssBtnHdlr := new GuiControlHandler( cmtCssBtnHdlr, this )
		this.bakCssBtnHdlr := new GuiControlHandler( bakCssBtnHdlr, this )
		this.postCssBtnHdlr := new GuiControlHandler( postCssBtnHdlr, this )
		this.postPrevCssBtnHdlr := new GuiControlHandler( postPrevCssBtnHdlr, this )
	}

	ChangeDefaultButton( dfltMode ) {
		global
		local guiName := this.name
		local guiType := this.type

		if ( dfltMode == "update" || dfltMode == "u" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%UpdateSM
		} else if ( dfltMode == "rebuild" || dfltMode == "r" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%RbldCss
		} else if ( dfltMode == "commit" || dfltMode == "m" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%CmtCss
		} else if ( dfltMode == "backup" || dfltMode == "b" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%BakCss
		} else if ( dfltMode == "post" || dfltMode == "p" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%PostCss
		} else if ( dfltMode == "postBackup" || dfltMode == "pb" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%PostPrevCss
		}
	}

	HandleBakCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
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
			MsgBox % "Please select a repository for which the CSS build in use on its WSUWP websit"
				. "e should be backed up."
		}
	}

	HandleCmtCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			LV_GetText( srcEntryPt, selRow, 4)
			LV_GetText( cssBld, selRow, 5)
			LV_GetText( minBld, selRow, 6)
			CommitCssBuild( A_ThisFunc, repository, srcEntryPt, cssBld, minBld )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Post CSS to website", % "After committing custom CSS build "
				. "files and dependencies, would you like to apply the custom stylesheet built for "
				. "production to the website via the WSUWP CSS Stylesheet Editor?"
			IfMsgBox Yes
			{
				this.HandlePostCssBtn()
			}
		} else {
			MsgBox % "Please select a repository for which files related to the custom CSS build sh"
				. "ould be committed to GitHub."
		}
	}

	HandlePostCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repoPath, selRow, 2 )
			LV_GetText( minCssRelPath, selRow, 6 )
			LV_GetText( websiteUrl, selRow, 3 )
			LV_GetText( winTitle, selRow, 8 )
			fullPath := repoPath . "CSS\" . minCssRelPath
			LoadWordPressSiteInChrome( websiteUrl, winTitle )
			CopySrcFileToClipboard( A_ThisFunc
				, fullPath
				, ""
				, "Couldn't copy minified CSS in repository " . repoPath )
			this.delayer.Wait( "l" )
			ExecuteCssPasteCmds()
		} else {
			MsgBox % "Please select a repository from which its built and minified custom CSS file "
				. "will be posted to its WSUWP website."
		}
	}

	HandlePostPrevCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
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
			MsgBox % "Please select a repository from which its backup custom CSS file will be post"
				. "ed to its WSUWP website."
		}
	}

	HandleRbldCssBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			PasteTextIntoGitShell( A_ThisFunc
				, "cd '" . repository . "'`r"
				. "gulp buildMinCss`r"
				. "[console]::beep(1500,300)`r" )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Proceed with code commit?", % "After rebuilding the custom CS"
				. "S file for use on the WSUWP website, would you like to proceed with committing C"
				. "SS build-related files?"
			IfMsgBox Yes
			{
				this.HandleCmtCssBtn()
				Return
			}
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Post custom CSS to website", % "After rebuilding the the "
				. "custom stylesheet built for production, would you like to apply it to the "
				. "website via the WSUWP CSS Stylesheet Editor?"
			IfMsgBox Yes
			{
				this.HandlePostCssBtn()
			}
		} else {
			MsgBox % "Please select a repository in which to rebuild the WSUWP website's custom CSS"
				. " file."
		}
	}

	HandleUpdateSmBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			PasteTextIntoGitShell( A_ThisFunc, "cd '" . repository . "\WSU-UE---CSS'`rgit checkout "
 . "master`rgit pull`rcd ..`rgit submodule update --remote --merge WSU-UE---CSS`r")
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Proceed with rebuild?", % "After updating the CSS submodule, "
 . "would you like to proceed with a CSS rebuild?"
			IfMsgBox Yes
			{
				this.HandleRbldCssBtn()
			}
		} else {
			MsgBox % "Please select a repository in which the CSS dependency submodule should be up"
 . "dated."
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

		; Start by creating an empty template for the GUI
		Gui, guiGh%guiType%%guiName%: New, , % this.title

		; Set up ListView control for viewing repositories for OUE websites.
		Gui, guiGh%guiType%%guiName%: Add, Text, w320 y16
			, % "Select a repository and a CSS-build related PowerShell operation:"
		Gui, guiGh%guiType%%guiName%: Add, ListView
			, vctrlGh%guiType%%guiName%LV BackgroundWhite NoSortHdr -Multi r15 W1440 xm+1 Y+3
			, % "Repo Name|Local Path|Site URL|Build Entry Point|Built CSS|Minified|Backup|Editor T"
			. "itle"
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

		; Set up button for updating CSS dependency submodules
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%UpdateSM Default Y+16
			, % "&Update Dependency Submodule"
		guiCallback := this.updateSmBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%UpdateSM, %guiCallback%

		; Set up button for rebuilding custom CSS files
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%RbldCss X+5
			, % "&Rebuild CSS"
		guiCallback := this.rbldCssBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%RbldCss, %guiCallback%

		; Set up button for committing CSS build-related files
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%CmtCss X+5
			, % "Co&mmit Files"
		guiCallback := this.cmtCssBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%CmtCss, %guiCallback%

		; Set up button for backing up live custom CSS file in use on the website
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%BakCss X+5
			, % "&Backup from website"
		guiCallback := this.bakCssBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%BakCss, %guiCallback%

		; Set up button for posting CSS to appropriate website
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%PostCss X+5
			, % "&Post to website"
		guiCallback := this.postCssBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%PostCss, %guiCallback%

		; Set up button for posting backup CSS to appropriate website
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%PostPrevCss X+5
			, % "Post &backup"
		guiCallback := this.postPrevCssBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%PostPrevCss, %guiCallback%

		; Set up cancel button
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%Cancel X+5
			, % "&Close"
		guiCallback := this.cancelBtnHandler.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%Cancel, %guiCallback%

		this.ChangeDefaultButton( dfltMode )

		; Display the completed GUI to the user
		Gui, guiGh%guiType%%guiName%: Show
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

CssBldPsOpsPostPrevCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandlePostPrevCssBtn()
}

CssBldPsOpsRbldCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleRbldCssBtn()
}

CssBldPsOpsUpdateSmBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleUpdateSmBtn()
}
