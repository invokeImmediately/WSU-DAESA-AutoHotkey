; ==================================================================================================
; STARTUP SCRIPTS: Dual-Monitor Windows 10 Desktop PC
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents
; -----------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS........................................................39
;   >>> §1.1: Work environment setup............................................................43
;     →→→ §1.1.1: Hotstring: @setupVirtualDesktops..............................................56
;     →→→ §1.1.2: Hotstring: @setupCiscoVpn.....................................................67
;   >>> §1.2: VD1: Website editing..............................................................84
;     →→→ §1.2.1: Function: PositionWindowViaCtrlFN............................................105
;     →→→ §1.2.2: Hotstring: @moveTempMonitors.................................................119
;     →→→ §1.2.3: Hotstring: @startSublimeText3................................................136
;     →→→ §1.2.4: Hotstring: @startChrome......................................................147
;     →→→ §1.2.5: Hotstring: startMsTodo.......................................................165
;   >>> §1.3: VD2: Programming.................................................................177
;     →→→ §1.3.1: Function: AddSublimeText3ToVd................................................194
;     →→→ §1.3.2: Hotstring: @startGithubClients...............................................236
;     →→→ §1.3.3: Hotstring: @arrangeGitHub....................................................255
;     →→→ §1.3.4: Function: agh_MovePowerShell.................................................280
;   >>> §1.4: Setup VD3: Graphic design........................................................319
;     →→→ §1.4.1: Hotstring: @arrangeGimp......................................................344
;   >>> §1.5: Setup VD4: Communications and media..............................................366
;     →→→ §1.5.1: Function: OpenWebsiteInChrome................................................399
;     →→→ §1.5.2: Function: OpenNewTabInChrome.................................................409
;     →→→ §1.5.3: Function: NavigateToWebsiteInChrome..........................................416
;     →→→ §1.5.4: Function: MoveToNextTabInChrome..............................................425
;     →→→ §1.5.5: Hotstring: @arrangeEmail.....................................................432
;   >>> §1.6: Setup VD5: Diagnostics & talmud..................................................477
;   >>> §1.7: Other setup hotstrings...........................................................523
;     →→→ §1.7.1: Hotstring: @startNotepadPp...................................................526
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS
; --------------------------------------------------------------------------------------------------

; ··································································································
;   >>> §1.1: Work environment setup

:*:@setupWorkEnvironment::
	Gosub, :*:@setupVirtualDesktops
	switchDesktopByNumber(1)
	Gosub, % ":*:@setupCiscoVpn"
	Sleep 330
	SoundPlay, %desktopArrangedSound%
	Gosub, % ":*:@setupWorkTimer"
	switchDesktopByNumber(5)
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.1.1: Hotstring: @setupVirtualDesktops

:*:@setupVirtualDesktops::
	Gosub, :*:@setupVirtualDesktop1
	Gosub, :*:@setupVirtualDesktop2
	Gosub, :*:@setupVirtualDesktop3
	Gosub, :*:@setupVirtualDesktop4
	Gosub, :*:@setupVirtualDesktop5
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.1.2: Hotstring: @setupCiscoVpn

:*:@setupCiscoVpn::
	CheckForCmdEntryGui()
	WinActivate, % "ahk_exe explorer.exe ahk_class Shell_TrayWnd"
	Sleep, 200
	MouseClick, Left, 1678, 16
	Sleep, 1000
	WinActivate, % "Cisco ahk_exe vpnui.exe"
	Sleep, 200	
	MouseClick, Left, 116, 82
	Sleep, 200
	SendInput, % "sslvpn.wsu.edu{Enter}"
Return


