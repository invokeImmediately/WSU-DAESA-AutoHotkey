; ============================================================================================================
; LEGEND
; ! = ALT     + = SHIFT     ^ = CONTROL     # = WIN
; (see https://autohotkey.com/docs/commands/Send.htm for more info)
; ============================================================================================================

OpenChromeTab:
    WinGet, thisProcess, ProcessName, A
    if (thisProcess = "chrome.exe") {
        SendInput ^n
        Sleep 250
        isReady := false
        while !isReady
        {
            IfWinExist, % "New Tab"
            {
                isReady := true
                Sleep, 500
            }
            else
            {
                Sleep, 250
            }
        }
    }
return

IsWindowOnLeftDualMonitor() {
    WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
    
    if (thisWinX < -8) {
        return true
    }
    else {
        return false
    }
}

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F10::WinSet, Alwaysontop, Toggle, A

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F1::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F2::
    SendInput, #{Tab}
    Sleep, 330
    SendInput, {Tab}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F3::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F4::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!F5::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Right}{Enter}
Return

^!F6::
    SendInput #{Tab}
    Sleep 330
    SendInput {Tab}{Right}{Right}{Right}{Right}{Right}{Enter}
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F9::
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 100
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , 100, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F8::
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 100
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , 0, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F7::
    SysGet, Mon1, MonitorWorkArea, 1
    M1Width := Mon1Right - Mon1Left - 100
    M1X := -M1Width
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , %M1X%, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^F6::
    SysGet, Mon1, MonitorWorkArea, 1
    M1X := -(Mon1Right - Mon1Left)
    M1Width := Mon1Right - Mon1Left - 100
    M1Height := Mon1Bottom - Mon1Top
    WinRestore, A
    WinMove, A, , %M1X%, 0, %M1Width%, %M1Height%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Left::
    if (IsWindowOnLeftDualMonitor()) {
        SysGet, Mon2, MonitorWorkArea, 2
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        WinMove, A, , %Mon2Left%, 0, %thisWinW%, %thisWinH%        
    }
    else {
        SysGet, Mon1, MonitorWorkArea, 1
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        WinMove, A, , %Mon1Left%, 0, %thisWinW%, %thisWinH%
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!#Right::
    if (IsWindowOnLeftDualMonitor()) {
        SysGet, Mon2, MonitorWorkArea, 2
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinX := Mon2Right - thisWinW
        WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%        
    }
    else {
        SysGet, Mon1, MonitorWorkArea, 1
        WinGetPos, thisWinX, thisWinY, thisWinW, thisWinH, A
        newWinX := Mon1Right - thisWinW
        WinMove, A, , %newWinX%, 0, %thisWinW%, %thisWinH%
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!1::
    hotstrStartTime := A_TickCount
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    hotstrEndTime := A_TickCount
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!2::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!3::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down 2}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down 2}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!4::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down 3}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down 3}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!5::
    if (IsWindowOnLeftDualMonitor()) {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {Tab 2}{AppsKey}{m}{Down 4}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
    else {
        SendInput, #{Tab}
        Sleep, 330
        SendInput, {AppsKey}{m}{Down 4}{Enter}
        Sleep, 100
        SendInput, #{Tab}
    }
return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---

^!m::
    WinGetPos, thisX, thisY, thisW, thisH, A
    thisX := -thisX - thisW
    WinMove, A, , %thisX%, %thisY%, %thisW%, %thisH%
Return

; ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---


/*
 * 	The options object below defines the hotkeys for the window manager. 
 *  
 *	Usage:
 *  An Empty Object:
 * 		Pressing numbers 1 through 0 while in the multi tasking view (the view that comes up after pressing win + tab) will go to the desktop number that you pressed
 *
 *  "goToDesktopModKey" : modKey (optional)
 * 		the key or modifier for going to a desktop. 
 *		Example: "#" == windows key + number to go to another desktop
 *
 * 	"moveWindowModKey" : ModKey (optional)
 *		The key or modifier for moving the active window to a desktop
 *		Example: "+#" == shift + windows key + number to move the active window to another desktop
 *
 *	"postChangeDesktop" : function name or function object (optional)
 *		A function that will be called after moving desktops
 *
 *	"postMoveWindow": function name or function object (optional)
 *		A function that will be called after moving the active window to a desktop
 * 	
 */
; options := {"goToDesktopModKey" : "Capslock" ;capslock + number number jumps to desktop
; 	,"moveWindowModKey" : "+#" ;windows key + shift + number moves the active window to a desktop
; 	,"postChangeDesktop" : Func("afterDesktopChangeTurnOffCapslock").bind()} ;after moving the active window turn off capslock
;  
; globalDesktopManager := new JPGIncDesktopManagerClass(options)
; return
;  
;  
; afterDesktopChangeTurnOffCapslock()
; {
; 	SetCapsLockState , Off
; 	return
; }
;  
; #c::ExitApp
;  
; JPGIncDesktopManagerCallback(desktopManager, functionName, keyPressed)
; {
; 	if(keyPressed == 0) 
; 	{
; 		keyPressed := 10
; 	}
; 	desktopManager[functionName](keyPressed)
; 	return
; 	desktopManager[functionName](keyPressed)
; 	return
; }
;  
; class JPGIncDesktopManagerClass
; {
; 	notAnAutohotkeyModKeyRegex := "[^#!^+<>*~$]"
; 	moveWinMod := "moveWindowModKey"
; 	changeVDMod := "goToDesktopModKey"
;  
; 	__new(options) 
; 	{
; 		this.options := options
; 		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
; 		this.monitorMapper := new MonitorMapperClass()
;  
; 		this.mapHotkeys()
; 		return this
; 	}
;  
; 	mapHotkeys()
; 	{
; 		this.fixModKeysForHotkeySyntax()
; 		loop, 10
; 		{
; 			moveCallback := Func("JPGIncDesktopManagerCallback").Bind(this, "moveActiveWindowToDesktop", A_Index - 1)
; 			changeCallback := Func("JPGIncDesktopManagerCallback").Bind(this, "goToDesktop", A_Index -1)
; 			Hotkey, If
; 			if(this.options[this.moveWinMod]) 
; 			{
; 				Hotkey, % this.options[this.moveWinMod] (A_index -1), % moveCallback
; 			}
; 			if(this.options[this.changeVDMod]) 
; 			{
; 				Hotkey, % this.options[this.changeVDMod] (A_index -1), % changeCallback
; 			}
;  
; 			Hotkey, IfWinActive, ahk_class MultitaskingViewFrame
; 			Hotkey, % "*" (A_index -1), % changeCallback ;if the user has already pressed win + tab then numbers quicly change desktops
; 		}
; 		return this
; 	}
;  
; 	/*
; 	 * If the modifier key used is only a modifier symbol then we don't need to do anything (https://autohotkey.com/docs/Hotkeys.htm#Symbols)
; 	 * but if it contains any other characters then it means that the hotkey is a combination hotkey then we need to add " & " 
; 	 */
; 	fixModKeysForHotkeySyntax() 
; 	{
; 		if(RegExMatch(this.options[this.moveWinMod], this.notAnAutohotkeyModKeyRegex)) {
; 			this.options[this.moveWinMod] .= " & "
; 		}
;  
; 		if(RegExMatch(this.options[this.changeVDMod], this.notAnAutohotkeyModKeyRegex)) {
; 			this.options[this.changeVDMod] .= " & "
; 		}
; 		return this
; 	}
; 	/*
; 	 *	swap to the given virtual desktop number
; 	 */
; 	goToDesktop(newDesktopNumber) 
; 	{
; 		debugger("in go to desktop changing to " newDesktopNumber)
; 		this._makeDesktopsIfRequired(newDesktopNumber)
; 			._goToDesktop(newDesktopNumber)
; 			.closeMultitaskingViewFrame()
; 			.doPostMoveDesktop()
; 		return this
; 	}
;  
; 	_makeDesktopsIfRequired(minimumNumberOfDesktops)
; 	{
; 		currentNumberOfDesktops := this.desktopMapper.getNumberOfDesktops()
; 		loop, % minimumNumberOfDesktops - currentNumberOfDesktops
; 		{
; 			this._send("#^d")
; 		}
;  
; 		return this
; 	}
;  
; 	/*
; 	 * If we send the keystrokes too quickly you sometimes get a flickering of the screen
; 	 */
; 	_send(toSend)
; 	{
; 		oldDelay := A_KeyDelay
; 		SetKeyDelay, 30
;  
; 		send, % toSend
;  
; 		SetKeyDelay, % oldDelay
; 		return this
; 	}
;  
; 	_goToDesktop(newDesktopNumber)
; 	{
; 		currentDesktop := this.desktopMapper.getDesktopNumber()
; 		direction := currentDesktop - newDesktopNumber
; 		distance := Abs(direction)
; 		debugger("distance to move is " distance "`ndirectin" direction)
; 		if(direction < 0)
; 		{
; 			debugger("Sending right! " distance "times")
; 			this._send("^#{right " distance "}")
; 		} else
; 		{
; 			this._send("^#{left " distance "}")
; 		}
; 		return this
; 	}
;  
; 	closeMultitaskingViewFrame()
; 	{
; 		IfWinActive, ahk_class MultitaskingViewFrame
; 		{
; 			this._send("#{tab}")
; 		}
; 		return this
; 	}
;  
; 	openMultitaskingViewFrame()
; 	{
; 		IfWinNotActive, ahk_class MultitaskingViewFrame
; 		{
; 			this._send("#{tab}")
; 			WinWaitActive, ahk_class MultitaskingViewFrame
; 		}
; 		return this
; 	}
;  
; 	doPostMoveDesktop() 
; 	{
; 		this._callFunction(this.options.postChangeDesktop)
; 		return this
; 	}
;  
; 	doPostMoveWindow() 
; 	{
; 		this._callFunction(this.options.postMoveWindow)
; 		return this
; 	}
;  
; 	_callFunction(possibleFunction)
; 	{
; 		if(IsFunc(possibleFunction)) 
; 		{
; 			%possibleFunction%()
; 		} else if(IsObject(possibleFunction))
; 		{
; 			possibleFunction.Call()
; 		}
; 		return this
; 	}
;  
; 	moveActiveWindowToDesktop(targetDesktop, follow := false)
; 	{
; 		currentDesktop := this.desktopMapper.getDesktopNumber()
; 		if(currentDesktop == targetDesktop) 
; 		{
; 			return this
; 		}
; 		numberOfTabsNeededToSelectActiveMonitor := this.monitorMapper.getRequiredTabCount(WinActive("A"))
; 		numberOfDownsNeededToSelectDesktop := this.getNumberOfDownsNeededToSelectDesktop(targetDesktop, currentDesktop)
;  
; 		this.openMultitaskingViewFrame()
; 			._send("{tab " numberOfTabsNeededToSelectActiveMonitor "}")
; 			._send("{Appskey}m{Down " numberOfDownsNeededToSelectDesktop "}{Enter}")
; 			.closeMultitaskingViewFrame()
; 			.doPostMoveWindow()
;  
; 		return	this
; 	}
;  
; 	getNumberOfDownsNeededToSelectDesktop(targetDesktop, currentDesktop)
; 	{
; 		; This part figures out how many times we need to push down within the context menu to get the desktop we want.	
; 		if (targetDesktop > currentDesktop)
; 		{
; 			targetDesktop -= 2
; 		}
; 		else
; 		{
; 			targetdesktop--
; 		}
; 		return targetDesktop
; 	}
;  
; 	getIndexFromArray(searchFor, array) 
; 	{
; 		loop, % array.MaxIndex()
; 		{
; 			if(array[A_index] == searchFor) 
; 			{
; 				return A_index
; 			}
; 		}
; 		return false
; 	}
; }
; class DesktopMapperClass
; {	
; 	desktopIds := []
;  
; 	__new(virtualDesktopManager)
; 	{
; 		this._setupGui()
; 		this.virtualDesktopManager := virtualDesktopManager
; 		return this
; 	}
;  
; 	/*
; 	 * Populates the desktopIds array with the current virtual deskops according to the registry key
; 	 */
; 	mapVirtualDesktops() 
; 	{
; 		regIdLength := 32
; 		RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
;  
; 		this.desktopIds := []
; 		while, true
; 		{
; 			desktopId := SubStr(DesktopList, ((A_index-1) * regIdLength) + 1, regIdLength)
; 			if(desktopId) 
; 			{
; 				this.desktopIds.Insert(this._idFromReg(desktopId))
; 			} else
; 			{
; 				break
; 			}
; 		}
; 		debugger("there are " this.desktopIds.MaxIndex() " things")
; 		return this
; 	}
;  
; 	/*
; 	 * Gets the desktop id of the current desktop
; 	 */
; 	getCurrentDesktopId()
; 	{
; 		hwnd := this.hwnd
; 		Gui %hwnd%:show, NA ;show but don't activate
; 		winwait, % "Ahk_id " hwnd
;  
; 		guid := this.virtualDesktopManager.getDesktopGuid(hwnd)
;  
; 		Gui %hwnd%:hide 
; 		;if you don't wait until it closes then the desktop the gui is on can get focus
; 		WinWaitClose,  % "Ahk_id " hwnd
;  
; 		return this._idFromGuid(guid)
; 	}
;  
; 	getNumberOfDesktops() 
; 	{
; 		this.mapVirtualDesktops()
; 		return this.desktopIds.maxIndex()
; 	}
;  
; 	/*
; 	 * returns the number of the current desktop
; 	 */
; 	getDesktopNumber()
; 	{
; 		this.mapVirtualDesktops()
; 		currentDesktop := this.getCurrentDesktopId()
;  
; 		return this._indexOfId(currentDesktop)
; 	}
;  
; 	/*
; 	 * takes an ID from the registry and extracts the last 16 characters (which matches the last 16 characters of the GUID)
; 	 */
; 	_idFromReg(regString) 
; 	{
; 		return SubStr(regString, 17)
; 	}
;  
; 	/*
; 	 * takes an ID from microsofts IVirtualDesktopManager and extracts the last 16 characters (which matches the last 16 characters of the ID from the registry)
; 	 */
; 	_idFromGuid(guidString)
; 	{
; 		return SubStr(RegExReplace(guidString, "[-{}]"), 17)
; 	}
;  
; 	_indexOfId(guid) 
; 	{
; 		loop, % this.desktopIds.MaxIndex()
; 		{
; 			debugger("looking for `n" guid "`n" this.desktopIds[A_index])
; 			if(this.desktopIds[A_index] == guid) 
; 			{
; 				debugger("Found it! desktop is " A_Index)
; 				return A_Index
; 			}
; 		}
; 		return -1
; 	}
;  
; 	_setupGui()
; 	{
; 		Gui, new
; 		Gui, show
; 		Gui, +HwndMyGuiHwnd
; 		this.hwnd := MyGuiHwnd
; 		Gui, hide
; 		return this
; 	}
; }
; class VirtualDesktopManagerClass
; {
; 	__new()
; 	{	
; 		debugger("creating th vdm")
; 		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186440(v=vs.85).aspx
; 		CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}" ;search VirtualDesktopManager clsid
; 		IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}" ;search IID_IVirtualDesktopManager
; 		this.iVirtualDesktopManager := ComObjCreate(CLSID, IID)
;  
; 		this.isWindowOnCurrentVirtualDesktopAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 3*A_PtrSize)
; 		this.getWindowDesktopIdAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 4*A_PtrSize)
; 		this.moveWindowToDesktopAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 5*A_PtrSize)
;  
; 		return this
; 	}
;  
; 	getWindowDesktopId(hWnd) 
; 	{
; 		desktopId := ""
; 		VarSetCapacity(desktopID, 16, 0)
; 		;IVirtualDesktopManager::GetWindowDesktopId  method
; 		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186441(v=vs.85).aspx
;  
; 		Error := DllCall(this.getWindowDesktopIdAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", hWnd, "Ptr", &desktopID)	
; 		if(Error != 0) {
; 			msgbox % "error in getWindowDesktopId " Error
; 			clipboard := error
; 		}
;  
; 		return &desktopID
; 	}
;  
; 	getDesktopGuid(hwnd)
; 	{
; 		debugger("getting the guid")
; 		return this._guidToStr(this.getWindowDesktopId(hwnd))
; 	}
; 	; https://github.com/cocobelgica/AutoHotkey-Util/blob/master/Guid.ahk#L36
; 	_guidToStr(ByRef VarOrAddress)
; 	{
; 		;~ debugger(&VarOrAddress " address")
; 		pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
; 		VarSetCapacity(sGuid, 78) ; (38 + 1) * 2
; 		if !DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", &sGuid, "Int", 39)
; 			throw Exception("Invalid GUID", -1, Format("<at {1:p}>", pGuid))
; 		return StrGet(&sGuid, "UTF-16")
; 	}
;  
;  
; 	isDesktopCurrentlyActive(hWnd) 
; 	{
; 		;IVirtualDesktopManager::IsWindowOnCurrentVirtualDesktop method
; 		;Indicates whether the provided window is on the currently active virtual desktop.
; 		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186442(v=vs.85).aspx
; 		Error := DllCall(this.isWindowOnCurrentVirtualDesktopAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", hWnd, "IntP", onCurrentDesktop)
; 		if(Error != 0) {
; 			msgbox % "error in isDesktopCurrentlyActive " Error
; 			clipboard := error
; 		}
;  
; 		return onCurrentDesktop
; 	}
;  
; 	moveWindowToDesktop(hWnd, ByRef desktopId)
; 	{
; 		Error := DllCall(this.moveWindowToDesktopAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", activeHwnd, "Ptr", &desktopId)
; 		if(Error != 0) {
; 			msgbox % "error in moveWindowToDesktop " Error "but no error?"
; 			clipboard := error
; 		}
; 		return this
; 	}
;  
; 	getCurrentDesktop(hWnd) 
; 	{
; 		desktopId := ""
; 		VarSetCapacity(desktopID, 16, 0)
;  
; 		Error := DllCall(this.getCurrentDesktopAddress, "Ptr", this.iVirtualDesktopManagerInternal, "Ptr", &desktopID)	
; 		if(Error != 0) {
; 			msgbox % "error in getWindowDesktopId " Error
; 			clipboard := error
; 		}
;  
; 		return &desktopID
; 	}
; }
; ;taken from optimist__prime https://autohotkey.com/boards/viewtopic.php?t=9224
; class MonitorMapperClass
; {
; 	; This part figures out how many times we need to hit Tab to get to the
; 	; monitor with the window we are trying to send to another desktop.	
; 	getRequiredTabCount(hwnd)
; 	{
; 		activemonitor := this.getWindowsMonitorNumber(hwnd)
;  
; 		SysGet, monitorcount, MonitorCount
; 		SysGet, primarymonitor, MonitorPrimary
;  
; 		If (activemonitor > primarymonitor)
; 		{
; 			tabCount := activemonitor - primarymonitor
; 		}
; 		else If (activemonitor < primarymonitor)
; 		{
; 			tabCount := monitorcount - primarymonitor + activemonitor
; 		}
; 		else
; 		{
; 			tabCount := 0
; 		}
; 		tabCount *= 2	
;  
; 		return tabCount
; 	}
;  
; 	/*
; 	 * This function returns the monitor number of the window with the given hwnd
; 	 */
; 	getWindowsMonitorNumber(hwnd)
; 	{
; 		WinGetPos, x, y, width, height, % "Ahk_id" hwnd
; 		debugger("Window Position/Size:`nX: " X "`nY: " Y "`nWidth: " width "`nHeight: " height)	
; 		SysGet, monitorcount, MonitorCount
; 		SysGet, primarymonitor, MonitorPrimary	
; 		debugger("Monitor Count: " MonitorCount)	
; 		Loop %monitorcount%
; 		{
; 			SysGet, mon, Monitor, %a_index%
; 			debugger("Primary Monitor: " primarymonitor "`nDistance between monitor #" a_index "'s right border and Primary monitor's left border (Left < 0, Right > 0):`n" monRight "px")	
; 			If (x < monRight - width / 2 || monitorcount = a_index)
; 			{
; 				return %a_index%
; 			}
; 		}
; 	}
; }
;  
; debugger(message) 
; {
; 	;~ ToolTip, % message
; 	;~ sleep 10
; 	return
; }
;  