; ==================================================================================================
; █▀▀▀ █  █ ▀█▀ ▐▀▄▀▌▄▀▀▀ █▀▀▀ █▀▀▄ ▄▀▀▄▐▄ ▄▌   ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀▄ █  █  █  █ ▀ ▌▀▀▀█ █ ▀▄ █▀▀▄ █  █  █     █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀  ▀▀  ▀▀▀ █   ▀▀▀▀  ▀▀▀▀ ▀▀▀   ▀▀ ▐▀ ▀▌ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Generate a GUI-based message box that does not interrupt script operation.
;
; @version 1.1.2
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/GUIs/GuiMsgBox.ahk
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

class GuiMsgBox extends AhkGui
{
	__New( guiMsg, guiName := "Default", guiTitle := "", okBtnHandler := "HandleGuiMsgBoxOk" ) {
		global checkType
		global execDelayer
		global scriptCfg
		base.__New( scriptCfg.guiThemes.cfgSettings[ 1 ], checkType, execDelayer, "MsgBox", guiName, guiTitle )
		this.msg := guiMsg
		this.okBtnHandler := new GuiControlHandler( okBtnHandler, this )
	}

	ShowGui() {
		; Set the default variable declaration mode to global so that GUI control variables receive
		;   global scope.
		global

		; Since we are working in global variable declaration mode, create the local variables that
		;   will be needed to set up and lay out the controls of the GUI.
		local guiType := this.type
		local guiName := this.name
		local guiCallback := this.okBtnHandler.handlerRef
		local guiW := 480
		local okBtnW := 80
		local okBtnX
		local okBtnSp := 16
		local scrlW
		local guiX

		; Center the OK button at the bottom of the GUI control.
		SysGet, scrlW, 2 ; The numeric value of SM_CXVSCROLL is 2.
		okBtnX := guiW / 2 - okBtnW / 2 + scrlW / 2

		; Create the GUI implementing a message box and apply the default styling theme.
		Gui, ahkGui%guiType%%guiName%: New, , % this.title
		this.ApplyTheme()

		; Add controls to the GUI consisting of the message and OK button.
		Gui, ahkGui%guiType%%guiName%: Add, Text, w%guiW% y16, % this.msg
		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%Ok%guiName% Default w%okBtnW% x%okBtnX% Y+%okBtnSp%, % "&Ok"
		
		; Assign a callback function to the OK button that will handle user interaction.
		GuiControl, +g, ahkGui%guiType%Ok%guiName%, %guiCallback%
		
		; Display the GUI to the user.
		this.SetGuiOrigin( guiW, 0 )
		guiX := this.originX
		Gui, ahkGui%guiType%%guiName%: Show, X%guiX%
	}
}

HandleGuiMsgBoxOk( args* ) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}
