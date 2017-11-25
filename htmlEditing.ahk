; ==================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ==================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
; HOTSTRINGS for text replacement
; --------------------------------------------------------------------------------------------------

:*:@cssShorthandBg::
	SendInput, % "bg-color bg-image position/bg-size bg-repeat bg-origin bg-clip bg-attachment init"
		. "ial|inherit;"
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@findStrBldrSctns::
	SendInput, % "(?<={^}---->\r\n){^}.*$(?:\r\n{^}(?{!}<{!}--|\r\n<{!}--|\Z).*$)*"
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoUrlNseAdmin::
	SendInput https://nse.wsu.edu/wp-admin/
Return

:*:@gotoUrlNseUpload::
	SendInput https://nse.wsu.edu/wp-admin/upload.php
Return

:*:@gotoUrlNseCss::
	SendInput https://nse.wsu.edu/wp-admin/themes.php?page=editcss
Return

:*:@gotoUrlNseJs::
	SendInput https://nse.wsu.edu/wp-admin/themes.php?page=custom-javascript
Return

:*:@gotoUrlNsePages::
	SendInput https://nse.wsu.edu/wp-admin/edit.php?post_type=page
Return

:*:@gotoUrlNsePosts::
	SendInput https://nse.wsu.edu/wp-admin/edit.php
Return

:*:@gotoUrlNseDocs::
	SendInput https://nse.wsu.edu/wp-admin/edit.php?post_type=document
Return

:*:@gotoUrlNseRedirects::
	SendInput https://nse.wsu.edu/wp-admin/edit.php?post_type=redirect_rule
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@gotoUrlSumResAdmin::
	SendInput https://summerresearch.wsu.edu/wp-admin/
Return

:*:@gotoUrlSumResUpload::
	SendInput https://summerresearch.wsu.edu/wp-admin/upload.php
Return

:*:@gotoUrlSumResCss::
	SendInput https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss
Return

:*:@gotoUrlSumResJs::
	SendInput https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript
Return

:*:@gotoUrlSumResPages::
	SendInput https://summerresearch.wsu.edu/wp-admin/edit.php?post_type=page
Return

:*:@gotoUrlSumResPosts::
	SendInput https://summerresearch.wsu.edu/wp-admin/edit.php
Return

:*:@gotoUrlSumResDocs::
	SendInput https://summerresearch.wsu.edu/wp-admin/edit.php?post_type=document
Return

:*:@gotoUrlSumResRedirects::
	SendInput https://summerresearch.wsu.edu/wp-admin/edit.php?post_type=redirect_rule
Return

