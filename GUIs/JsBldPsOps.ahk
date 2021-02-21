; ==================================================================================================
;    █ ▄▀▀▀ █▀▀▄ █    █▀▀▄ █▀▀▄ ▄▀▀▀ ▄▀▀▄ █▀▀▄ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; ▄  █ ▀▀▀█ █▀▀▄ █  ▄ █  █ █▄▄▀ ▀▀▀█ █  █ █▄▄▀ ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
; ▀▄▄█ ▀▀▀  ▀▀▀  ▀▀▀  ▀▀▀  █    ▀▀▀   ▀▀  █    ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Object-oriented implementation of GUI for automating JS build operations in PowerShell to support
;   the production of custom JS code to be employed on WSUWP-based websites.
;
; This script depends on other functions from the AutoHotkey scripting project that supports
;   development and coordination of WSU DAESA's websites while working on a Windows platform. The
;   project is developed and maintained on GitHub at the linked repository.
;
; @version 1.0.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-AutoHotkey/blob/master/GUIs/JsBldPsOps.ahk
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

class JsBldPsOps extends GhGui {
	__New( cfgSettings
			, typer
			, delayer
			, guiType := "JsBldPsOps"
			, guiName := "Default"
			, guiTitle := "PowerShell Extender for Enhancing JS Development"
			, updateSmBtnHdlr := "JsBldPsOpsUpdateSmBtnHdlr"
			, rbldJsBtnHdlr := "JsBldPsOpsRbldJsBtnHdlr"
			, cmtJsBtnHdlr := "JsBldPsOpsCmtJsBtnHdlr"
			, bakJsBtnHdlr := "JsBldPsOpsBakJsBtnHdlr"
			, postJsBtnHdlr := "JsBldPsOpsPostJsBtnHdlr"
			, postPrevJsBtnHdlr := "JsBldPsOpsPostPrevJsBtnHdlr"
			, cancelBtnHdlr := "JsBldPsOpsCancelHdlr" ) {
		base.__New( cfgSettings, typer, guiType, guiName, guiTitle, cancelBtnHdlr )
		this.delayer := delayer
		this.updateSmBtnHdlr := new GuiControlHandler( updateSmBtnHdlr, this )
		this.rbldJsBtnHdlr := new GuiControlHandler( rbldJsBtnHdlr, this )
		this.cmtJsBtnHdlr := new GuiControlHandler( cmtJsBtnHdlr, this )
		this.bakJsBtnHdlr := new GuiControlHandler( bakJsBtnHdlr, this )
		this.postJsBtnHdlr := new GuiControlHandler( postJsBtnHdlr, this )
		this.postPrevJsBtnHdlr := new GuiControlHandler( postPrevJsBtnHdlr, this )
	}

	ChangeDefaultButton( dfltMode ) {
		global
		local guiName := this.name
		local guiType := this.type

		if ( dfltMode == "update" || dfltMode == "u" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%UpdateSM
		} else if ( dfltMode == "rebuild" || dfltMode == "r" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%RbldJs
		} else if ( dfltMode == "commit" || dfltMode == "m" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%CmtJs
		} else if ( dfltMode == "backup" || dfltMode == "b" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%BakJs
		} else if ( dfltMode == "post" || dfltMode == "p" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%PostJs
		} else if ( dfltMode == "postBackup" || dfltMode == "pb" ) {
			GuiControl, +Default, guiGh%guiType%%guiName%PostPrevJs
		}
	}

	HandleBakJsBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2 )
			LV_GetText( website, selRow, 3 )
			LV_GetText( backup, selRow, 7 )
			CopyJsFromWebsite( website, copiedJs )
			if ( VerifyCopiedCode( A_ThisFunc, copiedJs ) ) {
				success := WriteCodeToFile( A_ThisFunc, copiedJs, repository . "JS\" . backup )
				if ( success ) {
					PasteTextIntoGitShell(caller, "cd '" . repository . "'`rgit add JS\" . backup
						. "`rgit commit -m 'Updating backup of latest verified custom JS build'`rg"
						. "it push`r")					
				}
			}
		} else {
			MsgBox % "Please select a GitHub repository within which the JS build in use on the "
				. "repo's associated WSUWP-based website should be backed up."
		}
	}

	HandleCmtJsBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			LV_GetText( srcEntryPt, selRow, 4)
			LV_GetText( jsBld, selRow, 5)
			LV_GetText( minBld, selRow, 6)
			CommitJsBuild( A_ThisFunc, repository, srcEntryPt, jsBld, minBld )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Post JS code to website", % "After committing files "
				. "involved in or produced by the build process that generates custom JS code "
				. "meant for production use on the WSUWP-based website associated withthis GitHub "
				. "project, would you like to apply the code to the website via the Custom JS "
				. "Editor page in WSUWP?"
			IfMsgBox Yes
			{
				this.HandlePostJsBtn()
			}
		} else {
			MsgBox % "Please select a GitHub repository within which files related to the process "
				. "of building custom JS code should be committed."
		}
	}

	HandlePostJsBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repoPath, selRow, 2 )
			LV_GetText( minJsRelPath, selRow, 6 )
			LV_GetText( websiteUrl, selRow, 3 )
			LV_GetText( winTitle, selRow, 8 )
			fullPath := repoPath . "JS\" . minJsRelPath
			LoadWordPressSiteInChrome( websiteUrl, winTitle )
			this.delayer.Wait( "l" )
			CopySrcFileToClipboard( A_ThisFunc
				, fullPath
				, ""
				, "Couldn't copy minified JS in repository " . repoPath )
			this.delayer.Wait( "l" )
			ExecuteJsPasteCmds()
		} else {
			MsgBox % "Please select a repository from which its file containing built and minified "
				. "custom JS code will be posted to its associated website created via WSUWP."
		}
	}

	HandlePostPrevJsBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repoPath, selRow, 2 )
			LV_GetText( prevJsRelPath, selRow, 7 )
			LV_GetText( websiteUrl, selRow, 3 )
			LV_GetText( winTitle, selRow, 8 )
			fullPath := repoPath . "JS\" . prevJsRelPath
			LoadWordPressSiteInChrome( websiteUrl, winTitle )
			CopySrcFileToClipboard( A_ThisFunc
				, fullPath
				, ""
				, "Couldn't copy backup JS in repository " . repoPath )
			this.delayer.Wait( "l" )
			ExecuteJsPasteCmds()
		} else {
			MsgBox % "Please select a repository from which its file containing backed up custom "
				. "JS code that has been verified for production usage will be posted to its "
				. "associated website created via WSUWP."
		}
	}

	HandleRbldJsBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
			selRow := LV_GetNext()
			LV_GetText( repository, selRow, 2)
			PasteTextIntoGitShell( A_ThisFunc
				, "cd '" . repository . "'`r"
				. "gulp buildMinJs`r"
				. "[console]::beep(1500,300)`r" )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Proceed with code commit?", % "After rebuilding files "
				. "containing custom JS code for use on the WSUWP-based website associated with "
				. "the current GitHub project, would you like to proceed with committing files "
				. "involved in or produced by the build process?"
			IfMsgBox Yes
			{
				this.HandleCmtJsBtn()
				Return
			}
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Post custom JS code to website?", % "After rebuilding files "
				. "containing custom JS code meant for production usage, would you like to apply "
				. "the minified build to the website associated with the current GitHub project "
				. "via the Custom JavaScript Editor page in WSUWP?"
			IfMsgBox Yes
			{
				this.HandlePostJsBtn()
			}
		} else {
			MsgBox % "Please select a repository in which to rebuild files containing custom JS "
				. "code meant for production usage on the repo's associated WSUWP-based website."
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
			PasteTextIntoGitShell( A_ThisFunc, "cd '" . repository . "WSU-DAESA-JS'`rgit checkout "
				. "master`rgit pull`rcd ..`rgit submodule update --remote --merge WSU-DAESA-JS`r" )
			MsgBox, % (0x4 + 0x20)
				, % A_ScriptName . ": Proceed with rebuild?", % "After updating the submodule "
				. "containing universal dependencies for building custom JS code to be used on "
				. "DAESA's websites, would you like to proceed with a production JS rebuild?"
			IfMsgBox Yes
			{
				this.HandleRbldJsBtn()
			}
		} else {
			MsgBox % "Please select a repository in which the submodule containing universal build "
				. "dependencies for generating production JS code should be updated."
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
		local jsSrcFile
		local jsBuildFile
		local minBuildFile
		local prevBuildFile

		; Start by creating an empty template for the GUI
		Gui, guiGh%guiType%%guiName%: New, , % this.title

		; Set up ListView control for viewing repositories for OUE websites.
		Gui, guiGh%guiType%%guiName%: Add, Text, w320 y16
			, % "Select a repository and a JS-build related PowerShell operation:"
		Gui, guiGh%guiType%%guiName%: Add, ListView
			, vctrlGh%guiType%%guiName%LV BackgroundWhite NoSortHdr -Multi r15 W1440 xm+1 Y+3
			, % "Repo Name|Local Path|Site URL|Build Entry Point|Built JS|Minified|Backup|Editor "
			. "Title"
		numRepos := this.repos.cfgSettings.Length()
		Loop %numRepos% {
			repoName := this.repos.cfgSettings[ A_Index ][ "name" ]
			repoPath := this.repos.cfgSettings[ A_Index ][ "repository" ]
			siteUrl := this.repos.cfgSettings[ A_Index ][ "url" ]
			jsSrcFile := this.repos.cfgSettings[ A_Index ][ "jsSrcFile" ]
			jsBuildFile := this.repos.cfgSettings[ A_Index ][ "jsBuildFile" ]
			minBuildFile := this.repos.cfgSettings[ A_Index ][ "minBuildFile" ]
			prevBuildFile := this.repos.cfgSettings[ A_Index ][ "prevBuildFile" ]
			winTitle := this.repos.cfgSettings[ A_Index ][ "jsIntfTitle" ]
			LV_Add( , repoName, repoPath, siteUrl, jsSrcFile, jsBuildFile, minBuildFile
				, prevBuildfile, winTitle )
		}
		LV_Modify( 1, "Focus" )
		LV_ModifyCol( 1, "AutoHdr" )
		LV_ModifyCol( 2, 192 )
		LV_ModifyCol( 3, 192 )
		LV_ModifyCol( 4, "AutoHdr" )
		LV_ModifyCol( 5, "AutoHdr" )
		LV_ModifyCol( 6, "AutoHdr" )

		; Set up button for updating submodule containing universal JS build dependencies
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%UpdateSM Default Y+16
			, % "&Update Dependency Submodule"
		guiCallback := this.updateSmBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%UpdateSM, %guiCallback%

		; Set up button for rebuilding files containing production JS code
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%RbldJs X+5
			, % "&Rebuild JS"
		guiCallback := this.rbldJsBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%RbldJs, %guiCallback%

		; Set up button for committing files related to the production JS build process
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%CmtJs X+5
			, % "Co&mmit Files"
		guiCallback := this.cmtJsBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%CmtJs, %guiCallback%

		; Set up button for backing up live custom JS file in use on the website
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%BakJs X+5
			, % "&Backup from website"
		guiCallback := this.bakJsBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%BakJs, %guiCallback%

		; Set up button for posting JS to appropriate website
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%PostJs X+5
			, % "&Post to website"
		guiCallback := this.postJsBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%PostJs, %guiCallback%

		; Set up button for posting backup JS to appropriate website
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%%guiName%PostPrevJs X+5
			, % "Post &backup"
		guiCallback := this.postPrevJsBtnHdlr.handlerRef
		GuiControl, +g, guiGh%guiType%%guiName%PostPrevJs, %guiCallback%

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

JsBldPsOpsBakJsBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleBakJsBtn()
}

JsBldPsOpsCancelHdlr( args* ) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}

JsBldPsOpsCmtJsBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleCmtJsBtn()
}

JsBldPsOpsPostJsBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandlePostJsBtn()
}

JsBldPsOpsPostPrevJsBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandlePostPrevJsBtn()
}

JsBldPsOpsRbldJsBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleRbldJsBtn()
}

JsBldPsOpsUpdateSmBtnHdlr( args* ) {
	guiToHandle := args[1]
	guiToHandle.HandleUpdateSmBtn()
}
