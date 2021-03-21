; ==================================================================================================
; █▀▀▀ █  █ ▀█▀ ▄▀▀▀ █▀▀▄ █    ▄▀▀▄ ▄▀▀▀ █  █▐▀█▀▌█▀▀▀▐▄ ▄▌▐▀█▀▌  ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀▄ █  █  █  ▀▀▀█ █▄▄▀ █  ▄ █▄▄█ ▀▀▀█ █▀▀█  █  █▀▀   █    █    █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀  ▀▀  ▀▀▀ ▀▀▀  █    ▀▀▀  █  ▀ ▀▀▀  █  ▀  █  ▀▀▀▀▐▀ ▀▌  █  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Generate a GUI-based splash text box.
;
; @version 1.0.0-alpha.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/master/GUIs/guiMsgBox.ahk
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

class GuiSplashText extends AhkGui
{
	__New( guiMsg, dispTime ) {
		global checkType
		global execDelayer
		base.__New( checkType, execDelayer, "SplashText", "Default", A_ScriptName )
		this.msg := guiMsg
		this.dispTime := dispTime
	}

	ShowGui() {
		global
		local guiType := this.type
		local guiName := this.name
		Gui, gui%guiType%%guiName%: New, , % this.title
		this.ApplyTheme()
		Gui, gui%guiType%%guiName%: Add, Text, w320, % this.msg
		Gui, gui%guiType%%guiName%: Show, NoActivate
		SetTimer, DismissGuiSplashText, % -1 * this.dispTime
	}

	CloseGui() {
		guiType := this.type
		guiName := this.name
		Gui, gui%guiType%%guiName%: Destroy
	}
}

DismissGuiSplashText() {
	Gui, guiSplashTextDefault: Destroy
}
