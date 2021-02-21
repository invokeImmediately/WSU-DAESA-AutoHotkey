; ==================================================================================================
; ▐▀█▀▌█  █ █▀▀▄ █▀▀▀ ▄▀▀▀ █  █ █▀▀▀ ▄▀▀▀ █ ▄▀ █▀▀▀ █▀▀▄    ▄▀▀▄ █  █ █ ▄▀ 
;   █  ▀▄▄█ █▄▄▀ █▀▀  █    █▀▀█ █▀▀  █    █▀▄  █▀▀  █▄▄▀    █▄▄█ █▀▀█ █▀▄  
;   █  ▄▄▄▀ █    ▀▀▀▀  ▀▀▀ █  ▀ ▀▀▀▀  ▀▀▀ ▀  ▀▄▀▀▀▀ ▀  ▀▄ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Class for checking variable types in a manner compatible with expression syntax.
;
; @version 1.0.0
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/master…→
;   ←…/Functions/typeChecker.ahk
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

class TypeChecker {
	IsAlnum( var ) {
		result := False

		if var is alnum
			result := True

		return result
	}

	IsAlpha( var ) {
		result := False

		if var is alpha
			result := True

		return result
	}

	IsDigit( var ) {
		result := False

		if var is digit
			result := True

		return result
	}

	IsFloat( var ) {
		result := False

		if var is float
			result := True

		return result
	}

	IsInteger( var ) {
		result := False

		if var is integer
			result := True

		return result
	}

	IsLower( var ) {
		result := False

		if var is lower
			result := True

		return result
	}

	IsNumber( var ) {
		result := False

		if var is number
			result := True

		return result
	}

	IsSpace( var ) {
		result := False

		if var is space
			result := True

		return result
	}

	IsTime( var ) {
		result := False

		if var is time
			result := True

		return result
	}

	IsUpper( var ) {
		result := False

		if var is upper
			result := True

		return result
	}

	IsXDigit( var ) {
		result := False

		if var is xdigit
			result := True

		return result
	}
}
