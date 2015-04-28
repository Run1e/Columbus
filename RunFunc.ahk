RunFunc(data) {
	if InStr(data, "(")
		func := SubStr(data, 1, InStr(data, "(") - 1), params := SubStr(data, InStr(data, "(") + 1)
	else
		func := data
	if InStr(func, ".")
		class := SubStr(func, 1, InStr(func, ".") - 1), func := SubStr(func, InStr(func, ".") + 1)
	p := []
	Loop, parse, params
	{
		if (A_LoopField = """")
			fin := !fin
		else if ((A_LoopField = ",") || (A_Index = params.length)) && (!fin) {
			i++
			p[i] := trim(temp)
			temp := ""
		} else
			temp .= A_LoopField
	} if InStr(data, "print(") <> 1
		print("Receive(): Calling " (class ? class "." : "") func "()" (params ? " with the parameters (" params : ""))
	if class
		return %class%[func](p*)
	else if func
		return %func%(p*)
	return 0
}