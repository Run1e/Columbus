timer(name) {
	static start := []
	if start[name] {
		temp := start[name], start[name] := ""
		return STMS() - temp
	} else
		start[name] := STMS()
}