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
	nbf := New NoteBlockFinisher
	nbf.Execute( execDelayer )
Return

; TODO: Decide whether to build a base class like "NoteBlockManipulator" that could be used to build other classes like this one.
class NoteBlockFinisher {
	; RegEx search strings
	static reNbLine1 := "{^}20[0-9]{{}2{}}-[0-1][0-9]-[0-3][0-9]--[0-2][0-9]:[0-9]{{}2{}}:[0-9]{{}2{}}─+┐$"
	static reNbLine2 := "{^}│.*?│$"
	static reNbLine3 := "{^}└───┬─+┘$"

	; Error conditions
	static procNotFound := 1
	static lineNotFound := 1 << 1

	__New( delayerIntf ) {
		this.delayerInt := delayerIntf
	}

	CheckProcess() {
		numApprProcs := this.approvedProcs.Length
		procApproved := False

		WinGet, curProc, ProcessName, A

		Loop, %numApprProcs% {
			procProps := this.approvedProcs[ A_Index ]
			if ( curProc == procProps.exeName ) {
				procApproved := True
				Break
			}
		}

		return procApproved
	}

	CopyCurLineToCb() {
		; this.delayerIntf.Wait( "s" )
		; TODO: Finish writing function
		return Clipboard
	}

	ErrorMsg( whatHappened ) {
		WinGet, curProc, ProcessName, A
		if ( whatHappened == NoteBlockFinisher.procNotFound ) {
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

		; TODO: Finish writing function

		Return 0
	}

	FindTitleLine() {
		lineFound := False
		; TODO: Get current line into clipboard
		; TODO: Ensure current line is one of the three possible formats
		; TODO: Get the rest of the lines in the note block
		; TODO: Determine what the line length of the note block should be based on line 2
		; TODO: Replace line 1 with correctly sized string
		; TODO: Replace line 3 with correctly sized string
		; TODO: Move down to root position where notes are entered
		return lineFound
	}

	GetApprovedProcList() {
		; TODO: Finish writing function
		return "??!"
	}

	ResetApprovedProcs() {
		this.approvedProcs := [ { desc: "Sublime Text 3"
			, exeName: "sublime_text.exe" } ]
	}
}
