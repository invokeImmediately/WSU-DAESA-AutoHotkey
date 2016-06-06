; ============================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

; ============================================================================================================
; TABLE OF CONTENTS
; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---
;   Global Variables: 19  •  Workspace Management: 27  •  Utility Functions: 289  •  Text Replacement: 517
;   Program/File Launching Shortcuts: 577  •  File System Navigation: 595  •  Google Chrome Shorctuts: 645
;   Github Shortcuts: 670
; ============================================================================================================

; ------------------------------------------------------------------------------------------------------------
; GLOBAL VARIABLES
; ------------------------------------------------------------------------------------------------------------

global userAccountFolder := "C:\Users\CamilleandDaniel"
global logFileName := userAccountFolder . "\Documents\Daniel\^WSU-Web-Dev\^Personnel-File\Work-log.txt"
global workTimerCountdownTime := -1200000
global workTimerNotificationSound := userAccountFolder . "\Documents\Daniel\Sound Library\foghorn.wav"
global bitAccentToggle := false
global accentOverwrite := "{U+00b7}"
global ahkCmds := Array()
global ahkCmdLimit := 20
global CmdChosen
global hotstrStartTime := 0
global hotstrEndTime := 0

#NoEnv
#SingleInstance

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\functions.ahk

; ------------------------------------------------------------------------------------------------------------
; COMMAND HISTORY
; ------------------------------------------------------------------------------------------------------------
#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\commandHistory.ahk

; ------------------------------------------------------------------------------------------------------------
; WORKSPACE MANAGEMENT
; ------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\workspaceMngmnt.ahk