; --------------------------------------------------------------------------------------------------
; GUI FUNCTIONS for handling user interactions with scripts
; --------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI triggering HOTSTRINGS
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@insBldrSctn::
	AppendAhkCmd(":*:@insBldrSctn")
	
	Gui, guiInsBldrSctn: New,, % "Post Minified JS to OUE Websites"
	Gui, guiInsBldrSctn: Add, Text,, % "Which OUE Websites would you like to update?"
	Gui, guiInsBldrSctn: Add, Radio, vBldrSctnChosen Checked, % "&Single"
	Gui, guiInsBldrSctn: Add, Radio, , % "Sidebar &Right"
	Gui, guiInsBldrSctn: Add, Radio, , % "&Halves"
	Gui, guiInsBldrSctn: Add, Radio, , % "&Thirds"
	Gui, guiInsBldrSctn: Add, Radio, , % "&Post"
	Gui, guiInsBldrSctn: Add, Radio, , % "H&eader"
	Gui, guiInsBldrSctn: Add, Radio, , % "Column background &image"
	Gui, guiInsBldrSctn: Add, Radio, , % "&Blank commenting line"
	Gui, guiInsBldrSctn: Add, Radio, , % "Pa&ge settings"
	Gui, guiInsBldrSctn: Add, Button, Default gHandleInsBldrSctnOK, &OK
	Gui, guiInsBldrSctn: Add, Button, gHandleInsBldrSctnCancel X+5, &Cancel
	Gui, guiInsBldrSctn: Show
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI driving FUNCTIONS
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleInsBldrSctnCancel() {
	Gui, guiInsBldrSctn: Destroy
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleInsBldrSctnOK() {
	global
	Gui, guiInsBldrSctn: Submit
	Gui, guiInsBldrSctn: Destroy
	
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		if (BldrSctnChosen = 1) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════"
				. "════════════════════════════════════════════════════╗`r---- ║ #### BUILDER SECTI"
				. "ON --- WSU SPINE THEME FOR WORDPRESS ###########################################"
				. "################## ║`r---- ╠===================================================="
				. "==================================================================╣`r---- ║ SING"
				. "LE --- Column One                                                               "
				. "                          1 of 1 ║`r---- ║  ╞═» Section classes: gutter pad-top "
				. "                                                                                "
				. "║`r---- ║  ╞═» Column classes: N/A                                              "
				. "                                               ║`r---- ║  ╘═» Column title: N/A "
				. "                                                                                "
				. "      § α…ω § ║`r---- ╚═════════════════════════════════════════════════════════"
				. "═════════════════════════════════════════════════════════════╝`r---->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 2) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════"
				. "════════════════════════════════════════════════════╗`r---- ║ #### BUILDER SECTI"
				. "ON --- WSU SPINE THEME FOR WORDPRESS ###########################################"
				. "################## ║`r---- ╠===================================================="
				. "==================================================================╣`r---- ║ SIDE"
				. "BAR RIGHT --- Column One                                                        "
				. "                          1 of 2 ║`r---- ║  ╞═» Section classes: gutter pad-top "
				. "                                                                                "
				. "║`r---- ║  ╞═» Column classes: N/A                                              "
				. "                                               ║`r---- ║  ╘═» Column title: N/A "
				. "                                                                                "
				. "         § α… ║`r---- ╠═════════════════════════════════════════════════════════"
				. "═════════════════════════════════════════════════════════════╣`r---->`r`r<!-- ╠═"
				. "════════════════════════════════════════════════════════════════════════════════"
				. "═════════════════════════════════════╣`r---- ║ #### BUILDER SECTION --- WSU SPIN"
				. "E THEME FOR WORDPRESS ##########################################################"
				. "### ║`r---- ╠==================================================================="
				. "===================================================╣`r---- ║ SIDEBAR RIGHT --- C"
				. "olumn Two                                                                       "
				. "           2 of 2 ║`r---- ║  ╞═» Section classes: gutter pad-top                "
				. "                                                                 ║`r---- ║  ╞═» "
				. "Column classes: N/A                                                             "
				. "                                ║`r---- ║  ╘═» Column title: N/A                "
				. "                                                                          …ω § ║"
				. "`r---- ╚════════════════════════════════════════════════════════════════════════"
				. "══════════════════════════════════════════════╝`r---->`r`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 3) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════"
				. "════════════════════════════════════════════════════╗`r---- ║ #### BUILDER SECTI"
				. "ON --- WSU SPINE THEME FOR WORDPRESS ###########################################"
				. "################## ║`r---- ╠===================================================="
				. "==================================================================╣`r---- ║ HALV"
				. "ES --- Column One                                                               "
				. "                          1 of 2 ║`r---- ║  ╞═» Section classes: gutter pad-top "
				. "                                                                                "
				. "║`r---- ║  ╞═» Column classes: N/A                                              "
				. "                                               ║`r---- ║  ╘═» Column title: N/A "
				. "                                                                                "
				. "         § α… ║`r---- ╠═════════════════════════════════════════════════════════"
				. "═════════════════════════════════════════════════════════════╣`r---->`r`r<!-- ╠═"
				. "════════════════════════════════════════════════════════════════════════════════"
				. "═════════════════════════════════════╣`r---- ║ #### BUILDER SECTION --- WSU SPIN"
				. "E THEME FOR WORDPRESS ##########################################################"
				. "### ║`r---- ╠==================================================================="
				. "===================================================╣`r---- ║ HALVES --- Column T"
				. "wo                                                                              "
				. "           2 of 2 ║`r---- ║  ╞═» Section classes: gutter pad-top                "
				. "                                                                 ║`r---- ║  ╞═» "
				. "Column classes: N/A                                                             "
				. "                                ║`r---- ║  ╘═» Column title: N/A                "
				. "                                                                          …ω § ║"
				. "`r---- ╚════════════════════════════════════════════════════════════════════════"
				. "══════════════════════════════════════════════╝`r---->`r`r"
				PasteText(commentTxt)
		} else if (BldrSctnChosen = 4) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════"
				. "════════════════════════════════════════════════════╗`r---- ║ #### BUILDER SECTI"
				. "ON --- WSU SPINE THEME FOR WORDPRESS ###########################################"
				. "################## ║`r---- ╠===================================================="
				. "==================================================================╣`r---- ║ THIR"
				. "DS --- Column One                                                               "
				. "                          1 of 3 ║`r---- ║  ╞═» Section classes: gutter pad-top "
				. "                                                                                "
				. "║`r---- ║  ╞═» Column classes: N/A                                              "
				. "                                               ║`r---- ║  ╘═» Column title: N/A "
				. "                                                                                "
				. "         § α… ║`r---- ╠═════════════════════════════════════════════════════════"
				. "═════════════════════════════════════════════════════════════╣`r---->`r`r<!-- ╠═"
				. "════════════════════════════════════════════════════════════════════════════════"
				. "═════════════════════════════════════╣`r---- ║ #### BUILDER SECTION --- WSU SPIN"
				. "E THEME FOR WORDPRESS ##########################################################"
				. "### ║`r---- ╠==================================================================="
				. "===================================================╣`r---- ║ THIRDS --- Column T"
				. "wo                                                                              "
				. "           2 of 3 ║`r---- ║  ╞═» Section classes: gutter pad-top                "
				. "                                                                 ║`r---- ║  ╞═» "
				. "Column classes: N/A                                                             "
				. "                                ║`r---- ║  ╘═» Column title: N/A                "
				. "                                                                             … ║"
				. "`r---- ╠════════════════════════════════════════════════════════════════════════"
				. "══════════════════════════════════════════════╣`r---->`r`r<!-- ╠════════════════"
				. "════════════════════════════════════════════════════════════════════════════════"
				. "══════════════════════╣`r---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WOR"
				. "DPRESS ############################################################# ║`r---- ╠=="
				. "================================================================================"
				. "====================================╣`r---- ║ THIRDS --- Column Three           "
				. "                                                                            3 of"
				. " 3 ║`r---- ║  ╞═» Section classes: gutter pad-top                               "
				. "                                                  ║`r---- ║  ╞═» Column classes:"
				. " N/A                                                                            "
				. "                 ║`r---- ║  ╘═» Column title: N/A                               "
				. "                                                           …ω § ║`r---- ╚═══════"
				. "════════════════════════════════════════════════════════════════════════════════"
				. "═══════════════════════════════╝`r---->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 5) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════"
				. "════════════════════════════════════════════════════╗`r---- ║ #### POST --- WSU "
				. "SPINE THEME FOR WORDPRESS ######################################################"
				. "################## ║`r---- ╠===================================================="
				. "==================================================================╣`r---- ║ Titl"
				. "e: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce congue fringil"
				. "la lorem sit ...                 ║`r---- ║  │     ...amet hendrerit.            "
				. "                                                                                "
				. "║`r---- ║  ╞═» Permalink: .../...                                               "
				. "                                               ║`r---- ║  ╞═» Thumbnail Image: /"
				. "wp-content/uploads/sites/.../201./../...                                        "
				. "              ║`r---- ║  │    ...                                               "
				. "                                                             ║`r---- ║  ╘═» Date"
				. " Posted: ....-..-..                                                             "
				. "                            ║`r---- ╚═══════════════════════════════════════════"
				. "═══════════════════════════════════════════════════════════════════════════╝`r--"
				. "-->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 6) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════"
				. "════════════════════════════════════════════════════╗`r---- ║ #### BUILDER SECTI"
				. "ON --- WSU SPINE THEME FOR WORDPRESS ###########################################"
				. "################## ║`r---- ╠===================================================="
				. "==================================================================╣`r---- ║ HEAD"
				. "ER --- Column One                                                               "
				. "                          1 of 1 ║`r---- ║  ╞═» Section classes: gutter pad-top "
				. "                                                                                "
				. "║`r---- ║  ╞═» Header level: h1                                                 "
				. "                                               ║`r---- ║  ╞═» Column classes: N/"
				. "A                                                                               "
				. "              ║`r---- ║  ╘═» Column title: N/A                                  "
				. "                                                     § α…ω § ║`r---- ╚══════════"
				. "════════════════════════════════════════════════════════════════════════════════"
				. "════════════════════════════╝`r---->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 7) {
			commentTxt := "---- ║  ╞═» Column background image: N/A                                "
				. "                                                    ║`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 8) {
			commentTxt := "---- ║  │                                                               "
				. "                                                    ║`r"
			PasteText(commentTxt)
		} else {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════"
				. "════════════════════════════════════════════════════╗`r---- ║ #### PAGE SETTINGS"
				. " ###############################################################################"
				. "################## ║`r---- ╚════════════════════════════════════════════════════"
				. "══════════════════════════════════════════════════════════════════╝`r---->`rTITL"
				. "E: …`rURL: /…`r"
			PasteText(commentTxt)
		}
	} else {
		MsgBox, 0
			, % "Error in AHK function: HandleInsBldrSctnOK" ; Title
			, % "An HTML comment for documenting Spine Builder tempalate sections can only be inser"
				. "ted if [Notepad++.exe] is the active process. Unfortunately, the currently activ"
				. "e process is [" . thisProcess . "]."
	}
}

