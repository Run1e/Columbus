String_Split(str, delim) {
	arr := []
	Loop, parse, str, % delim
		arr[A_Index] := A_LoopField
	return arr
}