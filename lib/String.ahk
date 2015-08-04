String_Contains(str, needle*) {
	for a, b in needle {
		if IsObject(b)
			return String_Contains(str, b*)
		else
			if (x := InStr(str, b))
				return x
	} return false
}

String_Equals(str, needle*) {
	for a, b in needle {
		if IsObject(b)
			return String_Equals(str, b*)
		else
			if (str = b)
				return true
	} return false
}

String_Find(str, string) {
	return InStr(str, string)
}

String_Split(str, delim := "") {
	arr := []
	Loop, parse, str, % delim
		arr[A_Index] := A_LoopField
	return arr
}

String_StartsWith(str, string) {
	if (InStr(str, string) = 1)
		return true
	return false	
}

String_EndsWith(str, string) {
	if (string = SubStr(str, StrLen(str) - StrLen(string) + 1))
		return true
	return false
}

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