; --------------------------------------------------------------------------------------------------
; FUNCTIONS for Quality Control of markup
; --------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> ESSENTIAL MARKUP BACKUP Hostring
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@backupOuePage::
	ahkThisCmd := A_ThisLabel
	keyDelay := 100
	webBrowserProcess := "chrome.exe"
	correctTitleNeedle := "\| Washington State University"
	viewSourceTitle := "view-source ahk_exe " . webBrowserProcess
	sublimeTextTitle := "Sublime Text ahk_exe sublime_text.exe"
	workingFilePath := "C:\Users\CamilleandDaniel\Documents\GitHub\backupOuePage-workfile.html"

	AppendAhkCmd(ahkThisCmd)

	; Use RegEx match mode so that any appearance of "| Washington State University" will easily be 
	; found in window titles; this textual phrase is appended to all WSU websites
	oldMatchMode := 0
	if (A_TitleMatchMode != RegEx) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode, RegEx
	}

	; Verify chrome as the active process, look for "| Washington State University" in title
	WinGet, activeProcess, ProcessName, A
	WinGetActiveTitle, processTitle
	if ( !(RegExMatch(activeProcess, webBrowserProcess) && RegExMatch(processTitle
			, correctTitleNeedle)) ) {
		ErrorBox(ahkThisCmd, "Before using this hotstring, please activate a tab of your web "
			. "browser into which a WSU OUE website is loaded.")
	} else {
		oldKeyDelay := 0
		if (A_KeyDelay != keyDelay)	{
			oldKeyDelay := A_KeyDelay
			SetKeyDelay, %keyDelay%
		}

		; Trigger view page source, wait for tab to load
		Send, ^u
		WinWaitActive, % viewSourceTitle, , 0.5
		idx := 0
		idxLimit := 9
		while(ErrorLevel)
		{
			WinWaitActive, % viewSourceTitle, , 0.5
			idx++
			if (idx >= idxLimit) {
				ErrorBox(ahkThisCmd, "I timed out while waiting for the view source tab to open.")
				break
			}
		}
		if (ErrorLevel) {
			Return
		} else {
			Sleep, (%keyDelay% * 10)
		}

		; Copy the markup and close the tab
		Send, ^a
		Send, ^c
		Send, ^w

		; Switch the active process to Sublime Text 3
		IfWinExist, % sublimeTextTitle
		{
			WinActivate
			Send, ^n
			Sleep, (%keyDelay% * 2)
			Send, {Esc}
			Send, ^v

			; Save the contents to the working file
			Send, ^+s
			Sleep, (%keyDelay% * 5)
			SendInput, % "{BackSpace}" . workingFilePath
			Sleep, %keyDelay%
			Send, {Enter}{Left}{Enter}
			Sleep, (%keyDelay% * 5)

			; Fix any problems with bad markup
			Send, ^h
			Sleep, (%keyDelay% * 2)
			SendInput, % "(<br ?/?> ?)\n[\t ]{{}0,{}}"
			Send, {Tab}^a{Del}
			SendInput, % "\1"
			Send, ^!{Enter}
			Sleep, (%keyDelay% * 2)
			Send, {Esc}{Right}

			; Trigger the Beautify HTML package to clean up markup and prepare it for RegEx 
			Send, ^!+f
			Sleep, (%keyDelay% * 10)

			; Find the portions of the markup that we want to back up, select them all, copy, and
			; then overwrite the full markup
			Send, ^f
			SendInput, % "{^}\t{{}5{}}<section.*class="".*row.*$\n({^}\t(?{!}\t{4}</section>).*$\n)"
				. "*{^}\t{{}5{}}</section>$\n|{^}\t*<title>.*$\n|{^}\t*<body.*$\n|{^}\t*</body.*$\n"
			Send, !{Enter}
			Sleep, (%keyDelay% * 10)
			Send, ^c
			Send, ^a
			Send, ^v

			; Beautify the markup one last time to remove unnecessary leading tabs that were left
			; over from the previous beautification
			Send, ^!+f

			; Insert final blank line for the sake of git
			Send, {Enter}

			; Insert ellipses after breaks in the original markup
			Send, ^f
			SendInput, % "</title>$|<body.*$|</section>(?=\n</body)" 
			Send, !{Enter}
			Send, {Right}{Enter}...{Esc}
		}
		Else
		{
			ErrorBox(ahkThisCmd, "I could not find a Sublime Text 3 process to activate.")
		}
		if (oldKeyDelay) {
			SetKeyDelay, %oldKeyDelay%
		}
	}
	if (oldMatchMode) {
		SetTitleMatchMode, %oldMatchMode%
	}
