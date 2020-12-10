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
;   §1: GENERAL text editing....................................................................50
;     >>> §1.1: Hotstrings......................................................................54
;     >>> §1.2: Hotkeys.........................................................................72
;       →→→ §1.2.1: Insertion of non-breaking spaces............................................75
;   §2: VIM-STYLE keyboard modifications........................................................82
;     >>> §2.1: Word based cursor movement hotkeys..............................................86
;     >>> §2.2: Directionally based cursor movement hotkeys....................................105
;     >>> §2.3: Character and word deletion and process termination hotkeys....................200
;   §3: FRONT-END web development..............................................................232
;     >>> §3.1: HTML editing...................................................................236
;     >>> §3.2: CSS editing....................................................................243
;     >>> §3.3: JS editing.....................................................................251
;   §4: NUMPAD mediated text insertion.........................................................256
;     >>> §4.1: GetCmdForMoveToCSSFolder.......................................................260
;     >>> §4.2: GetCmdForMoveToCSSFolder.......................................................278
;   §5: DATES and TIMES........................................................................296
;     >>> §5.1: Dates..........................................................................300
;     >>> §5.2: Times..........................................................................328
;   §6: CLIPBOARD modifying hotstrings.........................................................362
;     >>> §6.1: Slash character reversal.......................................................366
;     >>> §6.2: URL to Windows file name conversion............................................393
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
;     >>> §2.1: Word based cursor movement hotkeys

; Move the cursor to beginning of the previous word at its left.
SC027 & n::
CapsLock & n::SendInput % "^{Left}"

; Move the cursor to beginning of the next word at its right.
SC027 & m::
CapsLock & m::SendInput % "^{Right}{Right}^{Right}^{Left}"

; Move the cursor to end of the previous word at its left.
SC027 & y::
CapsLock & y::SendInput % "^{Left}{Left}^{Left}^{Right}"

; Move the cursor to end of the next word at its right.
SC027 & u::
CapsLock & u::SendInput % "^{Right}"

;   ································································································
;     >>> §2.2: Directionally based cursor movement hotkeys

; Move Left
SC027 & j::
CapsLock & j::SendInput % "{Left}"

#If ( ( GetKeyState( "LShift", "P" ) || GetKeyState( "RShift", "P" ) ) && !( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ))
SC027 & j::
CapsLock & j::SendInput % "+{Left}"

#If ( ( GetKeyState( "LShift", "P" ) || GetKeyState( "RShift", "P" ) ) && ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ) )
SC027 & j::
CapsLock & j::SendInput % "+{Home}"

#If ( ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ) && !( GetKeyState( "LCtrl", "P" ) || GetKeyState( "RCtrl", "P" ) ) )
SC027 & j::
CapsLock & j::SendInput % "{Home}"

#If ( ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ) && ( GetKeyState( "LCtrl", "P" ) || GetKeyState( "RCtrl", "P" ) ) )
SC027 & j::
CapsLock & j::SendInput % "^{Home}"

#If

; Move Up
SC027 & i::
CapsLock & i::SendInput % "{Up}"

#If (GetKeyState("LShift", "P") || GetKeyState("RShift", "P"))
SC027 & i::
CapsLock & i::SendInput % "+{Up}"

#If ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) && ( GetKeyState( "LCtrl", "P") || GetKeyState("RCtrl", "P") ) )
SC027 & i::
CapsLock & i::SendInput % "^!{Up}"

#If

; Move Down
SC027 & k::
CapsLock & k::SendInput % "{Down}"

#If (GetKeyState("RShift", "P") || GetKeyState("LShift", "P"))
SC027 & k::
CapsLock & k::SendInput % "+{Down}"

#If ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) && ( GetKeyState( "LCtrl", "P") || GetKeyState("RCtrl", "P") ) )
SC027 & k::
CapsLock & k::SendInput % "^!{Down}"

#If

; Move Right
SC027 & l::
CapsLock & l::SendInput % "{Right}"

#If ( ( GetKeyState( "LShift", "P" ) || GetKeyState( "RShift", "P" ) ) && !( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ))
SC027 & l::
CapsLock & l::SendInput % "+{Right}"

#If ( ( GetKeyState( "LShift", "P" ) || GetKeyState( "RShift", "P" ) ) && ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ))
SC027 & l::
CapsLock & l::SendInput % "+{End}"

#If ( ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ) && !( GetKeyState( "LCtrl", "P" ) || GetKeyState( "RCtrl", "P" ) ) )
SC027 & l::
CapsLock & l::SendInput % "{End}"

#If ( ( GetKeyState( "LAlt", "P" ) || GetKeyState( "RAlt", "P" ) ) && ( GetKeyState( "LCtrl", "P" ) || GetKeyState( "RCtrl", "P" ) ) )
SC027 & l::
CapsLock & l::SendInput % "^{End}"

#If

; Page Up
SC027 & o::
CapsLock & o::SendInput % "{PgUp}"

#If ( GetKeyState( "LCtrl", "P" ) || GetKeyState( "RCtrl", "P" ) )
SC027 & o::
CapsLock & o::SendInput % "^{PgUp}"

#If

; Page Down
SC027 & ,::
CapsLock & ,::SendInput % "{PgDn}"

#If ( GetKeyState( "LCtrl", "P" ) || GetKeyState( "RCtrl", "P" ) )
SC027 & ,::
CapsLock & ,::SendInput % "^{PgDn}"

#If

;   ································································································
;     >>> §2.3: Character and word deletion and process termination hotkeys

; Delete a word to the left of the cursor
CapsLock & a::
SC027 & a::SendInput % "^{Backspace}"

; Delete a character to the left of the cursor
CapsLock & s::
SC027 & s::SendInput % "{Backspace}"

; Delete a character to the right of the cursor
CapsLock & d::
SC027 & d::SendInput % "{Delete}"

; Delete a word to the right of the cursor
Capslock & f::
SC027 & f::SendInput % "^{Delete}"

; Delete a word to the right of the cursor
CapsLock & q::
SC027 & q::SendInput % "{Escape}"

; Trigger undo
SC027 & z::SendInput % "^z"

; Restore native function of the semicolon key
SC027::Send % ";"

; Restore native function of the shift modified semicolon key
+SC027::Send % ":"

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
