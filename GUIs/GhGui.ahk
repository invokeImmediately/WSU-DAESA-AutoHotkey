; ==================================================================================================
; GhGui.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Prototype for GUIs that support automation of operations and processes involving GitHub
;   repositories.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck. (Please refer to AutoHotkeyU64.ahk for full
;   license text.)
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
