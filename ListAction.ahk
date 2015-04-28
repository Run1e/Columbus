ListAction(GuiEvent) {
	if (GuiEvent = "Normal") || (GuiEvent = "RightClick")
		GuiControl 1: focus, input
	if (GuiEvent = "DoubleClick")
		Hotkeys("Enter") ; we want to simulate an "enter" click.
	LV_GetText(text, 1)
	if (text = "AHK Documentation:") {
		LV_GetText(text, LV_GetNext())
		WinGetPos, x, y,,, ahk_id%HWND_MAIN%
		if (desc := IniRead("docslist", text, "desc"))
			ToolTip % desc, x, y - 25
		else
			ToolTIp
	} else
		ToolTip
}