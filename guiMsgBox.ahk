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
	; __New(string, string, Func object, string)
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