; ··································································································
;   >>> §1.2: VD1: Website editing
:*:@setupVirtualDesktop1::
	waitingBeat := 150
	CheckForCmdEntryGui()
	switchDesktopByNumber(1)
	Sleep, % waitingBeat
	Gosub, :*:@moveTempMonitors
	switchDesktopByNumber(1)
	Sleep, % waitingBeat
	Gosub, :*:@startSublimeText3
	Sleep, % waitingBeat * 4
	PositionWindowViaCtrlFN("^F8", waitingBeat)
	Gosub, :*:@startChrome
	Sleep, % waitingBeat * 4
	PositionWindowViaCtrlFN("^F7", waitingBeat)
	Gosub, :*:@startMsTodo
	Sleep, % waitingBeat * 4
	PositionWindowViaCtrlFN("^F10", waitingBeat)
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.2.1: Function: PositionWindowViaCtrlFN
PositionWindowViaCtrlFN(posHotkey, delay) {
	if (posHotkey == "^F6" || posHotkey == "^F7" || posHotkey == "^F8" || posHotkey == "^F9"
			|| posHotkey == "^F10" || posHotkey == "^F11") {
		Gosub % posHotkey
		Sleep, % delay
		SendInput, % "{Enter}"
	} else {
		errorMsg := New GuiMsgBox("Error in " . A_ThisFunc . ": I was passed a window positioning "
			. "hotkey that I do not recognize: " . posHotkey, Func("HandleGuiMsgBoxOk"))
	}
}

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.2.2: Hotstring: @moveTempMonitors
:*:@moveTempMonitors::
	delay := 100

	; Send temperature monitoring programs to desktop #5 from #1
	AppendAhkCmd(":*:@moveTempMonitors")
	WinActivate, % "RealTemp ahk_exe RealTemp.exe"
	Sleep, % delay * 4
	moveActiveWindowToVirtualDesktop(5)
	Sleep, % delay * 2
	WinActivate, % "GPU Temp ahk_exe GPUTemp.exe"
	Sleep, % delay * 4
	moveActiveWindowToVirtualDesktop(5)
	Sleep, % delay * 2
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.2.3: Hotstring: @startSublimeText3
:*:@startSublimeText3::
	; Start up Sublime Text, open a new window, and send the initial, primary instance to desktop #2
	AppendAhkCmd(":*:@startSublimeText3")
	titleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	LaunchApplicationPatiently("C:\Program Files\Sublime Text 3\sublime_text.exe"
		, titleToMatch, "RegEx")
	Sleep, 150
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.2.4: Hotstring: @startChrome
:*:@startChrome::
	waitingBeat := 100 ; ms
	; Start up Chrome and direct it to a WSU WordPress login page; wait for it to load before
	; proceeding
	AppendAhkCmd(":*:@startChrome")
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, % waitingBeat * 10
	SendInput, !d
	Sleep, % waitingBeat / 5
	SendInput, https://distinguishedscholarships.wsu.edu/wp-admin/{Enter}
	Sleep, % waitingBeat
	WaitForApplicationPatiently("WSU Distinguished")
	Sleep, % waitingBeat * 10
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.2.5: Hotstring: startMsTodo
:*:@startMsTodo::
	waitingBeat := 100 ; ms
	; Start up Chrome and direct it to a WSU WordPress login page; wait for it to load before
	; proceeding
	AppendAhkCmd(A_ThisLabel)
	LaunchStdApplicationPatiently("C:\Users\CamilleandDaniel\Desktop\Microsoft To-Do - Shortcut.lnk"
		, "Microsoft To-Do")
	Sleep, % waitingBeat * 10
Return

