;testFunction(":*:@commitCssUgr", "undergraduateresearch.wsu.edu", "undergraduate-research-custom.less", "undergraduate-research-custom.css", "undergraduate-research-custom.min.css")

testFunction5()

testFunction5() {
	value1 := 5
	value2 := "This is a string"
	testObj := { one: value1, two: value2 }
	MsgBox, % "One: " . testObj.one . "`nTwo: " . testObj.two
	ExitApp
}

testFunction4() {
	WinActivate, % "Free Bible ahk_exe chrome.exe"
	ExitApp
}

testFunction3() {
	array := Object()
	taco := "twenty"
	array[taco] := "Burrito"
	array[twenty] := "Chalupa"
	array["twenty"] := "Gordito"
	MsgBox, % array[taco]
	ExitApp
}

testFunction2() {
	emptyStr := ""
	result := emptyStr == undefined
	MsgBox, %result%
	ExitApp
}

testFunction(ahkCmdName, fpGitFolder, fnLessSrcFile, fnCssbuild, fnMinCssBuild) {
	; Global variable declarations
	global commitCssVars := Object()
	global ctrlCommitCssAlsoCommitLessSrc
	global ctrlCommitCss1stMsg
	global ctrlCommitCss1stMsgCharCount
	global ctrlCommitCss2ndMsg
	global ctrlCommitCss2ndMsgCharCount
	global ctrlCommitCss1stLessMsg
	global ctrlCommitCss1stLessMsgCharCount
	global commitCssDflt1stCommitMsg
	global ctrlCommitCss2ndLessMsg
	global ctrlCommitCss2ndLessMsgCharCount
	
	; Variable initializations
	commitCssVars.ahkCmdName := ahkCmdName
	commitCssVars.fpGitFolder := fpGitFolder
	commitCssVars.fnLessSrcFile := fnLessSrcFile
	commitCssVars.fnCssbuild := fnCssbuild
	commitCssVars.fnMinCssBuild := fnMinCssBuild
	commitCssVars.dflt1stCommitMsg := "Updating custom CSS build with recent submodule changes"
	commitCssVars.dflt1stCommitMsgAlt := "Updating custom CSS build w/ source & submodule changes"
	commitCssVars.dflt2ndCommitMsg := "Rebuilding custom CSS production files to incorporate recent changes "
		. "to OUE-wide build dependencies."
	commitCssVars.dflt2ndCommitMsgAlt := "Rebuilding custom CSS production files to incorporate recent "
		. "changes to site-specific and OUE-wide build dependencies."
	msgLen1st := StrLen(commitCssVars.dflt1stCommitMsg)
	msgLen2nd := StrLen(commitCssVars.dflt2ndCommitMsg)
	
	
	; GUI initialization & display to user
	Gui, guiCommitCssBuild: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCommitCssBuild: Add, Text, , % "&Primary commit message:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss1stMsg gHandleCommitCss1stMsgChange X+5 W606, % commitCssVars.dflt1stCommitMsg
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss1stMsgCharCount Y+1 W500, % "Length = " . msgLen1st . " characters"
	Gui, guiCommitCssBuild: Add, Text, xm Y+12, % "&Secondary commit message:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss2ndMsg gHandleCommitCss2ndMsgChange X+5 W589, % commitCssVars.dflt2ndCommitMsg
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss2ndMsgCharCount Y+1, % "Length = " . msgLen2nd . " characters"
	Gui, guiCommitCssBuild: Add, Checkbox
		, vctrlCommitCssAlsoCommitLessSrc gHandleCommitCssCheckLessFileCommit xm Y+12
		, % "&Also commit less source " . commitCssVars.fnLessSrcFile . "?"
	Gui, guiCommitCssBuild: Add, Text, xm, % "Message for &LESS file changes:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss1stLessMsg X+5 W573 Disabled
	Gui, guiCommitCssBuild: Add, Text, xm, % "Secondary L&ESS message (optional):"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss2ndLessMsg X+5 W549 Disabled
	Gui, guiCommitCssBuild: Add, Button, Default gHandleCommitCssOk xm, &Ok
	Gui, guiCommitCssBuild: Add, Button, gHandleCommitCssCancel X+5, &Cancel
	Gui, guiCommitCssBuild: Show
}

