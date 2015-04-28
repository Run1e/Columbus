WindowSwitcher() {
	static
	if WinExist("ahk_id" HWND_SWITCHER) {
		Gui 2: Show
		return
	} Hotkey(Settings.Hotkey, "Off")
	Hotkey(Settings.WindowHotkey, "2GuiEscape")
	Gui 2: Font, cWhite s11
	Gui 2: Color, 454545, 454545
	Gui 2: Add, Button, Hidden gQuickSubmit Default
	Gui 2: Add, Edit, x0 y0 w505 h25 vQuickInput gQuickAction
	Gui 2: Add, ListView, x-3 y25 w508 h9999 gQuickListView -Grid -LV0x10 +LV0x20 -E0x200 +LV0x100 -TabStop -Hdr -Multi +AltSubmit, Result|Rating|contains|beginning
	Gui 2: -Caption +AlwaysOnTop +Border +hwndHWND_SWITCHER +ToolWindow
	Gui 2: Default
	Hotkey("Up", "QuickScroll", HWND_SWITCHER)
	Hotkey("Down", "QuickScroll", HWND_SWITCHER)
	Hotkey("WheelUp", "QuickScroll", HWND_SWITCHER)
	Hotkey("WheelDown", "QuickScroll", HWND_SWITCHER)
	Hotkey("Delete", "QuickClose", HWND_SWITCHER)
	Hotkey("^Backspace", "QuickBackspace", HWND_SWITCHER)
	LV_ModifyCol(1, 508)
	LV_SetImageList(QuickImageList := IL_Create(8))
	WinGet, processlist, list
	process := []
	loop % processlist {
		WinGetTitle, name, % "ahk_id" processlist%A_Index%
		WinGet, path, ProcessPath, % name
		if (name <> "")  && (!name.equals("Start|WindowSwitcher|Program Manager") && !name.contains("Columbus.exe")) {
			process[A_Index, "name"] := name
			process[A_Index, "icon"] := IL_Add(QuickImageList, path)
		}
	}
	
	; runs when something is typed into the edit control
	QuickAction:
	Gui Submit, NoHide
	2resort:
	LV_Delete()
	for a, b in (QuickInput ? FuzzySort(QuickInput, process, Settings.ForceSequential) : process)
		LV_Add("Icon" . b.icon, b.name, b.score, b.contains, b.abbreviation, b.beginning)
	ControlGetText, temp, Edit1, WindowSwitcher
	if (temp <> QuickInput) {
		QuickInput := temp
		gosub 2resort
		return
	} LV_ModifyCol(2, "Sort")
	LV_ModifyCol(3, "SortDesc")
	LV_ModifyCol(5, "SortDesc")
	LV_ModifyCol(4, "SortDesc")
	LV_Modify(1, "Select")
	if (A_ThisLabel = "WindowSwitcher") {
		Gui 2: Show, % "x" A_ScreenWidth / 2 - 250 " y" A_ScreenHeight / 2 - 115 " w507 h" LV_GetCount() * 20 + 27 " hide", WindowSwitcher
		DllCall("AnimateWindow", "UInt", HWND_SWITCHER, "Int", 65, "UInt", "0xa0000")
		Gui 2: Show
	} else
		WinMove % "ahk_id" HWND_SWITCHER,
	, % A_ScreenWidth / 2 - 250
	, % A_ScreenHeight / 2 - 115
	, 507
	, % LV_GetCount() * 20 + 27
	return
	
	; UP+DOWN and WHEELUP+WHEELDOWN scrolling logic
	QuickScroll:
	Gui 2: Default
	if LV_Modify(LV_GetNext() + (InStr(A_ThisHotkey, "Down") ? 1 : -1), "vis") && !(LV_GetNext() = 1 && InStr(A_ThisHotkey, "Up"))
		LV_Modify(LV_GetNext() + (InStr(A_ThisHotkey, "Down") ? 1 : -1), "Select")
	return
	
	; DELETE, closes the window
	QuickClose:
	Gui 2: Default
	pos := LV_GetNext()
	LV_GetText(text, pos)
	LV_Delete(pos)
	LV_Modify(pos > LV_GetCount() ? LV_GetCount() : pos, "Select")
	temp := process
	process := []
	for a, b in temp
		if (b.name <> text) {
		i++
		process[i, "name"] := b.name
		process[i, "icon"] := b.icon
	}
	WinMove % "ahk_id" HWND_SWITCHER,
			, % A_ScreenWidth / 2 - 250
			, % A_ScreenHeight / 2 - 115
			, 507
			, % LV_GetCount() * 20 + 27
	WinClose % text
	return
	
	; CTRL+BACKSPACE logic
	QuickBackspace:
	Gui 2: Default
	GuiControl 2: -Redraw, Edit1
	ControlSend, Edit1, ^+{Left}{Backspace}
	GuiControl 2: +Redraw, Edit1
	return
	
	; unfocuses the listview when an event occurs
	QuickListView:
	if (A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")
		GuiControl 2: focus, Edit1
	if (A_GuiEvent = "DoubleClick")
		gosub QuickSubmit
	return
	
	QuickSubmit:
	LV_GetText(text, LV_GetNext())
	gosub 2GuiEscape
	WinActivate % text
	return
	
	2GuiClose:
	2GuiEscape:
	Hotkey(Settings.Hotkey, "On")
	Hotkey(Settings.WindowHotkey, "WindowSwitcher")
	Hotkey("^Backspace", "Hotkey", HWND_MAIN)
	Hotkey("WheelUp", "Hotkey", HWND_MAIN)
	Hotkey("WheelDown", "Hotkey", HWND_MAIN)
	Hotkey("Up", "Hotkey", HWND_MAIN)
	Hotkey("Down", "Hotkey", HWND_MAIN)
	Hotkey("Delete", "Hotkey", HWND_MAIN)
	DllCall("AnimateWindow", "UInt", HWND_SWITCHER, "Int", 65, "UInt", "0x90000")
	IL_Destroy(QuickImageList)
	Gui 2: Destroy
	Gui 1: Default
	return
}