; ==================================================================================================
; ▀█▀ █▀▀ █ █ ▀█▀ █▀█ █▀▀ █▀█ ▀█  █▀█ █▀▀ █▀▀ █▀▄▀█ █▀▀ █▀▀▄ ▀█▀  █▀█ █ █ █ ▄▀ 
;  █  █▀▀ ▄▀▄  █  █▄▀ █▀▀ █▄█  █  █▄█ █   █▀▀ █ ▀ █ █▀▀ █  █  █   █▄█ █▀█ █▀▄  
;  ▀  ▀▀▀ ▀ ▀  ▀  ▀ ▀▄▀▀▀ █   ▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀   ▀ ▀▀▀ ▀  ▀  ▀ ▀ ▀ ▀ ▀ ▀ ▀  ▀▄
; --------------------------------------------------------------------------------------------------
; An assortment of text replacement hotkeys and hotstrings.
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey
; @license: MIT Copyright (c) 2020 Daniel C. Rieck.
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
; TABLE OF CONTENTS:
; -----------------
;   §1: GENERAL text editing....................................................................51
;     >>> §1.1: Hotstrings......................................................................55
;     >>> §1.2: Hotkeys.........................................................................73
;       →→→ §1.2.1: Insertion of non-breaking spaces............................................76
;   §2: VIM-STYLE keyboard modifications........................................................83
;     >>> §2.1: VIMy Mode: Persistent VIM-style cursor movement.................................87
;     >>> §2.2: Hotkeys for VIM-styled directional cursor movement not requring VIMy mode.......92
;       →→→ §2.1.1: VIMy mode toggle...........................................................108
;       →→→ §2.1.2: VIMy mode hotkey handler...................................................123
;       →→→ §2.1.3: Word based cursor movement hotkeys.........................................142
;       →→→ §2.1.4: Directionally based cursor movement hotkeys................................161
;   §3: FRONT-END web development..............................................................180
;     >>> §3.1: HTML editing...................................................................184
;     >>> §3.2: CSS editing....................................................................191
;     >>> §3.3: JS editing.....................................................................199
;   §4: NUMPAD mediated text insertion.........................................................204
;     >>> §4.1: GetCmdForMoveToCSSFolder.......................................................208
;     >>> §4.2: GetCmdForMoveToCSSFolder.......................................................226
;   §5: DATES and TIMES........................................................................244
;     >>> §5.1: Dates..........................................................................248
;     >>> §5.2: Times..........................................................................276
;   §6: CLIPBOARD modifying hotstrings.........................................................310
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GENERAL text editing hotstrings
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: Hotstrings

:*:@a5lh::
	AppendAhkCmd(A_ThisLabel)
	SendInput, {Enter 5}
Return

:*:@ppp::
	AppendAhkCmd(A_ThisLabel)
	SendInput, news-events_events_.html{Left 5}
Return

:*:@shrug::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "¯\_(·_·)_/¯"
Return

;   ································································································
;     >>> §1.2: Hotkeys

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.1: Insertion of non-breaking spaces

>^>!Space::
	SendInput, % " "
Return

; --------------------------------------------------------------------------------------------------
;   §2: VIM-STYLE keyboard modifications
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: VIMy Mode: Persistent VIM-style cursor movement

; @todo Add timer-based deactivation of VIM-style cursor movement state.

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.1: VIMy mode toggle

>+CapsLock::
	ToggleVimyMode()
Return

