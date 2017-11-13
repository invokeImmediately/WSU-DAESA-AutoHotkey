class GuiMsgBox
{
	msg := ""
	title := ""
	name := ""
	okBtnHandler := undefined

	; __New(string, string, Func object, string)
	__New(guiMsg, okBtnHandler, guiName := "Default", guiTitle := "") {
		if (guiName != "") {
			this.name := guiName
		} else {
			this.name := "Default"
		}
		this.msg := guiMsg
		if (guiTitle != "") {
			this.title := guiTitle
		} else {
			this.title := A_ScriptName
		}
		this.okBtnHandler := okBtnHandler.Bind(this)
	}

	ShowGui() {
		global
		local guiName := this.name
		local guiCallback := this.okBtnHandler
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

HandleGuiMsgBoxOk(args*) {
	guiToClose := args[1]
	guiToClose.CloseGui()
}
