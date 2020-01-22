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
;   §1: VIRTUAL DESKTOP SET UP HOTSTRINGS.......................................................62
;     >>> §1.1: Work environment set up — @setupWorkEnvironment.................................66
;       →→→ §1.1.1: @moveTempMonitors...........................................................83
;       →→→ §1.1.2: @setupVirtualDesktops......................................................103
;     >>> §1.2: Website editing VD — @setupVdForWebEditing.....................................138
;       →→→ §1.2.1: @startChrome...............................................................174
;       →→→ §1.2.2: @startSublimeText3.........................................................184
;       →→→ §1.2.3: PositionChromeVD1()........................................................195
;       →→→ §1.2.4: MoveActWinToMonViaCtrlFN(…)................................................210
;       →→→ §1.2.5: EnsureActWinMaxed()........................................................236
;       →→→ §1.2.6: Vd1_OpenWorkNotesLog().....................................................246
;     >>> §1.3: Programming VD — @setupVdForProgramming........................................310
;       →→→ §1.3.1: @addSublimeText3ToVd + AddSublimeText3ToVd()...............................331
;       →→→ §1.3.2: @arrangeGitHub.............................................................371
;       →→→ §1.3.3: @startGithubClients........................................................407
;       →→→ §1.3.4: agh_MovePowerShell().......................................................425
;     >>> §1.4: Graphic design VD — @setupVdForGraphicDesign...................................480
;       →→→ §1.4.1: @arrangeGimp...............................................................497
;       →→→ §1.4.2: svd3_OpenGimp(…)...........................................................520
;       →→→ §1.4.3: svd3_OpenGraphicsReferences(…).............................................532
;     >>> §1.5: Communications and media VD — @setupVdForCommunications........................544
;       →→→ §1.5.1: @arrangeEmail..............................................................562
;       →→→ §1.5.2: svd4_LoadWebEmailClients(…)................................................602
;     >>> §1.6: Research VD — @setupVdForResearch..............................................627
;     >>> §1.7: PC monitoring VD — @setupVdForPcMonitoring.....................................681
;   §2: STARTUP HOTKEYS........................................................................702
;     >>> §2.1: #!r............................................................................706
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS................................................713
;     >>> §3.1: @quitAhk.......................................................................717
;     >>> §3.2: ^#!r...........................................................................726
;     >>> §3.3: PerformScriptShutdownTasks()...................................................735
;     >>> §3.4: ScriptExitFunc(…)..............................................................745
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: VIRTUAL DESKTOP SET UP HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: Work environment set up — @setupWorkEnvironment

:*:@setupWorkEnvironment::
	AppendAhkCmd(A_ThisLabel)
;	PrimeVirtualDesktops()
	execDelayer.Wait( "l" )
	Gosub :*:@moveTempMonitors
	Gosub :*:@setupVirtualDesktops
	switchDesktopByNumber(1)
	execDelayer.Wait( "m" )
	SoundPlay %desktopArrangedSound%
	Gosub % ":*:@setupWorkTimer"
	switchDesktopByNumber(5)
	DisplaySplashText("Desktop set up is complete.", 3000)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.1: @moveTempMonitors

