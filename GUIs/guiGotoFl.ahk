; ==================================================================================================
; █▀▀▀ █  █ ▀█▀ █▀▀▀ ▄▀▀▄▐▀█▀▌▄▀▀▄ █▀▀▀ █      ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀▄ █  █  █  █ ▀▄ █  █  █  █  █ █▀▀▀ █  ▄   █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀  ▀▀  ▀▀▀ ▀▀▀▀  ▀▀   █   ▀▀  ▀    ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; GUI for going to a file location.
;
; @version 0.0.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/GUIs/guiGotoFl.ahk
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

class GuiGotoFl
{
	__New( logFile
			, guiName := "Default"
			, guiTitle := ""
			, addCmdHandler := "HandleGotoFlAddCmd"
			, okBtnHandler := "HandleGuiGotoFlOk" ) {
		if ( guiName != "" ) {
			this.name := guiName
		} else {
			this.name := "Default"
		}
		this.msg := guiMsg
		if ( guiTitle != "" ) {
			this.title := guiTitle
		} else {
			this.title := A_ScriptName
		}
		this.okBtnHandler := new GuiControlHandler( okBtnHandler, this )
	}

	ShowGui() {
		global
		local guiName := this.name
		local guiCallback := this.okBtnHandler.handlerRef
		Gui, guiMsgBox%guiName%: New, , % this.title
		Gui, guiMsgBox%guiName%: Add, Text, w320 y16, % this.msg
		Gui, guiMsgBox%guiName%: Add, Button, vguiMsgBoxOk%guiName% Default w80 x140 Y+16, % "&Ok"
		GuiControl, +g, guiMsgBoxOk%guiName%, %guiCallback%
		Gui, guiMsgBox%guiName%: Show
	}

	CloseGui() {
		guiName := this.name
		Gui, guiMsgBox%guiName%: Destroy
	}
}

HandleGuiGotoFlOk( args* ) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}
