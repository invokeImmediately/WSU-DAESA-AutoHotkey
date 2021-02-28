; ==================================================================================================
; █▀▀▀ █  █ █▀▀▀ █  █ ▀█▀   ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀▄ █▀▀█ █ ▀▄ █  █  █    █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀ █  ▀ ▀▀▀▀  ▀▀  ▀▀▀ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Prototype for GUIs that support automation of operations and processes involving GitHub
;   repositories.
;
; @version 1.0.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-AutoHotkey/blob/master/GUIs/GhGui.ahk
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

class GhGui extends AhkGui
{
	__New( cfgSettings
			, typer
			, guiType
			, guiName
			, guiTitle
			, cancelBtnHandler ) {

		; Call base's constructor.
		base.__New( typer, guiType, guiName, guiTitle )

		; Safely set configuration settings
		if ( cfgSettings.__Class == "CfgFile" ) {
			this.repos := cfgSettings
		} else {
			throw Exception( A_ThisFunc . ": Configuration settings parameter was not correctly typ"
				. "ed; member '__Class' was set to: '" . cfgSettings.__Class . "'." )
		}

		; Set cancel button handler
		this.cancelBtnHandler := new GuiControlHandler( cancelBtnHandler, this )
	}
}
