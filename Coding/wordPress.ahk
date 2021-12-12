; ==================================================================================================
; ▐   ▌▄▀▀▄ █▀▀▄ █▀▀▄ █▀▀▄ █▀▀▄ █▀▀▀ ▄▀▀▀ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; ▐ █ ▌█  █ █▄▄▀ █  █ █▄▄▀ █▄▄▀ █▀▀  ▀▀▀█ ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
;  ▀ ▀  ▀▀  ▀  ▀▄▀▀▀  █    ▀  ▀▄▀▀▀▀ ▀▀▀  ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; AutoHotkey script for automatically checking for updates in the WordPress editor.
;
; @version 1.0.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/Coding/wordPress.ahk
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
; TABLE OF CONTENTS:
; -----------------
;   §1: GLOBALS & SCRIPT PERMANENCE.............................................................39
;   §2: HOTSTRINGS & ASSOCIATED FUNCTIONS.......................................................67
;     >>> §2.1: Check CSS edits on WordPress sites..............................................71
;     >>> §2.2: JS-Mediated Console Based Enhancements of the WSUWP Editor.....................211
; ==================================================================================================

; TODO: Write hotstring that searches through OUE websites for latest CSS and JS updates
; Regex to match latest update: <ul class="post-revisions">.*?\.php\?revision=[0-9]{1,}">([^<]+)
; After overwriting code with what was found, replace with /1 to isolate 

; --------------------------------------------------------------------------------------------------
;   §1: GLOBALS & SCRIPT PERMANENCE
; --------------------------------------------------------------------------------------------------

GetWpEditorSettings() {
	global wpEditorSettings
	if ( !IsObject( wpEditorSettings ) ) {
		wpEditorSettings := {}
		wpEditorSettings.websites := ["https://ascc.wsu.edu"
			, "https://commonreading.wsu.edu"
			, "https://distinguishedscholarships.wsu.edu"
			, "https://firstyear.wsu.edu"
			, "https://learningcommunities.wsu.edu"
			, "https://nse.wsu.edu"
			, "https://summerresearch.wsu.edu"
			, "https://surca.wsu.edu"
			, "https://transfercredit.wsu.edu"
			, "https://undergraduateresearch.wsu.edu"
			, "https://ucore.wsu.edu"
			, "https://ucore.wsu.edu/assessment"]
		wpEditorSettings.commands := { editCss: "/wp-admin/themes.php?page=editcss"
			, editJs: "/wp-admin/themes.php?page=custom-javascript"}
		wpEditorSettings.logFilePath := "F:\Users\CamilleandDaniel\Documents\Daniel\^WSU-Web-Dev\^P"
			. "ersonnel-File\wordPress-automation-log.txt"
	}
	return wpEditorSettings
}

; --------------------------------------------------------------------------------------------------
;   §2: HOTSTRINGS & ASSOCIATED FUNCTIONS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: Check CSS edits on WordPress sites

:*?:@checkCssEdits::
	AppendAhkCmd(A_ThisLabel)
	CheckCssEdits()
Return

; TODO: Change the implementation of the functions in this section to an object-oriented approach.
CheckCssEdits() { ; (cce)
	; Initialize settings.
	delay := 200
	settings := GetWpEditorSettings()
	websites := settings.websites
	progressTitle := A_ThisFunc . "() Progress Indicator"
	numWebsites := websites.Length()
	; TODO: numOperations := numWebsites * ...

	; Set up a progress window.
	Progress, R0-%numWebsites%, % cce_GetProgressStr(0, numWebsites) ; TODO: , numOperations
		, % progressTitle, % A_ScriptName

	; Loop through our websites and check for CSS updates.
	logFile := cce_PrepareLogfile(settings.logFilePath)
	if (logFile) {
		cce_AnalyzeWebsites(settings, websites, numWebsites, logFile)
		logFile.Close()
	}

	; Notify the user that we are done, and dismiss the progress window.
	cce_CompleteTask(delay)
}

cce_GetProgressStr(progressCtr, numWebsites) {
	return progressCtr . " of " . numWebsites . " websites inspected"
}

cce_PrepareLogfile(filePath) {
	logFile := FileOpen(filePath, "a", "UTF-8")
	if (logFile) {
		if (logFile.Pos != 3) { ; New file has byte position of 3 ∵ 3-byte UTF-8 BOM
			logFile.WriteLine("")	
		}
		cce_WriteTitleBar(logFile)
		logFile.WriteLine("Analysis of OUE CSS updates conducted on " . A_Now) ; TODO: format A_Now
		cce_WriteTitleBar(logFile)
	} else {
		ErrorBox(A_ThisFunc, "I was unable to open the log file at:`n" . filePath . "`n`nThis was "
			. "reported to me as the reason:`n" . A_LastError)
	}
	return logFile
}

cce_WriteTitleBar(logFile) {
	if (IsObject(logFile)) {
		logFile.WriteLine("------------------------------------------------------------------------"
		 	. "----------------------------")
	} else {
		ErrorBox(A_ThisFunc, "I wasn't properly passed a file object in which to write my data.")
	}
}

