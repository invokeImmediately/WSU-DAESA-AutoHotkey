; ==================================================================================================
; cfgFile.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Module for storing and retreiving script configuration settings.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: MIT - Copyright (c) 2020 Daniel C. Rieck.
;
;   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;   and associated documentation files (the “Software”), to deal in the Software without
;   restriction, including without limitation the rights to use, copy, modify, merge, publish,
;   distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in all copies or
;   substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;   BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ==================================================================================================

class CfgFile {
	__New( cfgFilePath ) {
		this.cfgFilePath := cfgFilePath
		this.cfgFile := FileOpen( cfgFilePath, "r`n" )
		if ( this.cfgFile ) {
			this.LoadCfgSettings()
			this.cfgFile.Close()
		} else {
			MsgBox % "Failed to load configuration file."
		}
	}

	LoadCfgKeys() {
		if ( this.cfgFile && !this.cfgFile.AtEOF ) {
			this.cfgKeys := []
			line := StrReplace( this.cfgFile.ReadLine(), "`n", "" )
			startPos := 1
			foundPos := InStr( line, "`t", True, startPos )
			while ( foundPos ) {
				this.cfgKeys.Push( SubStr( line, startPos, foundPos - startPos ) )
				startPos := foundPos + 1
				foundPos := InStr( line, "`t", True, startPos )
			}
			if ( this.cfgKeys.Length() && startPos != StrLen( line ) + 1 ) {
				this.cfgKeys.Push( SubStr( line, startPos, StrLen( line ) - startPos + 1 ) )
			}
		} else {
			MsgBox % "Configuration file was not usable."
		}
	}

	LoadCfgSettings() {
		this.LoadCfgKeys()
		this.cfgSettings := []
		lineCount := 1
		errEncd := False
		while ( !errEncd && !this.cfgFile.AtEOF && lineCount <= 1024 ) {
			vals := []
			line := StrReplace( this.cfgFile.ReadLine(), "`n", "" )
			startPos := 1
			foundPos := InStr( line, "`t", True, startPos )
			idx := 1
			while ( foundPos ) {
				vals[ this.cfgKeys[ idx ] ] := SubStr( line, startPos, foundPos - startPos )
				startPos := foundPos + 1
				foundPos := InStr( line, "`t", True, startPos )
				idx++
			}
			if ( vals.Count() && startPos != StrLen( line ) + 1 ) {
				vals[ this.cfgKeys[ idx ] ] :=  SubStr( line, startPos
					, StrLen( line ) - startPos + 1 )
			}
			if ( vals.Count() == this.cfgKeys.Length() ) {
				this.cfgSettings.Push( vals )
			} else {
				errEncd := True
			}
			lineCount++
		}
	}
}