#!r::
    SetTitleMatchMode, 2
    LaunchApplicationPatiently("C:\Program Files (x86)\Notepad++\notepad++.exe", "C:\Users")
    SendInput ^{End}
    Sleep 330
    SendInput !{F6}
    Sleep 500
    SendInput !{Tab}
    Sleep 750
    Gosub % "^!1"
    Sleep 750
    LaunchApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
    Sleep 330
    SendInput !d
    Sleep 20
    SendInput, https://stage.oue.wsu.edu/wp-admin/{Enter}
    Sleep 100
    WaitForApplicationPatiently("Office of Undergraduate")
    Sleep 1000
    SendInput, #{Tab}
    Sleep, 330
    SendInput, {Tab}{Right}{Enter}
    Sleep, 330
    SendInput, #e
    WaitForApplicationPatiently("File Explorer")
    Sleep, 330
    LaunchApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
    SendInput !d
    Sleep 100
    SendInput, https://github.com/invokeImmediately{Enter}
    Sleep 330
    LaunchApplicationPatiently(userAccountFolder . "\AppData\Local\GitHub\Github.appref-ms", "GitHub ahk_exe GitHub.exe")
    LaunchApplicationPatiently(userAccountFolder . "\Desktop\Git Shell.lnk", "Powershell")
    Sleep 1000
    Gosub :*:@arrangeGitHub
    SendInput, #{Tab}
    Sleep, 330
    SendInput, {Tab}{Right}{Right}{Enter}
    LaunchApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
    SendInput !d
    Sleep 100
    SendInput, http://www.colorhexa.com/{Enter}
    Sleep 330
    LaunchApplicationPatiently("C:\Program Files\GIMP 2\bin\gimp-2.8.exe", "GNU Image")
    Sleep 1000
    SendInput, #{Tab}
    Sleep, 330
    SendInput, {Tab}{Right}{Right}{Right}{Enter}
    LaunchApplicationPatiently("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "New Tab")
    Run outlook
    Sleep 5000
    SendInput {Enter}
    Sleep 1500
    WaitForApplicationPatiently("Inbox - ahk_exe outlook.exe")
    LaunchApplicationPatiently("C:\Program Files\Microsoft Office 15\root\office15\onenote.exe", "- OneNote")
    Sleep 1000
    Gosub :*:@arrangeEmail
    SendInput, #{Tab}
    Sleep, 330
    SendInput, {Tab}{Right}{Right}{Right}{Right}{Enter}
    Sleep, 330
    LaunchApplicationPatiently(userAccountFolder . "\Documents\Daniel\^WSU-Web-Dev\^Personnel-File\Work Queue.xlsm", "Microsoft Excel")
    Sleep, 1000
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Enter}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@arrangeGitHub::
    SetTitleMatchMode, 2
    WinRestore, GitHub
    WinMove, GitHub, , -1893, 20, 1868, 772
    Sleep 200
    WinRestore, PowerShell
    WinMove, PowerShell, , -1527, 161
    Sleep 200
    WinRestore, invokeImmediately
    WinMove, invokeImmediately, , -1830, 0, 1700, 1040
    Sleep 200
    WinRestore, File Explorer
    WinMove, File Explorer, , 100, 0, 1820, 1040
    Sleep 200
    WinActivate, C:\Users
    Sleep 330
    WinRestore, C:\Users
    WinMove, C:\Users, , 0, 0, 1820, 1040
    Sleep 200
    WinActivate, PowerShell
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@arrangeEmail::
    SetTitleMatchMode, 2
    WinActivate, % "New Tab"
    Sleep 330
    SendInput !{d}
    Sleep 100
    SendInput % "mail.google.com{Enter}"
    Sleep 330
    SendInput ^t
    Sleep 100
    SendInput !{d}
    Sleep 100
    SendInput live.com{Enter}
    Sleep 330
    SendInput ^t
    Sleep 100
    SendInput !{d}
    Sleep 100
    SendInput % "biblegateway.com{Enter}"
    Sleep 1000
    SendInput ^{Tab}
    Sleep 330
    LaunchApplicationPatiently("C:\Program Files\iTunes\iTunes.exe", "iTunes")
    WinRestore, Outlook
    WinMove, Outlook, , -1920, 0, 1820, 1040
    Sleep 100
    WinRestore, Gmail
    WinMove, Gmail, , -1820, 0, 1820, 1040
    Sleep 100
    WinRestore, OneNote
    WinMove, OneNote, , 0, 0, 1820, 1040
    Sleep 100
    WinRestore, iTunes
    WinMove, iTunes, , 100, 0, 1820, 1040
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@arrangeGimp::
    SetTitleMatchMode, 2
    WinActivate, Toolbox - Tool Options
    Sleep 100
    WinMove, Toolbox - Tool Options, , -960, 0, 272, 1040
    Sleep 100
    WinActivate, Layers
    Sleep 100
    WinMove, Layers, , -699, 0, 356, 1040
    Sleep 100
    WinActivate, FG/BG
    Sleep 100
    WinMove, FG/BG, , -345, 0, 350, 522
    Sleep 100
    WinActivate, Navigation
    Sleep 100
    WinMove, Navigation, , -345, 518, 350, 522
return

; ------------------------------------------------------------------------------------------------------------
; UTILITY FUNCTIONS: For working with AutoHotkey
; ------------------------------------------------------------------------------------------------------------

