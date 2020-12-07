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
	Suspend, On
	Sleep % timingDelay
	Send % "^+f"
	Sleep % timingDelay
	Send % "{Backspace}"
	Sleep % timingDelay
	Suspend, Off

	GoSub % hsTocSectionFinder

	Suspend, On
	Sleep % timingDelay
	Send % "{Tab}^a{Backspace}<current file>"
	Sleep % timingDelay
	Send % "!{Enter}"
	Sleep % timingDelay
	Suspend, Off
}

;   ································································································
;     >>> §2.2: utoc_GetFileExtension(…)

utoc_GetFileExtension(timingDelay) {
	fileExtNeedle := "O)^.*\.([^.]+)$"

	; Copy the name of the file currently being edited to the clipboard.
	Suspend, On
	Sleep % timingDelay * 3
	Send % "^+p"
	Sleep % timingDelay
	Send % "{Backspace}"
	Sleep % timingDelay
	Send % "Copy File Name"
	Sleep % timingDelay
	Send % "{Enter}"
	Sleep % timingDelay * 5
	Suspend, Off

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
	Suspend, On
	Sleep % timingDelay
	Send % "^f"
	Sleep % timingDelay
	Send % "{Backspace}"
	Sleep % timingDelay
	Suspend, Off

	GoSub % hsTocLineFinder

	Suspend, On
	Sleep % timingDelay
	Send % "!{Enter}"
	Sleep % timingDelay
	Send % "^c"
	Sleep % timingDelay
	Send % "^a"
	Sleep % timingDelay
	Send % "^v"
	Sleep % timingDelay
	Send % "^a"
	Sleep % timingDelay
	Send % "^+l"
	Sleep % timingDelay
	Send % "{Home}"
	Sleep % timingDelay
	Send % "^+{Right}"
	Sleep % timingDelay
	Send % "^x"
	Sleep % timingDelay
	Send % "^w"
	Sleep % timingDelay
	Suspend, Off
}

;   ································································································
;     >>> §2.4: utoc_PerformTocUpdateCmds(…)

utoc_OverwriteTocLineNumbersInFile(hsTocHeaderFinder, timingDelay) {
	Suspend, On
	Sleep % timingDelay
	Send % "^f"
	Sleep % timingDelay
	Send % "{Backspace}"
	Sleep % timingDelay
	Suspend, Off

	GoSub % hsTocHeaderFinder

	Suspend, On
	Sleep % timingDelay
	Send % "!{Enter}"
	Sleep % timingDelay
	Send % "^+l"
	Sleep % timingDelay
	Send % "{Right}^+{Left}"
	Sleep % timingDelay
	Send % "^v"
	Sleep % timingDelay
	Suspend, Off
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
