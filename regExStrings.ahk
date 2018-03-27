; ==================================================================================================
; regExStrings.ahk: Script for inserting RegEx strings to be used in find/replace editing.
; ==================================================================================================

:*:@findStrLessTocSections1::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "{^}(\*\*|//)( *)(.*)(§[0-9]{+})(.*)$"
Return

:*:@findStrLessTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "{^} *([0-9]{+}): (?:\**|/*) {{}2{}}(.{+})$"
Return

:*:@replStrLessTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "\1**    \2......................................................................."
		. "........."
Return
