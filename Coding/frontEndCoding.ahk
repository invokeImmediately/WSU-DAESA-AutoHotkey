﻿; ==================================================================================================
; █▀▀▀ █▀▀▄ ▄▀▀▄ ▐▀▀▄▐▀█▀▌█▀▀▀ ▐▀▀▄ █▀▀▄ ▄▀▀▀ ▄▀▀▄ █▀▀▄ ▀█▀ ▐▀▀▄ █▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
; █▀▀▀ █▄▄▀ █  █ █  ▐  █  █▀▀  █  ▐ █  █ █    █  █ █  █  █  █  ▐ █ ▀▄   █▄▄█ █▀▀█ █▀▄  
; ▀    ▀  ▀▄ ▀▀  ▀  ▐  █  ▀▀▀▀ ▀  ▐ ▀▀▀   ▀▀▀  ▀▀  ▀▀▀  ▀▀▀ ▀  ▐ ▀▀▀▀ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; AutoHotkey script import for supporting front-end web development in the WSUWP environment.
;
; @version 1.1.2
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/Coding/frontEndCoding.ah
;   k
; @license MIT Copyright (c) 2021 Daniel C. Rieck.
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;     and associated documentation files (the “Software”), to deal in the Software without
;     restriction, including without limitation the rights to use, copy, modify, merge, publish,
;     distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;     Software is furnished to do so, subject to the following conditions:
;   The above copyright notice and this permission notice shall be included in all copies or
;     substantial portions of the Software.
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;     BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;     DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: FUNCTIONS utilized in automating HTML-related processes.................................52
;     >>> §1.1: BuildHyperlinkArray.............................................................56
;     >>> §1.2: CopyWebpageSourceToClipboard....................................................94
;     >>> §1.3: CountNewlinesInString..........................................................177
;     >>> §1.4: ExportHyperlinkArray...........................................................190
;     >>> §1.5: PullHrefsIntoHyperlinkArray....................................................215
;   §2: HOTSTRINGS.............................................................................228
;     >>> §2.1: Text Replacement...............................................................232
;       →→→ §2.1.1: CSS shorthand insertion strings............................................235
;       →→→ §2.1.2: URL shortcuts for WSUWP websites...........................................243
;       →→→ §2.1.3: String insertion related to front-end web development......................303
;     >>> §2.2: RegEx..........................................................................317
;     >>> §2.3: Backup HTML of OUE pages.......................................................324
;       →→→ §2.3.1: @backupOuePage.............................................................327
;       →→→ §2.3.2: BackupOueHtml & sub-functions..............................................352
;       →→→ §2.3.3: @backupOuePost.............................................................629
;     >>> §2.4: Hyperlink collection hotstring.................................................657
;     >>> §2.5: Checking for WordPress Updates.................................................726
;   §3: GUI-related hotstrings & functions for automating HTML-related tasks...................731
;     >>> §3.1: Insert Builder Sections GUI....................................................735
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: FUNCTIONS utilized in automating HTML-related processes
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: BuildHyperlinkArray

BuildHyperlinkArray(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: BuildHyperlinkArray(htmlMarkup)"
	hyperlinkArray := undefined
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)<a[^>]*>[^<]*</a>"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			numNewlines := CountNewlinesInString(SubStr(htmlMarkup, 1, foundPos))
			hyperlinkArray := [{position: foundPos - numNewlines, length: matchLen
				, markup: SubStr(htmlMarkup, foundPos, matchLen)}]
			newStart := foundPos + matchLen
			foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen, newStart)
			while (foundPos > 0) {
				numNewlines += CountNewlinesInString(SubStr(htmlMarkup, newStart, foundPos
					- newStart))
				hyperlinkArray[hyperlinkArray.Length() + 1] := {position: foundPos - numNewlines
					, length: matchLen, markup: SubStr(htmlMarkup, foundPos, matchLen)}
				newStart := foundPos + matchLen
				foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen, newStart)
			}
			PullHrefsIntoHyperlinkArray(hyperlinkArray)
		} else {
			errorMsg := "I found no hyperlinks in the markup passed to me."
		}
	} else {
		errorMsg := "I was passed an empty markup string."
	}
	if (errorMsg != "") {
		MsgBox % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
	return hyperlinkArray
}

