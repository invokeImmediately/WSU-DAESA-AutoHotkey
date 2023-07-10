; ==============================================================================
; ▓▓▓▒ ▐▀▀▄ █  █ ▐▀▄▀▌█▀▀▄ ▄▀▀▄ █▀▀▄ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓
; ▓▓▒▒ █  ▐ █  █ █ ▀ ▌█▄▄▀ █▄▄█ █  █ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓
; ▓▒▒▒ ▀  ▐  ▀▀  █   ▀█    █  ▀ ▀▀▀  Modifier.ahk ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓
; ··············································································
; Provide alternative character entry modes for the keyboard numpad.
;
; @version 1.2.0
;
; @author Daniel Rieck
;  [daniel.rieck@wsu.edu]
;  (https://github.com/invokeImmediately)
;
; @link https://github.com/invokeImmediately/WSU-AutoHotkey/blob/master…
;  …/TextInput/numpadModifier.ahk
;
; @license MIT Copyright (c) 2023 Daniel C. Rieck.
;  Permission is hereby granted, free of charge, to any person obtaining a copy
;   of this software and associated documentation files (the “Software”), to
;   deal in the Software without restriction, including without limitation the
;   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
;   sell copies of the Software, and to permit persons to whom the Software is
;   furnished to do so, subject to the following conditions:
;  The above copyright notice and this permission notice shall be included in
;   all copies or substantial portions of the Software.
;  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
;   IN THE SOFTWARE.
; ==============================================================================
; TABLE OF CONTENTS:
; -----------------
; §1: Numpad modification hotkeys...........................................40
;   §1.1: NumpadDiv.........................................................44
;   §1.2: NumpadSub.........................................................86
;   §1.3: NumpadDel........................................................118
; §2: Contextual numpad hotkeys............................................179
; §3: Mode persistence timer...............................................447
;   §3.1: AutomaticCheckForNpModeExpiration................................451
;   §3.2: CheckForNpModeExpiration.........................................463
;   §3.3: TerminateNpModes.................................................485
; ==============================================================================

; ------------------------------------------------------------------------------
; §1: Numpad modification hotkeys
; ------------------------------------------------------------------------------

;   ············································································
;   §1.1: NumpadDiv

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
	Gosub :*?:@toggleNumpadDiv
Return

^+NumpadDiv::
	Gosub :*?:@changeNumpadDiv
Return

:*?:@toggleNumpadDiv::
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

;   ············································································
;   §1.2: NumpadSub

NumpadSub::
	if (bitNumpadSubToggle) {
		SendInput, % numpadSubOverwrite
	}
	else {
		SendInput, -
	}
Return

^NumpadSub::
	Gosub :*?:@toggleNumpadSub
Return

^+NumpadSub::
	Gosub :*?:@changeNumpadSub
Return

:*?:@toggleNumpadSub::
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

;   ············································································
;   §1.3: NumpadDot/Del

^NumpadDel::
	SendInput % "…"
Return

^!NumpadDel::
	Gosub, :*?:@toggleNpBoxArt
Return

:*?:@toggleNpBoxArt::
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
	Gosub, :*?:@toggleNpArrowArt
Return

:*?:@toggleNpArrowArt::
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

; ------------------------------------------------------------------------------
; §2: Contextual numpad hotkeys
; ------------------------------------------------------------------------------

Numpad7::
	HandleNumpad7()
Return

HandleNumpad7() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "┌"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╔"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↰"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "↖"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "─"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "═"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↑"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "⇑"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "┐"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╗"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↱"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "↗"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "│"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "║"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "←"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "⇐"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "├"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╠"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "⇄"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "⇔"
	} else {
		SendInput, % "5"
	}
}

NumpadClear::
	HandleNumpadClear()
Return

HandleNumpadClear() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "┼"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╬"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↩"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "↪"
	}
}

Numpad6::
	HandleNumpad6()
Return

HandleNumpad6() {
	global npBoxArtActive
	global npArrowArtActive

	CheckForNpModeExpiration()
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "┤"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╣"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "→"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "⇒"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "└"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╚"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↲"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "↙"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "┬"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╦"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↓"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "⇓"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "┘"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╝"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↳"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↘"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "┴"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "╩"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "↴"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "⇅"
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
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if (npBoxArtActive && !capsLockDown) {
		SendInput, % "▒"
	}	else if (npBoxArtActive && capsLockDown) {
		SendInput, % "▓"
	} else if (npArrowArtActive && !capsLockDown) {
		SendInput, % "⇏"
	} else if (npArrowArtActive && capsLockDown) {
		SendInput, % "⇍"
	} else {
		SendInput, % "."
	}
}

NumpadMult::
	HandleNumpadMult()
Return

HandleNumpadMult() {
	global npArrowArtActive
	global npBoxArtActive

	CheckForNpModeExpiration()
	capsLockDown := GetKeyState( "CapsLock", "T" )
	if( npArrowArtActive && !capsLockDown ) {
		SendInput, % "•"
	} else if( npArrowArtActive && capsLockDown ) {
		SendInput, % "✓"
	} else if( npBoxArtActive && !capsLockDown ) {
		SendInput, % "░"
	} else if( npBoxArtActive && capsLockDown ) {
		SendInput, % "█"
	} else {
		SendInput, *
	}
}

; ------------------------------------------------------------------------------
; §3: Mode persistence timer
; ------------------------------------------------------------------------------

;   ············································································
;   §3.1: AutomaticCheckForNpModeExpiration()

AutomaticCheckForNpModeExpiration() {
	global npModeLastUsed
	global npModeExpirationTime

	if (A_TickCount - npModeLastUsed > npModeExpirationTime) {
		TerminateNpModes()
	}
}

;   ············································································
;   §3.2: CheckForNpModeExpiration()

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

;   ············································································
;   §3.3: TerminateNpModes()

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
