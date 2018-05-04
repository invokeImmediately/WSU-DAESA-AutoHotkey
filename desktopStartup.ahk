; ==================================================================================================
; STARTUP SCRIPTS: Dual-Monitor Windows 10 Desktop PC
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
; HOTSTRINGS & SUPPORTING FUNCTIONS
; --------------------------------------------------------------------------------------------------

:*:@setupWorkEnvironment::
	Gosub, :*:@setupVirtualDesktops
	switchDesktopByNumber(1)
	Gosub, % ":*:@setupCiscoVpn"
	Sleep 330
	SoundPlay, %desktopArrangedSound%
	Gosub, % ":*:@setupWorkTimer"
	switchDesktopByNumber(5)
Return

:*:@setupVirtualDesktops::
	Gosub, :*:@setupVirtualDesktop1
	Gosub, :*:@setupVirtualDesktop2
	Gosub, :*:@setupVirtualDesktop3
	Gosub, :*:@setupVirtualDesktop4
	Gosub, :*:@setupVirtualDesktop5
Return

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@setupVirtualDesktop1::
	delay := 150
	CheckForCmdEntryGui()
	switchDesktopByNumber(1)
	Sleep, % delay
	Gosub, :*:@moveTempMonitors
	switchDesktopByNumber(1)
	Sleep, % delay
	Gosub, :*:@startSublimeText3
	Sleep, % delay * 4
	Gosub % "^F8"
	Sleep, % delay
	SendInput, % "{Enter}"
	Gosub, :*:@startChrome
Return

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

:*:@startSublimeText3::
	; Start up Sublime Text, open a new window, and send the initial, primary instance to desktop #2
	AppendAhkCmd(":*:@startSublimeText3")
	titleToMatch := "Sublime Text ahk_exe sublime_text\.exe"
	LaunchApplicationPatiently("C:\Program Files\Sublime Text 3\sublime_text.exe"
		, titleToMatch, "RegEx")
	Sleep, 150
Return

:*:@startChrome::
	; Start up Chrome and direct it to a WSU WordPress login page; wait for it to load before
	; proceeding
	AppendAhkCmd(":*:@startChrome")
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, 1000
	SendInput, !d
	Sleep, 20
	SendInput, https://distinguishedscholarships.wsu.edu/wp-admin/{Enter}
	Sleep, 100
	WaitForApplicationPatiently("WSU Distinguished")
	Gosub % "^F7"
	Sleep, 140
	SendInput, {Enter}	
	Sleep, 1000
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@setupVirtualDesktop2::
	delay := 500
	CheckForCmdEntryGui()
	switchDesktopByNumber(2)
	SendInput, #e
	WaitForApplicationPatiently("File Explorer")
	Sleep, % delay * 2
	AddSublimeText3ToVd(2)
	Sleep, % delay
	switchDesktopByNumber(2)
	Gosub, :*:@startGithubClients
	Gosub, :*:@arrangeGitHub
Return

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
			Sleep, % delay
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
	WinMove, ahk_exe sublime_text.exe, , 0, 0, 1720, 1040
	agh_MovePowerShell()
	Sleep, 200
Return

; agh_MovePowerShell: @arrangeGitHub worker function
agh_MovePowerShell() {
	beat := 333 ; units = ms, time between operations
	destX := -1527 ; units = pixels, destination X coordinate
	destY := 161 ; units = pixels, destination Y coordinate
	attemptsLimit := 9 ; make repeated attempts over 3 seconds
	hWnd := WinExist("c: ahk_class ConsoleWindowClass")
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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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
	Gosub % ">^!#Left"
	LaunchStdApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.8.exe", "GNU Image")
	Sleep, 1000
Return

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

:*:@setupVirtualDesktop4::
	CheckForCmdEntryGui()
	switchDesktopByNumber(4)
	Sleep, 150
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, 330
	OpenWebsiteInChrome("mail.google.com", False)
	OpenWebsiteInChrome("mail.live.com")
	OpenWebsiteInChrome("sfgate.com")
	OpenWebsiteInChrome("news.wsu.edu")
	OpenWebsiteInChrome("dailyevergreen.com")
	OpenWebsiteInChrome("web.wsu.edu")
	OpenWebsiteInChrome("wsu-web.slack.com")
	MoveToNextTabInChrome()
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Microsoft Office\root\Office16"
		. "\outlook.exe", "ahk_class MsoSplash ahk_exe OUTLOOK.EXE")
	Sleep, 5000
	SendInput, {Enter}
	Sleep, 1500
	WaitForApplicationPatiently("Inbox - ahk_exe OUTLOOK.EXE")
	LaunchStdApplicationPatiently(userAccountFolderSSD . "\AppData\Local\Wunderlist\Wunderlist.exe"
		, "Inbox - Wunderlist")
	Sleep, 1000
	Gosub, :*:@arrangeEmail
Return

OpenWebsiteInChrome(website, inNewTab := True) {
	website .= "{Enter}"
	if (inNewTab) {
		OpenNewTabInChrome()
	}
	NavigateToWebsiteInChrome(website)
}

OpenNewTabInChrome() {
	SendInput, ^t
	Sleep, 100	
}

NavigateToWebsiteInChrome(website) {
	SendInput, !d
	Sleep, 100
	SendInput, % website
	Sleep, 330
}

MoveToNextTabInChrome() {
	SendInput, ^{Tab}
	Sleep, 100	
}

:*:@arrangeEmail::
	AppendAhkCmd(":*:@arrangeEmail")
	LaunchStdApplicationPatiently("C:\Program Files\iTunes\iTunes.exe", "iTunes")
	WinRestore, % "Inbox - ahk_exe outlook.exe"
	WinMove, % "Inbox - ahk_exe outlook.exe", , -1920, 0, 1720, 1040
	Sleep, 100
	WinRestore, % "Inbox ahk_exe chrome.exe"
	WinMove, % "Inbox ahk_exe chrome.exe", , -1720, 0, 1720, 1040
	Sleep, 200
	WinActivate, % "Inbox ahk_exe chrome.exe"
	Sleep, 450
	MouseMove 1657, 135
	Sleep, 100
	Send {Click}
	Sleep, 3000
	MouseMove 1517, 340
	Sleep, 100
	Send {Click}
	Sleep, 500
	WinRestore, % "Inbox - Wunderlist"
	WinMove, % "Inbox - Wunderlist", , 0, 0, 1720, 1040
	Sleep, 100
	WinRestore, % "iTunes ahk_exe iTunes.exe"
	WinMove, % "iTunes ahk_exe iTunes.exe", , 200, 0, 1720, 1040
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

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
; HOTKEYS
; --------------------------------------------------------------------------------------------------

#!r::
	Gosub, :*:@setupWorkEnvironment
Return

; --------------------------------------------------------------------------------------------------
; SHUTDOWN/RESTART Hotstrings & Functions
; --------------------------------------------------------------------------------------------------

:*:@quitAhk::
	AppendAhkCmd(":*:@quitAhk")
	PerformScriptShutdownTasks()
	ExitApp
Return

PerformScriptShutdownTasks() {
	SaveAhkCmdHistory()
	SaveCommitCssLessMsgHistory()
	SaveCommitAnyFileMsgHistory()
}

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

^#!r::
	PerformScriptShutdownTasks()
	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
Return

; · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 

ScriptExitFunc(ExitReason, ExitCode) {
	if ExitReason in Logoff, Shutdown, Menu
	{
		PerformScriptShutdownTasks()
	}
}