; ··································································································
;   >>> §1.3: VD2: Programming
:*:@setupVirtualDesktop2::
	delay := 500
	CheckForCmdEntryGui()
	switchDesktopByNumber(2)
	Sleep, % delay
	SendInput, #e
	WaitForApplicationPatiently("File Explorer")
	Sleep, % delay * 2
	AddSublimeText3ToVd(2)
	Sleep, % delay
	switchDesktopByNumber(2)
	Gosub, :*:@startGithubClients
	Gosub, :*:@arrangeGitHub
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.3.1: Function: AddSublimeText3ToVd
AddSublimeText3ToVd(whichVd) {
	oldTitleMatchMode := 0
	delay := 333
	st3TitleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	st3NewWinTitle := "untitled - Sublime ahk_exe sublime_text\.exe"

	; Proceed in RegEx title matching mode
	if (A_TitleMatchMode != "RegEx") {
		SetTitleMatchMode, RegEx
	}
	IfWinExist, %st3TitleToMatch%
	{
		Sleep, % delay
		SafeWinActivate(st3TitleToMatch, "RegEx")
		Sleep, % delay * 2
		st3Vd := GetCurrentVirtualDesktop()

		if (st3Vd != whichVd) {
			SendInput, ^+n
			Sleep, % delay * 3
			WaitForApplicationPatiently(st3NewWinTitle)
			moveActiveWindowToVirtualDesktop(whichVd)
			Sleep, % delay * 3
			switchDesktopByNumber(whichVd)
		} else {
			MsgBox, % "Sublime Text 3 is already on virtual desktop #" . whichVd . "Press OK to try again."
			AddSublimeText3ToVd(whichVd)
		}
	}
	else
	{
		GoSub, :*:@startSublimeText3
	}

	; Restore title matching mode to previous default if needed
	if (oldTitleMatchMode) {
		SetTitleMatchMode, % oldTitleMatchMode		
	}
}

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.3.2: Hotstring: @startGithubClients
:*:@startGithubClients::
	AppendAhkCmd(":*:@startGithubClients")
	Sleep, 330
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	SendInput, !d
	Sleep, 100
	SendInput, https://github.com/invokeImmediately{Enter}
	Sleep, 1000
	LaunchStdApplicationPatiently(userAccountFolderSSD . "\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
		, "GitHub ahk_exe GitHubDesktop.exe")
	Sleep, 1000
	LaunchApplicationPatiently("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
		, "ahk_exe powershell.exe")
	Sleep, 1000
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.3.3: Hotstring: @arrangeGitHub
:*:@arrangeGitHub::
	AppendAhkCmd(":*:@arrangeGitHub")
	WinRestore, GitHub
	Sleep, 200
	WinMove, GitHub, , -1893, 20, 1868, 772
	Sleep, 200
	WinRestore, invokeImmediately
	Sleep, 100
	WinMove, invokeImmediately, , -1830, 0, 1700, 1040
	Sleep, 200
	WinRestore, File Explorer
	Sleep, 100
	WinMove, File Explorer, , 200, 0, 1720, 1040
	Sleep, 200
	WinActivate, ahk_exe sublime_text.exe
	Sleep, 330
	WinRestore, ahk_exe sublime_text.exe
	Sleep, 100
	PositionWindowViaCtrlFN("^F8", 200)
	agh_MovePowerShell()
	Sleep, 200
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.3.4: Function: agh_MovePowerShell
agh_MovePowerShell() {
	beat := 333 ; units = ms, time between operations
	destX := 2313 ; units = pixels, destination X coordinate
	destY := 161 ; units = pixels, destination Y coordinate
	attemptsLimit := 9 ; make repeated attempts over 3 seconds
	attemptsCount := 0
	attemptDelay := beat
	hWnd := WinExist("Administrator: ahk_class ConsoleWindowClass")
	while (!hWnd && attemptsCount <= attemptsLimit) {
		Sleep, % attemptDelay
		hWnd := WinExist("Administrator: ahk_class ConsoleWindowClass")
		attemptsCount++
	}
	if (hWnd) {
		psTitle := "ahk_id " . hWnd ; i.e., PowerShell's identifying criteria
		Sleep, % beat
		WinGetPos, x, y, w, h, % psTitle
		attempts := 0
		while (attempts <= attemptsLimit && (x != destX && y != destY)) {
			WinMove, % psTitle, , % destX, % destY
			attempts++
			Sleep, % beat
			WinGetPos, x, y, w, h, % psTitle
		}
		if (attempts > attemptsLimit && (x != destX && y != destY)) {
			errorMsgBox := New GuiMsgBox("Error in " . A_ThisFunc . ": Failed to move PowerShell "
				. "after " . (beat * attemptsLimit / 1000) . " seconds.", Func("HandleGuiMsgBoxOk")
				, "PowerShellWontMove")
			errorMsgBox.ShowGui()
		}
	} else {
		errorMsgBox := New GuiMsgBox("Error in " . A_ThisFunc . ": Could not find PowerShell."
			, Func("HandleGuiMsgBoxOk"), "NoPowerShell")
		errorMsgBox.ShowGui()
	}
}

; ··································································································
;   >>> §1.4: Setup VD3: Graphic design

