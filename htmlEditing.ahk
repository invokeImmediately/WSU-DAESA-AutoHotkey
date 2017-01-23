; ============================================================================================================
; AUTOHOTKEY SCRIPT IMPORT for Working with Github Desktop for Windows
; ============================================================================================================
; AUTOHOTKEY SEND LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

; ------------------------------------------------------------------------------------------------------------
; GUI FUNCTIONS for handling user interactions with scripts
; ------------------------------------------------------------------------------------------------------------

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI DRIVEN HOTSTRINGS --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@insBldrSctn::
	AppendAhkCmd(":*:@insBldrSctn")
	
	Gui, guiInsBldrSctn: New,, % "Post Minified JS to OUE Websites"
	Gui, guiInsBldrSctn: Add, Text,, % "Which OUE Websites would you like to update?"
	Gui, guiInsBldrSctn: Add, Radio, vBldrSctnChosen Checked, % "&Single"
	Gui, guiInsBldrSctn: Add, Radio, , % "Sidebar &Right"
	Gui, guiInsBldrSctn: Add, Radio, , % "&Halves"
	Gui, guiInsBldrSctn: Add, Radio, , % "&Thirds"
	Gui, guiInsBldrSctn: Add, Button, Default gHandleInsBldrSctnOK, &OK
	Gui, guiInsBldrSctn: Add, Button, gHandleInsBldrSctnCancel X+5, &Cancel
	Gui, guiInsBldrSctn: Show
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
; >>> GUI DRIVING FUNCTIONS --  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleInsBldrSctnCancel:
	Gui, guiInsBldrSctn: Destroy
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

HandleInsBldrSctnOK:
	Gui, guiInsBldrSctn: Submit
	Gui, guiInsBldrSctn: Destroy

	WinGet, thisProcess, ProcessName, A
	if (thisProcess = "notepad++.exe") {
		if (BldrSctnChosen = 1) {
			commentTxt := "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "  -- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "  -- ╠=======================================================================================================╣`r"
				. "  -- ║ SINGLE --- Column One                                                                          1 of 1 ║`r"
				. "  -- ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "  -- ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "  -- ║  ╘═» Column title: N/A                                                                        § α…ω § ║`r"
				. "  -- ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "  -->`r"
				. "…`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 2) {
			commentTxt := "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "  -- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "  -- ╠=======================================================================================================╣`r"
				. "  -- ║ SIDEBAR RIGHT --- Column One                                                                   1 of 2 ║`r"
				. "  -- ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "  -- ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "  -- ║  ╘═» Column title: N/A                                                                           § α… ║`r"
				. "  -- ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "  -->`r"
				. "…`r`r"
				. "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "  -- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "  -- ╠=======================================================================================================╣`r"
				. "  -- ║ SIDEBAR RIGHT --- Column Two                                                                   2 of 2 ║`r"
				. "  -- ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "  -- ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "  -- ║  ╘═» Column title: N/A                                                                           …ω § ║`r"
				. "  -- ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "  -->`r"
				. "…`r"
			PasteText(commentTxt)
		} else if (BldrSctnChosen = 3) {
			commentTxt := "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "  -- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "  -- ╠=======================================================================================================╣`r"
				. "  -- ║ HALVES --- Column One                                                                          1 of 2 ║`r"
				. "  -- ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "  -- ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "  -- ║  ╘═» Column title: N/A                                                                           § α… ║`r"
				. "  -- ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "  -->`r"
				. "…`r`r"
				. "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "  -- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "  -- ╠=======================================================================================================╣`r"
				. "  -- ║ HALVES --- Column Two                                                                          2 of 2 ║`r"
				. "  -- ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "  -- ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "  -- ║  ╘═» Column title: N/A                                                                           …ω § ║`r"
				. "  -- ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "  -->`r"
				. "…`r"
			PasteText(commentTxt)
		} else {
			commentTxt := "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "  -- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "  -- ╠=======================================================================================================╣`r"
				. "  -- ║ THIRDS --- Column One                                                                          1 of 3 ║`r"
				. "  -- ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "  -- ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "  -- ║  ╘═» Column title: N/A                                                                           § α… ║`r"
				. "  -- ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "  -->`r"
				. "…`r"
				. "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "  -- ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "  -- ╠=======================================================================================================╣`r"
				. "  -- ║ THIRDS --- Column Two                                                                          2 of 3 ║`r"
				. "  -- ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "  -- ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "  -- ║  ╘═» Column title: N/A                                                                              … ║`r"
				. "  -- ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "  -->`r"
				. "…`r"
				. "<!-- ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗`r"
				. "--   ║ #### BUILDER SECTION --- WSU SPINE THEME FOR WORDPRESS ############################################## ║`r"
				. "--   ╠=======================================================================================================╣`r"
				. "--   ║ THIRDS --- Column Three                                                                        3 of 3 ║`r"
				. "--   ║  ╞═» Section classes: gutter pad-top                                                                  ║`r"
				. "--   ║  ╞═» Column classes: N/A                                                                              ║`r"
				. "--   ║  ╘═» Column title: N/A                                                                           …ω § ║`r"
				. "--   ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝`r"
				. "-->`r"
				. "…`r"
			PasteText(commentTxt)
		}
	} else {
		MsgBox, 0
			, % "Error in AHK function: HandleInsBldrSctnOK" ; Title
			, % "An HTML comment for documenting Spine Builder tempalate sections can only be inserted if [Notepad++.exe] is the active process. Unfortunately, the currently active process is [" . thisProcess . "]."			; Message
	}
Return