:*:@checkIsUnicode::
    AppendAhkCmd(":*:@checkIsUnicode")
    MsgBox % "Unicode flag set to: " A_IsUnicode
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@getWinTitle::
    AppendAhkCmd(":*:@getWinTitle")
    WinGetTitle, thisTitle, A
    MsgBox, The active window is "%thisTitle%"
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@getWinPos::
    AppendAhkCmd(":*:@getWinPos")
    WinGetPos, thisX, thisY, thisW, thisH, A
    MsgBox, % "The active window is at" . thisX . ", " . thisY . "`rWidth: " . thisW . ", Height: " . thisH
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@getWinPID::
    AppendAhkCmd(":*:@getWinPID")
    WinGet, thisPID, PID, A
    MsgBox, % "The active window PID is " . thisPID
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@getWinProcess::
    AppendAhkCmd(":*:@getWinProcess")
    WinGet, thisProcess, ProcessName, A
    MsgBox, % "The active window process name is " . thisProcess
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@getMousePos::
    AppendAhkCmd(":*:@getMousePos")
    MouseGetPos, windowMousePosX, windowMousePosY
    MsgBox % "The mouse cursor is at {x = " . windowMousePosX . ", y = " . windowMousePosY . "} relative to the window."
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@getLastHotStrTime::
    MsgBox % "The last hotstring took " . (hotStrEndTime - hotStrStartTime) . "ms to run."
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^+F1::
    clpbrdLngth := StrLen(clipboard)
    MsgBox % "The clipboard is " . clpbrdLngth . " characters long."
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!q::
    IfWinExist % "Untitled - Notepad"
        WinActivate % "Untitled - Notepad"
    else
        Run Notepad
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@setupWorkTimer::
    logFile := FileOpen(logFileName, "r `n")
    lineCount := 0
    logFileLines := Object()
    Loop
    {
        logFileLines[lineCount] := logFile.ReadLine()
        if (logFileLines[lineCount] = "") {
            break
        }
        lineCount := lineCount + 1
    }
    logFile.Close()
    FormatTime, todaysDate, A_Now, yyyy-MM-dd
    lineIndex := lineCount - 1
    dateFoundInFile := false
    Loop
    {
        if (lineIndex < 0) {
            break
        }
        dateOfLine := SubStr(logFileLines[lineIndex], 1, 10)
        if (dateOfLine = todaysDate) {
            dateFoundInFile := true
            break
        } else if (dateOfLine < todaysDate) {
            break
        }
        lineIndex := lineIndex - 1
    }
    if (dateFoundInFile) {
        MsgBox % 3, % "Continue Tracking Time?", % "It looks like work time was already logged for today. Would you like to restart the timer, counting the intervening time as a break?"
        IfMsgBox Yes
        {
            ; Find the end time, use that for break time.
            lineSubIndex := lineIndex
            Loop
            {
                if (lineSubIndex < 0) {
                    break
                }
                lineSubStr := SubStr(logFileLines[lineSubIndex], 13, 20)
                if (lineSubStr = "Ended work timer at ") {
                    timerEndTime := A_YYYY . A_MM . A_DD . SubStr(logFileLines[lineSubIndex], 33, 2) . SubStr(logFileLines[lineSubIndex], 36, 2) . SubStr(logFileLines[lineSubIndex], 39, 2)
                    timerTimeWorked := SubStr(logFileLines[lineSubIndex], 73, 8) * 3600
                    break
                } else if (dateOfLine < todaysDate) {
                    break
                }
                lineSubIndex := lineSubIndex - 1
            }
;            MsgBox % timerEndTime . " was end time, found on line " . lineSubIndex
            
            ; Find the start time, continuing from before.
            Loop
            {
                if (lineSubIndex < 0) {
                    break
                }
                lineSubStr := SubStr(logFileLines[lineSubIndex], 13, 22)
                if (lineSubStr = "Started work timer at ") {
                    timerStartTime := A_YYYY . A_MM . A_DD . SubStr(logFileLines[lineSubIndex], 35, 2) . SubStr(logFileLines[lineSubIndex], 38, 2) . SubStr(logFileLines[lineSubIndex], 41, 2)
                    break
                } else if (dateOfLine < todaysDate) {
                    break
                }
                lineSubIndex := lineSubIndex - 1
            }
;            MsgBox % timerStartTime . " was start time, found on line " . lineSubIndex
            
            ; Back-calculate the total break time, and proceed with the timer.
            timeElapsed := timerEndTime
            EnvSub, timeElapsed, %timerStartTime%, seconds
            timerTotalBreakTime := timeElapsed - timerTimeWorked
            timerBreakTime := A_Now
            EnvSub, timerBreakTime, %timerEndTime%, seconds
            EnvAdd, timerTotalBreakTime, %timerBreakTime%
;            MsgBox % timerTotalBreakTime
            logFile := FileOpen(logFileName, "a `n")
            logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Restarted work timer at " . A_Hour . ":" . A_Min . ":" . A_Sec )
            logFile.Close()
            SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
            latestTimerStartTime := A_Now
            workTimerRunning := true
        }
    } else {
        MsgBox, 1, Starting Work Timer, A work timer will be set to run for 20 minutes to indicate when you should next take a break.
        IfMsgBox OK
        {
            logFile := FileOpen(logFileName, "a `n")
            timerStartTime := A_Now
            timerTotalBreakTime := 0
            logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Started work timer at " . A_Hour . ":" . A_Min . ":" . A_Sec )
            logFile.Close()
            SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
            latestTimerStartTime := A_Now
            workTimerRunning := true
        }
    }
