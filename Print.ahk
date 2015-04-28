Print(text := "", col := "") {
	static Colors := {"Black":0,"Navy":1,"Green":2,"Teal":3,"Maroon":4,"Purple":5,"Olive":6
		,"Silver":7,"Gray":8,"Blue":9,"Lime":10,"Aqua":11,"Red":12,"Fuchsia":13,"Yellow":14,"White":15}
	if !Settings.Debug
		return
	if !handle
		Handle := DllCall("GetStdHandle", "UInt", (-11,DllCall("AllocConsole")), "UPtr"), col := "White"
	if col
		DllCall("SetConsoleTextAttribute", "UPtr", Handle, "UShort", Colors[col]|0<<4)
	if text
		return FileOpen("CONOUT$", "w").Write(text . "`n")
}