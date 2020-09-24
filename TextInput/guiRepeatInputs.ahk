; ==================================================================================================
; guiRepeatInputs.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Creates a GUI that enables the user to repeat a specified character a set number of
; times.
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
; --------------------------------------------------------------------------------------------------
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

:*:@rptInputs::
	AppendAhkCmd(A_ThisLabel)
	CreateRptInputsGui()
Return

^!i::
	Gosub :*:@rptInputs
Return

CreateRptInputsGui() {
	global
	local settings := GetRptInputsGuiSettings()

	Gui, guiRptInputs: New, , % "Repeat Input via Send N Times"
	Gui, guiRptInputs: Add, Text, , % "AHK &Input String to Repeat:"
	Gui, guiRptInputs: Add, Edit, vguiRptInputs_InputStr gHandleGuiRptInputsInputStrChanged x+5 w256, % settings.lastInputStr
	Gui, guiRptInputs: Add, Text, xm, % "Number of &Times:"
	Gui, guiRptInputs: Add, Edit, vguiRptInputs_HowMany gHandleGuiRptInputsHowManyChanged x+5 w30, % settings.lastNumTimes
	Gui, guiRptInputs: Add, Text, xm, % "Key &Delay:"
	Gui, guiRptInputs: Add, Edit, vguiRptInputs_KeyDelay gHandleGuiRptInputsKeyDelayChanged x+5 w30, % settings.keyDelay
	Gui, guiRptInputs: Add, Button, gHandleGuiRptInputsOk Default xm y+12, % "&Ok"
	Gui, guiRptInputs: Add, Button, gHandleGuiRptInputsCancel x+5, % "&Cancel"
	Gui, guiRptInputs: Show
}

GetRptInputsGuiSettings() {
	global rptInputsGuiSettings
	if (!IsObject(rptInputsGuiSettings)) {
		rptInputsGuiSettings := {}
		rptInputsGuiSettings.lastInputStr := ""
		rptInputsGuiSettings.lastNumTimes := ""
		rptInputsGuiSettings.keyDelay := 40 ; i.e., 100 WPM typing speed with 5 character words
	}
	return rptInputsGuiSettings
}

HandleGuiRptInputsInputStrChanged() {
	global
	local settings := GetRptInputsGuiSettings()

	Gui, guiRptInputs:Submit, NoHide
	settings.lastInputStr := guiRptInputs_InputStr		
}

HandleGuiRptInputsHowManyChanged() {
	global
	local newInput
	local settings := GetRptInputsGuiSettings()

	Gui, guiRptInputs:Submit, NoHide
	if (RegExMatch(guiRptInputs_HowMany, "[^0-9]")) {
		newInput := RegExReplace(guiRptInputs_HowMany, "[^0-9]")
		GuiControl, , guiRptInputs_HowMany, %newInput%
		settings.lastNumTimes := newInput
	} else {
		settings.lastNumTimes := guiRptInputs_HowMany
	}
}

HandleGuiRptInputsKeyDelayChanged() {
	global
	local newInput
	local settings := GetRptInputsGuiSettings()

	Gui, guiRptInputs:Submit, NoHide
	if (RegExMatch(guiRptInputs_KeyDelay, "[^0-9]")) {
		newInput := RegExReplace(guiRptInputs_KeyDelay, "[^0-9]")
		GuiControl, , guiRptInputs_KeyDelay, %newInput%
		settings.keyDelay := newInput
	} else {
		settings.keyDelay := guiRptInputs_KeyDelay
	}
}

HandleGuiRptInputsOk() {
	global
	local settings := GetRptInputsGuiSettings()
	local ctr := 0
	local keyDelayChanged := False
	local oldKeyDelay

	Gui guiRptInputs:Submit, NoHide
	if (guiRptInputs_InputStr && guiRptInputs_HowMany && guiRptInputs_KeyDelay) {
		Gui guiRptInputs:Destroy
		if (A_KeyDelay != guiRptInputs_KeyDelay) {
			keyDelayChanged := True
			oldKeyDelay := A_KeyDelay
			SetKeyDelay % guiRptInputs_KeyDelay
		}
		while (ctr < guiRptInputs_HowMany) {
			Send % guiRptInputs_InputStr
			Sleep % guiRptInputs_KeyDelay
			ctr++
		}
		if (keyDelayChanged) {
			SetKeyDelay % oldKeyDelay
		}
	} else {
		ErrorBox(A_ThisLabel, "Input must be finished before I can proceed.")
	}
}

HandleGuiRptInputsCancel() {
	Gui, guiRptInputs:Destroy
}
