; ==================================================================================================
; ▐▀█▀▌█▀▀▀▐▄ ▄▌▐▀█▀▌█▀▀▄ █▀▀▀ █▀▀▄ █    ▄▀▀▄ █▀▀ █▀▀▀ ▐▀▄▀▌█▀▀▀ ▐▀▀▄▐▀█▀▌  ▄▀▀▄ █  █ █ ▄▀ 
;   █  █▀▀   █    █  █▄▄▀ █▀▀  █▄▄▀ █  ▄ █▄▄█ █   █▀▀  █ ▀ ▌█▀▀  █  ▐  █    █▄▄█ █▀▀█ █▀▄  
;   █  ▀▀▀▀▐▀ ▀▌  █  ▀  ▀▄▀▀▀▀ █    ▀▀▀  █  ▀ ▀▀▀ ▀▀▀▀ █   ▀▀▀▀▀ █  ▐  █  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; An assortment of text replacement hotkeys and hotstrings.
;
; @version 1.0.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/master…→
;   ←…/TextInput/textReplacement.ahk
; @license: MIT Copyright (c) 2021 Daniel C. Rieck.
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
;   §1: GENERAL text editing....................................................................65
;     >>> §1.1: Hotstrings......................................................................69
;     >>> §1.2: Hotkeys.........................................................................87
;       →→→ §1.2.1: Insertion of non-breaking spaces............................................90
;   §2: VIM-STYLE keyboard modifications........................................................97
;     >>> §2.1: VIMy mode toggling.............................................................101
;       →→→ §2.1.1: ToggleVimyMode()...........................................................104
;       →→→ §2.1.2: NotifyUserOfVimyModeState( … ).............................................115
;       →→→ §2.1.3: DestroyVimyModeGui( whichMon ).............................................144
;       →→→ §2.1.4: ShowVimyModeGui( whichMon )................................................153
;       →→→ §2.1.5: Hotkeys for toggling VIMy mode.............................................185
;       →→→ §2.1.6: Semicolon key behavior with VIMy mode engaged..............................194
;       →→→ §2.1.7: Semicolon key behavior with VIMy mode disabled.............................204
;     >>> §2.2: Word based cursor movement hotkeys.............................................215
;     >>> §2.3: Directionally based cursor movement hotkeys....................................240
;     >>> §2.4: Character and word deletion and process termination hotkeys....................325
;   §3: FRONT-END web development..............................................................365
;     >>> §3.1: HTML editing...................................................................369
;     >>> §3.2: CSS editing....................................................................376
;     >>> §3.3: JS editing.....................................................................384
;   §4: NUMPAD mediated text insertion.........................................................389
;     >>> §4.1: GetCmdForMoveToCSSFolder.......................................................393
;     >>> §4.2: GetCmdForMoveToCSSFolder.......................................................411
;   §5: DATES and TIMES........................................................................429
;     >>> §5.1: Dates..........................................................................433
;     >>> §5.2: Times..........................................................................461
;   §6: CLIPBOARD modifying hotstrings.........................................................495
;     >>> §6.1: Slash character reversal.......................................................499
;     >>> §6.2: URL to Windows file name conversion............................................526
;     >>> §6.3: ASCII Text Art.................................................................546
;       →→→ §6.3.1: AsciiArtLetter3h class.....................................................549
;       →→→ §6.3.2: AsciiArtConverter class....................................................562
;       →→→ §6.3.3: @convertCbToAsciiArt hotstring.............................................693
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GENERAL text editing hotstrings
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: Hotstrings

:*?:@a5lh::
	AppendAhkCmd(A_ThisLabel)
	SendInput, {Enter 5}
Return

:*?:@ppp::
	AppendAhkCmd(A_ThisLabel)
	SendInput, news-events_events_.html{Left 5}
Return

:*?:@shrug::
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
;     >>> §2.1: VIMy mode toggling

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.1: ToggleVimyMode()

