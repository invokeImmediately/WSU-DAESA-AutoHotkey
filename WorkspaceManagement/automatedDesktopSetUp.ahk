; ==================================================================================================
; automatedDesktopSetUp.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Script for setting up the desktop upon session startup.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck.
;
;   Permission to use, copy, modify, and/or distribute this software for any purpose with or
;   without fee iOs hereby granted, provided that the above copyright notice and this permission
;   notice appear in all copies.
;
;   THE SOFTWARE IS PROVIDED "AS IS" AND DANIEL RIECK DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
;   SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
;   DANIEL RIECK BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
;   DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
;   CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;   PERFORMANCE OF THIS SOFTWARE.
; ==================================================================================================

; ==================================================================================================
; Table of Contents:
; -----------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS........................................................71
;     >>> §1.1: Work environment setup..........................................................75
;       →→→ §1.1.1: @setupWorkEnvironment.......................................................78
;       →→→ §1.1.2: @moveTempMonitors...........................................................96
;       →→→ §1.1.3: @setupVirtualDesktops......................................................113
;       →→→ §1.1.4: @setupCiscoVpn.............................................................130
;     >>> §1.2: VD1—Website editing............................................................149
;       →→→ §1.2.1: @setupVirtualDesktop1......................................................152
;       →→→ §1.2.2: PositionWindowViaCtrlFN(…).................................................180
;       →→→ §1.2.3: @startSublimeText3.........................................................197
;       →→→ §1.2.4: @startChrome...............................................................209
;       →→→ §1.2.5: PositionChromeVD1()........................................................221
;       →→→ §1.2.6: Vd1_OpenWorkNotesLog().....................................................236
;       →→→ §1.2.7: @startMsStickyNotes........................................................300
;       →→→ §1.2.8: PositionMsStickyNotes()....................................................310
;     >>> §1.3: VD2—Programming................................................................324
;       →→→ §1.3.1: @setupVirtualDesktop2......................................................327
;       →→→ §1.3.2: AddSublimeText3ToVd()......................................................352
;       →→→ §1.3.3: @startGithubClients........................................................388
;       →→→ §1.3.4: @arrangeGitHub.............................................................406
;       →→→ §1.3.5: agh_MovePowerShell().......................................................442
;     >>> §1.4: Setup VD3—Graphic design.......................................................497
;       →→→ §1.4.1: @setupVirtualDesktop4......................................................500
;       →→→ §1.4.2: svd3_OpenGraphicsReferences(…).............................................518
;       →→→ §1.4.3: svd3_OpenGimp(…)...........................................................530
;       →→→ §1.4.4: @arrangeGimp...............................................................542
;     >>> §1.5: Setup VD4—Communications and media.............................................565
;       →→→ §1.5.1: @setupVirtualDesktop4......................................................568
;       →→→ §1.5.2: svd4_LoadWebEmailClients(…)................................................589
;       →→→ §1.5.3: @arrangeEmail..............................................................609
;     >>> §1.6: Setup VD5—Talmud...............................................................643
;       →→→ §1.6.1: @setupVirtualDesktop5......................................................646
;     >>> §1.7: Setup VD7—Diagnostics & XAMPP..................................................696
;       →→→ §1.7.1: @setupVirtualDesktop6......................................................699
;   §2: STARTUP HOTKEYS........................................................................723
;     >>> §2.1: #!r............................................................................727
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS................................................734
;     >>> §3.1: @quitAhk.......................................................................738
;     >>> §3.2: PerformScriptShutdownTasks()...................................................747
;     >>> §3.3: ^#!r...........................................................................757
;     >>> §3.4: ScriptExitFunc(…)..............................................................766
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: VIRTUAL DESKTOP SETUP HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: Work environment setup

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.1: @setupWorkEnvironment

:*:@setupWorkEnvironment::
	AppendAhkCmd(A_ThisLabel)
	PrimeVirtualDesktops()
	execDelayer.Wait( "m" )
	Gosub :*:@moveTempMonitors
	Gosub :*:@setupVirtualDesktops
	switchDesktopByNumber(1)
	Gosub % ":*:@setupCiscoVpn"
	execDelayer.Wait( "m" )
	SoundPlay %desktopArrangedSound%
	Gosub % ":*:@setupWorkTimer"
	switchDesktopByNumber(5)
	DisplaySplashText("Desktop set up is complete.")
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.2: @moveTempMonitors

