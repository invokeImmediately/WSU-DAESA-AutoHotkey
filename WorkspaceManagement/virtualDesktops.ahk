; ==================================================================================================
; ▐   ▌▀█▀ █▀▀▄ ▐▀█▀▌█  █ ▄▀▀▄ █    █▀▀▄ █▀▀▀ ▄▀▀▀ █ ▄▀ ▐▀█▀▌▄▀▀▄ █▀▀▄ ▄▀▀▀   ▄▀▀▄ █  █ █ ▄▀ 
;  █ █  █  █▄▄▀   █  █  █ █▄▄█ █  ▄ █  █ █▀▀  ▀▀▀█ █▀▄    █  █  █ █▄▄▀ ▀▀▀█   █▄▄█ █▀▀█ █▀▄  
;   █  ▀▀▀ ▀  ▀▄  █   ▀▀  █  ▀ ▀▀▀  ▀▀▀  ▀▀▀▀ ▀▀▀  ▀  ▀▄  █   ▀▀  █    ▀▀▀  ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Functions for automating the management of virtual desktops in Windows 10.
;
; A key component of the code present in this file, namely the MapDesktopsFromRegistry function,
;   was adapted from https://www.computerhope.com/tips/tip224.htm, "Using AutoHotkey to switch
;   Virtual Desktops in Windows 10." The article there indicates that the code is ultimately
;   adapted from https://github.com/pmb6tz/windows-desktop-switcher.
;
; @version 1.0.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/master…→
;   ←…/WorkspaceManagement/virtualDesktops.ahk
; @license MIT Copyright (c) 2021 Daniel C. Rieck.
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;     and associated documentation files (the “Software”), to deal in the Software without
;     restriction, including without limitation the rights to use, copy, modify, merge, publish,
;     distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;     Software is furnished to do so, subject to the following conditions:
;   The above copyright notice and this permission notice shall be included in all copies or
;     substantial portions of the Software.
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;     BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;     DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================
; TABLE OF CONTENTS:
; -----------------
;   §1: GLOBAL VARIABLES.......................................................................51
;   §2: FUNCTIONS & SUBROUTINES................................................................58
;     >>> §2.1: CreateVirtualDesktop...........................................................62
;     >>> §2.2: DeleteVirtualDesktop...........................................................76
;     >>> §2.3: GetCurrentVirtualDesktop.......................................................90
;     >>> §2.4: GetSessionId..................................................................103
;       →→→ §2.4.1: @getSessionId.............................................................123
;     >>> §2.5: MapDesktopsFromRegistry.......................................................134
;     >>> §2.6: MoveActiveWindowToVirtualDesktop..............................................196
;     >>> §2.7: PrimeVirtualDesktops..........................................................266
;     >>> §2.8: SwitchDesktopByNumber.........................................................286
;   §3: HOTSTRINGS............................................................................344
;     >>> §3.1: CloseOpenWindowsOnVD..........................................................348
;     >>> §3.2: class VdWindowCloser..........................................................357
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: GLOBAL VARIABLES
; --------------------------------------------------------------------------------------------------

global vdDesktopCount = 2 ; Windows starts with 2 desktops at boot
global vdCurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)

; --------------------------------------------------------------------------------------------------
;   §2: FUNCTIONS & SUBROUTINES
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §2.1: CreateVirtualDesktop

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
;     >>> §2.2: DeleteVirtualDesktop

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
;     >>> §2.3: GetCurrentVirtualDesktop

; * Couples a call to MapDesktopsFromRegistry to the value of global variable vdCurrentDesktop.
; * Preferable to relying on the global variable vdCurrentDesktop, which requires a separate call to 
;   MapDesktopsFromRegistry to ensure accuracy.
GetCurrentVirtualDesktop() {
	global vdCurrentDesktop

	MapDesktopsFromRegistry()
	return vdCurrentDesktop
}

;   ································································································
;     >>> §2.4: GetSessionId
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
;       →→→ §2.4.1: @getSessionId
;
;	Use the DisplaySplashText function to show the current Session ID to the user.

