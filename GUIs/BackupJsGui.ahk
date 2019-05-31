; ==================================================================================================
; BackupJsGui.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Object-oriented implementation of GUI for backing up custom JS builds that are verified
;   to be working on WSUWP websites.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck. (Please refer to AutoHotkeyU64.ahk for full
;   license text.)
; ==================================================================================================

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
