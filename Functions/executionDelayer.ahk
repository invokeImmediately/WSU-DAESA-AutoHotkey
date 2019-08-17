class ExecutionDelayer {
	quantum := 0
	xsDelay := 0
	sDelay := 0
	mDelay := 0
	lDelay := 0
	defaultDelay := 0
	checkType := 0

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

	Wait( delayLength := 0, multiplier := 0 ) {
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
