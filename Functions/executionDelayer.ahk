; ==================================================================================================
; █▀▀▀▐▄ ▄▌█▀▀▀ ▄▀▀▀ █  █▐▀█▀▌▀█▀ ▄▀▀▄ ▐▀▀▄ █▀▀▄ █▀▀▀ █    ▄▀▀▄ █  █ █▀▀▀ █▀▀▄    ▄▀▀▄ █  █ █ ▄▀ 
; █▀▀   █  █▀▀  █    █  █  █   █  █  █ █  ▐ █  █ █▀▀  █  ▄ █▄▄█ ▀▄▄█ █▀▀  █▄▄▀    █▄▄█ █▀▀█ █▀▄  
; ▀▀▀▀▐▀ ▀▌▀▀▀▀  ▀▀▀  ▀▀   █  ▀▀▀  ▀▀  ▀  ▐ ▀▀▀  ▀▀▀▀ ▀▀▀  █  ▀ ▄▄▄▀ ▀▀▀▀ ▀  ▀▄ ▀ █  ▀ █  ▀ ▀  ▀▄
;
; Module for adjusting the timing of operations through systematic, enhanced usage of AutoHotkey's
;   Sleep command.
;
; @version 1.0.1
;
; @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
; @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/Functions/executionDelay
;   er.ahk
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
; Table of Contents:
; -----------------
;   §1: ExecutionDelayer........................................................................44
;     >>> §1.1: Properties......................................................................50
;     >>> §1.2: Constructor __New(…)............................................................64
;     >>> §1.3: Member functions................................................................78
;       →→→ §1.3.1: AreMembersValid()...........................................................81
;       →→→ §1.3.2: CompleteCurrentProcess()....................................................97
;       →→→ §1.3.3: InterpretDelayString(…)....................................................107
;       →→→ §1.3.4: ScaleDelay(…)..............................................................131
;       →→→ §1.3.5: SetDefaultDelay(…).........................................................152
;       →→→ §1.3.6: SetUpNewProcess(…).........................................................170
;       →→→ §1.3.7: Wait([…])..................................................................180
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
;   §1: ExecutionDelayer module
; --------------------------------------------------------------------------------------------------

class ExecutionDelayer {

;   ································································································
;     >>> §1.1: Properties

	quantum := 0
	xsDelay := 0
	sDelay := 0
	mDelay := 0
	lDelay := 0
	defaultDelay := 0
	checkType := 0
	curStep := 0
	totSteps := 0
	curProc := ""

;   ································································································
;     >>> §1.2: Constructor __New(…)

	__New( aTypeChecker, aQuantum, aXsScalar, aSScalar, aMScalar, aLScalar ) {
		this.checkType := aTypeChecker
		this.quantum := aQuantum
		this.qDelay := this.quantum
		this.xsDelay := aXsScalar * this.qDelay
		this.sDelay := aSScalar * this.qDelay
		this.mDelay := aMScalar * this.qDelay
		this.lDelay := aLScalar * this.qDelay
		this.defaultDelay := this.sDelay
	}

;   ································································································
;     >>> §1.3: Member Functions

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.1: AreMembersValid()

	AreMembersValid() {
		ct := this.checkType
		validity := True

		validity := ct.IsNumber( this.quantumn ) && this.quantum > 0
			&& ct.IsNumber( this.xsDelay ) && this.xsDelay > this.quantumn
			&& ct.IsNumber( this.sDelay ) && this.sDelay > this.xsDelay
			&& ct.IsNumber( this.mDelay ) && this.mDelay > this.sDelay
			&& ct.IsNumber( this.lDelay ) && this.lDelay > this.mDelay

		return validity
	}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.2: CompleteCurrentProcess()

	CompleteCurrentProcess() {
		if ( this.curStep < this.totSteps ) {
			this.curStep := this.totSteps
			DisplaySplashProgress( Round( this.curStep / this.totSteps * 100 ) )
		}
	}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.3: InterpretDelayString(…)

	InterpretDelayString( delayStr ) {
		if ( delayStr == "shortest" || delayStr == "zs" ) {
			delay := this.qDelay
		} else if ( delayStr == "xShort" || delayStr == "xs" ) {
			delay := this.xsDelay
		} else if ( delayStr == "short" || delayStr == "s" ) {
			delay := this.sDelay
		} else if ( delayStr == "medium" || delayStr == "m" ) {
			delay := this.mDelay
		} else if ( delayStr == "long" || delayStr == "l" ) {
			delay := this.lDelay
		} else {
			delay := this.sDelay
			ErrorBox( A_ThisLabel . " > " . A_ThisFunc, "I was called with an incorrectly specified"
				. " delayStr parameter, which had a value of: " . delayStr . ". I will assume a sho"
				. "rt delay is appropriate and allow script execution to proceed." )
		}

		return delay		
	}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.4: ScaleDelay(…)

	ScaleDelay( delay, multiplier ) {
		if ( this.checkType.IsNumber( delay ) && delay > 0 ) {
			if (multiplier > 0) {
				delay *= multiplier
			} else if (multiplier < 0) {
				ErrorBox( A_ThisLabel . " > " . A_ThisFunc, "I was called with an incorrectly speci"
					. "fied multiplier parameter, which had a value of: " . multiplier . ". I will "
					. "ignore it and allow execution to proceed.")
			}
		} else {
			ErrorBox( A_ThisLabel . " > " . A_ThisFunc, "I was called with an incorrectly typed/spe"
				. "cified delay parameter, which had a value of: " . delay . ". I will do nothing m"
				. "ore with it and simply return it as is.")			
		}

		return delay
	}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.5: SetDefaultDelay(…)

	SetDefaultDelay( delayLength, multiplier := 0 ) {
		delay := -1
		if ( this.checkType.IsAlpha( delayLength ) ) {
			delay := this.InterpretDelayString( delayLength )
		} else if ( this.checkType.IsNumber( delayLength ) && delayLength > 0 ) {
			delay := delayLength
		}
		if( delay > 0 ) {
			if ( multiplier != 0 ) {
				delay := this.ScaleDelay( delay, multiplier )
			}
			this.defaultDelay := delay			
		}
	}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.6: SetUpNewProcess(…)

	SetUpNewProcess( totSteps, procName ) {
		this.curStep := 0
		this.totSteps := totSteps
		this.curProc := procName
		DisplaySplashProgress( 0, this.curProc )
	}

;      · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
;       →→→ §1.3.7: Wait([…])

	Wait( delayLength := 0, multiplier := 0 ) {
		if ( this.totSteps != 0 && this.curStep < this.totSteps ) {
			this.curStep++
			DisplaySplashProgress( Round( this.curStep / this.totSteps * 100 ) )
		}
		if ( this.checkType.IsAlpha( delayLength ) ) {
			delay := this.InterpretDelayString( delayLength )
		} else if ( this.checkType.IsNumber( delayLength ) && delayLength > 0 ) {
			delay := delayLength
		} else {
			delay := this.defaultDelay
		}
		if ( multiplier != 0 ) {
			delay := this.ScaleDelay( delay, multiplier )
		}
		Sleep % delay			
	}
}