Return

; TODO: Write hotstring that searches through OUE websites for latest CSS and JS updates
; Regex to match latest update: <ul class="post-revisions">.*?\.php\?revision=[0-9]{1,}">([^<]+)
; After overwriting code with what was found, replace with /1 to isolate 

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> HYPERLINK CHECKING hotstring
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@findHrefsInHtml::
	AppendAhkCmd(":*:@findHrefsInHtml")
	pageContent := TrimAwayBuilderTemplateContentPrev(clipboard)
	pageContent := TrimAwayBuilderTemplateContentNext(pageContent)
	hyperlinkArray := BuildHyperlinkArray(pageContent)
	ExportHyperlinkArray(hyperlinkArray)
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

TrimAwayBuilderTemplateContentPrev(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: TrimAwayBuilderTemplatePageHeader(htmlMarkup)"
	remainder := ""
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)^(?:.(?!<div))*.<div(?:.(?!class=""))*.class=""(?:.(?!page))*.page[^>]*>"
			. "$\r\n"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			StringTrimLeft, remainder, htmlMarkup, % (foundPos + matchLen)
		} else {
			errorMsg := "I could not find the <div...>...</div> containing page content within html"
				. "Markup."
		}
	} else {
		errorMsg := "I was passed an empty HTML markup string."
	}
	if (errorMsg != "") {
		MsgBox, % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
	return remainder
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

TrimAwayBuilderTemplateContentNext(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: TrimAwayBuilderTemplatePageHeader(htmlMarkup)"
	remainder := ""
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)^(?:.(?!</div>))*.</div>$\r\n(?:^.*$\r\n){3}^(?:.(?!</main>))*.</main>$"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			StringLeft, remainder, htmlMarkup, % (foundPos - 1)
		} else {
			errorMsg := "I could not find the closing tag of the <div...>...</div> containing page "
				. "content within htmlMarkup."
		}
	} else {
		errorMsg := "I was passed an empty HTML markup string."
	}
	if (errorMsg != "") {
		MsgBox, % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
	return remainder
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

BuildHyperlinkArray(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: BuildHyperlinkArray(htmlMarkup)"
	hyperlinkArray := undefined
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)<a[^>]*>[^<]*</a>"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			hyperlinkArray := [{position: foundPos, length: matchLen, markup: SubStr(htmlMarkup
				, foundPos, matchLen)}]
			foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen, foundPos + matchLen)
			while (foundPos > 0) {
				hyperlinkArray[hyperlinkArray.Length() + 1] := {position: foundPos
					, length: matchLen, markup: SubStr(htmlMarkup, foundPos, matchLen)}
				foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen, foundPos + matchLen)
			}
			PullHrefsIntoHyperlinkArray(hyperlinkArray)
		} else {
			errorMsg := "I found no hyperlinks in the markup passed to me."
		}
	} else {
		errorMsg := "I was passed an empty markup string."
	}
	if (errorMsg != "") {
		MsgBox, % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
	return hyperlinkArray
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

PullHrefsIntoHyperlinkArray(ByRef hyperlinkArray) {
	regExNeedle := "P)href=""([^""]+)"""
	Loop % hyperlinkArray.Length() {
		foundPos := RegExMatch(hyperlinkArray[A_Index].markup, regExNeedle, match)
		hyperlinkArray[A_Index].href := SubStr(hyperlinkArray[A_Index].markup, matchPos1, matchLen1)
		if (A_Index = hyperlinkArray.Length()) {
			MsgBox, % matchPos1 . ", " matchLen1 . ", " hyperlinkArray[A_Index].href
		}
	}
	; TODO: determine which line hyperlink appears on, then copy the entire line to contents (to 
	; provide context)
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

ExportHyperlinkArray(hyperlinkArray) {
	exportStr := ""
	Loop % hyperlinkArray.Length() {
		if (A_Index > 1) {
			exportStr .= "`n"
		} else {
			exportStr .= "Character Position`tMatch Length`tMarkup`tHref`n"
		}
		exportStr .= hyperlinkArray[A_Index].position . "`t" . hyperlinkArray[A_Index].length 
			. "`t" . hyperlinkArray[A_Index].markup . "`t" . hyperlinkArray[A_Index].href
	}
	if (exportStr != "") {
		clipboard := exportStr
		; TODO: Replace the following MsgBox with a GUI containing a ListView.
		MsgBox, 0x0, % ":*:@findHrefsInHtml"
			, % "I found " . hyperlinkArray.Length() . " hyperlinks in markup copied to clipboard. "
			. "I then overwrote clipboard with the results of my analysis formatted for import into"
			. " Excel."
	}
}
