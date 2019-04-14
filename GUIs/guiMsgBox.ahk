; ==================================================================================================
; guiMsgBox.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Generate a GUI-based message box that does not interrupt script operation.
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

class GuiControlHandler
{
	__New( handlerName, guiRef ) {
		this.handlerRef := Func( handlerName )
		this.guiRef := guiRef
		this.handlerRef := ( this.handlerRef ).Bind( this.guiRef )
	}
}

class GuiMsgBox
{
	__New( guiMsg, guiName := "Default", guiTitle := "", okBtnHandler := "HandleGuiMsgBoxOk" ) {
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

HandleGuiMsgBoxOk( args* ) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}
