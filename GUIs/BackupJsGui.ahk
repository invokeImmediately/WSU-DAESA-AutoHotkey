; ==================================================================================================
; █▀▀▄ ▄▀▀▄ ▄▀▀▀ █ ▄▀ █  █ █▀▀▄    █ ▄▀▀▀ █▀▀▀ █  █ ▀█▀   ▄▀▀▄ █  █ █ ▄▀ 
; █▀▀▄ █▄▄█ █    █▀▄  █  █ █▄▄▀ ▄  █ ▀▀▀█ █ ▀▄ █  █  █    █▄▄█ █▀▀█ █▀▄  
; ▀▀▀  █  ▀  ▀▀▀ ▀  ▀▄ ▀▀  █    ▀▄▄█ ▀▀▀  ▀▀▀▀  ▀▀  ▀▀▀ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Object-oriented implementation of GUI for backing up custom JS builds that are verified to be
;   working on WSUWP websites.
;
; @version 1.0.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-AutoHotkey/blob/master/GUIs/BackupJsGui.ahk
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

class BackupJsGui extends GhGui {
	__New( cfgSettings
			, typer
			, guiType := "BackupJs"
			, guiName := "Default"
			, guiTitle := ""
			, okBtnHandler := "HandleGuiGhBackupJsOk"
			, cancelBtnHandler := "HandleGuiGhBackupJsCancel" ) {
		base.__New( cfgSettings, typer, guiType, guiName, guiTitle, cancelBtnHandler )
		this.okBtnHandler := new GuiControlHandler( okBtnHandler, this )
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
			, vctrlGh%guiType%%guiName%LV BackgroundWhite NoSortHdr -Multi r15 W728 xm+1 Y+3
			, % "Name|Path|Site URL|Backup File"
		numRepos := this.repos.cfgSettings.Length()
		Loop %numRepos% {
			repoName := this.repos.cfgSettings[ A_Index ][ "name" ]
			repoPath := this.repos.cfgSettings[ A_Index ][ "repository" ]
			siteUrl := this.repos.cfgSettings[ A_Index ][ "url" ]
			repoBackupFile := this.repos.cfgSettings[ A_Index ][ "backupFile" ]
			LV_Add( , repoName, repoPath, siteUrl, repoBackupFile )
		}
		LV_Modify( 1, "Focus" )
		LV_ModifyCol( 1, "AutoHdr" )
		LV_ModifyCol( 2, 192 )
		LV_ModifyCol( 3, 192 )
		LV_ModifyCol( 4, "AutoHdr" )
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
			Gui, guiGh%guiType%%guiName%: Submit, NoHide
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
