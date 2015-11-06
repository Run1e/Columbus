Manager() {
	static man
	Main.Hide(), Main.Disable()
	Hotkey.Disable(Settings.Hotkeys.Main)
	man := New Gui("Columbus Manager")
	man.Color(383838, 454545)
	man.Add("Text", "w210 Center cWhite", "Visible items")
	man.Add("Text", "yp xp+265 w200 Center cWhite", "Hidden items")
	man.Add("ListView", "x10 h294 gActiveLabel -LV0x10 -Multi NoSortHdr NoSort -Hdr AltSubmit cWhite", "Active|freq")
	man.Add("ListView", "hp xp+250 yp gDeletedLabel -LV0x10 -Multi NoSortHdr NoSort -Hdr AltSubmit cWhite", "Deleted|freq")
	man.Add("Text", "y330 x10 w250 cWhite", "Drag items across the lists to sort")
	man.Font("s9")
	man.Add("Edit", "yp-3 x260 w190 gManagerSearch cWhite")
	man.Font("s8")
	man.Add("Button", "yp-2 x461 w40 h24 gManagerSave", "Save")
	man.SetEvents({Close:"ManagerClose", Escape:"ManagerClose"})
	man.Control("focus", "Edit1")
	man.SetDefault()
	for a, b in xml.get("//lists/items/item") {
		man.Options("ListView", "SysListView32" (b.hide ? 2 : 1))
		LV_Add(, b.name, b.freq)
	} Loop 2 {
		man.Options("ListView", "SysListView32" A_Index)
		LV_ModifyCol(2, "SortDesc")
		LV_ModifyCol(1, 185)
		LV_ModifyCol(2, 34)
		LV_ModifyCol(2, "SortDesc")
	} man.Show()
	Hotkey.Bind("WheelUp", "ManagerScroll", man.hwnd)
	Hotkey.Bind("WheelDown", "ManagerScroll", man.hwnd)
	return
	
	ManagerScroll:
	MouseGetPos,,,, control
	if InStr(control, "SysListView32")
		ControlClick, % control, % man.ahkid,, % A_ThisHotkey
	return
	
	ManagerSearch:
	Loop 2 {
		man.Options("ListView", "SysListView32" A_Index)
		LV_Modify(LV_GetNext(), "-Select")
	} if man.GetText("Edit1").length
		Loop 2 {
			man.Options("ListView", "SysListView32" A_Index)
			Loop % LV_GetCount() {
				LV_GetText(text, A_Index)
				if InStr(text, man.GetText("Edit1")) {
					LV_Modify(A_Index, "Select")
					return
				}
			}
		}
	return
	
	ActiveLabel:
	DeletedLabel:
	Critical
	if (A_GuiEvent = "D") {
		man.Options("ListView", "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "2" : "1"))
		LV_GetText(name, A_EventInfo)
		LV_GetText(freq, A_EventInfo, 2)
		while GetKeyState("LButton") {
			ToolTip % name
			sleep 5
		} ToolTip
		MouseGetPos,,,,control
		if (control = "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "1" : "2")) {
			LV_Delete(LV_GetNext())
			man.Options("ListView", "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "1" : "2"))
			LV_Insert(Random(1, LV_GetCount() ? LV_GetCount() : 1),, name, freq)
			LV_ModifyCol(2, "SortDesc")
		}
	} else if A_GuiEvent.equals("Normal", "RightClick", "C") {
		man.Options("ListView", "SysListView32" (A_ThisLabel = "DeletedLabel" ? 1 : 2))
		if LV_GetNext()
			LV_Modify(LV_GetNext(), "-Select")
		man.Control("focus", "Visible items")
	} return
	
	ManagerSave:
	Loop 2 {
		man.Options("ListView", "SysListView32" A_Index)
		i := A_Index
		Loop % LV_GetCount() {
			LV_GetText(text, A_Index)
			node := xml.ssn("//lists/items/item[@name='" text "']")
			if (i - 1)
				node.SetAttribute("hide", i - 1)
			else if xml.ea(node).hide.length
				node.RemoveAttribute("hide")
		}
	} Items.Refresh(), Main.SetText()
	
	ManagerClose:
	Hotkey.Enable(Settings.Hotkeys.Main)
	Hotkey.Bind("WheelUp", "Hotkeys", Main.hwnd)
	Hotkey.Bind("WheelDown", "Hotkeys", Main.hwnd)
	man.Destroy(), man := ""
	Main.Enable()
	return
}