:*:@setupVirtualDesktop3::
	CheckForCmdEntryGui()
	switchDesktopByNumber(3)
	Sleep, 150
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	SendInput, !d
	Sleep, 100
	SendInput, http://www.colorhexa.com/{Enter}
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "brand.wsu.edu/visual/colors/{Enter}"
	Sleep, 330
	PositionWindowViaCtrlFN("^F6", 100)
	LaunchStdApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.8.exe", "GNU Image")
	PositionWindowViaCtrlFN("^F8", 100)
	Sleep, 1000
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.4.1: Hotstring: @arrangeGimp

:*:@arrangeGimp::
	AppendAhkCmd(":*:@arrangeGimp")
	WinActivate, Toolbox - Tool Options
	Sleep, 100
	WinMove, Toolbox - Tool Options, , -960, 0, 272, 1040
	Sleep, 100
	WinActivate, Layers
	Sleep, 100
	WinMove, Layers, , -699, 0, 356, 1040
	Sleep, 100
	WinActivate, FG/BG
	Sleep, 100
	WinMove, FG/BG, , -345, 0, 350, 522
	Sleep, 100
	WinActivate, Navigation
	Sleep, 100
	WinMove, Navigation, , -345, 518, 350, 522
Return

; ··································································································
;   >>> §1.5: Setup VD4: Communications and media

:*:@setupVirtualDesktop4::
	CheckForCmdEntryGui()
	switchDesktopByNumber(4)
	Sleep, 150
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, 330
	OpenWebsiteInChrome("mail.google.com", False)
	OpenWebsiteInChrome("mail.live.com")
	OpenWebsiteInChrome("digital.olivesoftware.com/Olive/ODN/SanFranciscoChronicle")
	OpenWebsiteInChrome("news.wsu.edu")
	OpenWebsiteInChrome("dailyevergreen.com")
	OpenWebsiteInChrome("web.wsu.edu")
	OpenWebsiteInChrome("wsu-web.slack.com")
	MoveToNextTabInChrome()
;	LaunchStdApplicationPatiently("C:\Program Files (x86)\Microsoft Office\root\Office16"
;		. "\outlook.exe", "ahk_class MsoSplash ahk_exe OUTLOOK.EXE")
;	Sleep, 5000
;	SendInput, {Enter}
;	Sleep, 1500
;	WaitForApplicationPatiently("Inbox ahk_exe OUTLOOK.EXE")
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Microsoft Office\root\Office16"
		. "\outlook.exe", "Inbox ahk_exe OUTLOOK.EXE")
	LaunchStdApplicationPatiently(userAccountFolderSSD . "\AppData\Local\Wunderlist\Wunderlist.exe"
		, "Inbox - Wunderlist")
	LaunchStdApplicationPatiently("C:\Program Files\iTunes\iTunes.exe", "iTunes")
	Sleep, 1000
	Gosub, :*:@arrangeEmail
Return

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.5.1: Function: OpenWebsiteInChrome
OpenWebsiteInChrome(website, inNewTab := True) {
	website .= "{Enter}"
	if (inNewTab) {
		OpenNewTabInChrome()
	}
	NavigateToWebsiteInChrome(website)
}

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.5.2: Function: OpenNewTabInChrome
OpenNewTabInChrome() {
	SendInput, ^t
	Sleep, 100	
}

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.5.3: Function: NavigateToWebsiteInChrome
NavigateToWebsiteInChrome(website) {
	SendInput, !d
	Sleep, 100
	SendInput, % website
	Sleep, 330
}

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.5.4: Function: MoveToNextTabInChrome
MoveToNextTabInChrome() {
	SendInput, ^{Tab}
	Sleep, 100	
}

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.5.5: Hotstring: @arrangeEmail
:*:@arrangeEmail::
	waitingBeat := 200

	; Register command in history
	AppendAhkCmd(":*:@arrangeEmail")

	; Reposition Outlook
	WinActivate, % "Inbox - ahk_exe outlook.exe"
	Sleep, % waitingBeat
	PositionWindowViaCtrlFN("^F6", 120)
	Sleep, % waitingBeat * 1.25

	; Reposition Chrome window for email and news browsing
	WinActivate, % "Inbox ahk_exe chrome.exe"
	Sleep, % waitingBeat * 1.25
	PositionWindowViaCtrlFN("^F7", 120)
	Sleep, % waitingBeat * 2.25

	; Open second Gmail account
	WinActivate, % "Inbox ahk_exe chrome.exe"
	Sleep, % waitingBeat * 0.5
	MouseMove 1488, 140
	Sleep, % waitingBeat * 0.5
	Send {Click}
	Sleep, % waitingBeat * 15
	MouseMove 1348, 340
	Sleep, % waitingBeat * 0.5
	Send {Click}
	Sleep, % waitingBeat * 2.5

	; Reposition Wunderlist
	WinActivate, % "Inbox - Wunderlist"
	Sleep, % waitingBeat
	PositionWindowViaCtrlFN("^F8", 120)
	Sleep, % waitingBeat * 0.5

	; Reposition iTunes
	WinActivate, % "iTunes ahk_exe iTunes.exe"
	Sleep, % waitingBeat * 0.5
	PositionWindowViaCtrlFN("^F9", 120)
	Sleep, % waitingBeat * 5
