; ==================================================================================================
; virtualDesktops.ahk
; ==================================================================================================
; * Script code adapted from https://www.computerhope.com/tips/tip224.htm, "Using AutoHotkey to 
;   switch Virtual Desktops in Windows 10." The article there indicates that the code is ultimately 
;   adapted from https://github.com/pmb6tz/windows-desktop-switcher.
; --------------------------------------------------------------------------------------------------
; TABLE OF CONTENTS:
;   §1: GLOBAL VARIABLES...................................................................... 13
;   §2: FUNCTIONS & SUBROUTINES............................................................... 19
;   >>> §2.1: MapDesktopsFromRegistry......................................................... 23
;   >>> §2.2: GetSessionId.................................................................... 81
;   >>> §2.3: SwitchDesktopByNumber........................................................... 97
;   >>> §2.4: MoveActiveWindowToVirtualDesktop............................................... 147
;   >>> §2.5: CreateVirtualDesktop........................................................... 196
;   >>> §2.6: DeleteVirtualDesktop........................................................... 209
; --------------------------------------------------------------------------------------------------

; --------------------------------------------------------------------------------------------------
;   §1: GLOBAL VARIABLES
; --------------------------------------------------------------------------------------------------
global DesktopCount = 2 ; Windows starts with 2 desktops at boot
global CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)

; --------------------------------------------------------------------------------------------------
;   §2: FUNCTIONS & SUBROUTINES
; --------------------------------------------------------------------------------------------------

; ··································································································
;   >>> §2.1: MapDesktopsFromRegistry
; * This function examines the registry to build an accurate list of the current virtual desktops 
;   and which one we're currently on.
; * Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersio
;   n\Explorer\SessionInfo\1\VirtualDesktops
; * List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Ex
;   plorer\VirtualDesktops
MapDesktopsFromRegistry() {
	global CurrentDesktop, DesktopCount

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
		DesktopCount := DesktopListLength / IdLength

	} else {
		DesktopCount := 1
	}

	; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry
	i := 0
	while (CurrentDesktopId and i < DesktopCount) {
		StartPos := (i * IdLength) + 1
		DesktopIter := SubStr(DesktopList, StartPos, IdLength)
		; OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.

		; Break out if we find a match in the list. If we didn't find anything, keep the
		; old guess and pray we're still correct :-D.
		if (DesktopIter = CurrentDesktopId) {
			CurrentDesktop := i + 1
			; OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
			break
		}

		i++
	}
}

; ··································································································
;   >>> §2.2: GetSessionId
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

; ··································································································
;   >>> §2.3: SwitchDesktopByNumber
SwitchDesktopByNumber(targetDesktop) {
	global CurrentDesktop
	global DesktopCount
	global alreadySwitchingDesktop
	keyDelay := 100

	if (!alreadySwitchingDesktop) {
		alreadySwitchingDesktop := True

		; Re-generate the list of desktops and where we fit in that. We do this because
		; the user may have switched desktops via some other means than the script.
		MapDesktopsFromRegistry()

		; Don't attempt to switch to an invalid desktop
		if (targetDesktop > DesktopCount || targetDesktop < 1) {
			OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
			return
		}

		if (CurrentDesktop < targetDesktop) {
			; Go right until we reach the desktop we want
			iCounter := 0
			while(CurrentDesktop < targetDesktop) {
				SendInput, ^#{Right}
				Sleep, %keyDelay%
				MapDesktopsFromRegistry()
				iCounter++
				if (iCounter > DesktopCount * 2) {
					Break
				}
			}
		} else if (CurrentDesktop > targetDesktop) {
			; Go left until we reach the desktop we want
			iCounter := 0
			while(CurrentDesktop > targetDesktop) {
				SendInput, ^#{Left}
				Sleep, %keyDelay%
				MapDesktopsFromRegistry()
				iCounter++
				if (iCounter > DesktopCount * 2) {
					Break
				}
			}
		}
		alreadySwitchingDesktop := False
	}
}

; ··································································································
;   >>> §2.4: MoveActiveWindowToVirtualDesktop
MoveActiveWindowToVirtualDesktop(targetDesktop) {
	global CurrentDesktop
	global DesktopCount
	prevKeyDelay := A_KeyDelay

	; Re-generate the list of desktops and where we fit in that. We do this because
	; the user may have switched desktops via some other means than the script.
	MapDesktopsFromRegistry()
	
	; Don't attempt to move to an invalid desktop
	if (targetDesktop > DesktopCount || targetDesktop < 1) {
		OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
		return
	}
	
	; No need to move a window that's already located on the targeted desktop; otherwise, prep the
	; interface for movement of the window
	if (CurrentDesktop == targetDesktop) {
		return
	} else {
		if (IsWindowOnLeftDualMonitor()) {
			SendInput, #{Tab}
			Sleep, 400
			SendInput, {Tab 2}{AppsKey}{m}
		} else {
			SendInput, #{Tab}
			Sleep, 400
			SendInput, {AppsKey}{m}
		}
	}

	SetKeyDelay, 100
	
	iDesktop := 1
	while(iDesktop < targetDesktop) {
		if (iDesktop != CurrentDesktop) {
			Send {Down}
		}
		iDesktop++
	}
	Send {Enter}
	Sleep, 120
	SendInput, #{Tab}

	SetKeyDelay, prevKeyDelay
}

; ··································································································
;   >>> §2.5: CreateVirtualDesktop
CreateVirtualDesktop() {
	global CurrentDesktop, DesktopCount
	prevKeyDelay := A_KeyDelay

	SetKeyDelay, 75
	Send, #^d
	MapDesktopsFromRegistry()
	SetKeyDelay, prevKeyDelay
	OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}

; ··································································································
;   >>> §2.6: DeleteVirtualDesktop
DeleteVirtualDesktop() {
	global CurrentDesktop, DesktopCount
	prevKeyDelay := A_KeyDelay

	SetKeyDelay, 75
	Send, #^{F4}
	MapDesktopsFromRegistry()
	SetKeyDelay, prevKeyDelay
	OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
