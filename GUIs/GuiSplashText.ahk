; ==================================================================================================
; █▀▀▀ █  █ ▀█▀ ▄▀▀▀ █▀▀▄ █    ▄▀▀▄ ▄▀▀▀ █  █▐▀█▀▌█▀▀▀▐▄ ▄▌▐▀█▀▌  ▄▀▀▄ █  █ █ ▄▀ 
; █ ▀▄ █  █  █  ▀▀▀█ █▄▄▀ █  ▄ █▄▄█ ▀▀▀█ █▀▀█  █  █▀▀   █    █    █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀  ▀▀  ▀▀▀ ▀▀▀  █    ▀▀▀  █  ▀ ▀▀▀  █  ▀  █  ▀▀▀▀▐▀ ▀▌  █  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Generate a GUI-based splash text box.
;
; @version 1.1.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/GUIs/GuiSplashText.ahk
; @license MIT Copyright (c) 2021 Daniel C. Rieck.
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

class SplashTextMsg {
	__New( msg, maxLen := 70 ) {
		this.maxLen := maxLen
		this.maxLineLen := 0
		this.numLines := 0
		this.msg := this.SplitMsgIntoLines( msg )
	}

	SplitMsgIntoLines( msg ) {
		; Recursively handle the case where the message string already has newlines. Split the message
		;  into two parts around the first newline, dealing with the right-hand portion as a
		;  recursively processed tail.
		foundPos := InStr( msg, "`n")
		if ( foundPos ) {
			msgTail := SubStr(msg, foundPos + 1, StrLen( msg ) - foundPos )
			msg := SubStr( msg, 1, foundPos - 1 )
			msgTail := "`n" . this.SplitMsgIntoLines( msgTail )
		} else {
			msgTail := ""
		}

		; Proceed only if the string is shorter than the maximum length of the line; if so, don't
		;  forget to reattach the recursively processed tail.
		if ( StrLen( msg ) <= this.maxLen ) {
			this.numLines++
			lineLen := StrLen( msg )
			if ( lineLen > this.maxLineLen ) {
				this.maxLineLen := lineLen
			}
			return msg . msgTail
		} else {
			newMsg := ""
		}

		; Since the message string we are working with is longer than the maximum length of a line,
		;  split it add newlines as needed to keep each line under the desired limit, working from
		;  left to right.
		regExNeedle := "Om)^(.*? )([^ ]*)$"
		while ( StrLen( msg ) > this.maxLen ) {
			msgChunkL := SubStr( msg, 1, this.maxLen )
			msgChunkR := SubStr( msg, this.maxLen + 1, StrLen( msg ) - this.maxLen )
			foundPos := RegExMatch( msgChunkL, regExNeedle, matches )
			if ( foundPos ) {

				; Be sure to keep track of which line happens to be the longest.
				lineLen := StrLen( matches[1] )
				if ( lineLen > this.maxLineLen ) {
					this.maxLineLen := lineLen
				}
				this.numLines++
				newMsg .= matches[1] . "`n"
				msg := matches[2] . msgChunkR
			} else {
				lineLen := StrLen( msgChunkL )
				if ( lineLen > this.maxLineLen ) {
					this.maxLineLen := lineLen
				}
				this.numLines++
				newMsg .= msg . "`n"
				msg := msgChunkR
			}
		}
		newMsg .= msg . msgTail
		this.numLines++
		lineLen := StrLen( msg )
		if ( lineLen > this.maxLineLen ) {
			this.maxLineLen := lineLen
		}
		return newMsg
	}
}

class GuiSplashText extends AhkGui
{
	__New( guiMsg, dispTime, waitForMsg ) {
		global checkType
		global execDelayer
		global scriptCfg
		base.__New( scriptCfg.guiThemes.cfgSettings[ 1 ], checkType, execDelayer, "SplashText", "Default", A_ScriptName )
		this.splMsg := new SplashTextMsg(guiMsg)
		this.dispTime := dispTime
		this.waitForMsg := waitForMsg
	}

	ShowGui() {
		global
		local guiX
		local guiY
		local guiType := this.type
		local guiName := this.name
		Gui, ahkGui%guiType%%guiName%: New, , % this.title
		Gui, ahkGui%guiType%%guiName%: +AlwaysOnTop
		this.ApplyTheme()
		Gui, ahkGui%guiType%%guiName%: Add, Text, w512, % this.splMsg.msg
		this.SetGuiOrigin(512, this.splMsg.numLines * 16 * 1.5)
		guiX := this.originX
		guiY := this.originY
		Gui, ahkGui%guiType%%guiName%: Show, X%guiX% Y%guiY% NoActivate
		SetTimer, DismissGuiSplashText, % -1 * this.dispTime
		if ( this.waitForMsg ) {
			this.delayer.Wait( this.dispTime )
		}
	}
}

DismissGuiSplashText() {
	Gui, ahkGuiSplashTextDefault: Destroy
}
