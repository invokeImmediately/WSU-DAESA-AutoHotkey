; ==================================================================================================
; regExStrings.ahk: Script for inserting RegEx strings to be used in find/replace editing.
; ==================================================================================================

:*:@findStrLessTocSections1::
	SendInput, % "{^}(\*\*|//)( *)(.*)(§[0-9]{+})(.*)$"
Return

:*:@findStrLessTocSections2::
	SendInput, % "{^} *([0-9]{+}): (?:\**|/*) {{}2{}}(.{+})$"
Return

:*:@replStrLessTocSections2::
	SendInput, % "\1**   \2........................................................................"
		. "........"
Return
