String_PseudoProperties(str, key) {
	if key in sqrt,ceil,floor,round,abs,exp,log,ln,cos,tan,sin
		return %key%(str)
	else if (key = "length")
		return StrLen(str)
	else if (key = "toUpper") {
		StringUpper, str, str
		return str
	} else if (key = "toLower") {
		StringLower, str, str
		return str
	} else if (key = "type") {
		for a, b in ["integer", "float", "digit", "xdigit"] {
			if str is %b%
				return "integer"
		} if RegExMatch(str, "\w")
			return "string"
	}
}