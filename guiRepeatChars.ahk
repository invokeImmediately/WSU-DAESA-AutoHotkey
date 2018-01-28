:*:@rptChars::
	AppendAhkCmd(A_ThisLabel)
	CreateRptCharsGui()
Return

CreateRptCharsGui() {
	global
	Gui, guiRptChars: New, , % "Repeat Character N Times"
	Gui, guiRptChars: Add, Text, , % "Character to Repeat:"
	Gui, guiRptChars: Add, Edit, vguiRptChars_WhichChar gHandleGuiRptCharsWhichCharChanged x+5
	Gui, guiRptChars: Add, Text, xm, % "Number of Times:"
	Gui, guiRptChars: Add, Edit, vguiRptChars_HowMany gHandleGuiRptCharsHowManyChanged x+5
	Gui, guiRptChars: Add, Button, gHandleGuiRptCharsOk Default xm y+12, % "&Ok"
	Gui, guiRptChars: Add, Button, gHandleGuiRptCharsCancel x+5, % "&Cancel"
	Gui, guiRptChars: Show
}

HandleGuiRptCharsWhichCharChanged() {
	global
	local newInput

	Gui, guiRptChars:Submit, NoHide
	if (RegExMatch(guiRptChars_WhichChar, "^..+")) {
		newInput := RegExReplace(guiRptChars_WhichChar, "^(.).*$", "$1")
		GuiControl, , guiRptChars_WhichChar, %newInput%
	}
}

HandleGuiRptCharsHowManyChanged() {
	global
	local newInput

	Gui, guiRptChars:Submit, NoHide
	if (RegExMatch(guiRptChars_HowMany, "[^0-9]")) {
		newInput := RegExReplace(guiRptChars_HowMany, "[^0-9]")
		GuiControl, , guiRptChars_HowMany, %newInput%		
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

