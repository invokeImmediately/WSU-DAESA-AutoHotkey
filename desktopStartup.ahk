; ==================================================================================================
; STARTUP SCRIPTS: Dual-Monitor Windows 10 Desktop PC
; ==================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
; FUNCTIONS
; --------------------------------------------------------------------------------------------------

:*:@setupWorkEnvironment::
	Gosub, :*:@setupVirtualDesktops
	SendInput, #{Tab}
	Sleep, 330
	SendInput, {Tab}{Enter}
	Sleep, 330
	Gosub, % ":*:@setupCiscoVpn"
	Sleep 330
	SoundPlay, %desktopArrangedSound%
	Gosub, % ":*:@setupWorkTimer"
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupVirtualDesktop1::
	CheckForCmdEntryGui()
	switchDesktopByNumber(1)
	Sleep, 150
	Gosub, :*:@moveTempMonitors
	Gosub, :*:@startNotepadPp
	Gosub, :*:@startChrome
Return

:*:@moveTempMonitors::

	; Send temperature monitoring programs to desktop #5 from #1
	AppendAhkCmd(":*:@moveTempMonitors")
	WinActivate, % "GPU Temp ahk_exe GPUTemp.exe"
	Sleep, 330
	moveActiveWindowToVirtualDesktop(5)
	Sleep, 240
	WinActivate, % "RealTemp ahk_exe RealTemp.exe"
	Sleep, 330
	moveActiveWindowToVirtualDesktop(5)
	Sleep, 240

Return

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
	Sleep, 500

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
	Sleep, 1000
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupVirtualDesktop2::
	CheckForCmdEntryGui()
	Sleep, 150
	switchDesktopByNumber(2)
	SendInput, #e
	WaitForApplicationPatiently("File Explorer")
	Gosub, :*:@startGithubClients
	Gosub, :*:@arrangeGitHub
Return

:*:@startGithubClients::
	AppendAhkCmd(":*:@startGithubClients")
	Sleep, 330
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	SendInput, !d
	Sleep, 100
	SendInput, https://github.com/invokeImmediately{Enter}
	Sleep, 1000
	LaunchStdApplicationPatiently(userAccountFolderSSD . "\AppData\Local\GitHub\Github.appref-ms"
		, "GitHub ahk_exe GitHub.exe")
	Sleep, 1000
	LaunchStdApplicationPatiently(userAccountFolderSSD . "\Desktop\Git Shell.lnk"
		, "ahk_exe Powershell.exe")
	Sleep, 1000
Return

:*:@arrangeGitHub::
	AppendAhkCmd(":*:@arrangeGitHub")
	WinRestore, GitHub
	WinMove, GitHub, , -1893, 20, 1868, 772
	Sleep, 200
	WinRestore, % "ahk_exe Powershell.exe"
	WinMove, % "ahk_exe Powershell.exe", , -1527, 161
	Sleep, 200
	WinRestore, invokeImmediately
	WinMove, invokeImmediately, , -1830, 0, 1700, 1040
	Sleep, 200
	WinRestore, File Explorer
	WinMove, File Explorer, , 200, 0, 1720, 1040
	Sleep, 200
	WinActivate, C:\Users
	Sleep, 330
	WinRestore, C:\Users
	WinMove, C:\Users, , 0, 0, 1720, 1040
	Sleep, 200
	WinActivate, PowerShell
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
	Gosub % "^!#Left"
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupVirtualDesktop4::
	CheckForCmdEntryGui()
	switchDesktopByNumber(4)
	Sleep, 150
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
		, "New Tab")
	Sleep, 330
	SendInput, !{d}
	Sleep, 100
	SendInput, % "mail.google.com{Enter}"
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "mail.live.com{Enter}"
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "biblegateway.com{Enter}"
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "sfgate.com{Enter}"
	Sleep, 330
	SendInput, ^t
	Sleep, 100
	SendInput, !{d}
	Sleep, 100
	SendInput, % "web.wsu.edu{Enter}"
	Sleep, 1000
	SendInput, ^{Tab}
	Sleep, 330
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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
	WinRestore, % "Free Bible ahk_exe chrome.exe"
	WinMove, % "Free Bible ahk_exe chrome.exe", , 136, 88, 1648, 874
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

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^#!r::
	PerformScriptShutdownTasks()
	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

ScriptExitFunc(ExitReason, ExitCode) {
	if ExitReason in Logoff, Shutdown, Menu
	{
		PerformScriptShutdownTasks()
	}
}