ToggleVimyMode() {
	global execDelayer
	global g_vimyModeActive
	g_vimyModeActive := !g_vimyModeActive
	vimyModeState := g_vimyModeActive ? "on" : "off"
	NotifyUserOfVimyModeState( vimyModeState )
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.2: NotifyUserOfVimyModeState( … )

NotifyUserOfVimyModeState( vimyModeState)  {

	; We will need the script's global variable storing the number of system monitors.
	global sysNumMonitors

	; For maintainability, specify settings up front in that will be important for the timing of user
	;   notifications and the layout of the GUI.
	msgTime := 500
	guiTransparency := 96

	; Show or dismiss a visual indicator that VIMy mode is engaged.
	if ( vimyModeState == "on" ) {
		Loop %sysNumMonitors% {
			ShowVimyModeGui( A_Index )
		}
	} else {
		Loop %sysNumMonitors% {
			DestroyVimyModeGui( A_Index )
		}
	}

	; Display a splash message.
	DisplaySplashText( "VIM-style cursor movement mode toggled to " . vimyModeState, msgTime )
	execDelayer.Wait( msgTime )
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.†3: DestroyVimyModeGui( whichMon )
DestroyVimyModeGui( whichMon ) {

		; Ensure that the GUI window for the indicated monitor that helps signal to the user VIMy mode
		;   is active is dismissed.
		Gui, GuiVimyModeOn%whichMon%:Destroy
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.†4: ShowVimyModeGui( whichMon )

ShowVimyModeGui( whichMon ) {

	; We will need the script's global variable storing the path to a graphic used to visually signal
	;   that VIMy mode has been engaged.
	global g_VimyModeIconPath

	; Determine the coordinates where the GUI should appear on the indicated monitor.
	guiWidth := 116
	guiXPos := ( mon%whichMon%WorkArea_Right - mon%whichMon%WorkArea_Left ) / 2 - guiWidth / 2
		+ mon%whichMon%WorkArea_Left
	guiYPos := mon%whichMon%WorkArea_Top

	; Create a new GUI window that signals to the user VIMy mode is active.
	Gui, GuiVimyModeOn%whichMon%:New, +AlwaysOnTop -SysMenu +LastFound
		, % "VIMy Mode Engaged"

	; Make the GUI partially transparent so users can see what lies underneath it on the desktop.
	Gui, GuiVimyModeOn%whichMon%:Color, EEAA99
	WinSet, TransColor, EEAA99

	; Set up the content of the GUI.
	Gui, GuiVimyModeOn%whichMon%:Add, Picture, x26 y0, % g_VimyModeIconPath

	; Show the GUI to the user; to help prevent interference with other windows, position the GUI
	;   at the top-center of the primary monitor.
	Gui, GuiVimyModeOn%whichMon%:Show, x%guiXPos% y%guiYPos% w%guiWidth% NoActivate	
}


;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.5: Hotkeys for toggling VIMy mode

SC027 & Space::
!SC027::
:*?:@toggleVimyMode::
	ToggleVimyMode()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.6: Semicolon key behavior with VIMy mode engaged

#If g_vimyModeActive
SC027::
Space::
	ToggleVimyMode()
Return
#If

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.7: Semicolon key behavior with VIMy mode disabled

#If !g_vimyModeActive
SC027::SendInput % ";"

#SC027::SendInput % "#;"

+SC027::SendInput % "+;"
#If

;   ································································································
;     >>> §2.2: Word based cursor movement hotkeys

#If g_vimyModeActive
; Move the cursor to beginning of the previous word at its left.
n::SendInput % "^{Left}"

+n::SendInput % "^+{Left}"

; Move the cursor to beginning of the next word at its right.
m::SendInput % "^{Right}{Right}^{Right}^{Left}"

+m::SendInput % "^+{Right}+{Right}^+{Right}^+{Left}"

; Move the cursor to end of the previous word at its left.
y::SendInput % "^{Left}{Left}^{Left}^{Right}"

+y::SendInput % "^+{Left}+{Left}^+{Left}^+{Right}"

; Move the cursor to end of the next word at its right.
u::SendInput % "^{Right}"

+u::SendInput % "^+{Right}"
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

#If !g_vimyModeActive
SC027 & j::SendInput % "{Left}"
#If

; Move Up
#If g_vimyModeActive
i::SendInput % "{Up}"

+i::SendInput % "+{Up}"

^!i::SendInput % "^!{Up}"
#If

#If !g_vimyModeActive
SC027 & i::SendInput % "{Up}"
#If

; Move Down
#If g_vimyModeActive
k::SendInput % "{Down}"

+k::SendInput % "+{Down}"

^!k::SendInput % "^!{Down}"
#If

#If !g_vimyModeActive
SC027 & k::SendInput % "{Down}"
#If

; Move Right
#If g_vimyModeActive
l::SendInput % "{Right}"

+l::SendInput % "+{Right}"

!+l::SendInput % "+{End}"

!l::SendInput % "{End}"

^!l::SendInput % "^{End}"
#If

#If !g_vimyModeActive
SC027 & l::SendInput % "{Right}"
#If

; Page Up
#If g_vimyModeActive
o::SendInput % "{PgUp}"

^o::SendInput % "^{PgUp}"
#If

#If !g_vimyModeActive
SC027 & o::SendInput % "{PgUp}"
#If

; Page Down
#If g_vimyModeActive
,::SendInput % "{PgDn}"

^,::SendInput % "^{PgDn}"
#If

#If !g_vimyModeActive
SC027 & ,::SendInput % "{PgDown}"
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

; Trigger redo
+z::SendInput % "^y"
#If

#If !g_vimyModeActive
; Delete a word to the left of the cursor
SC027 & a::SendInput % "^{Backspace}"

; Delete a character to the left of the cursor
SC027 & s::SendInput % "{Backspace}"

; Delete a character to the right of the cursor
SC027 & d::SendInput % "{Delete}"

; Delete a word to the right of the cursor
SC027 & f::SendInput % "^{Delete}"
#If

; --------------------------------------------------------------------------------------------------
;   §3: FRONT-END web development
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: HTML editing

:*?:@addClass::class=""{Space}{Left 2}

:*?:@addNrml::{Space}class="oue-normal"

;   ································································································
;     >>> §3.2: CSS editing

:*?:@doRGBa::
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

:*?:@changeNumpadDiv::
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

:*?:@changeNumpadSub::
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

:?*:@datetime::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDateTime, , yyyy-MM-dd HH:mm:ss
	SendInput, %currentDateTime%
Return

:?*:@ddd::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDate, , yyyy-MM-dd
	SendInput, %currentDate%
Return

:?*:@dtfn::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDateTime, , yyyy-MM-dd_HH:mm:ss
	updatedDateTime := StrReplace( currentDateTime, ":", "⋮" )
	SendInput, %updatedDateTime%
Return

:?*:@mdys::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDate, , MM/dd/yyyy
	SendInput, %currentDate%
Return

;   ································································································
;     >>> §5.2: Times

:?*:@ttt::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentTime, , HH-mm-ss
	SendInput, %currentTime%
Return

:?*:@ttc::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentTime, , HH:mm:ss
	SendInput, %currentTime%
Return

:?*:@ttfn::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentTime, , HH:mm:ss
	updatedTime := StrReplace( currentTime, ":", "⋮" )
	SendInput, % updatedTime
Return

:?*:@xccc::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, currentDate,, yyyy-MM-dd
	SendInput, / Completed %currentDate%
Return

:?*:@xsss::
	AppendAhkCmd(A_ThisLabel)
	FormatTime, CurrentDateTime,, yyyy-MM-dd
	SendInput, (Started %CurrentDateTime%)
Return

; --------------------------------------------------------------------------------------------------
;   §6: CLIPBOARD modifying hotstrings
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §6.1: Slash character reversal

:*?:@reverseBackSlashes::
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

:*?:@reverseFwdSlashes::
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

:*?:@convertUrlToFileName::
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

;   ································································································
;     >>> §6.3: ASCII Text Art

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.1: AsciiArtLetter3h class

class AsciiArtLetter3h {
	__New( row1chars, row2chars, row3chars, spaceRight, spaceLeft := True ) {
		this.rows[1] := row1chars
		this.rows[2] := row2chars
		this.rows[3] := row3chars
		this.spaceRight := spaceRight
		this.spaceLeft := spaceLeft
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.2: AsciiArtConverter class

class AsciiArtConverter {
	__New() {

		; Establish the important settings for our ASCII art alphabet.
		this.alphabet := {}
		this.numArtRows := 3

		; Build our ASCII art alphabet by specifying: 1) the rows of ASCII characters that represent		;   each glyph and 2) specifying left and right spacing for each glyph.
		this.alphabet[ "a" ] := new AsciiArtLetter3h( "▄▀▀▄", "█▄▄█", "█  ▀", True )
		this.alphabet[ "b" ] := new AsciiArtLetter3h( "█▀▀▄", "█▀▀▄", "▀▀▀ ", True )
		this.alphabet[ "c" ] := new AsciiArtLetter3h( "▄▀▀▀", "█   ", " ▀▀▀", True )
		this.alphabet[ "d" ] := new AsciiArtLetter3h( "█▀▀▄", "█  █", "▀▀▀ ", True )
		this.alphabet[ "e" ] := new AsciiArtLetter3h( "█▀▀▀", "█▀▀ ", "▀▀▀▀", True )
		this.alphabet[ "f" ] := new AsciiArtLetter3h( "█▀▀▀", "█▀▀▀", "▀   ", True )
		this.alphabet[ "g" ] := new AsciiArtLetter3h( "█▀▀▀", "█ ▀▄", "▀▀▀▀", True )
		this.alphabet[ "h" ] := new AsciiArtLetter3h( "█  █", "█▀▀█", "█  ▀", True )
		this.alphabet[ "i" ] := new AsciiArtLetter3h( "▀█▀", " █ ", "▀▀▀", True )
		this.alphabet[ "j" ] := new AsciiArtLetter3h( "   █", "▄  █", "▀▄▄█", True )
		this.alphabet[ "k" ] := new AsciiArtLetter3h( "█ ▄▀ ", "█▀▄  ", "▀  ▀▄", False )
		this.alphabet[ "l" ] := new AsciiArtLetter3h( "█   ", "█  ▄", "▀▀▀ ", True )
		this.alphabet[ "m" ] := new AsciiArtLetter3h( "▐▀▄▀▌", "█ ▀ ▌", "█   ▀", False )
		this.alphabet[ "n" ] := new AsciiArtLetter3h( "▐▀▀▄", "█  ▐", "▀  ▐", True )
		this.alphabet[ "o" ] := new AsciiArtLetter3h( "▄▀▀▄", "█  █", " ▀▀ ", True )
		this.alphabet[ "p" ] := new AsciiArtLetter3h( "█▀▀▄", "█▄▄▀", "█   ", True )
		this.alphabet[ "q" ] := new AsciiArtLetter3h( "▄▀▀▄", "█  █", " ▀█▄", True )
		this.alphabet[ "r" ] := new AsciiArtLetter3h( "█▀▀▄ ", "█▄▄▀ ", "▀  ▀▄", False )
		this.alphabet[ "s" ] := new AsciiArtLetter3h( "▄▀▀▀", "▀▀▀█", "▀▀▀ ", True )
		this.alphabet[ "t" ] := new AsciiArtLetter3h( "▐▀█▀▌", "  █  ", "  █  ", False, False )
		this.alphabet[ "u" ] := new AsciiArtLetter3h( "█  █", "█  █", " ▀▀ ", True )
		this.alphabet[ "v" ] := new AsciiArtLetter3h( "▐   ▌", " █ █ ", "  █  ", False, False )
		this.alphabet[ "w" ] := new AsciiArtLetter3h( "▐   ▌", "▐ █ ▌", " ▀ ▀ ", False, False )
		this.alphabet[ "x" ] := new AsciiArtLetter3h( "▐▄ ▄▌", "  █  ", "▐▀ ▀▌", False, False )
		this.alphabet[ "y" ] := new AsciiArtLetter3h( "█  █", "▀▄▄█", "▄▄▄▀", True )
		this.alphabet[ "z" ] := new AsciiArtLetter3h( "▀▀▀█", " ▄▀ ", "█▄▄▄", True )
		this.alphabet[ "0" ] := new AsciiArtLetter3h( "█▀▀█", "█▄▀█", "█▄▄█", True )
		this.alphabet[ "1" ] := new AsciiArtLetter3h( "▄█  ", " █  ", "▄█▄▌", True )
		this.alphabet[ "2" ] := new AsciiArtLetter3h( "▄▀▀█", " ▄▄▀", "█▄▄▄", True )
		this.alphabet[ "3" ] := new AsciiArtLetter3h( "█▀▀█", "  ▀▄", "█▄▄█", True )
		this.alphabet[ "4" ] := new AsciiArtLetter3h( " ▄▀█ ", "▐▄▄█▌", "   █ ", False )
		this.alphabet[ "5" ] := new AsciiArtLetter3h( "█▀▀▀", "▀▀▀▄", "▄▄▄▀", True )
		this.alphabet[ "6" ] := new AsciiArtLetter3h( "▄▀▀▄", "█▄▄ ", "▀▄▄▀", True )
		this.alphabet[ "7" ] := new AsciiArtLetter3h( "▐▀▀█", "  █ ", " ▐▌ ", True )
		this.alphabet[ "8" ] := new AsciiArtLetter3h( "▄▀▀▄", "▄▀▀▄", "▀▄▄▀", True )
		this.alphabet[ "9" ] := new AsciiArtLetter3h( "▄▀▀▄", "▀▄▄█", " ▄▄▀", True )
		this.alphabet[ " " ] := new AsciiArtLetter3h( " ", " ", " ", True )
		this.alphabet[ "." ] := new AsciiArtLetter3h( " ", " ", "▀", True )
		this.alphabet[ "," ] := new AsciiArtLetter3h( " ", "▄", "▐", True )
		this.alphabet[ "?" ] := new AsciiArtLetter3h( "▄▀▀█", "  █▀", "  ▄ ", True )
		this.alphabet[ "!" ] := new AsciiArtLetter3h( "█", "█", "▄", True )
		this.alphabet[ ":" ] := new AsciiArtLetter3h( "▄", "▄", " ", True )
		this.alphabet[ ";" ] := new AsciiArtLetter3h( "▄", "▄", "▐", True )
		this.alphabet[ "-" ] := new AsciiArtLetter3h( "  ", "▀▀", "  ", True )
		this.alphabet[ "–" ] := new AsciiArtLetter3h( "   ", "▀▀▀", "   ", True )
		this.alphabet[ "—" ] := new AsciiArtLetter3h( "    ", "▀▀▀▀", "    ", True )
		this.alphabet[ "_" ] := new AsciiArtLetter3h( "   ", "   ", "▀▀▀", True )
		this.alphabet[ "*" ] := new AsciiArtLetter3h( "▀▄█▄▀", " ▄█▄ ", "▀ ▀ ▀", True )
		this.alphabet[ "/" ] := new AsciiArtLetter3h( "  █", " █ ", "█  ", True )
		this.alphabet[ "\" ] := new AsciiArtLetter3h( "█  ", " █ ", "  █", True )
		this.alphabet[ "(" ] := new AsciiArtLetter3h( "▄▀", "█ ", " ▀", True )
		this.alphabet[ ")" ] := new AsciiArtLetter3h( "▀▄", " █", "▀ ", True )
		this.alphabet[ "[" ] := new AsciiArtLetter3h( "█▀", "█ ", "▀▀", True )
		this.alphabet[ "]" ] := new AsciiArtLetter3h( "▀█", " █", "▀▀", True )
		this.alphabet[ "{" ] := new AsciiArtLetter3h( " █▀", "▀▄ ", " ▀▀", True )
		this.alphabet[ "}" ] := new AsciiArtLetter3h( "▀█ ", " ▄▀", "▀▀ ", True )
	}

	ConvertString( str, newlines := "rn" ) {

		; Determine how new lines should be encoded.
		if ( newlines == "r") {
			nlChars := "`r"
		} else if( newslines == "n" ) {
			nlChars := "`n"
		} else {
			nlChars := "`r`n"
		}

		; Loop through each row of the ASCII art that will represent the input string.
		newStr := ""
		len := StrLen( str )
		idx_i := 1
		while( idx_i <= this.numArtRows ) {

			; For each row of ASCII art, loop through each character that needs to be converted.
			idx_j := 1
			while( idx_j <= len ) {

				; Get the character to be converted at the current columnar position along the current row
				;   of ASCII art.
				if ( idx_j == 1 ) {
					whichChar := SubStr( str, idx_j , 1 )
				} else {
					whichChar := nextChar
				}

				; Look ahead for the next character to be converted; this is important for determining
				;   spacing between letters.
				if ( idx_j < len ) {
					nextChar := SubStr( str, idx_j + 1, 1)
				}

				; Now obtain the appropriate row of ASCII art characters that represent the current
				;   character being converted.
				artChars := this.alphabet[ "" . whichChar ].rows[ idx_i ]
				if ( artChars ) {
					newStr .= artChars
					if ( idx_j < len && this.alphabet[ "" . whichChar ].spaceRight
							&& this.alphabet[ "" . nextChar ].spaceLeft ) {
						newStr .= " "
					}
				}

				; Proceed to the next character in the string to be converted for this row of ASCII art.
				idx_j++
			}

			; Proceed to building the next row of ASCII art.
			idx_i++
			if ( idx_i <= this.numArtRows ) {
				newStr .= nlChars
			}
		}

		; Return the text block of ASCII art constructed from the string supplied to the function.
		return newStr
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §6.3.3: @convertCbToAsciiArt hotstring

:*?:@convertCbToAsciiArt::
	global g_asciiArtConverter
	AppendAhkCmd(A_ThisLabel)

	; Get the global object referencing the script's ASCII art converter 
	if ( !g_asciiArtConverter ) {
		g_asciiArtConverter := New AsciiArtConverter()
	}

	; Convert the string in the clipboard to ASCII art
	Clipboard := g_asciiArtConverter.ConvertString( Clipboard )
Return
