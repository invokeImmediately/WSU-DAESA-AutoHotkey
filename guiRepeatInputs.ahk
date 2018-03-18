:*:@rptInputs::
	AppendAhkCmd(A_ThisLabel)
	CreateRptInputsGui()
Return

CreateRptInputsGui() {
	global
	local settings := GetRptInputsGuiSettings()

	Gui, guiRptInputs: New, , % "Repeat Input via Send N Times"
	Gui, guiRptInputs: Add, Text, , % "AHK Input String to Repeat:"
	Gui, guiRptInputs: Add, Edit, vguiRptInputs_InputStr x+5, % settings.lastInputStr
	Gui, guiRptInputs: Add, Text, xm, % "Number of Times:"
	Gui, guiRptInputs: Add, Edit, vguiRptInputs_HowMany gHandleGuiRptInputsHowManyChanged x+5 w100, % settings.lastNumTimes
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
		rptInputsGuiSettings.keyDelay := 100 ; i.e., 100 WPM typing speed with 5 character words
	}
	return rptInputsGuiSettings
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

HandleGuiRptInputsOk() {
	global
	local settings := GetRptInputsGuiSettings()
	local ctr := 0
	local keyDelayChanged := False
	local oldKeyDelay

	Gui, guiRptInputs:Submit, NoHide
	if (guiRptInputs_InputStr && guiRptInputs_HowMany) {
		Gui, guiRptInputs:Destroy
		if (A_KeyDelay != settings.keyDelay) {
			keyDelayChanged := True
			oldKeyDelay := A_KeyDelay
			SetKeyDelay, % settings.keyDelay
		}
		while (ctr < guiRptInputs_HowMany) {
			Send, % guiRptInputs_InputStr
			Sleep, % settings.keyDelay
			ctr++
		}
		if (keyDelayChanged) {
			SetKeyDelay, % oldKeyDelay
		}
	} else {
		ErrorBox(A_ThisLabel, "Input must be finished before I can proceed.")
	}
}

HandleGuiRptInputsCancel() {
	Gui, guiRptInputs:Destroy
}

