ScrollBarAt(ControlHWND) { ; thanks to VxE - http://www.autohotkey.com/board/topic/44657-how-to-check-if-its-the-end-of-page/?p=278091
	VarSetCapacity(sbi, 60, 0)
	NumPut(60, sbi, 0, "int")
	if DllCall("GetScrollBarInfo", uint, ControlHWND, int, 0xFFFFFFFB, uint, &sbi) {
		sbwid := NumGet(sbi, 20, "int")
		sbbot := NumGet(sbi, 16, "int") - NumGet(sbi, 8, "int") - sbwid*2
		thtop := NumGet(sbi, 24, "int") - sbwid
		thbot := NumGet(sbi, 28, "int") - sbwid
		thlen := thbot - thtop
		if NumGet(sbi, 36, "int") || NumGet(sbi, 48, "int") || thtop < 0
			return "Disabled"
		else if (thtop = 0)
			return 0
		else if (thbot = sbbot)
			return 1
		else
			return Round(thtop / (sbbot - thlen), 2)
	} return ""
}