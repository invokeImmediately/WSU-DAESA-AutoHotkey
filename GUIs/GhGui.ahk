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
; LICENSE: MIT - Copyright (c) 2020 Daniel C. Rieck.
;
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;   and associated documentation files (the “Software”), to deal in the Software without
;   restriction, including without limitation the rights to use, copy, modify, merge, publish,
;   distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in all copies or
;   substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;   BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================

class GhGui
{
	__New( cfgSettings
			, typer
			, guiType
			, guiName
			, guiTitle
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
		this.cancelBtnHandler := new GuiControlHandler( cancelBtnHandler, this )
	}

	CloseGui() {
		guiType := this.type
		guiName := this.name
		Gui, guiGh%guiType%%guiName%: Destroy
	}
}