:*:@moveTempMonitors::
	AppendAhkCmd( A_ThisLabel )
	DisplaySplashText( "Moving temperature monitors.", 3000 )
	execDelayer.SetUpNewProcess( 5.1, A_ThisLabel )
	execDelayer.Wait( "m", 3 )
	WinActivate % "RealTemp ahk_exe RealTemp.exe"
	execDelayer.Wait( "m", 3 )
	moveActiveWindowToVirtualDesktop( 6 )
	execDelayer.Wait( "l", 2 )
	WinActivate % "GPU Temp ahk_exe GPUTemp.exe"
	execDelayer.Wait( "m", 2 )
	moveActiveWindowToVirtualDesktop( 6 )
	execDelayer.Wait( "l", 2 )
	execDelayer.CompleteCurrentProcess()
	DisplaySplashText( "Finished moving temperature monitors.", 3000 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.2: @setupVirtualDesktops

:*:@setupVirtualDesktops::
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Setting up virtual desktops.", 3000)
	execDelayer.Wait( "l", 4 )
	MapDesktopsFromRegistry()
	execDelayer.Wait( "l", 4 )

	SwitchDesktopByNumber(1)
	execDelayer.Wait( "m" )
	Gosub :*:@setupVdForWebEditing
	execDelayer.Wait( "m" )
	SwitchDesktopByNumber(2)
	execDelayer.Wait( "m" )
	Gosub :*:@setupVdForProgramming
	execDelayer.Wait( "m" )
	SwitchDesktopByNumber(3)
	execDelayer.Wait( "m" )
	Gosub :*:@setupVdForGraphicDesign
	execDelayer.Wait( "m" )
	SwitchDesktopByNumber(4)
	execDelayer.Wait( "m" )
	Gosub :*:@setupVdForCommunications
	execDelayer.Wait( "m" )
	SwitchDesktopByNumber(5)
	execDelayer.Wait( "m" )
	Gosub :*:@setupVdForResearch
	execDelayer.Wait( "m" )
	SwitchDesktopByNumber(6)
	execDelayer.Wait( "m" )
	Gosub :*:@setupVdForPcMonitoring
Return

;   ································································································
;     >>> §1.2: Website editing VD — @setupVdForWebEditing

:*:@setupVdForWebEditing::
	AppendAhkCmd(A_ThisLabel)
	DisplaySplashText("Setting up current virtual desktop for website editing and coding.", 3000)

	; Start Sublime Text 3 & restore its default positioning
	MapDesktopsFromRegistry()
	AddSublimeText3ToVd( vdCurrentDesktop )
	execDelayer.Wait( "s", 4 )
	MoveActWinToMonViaCtrlFN( "^F8", execDelayer.InterpretDelayString( "s" ) * 4 )

	; Load chrome & navigate to WSUWP login page
	Gosub :*:@startChrome
	execDelayer.Wait( "s", 4 )
	OpenWebsiteInChrome("distinguishedscholarships.wsu.edu/wp-admin/", False)

	; Load notepad.exe & position it on virtual desktop
	LaunchStdApplicationPatiently( "C:\Windows\System32\notepad.exe", "ahk_exe notepad.exe" )
	execDelayer.Wait( "l" )
	if ( SafeWinActivate( "ahk_exe notepad.exe" ) ) {
		execDelayer.Wait( "s", 2 )
		WinMove A, , 3175, 3, 642, 1037
	}

	; Load an instance of Windows Explorer
	SendInput #e
	WaitForApplicationPatiently( "This PC ahk_exe explorer.exe" )
	execDelayer.Wait( "l" )
	WinMove A, , 1018, 1, 898, 1040

	PositionChromeOnWebEditVd()
	WebEditVd_OpenWorkNotesLog()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.1: @startChrome

:*:@startChrome::
	AppendAhkCmd( A_ThisLabel )
	LaunchStdApplicationPatiently( "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab ahk_exe chrome.exe" )
	execDelayer.Wait( "l" )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.2: @startSublimeText3

:*:@startSublimeText3::
	AppendAhkCmd( A_ThisLabel )
	titleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	LaunchApplicationPatiently( "C:\Program Files\Sublime Text 3\sublime_text.exe"
		, titleToMatch, mmRegEx )
	execDelayer.Wait( "s", 2 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.3: PositionChromeVD1()

PositionChromeOnWebEditVd() {
	global execDelayer

	chromeTitle := "Log In ahk_exe chrome.exe"
	chromeActive := SafeWinActivate( chromeTitle )
	if ( chromeActive ) {
		MoveActWinToMonViaCtrlFN( "^F7", execDelayer.InterpretDelayString( "s" ) * 5 )
		execDelayer.Wait( "s", 5 )
		EnsureActWinMaxed()
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.4: MoveActWinToMonViaCtrlFN(…)

MoveActWinToMonViaCtrlFN(posHotkey, delay) {
	global execDelayer

	if ( !( posHotkey == "^F6" || posHotkey == "^F7" || posHotkey == "^F8" || posHotkey == "^F9"
			|| posHotkey == "^F10" || posHotkey == "^F11" ) ) {
		errorMsg := New GuiMsgBox( "Error in " . A_ThisFunc . ": I was passed a window positioning "
			. "hotkey that I do not recognize: " . posHotkey )
		Return
	}
	if ( ( posHotkey == "^F6" || posHotkey == "^F7" ) && FindNearestActiveMonitor() == 1 ) {
		Return
	}
	if ( ( posHotkey == "^F8" || posHotkey == "^F9" ) && FindNearestActiveMonitor() == 2 ) {
		Return
	}
	if ( ( posHotkey == "^F10" || posHotkey == "^F11" ) && FindNearestActiveMonitor() == 3 ) {
		Return
	}
	Gosub % posHotkey
	execDelayer.Wait( delay )
	SendInput % "{Enter}"
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.5: EnsureActWinMaxed()

EnsureActWinMaxed() {
	WinGet, state, MinMax
	if ( state != 1 ) {
		WinMaximize, A
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.6: Vd1_OpenWorkNotesLog()

WebEditVd_OpenWorkNotesLog() {
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
		MoveActWinToMonViaCtrlFN("^F10", execDelayer.InterpretDelayString( "m" ) )
		execDelayer.Wait( "m", 3 )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m" )
		}

		; Create a new ST3 window and restore its default position on virtual desktop
		SendInput, ^+n
		execDelayer.Wait( "m", 3 )
		WaitForApplicationPatiently(st3NewWinTitle)
		MoveActWinToMonViaCtrlFN("^F8", execDelayer.InterpretDelayString( "m" ) )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m" )
		}
	} else {
		; Activate existing ST3 process and restore its default position on virtual desktop
		SafeWinActivate(st3GeneralTitle, mmRegEx)
		execDelayer.Wait( "m" )
		MoveActWinToMonViaCtrlFN("^F8", execDelayer.InterpretDelayString( "m" ) )
		execDelayer.Wait( "m", 3 )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m" )
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
		MoveActWinToMonViaCtrlFN("^F10", execDelayer.InterpretDelayString( "m" ) )
		execDelayer.Wait( "m", 3 )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m" )
		}
	}
	RestoreMatchMode(oldTitleMatchMode)
}

;   ································································································
;     >>> §1.3: Programming VD — @setupVdForProgramming

:*:@setupVdForProgramming::
	AppendAhkCmd( A_ThisLabel )
	execDelayer.Wait( "s", 10 )
	DisplaySplashText("Setting up current virtual desktop for coding and source code management."
		, 3000)

	; Load programming IDE, scripting and command-line interface, and coding repository.
	execDelayer.Wait( "s", 10 )
	curVd := GetCurrentVirtualDesktop()
	AddSublimeText3ToVd( curVd )
	execDelayer.Wait( "s", 5 )
	SendInput #e
	WaitForApplicationPatiently( "This PC" )
	Gosub :*:@startGithubClients
	execDelayer.Wait( "s", 5 )
	Gosub :*:@arrangeGitHub
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.1: @addSublimeText3ToVd + AddSublimeText3ToVd(…)

:*:@addSublimeText3ToVd::
	AppendAhkCmd( A_ThisLabel )
	curVd := GetCurrentVirtualDesktop()
	AddSublimeText3ToVd( curVd )
Return

AddSublimeText3ToVd( whichVd ) {
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
		SafeWinActivate( st3TitleToMatch, mmRegEx )
		execDelayer.InterpretDelayString( "m", 2 )
		st3Vd := GetCurrentVirtualDesktop()
		if ( st3Vd != whichVd ) {
			SendInput, ^+n
			execDelayer.InterpretDelayString( "m", 3 )
			WaitForApplicationPatiently( st3NewWinTitle )
			moveActiveWindowToVirtualDesktop( whichVd )
			execDelayer.InterpretDelayString( "m", 3 )
			switchDesktopByNumber( whichVd )
		}
	} else {
		GoSub, :*:@startSublimeText3
	}
	RestoreMatchMode(oldTitleMatchMode)
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.2: @arrangeGitHub

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
	MoveActWinToMonViaCtrlFN( "^F8", execDelayer.InterpretDelayString( "s", 2 ) )

	; Position Powershell console window
	agh_MovePowerShell()
	execDelayer.Wait( "s", 2 )
Return

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
;       →→→ §1.3.4: agh_MovePowerShell()

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
;     >>> §1.4: Graphic design VD — @setupVdForGraphicDesign

:*:@setupVdForGraphicDesign::
	delay := GetDelay("medium")
	AppendAhkCmd(A_ThisLabel)
	CheckForCmdEntryGui()

	; Switch to virtual desktop and notify user of subsequent automated activities.
	Sleep % delay / 2
	DisplaySplashText("Setting up current virtual desktop for graphic design.", 3000)

	; Open and arrange graphic design apps & websites.
	svd3_OpenGraphicsReferences(delay)
	svd3_OpenGimp(delay)
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.1: @arrangeGimp

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

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.2: svd3_OpenGimp(…)

svd3_OpenGimp(delay) {
	Sleep % delay
	MoveActWinToMonViaCtrlFN("^F10", 100)
	LaunchApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.10.exe", "GNU Image")
	Sleep % delay * 3
	MoveActWinToMonViaCtrlFN("^F6", 100)
	Sleep % delay * 3
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.3: svd3_OpenGraphicsReferences(…)

svd3_OpenGraphicsReferences(delay) {
	Sleep % delay * 2
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	OpenWebsiteInChrome("www.colorhexa.com", False)
	Sleep % delay
	OpenWebsiteInChrome("brand.wsu.edu/visual/colors")
}

;   ································································································
;     >>> §1.5: Communications and media VD — @setupVdForCommunications

:*:@setupVdForCommunications::
	AppendAhkCmd(A_ThisLabel)
	execDelayer.Wait( "s", 1.5 )
	DisplaySplashText("Setting up current virtual desktop for online correspondence.", 3000)

	; Set up email and messaging clients
	svd4_LoadWebEmailClients( execDelayer.InterpretDelayString( "s" ) )
	LaunchStdApplicationPatiently("C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
		, "Inbox ahk_exe OUTLOOK.EXE")

	; Restore default arrangement of windows
	execDelayer.Wait( "s", 10 )
	Gosub :*:@arrangeEmail
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.1: @arrangeEmail

:*:@arrangeEmail::
	delay := execDelayer.InterpretDelayString( "s" ) * 2
	AppendAhkCmd(A_ThisLabel)

	; Reposition Outlook
	WinActivate % "Inbox - ahk_exe OUTLOOK.EXE"
	execDelayer.Wait( delay, 2 )
	MoveActWinToMonViaCtrlFN("^F8", delay)
	execDelayer.Wait( delay, 1.25 )
	EnsureActWinMaxed()
	execDelayer.Wait( delay )

	; Reposition Chrome window for email and news browsing
	WinActivate % "Inbox ahk_exe chrome.exe"
	execDelayer.Wait( delay, 1.25 )
	MoveActWinToMonViaCtrlFN("^F6", delay)
	execDelayer.Wait( delay, 2.25 )

	; Open second Gmail account
	WinActivate % "Inbox ahk_exe chrome.exe"
	execDelayer.Wait( delay )
	MouseMove 1495, 145
	execDelayer.Wait( delay )
	Send {Click}
	execDelayer.Wait( delay, 15 )
	MouseMove 1245, 433
	execDelayer.Wait( delay )
	Send {Click}
	execDelayer.Wait( delay, 10 )
	Send % "^{Tab}"
	execDelayer.Wait( delay )
	Send % "^{Tab}"
	execDelayer.Wait( delay )
	Send % "^{Tab}"
	execDelayer.Wait( delay )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.5.2: svd4_LoadWebEmailClients(…)

svd4_LoadWebEmailClients( delay ) {
	global execDelayer
	execDelayer.Wait( delay, 1.5 )
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("mail.google.com", False)
	execDelayer.Wait( delay )
	OpenWebsiteInChrome("mail.live.com")
	execDelayer.Wait( delay )
	OpenWebsiteInChrome("web.wsu.edu")
	execDelayer.Wait( delay )
	OpenWebsiteInChrome("wsu-web.slack.com")
	execDelayer.Wait( delay )
	MoveToNextTabInChrome()
	execDelayer.Wait( delay, 3 )

	OpenNewWindowInChrome()
	OpenWebsiteInChrome("trello.com", False)
	MoveActWinToMonViaCtrlFN("^F10", delay)
}

;   ································································································
;     >>> §1.6: Research VD — @setupVdForResearch

:*:@setupVdForResearch::
	delay := execDelayer.InterpretDelayString( "s" )
	AppendAhkCmd(A_ThisLabel)
	execDelayer.Wait( delay, 2 )
	DisplaySplashText("Setting up current virtual desktop for computer monitoring and Torah study."
		, 3000)

	; Set up apps for catching up on news.
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	execDelayer.Wait( delay, 50 )
	OpenWebsiteInChrome("https://www.sfchronicle.com/")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("https://www.nytimes.com/")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("news.wsu.edu")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("dailyevergreen.com")
	execDelayer.Wait( delay, 20 )
	MoveToNextTabInChrome()
	MoveActWinToMonViaCtrlFN("^F6", delay)
	execDelayer.Wait( delay, 10 )
	EnsureActWinMaxed()

	; Set up apps for Torah study.
	execDelayer.Wait( delay, 6 )
	SendInput % "^n"
	execDelayer.Wait( delay, 20 )
	OpenWebsiteInChrome("biblegateway.com", False)
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("hebrew4christians.com")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("scripturetyper.com")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("www.blueletterbible.org")
	execDelayer.Wait( delay, 10 )
	MoveToNextTabInChrome()
	MoveActWinToMonViaCtrlFN("^F8", delay)
	execDelayer.Wait( delay, 10 )
	EnsureActWinMaxed()

	; Load music app
	LaunchStdApplicationPatiently("shell:appsFolder\AppleInc.iTunes_nzyj5cx40ttqa!iTunes", "iTunes")
	execDelayer.Wait( delay )
	WinActivate % "iTunes ahk_exe iTunes.exe"
	execDelayer.Wait( delay )
	MoveActWinToMonViaCtrlFN("^F10", delay)
	EnsureActWinMaxed()
	execDelayer.Wait( delay, 10 )
Return

;   ································································································
;     >>> §1.7: PC monitoring VD — @setupVdForPcMonitoring

:*:@setupVdForPcMonitoring::
	AppendAhkCmd(A_ThisLabel)
	execDelayer.Wait( "s", 2 )
	DisplaySplashText("Setting up current virtual desktop for computer monitoring.", 3000)

	; Set up computer monitoring apps.
	execDelayer.Wait( "s", 2 )
	LaunchStdApplicationPatiently("C:\Windows\System32\taskmgr.exe", "Task Manager")
	execDelayer.Wait( "s", 10 )
	WinMove % "GPU Temp", , % 1379 + Mon1WorkArea_Left, 59, 480, 400
	execDelayer.Wait( "s", 2 )
	WinMove % "RealTemp", , % 1383 + Mon1WorkArea_Left, 477, 318, 409
	execDelayer.Wait( "s", 2 )
	WinMove % "Task Manager", , % 392 + Mon1WorkArea_Left, 477, 976, 533

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
;     >>> §3.2: ^#!r

^#!r::
	PerformScriptShutdownTasks()
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
Return

;   ································································································
;     >>> §3.3: PerformScriptShutdownTasks()

PerformScriptShutdownTasks() {
	SaveAhkCmdHistory()
	SaveCommitCssLessMsgHistory()
	SaveCommitJsCustomJsMsgHistory()
	SaveCafMsgHistory()
}

;   ································································································
;     >>> §3.4: ScriptExitFunc(…)

ScriptExitFunc(ExitReason, ExitCode) {
	if ExitReason in Logoff, Shutdown, Menu
	{
		PerformScriptShutdownTasks()
	}
}
