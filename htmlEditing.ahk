; ===========================================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ===========================================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ===========================================================================================================================

; ---------------------------------------------------------------------------------------------------------------------------
; HOTSTRINGS for text replacement
; ---------------------------------------------------------------------------------------------------------------------------

:R*:@cssShorthandBg::bg-color bg-image position/bg-size bg-repeat bg-origin bg-clip bg-attachment initial|inherit;

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:R*:@findStrBldrSctns::(?<=^---->\r\n)^.*$(?:\r\n^(?!<!--|\r\n<!--|\Z).*$)*

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:R*:@gotoUrlSumResAdmin::https://summerresearch.wsu.edu/wp-admin/
:R*:@gotoUrlSumResUpload::https://summerresearch.wsu.edu/wp-admin/upload.php
:R*:@gotoUrlSumResCss::https://summerresearch.wsu.edu/wp-admin/themes.php?page=editcss
:R*:@gotoUrlSumResJs::https://summerresearch.wsu.edu/wp-admin/themes.php?page=custom-javascript
:R*:@gotoUrlSumResPages::https://summerresearch.wsu.edu/wp-admin/edit.php?post_type=page
:R*:@gotoUrlSumResPosts::https://summerresearch.wsu.edu/wp-admin/edit.php
:R*:@gotoUrlSumResDocs::https://summerresearch.wsu.edu/wp-admin/edit.php?post_type=document
:R*:@gotoUrlSumResRedirects::https://distinguishedscholarships.wsu.edu/wp-admin/edit.php?post_type=redirect_rule

; ---------------------------------------------------------------------------------------------------------------------------
; GUI FUNCTIONS for handling user interactions with scripts
; ---------------------------------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI triggering HOTSTRINGS
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI driving FUNCTIONS
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleInsBldrSctnCancel() {
	Gui, guiInsBldrSctn: Destroy
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleInsBldrSctnOK() {
	global
	Gui, guiInsBldrSctn: Submit
	Gui, guiInsBldrSctn: Destroy
	
	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		if (BldrSctnChosen = 1) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ SINGLE --- Column One                                                                                         1 of 1 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                       § α…ω § ║`r"
				. "---- ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "---->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 2) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ SIDEBAR RIGHT --- Column One                                                                                  1 of 2 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                          § α… ║`r"
				. "---- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---->`r"
				. "`r"
				. "<!-- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ SIDEBAR RIGHT --- Column Two                                                                                  2 of 2 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                          …ω § ║`r"
				. "---- ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "---->`r"
				. "`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 3) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ HALVES --- Column One                                                                                         1 of 2 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                          § α… ║`r"
				. "---- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---->`r"
				. "`r"
				. "<!-- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ HALVES --- Column Two                                                                                         2 of 2 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                          …ω § ║`r"
				. "---- ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "---->`r"
				. "`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 4) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ THIRDS --- Column One                                                                                         1 of 3 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                          § α… ║`r"
				. "---- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---->`r"
				. "`r"
				. "<!-- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ THIRDS --- Column Two                                                                                         2 of 3 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                             … ║`r"
				. "---- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---->`r"
				. "`r"
				. "<!-- ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ THIRDS --- Column Three                                                                                       3 of 3 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                          …ω § ║`r"
				. "---- ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "---->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 5) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "---- ║ #### POST --- WSU SPINE THEME FOR WORDPRESS ######################################################################## ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ Title: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce congue fringilla lorem sit ...                 ║`r"
				. "---- ║  │     ...amet hendrerit.                                                                                            ║`r"
				. "---- ║  ╞═» Permalink: .../...                                                                                              ║`r"
				. "---- ║  ╞═» Thumbnail Image: /wp-content/uploads/sites/.../201./../...                                                      ║`r"
				. "---- ║  │    ...                                                                                                            ║`r"
				. "---- ║  ╘═» Date Posted: ....-..-..                                                                                         ║`r"
				. "---- ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "---->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 6) {
			commentTxt := "<!-- ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "---- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################################# ║`r"
				. "---- ╠======================================================================================================================╣`r"
				. "---- ║ HEADER --- Column One                                                                                         1 of 1 ║`r"
				. "---- ║  ╞═» Section classes: gutter pad-top                                                                                 ║`r"
				. "---- ║  ╞═» Header level: h1                                                                                                ║`r"
				. "---- ║  ╞═» Column classes: N/A                                                                                             ║`r"
				. "---- ║  ╘═» Column title: N/A                                                                                       § α…ω § ║`r"
				. "---- ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "---->`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 7) {
			commentTxt := "---- ║  ╞═» Column background image: N/A                                                                                    ║`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 8) {
			commentTxt := "---- ║  │                                                                                                                   ║`r"
			PasteText(commentTxt)
		} else {
			commentTxt:= "<!-- ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "---- ║ #### PAGE SETTINGS ################################################################################################# ║`r"
				. "---- ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "---->`r"
				. "TITLE: …`r"
				. "URL: /…`r"
			PasteText(commentTxt)
		}
	} else {
		MsgBox, 0
			, % "Error in AHK function: HandleInsBldrSctnOK" ; Title
			, % "An HTML comment for documenting Spine Builder tempalate sections can only be inserted if [Notepad++.exe] is the active process. Unfortunately, the currently active process is [" . thisProcess . "]."			; Message
	}
}

