; ==================================================================================================
; virtualDesktops.ahk
; ==================================================================================================
; * Script code adapted from https://www.computerhope.com/tips/tip224.htm, "Using AutoHotkey to 
;   switch Virtual Desktops in Windows 10." The article there indicates that the code is ultimately 
;   adapted from https://github.com/pmb6tz/windows-desktop-switcher.
; --------------------------------------------------------------------------------------------------
; TABLE OF CONTENTS:
;   §1: GLOBAL VARIABLES.......................................................................24
;   §2: FUNCTIONS & SUBROUTINES................................................................30
;     >>> §2.1: CloseOpenWindowsOnVD...........................................................34
;     >>> §2.2: CreateVirtualDesktop..........................................................102
;     >>> §2.3: DeleteVirtualDesktop..........................................................116
;     >>> §2.4: GetCurrentVirtualDesktop......................................................130
;     >>> §2.5: GetSessionId..................................................................143
;       →→→ §2.5.1: @getSessionId.............................................................163
;     >>> §2.6: MapDesktopsFromRegistry.......................................................174
;     >>> §2.7: MoveActiveWindowToVirtualDesktop..............................................236
;     >>> §2.8: PrimeVirtualDesktops..........................................................299
;     >>> §2.9: SwitchDesktopByNumber.........................................................316
; --------------------------------------------------------------------------------------------------

; --------------------------------------------------------------------------------------------------
;   §1: GLOBAL VARIABLES
; --------------------------------------------------------------------------------------------------
global vdDesktopCount = 2 ; Windows starts with 2 desktops at boot
global vdCurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)

; --------------------------------------------------------------------------------------------------
;   §2: FUNCTIONS & SUBROUTINES
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: CloseOpenWindowsOnVD (Abbreviated prefix: cowvd_…)
;
; 		Research:
; 		--------
; 		• Anything unique about Explorer.exe (i.e., desktop process) that can distinguish it from
; 		File Explorer?
;
; 		Execution Steps:
; 		---------------
; 		• Get the active window process name + title + Hwnd; store in an object.
; 		• Check if there was already an attempt to close the window, or if we have hit the desktop
; 		  with no open windows left. If not, add the 
; 		• If appropriate, tell the active window to close via Ctrl+W or Alt+F4.
; 		• Then, switch to the next available window via Alt+Tab.
; 		• Loop as long as there are new open windows to close.
; 		• Exit conditions: the desktop is now active, or we circled around to a window we already
; 		  tried to close.
;
; 		Testing that is needed:
; 		----------------------
; 		• Is there a way to keep track of windows that didn't successfully close? Perhaps they can
; 		  then be reviewed via a hotstring. Or a message box could report which VD's still have a
; 		  window open on it. (Perhaps this specific function could return a bool via allWindowsClosed,
; 		  or an array of Hwnds.)
; 		• Do we need to run checks on each window, e.g., by adding a counter to the object and
; 		  running through the loop multiple times?

:*:@testCloseOpenWindows::
	AppendAhkCmd(A_ThisLabel)
	CloseOpenWindowsOnVD()	
Return

CloseOpenWindowsOnVD() { ; - Alias = cowvd
	global g_osDesktopHwnd
	delay := GetDelay("short")

	; Make sure the active window window to see if it is the OS desktop
	cowvd_CheckOsDesktopHwnd()
	windowsAlreadyClosed := cowvd_GetStarted(delay)
	if (!windowsAlreadyClosed) {
		; Proceed...
	}

	; First draft of code...
;	WinGet, aProcess, ID, A
;	WinGetClass, aClass, A
;	if (!cowvd_IsOsActive()) {
;		vdHWnds := Array()
		; TODO: Finish writing statement block.
		; Log all open windows
;	} else {
		; Perform at least one alt+tab and see if the OS desktop is still active
;		SendInput, !{Tab}
;		Sleep, % delay
;		if (!cowvd_IsOsActive()) {
			; TODO: Finish writing statement block.
;		}
;	}
}

cowvd_CheckOsDesktopHwnd(overwrite := False) {
	global g_osDesktopWinTitle
	global g_osDesktopHwnd

	if (!g_osDesktopHwnd || overwrite) {
		WinGet g_osDesktopHwnd, ID, % g_osDesktopWinTitle
	}
}

