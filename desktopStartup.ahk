; ==================================================================================================
; STARTUP SCRIPTS: Dual-Monitor Windows 10 Desktop PC
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents
; -----------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS........................................................43
;     >>> §1.1: Work environment setup..........................................................47
;       →→→ §1.1.1: Hotstring: @setupVirtualDesktops............................................61
;       →→→ §1.1.2: Hotstring: @setupCiscoVpn...................................................78
;     >>> §1.2: VD1: Website editing............................................................92
;       →→→ §1.2.1: PositionWindowViaCtrlFN — Function.........................................109
;       →→→ §1.2.2: @moveTempMonitors — Hotstring..............................................127
;       →→→ §1.2.3: @startSublimeText3 — Hotstring.............................................141
;       →→→ §1.2.4: @startChrome — Hotstring...................................................152
;       →→→ §1.2.5: PositionChromeVD1 — Function...............................................164
;       →→→ §1.2.6: @startMsTodo — Hotstring...................................................179
;       →→→ §1.2.7: PositionMsTodo — Function..................................................189
;     >>> §1.3: VD2: Programming...............................................................206
;       →→→ §1.3.1: Function: AddSublimeText3ToVd..............................................223
;       →→→ §1.3.2: Hotstring: @startGithubClients.............................................265
;       →→→ §1.3.3: Hotstring: @arrangeGitHub..................................................283
;       →→→ §1.3.4: Function: agh_MovePowerShell...............................................308
;     >>> §1.4: Setup VD3: Graphic design......................................................347
;       →→→ §1.4.1: Hotstring: @arrangeGimp....................................................367
;     >>> §1.5: Setup VD4: Communications and media............................................389
;       →→→ §1.5.1: Function: OpenWebsiteInChrome..............................................422
;       →→→ §1.5.2: Function: OpenNewTabInChrome...............................................441
;       →→→ §1.5.3: Function: NavigateToWebsiteInChrome........................................448
;       →→→ §1.5.4: Function: MoveToNextTabInChrome............................................457
;       →→→ §1.5.5: Hotstring: @arrangeEmail...................................................464
;     >>> §1.6: Setup VD5: Diagnostics & talmud................................................509
;     >>> §1.7: Other setup hotstrings.........................................................539
;       →→→ §1.7.1: Hotstring: @startNotepadPp.................................................542
;   §2: STARTUP HOTKEYS........................................................................568
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS................................................576
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: Work environment setup

:*:@setupWorkEnvironment::
	Gosub, :*:@moveTempMonitors
	Gosub, :*:@setupVirtualDesktops
	switchDesktopByNumber(1)
	Gosub, % ":*:@setupCiscoVpn"
	Sleep 330
	SoundPlay, %desktopArrangedSound%
	Gosub, % ":*:@setupWorkTimer"
	switchDesktopByNumber(5)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.2: @moveTempMonitors — Hotstring
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.1: Hotstring: @setupVirtualDesktops

:*:@setupVirtualDesktops::
	delay := g_delayQuantum * 7
	MapDesktopsFromRegistry()
	Sleep, % delay * 4
	Gosub, :*:@setupVirtualDesktop1
	Gosub, :*:@setupVirtualDesktop2
	Gosub, :*:@setupVirtualDesktop3
	Gosub, :*:@setupVirtualDesktop4
	Gosub, :*:@setupVirtualDesktop5
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.2: Hotstring: @setupCiscoVpn

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


