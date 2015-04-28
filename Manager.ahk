Manager() {
	static
	global HWND_MANAGER
	if WinExist("ahk_id" HWND_MANAGER) {
		WinActivate
		return
	} Gui 2: Destroy
	Hotkey(Settings.Hotkey, "Off")
	Hotkey(Settings.WindowHotkey, "Off")
	Gui 1: +Disabled
	Gui 4: Default
	Gui 4: Color, 383838, 454545
	Gui 4: Add, Text, w200 Center cWhite, Visible items
	Gui 4: Add, Text, yp xp+270 w200 Center cWhite, Hidden items
	Gui 4: Add, ListView, x10 h294 vActiveListView gActiveLabel -LV0x10 -Multi NoSortHdr NoSort -Hdr AltSubmit cWhite Checked, Active|freq|priv
	Gui 4: Add, ListView, hp xp+250 yp vDeletedListView gDeletedLabel -LV0x10 -Multi NoSortHdr NoSort -Hdr AltSubmit cWhite Checked, Deleted|freq|priv
	Gui 4: Add, Text, y330 x10 w250 cWhite, Drag && drop. Check an item to bypass file validation.
	Gui 4: Font, s9
	Gui 4: Add, Edit, yp-3 x260 w190 gManagerSearch vmanagerinfo cWhite
	Gui 4: Font, s8
	Gui 4: Add, Button, yp-2 x461 w40 h24 gManagerSave hwndHWND_MANAGER_SAVE, Save
	Gui 4: ListView, SysListView321
	for a, b in list()
		LV_Add((b.priv ? "Check" : ""), b.name, b.freq, b.priv)
	LV_ModifyCol(2, "SortDesc")
	LV_ModifyCol(1, 182)
	LV_ModifyCol(2, 36)
	LV_ModifyCol(3, 0)
	temp := FileRead(A_WorkingDir "\del_items.ini")
	Gui 4: ListView, SysListView322
	Loop, parse, temp, % "`n", % "`r"
		if InStr(A_LoopField, "[") = 1
			LV_Add((IniRead("del_items", SubStr(A_LoopField, 2, -1), "priv") ? "Check" : ""), br(SubStr(A_LoopField, 2, -1)), IniRead("del_items", SubStr(A_LoopField, 2, -1), "freq"), IniRead("del_items", SubStr(A_LoopField, 2, -1), "priv"))
	LV_ModifyCol(2, "SortDesc")
	LV_ModifyCol(1, 182)
	LV_ModifyCol(2, 36)
	LV_ModifyCol(3, 0)
	Gui 4: Show,, Program Manager
	Gui 4: -0x20000 +hwndHWND_MANAGER
	GuiControl 4: Focus, Edit1
	Hotkey("^Backspace", "ManagerBackspace", HWND_MANAGER)
	Hotkey("MButton", "ManagerMButton", HWND_MANAGER)
	Hotkey("WheelUp", "ManagerScroll", HWND_MANAGER)
	Hotkey("WheelDown", "ManagerScroll", HWND_MANAGER)
	Hotkey("Up", "Off", HWND_MAIN)
	Hotkey("Down", "Off", HWND_MAIN)
	return
	
	; handles the moving of items when dragging
	DeletedLabel:
	ActiveLabel:
	Critical
	if (A_GuiEvent = "D") {
		Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "2" : "1")
		LV_GetText(name, A_EventInfo)
		LV_GetText(freq, A_EventInfo, 2)
		LV_GetText(priv, A_EventInfo, 3)
		while GetKeyState("LButton", "P") {
			ToolTip % name
			sleep 5
		} ToolTip
		MouseGetPos,,,,control
		if (control = "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "1" : "2")) {
			IsChecked := LV_IsChecked(A_EventInfo)
			LV_Delete(A_EventInfo)
			Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "1" : "2")
			max := pos := ""
			if freq
				pos := LV_Add((IsChecked ? "Check" : ""), name, freq, IsChecked)
			else
				while (pos = 0 || max = "")
					pos := LV_Insert(Random(1, Random(1, max := Ceil((LV_GetCount() / 4) * 3))), (IsChecked ? "Check" : ""), name, freq, IsChecked)
			LV_ModifyCol(2, "SortDesc")
			GuiControl 4:, Static3, % (A_ThisLabel = "DeletedLabel" ? "Showing: " : "Hiding: ") . name
			Print("Manager(): " (A_ThisLabel = "DeletedLabel" ? "Showing: " : "Hiding: ") name)
		}
	} else if (A_GuiEvent = "I") {
		if !WinExist("ahk_id" HWND_MANAGER)
			return
		Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "2" : "1")
		LV_Modify(A_EventInfo, "Col3", LV_IsChecked(A_EventInfo))
	} else if A_GuiEvent.equals("Normal|RightClick|C") {
		Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? 1 : 2)
		if LV_GetNext()
			LV_Modify(LV_GetNext(), "-Select")
		GuiControl 4: Focus, Visible items
	}
	return
	
	; scrolls the listview which the mouse hovers over
	ManagerScroll:
	MouseGetPos,,,,control
	ControlClick, % control,,, % InStr(A_ThisHotkey, "Down") ? "WheelDown" : "WheelUp", ahk_id%HWND_MAIN%
	return
	
	; focuses on a static when MButton is pressed
	ManagerMButton:
	GuiControl 4: Focus, Visible items
	return
	
	; runs when anything is written into the edit control
	ManagerSearch:
	Gui 4: Submit, NoHide
	if (managerinfo = "") {
		Loop 2 {
			Gui 4: ListView, % "SysListView32" A_Index
			LV_Modify(LV_GetNext(), "-Select")
		} return
	} Loop 2 {
		LV_Modify(LV_GetNext(), "-Select")
		Gui 4: ListView, % "SysListView32" A_Index
		Loop % LV_GetCount() {
			LV_GetText(text, A_Index)
			if InStr(text, managerinfo) {
				LV_Modify(A_Index, "Select Vis")
				return
			}
		}
	} return
	
	; CTRL+BACKSPACE logic
	ManagerBackspace:
	ControlGetFocus, control, % "ahk_id" HWND_MANAGER
	if (control = "Edit1") {
		GuiControl 3: -Redraw, Edit1
		Send ^+{Left}{Backspace}
		GuiControl 3: +Redraw, Edit1
	} return
	
	; save!
	ManagerSave:
	Gui 4: +Disabled
	ControlGetText, temp, Static3
	GuiControl 4:, Static3, % "Saving.. please wait.."
	list := []
	for a, b in ["items", "del_items"] {
		par := IniRead(b)
		Loop, parse, par, % "`n", % "`r"
		{
			list[A_LoopField, "dir"] := IniRead(b, A_LoopField, "dir")
			list[A_LoopField, "icon"] := IniRead(b, A_LoopField, "icon")
			list[A_LoopField, "freq"] := IniRead(b, A_LoopField, "freq")
			for c, d in [1, 2] {
				Gui 4: ListView, % "SysListView32" . d
				Loop % LV_GetCount() {
					LV_GetText(text, A_Index)
					if (text = A_LoopField) {
						LV_GetText(IsChecked, A_Index, 3)
						list[A_LoopField, "priv"] := IsChecked
						break 2
					}
				}
			}
		}
	} 
	for a, b in ["items", "del_items"] {
		FileDelete % b ".ini"
		Gui 4: ListView, % "SysListView32" A_Index
		Loop % LV_GetCount()
		{
			LV_GetText(text, A_Index)
			IniWrite(b, text, "dir", list[text, "dir"])
			IniWrite(b, text, "icon", list[text, "icon"])
			IniWrite(b, text, "freq", list[text, "freq"])
			IniWrite(b, text, "priv", (list[text, "priv"] ? list[text, "priv"] : 0))
		}
	}
	
	list(true)
	GuiControl 1:, input, % ""
	
	Item.action := []
	
	4GuiEscape:
	4GuiClose:
	Hotkey(Settings.Hotkey, "On")
	Hotkey(Settings.WindowHotkey, "On")
	Hotkey("^Backspace", "Hotkey", HWND_MAIN)
	Hotkey("MButton", "Hotkey", HWND_MAIN)
	Hotkey("MButton", "Hotkey", HWND_MAIN)
	Hotkey("WheelUp", "Hotkey", HWND_MAIN)
	Hotkey("WheelDown", "Hotkey", HWND_MAIN)
	Hotkey("Up", "On", HWND_MAIN)
	Hotkey("Down", "On", HWND_MAIN)
	Gui 4: Destroy
	Gui 1: -Disabled
	Gui 1: Default
	GuiControl 1: focus, input
	return
}