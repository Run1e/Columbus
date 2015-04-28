String_Contains(str, needle) {
	Loop, parse, needle, % "|"
		if InStr(str, A_LoopField)
			return true
	return false
}