; ---------------------------------------------------------------------------------------------------------------------------
; FUNCTIONS for Quality Control of markup
; ---------------------------------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> HYPERLINK CHECKING hotstring
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@findHrefsInHtml::
	AppendAhkCmd(":*:@findHrefsInHtml")
	pageContent := TrimAwayBuilderTemplateContentPrev(clipboard)
	pageContent := TrimAwayBuilderTemplateContentNext(pageContent)
	hyperlinkArray := BuildHyperlinkArray(pageContent)
	ExportHyperlinkArray(hyperlinkArray)
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

TrimAwayBuilderTemplateContentPrev(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: TrimAwayBuilderTemplatePageHeader(htmlMarkup)"
	remainder := ""
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)^(?:.(?!<div))*.<div(?:.(?!class=""))*.class=""(?:.(?!page))*.page[^>]*>$\r\n"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			StringTrimLeft, remainder, htmlMarkup, % (foundPos + matchLen)
		} else {
			errorMsg := "I could not find the <div...>...</div> containing page content within htmlMarkup."
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

TrimAwayBuilderTemplateContentNext(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: TrimAwayBuilderTemplatePageHeader(htmlMarkup)"
	remainder := ""
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)^(?:.(?!</div>))*.</div>$\r\n(?:^.*$\r\n){3}^(?:.(?!</main>))*.</main>$"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			StringLeft, remainder, htmlMarkup, % (foundPos - 1)
		} else {
			errorMsg := "I could not find the closing tag of the <div...>...</div> containing page content within htmlMarkup."
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

BuildHyperlinkArray(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: BuildHyperlinkArray(htmlMarkup)"
	hyperlinkArray := undefined
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)<a[^>]*>[^<]*</a>"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			hyperlinkArray := [{position: foundPos, length: matchLen, markup: SubStr(htmlMarkup, foundPos, matchLen)}]
			foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen, foundPos + matchLen)
			while (foundPos > 0) {
				hyperlinkArray[hyperlinkArray.Length() + 1] := {position: foundPos, length: matchLen, markup: SubStr(htmlMarkup, foundPos, matchLen)}
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

PullHrefsIntoHyperlinkArray(ByRef hyperlinkArray) {
	regExNeedle := "P)href=""([^""]+)"""
	Loop % hyperlinkArray.Length() {
		foundPos := RegExMatch(hyperlinkArray[A_Index].markup, regExNeedle, match)
		hyperlinkArray[A_Index].href := SubStr(hyperlinkArray[A_Index].markup, matchPos1, matchLen1)
		if (A_Index = hyperlinkArray.Length()) {
			MsgBox, % matchPos1 . ", " matchLen1 . ", " hyperlinkArray[A_Index].href
		}
	}
	;TODO: determine which line hyperlink appears on, then copy the entire line to contents (to provide context)
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

ExportHyperlinkArray(hyperlinkArray) {
	exportStr := ""
	Loop % hyperlinkArray.Length() {
		if (A_Index > 1) {
			exportStr .= "`n"
		} else {
			exportStr .= "Character Position`tMatch Length`tMarkup`tHref`n"
		}
		exportStr .= hyperlinkArray[A_Index].position . "`t" . hyperlinkArray[A_Index].length . "`t" . hyperlinkArray[A_Index].markup . "`t" . hyperlinkArray[A_Index].href
	}
	if (exportStr != "") {
		clipboard := exportStr
		; TODO: Replace the following MsgBox with a GUI containing a ListView.
		MsgBox, 0x0, % ":*:@findHrefsInHtml"
			, % "I found " . hyperlinkArray.Length() . " hyperlinks in markup copied to clipboard. I then overwrote clipboard with the results of my analysis formatted for import into Excel."
	}
}