return

PostWorkBreakMessage:
    timerEndTime := A_Now
    timerTimeWorked := timerEndTime
    EnvSub, timerTimeWorked, %timerStartTime%, seconds
    timerTimeWorked := timerTimeWorked / 3600 - timerTotalBreakTime / 3600    
    SoundPlay, %workTimerNotificationSound%
    MsgBox, 4, Work Break Timer, % "You have spent the last 20 minutes working; it's time to take a break.`nTime worked so far: " . timerTimeWorked  . " hours.`nWould you like to start another 20 minute timer?"
    logFile := FileOpen(logFileName, "a `n")
    IfMsgBox Yes
    {
        timerBreakTime := A_Now
        EnvSub, timerBreakTime, %timerEndTime%, seconds
        EnvAdd, timerTotalBreakTime, %timerBreakTime%
        FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
        logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended break at " . timerEndTimeHMS . " for " . (timerBreakTime / 60) . " minutes. Cumulative time worked today: " . timerTimeWorked . " hours")
        FormatTime, timerRestartHMS, , HH:mm:ss
        logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Restarted work timer at " . timerRestartHMS )
        logFile.Close()
        SetTimer, PostWorkBreakMessage, %workTimerCountdownTime%
        latestTimerStartTime := A_Now
        workTimerRunning := true
    }
    Else {
        timerBreakTime := timerTimeWorked
        EnvSub, timerBreakTime, %timerEndTime%, seconds
        EnvAdd, timerTotalBreakTime, %timerBreakTime%
        FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
        logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended work timer at " . timerEndTimeHMS . ". Cumulative time worked today: " . timerTimeWorked . " hours")
        logFile.Close()    
        workTimerRunning := false
    }
return

:*:@stopWorkTimer::
    if (workTimerRunning) {
        MsgBox % 3, % "Stop work timer?", % "Would you like to stop your 20 minute work timer prematurely?"
        IfMsgBox Yes
        {
            logFile := FileOpen(logFileName, "a `n")
            timerTimeWorked := A_Now
            EnvSub, timerTimeWorked, %timerStartTime%, seconds
            timerTimeWorked := timerTimeWorked / 3600 - timerTotalBreakTime / 3600
            FormatTime, timerEndTimeHMS, timerEndTime, HH:mm:ss
            logFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . ": Ended work timer at " . timerEndTimeHMS . ". Cumulative time worked today: " . timerTimeWorked . " hours")
            logFile.Close()    
            SetTimer, PostWorkBreakMessage, Delete
            workTimerRunning := false
        }
    } else {
        MsgBox % 1, % "Stop work timer?", % "No work timer is currently running."
    }
return

:*:@checkWorkTimer::
    if (workTimerRunning) {
        timerTimeLeft := A_Now
        EnvSub, timerTimeLeft, %latestTimerStartTime%, seconds
        timerTimeLeft := (-1* workTimerCountdownTime / 1000 - timerTimeLeft) / 60
        MsgBox % 1, % "Check Work Timer", % "There are " . timerTimeLeft . " minutes left on the work timer."
    }
return

; ------------------------------------------------------------------------------------------------------------
; TEXT REPLACEMENT
; ------------------------------------------------------------------------------------------------------------