cowvd_GetStarted(delay) {
	windowsAlreadyClosed := false
	if (cowvd_IsOsActive()) {
		SendInput !{Tab}
		Sleep % delay * 2
		if (cowvd_IsOsActive()) {
			windowsAlreadyClosed := true
		}
	}
	return windowsAlreadyClosed
}

cowvd_IsOsActive() {
	global g_osDesktopHwnd

	WinGet aHwnd, ID, A
	return aHwnd == g_osDesktopHwnd
}

cowvd_ProcessOpenWindows() {

}

;   ································································································
;     >>> §2.2: CreateVirtualDesktop

CreateVirtualDesktop() {
	global vdCurrentDesktop, vdDesktopCount
	prevKeyDelay := A_KeyDelay

	SetKeyDelay, 75
	Send, #^d
	MapDesktopsFromRegistry()
	SetKeyDelay, prevKeyDelay
	OutputDebug, [create] desktops: %vdDesktopCount% current: %vdCurrentDesktop%
}

;   ································································································
;     >>> §2.3: DeleteVirtualDesktop

DeleteVirtualDesktop() {
	global vdCurrentDesktop, vdDesktopCount
	prevKeyDelay := A_KeyDelay

	SetKeyDelay, 75
	Send, #^{F4}
	MapDesktopsFromRegistry()
	SetKeyDelay, prevKeyDelay
	OutputDebug, [delete] desktops: %vdDesktopCount% current: %vdCurrentDesktop%
}

;   ································································································
;     >>> §2.4: GetCurrentVirtualDesktop

; * Couples a call to MapDesktopsFromRegistry to the value of global variable vdCurrentDesktop.
; * Preferable to relying on the global variable vdCurrentDesktop, which requires a separate call to 
;   MapDesktopsFromRegistry to ensure accuracy.
GetCurrentVirtualDesktop() {
	global vdCurrentDesktop

	MapDesktopsFromRegistry()
	return vdCurrentDesktop
}

;   ································································································
;     >>> §2.5: GetSessionId
;
;	Use the current process ID to find the Session ID, which is needed for mapping virtual desktops
;   via the registry.

GetSessionId() {
	ProcessId := DllCall("GetCurrentProcessId", "UInt")
	if ErrorLevel {
		OutputDebug, Error getting current process id: %ErrorLevel%
		return
	}
	DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
	if ErrorLevel {
		OutputDebug, Error getting session id: %ErrorLevel%
		return
	}
	return SessionId
}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §2.5.1: @getSessionId
;
;	Use the DisplaySplashText function to show the current Session ID to the user.

:*:@getSessionId::
	SessionId := GetSessionId()
	msg := "Current session id via GetSessionId() = " . SessionId
	DisplaySplashText(msg)
Return

;   ································································································
;     >>> §2.6: MapDesktopsFromRegistry
;
;   Examine the registry to build an accurate list of the current virtual desktops and which one
;   we're currently on.
;
;   * Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVers
;      ion\Explorer\SessionInfo\1\VirtualDesktops
;   * List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\
;      Explorer\VirtualDesktops

MapDesktopsFromRegistry() {
	global vdCurrentDesktop
	global vdDesktopCount

	; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this
	; couldn't change in a later Windows release so we check.
	IdLength := 32
	SessionId := GetSessionId()
	if (SessionId) {
		RegRead, CurrentDesktopId
			, % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\"
			. SessionId . "\VirtualDesktops"
			, % "CurrentVirtualDesktop"
		if (CurrentDesktopId) {
			IdLength := StrLen(CurrentDesktopId)
		}
	}

	; Get a list of the UUIDs for all virtual desktops on the system
	RegRead, DesktopList
		, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
		, VirtualDesktopIDs
	if (DesktopList) {
		DesktopListLength := StrLen(DesktopList)

		; Figure out how many virtual desktops there are
		vdDesktopCount := DesktopListLength / IdLength

	} else {
		vdDesktopCount := 1
	}

	; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry
	i := 0
	while (CurrentDesktopId and i < vdDesktopCount) {
		StartPos := (i * IdLength) + 1
		DesktopIter := SubStr(DesktopList, StartPos, IdLength)
		; OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.

		; Break out if we find a match in the list. If we didn't find anything, keep the
		; old guess and pray we're still correct :-D.
		if (DesktopIter = CurrentDesktopId) {
			vdCurrentDesktop := i + 1
			; OutputDebug, Current desktop number is %vdCurrentDesktop% with an ID of %DesktopIter%.
			break
		}

		i++
	}
}

