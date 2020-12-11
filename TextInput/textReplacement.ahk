; ==================================================================================================
; ▐▀█▀▌█▀▀▀▐▄ ▄▌▐▀█▀▌█▀▀▄ █▀▀▀ █▀▀▄ █    ▄▀▀▄ █▀▀ █▀▀▀ ▐▀▄▀▌█▀▀▀ ▐▀▀▄▐▀█▀▌  ▄▀▀▄ █  █ █ ▄▀ 
;   █  █▀▀   █    █  █▄▄▀ █▀▀  █▄▄▀ █  ▄ █▄▄█ █   █▀▀  █ ▀ ▌█▀▀  █  ▐  █    █▄▄█ █▀▀█ █▀▄  
;   █  ▀▀▀▀▐▀ ▀▌  █  ▀  ▀▄▀▀▀▀ █    ▀▀▀  █  ▀ ▀▀▀ ▀▀▀▀ █   ▀▀▀▀▀ █  ▐  █  ▀ █  ▀ █  ▀ ▀  ▀▄
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
;     >>> §2.1: Toggle VIMy mode................................................................87
;     >>> §2.2: Word based cursor movement hotkeys.............................................105
;     >>> §2.3: Directionally based cursor movement hotkeys....................................122
;     >>> §2.4: Character and word deletion and process termination hotkeys....................183
;   §3: FRONT-END web development..............................................................206
;     >>> §3.1: HTML editing...................................................................210
;     >>> §3.2: CSS editing....................................................................217
;     >>> §3.3: JS editing.....................................................................225
;   §4: NUMPAD mediated text insertion.........................................................230
;     >>> §4.1: GetCmdForMoveToCSSFolder.......................................................234
;     >>> §4.2: GetCmdForMoveToCSSFolder.......................................................252
;   §5: DATES and TIMES........................................................................270
;     >>> §5.1: Dates..........................................................................274
;     >>> §5.2: Times..........................................................................302
;   §6: CLIPBOARD modifying hotstrings.........................................................336
;     >>> §6.1: Slash character reversal.......................................................340
;     >>> §6.2: URL to Windows file name conversion............................................367
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
;     >>> §2.1: Toggle VIMy mode

CapsLock & SC027::
:*:@toggleVimyMode::
	ToggleVimyMode()
Return

ToggleVimyMode() {
	global execDelayer
	global g_vimyModeActive
	g_vimyModeActive := !g_vimyModeActive
	vimyModeState := g_vimyModeActive ? "on" : "off"
	msgTime := 500
	DisplaySplashText( "VIM-style cursor movement mode toggled to " . vimyModeState, msgTime )
	execDelayer.Wait( msgTime )
}

;   ································································································
;     >>> §2.2: Word based cursor movement hotkeys

#If g_vimyModeActive
; Move the cursor to beginning of the previous word at its left.
n::SendInput % "^{Left}"

; Move the cursor to beginning of the next word at its right.
m::SendInput % "^{Right}{Right}^{Right}^{Left}"

; Move the cursor to end of the previous word at its left.
y::SendInput % "^{Left}{Left}^{Left}^{Right}"

; Move the cursor to end of the next word at its right.
u::SendInput % "^{Right}"
#If

;   ································································································
;     >>> §2.3: Directionally based cursor movement hotkeys

; Move Left
#If g_vimyModeActive
j::SendInput % "{Left}"

+j::SendInput % "+{Left}"

!+j::SendInput % "+{Home}"

!j::SendInput % "{Home}"

^!j::SendInput % "^{Home}"
#If

; Move Up
#If g_vimyModeActive
i::SendInput % "{Up}"

+i::SendInput % "+{Up}"

^!i::SendInput % "^!{Up}"
#If

; Move Down
#If g_vimyModeActive
k::SendInput % "{Down}"

+k::SendInput % "+{Down}"

^!k::SendInput % "^!{Down}"
#If

; Move Right
#If g_vimyModeActive
l::SendInput % "{Right}"

+l::SendInput % "+{Right}"

!+l::SendInput % "+{End}"

!l::SendInput % "{End}"

^!l::SendInput % "^{End}"
#If

; Page Up
#If g_vimyModeActive
o::SendInput % "{PgUp}"

^o::SendInput % "^{PgUp}"
#If

; Page Down
#If g_vimyModeActive
,::SendInput % "{PgDn}"

^,::SendInput % "^{PgDn}"
#If

;   ································································································
;     >>> §2.4: Character and word deletion and process termination hotkeys

#If g_vimyModeActive
; Delete a word to the left of the cursor
a::SendInput % "^{Backspace}"

; Delete a character to the left of the cursor
s::SendInput % "{Backspace}"

; Delete a character to the right of the cursor
d::SendInput % "{Delete}"

; Delete a word to the right of the cursor
f::SendInput % "^{Delete}"

; Delete a word to the right of the cursor
q::SendInput % "{Escape}"

; Trigger undo
z::SendInput % "^z"
#If

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

;   ································································································
;     >>> §6.1: Slash character reversal

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

;   ································································································
;     >>> §6.2: URL to Windows file name conversion

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
