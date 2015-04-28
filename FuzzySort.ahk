FuzzySort(needle := "", arr := "", ForceSequential := false) {
	list := []
	for i, b in arr {
		score:=prefound:=0, pos:=1, approx:=b.name
		Loop % needle.length {
			if !ForceSequential
				if (muddy := InStr(approx, SubStr(needle, A_Index, 1)))
					approx := SubStr(approx, 1, muddy - 1) . SubStr(approx, muddy + 1)
			if (found := InStr(SubStr(b.name, pos), SubStr(needle, A_Index, 1)))
				pos += found, score += prefound - found, prefound := found * -1
			else if (!muddy)
				break
			if (A_Index = needle.length) {
				list[i, "name"] := b.name
				list[i, "icon"] := b.icon
				list[i, "score"] := score * -1
				list[i, "contains"] := !!InStr(b.name, needle)
				for x, v in StrSplit(needle)
					temp .= v ".*?\s+"
				list[i, "abbreviation"] := !!RegExMatch(b.name, "i)" SubStr(temp, 1, -6)) || InStr(RegExReplace(b.name, "[^A-Z]"), needle)
				beg := InStr(b.name, needle)
				list[i, "beginning"] := (beg = 1) || (SubStr(b.name, beg - 1, 1) = " ")
				temp:=""
			}
		}
	} return list
}