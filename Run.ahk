Run(file, args := "") {
	run % file (args ? " " args : ""), % SubStr(file, 1, InStr(file, "\",, 0)), UseErrorLevel
	if ErrorLevel
		return PrintError("run(): ERROR - " ErrorLevel)
	print("run(): " file (args ? " ARGS: " args : ""))
	return true
}