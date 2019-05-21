﻿; ==================================================================================================
; AHK SCRIPT FOR MODIFYING THE BEHAVIOR OF NUMPAD KEYS
; ==================================================================================================
; AutoHotkey Send Legend:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: Numpad modification hotkeys.............................................................22
;     >>> §1.1: NumpadDiv.......................................................................26
;     >>> §1.2: NumpadSub.......................................................................68
;     >>> §1.3: NumpadDel......................................................................100
;   §2: Contextual numpad hotkeys..............................................................157
;   §3: Mode persistence timer.................................................................373
;     >>> §3.1: AutomaticCheckForNpModeExpiration..............................................377
;     >>> §3.2: CheckForNpModeExpiration.......................................................389
;     >>> §3.3: TerminateNpModes...............................................................411
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Numpad modification hotkeys
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: NumpadDiv

NumpadDiv::
	HandleNumpadDiv()
Return

HandleNumpadDiv() {
	global npArrowArtActive
	global bitNumpadDivToggle
	if (npArrowArtActive) {
		SendInput, % "✓"
	} else {
		if (bitNumpadDivToggle) {
			SendInput, % numpadDivOverwrite
		}
		else {
			SendInput, /
		}
	}
}

^NumpadDiv::
	Gosub :*:@toggleNumpadDiv
Return

^+NumpadDiv::
	Gosub :*:@changeNumpadDiv
Return

:*:@toggleNumpadDiv::
	AppendAhkCmd(A_ThisLabel)
	toggleMsg := "The NumPad / key has been toggled to "
	bitNumpadDivToggle := !bitNumpadDivToggle
	if (bitNumpadDivToggle) {
		toggleMsg .= numpadDivOverwrite
	} else {
		toggleMsg .=  "/"
	}
	DisplaySplashText(toggleMsg)
Return

;   ································································································
;     >>> §1.2: NumpadSub

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
	AppendAhkCmd(A_ThisLabel)
	toggleMsg := "The NumPad- key has been toggled to "
	bitNumpadSubToggle := !bitNumpadSubToggle
	if (bitNumpadSubToggle) {
		toggleMsg .= numpadSubOverwrite
	} else {
		toggleMsg .=  "-"
	}
	DisplaySplashText(toggleMsg)
Return

;   ································································································
;     >>> §1.3: NumpadDot/Del

^!NumpadDel::
	Gosub, :*:@toggleNpBoxArt
Return

:*:@toggleNpBoxArt::
	HandleToggleNpBoxArt()
Return

HandleToggleNpBoxArt() {
	global npBoxArtActive
	global npArrowArtActive
	global npModeLastUsed

	CheckForNpModeExpiration()
	npArrowArtActive := False
	toggleMsg := "Numpad box art toggled to "
	if (npBoxArtActive) {
		npBoxArtActive := False
		toggleMsg .= "OFF"
	} else {
		npBoxArtActive := True
		toggleMsg .= "ON"
		npModeLastUsed := A_TickCount
	}
	DisplaySplashText(toggleMsg)
}

^!#NumpadDot::
	Gosub, :*:@toggleNpArrowArt
Return

:*:@toggleNpArrowArt::
	HandleToggleNpArrowArt()
Return

HandleToggleNpArrowArt() {
	global npBoxArtActive
	global npArrowArtActive
	global npModeLastUsed

	CheckForNpModeExpiration()
	npBoxArtActive := False
	toggleMsg := "Numpad arrow art toggled to "
	if (npArrowArtActive) {
		npArrowArtActive := False
		toggleMsg .= "OFF"
	} else {
		npArrowArtActive := True
		toggleMsg .= "ON"
		npModeLastUsed := A_TickCount
	}
	DisplaySplashText(toggleMsg)
}

;   ································································································
;     >>> §2: Contextual numpad hotkeys

Numpad7::
	HandleNumpad7()
Return

