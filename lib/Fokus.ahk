Fokus() {
	static FokusIL, process, icon, offset
	Fokus.SetText("Edit1", "")
	Hotkey.Disable(Settings.Hotkeys.Main)
	Hotkey.Bind(Settings.Hotkeys.Fokus, "FokusClose")
	Hotkey.Bind("Up", "FokusScroll", Fokus.hwnd)
	Hotkey.Bind("Down", "FokusScroll", Fokus.hwnd)
	Hotkey.Bind("WheelUp", "FokusScroll", Fokus.hwnd)
	Hotkey.Bind("WheelDown", "FokusScroll", Fokus.hwnd)
	Hotkey.Bind("Delete", "FokusDel", Fokus.hwnd)
	Hotkey.Bind("^Backspace", "FokusBackspace", Fokus.hwnd)
	Fokus.SetDefault()
	LV_ModifyCol(1, 508)
	LV_SetImageList(FokusIL := IL_Create(5,, 1), 1)
	DetectHiddenWindows Off
	WinGet, processlist, list
	process := [], icon := []
	loop % processlist {
		WinGetTitle, name, % "ahk_id" processlist%A_Index%
		WinGet, path, ProcessPath, % name
		if (name <> "")  && (!name.equals("Start", "WindowSwitcher", "Program Manager")) && !InStr(name, "Columbus." FileExt(A_ScriptFullPath)) {
			process.Insert(name)
			icon[name] := IL_Add(FokusIL, path)
		}
	} DetectHiddenWindows On
	offset := process.MaxIndex() * 33 / 2
	Fokus.Enable()
	Fokus.Control("focus", "Edit1")
	
	; runs when something is typed into the edit control
	FokusEdit:
	Fokus.SetDefault()
	LV_Delete()
	for a, b in Fuzzy(Fokus.GetText("Edit1"), process)
		LV_Add("Icon" . icon[b.name], b.name)
	LV_Modify(1, "Select")
	Fokus.Pos(A_ScreenWidth / 2 - 250, A_ScreenHeight / 2 - offset, 505, LV_GetCount() * 33 + 25)
	if !Fokus.IsVisible
		Fokus.Show()
	return
	
	FokusDel:
	Fokus.SetDefault()
	pos := LV_GetNext()
	LV_GetText(name, pos)
	LV_Delete(pos)
	LV_Modify(pos > LV_GetCount() ? LV_GetCount() : pos, "Select")
	for a, b in process
		if (b = name)
			process.Remove(a)
	icon.Remove(name)
	Fokus.Pos(,,, LV_GetCount() * 33 + 25)
	WinClose % name
	return
	
	; UP+DOWN and WHEELUP+WHEELDOWN scrolling logic
	FokusScroll:
	Fokus.SetDefault()
	if LV_Modify(LV_GetNext() + (InStr(A_ThisHotkey, "Down") ? 1 : -1), "vis") && !(LV_GetNext() = 1 && InStr(A_ThisHotkey, "Up"))
		LV_Modify(LV_GetNext() + (InStr(A_ThisHotkey, "Down") ? 1 : -1), "Select")
	return
	
	; CTRL+BACKSPACE logic
	FokusBackspace:
	Fokus.SetDefault()
	Fokus.Control("-Redraw", "Edit1")
	ControlSend, Edit1, ^+{Left}{Backspace}, % Fokus.ahkid
	Fokus.Control("+Redraw", "Edit1")
	return
	
	; unfocuses the listview when an event occurs
	FokusListView:
	if A_GuiEvent.equals("Normal", "RightClick")
		Fokus.Control("focus", "Edit1")
	if (A_GuiEvent = "DoubleClick")
		gosub FokusSubmit
	return
	
	FokusSubmit:
	LV_GetText(text, LV_GetNext())
	gosub FokusClose
	WinActivate % text
	return
	
	FokusClose:
	process := icon := offset := ""
	Fokus.Hide()
	Fokus.Disable()
	Main.SetDefault()
	Hotkey.Enable(Settings.Hotkeys.Main)
	Hotkey.Bind("^Backspace", "Hotkeys", Main.hwnd)
	Hotkey.Bind("WheelUp", "Hotkeys", Main.hwnd)
	Hotkey.Bind("WheelDown", "Hotkeys", Main.hwnd)
	Hotkey.Bind("Up", "Hotkeys", Main.hwnd)
	Hotkey.Bind("Down", "Hotkeys", Main.hwnd)
	Hotkey.Bind("Delete", "Hotkeys", Main.hwnd)
	IL_Destroy(FokusIL)
	Hotkey.Bind(Settings.Hotkeys.Fokus, "Fokus")
	Main.Control("focus", "Edit1")
	return
}