:*:@moveTempMonitors::
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Moving temperature monitors.")
	execDelayer.Wait( "s", 3 )
	WinActivate % "RealTemp ahk_exe RealTemp.exe"
	execDelayer.Wait( "s", 4 )
	moveActiveWindowToVirtualDesktop(6)
	execDelayer.Wait( "s", 2 )
	WinActivate % "GPU Temp ahk_exe GPUTemp.exe"
	execDelayer.Wait( "s", 4 )
	moveActiveWindowToVirtualDesktop(6)
	execDelayer.Wait( "s", 2 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.3: @setupVirtualDesktops

:*:@setupVirtualDesktops::
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Setting up virtual desktops.")
	execDelayer.Wait( "s", 4 )
	MapDesktopsFromRegistry()
	execDelayer.Wait( "s", 4 )
	Gosub :*:@setupVirtualDesktop1
	Gosub :*:@setupVirtualDesktop2
	Gosub :*:@setupVirtualDesktop3
	Gosub :*:@setupVirtualDesktop4
	Gosub :*:@setupVirtualDesktop5
	Gosub :*:@setupVirtualDesktop6
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.4: @setupCiscoVpn

:*:@setupCiscoVpn::
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Setting up Cisco VPN for a connection to WSU.")
	execDelayer.Wait( "s", 4 )
	WinActivate % "ahk_exe explorer.exe ahk_class Shell_TrayWnd"
	execDelayer.Wait( "s", 2 )
	MouseClick Left, 1678, 16
	execDelayer.Wait( "s", 10 )
	WinActivate % "Cisco ahk_exe vpnui.exe"
	execDelayer.Wait( "s", 2 )
	MouseClick Left, 116, 82
	execDelayer.Wait( "s", 2 )
	SendInput % "sslvpn.wsu.edu{Enter}"
Return


;   ································································································
;     >>> §1.2: VD1—Website editing

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.1: @setupVirtualDesktop1

:*:@setupVirtualDesktop1::
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(1)
	execDelayer.Wait( "s", 4 )
	DisplaySplashText("Setting up virtual desktop #1 for website editing and coding.")

	; Start Sublime Text 3 & restore its default positioning
	AddSublimeText3ToVd(1)
	execDelayer.Wait( "s", 4 )
	PositionWindowViaCtrlFN( "^F8", execDelayer.InterpretDelayString( "s" ) * 4 )

	; Load chrome & navigate to WSUWP login page
	Gosub :*:@startChrome
	execDelayer.Wait( "s", 4 )
	OpenWebsiteInChrome("distinguishedscholarships.wsu.edu/wp-admin/", False)

	Gosub :*:@startMsStickyNotes
	PositionMsStickyNotes()

	PositionChromeOnVD1()
	Vd1_OpenWorkNotesLog()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.2: PositionWindowViaCtrlFN(…)

PositionWindowViaCtrlFN(posHotkey, delay) {
	global execDelayer

	if ( posHotkey == "^F6" || posHotkey == "^F7" || posHotkey == "^F8" || posHotkey == "^F9"
			|| posHotkey == "^F10" || posHotkey == "^F11" ) {
		Gosub % posHotkey
		execDelayer.Wait( delay )
		SendInput % "{Enter}"
	} else {
		errorMsg := New GuiMsgBox( "Error in " . A_ThisFunc . ": I was passed a window positioning "
			. "hotkey that I do not recognize: " . posHotkey )
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.3: @startSublimeText3

:*:@startSublimeText3::
	; Start up Sublime Text, open a new window, and send the initial, primary instance to desktop #2
	AppendAhkCmd(A_ThisLabel)
	titleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	LaunchApplicationPatiently("C:\Program Files\Sublime Text 3\sublime_text.exe"
		, titleToMatch, mmRegEx)
	execDelayer.Wait( "s", 2 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.4: @startChrome

:*:@startChrome::
	; Start up Chrome and direct it to a WSU WordPress login page; wait for it to load before
	; proceeding
	AppendAhkCmd(A_ThisLabel)
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab ahk_exe chrome.exe")
	execDelayer.Wait( "l" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.5: PositionChromeVD1()

PositionChromeOnVD1() {
	global execDelayer

	chromeTitle := "Log In ahk_exe chrome.exe"
	chromeActive := SafeWinActivate(chromeTitle)
	if (chromeActive) {
		PositionWindowViaCtrlFN("^F7", execDelayer.InterpretDelayString( "s" ) * 5 )
		execDelayer.Wait( "s", 5 )
		WinMaximize % chromeTitle
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.6: Vd1_OpenWorkNotesLog()

Vd1_OpenWorkNotesLog() {
	global mmRegEx
	global execDelayer

	oldTitleMatchMode := 0
	st3TitleToMatch := "log_work-notes.txt ahk_exe sublime_text\.exe"
	st3GeneralTitle := "ahk_exe sublime_text\.exe"
	st3NewWinTitle := "untitled - Sublime ahk_exe sublime_text\.exe"

	oldTitleMatchMode := ChangeMatchMode(mmRegEx)
	IfWinExist %st3TitleToMatch%
	{
		; Ensure ST3 is active and restore default position of work notes
		execDelayer.Wait( "m" )
		SafeWinActivate(st3TitleToMatch, mmRegEx)
		PositionWindowViaCtrlFN("^F10", execDelayer.InterpretDelayString( "m" ) )
		execDelayer.Wait( "m", 3 )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m", 2 / 3 )
		}

		; Create a new ST3 window and restore its default position on virtual desktop
		SendInput, ^+n
		execDelayer.Wait( "m", 3 )
		WaitForApplicationPatiently(st3NewWinTitle)
		PositionWindowViaCtrlFN("^F8", execDelayer.InterpretDelayString( "m" ) )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m", 2 / 3 )
		}
	} else {
		; Activate existing ST3 process and restore its default position on virtual desktop
		SafeWinActivate(st3GeneralTitle, mmRegEx)
		execDelayer.Wait( "m" )
		PositionWindowViaCtrlFN("^F8", execDelayer.InterpretDelayString( "m" ) )
		execDelayer.Wait( "m", 3 )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m", 2 / 3 )
		}

		; Create a new ST3 window, open the work log, and restore its default position
		SendInput ^+n
		execDelayer.Wait( "m", 3 )
		WaitForApplicationPatiently(st3NewWinTitle)
		execDelayer.Wait( "m" )
		SendInput ^o
		execDelayer.Wait( "m", 9 )
		SendInput % "C:\GitHub\log_work-notes.txt{Enter}"
		execDelayer.Wait( "m", 12 )
		PositionWindowViaCtrlFN("^F10", execDelayer.InterpretDelayString( "m" ) )
		execDelayer.Wait( "m", 3 )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m", 2 / 3 )
		}
	}
	RestoreMatchMode(oldTitleMatchMode)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.7: @startMsStickyNotes

:*:@startMsStickyNotes::
	AppendAhkCmd(A_ThisLabel)
	LaunchStdApplicationPatiently("shell:appsFolder\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe!ap"
		. "p", "ahk_exe Explorer.EXE ahk_class ApplicationFrameWindow")
	execDelayer.Wait( "l" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.8: PositionMsStickyNotes()

PositionMsStickyNotes() {
	global execDelayer

	msStickyNotesTitle := "ahk_exe Explorer.EXE ahk_class ApplicationFrameWindow"
	msStickyNotesActive := SafeWinActivate(msStickyNotesTitle)
	if (msStickyNotesActive) {
		execDelayer.Wait( "s", 2 )
		WinMove A, , 1400, 67, 470, 906
	}
}

;   ································································································
;     >>> §1.3: VD2—Programming

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.1: setupVirtualDesktop2

:*:@setupVirtualDesktop2::
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(2)
	execDelayer.Wait( "s", 10 )
	DisplaySplashText("Setting up virtual desktop #2 for coding and source code management.")

	; Load programming IDE, scripting and command-line interface, and coding repository.
	execDelayer.Wait( "s", 10 )
	AddSublimeText3ToVd(2)
	execDelayer.Wait( "s", 5 )
	switchDesktopByNumber(2)
	execDelayer.Wait( "s", 5 )
	SendInput #e
	WaitForApplicationPatiently("This PC")
	Gosub :*:@startGithubClients

	; Restore default arrangement of windows.
	Gosub :*:@arrangeGitHub
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.2: AddSublimeText3ToVd(…)

AddSublimeText3ToVd(whichVd) {
	global mmRegEx
	global execDelayer

	oldTitleMatchMode := ChangeMatchMode(mmRegEx)
	st3TitleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	st3NewWinTitle := "untitled - Sublime ahk_exe sublime_text\.exe"

	; Add ST3 window to virtual desktop
	; TODO: Check to see if ST3 is already on the virtual desktop.
	IfWinExist, %st3TitleToMatch%
	{
		; Switch to ST3 so that a new window can be generated and moved to the virtual desktop
		execDelayer.InterpretDelayString( "m" )
		SafeWinActivate(st3TitleToMatch, mmRegEx)
		execDelayer.InterpretDelayString( "m", 2 )
		st3Vd := GetCurrentVirtualDesktop()
		if (st3Vd != whichVd) {
			SendInput, ^+n
			execDelayer.InterpretDelayString( "m", 3 )
			WaitForApplicationPatiently(st3NewWinTitle)
			moveActiveWindowToVirtualDesktop(whichVd)
			execDelayer.InterpretDelayString( "m", 3 )
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
;       →→→ §1.3.3: @startGithubClients

:*:@startGithubClients::
	AppendAhkCmd( A_ThisLabel )
	execDelayer.Wait( "s" )
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	execDelayer.Wait( "s" )
	OpenWebsiteInChrome("github.com/invokeImmediately", False)
	; LaunchStdApplicationPatiently(userAccountFolderSSD . "\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
	; 	, "GitHub ahk_exe GitHubDesktop.exe")
	; Sleep % delay * 3
	LaunchApplicationPatiently("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
		, "ahk_exe powershell.exe")
	execDelayer.Wait( "s", 3 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.4: @arrangeGitHub

:*:@arrangeGitHub::
	AppendAhkCmd(A_ThisLabel)

	; Position GitHub Desktop for Windows
	; WinRestore, GitHub
	; Sleep, % delay * 2
	; WinMove, GitHub, , -1893, 20, 1868, 772
	; Sleep, % delay * 2

	; Position chrome window containing tab loaded with GitHub profile
	WinRestore, invokeImmediately
	execDelayer.Wait( "s" )
	WinMove, invokeImmediately, , Mon1WorkArea_Left + 90, 0, 1700, 1040
	execDelayer.Wait( "s", 2 )

	; Position File Explorer window
	WinRestore, File Explorer
	execDelayer.Wait( "s" )
	WinMove, File Explorer, , Mon1WorkArea_Left + 200, 0, 1720, 1040
	execDelayer.Wait( "s", 2 )

	; Position Sublime Text 3 window
	WinActivate, ahk_exe sublime_text.exe
	execDelayer.Wait( "s", 3 )
	WinRestore, ahk_exe sublime_text.exe
	execDelayer.Wait( "s" )
	PositionWindowViaCtrlFN( "^F8", execDelayer.InterpretDelayString( "s", 2 ) )

	; Position Powershell console window
	agh_MovePowerShell()
	execDelayer.Wait( "s", 2 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.5: agh_MovePowerShell()

agh_MovePowerShell() {
	global execDelayer
	global mon3WorkArea_Left
	delay := GetDelay( "medium" )
	destX := mon3WorkArea_Left + 393 ; units = pixels, destination X coordinate
	destY := 161 ; units = pixels, destination Y coordinate
	attemptsLimit := 9 ; make repeated attempts over 3 seconds
	attemptsCount := 0

	; Activate Powershell console window
	hWnd := WinExist( "Administrator: ahk_class ConsoleWindowClass" )
	while ( !hWnd && attemptsCount <= attemptsLimit ) {
		execDelayer.Wait( "m" )
		hWnd := WinExist( "Administrator: ahk_class ConsoleWindowClass" )
		attemptsCount++
	}

	; Move Powershell console window
	if (hWnd) {
		; Set up a loop for repeated move attemps
		psTitle := "ahk_id " . hWnd ; i.e., PowerShell's identifying criteria
		execDelayer.Wait( "m" )
		WinGetPos x, y, w, h, % psTitle
		attempts := 0

		; Execute a loop for repeated move attempts
		while ( attempts <= attemptsLimit && ( x != destX && y != destY ) ) {
			WinMove % psTitle, , % destX, % destY
			attempts++
			execDelayer.Wait( "m" )
			WinGetPos x, y, w, h, % psTitle
		}

		; If necessary, report failure to move Powershell console window
		if ( attempts > attemptsLimit && ( x != destX && y != destY ) ) {
			errorMsgBox := New GuiMsgBox( "Error in " . A_ThisFunc . ": Failed to move PowerShell "
				. "after " . ( delay * attemptsLimit / 1000 ) . " seconds.", "PowerShellWontMove" )
			errorMsgBox.ShowGui()
		} else {
			execDelayer.Wait( "m" )
			WinActivate % psTitle
			execDelayer.Wait( "m", 2 )
			Gosub % "<^!+Left"
		}
	} else {
		; Report failure to activate Powershell console window
		errorMsgBox := New GuiMsgBox( "Error in " . A_ThisFunc . ": Could not find PowerShell."
			, "NoPowerShell" )
		errorMsgBox.ShowGui()
	}
}

;   ································································································
;     >>> §1.4: Setup VD3—Graphic design

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.1: @setupVirtualDesktop3

:*:@setupVirtualDesktop3::
	delay := GetDelay("medium")
	AppendAhkCmd(A_ThisLabel)
	CheckForCmdEntryGui()

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(3)
	Sleep % delay / 2
	DisplaySplashText("Setting up virtual desktop #3 for graphic design.")

	; Open and arrange graphic design apps & websites.
	svd3_OpenGraphicsReferences(delay)
	svd3_OpenGimp(delay)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.2: svd3_OpenGraphicsReferences(…)

svd3_OpenGraphicsReferences(delay) {
	Sleep % delay * 2
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	OpenWebsiteInChrome("www.colorhexa.com", False)
	Sleep % delay
	OpenWebsiteInChrome("brand.wsu.edu/visual/colors")
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.3: svd3_OpenGimp(…)

svd3_OpenGimp(delay) {
	Sleep % delay
	PositionWindowViaCtrlFN("^F10", 100)
	LaunchApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.10.exe", "GNU Image")
	Sleep % delay * 3
	PositionWindowViaCtrlFN("^F6", 100)
	Sleep % delay * 3
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.4: @arrangeGimp

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
;     >>> §1.5: Setup VD4—Communications and media

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.1: @setupVirtualDesktop4

:*:@setupVirtualDesktop4::
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities
	switchDesktopByNumber(4)
	execDelayer.Wait( "s", 1.5 )
	DisplaySplashText("Setting up virtual desktop #4 for online correspondence.")

	; Set up email and messaging clients
	svd4_LoadWebEmailClients( execDelayer.InterpretDelayString( "s" ) )
	LaunchStdApplicationPatiently("C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
		, "Inbox ahk_exe OUTLOOK.EXE")

	; Restore default arrangement of windows
	execDelayer.Wait( "s", 10 )
	Gosub :*:@arrangeEmail
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.2: svd4_LoadWebEmailClients(…)

svd4_LoadWebEmailClients( delay ) {
	execDelayer.Wait( delay, 1.5 )
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("mail.google.com", False)
	OpenWebsiteInChrome("mail.live.com")
	OpenWebsiteInChrome("web.wsu.edu")
	OpenWebsiteInChrome("wsu-web.slack.com")
	MoveToNextTabInChrome()
	execDelayer.Wait( delay, 3 )

	OpenNewWindowInChrome()
	OpenWebsiteInChrome("trello.com", False)
	PositionWindowViaCtrlFN("^F10", delay)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.3: @arrangeEmail

:*:@arrangeEmail::
	delay := execDelayer.InterpretDelayString( "s" ) * 2
	AppendAhkCmd(A_ThisLabel)

	; Reposition Outlook
	WinActivate % "Inbox - ahk_exe OUTLOOK.EXE"
	execDelayer.Wait( delay, 2 )
	PositionWindowViaCtrlFN("^F8", delay)
	execDelayer.Wait( delay, 1.25 )
	WinMaximize A
	execDelayer.Wait( delay )

	; Reposition Chrome window for email and news browsing
	WinActivate % "Inbox ahk_exe chrome.exe"
	execDelayer.Wait( delay, 1.25 )
	PositionWindowViaCtrlFN("^F6", delay)
	execDelayer.Wait( delay, 2.25 )

	; Open second Gmail account
	WinActivate % "Inbox ahk_exe chrome.exe"
	execDelayer.Wait( delay, 0.5 )
	MouseMove 1495, 145
	execDelayer.Wait( delay, 0.5 )
	Send {Click}
	execDelayer.Wait( delay, 15 )
	MouseMove 1245, 360
	execDelayer.Wait( delay, 0.5 )
	Send {Click}
	execDelayer.Wait( delay, 10 )
Return

;   ································································································
;     >>> §1.6: Setup VD5—Talmud

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.6.1: @setupVirtualDesktop5

:*:@setupVirtualDesktop5::
	delay := execDelayer.InterpretDelayString( "s" )
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(5)
	execDelayer.Wait( delay, 2 )
	DisplaySplashText("Setting up virtual desktop #5 for computer monitoring and Torah study.")

	; Set up apps for catching up on news.
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	execDelayer.Wait( delay, 50 )
	OpenWebsiteInChrome("https://www.sfchronicle.com/", False)
	OpenWebsiteInChrome("https://www.nytimes.com/")
	OpenWebsiteInChrome("news.wsu.edu")
	OpenWebsiteInChrome("dailyevergreen.com")
	execDelayer.Wait( delay, 20 )
	MoveToNextTabInChrome()
	PositionWindowViaCtrlFN("^F6", delay)
	execDelayer.Wait( delay, 10 )
	WinMaximize A

	; Set up apps for Torah study.
	execDelayer.Wait( delay, 6 )
	SendInput % "^n"
	execDelayer.Wait( delay, 20 )
	OpenWebsiteInChrome("biblegateway.com", False)
	OpenWebsiteInChrome("hebrew4christians.com")
	OpenWebsiteInChrome("scripturetyper.com")
	OpenWebsiteInChrome("www.blueletterbible.org")
	execDelayer.Wait( delay, 10 )
	MoveToNextTabInChrome()
	PositionWindowViaCtrlFN("^F8", delay)
	execDelayer.Wait( delay, 10 )
	WinMaximize A

	; Load music app
	LaunchStdApplicationPatiently("shell:appsFolder\AppleInc.iTunes_nzyj5cx40ttqa!iTunes", "iTunes")
	execDelayer.Wait( delay )
	WinActivate % "iTunes ahk_exe iTunes.exe"
	execDelayer.Wait( delay )
	PositionWindowViaCtrlFN("^F10", delay)
	WinMaximize A
	execDelayer.Wait( delay, 10 )
Return

;   ································································································
;     >>> §1.7: Setup VD6—Diagnostics & XAMPP

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.7.1: @setupVirtualDesktop6

:*:@setupVirtualDesktop6::
	AppendAhkCmd(A_ThisLabel)

	; Switch to virtual desktop and notify user of subsequent automated activities.
	switchDesktopByNumber(6)
	execDelayer.Wait( "s", 2 )
	DisplaySplashText("Setting up virtual desktop #6 for computer monitoring and XAMPP.")

	; Set up computer monitoring apps.
	execDelayer.Wait( "s", 2 )
	LaunchStdApplicationPatiently("C:\Windows\System32\taskmgr.exe", "Task Manager")
	execDelayer.Wait( "s", 10 )
	WinMove % "GPU Temp", , % 1379 + Mon1WorkArea_Left, 59, 480, 400
	execDelayer.Wait( "s", 2 )
	WinMove % "RealTemp", , % 1383 + Mon1WorkArea_Left, 477, 318, 409
	execDelayer.Wait( "s", 2 )
	WinMove % "Task Manager", , % 392 + Mon1WorkArea_Left, 184, 976, 600

	LaunchApplicationPatiently("C:\xampp\xampp-control.exe", "XAMPP ahk_exe xampp-control.exe")
Return

; --------------------------------------------------------------------------------------------------
;   §2: STARTUP HOTKEYS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: #!r

#!r::
	Gosub :*:@setupWorkEnvironment
Return

; --------------------------------------------------------------------------------------------------
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: @quitAhk

:*:@quitAhk::
	AppendAhkCmd(A_ThisLabel)
	PerformScriptShutdownTasks()
	ExitApp
Return

;   ································································································
;     >>> §3.2: PerformScriptShutdownTasks()

PerformScriptShutdownTasks() {
	SaveAhkCmdHistory()
	SaveCommitCssLessMsgHistory()
	SaveCommitJsCustomJsMsgHistory()
	SaveCafMsgHistory()
}

;   ································································································
;     >>> §3.3: ^#!r

^#!r::
	PerformScriptShutdownTasks()
	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
Return

;   ································································································
;     >>> §3.4: ScriptExitFunc(…)

ScriptExitFunc(ExitReason, ExitCode) {
	if ExitReason in Logoff, Shutdown, Menu
	{
		PerformScriptShutdownTasks()
	}
}
