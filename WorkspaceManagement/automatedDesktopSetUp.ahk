; ==================================================================================================
; automatedDesktopSetUp.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Script for setting up the desktop upon session startup.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
;
; REPOSITORY: https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey
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
;   §1: VIRTUAL DESKTOP SET UP HOTSTRINGS.......................................................64
;     >>> §1.1: Work environment set up — @setupWorkEnvironment.................................68
;       →→→ §1.1.1: class ScriptEnvChecker......................................................88
;       →→→ §1.1.1: @moveTempMonitors..........................................................163
;       →→→ §1.1.2: @setupVirtualDesktops......................................................185
;     >>> §1.2: Website editing VD — @setupVdForWebEditing.....................................220
;       →→→ §1.2.1: @startChrome...............................................................254
;       →→→ §1.2.2: @startSublimeText3.........................................................264
;       →→→ §1.2.3: PositionChromeVD1()........................................................275
;       →→→ §1.2.4: PosActWinOnMonsViaCtrlFN(…)................................................288
;       →→→ §1.2.5: MaxActWinOnMonViaCtrlFN(…).................................................305
;       →→→ §1.2.6: EnsureActWinMaxed()........................................................336
;       →→→ §1.2.7: Vd1_OpenWorkNotesLog().....................................................350
;     >>> §1.3: Programming VD — @setupVdForProgramming........................................414
;       →→→ §1.3.1: @addSublimeText3ToVd + AddSublimeText3ToVd()...............................435
;       →→→ §1.3.2: @arrangeGitHub.............................................................480
;       →→→ §1.3.3: @startGithubClients........................................................517
;       →→→ §1.3.4: agh_MovePowerShell().......................................................533
;     >>> §1.4: Graphic design VD — @setupVdForGraphicDesign...................................588
;       →→→ §1.4.1: @arrangeGimp...............................................................605
;       →→→ §1.4.2: svd3_OpenGimp(…)...........................................................628
;       →→→ §1.4.3: svd3_OpenGraphicsReferences(…).............................................640
;     >>> §1.5: Communications and media VD — @setupVdForCommunications........................651
;       →→→ §1.5.1: @arrangeEmail..............................................................669
;       →→→ §1.5.2: svd4_LoadWebEmailClients(…)................................................717
;     >>> §1.6: Research VD — @setupVdForResearch..............................................742
;     >>> §1.7: PC monitoring VD — @setupVdForPcMonitoring.....................................788
;   §2: STARTUP HOTKEYS........................................................................809
;     >>> §2.1: #!r............................................................................813
;   §3: SHUTDOWN/RESTART HOTSTRINGS & FUNCTIONS................................................820
;     >>> §3.1: @quitAhk.......................................................................824
;     >>> §3.2: ^#!r...........................................................................833
;     >>> §3.3: PerformScriptShutdownTasks()...................................................842
;     >>> §3.4: ScriptExitFunc(…)..............................................................852
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: VIRTUAL DESKTOP SET UP HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §1.1: Work environment set up — @setupWorkEnvironment

:*:@setupWorkEnvironment::
	AppendAhkCmd( A_ThisLabel )
	execDelayer.Wait( "l" )
	envChecker := new ScriptEnvChecker( Func( MapDesktopsFromRegistry ) )
	envStatus := envChecker.CheckWorkEnv()
	if ( envStatus == "ready" ) {
		Gosub :*:@moveTempMonitors
		Gosub :*:@setupVirtualDesktops
		switchDesktopByNumber( 1 )
		execDelayer.Wait( "m" )
		SoundPlay %desktopArrangedSound%
		Gosub % ":*:@setupWorkTimer"
		switchDesktopByNumber( 5 )
		DisplaySplashText( "Desktop set up is complete.", 3000 )
	}
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.1: class ScriptEnvChecker

class ScriptEnvChecker {
	__New( fVdMapper ) {
		this.fMapDesktopsFromRegistry := fVdMapper
	}

	CheckWorkEnv() {
		global vdDesktopCount
		this.fMapDesktopsFromRegistry.Call()
		DetectHiddenWindows On
		this.gpuTempExists := WinExist( "GPU Temp ahk_exe GPUTemp.exe" )
		this.realTempExists := WinExist( "RealTemp ahk_exe RealTemp.exe" )
		DetectHiddenWindows Off
		this.vdCount := vdDesktopCount
		return this.ClassifyEnvStatus()
	}

