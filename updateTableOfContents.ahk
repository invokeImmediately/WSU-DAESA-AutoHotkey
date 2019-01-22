; ==================================================================================================
; updateTableOfContents.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Automate the updating of line numbers in medias res in table of contents sections of the
; inline documentation of Less, JS, and AHK files while coding in Sublime Text 3.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck.
;
;   Permission to use, copy, modify, and/or distribute this software for any purpose with or
;   without fee is hereby granted, provided that the above copyright notice and this permission
;   notice appear in all copies.
;
;   THE SOFTWARE IS PROVIDED "AS IS" AND DANIEL RIECK DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
;   SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
;   DANIEL RIECK BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
;   DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
;   CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;   PERFORMANCE OF THIS SOFTWARE.
; --------------------------------------------------------------------------------------------------
; AUTOHOTKEY SEND LEGEND:
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: @updateTocInFile........................................................................45
;   §2: Functions for supporting @updateTocInFile...............................................69
;     >>> §2.1: utoc_FindTocSectionsInFile(…)...................................................73
;     >>> §2.2: utoc_GetFileExtension(…)........................................................90
;     >>> §2.3: utoc_GetTocLineNumbersInFindResults(…).........................................123
;     >>> §2.4: utoc_PerformTocUpdateCmds(…)...................................................156
;     >>> §2.5: utoc_PerformTocUpdateCmds(…)...................................................177
;     >>> §2.6: utoc_UpdateTocInAhkFile(…).....................................................186
;     >>> §2.7: utoc_UpdateTocInJsFile(…)......................................................194
;     >>> §2.8: utoc_UpdateTocInLessFile(…)....................................................202
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: @updateTocInFile
; --------------------------------------------------------------------------------------------------

:*:@updateTocInFile::
	AppendAhkCmd(A_ThisLabel)
	timingDelay := GetDelay("xShort")
	editor := "sublime_text.exe"
	if (isTargetProcessActive(editor, A_ThisLabel, "This hotstring only works when editing a file i"
			. "n " . editor . ". Currently, the active process is " . getActiveProcessName())) {
		fileExt := utoc_GetFileExtension(timingDelay)
		if (fileExt = "js") {
			utoc_UpdateTocInJsFile(timingDelay)
		} else if (fileExt = "ahk") {
			utoc_UpdateTocInAhkFile(timingDelay)
		} else if (fileExt = "less") {
			utoc_UpdateTocInLessFile(timingDelay)
		} else {
			MsgBox % "Editing a file that is not saved as JS, AHK, or Less; file extension is "
				. fileExt
		}
	}
Return

; --------------------------------------------------------------------------------------------------
;   §2: Functions for supporting @updateTocInFile
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: utoc_FindTocSectionsInFile(…)

utoc_FindTocSectionsInFile(hsTocSectionFinder, timingDelay) {
	Sleep % timingDelay
	SendInput % "^+f"
	Sleep % timingDelay
	SendInput % "{Backspace}"
	Sleep % timingDelay
	GoSub % hsTocSectionFinder
	Sleep % timingDelay
	SendInput % "{Tab}^a{Backspace}<current file>"
	Sleep % timingDelay
	SendInput % "!{Enter}"
	Sleep % timingDelay
}

;   ································································································
;     >>> §2.2: utoc_GetFileExtension(…)

utoc_GetFileExtension(timingDelay) {
	fileExtNeedle := "O)^.*\.([^.]+)$"

	; Copy the name of the file currently being edited to the clipboard.
	Sleep % timingDelay * 3
	SendInput % "^+p"
	Sleep % timingDelay
	SendInput % "{Backspace}"
	Sleep % timingDelay
	Send % "Copy File Name"
	Sleep % timingDelay
	SendInput % "{Enter}"
	Sleep % timingDelay * 5

	; Use RegEx to isolate the extension of the file.
	fileName := Clipboard
	Sleep % timingDelay
	foundPos := RegExMatch(fileName, fileExtNeedle, matchObj)
	if (foundPos) {
		fileExt := matchObj.Value(1)
	} else if (foundPos = 0) {
		fileExt := ""
	} else if (foundPos = "") {
		ErrorBox(A_ThisFunc, "An error occured in RegExMatch; ErrorLevel = " . ErrorLevel)
		fileExt := ""
	}

	return fileExt
}

;   ································································································
;     >>> §2.3: utoc_GetTocLineNumbersInFindResults(…)

utoc_GetTocLineNumbersInFindResults(hsTocLineFinder, timingDelay) {
	Sleep % timingDelay
	SendInput % "^f"
	Sleep % timingDelay
	SendInput % "{Backspace}"
	Sleep % timingDelay
	GoSub % hsTocLineFinder
	Sleep % timingDelay
	SendInput % "!{Enter}"
	Sleep % timingDelay
	SendInput % "^c"
	Sleep % timingDelay
	SendInput % "^a"
	Sleep % timingDelay
	SendInput % "^v"
	Sleep % timingDelay
	SendInput % "^a"
	Sleep % timingDelay
	SendInput % "^+l"
	Sleep % timingDelay
	SendInput % "{Home}"
	Sleep % timingDelay
	SendInput % "^+{Right}"
	Sleep % timingDelay
	SendInput % "^x"
	Sleep % timingDelay
	SendInput % "^w"
	Sleep % timingDelay
}

;   ································································································
;     >>> §2.4: utoc_PerformTocUpdateCmds(…)

utoc_OverwriteTocLineNumbersInFile(hsTocHeaderFinder, timingDelay) {
	Sleep % timingDelay
	SendInput % "^f"
	Sleep % timingDelay
	SendInput % "{Backspace}"
	Sleep % timingDelay
	GoSub % hsTocHeaderFinder
	Sleep % timingDelay
	SendInput % "!{Enter}"
	Sleep % timingDelay
	SendInput % "^+l"
	Sleep % timingDelay
	SendInput % "{Right}^+{Left}"
	Sleep % timingDelay
	SendInput % "^v"
	Sleep % timingDelay
}

;   ································································································
;     >>> §2.5: utoc_PerformTocUpdateCmds(…)

utoc_PerformTocUpdateCmds(hsTocSectionFinder, hsTocLineFinder, hsTocHeaderFinder, timingDelay) {
	utoc_FindTocSectionsInFile(hsTocSectionFinder, timingDelay)
	utoc_GetTocLineNumbersInFindResults(hsTocLineFinder, timingDelay)
	utoc_OverwriteTocLineNumbersInFile(hsTocHeaderFinder, timingDelay)
}

;   ································································································
;     >>> §2.6: utoc_UpdateTocInAhkFile(…)

utoc_UpdateTocInAhkFile(timingDelay) {
	utoc_PerformTocUpdateCmds(":*:@findStrAhkTocSections1", ":*:@findStrAhkTocSections2"
		, ":*:@findStrAhkTocHeader", timingDelay)
}

;   ································································································
;     >>> §2.7: utoc_UpdateTocInJsFile(…)

utoc_UpdateTocInJsFile(timingDelay) {
	utoc_PerformTocUpdateCmds(":*:@findStrJsTocSections1", ":*:@findStrJsTocSections2"
		, ":*:@findStrJsTocHeader", timingDelay)
}

;   ································································································
;     >>> §2.8: utoc_UpdateTocInLessFile(…)

utoc_UpdateTocInLessFile(timingDelay) {
	utoc_PerformTocUpdateCmds(":*:@findStrLessTocSections1", ":*:@findStrLessTocSections2"
		, ":*:@findStrLessTocHeader", timingDelay)
}
