RandomString(length, special := false) {
	Loop % length
		str .= (r := Random(1, special ? 4 : 3)) = 1
	? Random(0, 9) : r = 2
	? Chr(Random(65, 90)) : r = 3
	? Chr(Random(97, 122)) : SubStr("-_?!&:", r := Random(1, 6), 1)
	return % str
}