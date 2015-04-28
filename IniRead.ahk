IniRead(file, section := "", key := "") {
	IniRead, output, % A_WorkingDir "\" file ".ini", % br(section, true), % key, % A_Space
	if (section = "" && key = "")
		output := br(output)
	return output
}