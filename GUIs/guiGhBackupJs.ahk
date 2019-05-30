; ==================================================================================================
; guiGhBackupJs.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: GUI for going to a file location.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck.
;
;   Permission to use, copy, modify, and/or distribute this software for any purpose with or
;   without fee is hereby granted, provided that the above copyright notice and this permission
;   notice appear in all copies.
;
;   THE SOFTWARE IS PROVIDED "AS IS" AND DANIEL RIECK DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
;   SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
;   DANIEL RIECK BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
;   DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
;   CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;   PERFORMANCE OF THIS SOFTWARE.
; ==================================================================================================

class GhGui
{
	__New( cfgSettings
			, typer
			, guiType
			, guiName
			, guiTitle
			, okBtnHandler
			, cancelBtnHandler ) {

		; Safely set configuration settings
		if ( cfgSettings.__Class == "CfgFile" ) {
			this.repos := cfgSettings
		} else {
			throw Exception( A_ThisFunc . ": Configuration settings parameter was not correctly typ"
				. "ed; member '__Class' was set to: '" . cfgSettings.__Class . "'." )
		}

		; Safely set type checker
		if ( typer.__Class == "TypeChecker" ) {
			this.typer := typer
		} else {
			throw Exception( A_ThisFunc . ": Type checker parameter was not correctly typed; member"
				. " '__Class' was set to: '" . typer.__Class . "'." )
		}

		; Safely set GUI Type identifier
		if ( typer.IsAlnum( guiType ) && guiType != "" ) {
			this.type := guiType
		} else {
			this.type := "Misc"
		}
		if ( typer.IsAlnum( guiName ) && guiName != "" ) {
			this.name := guiName
		} else {
			this.name := "Default"
		}
		if ( typer.IsAlnum( guiTitle ) && guiTitle != "" ) {
			this.title := guiTitle
		} else {
			this.title := A_ScriptName
		}
		this.okBtnHandler := new GuiControlHandler( okBtnHandler, this )
		this.cancelBtnHandler := new GuiControlHandler( cancelBtnHandler, this )
	}

	CloseGui() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Destroy
	}
}

class BackupJsGui extends GhGui {
	__New( cfgSettings
			, typer
			, guiType := "BackupJs"
			, guiName := "Default"
			, guiTitle := ""
			, okBtnHandler := "HandleGuiGhBackupJsOk"
			, cancelBtnHandler := "HandleGuiGhBackupJsCancel" ) {
		base.__New( cfgSettings, typer, guiType, guiName, guiTitle, okBtnHandler, cancelBtnHandler )
	}

	ShowGui() {
		global
		local guiName := this.name
		local guiType := this.type
		local guiCallback
		local numRepos
		local repoName
		local repoPath
		local siteUrl
		local repoBackupFile

		Gui, guiGh%guiType%%guiName%: New, , % this.title
		Gui, guiGh%guiType%%guiName%: Add, Text, w320 y16
			, % "Select a repository in which the JS backup will be performed:"
		Gui, guiGh%guiType%%guiName%: Add, ListView
			, vctrlGh%guiType%%guiName%LV grid BackgroundEBF8FE NoSortHdr -Multi r15 W728 xm+1 Y+3
			, % "Name|Path|Site URL|Backup File"
		numRepos := this.repos.cfgSettings.Length()
		Loop %numRepos% {
			repoName := this.repos.cfgSettings[ A_Index ][ "name" ]
			repoPath := this.repos.cfgSettings[ A_Index ][ "repository" ]
			siteUrl := this.repos.cfgSettings[ A_Index ][ "url" ]
			repoBackupFile := this.repos.cfgSettings[ A_Index ][ "backupFile" ]
			LV_Add( , repoName, repoPath, siteUrl, repoBackupFile )
		}
		Gui, guiGh%guiType%%guiName%: Add, Button
			, vguiGh%guiType%Ok%guiName% Default w80 x140 xm Y+16, % "&Ok"
		guiCallback := this.okBtnHandler.handlerRef
		GuiControl, +g, guiGh%guiType%Ok%guiName%, %guiCallback%
		Gui, guiGh%guiType%%guiName%: Add, Button, vguiGh%guiType%Cancel%guiName% X+5, &Cancel
		guiCallback := this.cancelBtnHandler.handlerRef
		GuiControl, +g, guiGh%guiType%Cancel%guiName%, %guiCallback%
		Gui, guiGh%guiType%%guiName%: Show
	}

	HandleOkBtn() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Default
		if ( LV_GetCount( "Selected" ) ) {
			Gui, guiGhBackupJs%guiName%: Submit
			selRow := LV_GetNext()
			LV_GetText( website, selRow, 3)
			LV_GetText( repository, selRow, 2)
			LV_GetText( backupFile, selRow, 4)
			this.CloseGui()
			BackupJs( "", website, repository, backupFile)
		} else {
			MsgBox % "Please select a repository in which to perform the custom JS backup."
		}
	}
}

HandleGuiGhBackupJsOk( args* ) {
	guiToClose := args[1]
	guiToClose.HandleOkBtn()
}

HandleGuiGhBackupJsCancel( args* ) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}
