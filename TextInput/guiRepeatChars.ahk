;===================================================================================================
; █▀▀▀ █  █ ▀█▀ █▀▀▄ █▀▀▀ █▀▀▄ █▀▀▀ ▄▀▀▄▐▀█▀▌▄▀▀▀ █  █ ▄▀▀▄ █▀▀▄ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀▄ █  █  █  █▄▄▀ █▀▀  █▄▄▀ █▀▀  █▄▄█  █  █    █▀▀█ █▄▄█ █▄▄▀ ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀  ▀▀  ▀▀▀ ▀  ▀▄▀▀▀▀ █    ▀▀▀▀ █  ▀  █   ▀▀▀ █  ▀ █  ▀ ▀  ▀▄▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; GUI for repeating the input of a character a set number of times at a specified rate.
;
; @version 1.0.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/TextInput/guiRepeatChars
;   .ahk
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

:*?:@rptChars::
	AppendAhkCmd(A_ThisLabel)
	CreateRptCharsGui()
Return

CreateRptCharsGui() {
	global
	local settings := GetRptCharsGuiSettings()

	Gui, guiRptChars: New, , % "Repeat Character N Times"
	Gui, guiRptChars: Add, Text, , % "Character to Repeat:"
	Gui, guiRptChars: Add, Edit, vguiRptChars_WhichChar gHandleGuiRptCharsWhichCharChanged x+5, % settings.lastChar
	Gui, guiRptChars: Add, Text, xm, % "Number of Times:"
	Gui, guiRptChars: Add, Edit, vguiRptChars_HowMany gHandleGuiRptCharsHowManyChanged x+5, % settings.lastNumTimes
	Gui, guiRptChars: Add, Button, gHandleGuiRptCharsOk Default xm y+12, % "&Ok"
	Gui, guiRptChars: Add, Button, gHandleGuiRptCharsCancel x+5, % "&Cancel"
	Gui, guiRptChars: Show
}

GetRptCharsGuiSettings() {
	global rptCharsGuiSettings
	if (!IsObject(rptCharsGuiSettings)) {
		rptCharsGuiSettings := {}
		rptCharsGuiSettings.lastChar := ""
		rptCharsGuiSettings.lastNumTimes := ""
	}
	return rptCharsGuiSettings
}

HandleGuiRptCharsWhichCharChanged() {
	global
	local newInput
	local settings := GetRptCharsGuiSettings()

	Gui, guiRptChars:Submit, NoHide
	if (RegExMatch(guiRptChars_WhichChar, "^..+")) {
		newInput := RegExReplace(guiRptChars_WhichChar, "^(.).*$", "$1")
		GuiControl, , guiRptChars_WhichChar, %newInput%
		settings.lastChar := newInput
	} else {
		settings.lastChar := guiRptChars_WhichChar		
	}
}

HandleGuiRptCharsHowManyChanged() {
	global
	local newInput
	local settings := GetRptCharsGuiSettings()

	Gui, guiRptChars:Submit, NoHide
	if (RegExMatch(guiRptChars_HowMany, "[^0-9]")) {
		newInput := RegExReplace(guiRptChars_HowMany, "[^0-9]")
		GuiControl, , guiRptChars_HowMany, %newInput%
		settings.lastNumTimes := newInput
	} else {
		settings.lastNumTimes := guiRptChars_HowMany		
	}
}

HandleGuiRptCharsOk() {
	global

	Gui, guiRptChars:Submit, NoHide
	if (guiRptChars_WhichChar && guiRptChars_HowMany) {
		Gui, guiRptChars:Destroy
		if (guiRptChars_WhichChar == " ") {
			guiRptChars_WhichChar := "Space"
		}
		SendInput, % "{" . guiRptChars_WhichChar . " " . guiRptChars_HowMany . "}"
	} else {
		ErrorBox(A_ThisLabel, "Input must be finished before I can proceed.")
	}
}

HandleGuiRptCharsCancel() {
	Gui, guiRptChars:Destroy
}

