IniDelete(file, section, key := "") {
	if key
		IniDelete, % A_WorkingDir "\" file ".ini", % br(section, true), % key
	else
		IniDelete, % A_WorkingDir "\" file ".ini", % br(section, true)
}