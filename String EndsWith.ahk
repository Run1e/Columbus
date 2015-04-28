String_EndsWith(str, string) {
	if (string = SubStr(str, StrLen(str) - StrLen(string) + 1))
		return true
	return false
}