; Triggered when the primary git commit message for the updated CSS builds is changed.
HandleCommitCss1stMsgChange() {
	; Make global variable declarations.
	global ctrlCommitCss1stMsg
	global ctrlCommitCss1stMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitCss1stMsg)
	newCountMsg := "Length = " . msgLen . " characters"
	if (msgLen > 100) {
		MsgBox, %newCountMsg%
	}
	GuiControl, , ctrlCommitCss1stMsgCharCount, %newCountMsg%
}

; Triggered when the secondary git commit message for the updated CSS builds is changed.
HandleCommitCss2ndMsgChange() {
	; Make global variable declarations.
	global ctrlCommitCss2ndMsg
	global ctrlCommitCss2ndMsgCharCount

	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Update character count field
	msgLen := StrLen(ctrlCommitCss2ndMsg)
	GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
}

; Triggered by state changes in checkbox control in guiCommitCssBuild GUI.
HandleCommitCssCheckLessFileCommit() {
	; Make global variable declarations.
	global commitCssVars
	global ctrlCommitCss1stMsg
	global ctrlCommitCss1stMsgCharCount
	global ctrlCommitCss2ndMsg
	global ctrlCommitCss2ndMsgCharCount
	global ctrlCommitCss1stLessMsg
	global ctrlCommitCss2ndLessMsg
	global ctrlCommitCssAlsoCommitLessSrc
	
	; Submit GUI without hiding to update variables storing states of controls.
	Gui, guiCommitCssBuild: Submit, NoHide
	
	; Respond to user input.
	if (ctrlCommitCssAlsoCommitLessSrc) {
		GuiControl, Enable, ctrlCommitCss1stLessMsg
		GuiControl, Enable, ctrlCommitCss2ndLessMsg
		if (ctrlCommitCss1stMsg == commitCssVars.dflt1stCommitMsg) {
			GuiControl, , ctrlCommitCss1stMsg, % commitCssVars.dflt1stCommitMsgAlt
			msgLen := StrLen(commitCssVars.dflt1stCommitMsgAlt)
			GuiControl, , ctrlCommitCss1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitCss2ndMsg == commitCssVars.dflt2ndCommitMsg) {
			GuiControl, , ctrlCommitCss2ndMsg, % commitCssVars.dflt2ndCommitMsgAlt
			msgLen := StrLen(commitCssVars.dflt2ndCommitMsgAlt)
			GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	} else {
		GuiControl, Disable, ctrlCommitCss1stLessMsg
		GuiControl, Disable, ctrlCommitCss2ndLessMsg
		if (ctrlCommitCss1stMsg == commitCssVars.dflt1stCommitMsgAlt) {
			GuiControl, , ctrlCommitCss1stMsg, % commitCssVars.dflt1stCommitMsg
			msgLen := StrLen(commitCssVars.dflt1stCommitMsg)
			GuiControl, , ctrlCommitCss1stMsgCharCount, % "Length = " . msgLen . " characters"
		}
		if (ctrlCommitCss2ndMsg == commitCssVars.dflt2ndCommitMsgAlt) {
			GuiControl, , ctrlCommitCss2ndMsg, % commitCssVars.dflt2ndCommitMsg
			msgLen := StrLen(commitCssVars.dflt2ndCommitMsg)
			GuiControl, , ctrlCommitCss2ndMsgCharCount, % "Length = " . msgLen . " characters"
		}
	}
}

HandleCommitCssOk() {
	Gui, guiCommitCssBuild: Destroy
	ExitApp
}

HandleCommitCssCancel() {
	Gui, guiCommitCssBuild: Destroy
	ExitApp
}
