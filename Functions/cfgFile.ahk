; ==================================================================================================
; cfgFile.ahk
; --------------------------------------------------------------------------------------------------
; SUMMARY: Module for storing and retreiving script configuration settings.
;
; AUTHOR: Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; 
; REPOSITORY: https://github.com/invokeImmediately/WSU-AutoHotkey
;
; LICENSE: ISC - Copyright (c) 2019 Daniel C. Rieck.
;
;   Permission to use, copy, modify, and/or distribute this software for any purpose with or
;   without fee is hereby granted, provided that the above copyright notice and this permission
;   notice appear in all copies.
;
;   THE SOFTWARE IS PROVIDED "AS IS" AND DANIEL RIECK DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
;   SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
;   DANIEL RIECK BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
;   DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
;   CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;   PERFORMANCE OF THIS SOFTWARE.
; ==================================================================================================

class CfgFile {
	__New( cfgFilePath ) {
		this.cfgFilePath := cfgFilePath
		this.cfgFile := FileOpen( cfgFilePath, "r" )
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
			line := this.cfgFile.ReadLine()
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
			line := this.cfgFile.ReadLine()
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
