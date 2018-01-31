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
		wpEditorSettings.logFile := "C:\Users\CamilleandDaniel\{^}WSU-Web-Dev\^Personnel-File\wordP"
			. "ress-automation-log.txt"
	}
	return wpEditorSettings
}

; --------------------------------------------------------------------------------------------------
;   §2: HOTSTRINGS & ASSOCIATED FUNCTIONS
; --------------------------------------------------------------------------------------------------

; ··································································································
;   >>> §2.1: Check CSS edits on WordPress sites
:*:@checkCssEdits::
	AppendAhkCmd(A_ThisLabel)
	CheckCssEdits()
Return

CheckCssEdits() {
	delay := 200
	settings := GetWpEditorSettings()
	websites := settings.websites
	numWebsites := websites.Length()
	slug := settings.commands.editCss
	mainTitle := A_ThisFunc . "() Progress Indicator"
	progressCtr := 0
	Progress, R0-%numWebsites%, % GetCheckCssEditsProgressStr(progressCtr, numWebsites)
		, % mainTitle, % A_ScriptName
	For key, value in websites
	{
		url := value . slug
		LoadWordPressSiteInChrome(url)
		progressCtr++
		Progress, %progressCtr%, % GetCheckCssEditsProgressStr(progressCtr, numWebsites)
	}
	Sleep % delay * 5
	Progress, , % "Complete!"
	Sleep % delay * 10
	Progress, Off
}

GetCheckCssEditsProgressStr(progressCtr, numWebsites) {
	return progressCtr . " of " . numWebsites . " websites inspected"
}