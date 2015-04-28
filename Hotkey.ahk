Hotkey(key, label := "", hwnd := "") {
	if hwnd
		Hotkey, IfWinActive, % "ahk_id" hwnd
	else
		Hotkey, IfWinActive
	if key
		Hotkey, % key, % label, UseErrorLevel
	if ErrorLevel
		PrintError("Hotkey(): Failed assignment: " key " - " label " - " hwnd)
}