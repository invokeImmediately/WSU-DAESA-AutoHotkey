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
;     >>> §2.2: CreateVirtualDesktop..........................................................143
;     >>> §2.3: DeleteVirtualDesktop..........................................................157
;     >>> §2.4: GetCurrentVirtualDesktop......................................................171
;     >>> §2.5: GetSessionId..................................................................184
;       →→→ §2.5.1: @getSessionId.............................................................204
;     >>> §2.6: MapDesktopsFromRegistry.......................................................215
;     >>> §2.7: MoveActiveWindowToVirtualDesktop..............................................277
;     >>> §2.8: PrimeVirtualDesktops..........................................................340
;     >>> §2.9: SwitchDesktopByNumber.........................................................359
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

:*:@closeOpenWindowsOnActiveVd::
	AppendAhkCmd(A_ThisLabel)
	CloseOpenWindowsOnVD()	
Return

CloseOpenWindowsOnVD() { ; - Alias = cowvd
	global g_osDesktopHwnd
	delay := GetDelay("short")

	cowvd_CheckOsDesktopHwnd()
	windowsAlreadyClosed := cowvd_GetStarted(delay)
	if (!windowsAlreadyClosed) {
		vdHWnds := cowvd_LogOpenWindows(delay)
		cowvd_ClosedLoggedWindows(vdHWnds, delay)
	}
}

cowvd_CheckOsDesktopHwnd(overwrite := False) {
	global g_osDesktopWinTitle
	global g_osDesktopHwnd

	if (!g_osDesktopHwnd || overwrite) {
		WinGet g_osDesktopHwnd, ID, % g_osDesktopWinTitle
	}
}

cowvd_ClosedLoggedWindows(vdHWnds, delay) {
	For index, value in vdHWnds
	{
		; Alternative approach: WinClose % "ahk_id " . index,, 1
		PostMessage, 0x112, 0xF060,,, % "ahk_id " . index
		Sleep % delay * 10
	}
	cowvd_VerifyClosingOfWindows(vdHWnds, delay)
}

cowvd_GetStarted(delay) {
	windowsAlreadyClosed := false
	SendInput !{Tab}
	Sleep % delay * 2
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

cowvd_LogOpenWindows(delay) {
	vdHWnds := {}
	keepSearching := true

	if (cowvd_IsOsActive()) {
		cowvd_SwitchToNextWindow(delay)
	}
	wCount := 0
	while keepSearching && !cowvd_IsOsActive() {
		WinGet aHwnd, ID, A
		if (!vdHWnds[aHwnd]) {
			vdHWnds[aHwnd] := true
			wCount++
			cowvd_SwitchToNextWindow(delay, wCount)
		} else {
			keepSearching := false
		}
	}
	return vdHWnds
}

cowvd_RetryClosingOfWindows(aVdHWnds, delay) {
	Loop % aVdHwnds.Length()
	{
		PostMessage, 0x112, 0xF060,,, % "ahk_id " . aVdHwnds[A_Index]
		Sleep % delay * 10
	}
}

cowvd_SwitchToNextWindow(delay, wCount := 1) {
	oldKeyDelay := A_KeyDelay
	SetKeyDelay % delay
	Send % "{Alt Down}{Tab " . wCount . "}{Alt Up}"
	Sleep % delay
	SetKeyDelay % oldKeyDelay
}

cowvd_VerifyClosingOfWindows(vdHWnds, delay) {
	aVdHwnds := Object()
	For index, value in vdHWnds
	{
		if (!WinExist("ahk_id " . index)) {
			aVdHwnds.Push(index)
		}
		Sleep % delay * 2
	}
	cowvd_RetryClosingOfWindows(aVdHwnds, delay)
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
	DisplaySplashText("Priming the registry with information about virtual desktops in use.")
	Sleep %delay%
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
