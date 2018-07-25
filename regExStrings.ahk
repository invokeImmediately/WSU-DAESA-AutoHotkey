; ==================================================================================================
; regExStrings.ahk: Script for inserting RegEx strings to be used in find/replace editing.
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: Regex strings for working with Less
; --------------------------------------------------------------------------------------------------

:*:@findStrLessTocSections1::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "(?{<}=[-·]\n){^}(\*\*|//)(\*?/? *)(.*)(§[0-9]{+})(.*)$"
Return

:*:@findStrLessTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "{^} *([0-9]{+}): (?:\**|/*)( {+})(.{+})$"
Return

:*:@replStrLessTocSections2::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "\1**  \2\3......................................................................."
		. "........."
Return

; --------------------------------------------------------------------------------------------------
;   §2: Regex strings for working with HTML
; --------------------------------------------------------------------------------------------------

:*:@findStrNoAltImgTags::
	AppendAhkCmd(A_ThisLabel)
	SendInput, % "<img([{^}>](?{!}alt=))*>"
Return