Return

; ··································································································
;   >>> §1.6: Setup VD5: Diagnostics & talmud

:*:@setupVirtualDesktop5::
	CheckForCmdEntryGui()
	switchDesktopByNumber(5)
	Sleep, 150
	LaunchStdApplicationPatiently("C:\Windows\System32\taskmgr.exe", "Task Manager")
	Sleep, 1000
	WinMove, % "GPU Temp", , -541, 59, 480, 400
	Sleep, 200
	WinMove, % "RealTemp", , -537, 477, 318, 409
	Sleep, 200
	WinMove, % "Task Manager", , -1528, 184, 976, 600
	Sleep 200
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, 330
	SendInput, !{d}
	Sleep, 100
	SendInput, % "biblegateway.com{Enter}"
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "hebrew4christians.com{Enter}"
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "scripturetyper.com{Enter}"
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "www.blueletterbible.org{Enter}"
	Sleep, 1000
	SendInput, ^{Tab}
	Sleep, 1000
	WinRestore, % "BibleGateway ahk_exe chrome.exe"
	WinMove, % "BibleGateway ahk_exe chrome.exe", , 136, 88, 1648, 874
Return

; ··································································································
;   >>> §1.7: Other setup hotstrings

;  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;     →→→ §1.7.1: Hotstring: @startNotepadPp

:*:@startNotepadPp::
	; Start up Notepad++, open a second instance, and send the initial, primary instance to desktop 
	; #2
	AppendAhkCmd(":*:@startNotepadPp")
	LaunchApplicationPatiently("C:\Program Files\Notepad++\notepad++.exe"
		, "C:\Users ahk_exe notepad++.exe")
	Sleep, 3000
	WinActivate, % "C:\Users ahk_exe notepad++.exe"
	Sleep, 100
	SendInput, ^{End}
	Sleep, 500
	SendInput, !+{F6}
	Sleep, 3000
	SendInput, !{Tab}
	Sleep, 750
	moveActiveWindowToVirtualDesktop(2)
	Sleep, 750
	Gosub % "^F8"
	Sleep, 140
	SendInput, {Enter}
	Sleep, 500
Return

; --------------------------------------------------------------------------------------------------
; §2: STARTUP HOTKEYS
; --------------------------------------------------------------------------------------------------

#!r::
	Gosub, :*:@setupWorkEnvironment
Return

; --------------------------------------------------------------------------------------------------
; §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS
; --------------------------------------------------------------------------------------------------

:*:@quitAhk::
	AppendAhkCmd(":*:@quitAhk")
	PerformScriptShutdownTasks()
	ExitApp
Return

PerformScriptShutdownTasks() {
	SaveAhkCmdHistory()
	SaveCommitCssLessMsgHistory()
	SaveCommitJsCustomJsMsgHistory()
	SaveCommitAnyFileMsgHistory()
}

^#!r::
	PerformScriptShutdownTasks()
	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
Return

ScriptExitFunc(ExitReason, ExitCode) {
	if ExitReason in Logoff, Shutdown, Menu
	{
		PerformScriptShutdownTasks()
	}
}