:*:@ddd::
    FormatTime, CurrentDateTime,, yyyy-MM-dd
    SendInput %CurrentDateTime%
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@datetime::
    FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm:ss
    SendInput %CurrentDateTime%
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@xsss::
    FormatTime, CurrentDateTime,, yyyy-MM-dd
    SendInput (Started %CurrentDateTime%)
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@xccc::
    FormatTime, CurrentDateTime,, yyyy-MM-dd
    SendInput / Completed %CurrentDateTime%
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@ppp::
    SendInput news-events_events_.html{Left 5}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@add5lineshere::
    SendInput {Enter 5}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@doRGBa::
    SendInput rgba(@rval, @gval, @bval, );{Left 2}
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@addNrml::{Space}class="oue-normal"

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@addClass::class=""{Space}{Left 2}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@toggleAccentKey::
    bitAccentToggle := !bitAccentToggle
return

^+`::
    Gosub :*:@toggleAccentKey
return

:*:``::
    if (bitAccentToggle) {
        SendInput % accentOverwrite
    }
    else {
        SendInput ``
    }
return

:*:@changeAccentOverwrite::
    Inputbox, inputEntered, % "Change Accent Overwrite", % "Enter a character/string that the accent key will now represent when alternative input is toggled."
    if (!ErrorLevel) {
        accentOverwrite := inputEntered
    }
return

; ------------------------------------------------------------------------------------------------------------
; PROGRAM/FILE LAUNCHING SHORTCUTS
; ------------------------------------------------------------------------------------------------------------

:R*?:runNotepad::
    Run C:\Program Files (x86)\Notepad++\notepad++.exe
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

#z::
    Run notepad++.exe, C:\Program Files (x86)\Notepad++, Max
return

:*:@checkHTMLSpec::
    Run % userAccountFolder . "\Documents\Daniel\^WSU-Web-Dev\^Master-VPUE\Anatomy of an HTML5 Document_2016-03-16.jpg"
return

; ------------------------------------------------------------------------------------------------------------
; FILE SYSTEM NAVIGATION
; ------------------------------------------------------------------------------------------------------------

:*:@gotoTorah::C:\Users\CamilleandDaniel\Documents\Daniel\{^}Derek-Haqodesh\{Enter}
:*:@gotoCurrent::C:\Users\CamilleandDaniel\Documents\Daniel\{^}Derek-Haqodesh\TheMessage.cc\Messages\Message_The-Man-from-Heaven_2015-12-06{Enter}
:*:@gotoGithub::C:\Users\CamilleandDaniel\Documents\GitHub{Enter}
:*:@gotoWebdev::C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev{Enter}
:*:@gotoFye::C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev\FYE{Enter}
:*:@gotoSurca::C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev\SURCA{Enter}
:*:@gotoDsp::C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev\SURCA{Enter}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

:*:@openNodeCodes::SendInput C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev\{^}Master-VPUE\Node\node-commands.bat{Enter}
:*:@openGitCodes::SendInput C:\Users\CamilleandDaniel\Documents\Daniel\{^}WSU-Web-Dev\GitHub\git-codes.bat{Enter}

; ------------------------------------------------------------------------------------------------------------
; GOOGLE CHROME SHORTCUTS
; ------------------------------------------------------------------------------------------------------------

^!o::
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "chrome.exe") {
        SendInput ^n
        Sleep 333
        SendInput ^+o
        Sleep 100
        SendInput ^!m
    } else {
        GoSub, PerformBypassingCtrlAltO
    }
return

PerformBypassingCtrlAltO:
    Suspend
    Sleep 10
    SendInput ^!o
    Sleep 10
    Suspend, Off
return

#Include %A_ScriptDir%\GitHub\WSU-OUE-AutoHotkey\github.ahk

; Shift + Wheel for horizontal scrolling
;+WheelDown::WheelRight
;+WheelUp::WheelLeft
