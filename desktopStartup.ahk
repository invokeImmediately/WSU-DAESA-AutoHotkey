﻿; ==================================================================================================
; STARTUP SCRIPTS: Dual-Monitor Windows 10 Desktop PC
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================
; Table of Contents
; -----------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS........................................................44
;     >>> §1.1: Work environment setup..........................................................48
;       →→→ §1.2.2: @moveTempMonitors...........................................................67
;       →→→ §1.1.1: @setupVirtualDesktops.......................................................85
;       →→→ §1.1.2: @setupCiscoVpn.............................................................102
;     >>> §1.2: VD1: Website editing...........................................................122
;       →→→ §1.2.1: PositionWindowViaCtrlFN....................................................148
;       →→→ §1.2.3: @startSublimeText3.........................................................163
;       →→→ §1.2.4: @startChrome...............................................................176
;       →→→ §1.2.5: PositionChromeVD1..........................................................189
;       →→→ §1.2.6: Vd1_OpenWorkNotesLog.......................................................203
;       →→→ §1.2.7: @startMsTodo...............................................................256
;       →→→ §1.2.8: PositionMsTodo.............................................................267
;     >>> §1.3: VD2: Programming...............................................................283
;       →→→ §1.3.1: AddSublimeText3ToVd........................................................309
;       →→→ §1.3.2: @startGithubClients........................................................349
;       →→→ §1.3.3: @arrangeGitHub.............................................................368
;       →→→ §1.3.4: agh_MovePowerShell.........................................................405
;     >>> §1.4: Setup VD3: Graphic design......................................................460
;       →→→ §1.4.1: @arrangeGimp...............................................................489
;     >>> §1.5: Setup VD4: Communications and media............................................512
;       →→→ §1.5.1: OpenWebsiteInChrome........................................................546
;       →→→ §1.5.2: OpenNewTabInChrome.........................................................567
;       →→→ §1.5.3: NavigateToWebsiteInChrome..................................................579
;       →→→ §1.5.4: MoveToNextTabInChrome......................................................593
;       →→→ §1.5.5: @arrangeEmail..............................................................605
;     >>> §1.6: Setup VD5: Diagnostics & talmud................................................649
;     >>> §1.7: Other setup hotstrings.........................................................687
;       →→→ §1.7.1: @startNotepadPp............................................................690
;   §2: STARTUP HOTKEYS........................................................................715
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS................................................723
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: Work environment setup

