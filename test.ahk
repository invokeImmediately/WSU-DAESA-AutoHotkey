;testFunction(":*:@commitCssUgr", "undergraduateresearch.wsu.edu"
;	, "undergraduate-research-custom.less", "undergraduate-research-custom.css"
;	, "undergraduate-research-custom.min.css")

#include %A_ScriptDir%\guiMsgBox.ahk
#include %A_ScriptDir%\trie.ahk

testFunction13()

testFunction14() {
	string = "The Quick Brown Fox Jumps Over the Lazy Dog"
	MsgBox, % string[2]
	ExitApp
}

testFunction13() {
	myTrie := New Trie("", false)
	myTrie.Insert("tea")
	myTrie.Insert("teavana")
	myTrie.Insert("teava")
	myTrie.Insert("burritos")
	myTrie.Insert("bulls")
	myTrie.Insert("bullspit")
	myTrie.Insert("caca")
	trieWords := myTrie.GetPipedWordsList("te")
	MsgBox, % trieWords
	; PrintArray(trieWords)
	; trieWords := myTrie.GetWordsArray("b")
	; PrintArray(trieWords)
	ExitApp
}

PrintArray(arrayToPrint) {
	msg := ""
	For key, value in arrayToPrint
	{
		if (A_Index != 1) {
			msg .= "`n"
		}
		msg .= value
	}
	MsgBox, % msg
}

testFunction12() {
	testA := New Test()
	testA.foo := 5
	array := testA.children
	array["taco"] := "beef"
	array["burrito"] := "chicken"
	array["enchilada"] := "crab"
	testA.PrintChildren()
	MsgBox, % testA.foo
	ExitApp
}

class Test {
	_children := Object()
	PrintChildren() {
		msg := ""
		idx := 0
		For key, value in (this._children)
		{
			if (idx != 0) {
				msg .= "`n"
			}
			msg .= key . " = " . value
			idx++
		}
		MsgBox, % msg
	}
	children[]
	{
		get {
			return this._children
		}
		set {
			return undefined
		}
	}
	foo[]
	{
		get {
			return this._foo
		}
		set {
			return this._foo := value
		}
	}
}

testFunction11() {
	obj := Object()
	obj["taco"] := "beef"
	msg := "Type of taco = " . obj["taco"] . "`nType of burrito = " . obj["burrito"]
	MsgBox, % msg
	if (obj["burrito"]) {
		MsgBox, % "Burrito exists."
	}
	ExitApp
}

testFunction10() {
	delay := 100
	Sleep (%delay% * 5)
	MsgBox % "Just a test."
	SetTitleMatchMode RegEx
	WinActivate | Washington State University ahk_exe chrome\.exe
	ExitApp	
}

testFunction9() {
	SetTitleMatchMode, RegEx
	testMsgBox := New GuiMsgBox("This is a test", Func("HandleGuiMsgBoxOk"))
	testMsgBox2 := New GuiMsgBox("This is another test", Func("HandleGuiMsgBoxOk"), "Default2"
		, "Oh look, a title!")
	testMsgBox3 := New GuiMsgBox("This should wipe out the other box", Func("HandleGuiMsgBoxOk"))
	testMsgBox.ShowGui()
	testMsgBox2.ShowGui()
	testMsgBox3.ShowGui()
	MsgBox, Testing 4 5 6
}

testFunction8() {
	junkObj := New Junk("testing 1 2 3")
	junkObj.testMe()
	ExitApp
}

class Junk
{
	myStr := ""
	__New(str) {
		this.myStr := str
	}
	testMe() {
		str := this.myStr
		MsgBox %str%
	}
}

testFunction7(Name) {
	gGuiName := Name
	Gui gui%Name%: New
	Gui gui%Name%: Add, Text, , % "This is a test."
	Gui gui%Name%: Add, Button, gHandleOkButtonPress, % "&Ok"
	Gui gui%Name%: Show, w500, % Name
}

HandleOkButtonPress() {
	Gui guiSendMsg: Submit
	Gui guiSendMsg: Destroy
	SetTimer, ExitTimer, -1000
}

ExitTimer() {
	MsgBox, Exiting now.
	ExitApp
}

testFunction6() {
	value := "This is our test's ""string""; it should be displayed right now with escaped quotatio"
		. "n marks"
	escapedValue := EscapeCommitMessage(value)
	MsgBox, % escapedValue
	ExitApp
}

EscapeCommitMessage(msgToEscape) {
	escapedMsg := RegExReplace(msgToEscape, "m)('|"")", "\$1")
	return escapedMsg
}

testFunction5() {
	value1 := 5
	value2 := "'This is a test's ""string"""
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
	commitCssVars.dflt2ndCommitMsg := "Rebuilding custom CSS production files to incorporate "
		. "recent changes to OUE-wide build dependencies."
	commitCssVars.dflt2ndCommitMsgAlt := "Rebuilding custom CSS production files to incorporate "
		. "recent changes to site-specific and OUE-wide build dependencies."
	msgLen1st := StrLen(commitCssVars.dflt1stCommitMsg)
	msgLen2nd := StrLen(commitCssVars.dflt2ndCommitMsg)
	
	
	; GUI initialization & display to user
	Gui, guiCommitCssBuild: New, , % ahkCmdName . " Commit Message Specification"
	Gui, guiCommitCssBuild: Add, Text, , % "&Primary commit message:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss1stMsg gHandleCommitCss1stMsgChange X+5 W606
		, % commitCssVars.dflt1stCommitMsg
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss1stMsgCharCount Y+1 W500, % "Length = " 
		. msgLen1st . " characters"
	Gui, guiCommitCssBuild: Add, Text, xm Y+12, % "&Secondary commit message:"
	Gui, guiCommitCssBuild: Add, Edit, vctrlCommitCss2ndMsg gHandleCommitCss2ndMsgChange X+5 W589
		, % commitCssVars.dflt2ndCommitMsg
	Gui, guiCommitCssbuild: Add, Text, vctrlCommitCss2ndMsgCharCount Y+1, % "Length = " 
		. msgLen2nd . " characters"
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