;   ································································································
;     >>> §1.2: VD1: Website editing
:*:@setupVirtualDesktop1::
	AppendAhkCmd(A_ThisLabel)
	delay := g_delayQuantum * 7
	switchDesktopByNumber(1)
	Sleep, % delay * 4
	Gosub, :*:@startSublimeText3
	Sleep, % delay * 4
	PositionWindowViaCtrlFN("^F8", delay)
	Gosub, :*:@startChrome
	Sleep, % delay * 4
	OpenWebsiteInChrome("distinguishedscholarships.wsu.edu/wp-admin/", False)
	PositionChromeOnVD1()
	Gosub, :*:@startMsTodo
	PositionMsTodo()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.1: PositionWindowViaCtrlFN — Function
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.3: @startSublimeText3 — Hotstring
:*:@startSublimeText3::
	; Start up Sublime Text, open a new window, and send the initial, primary instance to desktop #2
	AppendAhkCmd(":*:@startSublimeText3")
	titleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	LaunchApplicationPatiently("C:\Program Files\Sublime Text 3\sublime_text.exe"
		, titleToMatch, "RegEx")
	Sleep, 150
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.4: @startChrome — Hotstring
:*:@startChrome::
	delay := g_delayQuantum * 7 ; ms
	; Start up Chrome and direct it to a WSU WordPress login page; wait for it to load before
	; proceeding
	AppendAhkCmd(":*:@startChrome")
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab ahk_exe chrome.exe")
	Sleep, % delay * 10
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.5: PositionChromeVD1 — Function
PositionChromeOnVD1() {
	global g_delayQuantum

	delay := g_delayQuantum * 7
	chromeTitle := "Log In ahk_exe chrome.exe"
	chromeActive := SafeWinActivate(chromeTitle)
	if (chromeActive) {
		PositionWindowViaCtrlFN("^F7", delay)
		Sleep, % delay * 5
		WinMaximize, % chromeTitle
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.6: @startMsTodo — Hotstring
:*:@startMsTodo::
	delay := g_delayQuantum * 7
	AppendAhkCmd(A_ThisLabel)
	LaunchStdApplicationPatiently("C:\Users\CamilleandDaniel\Desktop\Microsoft To-Do - Shortcut.lnk"
		, "Microsoft To-Do")
	Sleep, % delay * 10
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.7: PositionMsTodo — Function
PositionMsTodo() {
	global g_delayQuantum

	delay := g_delayQuantum * 7
	msTodoTitle := "Microsoft To-Do ahk_exe ApplicationFrameHost.exe"
	msTodoActive := SafeWinActivate(msTodoTitle)

	if (msTodoActive) {
		Sleep, % delay * 2
		PositionWindowViaCtrlFN("^F10", delay)
		Sleep, % delay * 5
		WinMaximize, % msTodoTitle
	}
}

;   ································································································
;     >>> §1.3: VD2: Programming
:*:@setupVirtualDesktop2::
	; Initialize local variables
	delay := g_delayQuantum * 32

	; Switch to VD 2
	AppendAhkCmd(A_ThisLabel)
	switchDesktopByNumber(2)
	Sleep, % delay * 2

	; Add Sublime Text 3 to virtual desktop if necessary
	AddSublimeText3ToVd(2)
	Sleep, % delay

	; Open a File Explorer window
	switchDesktopByNumber(2)
	Sleep, % delay
	SendInput, #e
	WaitForApplicationPatiently("This PC")

	; Start GitHub clients
	Gosub, :*:@startGithubClients

	; Restore default arrangement of windows
	Gosub, :*:@arrangeGitHub
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.1: Function: AddSublimeText3ToVd
AddSublimeText3ToVd(whichVd) {
	; Declare global variables
	global g_delayQuantum

	; Initialize local variables
	oldTitleMatchMode := 0
	delay := g_delayQuantum * 21
	st3TitleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	st3NewWinTitle := "untitled - Sublime ahk_exe sublime_text\.exe"

	; Proceed in RegEx title matching mode
	if (A_TitleMatchMode != "RegEx") {
		SetTitleMatchMode, RegEx
	}

	; Add ST3 window to virtual desktop
	IfWinExist, %st3TitleToMatch%
	{
		; Switch to ST3 so that a new window can be generated and moved to the virtual desktop
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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.2: Hotstring: @startGithubClients
:*:@startGithubClients::
	; Initialize local variables
	delay := g_delayQuantum * 21
	AppendAhkCmd(":*:@startGithubClients")
	Sleep, % delay

	; Load GitHub profile in Chrome
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, % delay
	OpenWebsiteInChrome("github.com/invokeImmediately", False)

	; Load GitHub Desktop for Windows
	LaunchStdApplicationPatiently(userAccountFolderSSD . "\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
		, "GitHub ahk_exe GitHubDesktop.exe")
	Sleep, % delay * 3

	; Load a PowerShell console window
	LaunchApplicationPatiently("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
		, "ahk_exe powershell.exe")
	Sleep, % delay * 3
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.3: Hotstring: @arrangeGitHub
:*:@arrangeGitHub::
	; Initialize local variables
	delay := g_delayQuantum * 7

	; Position GitHub Desktop for Windows
	AppendAhkCmd(":*:@arrangeGitHub")
	WinRestore, GitHub
	Sleep, % delay * 2
	WinMove, GitHub, , -1893, 20, 1868, 772
	Sleep, % delay * 2

	; Position chrome window containing tab loaded with GitHub profile
	WinRestore, invokeImmediately
	Sleep, % delay
	WinMove, invokeImmediately, , -1830, 0, 1700, 1040
	Sleep, % delay * 2

	; Position File Explorer window
	WinRestore, File Explorer
	Sleep, % delay
	WinMove, File Explorer, , 200, 0, 1720, 1040
	Sleep, % delay * 2

	; Position Sublime Text 3 window
	WinActivate, ahk_exe sublime_text.exe
	Sleep, % delay * 3
	WinRestore, ahk_exe sublime_text.exe
	Sleep, % delay
	PositionWindowViaCtrlFN("^F8", 200)

	; Position Powershell console window
	agh_MovePowerShell()
	Sleep, % delay * 2
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.4: Function: agh_MovePowerShell
agh_MovePowerShell() {
	; Declare global variables
	global g_delayQuantum

	; Initialize local varaibles
	delay := g_delayQuantum * 21 ; units = ms, time between operations
	destX := 2313 ; units = pixels, destination X coordinate
	destY := 161 ; units = pixels, destination Y coordinate
	attemptsLimit := 9 ; make repeated attempts over 3 seconds
	attemptsCount := 0
	attemptDelay := delay

	; Activate Powershell console window
	hWnd := WinExist("Administrator: ahk_class ConsoleWindowClass")
	while (!hWnd && attemptsCount <= attemptsLimit) {
		Sleep, % attemptDelay
		hWnd := WinExist("Administrator: ahk_class ConsoleWindowClass")
		attemptsCount++
	}

	; Move Powershell console window
	if (hWnd) {
		psTitle := "ahk_id " . hWnd ; i.e., PowerShell's identifying criteria
		Sleep, % delay
		WinGetPos, x, y, w, h, % psTitle
		attempts := 0
		while (attempts <= attemptsLimit && (x != destX && y != destY)) {
			WinMove, % psTitle, , % destX, % destY
			attempts++
			Sleep, % delay
			WinGetPos, x, y, w, h, % psTitle
		}
		if (attempts > attemptsLimit && (x != destX && y != destY)) {
			errorMsgBox := New GuiMsgBox("Error in " . A_ThisFunc . ": Failed to move PowerShell "
				. "after " . (delay * attemptsLimit / 1000) . " seconds.", Func("HandleGuiMsgBoxOk")
				, "PowerShellWontMove")
			errorMsgBox.ShowGui()
		}
	} else {
		errorMsgBox := New GuiMsgBox("Error in " . A_ThisFunc . ": Could not find PowerShell."
			, Func("HandleGuiMsgBoxOk"), "NoPowerShell")
		errorMsgBox.ShowGui()
	}
}

;   ································································································
;     >>> §1.4: Setup VD3: Graphic design

:*:@setupVirtualDesktop3::
	delay := g_delayQuantum * 21
	CheckForCmdEntryGui()
	switchDesktopByNumber(3)
	Sleep, % delay / 2
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	OpenWebsiteInChrome("www.colorhexa.com", False)
	Sleep, % delay
	OpenWebsiteInChrome("brand.wsu.edu/visual/colors")
	Sleep, % delay
	PositionWindowViaCtrlFN("^F6", 100)
	LaunchStdApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.8.exe", "GNU Image")
	PositionWindowViaCtrlFN("^F8", 100)
	Sleep, % delay * 3
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.1: Hotstring: @arrangeGimp

:*:@arrangeGimp::
	AppendAhkCmd(":*:@arrangeGimp")
	WinActivate, Toolbox - Tool Options
	Sleep, 100
	WinMove, Toolbox - Tool Options, , 0, 0, 272, 1040
	Sleep, 100
	WinActivate, Layers
	Sleep, 100
	WinMove, Layers, , 261, 0, 356, 1040
	Sleep, 100
	WinActivate, FG/BG
	Sleep, 100
	WinMove, FG/BG, , 615, 0, 350, 522
	Sleep, 100
	WinActivate, Navigation
	Sleep, 100
	WinMove, Navigation, , 615, 518, 350, 522
Return

;   ································································································
;     >>> §1.5: Setup VD4: Communications and media

:*:@setupVirtualDesktop4::
	; Initialize local variables
	delay := g_delayQuantum * 7
	CheckForCmdEntryGui()
	switchDesktopByNumber(4)

	; Load a Chrome window for this virtual desktop
	Sleep, % delay * 1.5
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, % delay * 10

	; Open default email and news websites in Chrome
	OpenWebsiteInChrome("mail.google.com", False)
	OpenWebsiteInChrome("mail.live.com")
	OpenWebsiteInChrome("digital.olivesoftware.com/Olive/ODN/SanFranciscoChronicle")
	OpenWebsiteInChrome("news.wsu.edu")
	OpenWebsiteInChrome("dailyevergreen.com")
	OpenWebsiteInChrome("web.wsu.edu")
	OpenWebsiteInChrome("wsu-web.slack.com")
	MoveToNextTabInChrome()

	; Load Outlook 365
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Microsoft Office\root\Office16"
		. "\outlook.exe", "Inbox ahk_exe OUTLOOK.EXE")
	LaunchStdApplicationPatiently("C:\Program Files\iTunes\iTunes.exe", "iTunes")
	Sleep, % delay * 10

	; Restore default window arrangement
	Gosub, :*:@arrangeEmail
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.1: Function: OpenWebsiteInChrome
OpenWebsiteInChrome(website, inNewTab := True) {
	; Declare global variables
	global g_delayQuantum
	
	; Initialize local variables
	delay := g_delayQuantum * 7
	website .= "{Enter}"
	attemptCount := 0

	; Begin execution by activating Chrome
	WinGet, procName, ProcessName, A
	while (procName != "chrome.exe" && attemptCount <= 8) {
		Sleep, 250
		WinActivate, % "ahk_exe chrome.exe"
		Sleep, 120
		WinGet, procName, ProcessName, A
		attemptCount++
	}

	; Handle optional opening of new tab
	if (inNewTab) {
		OpenNewTabInChrome()
	}

	; Navigate to the specified website
	NavigateToWebsiteInChrome(website)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.2: Function: OpenNewTabInChrome
OpenNewTabInChrome() {
	; Declare global variables
	global g_delayQuantum

	; Verify that Chrome is active
	WinGet, procName, ProcessName, A
	if (procName == "chrome.exe") {
		; Open a new tab via keyboard shortcut
		SendInput, ^t
		Sleep, % g_delayQuantum * 7	
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.3: Function: NavigateToWebsiteInChrome
NavigateToWebsiteInChrome(website) {
	; Declare global variables
	global g_delayQuantum

	; Verify that Chrome is active
	WinGet, procName, ProcessName, A
	if (procName == "chrome.exe") {
		; Ensure that the address bar has focus via keyboard shortuct
		SendInput, !d
		Sleep, % g_delayQuantum * 7

		; Navigate to the specified URL
		SendInput, % website
		Sleep, % g_delayQuantum * 21
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.4: Function: MoveToNextTabInChrome
MoveToNextTabInChrome() {
	; Declare global variables
	global g_delayQuantum

	; Verify that Chrome is active
	WinGet, procName, ProcessName, A
	if (procName == "chrome.exe") {
		; Move to the next tab via keyboard shortcut
		SendInput, ^{Tab}
		Sleep, % g_delayQuantum * 7
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.5: Hotstring: @arrangeEmail
:*:@arrangeEmail::
	; Initialize local variables
	delay := g_delayQuantum * 14

	; Register command in history
	AppendAhkCmd(":*:@arrangeEmail")

	; Reposition Outlook
	WinActivate, % "Inbox - ahk_exe OUTLOOK.EXE"
	Sleep, % delay * 2
	PositionWindowViaCtrlFN("^F8", delay)
	Sleep, % delay * 1.25
	WinMaximize, A
	Sleep, % delay * 1

	; Reposition Chrome window for email and news browsing
	WinActivate, % "Inbox ahk_exe chrome.exe"
	Sleep, % delay * 1.25
	PositionWindowViaCtrlFN("^F6", delay)
	Sleep, % delay * 2.25

	; Open second Gmail account
	WinActivate, % "Inbox ahk_exe chrome.exe"
	Sleep, % delay * 0.5
	MouseMove 1488, 140
	Sleep, % delay * 0.5
	Send {Click}
	Sleep, % delay * 15
	MouseMove 1348, 340
	Sleep, % delay * 0.5
	Send {Click}
	Sleep, % delay * 2.5
	WinMaximize, A
	Sleep, % delay * 1

	; Reposition iTunes
	WinActivate, % "iTunes ahk_exe iTunes.exe"
	Sleep, % delay * 0.5
	PositionWindowViaCtrlFN("^F10", delay)
	Sleep, % delay * 5
	WinMaximize, A
	Sleep, % delay * 1
Return

;   ································································································
;     >>> §1.6: Setup VD5: Diagnostics & talmud

:*:@setupVirtualDesktop5::
	delay := g_delayQuantum * 7
	CheckForCmdEntryGui()
	switchDesktopByNumber(5)
	Sleep, % delay * 2
	LaunchStdApplicationPatiently("C:\Windows\System32\taskmgr.exe", "Task Manager")
	Sleep, % delay * 10
	WinMove, % "GPU Temp", , -541, 59, 480, 400
	Sleep, % delay * 2
	WinMove, % "RealTemp", , -537, 477, 318, 409
	Sleep, % delay * 2
	WinMove, % "Task Manager", , -1528, 184, 976, 600
	Sleep % delay * 2
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, % delay * 3
	OpenWebsiteInChrome("biblegateway.com", False)
	OpenWebsiteInChrome("hebrew4christians.com")
	OpenWebsiteInChrome("scripturetyper.com")
	OpenWebsiteInChrome("www.blueletterbible.org")
	Sleep, % delay * 10
	SendInput, ^{Tab}
	Sleep, % delay * 10
	WinRestore, % "BibleGateway ahk_exe chrome.exe"
	WinMove, % "BibleGateway ahk_exe chrome.exe", , 136, 88, 1648, 874
Return

;   ································································································
;     >>> §1.7: Other setup hotstrings

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.7.1: Hotstring: @startNotepadPp

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
;   §2: STARTUP HOTKEYS
; --------------------------------------------------------------------------------------------------

#!r::
	Gosub, :*:@setupWorkEnvironment
Return

; --------------------------------------------------------------------------------------------------
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS
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
