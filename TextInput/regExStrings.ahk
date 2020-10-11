; ==================================================================================================
; regExStrings.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Automate the insertion of RegEx strings used in find/replace editing via Sublime Text 3.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: MIT - Copyright (c) 2020 Daniel C. Rieck.
;
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;   and associated documentation files (the “Software”), to deal in the Software without
;   restriction, including without limitation the rights to use, copy, modify, merge, publish,
;   distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in all copies or
;   substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;   BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================

; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: Regex strings for working with AHK files................................................44
;     >>> §1.1: @findStrAhkTocSections1.........................................................48
;     >>> §1.2: @findStrAhkTocSections2.........................................................57
;     >>> §1.3: @replStrAhkTocSections2.........................................................65
;     >>> §1.4: findStrAhkTocHeader.............................................................74
;   §2: Less/CSS files..........................................................................83
;   §3: JS files...............................................................................109
;   §4: HTML files.............................................................................129
;   §5: General note taking....................................................................138
;     >>> §5.1: @finishNotesBlock..............................................................142
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Regex strings for working with AHK files
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: @findStrAhkTocSections1

:*:@findStrAhkTocSections1::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "(?:{^}; -{{}98{}}$\n; {{}3{}}.{+}$\n{^}; -{{}98{}}$)|(?:{^}; {{}3{}}·{{}96{}}$\n{"
		. "^}; {{}5{}}>>> .*$)|(?:{^}; {{}5{}}(?: ·){{}47{}}$\n{^}; {{}7{}}→→→ .*$)"
Return

;   ································································································
;     >>> §1.2: @findStrAhkTocSections2

:*:@findStrAhkTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "{^} {{}1,{}}([0-9]{{}1,{}}): (; {{}3{}}.*§.{+})$"
Return

;   ································································································
;     >>> §1.3: @replStrAhkTocSections2

:*:@replStrAhkTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "\1\2............................................................................."
		. ".........."
Return

;   ································································································
;     >>> §1.4: findStrAhkTocHeader

:*:@findStrAhkTocHeader::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "(?<=; ={{}98{}}\n; Table of Contents:\n; -{{}17{}}\n)(({^}.*$\n)(?{!}; ={{}98{}}))"
		. "*({^}.*$\n)"
Return

; --------------------------------------------------------------------------------------------------
;   §2: Regex strings for working with Less/CSS files
; --------------------------------------------------------------------------------------------------

:*:@findStrLessTocSections1::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "(?{<}=[-·=]\n){^}(\*\*|//)(\*?/? *)(.*)(§[0-9]{+})(.*)$"
Return

:*:@findStrLessTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "{^} *([0-9]{+}): (?:\**|/*)( {+})(.{+})$"
Return

:*:@replStrLessTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "\1**  \2\3......................................................................."
		. "........."
Return

:*:@findStrLessTocHeader::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "(?<=\*{{}3{}} {{}2{}}TABLE OF CONTENTS:\n\*{{}3{}} {{}2{}}─{{}92{}}\n)(({^}.*$\n)("
		. "?{!}\*{{}3{}} {{}2{}}─{{}95{}}\n))*({^}.*$\n)"
Return

; --------------------------------------------------------------------------------------------------
;   §3: Regex strings for working with JS files
; --------------------------------------------------------------------------------------------------

:*:@findStrJsTocSections1::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "({^}(?<=/{{}7{}}\n)\t*// §.*$)"
Return

:*:@findStrJsTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "{^} *([0-9]{+}): \t*(// §.*)$"
Return

:*:@findStrJsTocHeader::
	AppendAhkCmd(A_ThisLabel)
	SendInput % "(?<=/{{}100{}}\n/{{}2{}} TABLE OF CONTENTS\n/{{}2{}} -{{}17{}}\n)(({^}.*$\n)(?{!}/"
		. "{{}100{}}))*({^}.*$\n)"
Return

; --------------------------------------------------------------------------------------------------
;   §4: Regex strings for working with HTML files
; --------------------------------------------------------------------------------------------------

:*:@findStrNoAltImgTags::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "<img([{^}>](?{!}alt=))*>"
Return

; --------------------------------------------------------------------------------------------------
;   §5: General note taking
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §5.1: @finishNotesBlock

:*:@finishNotesBlock::
Return

class NoteBlockFinisher {
	static procNotFound := 1
	static lineNotFound := 1 << 1

	CheckProcess() {
		return False
	}

	ErrorMsg( whatHappened ) {
		WinGet, curProc, ProcessName, A
		if( whatHappened == NoteBlockFinisher.procNotFound ) {
			return "The active process, " . curProc . ", was not found to be among the list of approved processes including: " . this.GetApprovedProcList()
		} else if ( whatHappened == NoteBlockFinisher.lineNotFound ) {
			return "I determined that the line you are on in " . curProc . " wasn't inside the heading of a note block."
		} else {
			return "An unclassified error was encountered, so I'm giving up on finishing the note block."
		}
	}

	Execute() {
		this.ResetApprovedProcs()

		procOk := this.CheckProcess()
		if ( !procOk ) {
			Return this.ErrorMsg( NoteBlockFinisher.procNotFound )
		}

		lineFound := this.FindTitleLine()
		if ( !lineFound ) {
			Return this.ErrorMsg( NoteBlockFinisher.lineNotFound )
		}

		Return 0
	}

	FindTitleLine() {
		return False
	}

	ResetApprovedProcs() {
		this.approvedProcs := [ { desc: "Sublime Text 3"
			, titleStr: "ahk_exe sublime_text.exe" } ]
	}
}
