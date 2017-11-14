; Script code adapted from https://www.computerhope.com/tips/tip224.htm, "Using AutoHotkey to switch
; Virtual Desktops in Windows 10." The article there indicates that the code is ultimately adapted
; from https://github.com/pmb6tz/windows-desktop-switcher.

; Globals
global DesktopCount = 2 ; Windows starts with 2 desktops at boot
global CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)
;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
	global CurrentDesktop, DesktopCount

	; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this
	; couldn't change in a later Windows release so we check.
	IdLength := 32
	SessionId := getSessionId()
	if (SessionId) {
		RegRead, CurrentDesktopId
			, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops
			, CurrentVirtualDesktop
		if (CurrentDesktopId) {
			IdLength := StrLen(CurrentDesktopId)
		}
	}

	; Get a list of the UUIDs for all virtual desktops on the system
	RegRead, DesktopList
		, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
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
		OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.

		; Break out if we find a match in the list. If we didn't find anything, keep the
		; old guess and pray we're still correct :-D.
		if (DesktopIter = CurrentDesktopId) {
			CurrentDesktop := i + 1
			OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
			break
		}

		i++
	}
}

getSessionId()
{
	ProcessId := DllCall("GetCurrentProcessId", "UInt")
	if ErrorLevel {
		OutputDebug, Error getting current process id: %ErrorLevel%
		return
	}
	OutputDebug, Current Process Id: %ProcessId%
		DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
		if ErrorLevel {
		OutputDebug, Error getting session id: %ErrorLevel%
		return
	}
	OutputDebug, Current Session Id: %SessionId%
	return SessionId
}

switchDesktopByNumber(targetDesktop)
{
	global CurrentDesktop
	global DesktopCount
	prevKeyDelay := A_KeyDelay

	; Re-generate the list of desktops and where we fit in that. We do this because
	; the user may have switched desktops via some other means than the script.
	mapDesktopsFromRegistry()

	; Don't attempt to switch to an invalid desktop
	if (targetDesktop > DesktopCount || targetDesktop < 1) {
		OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
		return
	}

	SetKeyDelay, 75

	; Go right until we reach the desktop we want
	while(CurrentDesktop < targetDesktop) {
		Send ^#{Right}
		CurrentDesktop++
		OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
	}

	; Go left until we reach the desktop we want
	while(CurrentDesktop > targetDesktop) {
		Send ^#{Left}
		CurrentDesktop--
		OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
	}

	SetKeyDelay, prevKeyDelay
}

moveActiveWindowToVirtualDesktop(targetDesktop) {
	global CurrentDesktop
	global DesktopCount
	prevKeyDelay := A_KeyDelay

	; Re-generate the list of desktops and where we fit in that. We do this because
	; the user may have switched desktops via some other means than the script.
	mapDesktopsFromRegistry()
	
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

	SetKeyDelay, 75
	
	iDesktop := 1
	while(iDesktop < targetDesktop) {
		if (iDesktop != CurrentDesktop) {
			Send {Down}
		}
		iDesktop++
	}
	Send {Enter}
	Send #{Tab}

	SetKeyDelay, prevKeyDelay
}

createVirtualDesktop() {
	global CurrentDesktop, DesktopCount
	prevKeyDelay := A_KeyDelay

	SetKeyDelay, 75
	Send, #^d
	DesktopCount++
	CurrentDesktop = %DesktopCount%
	SetKeyDelay, prevKeyDelay
	OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}

deleteVirtualDesktop() {
	global CurrentDesktop, DesktopCount
	prevKeyDelay := A_KeyDelay

	SetKeyDelay, 75
	Send, #^{F4}
	DesktopCount--
	CurrentDesktop--
	SetKeyDelay, prevKeyDelay
	OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}

; User config!
; This section binds the key combo to the switch/create/delete actions
;LWin & 1::switchDesktopByNumber(1)
;LWin & 2::switchDesktopByNumber(2)
;LWin & 3::switchDesktopByNumber(3)
;LWin & 4::switchDesktopByNumber(4)
;LWin & 5::switchDesktopByNumber(5)
;LWin & 6::switchDesktopByNumber(6)
;LWin & 7::switchDesktopByNumber(7)
;LWin & 8::switchDesktopByNumber(8)
;LWin & 9::switchDesktopByNumber(9)
;CapsLock & 1::switchDesktopByNumber(1)
;CapsLock & 2::switchDesktopByNumber(2)
;CapsLock & 3::switchDesktopByNumber(3)
;CapsLock & 4::switchDesktopByNumber(4)
;CapsLock & 5::switchDesktopByNumber(5)
;CapsLock & 6::switchDesktopByNumber(6)
;CapsLock & 7::switchDesktopByNumber(7)
;CapsLock & 8::switchDesktopByNumber(8)
;CapsLock & 9::switchDesktopByNumber(9)
;CapsLock & n::switchDesktopByNumber(CurrentDesktop + 1)
;CapsLock & p::switchDesktopByNumber(CurrentDesktop - 1)
;CapsLock & s::switchDesktopByNumber(CurrentDesktop + 1)
;CapsLock & a::switchDesktopByNumber(CurrentDesktop - 1)
;CapsLock & c::createVirtualDesktop()
;CapsLock & d::deleteVirtualDesktop()
; Alternate keys for this config. Adding these because DragonFly (python) doesn't send CapsLock correctly.
;^!1::switchDesktopByNumber(1)
;^!2::switchDesktopByNumber(2)
;^!3::switchDesktopByNumber(3)
;^!4::switchDesktopByNumber(4)
;^!5::switchDesktopByNumber(5)
;^!6::switchDesktopByNumber(6)
;^!7::switchDesktopByNumber(7)
;^!8::switchDesktopByNumber(8)
;^!9::switchDesktopByNumber(9)
;^!n::switchDesktopByNumber(CurrentDesktop + 1)
;^!p::switchDesktopByNumber(CurrentDesktop - 1)
;^!s::switchDesktopByNumber(CurrentDesktop + 1)
;^!a::switchDesktopByNumber(CurrentDesktop - 1)
;^!c::createVirtualDesktop()
;^!d::deleteVirtualDesktop()