ToggleVimyMode() {
	global execDelayer
	global g_vimyModeActive
	g_vimyModeActive := !g_vimyModeActive
	vimyModeState := g_vimyModeActive ? "on" : "off"
	DisplaySplashText( "VIM-style cursor movement mode toggled to " . vimyModeState, 500 )
	execDelayer.Wait( 500 )
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.2: VIMy mode hotkey handler

HandleVimyKey( vimyModeOnKey, vimyModeOffKey ) {
	global execDelayer
	global g_vimyModeActive
	if ( g_vimyModeActive ) {
		SendInput % vimyModeOnKey
	} else {
		Suspend, On
		SendInput % vimyModeOffKey
		Suspend, Off
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.3: Word based cursor movement hotkeys

n::
	HandleVimyKey( "^{Left}", "n" )
Return

m::
	HandleVimyKey( "^{Right}{Right}^{Right}^{Left}", "m" )
Return

y::
	HandleVimyKey( "^{Left}{Left}^{Left}^{Right}", "y" )
Return

u::
	HandleVimyKey( "^{Right}", "u" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.4: Directionally based cursor movement hotkeys

j::
	HandleVimyKey( "{Left}", "j" )
Return

i::
	HandleVimyKey( "{Up}", "i" )
Return

k::
	HandleVimyKey( "{Down}", "k" )
Return

l::
	HandleVimyKey( "{Right}", "l" )
Return

;   ································································································
;     >>> §2.2: Hotkeys for VIM-styled directional cursor movement not requring VIMy mode

^#j::
	SendInput {Left}
Return

^#i::
	SendInput {Up}
Return

^#k::
	SendInput {Down}
Return

^#l::
	SendInput {Right}
Return

; --------------------------------------------------------------------------------------------------
;   §3: FRONT-END web development
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: HTML editing

:*:@addClass::class=""{Space}{Left 2}

:*:@addNrml::{Space}class="oue-normal"

;   ································································································
;     >>> §3.2: CSS editing

:*:@doRGBa::
	AppendAhkCmd(A_ThisLabel)
	SendInput, rgba(@rval, @gval, @bval, );{Left 2}
Return

;   ································································································
;     >>> §3.3: JS editing

:R*:@findStrFnctns::^[^{\r\n]+{$\r\n(?:^(?<!\}).+$\r\n)+^\}$

; --------------------------------------------------------------------------------------------------
;   §4: NUMPAD mediated text insertion
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §4.1: @changeNumpadDiv

:*:@changeNumpadDiv::
	AppendAhkCmd(A_ThisLabel)
	Inputbox, inputEntered
		, % "@changeNumpadDiv: Change Numpad / Overwrite"
		, % "Enter a character/string that the Numpad- key will now represent once alternative "
		. "input is toggled on."
	if (!ErrorLevel) {
		numpadDivOverwrite := inputEntered
	} else {
		MsgBox, % (0x0 + 0x40)
			, % "@changeNumpadDiv: Numpad / Overwrite Canceled"
			, % "Alternative input for Numpad / will remain as " . numpadDivOverwrite
	}
Return

;   ································································································
;     >>> §4.2: @changeNumpadSub

:*:@changeNumpadSub::
	AppendAhkCmd(A_ThisLabel)
	Inputbox, inputEntered
		, % "@changeNumpadSub: Change Numpad- Overwrite"
		, % "Enter a character/string that the Numpad- key will now represent once alternative "
		. "input is toggled on."
	if (!ErrorLevel) {
		numpadSubOverwrite := inputEntered
	} else {
		MsgBox, % (0x0 + 0x40)
			, % "@changeNumpadSub: Numpad- Overwrite Canceled"
			, % "Alternative input for Numpad- will remain as " . numpadSubOverwrite
	}
Return

; --------------------------------------------------------------------------------------------------
;   §5: DATES and TIMES
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: Dates

:*:@datetime::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDateTime, , yyyy-MM-dd HH:mm:ss
	SendInput, %currentDateTime%
Return

:*:@ddd::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDate, , yyyy-MM-dd
	SendInput, %currentDate%
Return

:*:@dtfn::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDateTime, , yyyy-MM-dd_HH:mm:ss
	updatedDateTime := StrReplace( currentDateTime, ":", "⋮" )
	SendInput, %updatedDateTime%
Return

:*:@mdys::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDate, , MM/dd/yyyy
	SendInput, %currentDate%
Return

;   ································································································
;     >>> §5.2: Times

:*:@ttt::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentTime, , HH-mm-ss
	SendInput, %currentTime%
Return

:*:@ttc::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentTime, , HH:mm:ss
	SendInput, %currentTime%
Return

:*:@ttfn::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentTime, , HH:mm:ss
	updatedTime := StrReplace( currentTime, ":", "⋮" )
	SendInput, % updatedTime
Return

:*:@xccc::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDate,, yyyy-MM-dd
	SendInput, / Completed %currentDate%
Return

:*:@xsss::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, (Started %CurrentDateTime%)
Return

; --------------------------------------------------------------------------------------------------
;   §6: CLIPBOARD modifying hotstrings
; --------------------------------------------------------------------------------------------------

:*:@reverseBackSlashes::
	AppendAhkCmd( A_ThisLabel )
	oldText := Clipboard
	execDelayer.Wait( "s" )
	newText := RegExReplace( Clipboard, "\\", "/" )
	execDelayer.Wait( "s" )
	Clipboard := newText
	execDelayer.Wait( "s" )
	DisplaySplashText( "Text in the clipboard has been modified such that back slashes have been "
	 . "reversed.", 3000 )
Return

:*:@reverseFwdSlashes::
	AppendAhkCmd( A_ThisLabel )
	oldText := Clipboard
	execDelayer.Wait( "s" )
	newText := RegExReplace( Clipboard, "/", "\" )
	execDelayer.Wait( "s" )
	Clipboard := newText
	execDelayer.Wait( "s" )
	DisplaySplashText( "Text in the clipboard has been modified such that foward slashes have been "
	 . "reversed.", 3000 )
Return

:*:@convertUrlToFileName::
	AppendAhkCmd( A_ThisLabel )
	oldText := Clipboard
	execDelayer.Wait( "s" )
	newText := RegExReplace( Clipboard, "/", "❘" )
	execDelayer.Wait( "s" )
	newText := RegExReplace( newText, "\.", "·" )
	execDelayer.Wait( "s" )
	newText := RegExReplace( newText, ":", "⋮" )
	execDelayer.Wait( "s" )
	Clipboard := newText
	execDelayer.Wait( "s" )
	DisplaySplashText( "Text in the clipboard has been modified such that colons have been "
	 . "replaced with vertical ellipses, foward slashes have been replaced with vertical bars, "
	 . "and periods have been replaced with middle dots.", 3000 )
Return