:*?:@getSessionId::
	SessionId := GetSessionId()
	msg := "Current session id via GetSessionId() = " . SessionId
	DisplaySplashText(msg)
Return

;   ································································································
;     >>> §2.5: MapDesktopsFromRegistry
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
;     >>> §2.6: MoveActiveWindowToVirtualDesktop

MoveActiveWindowToVirtualDesktop(targetDesktop) {
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DECLARATIONS
	global vdCurrentDesktop
	global vdDesktopCount
	global execDelayer
	global g_dpiScalar

	; Timing variables
	prevKeyDelay := A_KeyDelay
	keyDelay := 120
	pauseAmt := 200
	oldCoordMode := undefined

	; UI interaction variables
	awThumbnailX := 95 * g_dpiScalar ; Active Window Thumbnail: horizontal click position
	awThumbnailY := 220 * g_dpiScalar ; Active Window Thumbnail: vertical click position

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
		oldCoordMode := ChangeMouseCoordMode(Screen)
		MouseGetPos currentMouseX, currentMouseY
		GetActiveMonitorWorkArea(whichMon, monALeft, monATop, monARight, monABottom)
		clickPosX := monALeft + awThumbnailX
		clickPosY := monATop + awThumbnailY
		Send #{Tab}
		execDelayer.Wait( "s", 12 )
		Send {Click, %clickPosX%, %clickPosY%, right}
		execDelayer.Wait( "s", 3 )
		SendInput {Down 2}{Right}
		execDelayer.Wait( "s", 5 )
		SendInput {Left}{Right}
		execDelayer.Wait( "s", 3 )
	}
	
	iDesktop := 1
	while(iDesktop < targetDesktop) {
		if (iDesktop != vdCurrentDesktop) {
			SendInput {Down}
			execDelayer.Wait( "s" )
		}
		iDesktop++
	}
	Send {Enter}#{Tab}
	execDelayer.Wait( "s", 2 )
	MouseMove %currentMouseX%, %currentMouseY%
	RestoreMouseCoordMode(oldCoordMode)
	SetKeyDelay %prevKeyDelay%
}

;   ································································································
;     >>> §2.7: PrimeVirtualDesktops
;
;   Move between virtual desktops to make sure the registry is accurately populated.

PrimeVirtualDesktops() {
	global execDelayer
	
	DisplaySplashText("Priming the registry with information about virtual desktops in use.", 3000)
	execDelayer.Wait( "l" )
	SendInput % "^#{Right}"
	execDelayer.Wait( "l" )
	SendInput % "^#{Left}"
	execDelayer.Wait( "l" )
	SendInput % "#{Tab}"
	execDelayer.Wait( "l", 3 )
	SendInput % "{Esc}"
	execDelayer.Wait( "l", 3 )
}

;   ································································································
;     >>> §2.8: SwitchDesktopByNumber

