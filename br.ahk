br(string, encode := false) {
	if encode {
		StringReplace, string, string, [, |(|, 1
		StringReplace, string, string, ], |)|, 1
	} else {
		StringReplace, string, string, |(|, [, 1
		StringReplace, string, string, |)|, ], 1
	} return string
}