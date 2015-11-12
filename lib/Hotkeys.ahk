; handles hotkeys
Hotkeys(key) {
	
	Gui % Main.hwnd ":Default"
	
	if Plugin.Event("OnHotkey", false, key)
		return
	
	if (key = "^Backspace") {
		Main.Control("-Redraw", "Edit1")
		ControlSend, Edit1, ^+{Left}{Backspace}, % Main.ahkid
		Main.Control("+Redraw", "Edit1")
	} else
		
	if key.equals("WheelDown", "WheelUp") {
		ControlClick, SysListView321, % Main.ahkid,, % key
	} else
		
	if (key = "Escape") {
		if Main.GetText().startsWith(Settings.Prefix)
			Main.SetText()
		else
			Main.Hide(true)
	} else
		
	if (key = "Delete") && (Settings.List = "items") {
		temp := []
		; loop through the selected rows
		while (num := LV_GetNext()) {
			LV_GetText(item_name, num)
			LV_Delete(num)
			temp.Insert({pos:num, name:item_name})
			ItemList.Lists[Settings.List].Hide(item_name)
			if !top
				top := num
		} ItemList.Lists[Settings.List].History.Insert(temp)
		for a, b in temp
			for z, x in ItemList.Lists[Settings.List].List
				if (b.name = x)
					ItemList.Lists[Settings.List].List.Remove(z)
		LV_Modify(top > LV_GetCount() ? LV_GetCount() : top, "Select Vis") ; select the top row
		Main.SizeGui()
	} else
		
	if (key = "^Z") && (Settings.List = "items") {
		Main.SetDefault()
		if !IsObject(lat := ItemList.Lists[Settings.List].History.Pop())
			return
		while (num := LV_GetNext())
			LV_Modify(num, "-Select")
		for a, b in lat {
			ItemList.Lists[Settings.List].Show(b.name)
			ItemList.Lists[Settings.List].List.InsertAt(b.pos + A_Index - 1, b.name)
			LV_Modify(LV_Insert(b.pos + A_Index - 1, "Icon" ItemList.Lists[Settings.List].Icon[b.name], b.name), "Select Vis")
		} Main.SizeGui()
	} else
		
	/*
		if key.equals("+Down", "+Up") {
			if (key = "+Down") {
				while selected
					selected := LV_GetNext(selected ? selected : 0)
			} else
				selected:=LV_GetNext()
			
			if (key = "+Down" && selected < LV_GetCount()) || (key = "+Up" && selected > 1)
				LV_Modify(selected + (key = "+Down" ? 1 : -1), "Select vis")
		} else
			
	*/
	if key.equals("Down", "Up") {
		selected := LV_GetNext()
		if (key = "Down" && selected < LV_GetCount()) || (key = "Up" && selected > 1)
			LV_Modify(selected, "-Select"), LV_Modify(selected + (key = "down" ? 1 : -1), "Select vis")
		sleep 1
	}
	
	Plugin.Event("OnHotkey", true, key)
	
}