SwitchDesktopByNumber(targetDesktop) {
	global vdCurrentDesktop
	global vdDesktopCount
	global alreadySwitchingDesktop
	global execDelayer
	delay := execDelayer.InterpretDelayString( "s" )
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
				execDelayer.Wait( delay, 2 )
				MapDesktopsFromRegistry()
				execDelayer.Wait( delay )
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
				execDelayer.Wait( delay, 2 )
				MapDesktopsFromRegistry()
				execDelayer.Wait( delay )
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

; --------------------------------------------------------------------------------------------------
;   §3: HOTSTRINGS
; --------------------------------------------------------------------------------------------------

;   ································································································
;     >>> §3.1: @closeOpenWindowsOnActiveVd

:*?:@closeOpenWindowsOnActiveVd::
	AppendAhkCmd(A_ThisLabel)
	windowCloser := new VdWindowCloser()
	windowCloser.CloseOpenWindowsOnVd()
Return

;   ································································································
;     >>> §3.2: class VdWindowCloser

class VdWindowCloser {
	__New() {
	}

	CheckOsDesktopHwnd( overwrite := False ) {
		global g_osDesktopHwnd
		global g_osDesktopWinTitle
		if ( !g_osDesktopHwnd || overwrite ) {
			WinGet g_osDesktopHwnd, ID, % g_osDesktopWinTitle
		}
	}

	CloseLoggedWindows( vdHWnds, delay ) {
		global execDelayer
		if ( vdHWnds.Count() == 0 ) {
			return
		}
		execDelayer.SetUpNewProcess( vdHWnds.Count(), A_ThisFunc )
		For index, value in vdHWnds
		{
			; Alternative approach: WinClose % "ahk_id " . index,, 1
			PostMessage, 0x112, 0xF060,,, % "ahk_id " . index
			execDelayer.Wait( delay * 10 )
		}
		execDelayer.CompleteCurrentProcess()
	}

	CloseOpenWindowsOnVd() {
		global execDelayer
		delay := execDelayer.InterpretDelayString( "short" ) * 1.5
		DisplaySplashText( "Now closing the open windows on the active virtual desktop." )
		execDelayer.Wait( "l" )
		this.CheckOsDesktopHwnd()
		windowsAlreadyClosed := this.GetStarted( delay )
		if ( !windowsAlreadyClosed ) {
			vdHWnds := this.LogOpenWindowsByList( delay )
			this.CloseLoggedWindows( vdHWnds, delay )
			vdHWnds := this.LogOpenWindowsByAltTab( delay )
			this.CloseLoggedWindows(vdHWnds, delay)
		}
		DisplaySplashText( "The process for closing the open windows on the active virtual desktop has"
			. " just finished." )
	}

	GetStarted( delay ) {
		global execDelayer
		windowsAlreadyClosed := false
		SendInput !{Tab}
		execDelayer.Wait( delay * 2 )
		if ( this.IsOsActive() ) {
			SendInput !{Tab}
			execDelayer.Wait( delay * 2 )
			if ( this.IsOsActive() ) {
				windowsAlreadyClosed := true
			}
		}
		return windowsAlreadyClosed
	}

	IsOsActive() {
		global g_osDesktopHwnd
		WinGet aHwnd, ID, A
		return aHwnd == g_osDesktopHwnd
	}

	LogOpenWindowsByAltTab( delay ) {
		vdHWnds := {}
		keepSearching := true
		if ( this.IsOsActive() ) {
			this.SwitchToNextWindow( delay )
		}
		wCount := 0
		while( keepSearching && !this.IsOsActive() ) {
			WinGet aHwnd, ID, A
			if ( !vdHWnds[ aHwnd ] ) {
				vdHWnds[ aHwnd ] := true
				wCount++
				this.SwitchToNextWindow( delay, wCount )
			} else {
				keepSearching := false
			}
		}
		return vdHWnds
	}

	LogOpenWindowsByList( delay ) {
		vdHWnds := {}
		keepSearching := true
		WinGet, hwndList, List
		windowsList := ""
		Loop %hwndList% {
			curHWnd := hwndList%A_Index%
			WinGet, procName, ProcessName, % "ahk_id " . curHWnd
			if ( !vdHWnds[ curHWnd ] && procName != "" && procName != "explorer.exe"
					&& procName != "AutoHotkey.exe" && procName != "Teams.exe" && procName != "Zoom.exe" ) {
				vdHWnds[ curHWnd ] := true
				windowsList .= curHWnd . ", " . procName
				if ( A_Index > 1 && A_Index < hwndList ) {
					windowsList .= " | "
				}
			}
		}
		windowsList := SubStr( windowsList, 1, StrLen( windowsList ) - 3 )
		winsToClose := new GuiMsgBox( windowsList, "vdWinsToClose", "Windows to Be Closed" )
		winsToClose.ShowGui()
		return vdHWnds
	}

	SwitchToNextWindow( delay, wCount := 1 ) {
		global execDelayer
		oldKeyDelay := A_KeyDelay
		SetKeyDelay % delay
		Send % "{Alt Down}{Tab " . wCount . "}{Alt Up}"
		execDelayer.Wait( delay )
		SetKeyDelay % oldKeyDelay
	}
}
