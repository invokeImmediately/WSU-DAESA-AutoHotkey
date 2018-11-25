; ==================================================================================================
; wordPress.ahk
; AutoHotkey script for automatically checking for updates in the WordPress editor.
; ==================================================================================================

; TODO: Write hotstring that searches through OUE websites for latest CSS and JS updates
; Regex to match latest update: <ul class="post-revisions">.*?\.php\?revision=[0-9]{1,}">([^<]+)
; After overwriting code with what was found, replace with /1 to isolate 

; --------------------------------------------------------------------------------------------------
;   §1: GLOBALS & SCRIPT PERMANENCE
; --------------------------------------------------------------------------------------------------

GetWpEditorSettings() {
	global wpEditorSettings
	if (!IsObject(wpEditorSettings)) {
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

:*:@checkCssEdits::
	AppendAhkCmd(A_ThisLabel)
	CheckCssEdits()
Return

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
