WM_LBUTTONDOWN() {
	WinGet, style, Style
	if (Style & 0x40000) && (A_Gui = 1)
		PostMessage, 0xA1, 2
	else if (A_Gui = 7)
		Tray.Destroy()
}