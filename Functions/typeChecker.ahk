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