;   ································································································
;     >>> §1.2: CopyWebpageSourceToClipboard

CopyWebpageSourceToClipboard( webBrowserProcess, correctTitleNeedle, viewSourceTitle, errorMsg ) {
	global execDelayer
	keyDelay := 200
	success := False

	; Use RegEx match mode so that any appearance of "| Washington State University" will easily be
	; found in window titles; this textual phrase is appended to all WSU websites
	oldMatchMode := 0
	if (A_TitleMatchMode != RegEx) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode RegEx
	}

	; Verify chrome as the active process, look for "| Washington State University" in title
	WinGet activeProcess, ProcessName, A
	WinGetActiveTitle processTitle
	if ( !( RegExMatch( activeProcess, webBrowserProcess ) && RegExMatch( processTitle
			, correctTitleNeedle)) ) {
		ErrorBox( A_ThisFunc, errorMsg )
	} else {
		oldKeyDelay := 0
		if (A_KeyDelay != keyDelay)	{
			oldKeyDelay := A_KeyDelay
			SetKeyDelay %keyDelay%
		}

		; Copy the URL of the webpage
		Send !d
		exceDelayer.Wait( "medium" )
		Send ^c
		exceDelayer.Wait( "medium" )
		success := {}
		success.url := Clipboard
		execDelayer.Wait( "long" )
		Send +{F6}
		exceDelayer.Wait( "medium" )

		; Trigger view page source, wait for tab to load
		Send ^u
		WinWaitActive % viewSourceTitle, , 0.5
		idx := 0
		idxLimit := 9
		while( ErrorLevel )
		{
			WinWaitActive % viewSourceTitle, , 0.5
			idx++
			if ( idx >= idxLimit ) {
				ErrorBox( A_ThisFunc, "I timed out while waiting for the view source tab to open." )
				break
			}
		}
		if ( ErrorLevel ) {
			Return
		} else {
			Sleep % keyDelay * 15
		}
		execDelayer.Wait( "long", 2 )

		; Copy the markup and close the tab
		Send ^a
		execDelayer.Wait( "long" )
		Send ^c
		execDelayer.Wait( "medium" )
		Send ^w
		success.code := Clipboard
		execDelayer.Wait( "long" )

		if (oldKeyDelay) {
			SetKeyDelay %oldKeyDelay%
		}
	}

	if (oldMatchMode) {
		SetTitleMatchMode %oldMatchMode%
	}

	Sleep %keyDelay%
	Return success
}

;   ································································································
;     >>> §1.3: CountNewlinesInString

CountNewlinesInString(haystack) {
	numFound := 0
	foundPos := InStr(haystack, "`n")
	while (foundPos > 0) {
		numFound++
		foundPos := InStr(haystack, "`n", false, foundPos + 1)
	}
	Return numFound
}

;   ································································································
;     >>> §1.4: ExportHyperlinkArray

ExportHyperlinkArray(hyperlinkArray, pageContent) {
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
		exportStr .= "`n`nHyperlinks were found in the following markup:`n" . pageContent
		clipboard := exportStr
		; TODO: Replace the following MsgBox with a GUI containing a ListView.
		MsgBox 0x0, % ":*?:@findHrefsInHtml"
			, % "I found " . hyperlinkArray.Length() . " hyperlinks in markup copied to clipboard. "
			. "I then overwrote clipboard with the results of my analysis formatted for import into"
			. " Excel."
	}
}

;   ································································································
;     >>> §1.5: PullHrefsIntoHyperlinkArray

PullHrefsIntoHyperlinkArray(ByRef hyperlinkArray) {
	regExNeedle := "P)href=""([^""]+)"""
	Loop % hyperlinkArray.Length() {
		foundPos := RegExMatch(hyperlinkArray[A_Index].markup, regExNeedle, match)
		hyperlinkArray[A_Index].href := SubStr(hyperlinkArray[A_Index].markup, matchPos1, matchLen1)
	}
	; TODO: determine which line hyperlink appears on, then copy the entire line to contents (to
	; provide context)
}

; --------------------------------------------------------------------------------------------------
;   §2: HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: Text Replacement

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.1: CSS shorthand insertion strings