:*:@setupWorkEnvironment::
	delay := GetDelay("medium")
	AppendAhkCmd(A_ThisLabel)
	PrimeVirtualDesktops()
	Sleep %delay%
	Gosub :*:@moveTempMonitors
	Gosub :*:@setupVirtualDesktops
	switchDesktopByNumber(1)
	Gosub % ":*:@setupCiscoVpn"
	Sleep %delay%
	SoundPlay %desktopArrangedSound%
	Gosub % ":*:@setupWorkTimer"
	switchDesktopByNumber(5)
	DisplaySplashText("Desktop set up is complete.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.1: @moveTempMonitors

:*:@moveTempMonitors::
	delay := GetDelay("short")
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Moving temperature monitors.")
	Sleep % delay * 3
	WinActivate % "RealTemp ahk_exe RealTemp.exe"
	Sleep % delay * 4
	moveActiveWindowToVirtualDesktop(5)
	Sleep % delay * 2
	WinActivate % "GPU Temp ahk_exe GPUTemp.exe"
	Sleep % delay * 4
	moveActiveWindowToVirtualDesktop(5)
	Sleep % delay * 2
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.2: @setupVirtualDesktops

:*:@setupVirtualDesktops::
	delay := GetDelay("short")
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Setting up virtual desktops.")
	Sleep % delay * 4
	MapDesktopsFromRegistry()
	Sleep % delay * 4
	Gosub :*:@setupVirtualDesktop1
	Gosub :*:@setupVirtualDesktop2
	Gosub :*:@setupVirtualDesktop3
	Gosub :*:@setupVirtualDesktop4
	Gosub :*:@setupVirtualDesktop5
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.3: @setupCiscoVpn

:*:@setupCiscoVpn::
	delay := GetDelay("short", 2)
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Setting up Cisco VPN for a connection to WSU.")
	Sleep % delay * 2
	WinActivate % "ahk_exe explorer.exe ahk_class Shell_TrayWnd"
	Sleep %delay%
	MouseClick Left, 1678, 16
	Sleep % delay * 5
	WinActivate % "Cisco ahk_exe vpnui.exe"
	Sleep %delay%
	MouseClick Left, 116, 82
	Sleep %delay%
	SendInput % "sslvpn.wsu.edu{Enter}"
Return


;   ································································································
;     >>> §1.2: VD1: Website editing

:*:@setupVirtualDesktop1::
	delay := GetDelay("short")
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(1)
	Sleep % delay * 4
	DisplaySplashText("Setting up virtual desktop #1 for website editing and coding.")

	; Start Sublime Text 3 & restore its default positioning
	AddSublimeText3ToVd(1)
	Sleep % delay * 4
	PositionWindowViaCtrlFN("^F8", delay)

	; Load chrome & navigate to WSUWP login page
	Gosub :*:@startChrome
	Sleep % delay * 4
	OpenWebsiteInChrome("distinguishedscholarships.wsu.edu/wp-admin/", False)

	Gosub :*:@startMsStickyNotes
	PositionMsStickyNotes()

	PositionChromeOnVD1()
	Vd1_OpenWorkNotesLog()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.1: PositionWindowViaCtrlFN

PositionWindowViaCtrlFN(posHotkey, delay) {
	if (posHotkey == "^F6" || posHotkey == "^F7" || posHotkey == "^F8" || posHotkey == "^F9"
			|| posHotkey == "^F10" || posHotkey == "^F11") {
		Gosub % posHotkey
		Sleep % delay
		SendInput % "{Enter}"
	} else {
		errorMsg := New GuiMsgBox("Error in " . A_ThisFunc . ": I was passed a window positioning "
			. "hotkey that I do not recognize: " . posHotkey, Func("HandleGuiMsgBoxOk"))
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.3: @startSublimeText3

:*:@startSublimeText3::
	; Start up Sublime Text, open a new window, and send the initial, primary instance to desktop #2
	delay := GetDelay("short", 2)
	AppendAhkCmd(A_ThisLabel)
	titleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	LaunchApplicationPatiently("C:\Program Files\Sublime Text 3\sublime_text.exe"
		, titleToMatch, mmRegEx)
	Sleep %delay%
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.4: @startChrome

:*:@startChrome::
	delay := GetDelay("long")
	; Start up Chrome and direct it to a WSU WordPress login page; wait for it to load before
	; proceeding
	AppendAhkCmd(A_ThisLabel)
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab ahk_exe chrome.exe")
	Sleep, %delay%
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.5: PositionChromeVD1

PositionChromeOnVD1() {
	delay := GetDelay("short")
	chromeTitle := "Log In ahk_exe chrome.exe"
	chromeActive := SafeWinActivate(chromeTitle)
	if (chromeActive) {
		PositionWindowViaCtrlFN("^F7", delay)
		Sleep % delay * 5
		WinMaximize % chromeTitle
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.6: Vd1_OpenWorkNotesLog — Function

Vd1_OpenWorkNotesLog() {
	Global mmRegEx
	oldTitleMatchMode := 0
	delay := GetDelay("medium")
	st3TitleToMatch := "log_work-notes.txt ahk_exe sublime_text\.exe"
	st3GeneralTitle := "ahk_exe sublime_text\.exe"
	st3NewWinTitle := "untitled - Sublime ahk_exe sublime_text\.exe"

	oldTitleMatchMode := ChangeMatchMode(mmRegEx)
	IfWinExist %st3TitleToMatch%
	{
		; Ensure ST3 is active and restore default position of work notes
		Sleep % delay
		SafeWinActivate(st3TitleToMatch, mmRegEx)
		PositionWindowViaCtrlFN("^F10", delay)
		Sleep % delay * 3
		Loop 3 {
			GoSub % "<^!#Left"
			Sleep % (delay * 2 / 3)
		}

		; Create a new ST3 window and restore its default position on virtual desktop
		SendInput, ^+n
		Sleep % delay * 3
		WaitForApplicationPatiently(st3NewWinTitle)
		PositionWindowViaCtrlFN("^F8", delay)
		Loop 3 {
			GoSub % "<^!#Left"
			Sleep % (delay * 2 / 3)
		}
	} else {
		; Activate existing ST3 process and restore its default position on virtual desktop
		SafeWinActivate(st3GeneralTitle, mmRegEx)
		Sleep % delay
		PositionWindowViaCtrlFN("^F8", delay)
		Sleep % delay * 3
		Loop 3 {
			GoSub % "<^!#Left"
			Sleep % (delay * 2 / 3)
		}

		; Create a new ST3 window, open the work log, and restore its default position
		SendInput ^+n
		Sleep % delay * 3
		WaitForApplicationPatiently(st3NewWinTitle)
		Sleep % delay
		SendInput ^o
		Sleep % delay * 9
		SendInput % "C:\GitHub\log_work-notes.txt{Enter}"
		Sleep % delay * 12
		PositionWindowViaCtrlFN("^F10", delay)
		Sleep % delay * 3
		Loop 3 {
			GoSub % "<^!#Left"
			Sleep % (delay * 2 / 3)
		}
	}
	RestoreMatchMode(oldTitleMatchMode)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.7: @startMsStickyNotes

:*:@startMsStickyNotes::
	delay := GetDelay("long")
	AppendAhkCmd(A_ThisLabel)
	LaunchStdApplicationPatiently("shell:appsFolder\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe!ap"
		. "p", "ahk_exe Explorer.EXE ahk_class ApplicationFrameWindow")
	Sleep, %delay%
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.8: PositionMsTodo

PositionMsStickyNotes() {
	delay := GetDelay("short")
	msStickyNotesTitle := "Microsoft To-Do ahk_exe ApplicationFrameHost.exe"
	msStickyNotesActive := SafeWinActivate(msStickyNotesTitle)

	if (msStickyNotesActive) {
		Sleep % delay * 2
		WinMove 1467, 67
	}
}

;   ································································································
;     >>> §1.3: VD2: Programming

:*:@setupVirtualDesktop2::
	delay := GetDelay("short", 5)
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(2)
	Sleep % delay * 2
	DisplaySplashText("Setting up virtual desktop #2 for coding and source code management.")

	; Load programming IDE, scripting and command-line interface, and coding repository.
	Sleep % delay * 2
	AddSublimeText3ToVd(2)
	Sleep % delay
	switchDesktopByNumber(2)
	Sleep % delay
	SendInput #e
	WaitForApplicationPatiently("This PC")
	Gosub :*:@startGithubClients

	; Restore default arrangement of windows.
	Gosub :*:@arrangeGitHub
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.1: Function: AddSublimeText3ToVd

AddSublimeText3ToVd(whichVd) {
	Global mmRegEx
	delay := GetDelay("medium")
	oldTitleMatchMode := ChangeMatchMode(mmRegEx)
	st3TitleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	st3NewWinTitle := "untitled - Sublime ahk_exe sublime_text\.exe"

	; Add ST3 window to virtual desktop
	; TODO: Check to see if ST3 is already on the virtual desktop.
	IfWinExist, %st3TitleToMatch%
	{
		; Switch to ST3 so that a new window can be generated and moved to the virtual desktop
		Sleep, % delay
		SafeWinActivate(st3TitleToMatch, mmRegEx)
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
	RestoreMatchMode(oldTitleMatchMode)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.2: Hotstring: @startGithubClients

:*:@startGithubClients::
	delay := GetDelay("short")
	AppendAhkCmd(":*:@startGithubClients")
	Sleep % delay
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep % delay
	OpenWebsiteInChrome("github.com/invokeImmediately", False)
	; LaunchStdApplicationPatiently(userAccountFolderSSD . "\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
	; 	, "GitHub ahk_exe GitHubDesktop.exe")
	; Sleep % delay * 3
	LaunchApplicationPatiently("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
		, "ahk_exe powershell.exe")
	Sleep % delay * 3
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.3: Hotstring: @arrangeGitHub

:*:@arrangeGitHub::
	delay := GetDelay("short")
	AppendAhkCmd(A_ThisLabel)

	; Position GitHub Desktop for Windows
	; WinRestore, GitHub
	; Sleep, % delay * 2
	; WinMove, GitHub, , -1893, 20, 1868, 772
	; Sleep, % delay * 2

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
	delay := GetDelay("medium")
	destX := 2313 ; units = pixels, destination X coordinate
	destY := 161 ; units = pixels, destination Y coordinate
	attemptsLimit := 9 ; make repeated attempts over 3 seconds
	attemptsCount := 0
	attemptDelay := delay

	; Activate Powershell console window
	hWnd := WinExist("Administrator: ahk_class ConsoleWindowClass")
	while (!hWnd && attemptsCount <= attemptsLimit) {
		Sleep % attemptDelay
		hWnd := WinExist("Administrator: ahk_class ConsoleWindowClass")
		attemptsCount++
	}

	; Move Powershell console window
	if (hWnd) {
		; Set up a loop for repeated move attemps
		psTitle := "ahk_id " . hWnd ; i.e., PowerShell's identifying criteria
		Sleep % delay
		WinGetPos x, y, w, h, % psTitle
		attempts := 0

		; Execute a loop for repeated move attempts
		while (attempts <= attemptsLimit && (x != destX && y != destY)) {
			WinMove % psTitle, , % destX, % destY
			attempts++
			Sleep % delay
			WinGetPos x, y, w, h, % psTitle
		}

		; If necessary, report failure to move Powershell console window
		if (attempts > attemptsLimit && (x != destX && y != destY)) {
			errorMsgBox := New GuiMsgBox("Error in " . A_ThisFunc . ": Failed to move PowerShell "
				. "after " . (delay * attemptsLimit / 1000) . " seconds.", Func("HandleGuiMsgBoxOk")
				, "PowerShellWontMove")
			errorMsgBox.ShowGui()
		} else {
			Sleep % delay
			WinActivate % psTitle
			Sleep % delay * 2
			Gosub % "<^!+#Left"
		}
	} else {
		; Report failure to activate Powershell console window
		errorMsgBox := New GuiMsgBox("Error in " . A_ThisFunc . ": Could not find PowerShell."
			, Func("HandleGuiMsgBoxOk"), "NoPowerShell")
		errorMsgBox.ShowGui()
	}
}

;   ································································································
;     >>> §1.4: Setup VD3: Graphic design

:*:@setupVirtualDesktop3::
	delay := GetDelay("medium")
	AppendAhkCmd(A_ThisLabel)
	CheckForCmdEntryGui()

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(3)
	Sleep % delay / 2
	DisplaySplashText("Setting up virtual desktop #3 for graphic design.")

	; Load graphics editor and reference materials.
	Sleep % delay * 2
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	OpenWebsiteInChrome("www.colorhexa.com", False)
	Sleep % delay
	OpenWebsiteInChrome("brand.wsu.edu/visual/colors")

	; Restore default arrangement of windows.
	Sleep % delay
	PositionWindowViaCtrlFN("^F10", 100)
	LaunchStdApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.10.exe", "GNU Image")
	Sleep % delay * 3
	PositionWindowViaCtrlFN("^F6", 100)
	Sleep % delay * 3
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.1: Hotstring: @arrangeGimp

:*:@arrangeGimp::
	AppendAhkCmd(A_ThisLabel)
	delay := GetDelay("short")
	WinActivate Toolbox - Tool Options
	Sleep %delay%
	WinMove Toolbox - Tool Options, , 0, 0, 272, 1040
	Sleep %delay%
	WinActivate Layers
	Sleep %delay%
	WinMove Layers, , 261, 0, 356, 1040
	Sleep %delay%
	WinActivate FG/BG
	Sleep %delay%
	WinMove FG/BG, , 615, 0, 350, 522
	Sleep %delay%
	WinActivate, Navigation
	Sleep %delay%
	WinMove Navigation, , 615, 518, 350, 522
Return

;   ································································································
;     >>> §1.5: Setup VD4: Communications and media

:*:@setupVirtualDesktop4::
	AppendAhkCmd(A_ThisLabel)
	delay := GetDelay("short")

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(4)
	Sleep % delay * 1.5
	DisplaySplashText("Setting up virtual desktop #4 for online correspondence.")

	; Load email clients and news websites.
	Sleep % delay * 1.5
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep % delay * 10
	OpenWebsiteInChrome("mail.google.com", False)
	OpenWebsiteInChrome("mail.live.com")
	OpenWebsiteInChrome("digital.olivesoftware.com/Olive/ODN/SanFranciscoChronicle")
	OpenWebsiteInChrome("news.wsu.edu")
	OpenWebsiteInChrome("dailyevergreen.com")
	OpenWebsiteInChrome("web.wsu.edu")
	OpenWebsiteInChrome("wsu-web.slack.com")
	MoveToNextTabInChrome()
	LaunchStdApplicationPatiently("C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE", "Inbox ahk_exe OUTLOOK.EXE")
	LaunchStdApplicationPatiently("shell:appsFolder\AppleInc.iTunes_nzyj5cx40ttqa!iTunes", "iTunes")

	; Restore default arrangement of windows.
	Sleep % delay * 10
	Gosub :*:@arrangeEmail
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.1: OpenWebsiteInChrome

OpenWebsiteInChrome(website, inNewTab := True) {
	delay := GetDelay("short")
	website .= "{Enter}"
	attemptCount := 0
	WinGet procName, ProcessName, A
	while (procName != "chrome.exe" && attemptCount <= 8) {
		Sleep % delay * 2.5
		WinActivate % "ahk_exe chrome.exe"
		Sleep %delay%
		WinGet procName, ProcessName, A
		attemptCount++
	}
	if (inNewTab) {
		OpenNewTabInChrome()
	}
	NavigateToWebsiteInChrome(website)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.2: OpenNewTabInChrome

OpenNewTabInChrome() {
	delay := GetDelay("short")
	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput, ^t
		Sleep, %delay%
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.3: NavigateToWebsiteInChrome

NavigateToWebsiteInChrome(website) {
	delay := GetDelay("short")
	WinGet, procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput, !d
		Sleep, %delay%
		SendInput, % website
		Sleep, % delay * 3
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.4: MoveToNextTabInChrome

MoveToNextTabInChrome() {
	delay := GetDelay("short")
	WinGet procName, ProcessName, A
	if (procName == "chrome.exe") {
		SendInput ^{Tab}
		Sleep %delay%
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.5: @arrangeEmail

:*:@arrangeEmail::
	delay := GetDelay("short", 2)
	AppendAhkCmd(A_ThisLabel)

	; Reposition Outlook
	WinActivate % "Inbox - ahk_exe OUTLOOK.EXE"
	Sleep % delay * 2
	PositionWindowViaCtrlFN("^F8", delay)
	Sleep % delay * 1.25
	WinMaximize A
	Sleep % delay * 1

	; Reposition Chrome window for email and news browsing
	WinActivate % "Inbox ahk_exe chrome.exe"
	Sleep % delay * 1.25
	PositionWindowViaCtrlFN("^F6", delay)
	Sleep % delay * 2.25

	; Open second Gmail account
	WinActivate % "Inbox ahk_exe chrome.exe"
	Sleep % delay * 0.5
	MouseMove 1488, 140
	Sleep % delay * 0.5
	Send {Click}
	Sleep % delay * 15
	MouseMove 1348, 340
	Sleep % delay * 0.5
	Send {Click}
	Sleep % delay * 2.5
	WinMaximize A
	Sleep % delay * 1

	; Reposition iTunes
	WinActivate % "iTunes ahk_exe iTunes.exe"
	Sleep % delay * 0.5
	PositionWindowViaCtrlFN("^F10", delay)
	Sleep % delay * 5
	WinMaximize A
	Sleep % delay * 1
Return

;   ································································································
;     >>> §1.6: Setup VD5: Diagnostics & talmud

:*:@setupVirtualDesktop5::
	delay := GetDelay("short")
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(5)
	Sleep % delay * 2
	DisplaySplashText("Setting up virtual desktop #5 for computer monitoring and Torah study.")

	; Set up computer monitoring apps.
	Sleep % delay * 2
	LaunchStdApplicationPatiently("C:\Windows\System32\taskmgr.exe", "Task Manager")
	Sleep % delay * 10
	WinMove % "GPU Temp", , -541, 59, 480, 400
	Sleep % delay * 2
	WinMove % "RealTemp", , -537, 477, 318, 409
	Sleep % delay * 2
	WinMove % "Task Manager", , -1528, 184, 976, 600
	Sleep % delay * 2
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	
	; Set up apps for Torah study.
	Sleep % delay * 3
	OpenWebsiteInChrome("biblegateway.com", False)
	OpenWebsiteInChrome("hebrew4christians.com")
	OpenWebsiteInChrome("scripturetyper.com")
	OpenWebsiteInChrome("www.blueletterbible.org")
	Sleep % delay * 10
	SendInput ^{Tab}
	Sleep % delay * 10
	WinRestore % "BibleGateway ahk_exe chrome.exe"
	WinMove % "BibleGateway ahk_exe chrome.exe", , 136, 88, 1648, 874
Return

;   ································································································
;     >>> §1.7: Other setup hotstrings

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.7.1: @startNotepadPp

:*:@startNotepadPp::
	delay := GetDelay("short")
	AppendAhkCmd(A_ThisLabel)
	LaunchApplicationPatiently("C:\Program Files\Notepad++\notepad++.exe"
		, "C:\Users ahk_exe notepad++.exe")
	Sleep % delay * 30
	WinActivate, % "C:\Users ahk_exe notepad++.exe"
	Sleep %delay%
	SendInput ^{End}
	Sleep % delay * 5
	SendInput !+{F6}
	Sleep % delay * 30
	SendInput !{Tab}
	Sleep % delay * 7.5
	moveActiveWindowToVirtualDesktop(2)
	Sleep % delay * 7.5
	Gosub % "^F8"
	Sleep % delay * 2
	SendInput {Enter}
	Sleep % delay * 5
Return

; --------------------------------------------------------------------------------------------------
;   §2: STARTUP HOTKEYS
; --------------------------------------------------------------------------------------------------

#!r::
	Gosub :*:@setupWorkEnvironment
Return

; --------------------------------------------------------------------------------------------------
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS
; --------------------------------------------------------------------------------------------------

:*:@quitAhk::
	AppendAhkCmd(A_ThisLabel)
	PerformScriptShutdownTasks()
	ExitApp
Return

PerformScriptShutdownTasks() {
	SaveAhkCmdHistory()
	SaveCommitCssLessMsgHistory()
	SaveCommitJsCustomJsMsgHistory()
	SaveCafMsgHistory()
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
