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

class GuiGhBackupJs
{
	__New( cfgSettings
			, guiName := "Default"
			, guiTitle := ""
			, okBtnHandler := "HandleGuiGhBackupJsOk"
			, cancelBtnHandler := "HandleGuiGhBackupJsCancel" ) {
		this.repos := cfgSettings
		if ( guiName != "" ) {
			this.name := guiName
		} else {
			this.name := "Default"
		}
		if ( guiTitle != "" ) {
			this.title := guiTitle
		} else {
			this.title := A_ScriptName
		}
		this.okBtnHandler := new GuiControlHandler( okBtnHandler, this )
		this.cancelBtnHandler := new GuiControlHandler( cancelBtnHandler, this )
	}

	CloseGui() {
		guiName := this.name
		Gui, guiGhBackupJs%guiName%: Destroy
	}

	HandleOkBtn() {
		; TODO: Write function to handle call to BackupJs...
		guiName := this.name
		Gui, guiGhBackupJs%guiName%: Default
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

	ShowGui() {
		global
		local guiName := this.name
		local guiCallback
		local numRepos
		local repoName
		local repoPath
		local siteUrl
		local repoBackupFile

		Gui, guiGhBackupJs%guiName%: New, , % this.title
		Gui, guiGhBackupJs%guiName%: Add, Text, w320 y16
			, % "Select a repository in which the JS backup will be performed:"
		Gui, guiGhBackupJs%guiName%: Add, ListView
			, vctrlGhBackupJs%guiName%LV grid BackgroundEBF8FE NoSortHdr -Multi r15 W728 xm+1 Y+3
			, % "Name|Path|Site URL|Backup File"
		numRepos := this.repos.cfgSettings.Length()
		Loop %numRepos% {
			repoName := this.repos.cfgSettings[ A_Index ][ "name" ]
			repoPath := this.repos.cfgSettings[ A_Index ][ "repository" ]
			siteUrl := this.repos.cfgSettings[ A_Index ][ "url" ]
			repoBackupFile := this.repos.cfgSettings[ A_Index ][ "backupFile" ]
			LV_Add( , repoName, repoPath, siteUrl, repoBackupFile )
		}
		Gui, guiGhBackupJs%guiName%: Add, Button
			, vguiGhBackupJsOk%guiName% Default w80 x140 xm Y+16, % "&Ok"
		guiCallback := this.okBtnHandler.handlerRef
		GuiControl, +g, guiGhBackupJsOk%guiName%, %guiCallback%
		Gui, guiGhBackupJs%guiName%: Add, Button, vguiGhBackupJsCancel%guiName% X+5, &Cancel
		guiCallback := this.cancelBtnHandler.handlerRef
		GuiControl, +g, guiGhBackupJsCancel%guiName%, %guiCallback%
		Gui, guiGhBackupJs%guiName%: Show
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
