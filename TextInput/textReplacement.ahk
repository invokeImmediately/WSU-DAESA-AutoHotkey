; ==================================================================================================
; textReplacement.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: An assortment of text replacement hotstrings.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2020 Daniel C. Rieck.
;
;   Permission to use, copy, modify, and/or distribute this software for any purpose with or
;   without fee is hereby granted, provided that the above copyright notice and this permission
;   notice appear in all copies.
;
;   THE SOFTWARE IS PROVIDED "AS IS" AND DANIEL C. RIECK DISCLAIMS ALL WARRANTIES WITH REGARD TO
;   THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
;   DANIEL C. RIECK BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
;   DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
;   CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;   PERFORMANCE OF THIS SOFTWARE.
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: GENERAL text editing hotstrings.........................................................39
;   §2: FRONT-END web development...............................................................58
;     >>> §2.1: HTML editing....................................................................62
;     >>> §2.2: CSS editing.....................................................................69
;     >>> §2.3: JS editing......................................................................77
;   §3: NUMPAD mediated text insertion..........................................................82
;     >>> §3.1: GetCmdForMoveToCSSFolder........................................................86
;     >>> §3.2: GetCmdForMoveToCSSFolder.......................................................104
;   §4: DATES and TIMES........................................................................122
;     >>> §4.1: Dates..........................................................................126
;     >>> §4.2: Times..........................................................................154
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GENERAL text editing hotstrings
; --------------------------------------------------------------------------------------------------

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

; --------------------------------------------------------------------------------------------------
;   §2: FRONT-END web development
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: HTML editing

:*:@addClass::class=""{Space}{Left 2}

:*:@addNrml::{Space}class="oue-normal"

;   ································································································
;     >>> §2.2: CSS editing

:*:@doRGBa::
	AppendAhkCmd(A_ThisLabel)
	SendInput, rgba(@rval, @gval, @bval, );{Left 2}
Return

;   ································································································
;     >>> §2.3: JS editing

:R*:@findStrFnctns::^[^{\r\n]+{$\r\n(?:^(?<!\}).+$\r\n)+^\}$

; --------------------------------------------------------------------------------------------------
;   §3: NUMPAD mediated text insertion
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: @changeNumpadDiv

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
;     >>> §3.2: @changeNumpadSub

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
;   §4: DATES and TIMES
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §4.1: Dates

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
;     >>> §4.2: Times

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