	ClassifyEnvStatus() {
		if ( this.gpuTempExists && this.realTempExists ) {
			this.envStatus := "temp monitors ready"
		} else if ( gpuTempExists && !realTempExists ) {
			this.envStatus := "cpu temp not ready"
		} else if ( !gpuTempExists && realTempExists ) {
			this.envStatus := "gpu temp not ready"
		} else {
			this.envStatus := "temp monitors not ready"
		}
		if ( this.vdCount >= 6 && this.envStatus == "temp monitors ready" ) {
			this.envStatus := "ready"
		} else if ( vdDesktopCount < 6 &&  envStatus == "temp monitors ready" ) {
			this.envStatus := "too few vds"
		} else if ( vdDesktopCount < 6 ) {
			this.envStatus .= ", too few vds"
		}
		this.ReportOnEnvStatus( this.envStatus )
		return this.envStatus
	}

	ReportOnEnvStatus( envStatus ) {
		if ( envStatus == "too few vds" ) {
			DisplaySplashText( "Sorry, the system is not yet ready for automated set up: Less than the"
				. " required six virtual desktops are currently active.", 3000)
		} else if ( envStatus == "temp monitors not ready" ) {
			DisplaySplashText( "Sorry, the system is not yet ready for automated set up: Temperature"
				. " monitoring processes for both the system's CPU and the GPU have not yet been"
				. " started yet.", 3000)
		} else if ( envStatus == "cpu temp not ready" ) {
			DisplaySplashText( "Sorry, the system is not yet ready for automated set up: The"
				. " temperature monitoring processes for the system's CPU has not yet been started yet."
				, 3000)
		} else if ( envStatus == "cpu temp not ready, too few vds" ) {
			DisplaySplashText( "Sorry, the system is not yet ready for automated set up: The"
				. " temperature monitoring processes for the system's CPU has not yet been started"
				. " yet. Moreover, less than the required six virtual desktops are currently active."
				, 3000)
		} else if ( envStatus == "gpu temp not ready" ) {
			DisplaySplashText( "Sorry, the system is not yet ready for automated set up: The"
				. " temperature monitoring processes for the system's GPU has not yet been started yet."
				, 3000)
		} else if ( envStatus == "gpu temp not ready, too few vds" ) {
			DisplaySplashText( "Sorry, the system is not yet ready for automated set up: The"
				. " temperature monitoring processes for the system's GPU has not yet been started"
				. " yet. Moreover, less than the required six virtual desktops are currently active."
				, 3000)
		} else {
			DisplaySplashText( "Sorry, the system is not yet ready for automated set up: Temperature"
				. " monitoring processes for both the system's CPU and the GPU have not yet been"
				. " started yet. Moreover, less than the required six virtual desktops are currently"
				. " active.", 3000)
		}
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.2: @moveTempMonitors

:*:@moveTempMonitors::
	AppendAhkCmd( A_ThisLabel )
	DisplaySplashText( "Moving temperature monitors.", 3000 )
	execDelayer.SetUpNewProcess( 5.1, A_ThisLabel )
	execDelayer.Wait( "m", 3 )
	DetectHiddenWindows On
	WinActivate % "RealTemp ahk_exe RealTemp.exe"
	execDelayer.Wait( "m", 3 )
	moveActiveWindowToVirtualDesktop( 6 )
	execDelayer.Wait( "l", 2 )
	WinActivate % "GPU Temp ahk_exe GPUTemp.exe"
	DetectHiddenWindows Off
	execDelayer.Wait( "m", 2 )
	moveActiveWindowToVirtualDesktop( 6 )
	execDelayer.Wait( "l", 2 )
	execDelayer.CompleteCurrentProcess()
	DisplaySplashText( "Finished moving temperature monitors.", 3000 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.1.3: @setupVirtualDesktops

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
	MaxActWinOnMonViaCtrlFN( "^F9", "m" )

	; Load chrome & navigate to WSUWP login page
	Gosub :*:@startChrome
	execDelayer.Wait( "s", 4 )
	OpenWebsiteInChrome("daesa.wsu.edu/wp-admin/", False)

	; Load an instance of Windows Explorer
	SendInput #e
	WaitForApplicationPatiently( "This PC ahk_exe explorer.exe" )
	execDelayer.Wait( "l" )
	PosActWinOnMonsViaCtrlFN( "^F12", "m" )

	PositionChromeOnWebEditVd()
	execDelayer.Wait( "m" )
	OpenNewWindowInChrome()
	execDelayer.Wait( "m" )
	OpenWebsiteInChrome( "trello.com", False )
	execDelayer.Wait( "m" )
	PosActWinOnMonsViaCtrlFN( "^F11", "m" )
;	WebEditVd_OpenWorkNotesLog()
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.1: @startChrome

:*:@startChrome::
	AppendAhkCmd( A_ThisLabel )
	LaunchStdApplicationPatiently( "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "chrome://newtab ahk_exe chrome.exe" )
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
		MaxActWinOnMonViaCtrlFN( "^F7", execDelayer.InterpretDelayString( "s" ) * 5 )
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.4: PosWinOnMonsViaCtrlFN(…)

PosActWinOnMonsViaCtrlFN( posHotkey, delay ) {
	global execDelayer

	if ( !( posHotkey == "^F7" || posHotkey == "^F8" || posHotkey == "^F9" || posHotkey == "^F10"
			|| posHotkey == "^F11" || posHotkey == "^F12" ) ) {
		errorMsg := New GuiMsgBox( "Error in " . A_ThisFunc . ": I was passed a window positioning "
			. "hotkey that I do not recognize: " . posHotkey )
		Return
	}
	Gosub % posHotkey
	execDelayer.Wait( delay )
	SendInput % "{Enter}"
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.5: MaxActWinOnMonViaCtrlFN(…)

MaxActWinOnMonViaCtrlFN( posHotkey, delay ) {
	global execDelayer

	if ( !( posHotkey == "^F7" || posHotkey == "^F8" || posHotkey == "^F9" || posHotkey == "^F10"
			|| posHotkey == "^F11" || posHotkey == "^F12" ) ) {
		errorMsg := New GuiMsgBox( "Error in " . A_ThisFunc . ": I was passed a window positioning "
			. "hotkey that I do not recognize: " . posHotkey )
		Return
	}
	if ( ( posHotkey == "^F7" || posHotkey == "^F8" ) && FindNearestActiveMonitor() == 1 ) {
		EnsureActWinMaxed()
		Return
	}
	if ( ( posHotkey == "^F9" || posHotkey == "^F10" ) && FindNearestActiveMonitor() == 2 ) {
		EnsureActWinMaxed()
		Return
	}
	if ( ( posHotkey == "^F11" || posHotkey == "^F12" ) && FindNearestActiveMonitor() == 3 ) {
		EnsureActWinMaxed()
		Return
	}
	Gosub % posHotkey
	execDelayer.Wait( delay )
	SendInput % "{Enter}"
	execDelayer.Wait( delay, 2 )
	EnsureActWinMaxed()
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.6: EnsureActWinMaxed()

EnsureActWinMaxed() {
	global execDelayer

	WinGet, state, MinMax, A
	execDelayer.Wait( "s" )
	if ( state != 1 ) {
		WinMaximize, A
		execDelayer.Wait( "m" )
	}
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.2.7: Vd1_OpenWorkNotesLog()

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
		PosActWinOnMonsViaCtrlFN("^F11", execDelayer.InterpretDelayString( "m" ) )
		execDelayer.Wait( "m", 3 )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m" )
		}

		; Create a new ST3 window and restore its default position on virtual desktop
		SendInput, ^+n
		execDelayer.Wait( "m", 3 )
		WaitForApplicationPatiently(st3NewWinTitle)
		PosActWinOnMonsViaCtrlFN("^F9", execDelayer.InterpretDelayString( "m" ) )
		Loop 3 {
			GoSub % "<^!#Left"
			execDelayer.Wait( "m" )
		}
	} else {
		; Activate existing ST3 process and restore its default position on virtual desktop
		SafeWinActivate(st3GeneralTitle, mmRegEx)
		execDelayer.Wait( "m" )
		PosActWinOnMonsViaCtrlFN("^F9", execDelayer.InterpretDelayString( "m" ) )
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
		PosActWinOnMonsViaCtrlFN("^F11", execDelayer.InterpretDelayString( "m" ) )
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
	DetectHiddenWindows On
	IfWinExist, %st3TitleToMatch%
	{
		; Switch to ST3 so that a new window can be generated and moved to the virtual desktop
		execDelayer.Wait( "m" )
		SafeWinActivate( st3TitleToMatch, mmRegEx )
		execDelayer.Wait( "l" )
		st3Vd := GetCurrentVirtualDesktop()
		execDelayer.Wait( "m" )
		if ( st3Vd != whichVd ) {
			SendInput, ^+n
			execDelayer.Wait( "l" )
			WaitForApplicationPatiently( st3NewWinTitle )
			execDelayer.Wait( "m" )
			moveActiveWindowToVirtualDesktop( whichVd )
			execDelayer.Wait( "l", 2 )
			switchDesktopByNumber( whichVd )
			execDelayer.Wait( "l" )
		}
	} else {
		GoSub, :*:@startSublimeText3
	}
	DetectHiddenWindows Off
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
	WinActivate, % "invokeImmediately ahk_exe chrome.exe"
	execDelayer.Wait( "m" )
	PosActWinOnMonsViaCtrlFN( "^F7", execDelayer.InterpretDelayString( "s", 2 ) )
	execDelayer.Wait( "s", 2 )

	; Position File Explorer window
	WinRestore, % "This PC ahk_exe explorer.exe"
	execDelayer.Wait( "m" )
	WinActivate,  % "This PC ahk_exe explorer.exe"
	execDelayer.Wait( "m" )
	WinMove,  % "This PC ahk_exe explorer.exe", , Mon1WorkArea_Left + 200, 0, 1720, 1040
	execDelayer.Wait( "s", 2 )
	WinActivate, % "invokeImmediately ahk_exe chrome.exe"

	; Position Sublime Text 3 window
	WinActivate, ahk_exe sublime_text.exe
	execDelayer.Wait( "s", 3 )
	PosActWinOnMonsViaCtrlFN( "^F9", execDelayer.InterpretDelayString( "s", 2 ) )

	; Position Powershell console window
	agh_MovePowerShell()
	execDelayer.Wait( "s", 2 )
Return

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.3: @startGithubClients

:*:@startGithubClients::
	AppendAhkCmd( A_ThisLabel )
	execDelayer.Wait( "s" )
	Gosub :*:@startChrome
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
			PosActWinOnMonsViaCtrlFN( "^F11", execDelayer.InterpretDelayString( "m" ) )
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
	MaxActWinOnMonViaCtrlFN("^F11", 100)
	LaunchApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.10.exe", "GNU Image")
	Sleep % delay * 3
	MaxActWinOnMonViaCtrlFN("^F7", 100)
	Sleep % delay * 3
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.4.3: svd3_OpenGraphicsReferences(…)

svd3_OpenGraphicsReferences(delay) {
	Sleep % delay * 2
	Gosub :*:@startChrome
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
	MaxActWinOnMonViaCtrlFN("^F9", delay)
	execDelayer.Wait( delay, 1.25 )

	; Reposition Chrome window for email and news browsing
	WinActivate % "Inbox ahk_exe chrome.exe"
	execDelayer.Wait( delay, 1.25 )
	MaxActWinOnMonViaCtrlFN("^F7", delay)
	execDelayer.Wait( delay, 2.25 )

	; Open tab for second Gmail account
	WinActivate % "Inbox ahk_exe chrome.exe"
	execDelayer.Wait( delay )

	; Click on the user profile icon
	clickX := 1888 * g_dpiScalar
	clickY := 141 * g_dpiScalar
	MouseMove %clickX%, %clickY%
	execDelayer.Wait( delay )
	Send {Click}
	execDelayer.Wait( delay, 15 )

	; Click on the second user account
	clickX := 1673 * g_dpiScalar
	clickY := 433 * g_dpiScalar
	MouseMove %clickX%, %clickY%
	execDelayer.Wait( delay )
	Send {Click}
	execDelayer.Wait( delay, 10 )

	; Move to the WSU Web Slack tab
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
	global webBrowserNewTabTitle
	execDelayer.Wait( delay, 1.5 )
	Gosub :*:@startChrome
	OpenWebsiteInChrome( "mail.google.com", False )
	execDelayer.Wait( delay )
	OpenWebsiteInChrome( "mail.live.com" )
	execDelayer.Wait( delay )
	OpenWebsiteInChrome( "web.wsu.edu" )
	execDelayer.Wait( delay )
	OpenWebsiteInChrome( "wsu-web.slack.com" )
	execDelayer.Wait( delay )
	MoveToNextTabInChrome()
	execDelayer.Wait( delay, 3 )

	; OpenNewWindowInChrome()
	; OpenWebsiteInChrome( "trello.com", False )
	; execDelayer.Wait( "m" )
	; MaxActWinOnMonViaCtrlFN( "^F11", delay )
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
	Gosub :*:@startChrome
	OpenWebsiteInChrome("https://www.sfchronicle.com/", False)
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("https://www.nytimes.com/")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("news.wsu.edu")
	execDelayer.Wait( delay, 10 )
	OpenWebsiteInChrome("dailyevergreen.com")
	execDelayer.Wait( delay, 20 )
	MoveToNextTabInChrome()
	MaxActWinOnMonViaCtrlFN("^F7", delay)

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
	MaxActWinOnMonViaCtrlFN("^F9", delay)

	; Load music app
	LaunchStdApplicationPatiently("shell:appsFolder\AppleInc.iTunes_nzyj5cx40ttqa!iTunes", "iTunes")
	execDelayer.Wait( delay )
	WinActivate % "iTunes ahk_exe iTunes.exe"
	execDelayer.Wait( delay )
	MaxActWinOnMonViaCtrlFN("^F11", delay)
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

#^r::
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
