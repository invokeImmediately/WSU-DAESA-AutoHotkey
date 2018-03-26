; ==================================================================================================
; AHK SCRIPT FOR MODIFYING THE BEHAVIOR OF NUMPAD KEYS
; ==================================================================================================
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

NumpadDiv::
	if (bitNumpadDivToggle) {
		SendInput, % numpadDivOverwrite
	}
	else {
		SendInput, /
	}
Return

^NumpadDiv::
	Gosub :*:@toggleNumpadDiv
Return

^+NumpadDiv::
	Gosub :*:@changeNumpadDiv
Return

:*:@toggleNumpadDiv::
	AppendAhkCmd(":*:@toggleNumpadDiv")
	toggleMsg := "The NumPad / key has been toggled to "
	bitNumpadDivToggle := !bitNumpadDivToggle
	if (bitNumpadDivToggle) {
		toggleMsg .= numpadDivOverwrite
	} else {
		toggleMsg .=  "/"
	}
	MsgBox, % (0x0 + 0x40)
		, % "@toggleNumpadDiv: NumPad / Toggled"
		, % toggleMsg
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

NumpadSub::
	if (bitNumpadSubToggle) {
		SendInput, % numpadSubOverwrite
	}
	else {
		SendInput, -
	}
Return

^NumpadSub::
	Gosub :*:@toggleNumpadSub
Return

^+NumpadSub::
	Gosub :*:@changeNumpadSub
Return

:*:@toggleNumpadSub::
	AppendAhkCmd(":*:@toggleNumpadSub")
	toggleMsg := "The NumPad- key has been toggled to "
	bitNumpadSubToggle := !bitNumpadSubToggle
	if (bitNumpadSubToggle) {
		toggleMsg .= numpadSubOverwrite
	} else {
		toggleMsg .=  "-"
	}
	MsgBox, % (0x0 + 0x40)
		, % "@toggleNumpadSub: NumPad- Toggled"
		, % toggleMsg
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^!NumpadDel::
	Gosub, :*:@toggleNpBoxArt
Return

:*:@toggleNpBoxArt::
	HandleToggleNpBoxArt()
Return

HandleToggleNpBoxArt() {
	global npBoxArtActive
	if (npBoxArtActive) {
		npBoxArtActive := False
	} else {
		npBoxArtActive := True
	}
}

Numpad7::
	HandleNumpad7()
Return

HandleNumpad7() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "┌"
	} else {
		SendInput, % "7"
	}
}

Numpad8::
	HandleNumpad8()
Return

HandleNumpad8() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "─"
	} else {
		SendInput, % "8"
	}
}

Numpad9::
	HandleNumpad9()
Return

HandleNumpad9() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "┐"
	} else {
		SendInput, % "9"
	}
}

Numpad4::
	HandleNumpad4()
Return

HandleNumpad4() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "│"
	} else {
		SendInput, % "4"
	}
}

Numpad5::
	HandleNumpad5()
Return

HandleNumpad5() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "├"
	} else {
		SendInput, % "5"
	}
}

Numpad6::
	HandleNumpad6()
Return

HandleNumpad6() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "┤"
	} else {
		SendInput, % "6"
	}
}

Numpad1::
	HandleNumpad1()
Return

HandleNumpad1() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "└"
	} else {
		SendInput, % "1"
	}
}

Numpad2::
	HandleNumpad2()
Return

HandleNumpad2() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "┬"
	} else {
		SendInput, % "2"
	}
}

Numpad3::
	HandleNumpad3()
Return

HandleNumpad3() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "┘"
	} else {
		SendInput, % "3"
	}
}

Numpad0::
	HandleNumpad0()
Return

HandleNumpad0() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "┴"
	} else {
		SendInput, % "0"
	}
}

NumpadDot::
	HandleNumpadDot()
Return

HandleNumpadDot() {
	global npBoxArtActive
	if (npBoxArtActive) {
		SendInput, % "┼"
	} else {
		SendInput, % "."
	}
}