cce_AnalyzeWebsites(settings, websites, numWebsites, logFile) {
	delay := 500
	argCheck := (IsObject(websites) << 1) | IsObject(logFile) ; ∴ 0b11 represents valid arguments
	if (argCheck = 3) { ; b/c 0b11 = 0d3
		slug := settings.commands.editCss
		webBrowserProcess := "chrome.exe"
		correctTitleNeedle := "CSS "
		viewSourceTitle := "view-source ahk_exe " . webBrowserProcess
		progressCtr := 0
		For idx, domain in websites
		{
			url := domain . slug
			LoadWordPressSiteInChrome(url)
			Sleep, % delay
			markup := CopyWebpageSourceToClipboard(webBrowserProcess, correctTitleNeedle
				, viewSourceTitle, "I was unable to locate a 'view source' tab for a CSS "
				. "Stylesheet Editor page in WordPress.")
			cce_LogLatestUpdate(logFile, domain, markup)
			Sleep, % delay / 5
			Send, ^w
			progressCtr++
			Progress, %progressCtr%, % cce_GetProgressStr(progressCtr, numWebsites)
		}
	} else {
		cce_ReportAnalysisError(A_ThisFunc, argCheck)
	}
}

cce_ReportAnalysisError(funcName, argCheck) {
	if (argCheck >= 0 && argCheck <= 2) {
		if (!argCheck) {
			errorMsg := "I wasn't properly passed objects for either the website list or the log "
				. "file."
		} else if (argCheck = 1) {
			errorMsg := "I wasn't properly passed an object for the log file."
		} else {
			errorMsg := "I wasn't properly passed an object for the website list."
		}
		ErrorBox(funcName, errorMsg)
	} else {
		ErrorBox(A_ThisFunc, "I received an error state that makes no sense to me.")
	}
}

cce_LogLatestUpdate(logFile, domain, markup) {
	if (IsObject(logFile)) {
		; Find the latest update in the markup
		line := domain . "`t" . cce_GetLatestUpdate(markup)
		logFile.WriteLine(line)
	} else {
		ErrorBox(A_ThisFunc, "I wasn't properly passed a file object in which to write my data.")
	}
}

cce_GetLatestUpdate(markup) {
	updateStr := ""
	foundPos := RegExMatch(markup, "Pm)<ul class=""post-revisions"">", matchLen)
	if (foundPos) {
		authorPos := RegExMatch(markup, "Om)> ([^ ]+) <a href=", match, foundPos + matchLen)
		updateStr := match.Value(1)
		updatePos := RegExMatch(markup, "Om)<a href=""[^>]+>([^<]+)<", match, foundPos + matchLen)
		updateStr .= "`t" . match.Value(1)
	} else {
		updateStr := "ERROR: Couldn't find latest update"
	}
	return updateStr
}

cce_CompleteTask(delay) {
	if (delay <= 0 || delay > 1000) {
		delay := 200
	}
	Sleep % delay * 5
	Progress, , % "Complete!"
	Sleep % delay * 10
	Progress, Off
}

;   ································································································
;     >>> §2.2: JS-Mediated Console Based Enhancements of the WSUWP Editor

:*?:@collapseOpenBuilderSections::
	AppendAhkCmd(A_ThisLabel)
	Send % "// Collapse all open builder sections.+{Enter}( function($) {{}+{Enter}{Tab}'use"
		. " strict';+{Enter}+{Enter}{Tab}$( '.ttfmake-section' ).each( function() {{}+{Enter}{Tab"
		. " 2}let $this = $( this );+{Enter}{Tab 2}if ( $this.hasClass( 'ttfmake-section-open' ) )"
		. " {{}+{Enter}{Tab 3}let $toggle = $this.find( '.ttfmake-section-toggle' );+{Enter}{Tab"
		. " 3}$toggle.click();+{Enter}{Tab 2}{}}+{Enter}{Tab}{}} );+{Enter}{}} )( jQuery );"
Return

:*?:@expandClosedBuilderSections::
	AppendAhkCmd(A_ThisLabel)
	Send % "// Expand all closed builder sections.+{Enter}( function($) {{}+{Enter}{Tab}'use"
		. " strict';+{Enter}+{Enter}{Tab}$( '.ttfmake-section' ).each( function() {{}+{Enter}{Tab"
		. " 2}let $this = $( this );+{Enter}{Tab 2}if ( {!}$this.hasClass( 'ttfmake-section-open' )"
		. " ) {{}+{Enter}{Tab 3}let $toggle = $this.find( '.ttfmake-section-toggle' );+{Enter}{Tab"
		. " 3}$toggle.click();+{Enter}{Tab 2}{}}+{Enter}{Tab}{}} );+{Enter}{}} )( jQuery );"
Return

:*?:@resizeWsuwpBuilderColumns::
	AppendAhkCmd(A_ThisLabel)
	Send % "// Resize WSUWP page builder editor text areas so all text is visibile within the"
		. " control.+{Enter}( ($) => {{}+{Enter}{Tab}'use strict';+{Enter}+{Enter}{Tab}let"
		. " $makeSections = $( '.ttfmake-section-open' );+{Enter}{Tab}$makeSections.each("
		. " function() {{}+{Enter}{Tab 2}let $this = $( this );+{Enter}{Tab 2}let $textarea ="
		. " $this.find( 'textarea.wp-editor-area' );+{Enter}{Tab 2}$textarea.outerHeight("
		. " $textarea[0].scrollHeight );+{Enter}{Tab}{}} );+{Enter}{}} )( jQuery );"
Return
