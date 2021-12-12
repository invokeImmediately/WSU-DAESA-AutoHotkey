; ==================================================================================================
; ▄▀▀▀▐▀█▀▌▄▀▀▄ █▀▀▄ ▐▀█▀▌█  █ █▀▀▄ █▀▀▀ █  █ ▀█▀   ▄▀▀▄ █  █ █ ▄▀
; ▀▀▀█  █  █▄▄█ █▄▄▀   █  █  █ █▄▄▀ █ ▀▄ █  █  █    █▄▄█ █▀▀█ █▀▄
; ▀▀▀   █  █  ▀ ▀  ▀▄  █   ▀▀  █    ▀▀▀▀  ▀▀  ▀▀▀ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; GUI to be displayed at script startup.
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

class StartupGui extends AhkGui
{
	__New( guiTheme
			, typer
			, delayer
			, guiType := "ScriptStartup"
			, guiName := "Default"
			, guiTitle := "WSU-DAESA-AutoHotkey.U64.ahk"
			, okBtnHdlr := "HandleScriptStartupGuiOk" ) {

		; Call base's constructor.
		base.__New( guiTheme, typer, delayer, guiType, guiName, guiTitle )

		; Set OK button handler
		this.okBtnHandler := new GuiControlHandler( okBtnHdlr, this )
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
		local guiBgW := 1440
		local guiBgH := 810
		local guiBgPicFp := A_ScriptDir . "\Images\wsu-daesa-autohotkey_start-screen_background_v1-0-0.jpg"
		local guiFgW := 773
		local guiFgH := 361
		local guiFgX := guiBgW / 2 - guiFgW / 2
		local guiFgY := guiBgH / 2 - guiFgH / 2
		local guiFgPicFp := A_ScriptDir . "\Images\wsu-daesa-autohotkey_start-screen_messaging_v1-0-0.png"
		local okBtnW := 80
		local okBtnX := guiBgW / 2 - okBtnW / 2
		Local okBtnY := 810 - 32
		local okBtnSp := 16
		local scrlW
		local guiX

		; Create the GUI implementing a message box and apply the default styling theme.
		Gui, ahkGui%guiType%%guiName%: New, , % this.title
		this.ApplyTheme()

		; Add controls to the startup GUI.
		Gui, ahkGui%guiType%%guiName%: Add, Picture
			, w%guiBgW% h%guiBgH% AltSubmit, %guiBgPicFp%

		Gui, ahkGui%guiType%%guiName%: Add, Picture
			, x%guiFgX% y%guiFgY% w%guiFgW% h%guiFgH% AltSubmit +BackgroundTrans, %guiFgPicFp%

		Gui, ahkGui%guiType%%guiName%: Add, Button
			, vahkGui%guiType%Ok%guiName% Default w%okBtnW% x%okBtnX% y%okBtnY%, % "&Ok"
		
		; Assign a callback function to the OK button that will handle user interaction.
		GuiControl, +g, ahkGui%guiType%Ok%guiName%, %guiCallback%
		
		; Display the GUI to the user.
		this.SetGuiOrigin( guiBgW, 0 )
		guiX := this.originX
		Gui, ahkGui%guiType%%guiName%: Show, X%guiX%
	}
}

HandleScriptStartupGuiOk( args* ) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}
