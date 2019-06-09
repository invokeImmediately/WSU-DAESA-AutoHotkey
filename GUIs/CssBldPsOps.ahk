; ==================================================================================================
; CssBldPsOps.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Object-oriented implementation of GUI for automating CSS build operations in PowerShell
;   to support the production of custom CSS files to be utilized on WSUWP websites.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck. (Please refer to AutoHotkeyU64.ahk for full
;   license text.)
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
			, postCssBtnHdlr := "CssBldPsOpsPostCssBtnHdlr"
			, cancelBtnHdlr := "CssBldPsOpsCancelHdlr" ) {
		base.__New( cfgSettings, typer, guiType, guiName, guiTitle, cancelBtnHdlr )
		this.delayer := delayer
		this.updateSmBtnHdlr := new GuiControlHandler( updateSmBtnHdlr, this )
		this.rbldCssBtnHdlr := new GuiControlHandler( rbldCssBtnHdlr, this )
		this.cmtCssBtnHdlr := new GuiControlHandler( cmtCssBtnHdlr, this )
		this.postCssBtnHdlr := new GuiControlHandler( postCssBtnHdlr, this )
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
		} else if ( dfltMode == "post" || dfltMode == "p" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%PostCss
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
			LV_GetText( repoPath, selRow, 2)
			LV_GetText( minCssRelPath, selRow, 6)
			LV_GetText( websiteUrl, selRow, 3)
			fullPath := repoPath . "CSS\" . minCssRelPath
			LoadWordPressSiteInChrome(websiteUrl)
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
			PasteTextIntoGitShell( A_ThisFunc, "cd '" . repository . "WSU-UE---CSS'`r"
				. "git fetch`rgit merge origin/master`rcd ..`rgit add WSU-UE---CSS`rgit commit -m '"
				. "Updating custom CSS master submodule for OUE websites' -m 'Obtaining recent chan"
				. "ges in OUE-wide Less/CSS source code for use in builds'`rgit push`r")
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

		; Start by creating an empty template for the GUI
		Gui, guiGh%guiType%%guiName%: New, , % this.title

		; Set up ListView control for viewing repositories for OUE websites.
		Gui, guiGh%guiType%%guiName%: Add, Text, w320 y16
			, % "Select a repository and a CSS-build related PowerShell operation:"
		Gui, guiGh%guiType%%guiName%: Add, ListView
			, vctrlGh%guiType%%guiName%LV BackgroundWhite NoSortHdr -Multi r15 W1440 xm+1 Y+3
			, % "Repo Name|Local Path|Site URL|Build Entry Point|Built CSS|Minified"
		numRepos := this.repos.cfgSettings.Length()
		Loop %numRepos% {
			repoName := this.repos.cfgSettings[ A_Index ][ "name" ]
			repoPath := this.repos.cfgSettings[ A_Index ][ "repository" ]
			siteUrl := this.repos.cfgSettings[ A_Index ][ "url" ]
			lessSrcFile := this.repos.cfgSettings[ A_Index ][ "lessSrcFile" ]
			cssBuildFile := this.repos.cfgSettings[ A_Index ][ "cssBuildFile" ]
			minBuildFile := this.repos.cfgSettings[ A_Index ][ "minBuildFile" ]
			LV_Add( , repoName, repoPath, siteUrl, lessSrcFile, cssBuildFile, minBuildFile )
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

		; Set up button for posting CSS to appropriate website
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%PostCss X+5
			, % "&Post to website"
		guiCallback := this.postCssBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%PostCss, %guiCallback%

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

CssBldPsOpsRbldCssBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleRbldCssBtn()
}

CssBldPsOpsUpdateSmBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleUpdateSmBtn()
}
