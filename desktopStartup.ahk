; ============================================================================================================
; STARTUP SCRIPTS: Dual-Monitor Windows 10 Desktop PC
; ============================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

;   --------------------------------------------------------------------------------------------------------
;   FUNCTIONS
;   --------------------------------------------------------------------------------------------------------

:*:@setupVirtualDesktop1::
	Gosub, :*:@moveTempMonitors
	Gosub, :*:@startNotepadPp
	Gosub, :*:@startChrome
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupVirtualDesktop2::
	SendInput, #{Tab}
	Sleep, 330
	SendInput, {Tab}{Right}{Enter}
	Sleep, 330
	SendInput, #e
	WaitForApplicationPatiently("File Explorer")
	Gosub, :*:@startGithubClients
	Gosub, :*:@arrangeGitHub
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupVirtualDesktop3::
	SendInput, #{Tab}
	Sleep, 330
	SendInput, {Tab}{Right}{Right}{Enter}
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
	SendInput, !d
	Sleep, 100
	SendInput, http://www.colorhexa.com/{Enter}
	Sleep, 330
	Gosub % "^!#Left"
	LaunchStdApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.8.exe", "GNU Image")
	Sleep, 1000
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupVirtualDesktop4::
	CheckForCmdEntryGui()
	SendInput, #{Tab}
	Sleep, 330
	SendInput, {Tab}{Right}{Right}{Right}{Enter}
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
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
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Microsoft Office\root\Office16\outlook.exe", "Outlook ahk_class MsoSplash ahk_exe OUTLOOK.EXE")
	Sleep, 1000
	SendInput, {Enter}
	Sleep, 1500
	WaitForApplicationPatiently("Inbox - ahk_exe OUTLOOK.EXE")
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Microsoft Office\root\office16\onenote.exe", "ahk_exe ONENOTE.EXE")
	Sleep, 1000
	Gosub, :*:@arrangeEmail
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupVirtualDesktop5::
	CheckForCmdEntryGui()
	SendInput, #{Tab}
	Sleep, 330
	SendInput, {Tab}{Right}{Right}{Right}{Right}{Enter}
	Sleep, 330
	LaunchStdApplicationPatiently(userAccountFolder . "\AppData\Local\Wunderlist\Wunderlist.exe", "Inbox - Wunderlist")
	Sleep, 1000
	LaunchStdApplicationPatiently("C:\Windows\System32\taskmgr.exe", "Task Manager")
	Sleep, 1000
	WinMove, % "Inbox - Wunderlist", , 136, 88, 1648, 874
	Sleep, 200
	WinMove, % "GPU Temp", , -541, 59, 480, 400
	Sleep, 200
	WinMove, % "RealTemp", , -537, 477, 318, 409
	Sleep, 200
	WinMove, % "Task Manager", , -1528, 184, 976, 600
	Sleep, 200
	WinActivate, % "Inbox - Wunderlist"
Return

;   --------------------------------------------------------------------------------------------------------
;   HOTKEYS
;   --------------------------------------------------------------------------------------------------------

#!r::
	Gosub, :*:@setupVirtualDesktop1
	Gosub, :*:@setupVirtualDesktop2
	Gosub, :*:@setupVirtualDesktop3
	Gosub, :*:@setupVirtualDesktop4
	Gosub, :*:@setupVirtualDesktop5	
	SendInput, #{Tab}
	Sleep, 330
	SendInput, {Tab}{Enter}
	Sleep, 330
	Gosub, % ":*:@setupWorkTimer"
Return

;   --------------------------------------------------------------------------------------------------------
;   HOTSTRINGS
;   --------------------------------------------------------------------------------------------------------

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

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@arrangeEmail::
	AppendAhkCmd(":*:@arrangeEmail")
	LaunchStdApplicationPatiently("C:\Program Files\iTunes\iTunes.exe", "iTunes")
	WinRestore, % "Inbox - ahk_exe outlook.exe"
	WinMove, % "Inbox - ahk_exe outlook.exe", , -1920, 0, 1720, 1040
	Sleep, 100
	WinRestore, % "Gmail ahk_exe chrome.exe"
	WinMove, % "Gmail ahk_exe chrome.exe", , -1720, 0, 1720, 1040
	Sleep, 200
	WinActivate, % "Gmail ahk_exe chrome.exe"
	Sleep, 200
	CoordMode, Mouse, Client
	Sleep, 250
	MouseMove 1657, 135
	Sleep, 100
	Send {Click}
	Sleep, 3000
	MouseMove 1517, 340
	Sleep, 100
	Send {Click}
	Sleep, 500
	WinRestore, OneNote
	WinMove, OneNote, , 0, 0, 1720, 1040
	Sleep, 100
	WinRestore, % "iTunes ahk_exe iTunes.exe"
	WinMove, iTunes, , 200, 0, 1720, 1040
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

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

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@moveTempMonitors::
	; Send temperature monitoring programs to desktop #5 from #1
	AppendAhkCmd(":*:@moveTempMonitors")
	WinActivate, % "GPU Temp"
	Sleep, 330
	Gosub % "^!4"
	Sleep, 750
	WinActivate, % "RealTemp"
	Sleep, 330
	Gosub % "^!4"
	Sleep, 750
Return


;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@startChrome::
	; Start up Chrome and direct it to a WSU WordPress login page; wait for it to load before proceeding
	AppendAhkCmd(":*:@startChrome")
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
	Sleep, 1000
	SendInput, !d
	Sleep, 20
	SendInput, https://distinguishedscholarships.wsu.edu/wp-admin/{Enter}
	Sleep, 100
	WaitForApplicationPatiently("WSU Distinguished")
	Gosub % "^F7"
	Sleep, 1000
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@startGithubClients::
	AppendAhkCmd(":*:@startGithubClients")
	Sleep, 330
	LaunchStdApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
	SendInput, !d
	Sleep, 100
	SendInput, https://github.com/invokeImmediately{Enter}
	Sleep, 1000
	LaunchStdApplicationPatiently(userAccountFolder . "\AppData\Local\GitHub\Github.appref-ms", "GitHub ahk_exe GitHub.exe")
	Sleep, 1000
	LaunchStdApplicationPatiently(userAccountFolder . "\Desktop\Git Shell.lnk", "Powershell")
	Sleep, 1000
Return

;   ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@startNotepadPp::
	; Start up Notepad++, open a second instance, and send the initial, primary instance to desktop #2
	AppendAhkCmd(":*:@startNotepadPp")
	LaunchApplicationPatiently("C:\Program Files (x86)\Notepad++\notepad++.exe", "C:\Users ahk_exe notepad++.exe")
	Sleep, 3000
	WinActivate, % "C:\Users ahk_exe notepad++.exe"
	Sleep, 100
	SendInput, ^{End}
	Sleep, 500
	SendInput, !+{F6}
	Sleep, 3000
	SendInput, !{Tab}
	Sleep, 750
	Gosub % "^!1"
	Sleep, 750
	Gosub % "^F8"
	Sleep, 500
Return