:*?:@cssShorthandBg::
	SafeSendInput( "bg-color bg-image position/bg-size bg-repeat bg-origin bg-clip bg-attachment init"
		. "ial|inherit;" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.2: URL shortcuts for WSUWP websites

:*?:@setWsuWpDomain::
	; TODO: Write a GUI to set the value of global variable aWsuWpDomain.
Return

InsertWsuWpUrl(slug) {
	global aWsuWpDomain
	if (aWsuWpDomain) {
		SafeSendInput( aWsuWpDomain . slug )
	} else {
		Gosub :*?:@setWsuWpDomain
	}
}

:*?:@gotoUrlAdmin::
	InsertWsuWpUrl("wp-admin/")
Return

:*?:@gotoUrlCss::
	InsertWsuWpUrl("wp-admin/themes.php?page=editcss")
Return

:*?:@gotoUrlDocs::
	InsertWsuWpUrl("wp-admin/edit.php?post_type=document")
Return

:*?:@gotoUrlDomain::
	InsertWsuWpUrl("")
Return

:*?:@gotoUrlEvents::
	InsertWsuWpUrl("wp-admin/edit.php?post_type=tribe_events")
Return

:*?:@gotoUrlJs::
	InsertWsuWpUrl("wp-admin/themes.php?page=custom-javascript")
Return

:*?:@gotoUrlPages::
	InsertWsuWpUrl("wp-admin/edit.php?post_type=page")
Return

:*?:@gotoUrlPosts::
	InsertWsuWpUrl("wp-admin/edit.php")
Return

:*?:@gotoUrlRedirects::
	InsertWsuWpUrl("wp-admin/edit.php?post_type=redirect_rule")
Return

:*?:@gotoUrlTables::
	InsertWsuWpUrl("wp-admin/upload.php")
Return

:*?:@gotoUrlUpload::
	InsertWsuWpUrl("wp-admin/admin.php?page=tablepress")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.1.3: String insertion related to front-end web development

:*?:@insWorkNotesBlock::
	AppendAhkCmd(A_ThisLabel)
	Gosub :?*:@ddd
	SendInput % "--"
	Gosub :?*:@ttc
	SendInput % "────────────────────────────────────────────────────────────┐{Enter}│ Lorem ipsum "
		. "dolor sit amet.                                                   │{Enter}└───┬─────────"
		. "──────────────────────────────────────────────────────────────────┘{Enter}+{Tab}{Tab}└─→"
		. " …{Up 2}{Left 7}+{Right 27}"
Return

;   ································································································
;     >>> §2.2: RegEx

:*?:@findStrBldrSctns::
	SafeSendInput( "(?<={^}---->\r\n){^}.*$(?:\r\n{^}(?{!}<{!}--|\r\n<{!}--|\Z).*$)*" )
Return

;   ································································································
;     >>> §2.3: Backup HTML of OUE pages

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.3.1: @backupOuePage
;
;	Backup the markup used to construct a web page in WSUWP.

:*?:@backupOuePage::
	keyDelay := 140
	webBrowserProcess := "chrome.exe"
	correctTitleNeedle := "\| Washington State University"
	viewSourceTitle := "view-source ahk_exe " . webBrowserProcess
	workingFilePath := A_ScriptDir . "\Local\backupOuePage-workfile.html"
	targetContentNeedle := "{^}(?:\t| )*.*<section.*class="".*row.*$\n({^}.*$\n)*{^}(?:\t| )*</section>$(?=\n{^}(?:\t| )*</div><{!}-- {#}post -->)|{^}(?:\t| )*.*<section.*class="".*row.*$\n({^}.*$\n)*{^}(?:\t| )*</section>$\n{^}</div>(?=(?:\t| )*</div><{!}-- {#}post -->)|{^}(?:\t| )*<title>.*$\n|{^}(?:\t| )*<body.*$\n|{^}(?:\t| )*</body.*$\n"

	AppendAhkCmd( A_ThisLabel )
	DisplaySplashText( "Now backuping up WordPress page on active DAESA website." )
	results := CopyWebpageSourceToClipboard( webBrowserProcess, correctTitleNeedle
		, viewSourceTitle, "Before using this hotstring, please activate a tab of your web browser "
		. "into which a WSU OUE website is loaded.")
	if ( results ) {
		BackupOueHtml( results, workingFilePath, targetContentNeedle, "", keyDelay )
		doneMsg := New GuiMsgBox( "Finished backing up WordPress page on active DAESA website." )
		doneMsg.ShowGui()
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.3.2: BackupOueHtml & sub-functions
;
;	Regardless of the specific post type, backup markup used to construct something in WSUWP.

BackupOueHtml( source, workingFilePath, targetContentNeedle, cleaningNeedle
		, keyDelay ) {
	sublimeTextTitle := "Sublime Text ahk_exe sublime_text.exe"
	oldMatchMode := 0

	if (A_TitleMatchMode != RegEx) {
		oldMatchMode := A_TitleMatchMode
		SetTitleMatchMode RegEx
	}

	oldKeyDelay := 0
	if (A_KeyDelay != keyDelay)	{
		oldKeyDelay := A_KeyDelay
		SetKeyDelay %keyDelay%
	}

	; Switch the active process to Sublime Text 3
	DetectHiddenWindows, On
	IfWinExist, % sublimeTextTitle
	{
		BackupOueHtml_CreateNewFile(source.code, keyDelay)
		fileHdrCmt := BackupOueHtml_SaveToWorkingFile(source.url, workingFilePath, keyDelay)
		BackupOueHtml_FixBadMarkup(keyDelay)
		BackupOueHtml_BeautifyHtml(keyDelay)
		BackupOueHtml_CopyMarkupSections(targetContentNeedle, keyDelay)
		BackupOueHtml_CleanMarkup(cleaningNeedle, keyDelay)
		BackupOueHtml_BeautifyHtml(keyDelay)
		BackupOueHtml_InsertEllipses()
		BackupOueHtml_RemoveBlankLines(keyDelay)
		BackupOueHtml_InsertEofBlankLine(keyDelay)
		BackupOueHtml_ConvertIndentationToTabs(keyDelay)
		BackupOueHtml_InsertFileHeaderComment(fileHdrCmt, keyDelay)
		BackupOueHtml_PerformFinalSave(keyDelay)
	}
	Else
	{
		ErrorBox( A_ThisLabel, "I could not find a Sublime Text 3 process to activate." )
	}
	DetectHiddenWindows, Off

	if (oldKeyDelay) {
		SetKeyDelay %oldKeyDelay%
	}

	if (oldMatchMode) {
		SetTitleMatchMode %oldMatchMode%
	}
}

BackupOueHtml_CreateNewFile( srcCode, keyDelay ) {
	global execDelayer

	WinActivate
	Send ^n
	execDelayer.Wait( keyDelay )
	Send {Esc}
	execDelayer.Wait( "short" )
	if ( Clipboard != srcCode ) {
		Clipboard := srcCode
		execDelayer.Wait( "long" )
	}
	Send ^v
	execDelayer.Wait( keyDelay, 3 )
}

BackupOueHtml_SaveToWorkingFile(url, workingFilePath, keyDelay) {
	global execDelayer

	pathToUse := BackupOueHtml_GetPathFromUrl( url )
	fileHdrCmt := ""

	if ( !pathToUse ) {
		pathToUse := workingFilePath
	} else {
		if ( !FileExist( pathToUse ) ) {
			FileAppend, % "", %pathToUse%
		} else {
			fileHdrCmt := BackupOueHtml_GetFileHeaderComment( pathToUse, keyDelay )
			if ( SubStr( fileHdrCmt, 1, 4 ) != "<!--" ) {
				fileHdrCmt := ""
			}
		}
	}
	SendInput % "^+s"
	execDelayer.Wait( keyDelay * 20 )
	SendInput % "{BackSpace}" . pathToUse
	execDelayer.Wait( keyDelay * 5 )
	SendInput % "{Enter}{Left}{Enter}"
	execDelayer.Wait( keyDelay * 5 )
	return fileHdrCmt
}

BackupOueHtml_GetPathFromUrl( url ) {
	global execDelayer
	global scriptCfg

	repoFp := False
	cfgFile := scriptCfg.daesaRepos
	numRepos := cfgFile.cfgSettings.Length()
	Loop %numRepos% {
		sd := cfgFile.cfgSettings[ A_Index ][ "subdomain" ]
		foundPos := InStr( url, sd )
		if ( foundPos == 9 ) {
			repoFp := cfgFile.cfgSettings[ A_Index ][ "repository" ]
			Break
		}
	}
	if ( repoFp ) {
		repoFp := BackupOueHtml_ConvertUrlToFp( url, sd, repoFp )
	}

	Return repoFp
}

BackupOueHtml_ConvertUrlToFp( url, subdomain, repoFp ) {
	sdLen := StrLen( subdomain ) + 9
	urlLen := StrLen( url )
	if ( urlLen <= sdLen ) {
		urlSubStr := "home"
	} else {
		urlSubStr := SubStr( url, sdLen + 1, urlLen - sdLen - 1 )
		if ( SubStr( urlSubStr, StrLen( urlSubStr ), 1) == "/" ) {
			urlSubStr := SubStr( urlSubStr, 1, StrLen( urlSubStr ) - 1 )
		}
	}
	fpFromUrl := StrReplace( urlSubStr, "/", "_" )
	fpFromUrl := repoFp . "HTML\" . fpFromUrl . ".html"

	return fpFromUrl
}

BackupOueHtml_GetFileHeaderComment( pathToUse, keyDelay ) {
	global execDelayer
	SendInput % "^o"
	execDelayer.Wait( keyDelay * 20 )
	SendInput % "{BackSpace}" . pathToUse
	execDelayer.Wait( keyDelay * 5 )
	SendInput % "{Enter}"
	execDelayer.Wait( keyDelay * 3 )
	SendInput % "^f"
	execDelayer.Wait( keyDelay * 5 )
	SendInput % "{^}<{!}-{{}98{}}$\n({^}--.*$\n){+}{^}-{{}99{}}>$\n"
	execDelayer.Wait( keyDelay * 5 )
	SendInput % "!{Enter}"
	execDelayer.Wait( keyDelay * 3 )
	SendInput % "^c"
	execDelayer.Wait( keyDelay * 3 )
	fileHdrCmt := Clipboard
	execDelayer.Wait( keyDelay * 3 )
	SendInput % "^w"
	execDelayer.Wait( keyDelay * 3 )
	return fileHdrCmt
}

BackupOueHtml_FixBadMarkup( keyDelay ) {
	global execDelayer
	execDelayer.Wait( keyDelay * 10 )
	SendInput, % "^h"
	execDelayer.Wait( keyDelay * 3 )
	SendInput, % "(<br ?/?> ?)\n[\t ]{{}0,{}}"
	execDelayer.Wait( keyDelay * 3 )
	SendInput, % "{Tab}^a{Del}\1"
	execDelayer.Wait( keyDelay * 3 )
	SendInput, % "^!{Enter}"
	execDelayer.Wait( keyDelay * 3 )
	SendInput, % "{Esc}{Right}"
	execDelayer.Wait( keyDelay * 3 )
}

BackupOueHtml_BeautifyHtml(keyDelay) {
	; Trigger the HTMLPrettify package in Sublime Text to clean up markup and prepare it for RegEx
	Send ^k^h
	Sleep % keyDelay * 5
}

BackupOueHtml_CopyMarkupSections(targetContentNeedle, keyDelay) {
	; Find the portions of the markup that we want to back up, select them all, copy, and
	;  then overwrite the full markup
	Send ^f
	SendInput % targetContentNeedle
	Send !{Enter}
	Sleep % keyDelay * 15
	Send ^c
	Send ^a
	Send ^v
}

BackupOueHtml_CleanMarkup(cleaningNeedle, keyDelay) {
	if (cleaningNeedle != "") {
		Send ^h
		Sleep % keyDelay * 2
		SendInput % cleaningNeedle
		Send {Tab}^a{Del}
		Send ^!{Enter}
		Sleep % keyDelay * 2
		Send {Esc}{Right}
		Sleep % keyDelay
	}
}

BackupOueHtml_InsertEllipses() {
	; Insert ellipses after breaks in the original markup
	global execDelayer
	SendInput % "^f"
	execDelayer.Wait( "m" )
	SendInput % "</title>$|<body.*$|</section>(?=\n</body)|</div>(?=\n\t*</body)"
	execDelayer.Wait( "m" )
	SendInput % "!{Enter}"
	execDelayer.Wait( "m" )
	SendInput % "{Right}{Enter}<{!}--...-->{Esc}"
	execDelayer.Wait( "m" )
}

BackupOueHtml_RemoveBlankLines(keyDelay) {
	; Remove extra blank lines that appear throughout the source code file.
	global execDelayer
	SendInput % "{Up}{Down}"
	execDelayer.Wait( keyDelay * 2 )
	SendInput % "^h"
	execDelayer.Wait( keyDelay * 2 )
	SendInput % "{^}[ \t]*$\n"
	execDelayer.Wait( keyDelay * 2 )
	SendInput % "{Tab}^a{Del}"
	execDelayer.Wait( keyDelay * 3 )
	SendInput % "^!{Enter}"
	execDelayer.Wait( keyDelay * 3 )
	SendInput % "{Esc}{Right}"
	execDelayer.Wait( keyDelay * 2 )
}

BackupOueHtml_InsertEofBlankLine(keyDelay) {
	; Insert final blank line for the sake of git
	global execDelayer
	SendInput, % "^{End}"
	execDelayer.Wait( keyDelay )
	SendInput, % "{Enter}"
	execDelayer.Wait( keyDelay )
	SendInput, % "^{Home}"
	execDelayer.Wait( keyDelay )
}

BackupOueHtml_ConvertIndentationToTabs(keyDelay) {
	Sleep % keyDelay
	SendInput ^+p
	Sleep % keyDelay
	SendInput {Backspace}
	Sleep % keyDelay * 4
	SendInput % "Indentation: Convert to Ta"
	Sleep % keyDelay * 8
	SendInput % "{Enter}"
}

BackupOueHtml_InsertFileHeaderComment(fileHdrCmt, keyDelay) {
	global execDelayer
	Clipboard := fileHdrCmt
	execDelayer.Wait( keyDelay * 5 )
	SendInput, % "^v"
	execDelayer.Wait( keyDelay * 3 )
}

BackupOueHtml_PerformFinalSave(keyDelay) {
	; Remove extra line that ends up on line 3.
	Sleep % keyDelay * 8
	SendInput % "^s"
}

BackupOueHtml_RemoveBlankLine3(keyDelay) {
	; Remove extra line that ends up on line 3.
	Send ^g3{Enter}{Backspace}
	Sleep % keyDelay
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.3.3: @backupOuePost
;
;	Backup the markup used to construct a news post in WSUWP.

:*?:@backupOuePost::
	ahkThisCmd := A_ThisLabel
	keyDelay := 140
	webBrowserProcess := "chrome.exe"
	correctTitleNeedle := "\| Washington State University"
	viewSourceTitle := "view-source ahk_exe " . webBrowserProcess
	workingFilePath := "C:\GitHub\WSU-OUE-AutoHotkey\Local\backupOuePost-workfile.html"
	targetContentNeedle := "{^}\t*<div.*class="".*one.*$\n({^}.*$\n)*{^}\t*</div><{!}--/column-->$|"
		. "{^}\t*<title>.*$\n|{^}\t*<body.*$\n|{^}\t*</body.*$\n"
	cleaningNeedle := "<{!}--.*\.?(?:author-avatar|author-link|author-description|author-info|entry"
		. "-meta|/column).*-->"

	AppendAhkCmd(ahkThisCmd)
	DisplaySplashText( "Now backuping up WordPress post on active DAESA website." )
	results := CopyWebpageSourceToClipboard( webBrowserProcess, correctTitleNeedle
		, viewSourceTitle , "Before using this hotstring, please activate a tab of your web browser"
		. " into which a WSU OUE website is loaded." )
	if ( results ) {
		BackupOueHtml( results, workingFilePath, targetContentNeedle, cleaningNeedle, keyDelay )
		DisplaySplashText( "Finished backuping up WordPress post on active DAESA website." )
	}
Return

;   ································································································
;     >>> §2.4: Hyperlink collection hotstring

:*?:@findHrefsInOueHtml::
	AppendAhkCmd(A_ThisLabel)
	pageContent := TrimAwayBuilderTemplateContentPrev(clipboard)
	if (pageContent == "" && CheckForValidOueHtml(clipboard)) {
		pageContent := clipboard
	} else if (pageContent != "") {
		pageContent := TrimAwayBuilderTemplateContentNext(pageContent)
	}
	if (pageContent != "") {
		hyperlinkArray := BuildHyperlinkArray(pageContent)
		ExportHyperlinkArray(hyperlinkArray, pageContent)
	}
Return

TrimAwayBuilderTemplateContentPrev(htmlMarkup) {
	ahkFuncName := A_ThisFunc
	remainder := ""
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)^(?:.(?!<div))*.<div(?:.(?!class=""))*.class=""(?:.(?!page))*.page[^>]*>"
			. "$\r\n"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			StringTrimLeft remainder, htmlMarkup, % (foundPos + matchLen)
		}
	} else {
		errorMsg := "I was passed an empty HTML markup string."
	}
	if (errorMsg != "") {
		MsgBox % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
	return remainder
}

CheckForValidOueHtml(htmlMarkup) {
	ahkFuncName := A_ThisFunc
	needle := "Pm)[ \t\n]*<article|aside|aside|blockquote|div|h1|h2|h3|h4|h5|h6|iframe|nav|ol|p|"
		. "section|ul[^>]*>"
	foundPos := RegExMatch(htmlMarkup, needle, foundPos)
	return foundPos > 0
}

TrimAwayBuilderTemplateContentNext(htmlMarkup) {
	ahkFuncName := "htmlEditing.ahk: TrimAwayBuilderTemplatePageHeader(htmlMarkup)"
	remainder := ""
	if (htmlMarkup != undefined) {
		regExNeedle := "Pm)^(?:.(?!</div>))*.</div>$\r\n(?:^.*$\r\n){3}^(?:.(?!</main>))*.</main>$"
		foundPos := RegExMatch(htmlMarkup, regExNeedle, matchLen)
		if (foundPos > 0) {
			StringLeft remainder, htmlMarkup, % (foundPos - 1)
		} else {
			errorMsg := "I could not find the closing tag of the <div...>...</div> containing page "
				. "content within htmlMarkup."
		}
	} else {
		errorMsg := "I was passed an empty HTML markup string."
	}
	if (errorMsg != "") {
		MsgBox % (0x0 + 0x10)
			, % "Error in " . ahkFuncName
			, % errorMsg
	}
	return remainder
}

;   ································································································
;     >>> §2.5: Checking for WordPress updates

#Include %A_ScriptDir%\Coding\wordPress.ahk

; --------------------------------------------------------------------------------------------------
;   §3: GUI-related hotstrings & functions for automating HTML-related tasks
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: Insert Builder Sections GUI

:*?:@insBldrSctn::
	AppendAhkCmd(":*?:@insBldrSctn")

	Gui guiInsBldrSctn: New,, % "Post Minified JS to OUE Websites"
	Gui guiInsBldrSctn: Add, Text,, % "Which OUE Websites would you like to update?"
	Gui guiInsBldrSctn: Add, Radio, vBldrSctnChosen Checked, % "&Single"
	Gui guiInsBldrSctn: Add, Radio, , % "Sidebar &Right"
	Gui guiInsBldrSctn: Add, Radio, , % "&Halves"
	Gui guiInsBldrSctn: Add, Radio, , % "&Thirds"
	Gui guiInsBldrSctn: Add, Radio, , % "&Post"
	Gui guiInsBldrSctn: Add, Radio, , % "H&eader"
	Gui guiInsBldrSctn: Add, Radio, , % "Column background &image"
	Gui guiInsBldrSctn: Add, Radio, , % "&Blank commenting line"
	Gui guiInsBldrSctn: Add, Radio, , % "Pa&ge settings"
	Gui guiInsBldrSctn: Add, Button, Default gHandleInsBldrSctnOK, &OK
	Gui guiInsBldrSctn: Add, Button, gHandleInsBldrSctnCancel X+5, &Cancel
	Gui guiInsBldrSctn: Show
Return

HandleInsBldrSctnCancel() {
	Gui, guiInsBldrSctn: Destroy
}

HandleInsBldrSctnOK() {
	global
	Gui guiInsBldrSctn: Submit
	Gui guiInsBldrSctn: Destroy

	WinGet thisProcess, ProcessName, A
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
		MsgBox 0
			, % "Error in AHK function: HandleInsBldrSctnOK" ; Title
			, % "An HTML comment for documenting Spine Builder tempalate sections can only be inser"
				. "ted if [Notepad++.exe] is the active process. Unfortunately, the currently activ"
				. "e process is [" . thisProcess . "]."
	}
}