HandleNumpad7() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "┌"
	} else if (npArrowArtActive) {
		SendInput, % "└"
	} else {
		SendInput, % "7"
	}
}

Numpad8::
	HandleNumpad8()
Return

HandleNumpad8() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "─"
	} else if (npArrowArtActive) {
		SendInput, % "↑"
	} else {
		SendInput, % "8"
	}
}

Numpad9::
	HandleNumpad9()
Return

HandleNumpad9() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "┐"
	} else if (npArrowArtActive) {
		SendInput, % "↱"
	} else {
		SendInput, % "9"
	}
}

Numpad4::
	HandleNumpad4()
Return

HandleNumpad4() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "│"
	} else if (npArrowArtActive) {
		SendInput, % "←"
	} else {
		SendInput, % "4"
	}
}

Numpad5::
	HandleNumpad5()
Return

HandleNumpad5() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "├"
	} else if (npArrowArtActive) {
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
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "┤"
	} else if (npArrowArtActive) {
		SendInput, % "→"
	} else {
		SendInput, % "6"
	}
}

Numpad1::
	HandleNumpad1()
Return

HandleNumpad1() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "└"
	} else if (npArrowArtActive) {
		SendInput, % "─"
	} else {
		SendInput, % "1"
	}
}

Numpad2::
	HandleNumpad2()
Return

HandleNumpad2() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "┬"
	} else if (npArrowArtActive) {
		SendInput, % "↓"
	} else {
		SendInput, % "2"
	}
}

Numpad3::
	HandleNumpad3()
Return

HandleNumpad3() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "┘"
	} else if (npArrowArtActive) {
		SendInput, % "↳"
	} else {
		SendInput, % "3"
	}
}

Numpad0::
	HandleNumpad0()
Return

HandleNumpad0() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "┴"
	} else if (npArrowArtActive) {
		SendInput, % "│"
	} else {
		SendInput, % "0"
	}
}

NumpadDot::
	HandleNumpadDot()
Return

HandleNumpadDot() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npBoxArtActive) {
		SendInput, % "┼"
	} else if (npArrowArtActive) {
		SendInput, % "└"
	} else {
		SendInput, % "."
	}
}

NumpadMult::
	HandleNumpadMult()
Return

HandleNumpadMult() {
	global npArrowArtActive

	CheckForNpModeExpiration()
	if (npArrowArtActive) {
		SendInput, % "•"
	} else {
		SendInput, *
	}
}

; --------------------------------------------------------------------------------------------------
;   §3: Mode persistence timer
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: AutomaticCheckForNpModeExpiration()

AutomaticCheckForNpModeExpiration() {
	global npModeLastUsed
	global npModeExpirationTime

	if (A_TickCount - npModeLastUsed > npModeExpirationTime) {
		TerminateNpModes()
	}
}

;   ································································································
;     >>> §3.2: CheckForNpModeExpiration()

CheckForNpModeExpiration() {
	global npModeLastUsed
	global npModeExpirationTime
	global npModeTimerActive
	global npArrowArtActive
	global npBoxArtActive

	if ( ( npArrowArtActive || npBoxArtActive ) && !npModeTimerActive ) {
		npModeTimerActive := True
		SetTimer AutomaticCheckForNpModeExpiration, 5000
	}
	if ( ( npArrowArtActive || npBoxArtActive )
			&& A_TickCount - npModeLastUsed > npModeExpirationTime ) {
		TerminateNpModes()
	} else {
		npModeLastUsed := A_TickCount
	}
}

;   ································································································
;     >>> §3.3: TerminateNpModes()

TerminateNpModes() {
	global npModeTimerActive
	global npArrowArtActive
	global npBoxArtActive

	npArrowArtActive := False
	npBoxArtActive := False
	npModeTimerActive := False
	SetTimer AutomaticCheckForNpModeExpiration, Off
	DisplaySplashText("Numpad box art automatically disabled after set period of disuse.", 3000)
}
