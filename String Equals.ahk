String_Equals(str, needle) {
	Loop, parse, needle, % "|"
		if (A_LoopField = str)
			return true
	return false
}