;   ································································································
;     >>> §2.7: MoveActiveWindowToVirtualDesktop

MoveActiveWindowToVirtualDesktop(targetDesktop) {
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DECLARATIONS
	global vdCurrentDesktop
	global vdDesktopCount

	; Timing variables
	prevKeyDelay := A_KeyDelay
	keyDelay := 120
	pauseAmt := 200

	; UI interaction variables
	awThumbnailX := 95 ; Active Window Thumbnail: horizontal click position
	awThumbnailY := 220 ; Active Window Thumbnail: vertical click position

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; BEGIN EXECUTION
	SetKeyDelay %keyDelay%

	; Re-generate the list of desktops and where we fit in that. We do this because
	; the user may have switched desktops via some other means than the script.
	MapDesktopsFromRegistry()
	
	; Don't attempt to move to an invalid desktop
	if (targetDesktop > vdDesktopCount || targetDesktop < 1) {
		OutputDebug [invalid] target: %targetDesktop% current: %vdCurrentDesktop%
		return
	}
	
	; No need to move a window that's already located on the targeted desktop; otherwise, prep the
	; interface for movement of the window
	if (vdCurrentDesktop == targetDesktop) {
		return
	} else {
		GetActiveMonitorWorkArea(whichMon, monALeft, monATop, monARight, monABottom)
		MouseGetPos currentMouseX, currentMouseY
		clickPosX := monALeft + awThumbnailX
		clickPosY := monATop + awThumbnailY
		Send #{Tab}
		Sleep % pauseAmt * 3
		Send {Click, %clickPosX%, %clickPosY%, right}
		Sleep % pauseAmt
		Send {Down 2}{Right}
		Sleep % pauseAmt
		Send {Click, %currentMouseX%, %currentMouseY%, 0}
	}
	
	iDesktop := 1
	while(iDesktop < targetDesktop) {
		if (iDesktop != vdCurrentDesktop) {
			SendInput {Down}
			Sleep % pauseAmt * .85
		}
		iDesktop++
	}
	Send {Enter}#{Tab}

	SetKeyDelay %prevKeyDelay%
}

;   ································································································
;     >>> §2.8: PrimeVirtualDesktops
;
;   Move between virtual desktops to make sure the registry is accurately populated.

PrimeVirtualDesktops() {
	delay := GetDelay("long")
	SendInput % "^#{Right}"
	Sleep %delay%
	SendInput % "^#{Left}"
	Sleep %delay%
	SendInput % "#{Tab}"
	Sleep % delay * 2
	SendInput % "{Esc}"
	Sleep % delay * 0.5
}

;   ································································································
;     >>> §2.9: SwitchDesktopByNumber

SwitchDesktopByNumber(targetDesktop) {
	global vdCurrentDesktop
	global vdDesktopCount
	global alreadySwitchingDesktop
	delay := GetDelay("shortest", 4)
	keyDelay := delay

	if (!alreadySwitchingDesktop) {
		alreadySwitchingDesktop := True
		oldKeyDelay := A_KeyDelay
		SetKeyDelay % keyDelay

		; Re-generate the list of desktops and where we fit in that. We do this because
		; the user may have switched desktops via some other means than the script.
		MapDesktopsFromRegistry()

		; Don't attempt to switch to an invalid desktop
		if (targetDesktop > vdDesktopCount || targetDesktop < 1) {
			OutputDebug [invalid] target: %targetDesktop% current: %vdCurrentDesktop%
			return
		}

		if (vdCurrentDesktop < targetDesktop) {
			; Go right until we reach the desktop we want
			iCounter := 0
			while(vdCurrentDesktop < targetDesktop) {
				SendInput ^#{Right}
				Sleep % delay * 2
				MapDesktopsFromRegistry()
				iCounter++
				if (iCounter > vdDesktopCount * 4) {
					Break
				}
			}
		} else if (vdCurrentDesktop > targetDesktop) {
			; Go left until we reach the desktop we want
			iCounter := 0
			while(vdCurrentDesktop > targetDesktop) {
				SendInput ^#{Left}
				Sleep % delay * 2
				MapDesktopsFromRegistry()
				iCounter++
				if (iCounter > vdDesktopCount * 4) {
					Break
				}
			}
		}
		SetKeyDelay % oldKeyDelay
		alreadySwitchingDesktop := False
	}
}
