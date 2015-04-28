IniWrite(file, section, key, value) {
	IniWrite, % value, % A_WorkingDir "\" file ".ini", % br(section, true), % key
	return ErrorLevel
}