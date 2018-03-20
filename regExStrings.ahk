; ==================================================================================================
; regExStrings.ahk: Script for inserting RegEx strings to be used in find/replace editing.
; ==================================================================================================

:*:@findStrLessTocSections::
	SendInput, % "{^}(\*\*|//)( *)(.*)(§[0-9]{+})(.*)$"
Return
