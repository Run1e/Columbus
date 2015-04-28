Hotkeys(key) {
	LV_GetText(type, 1)
	LV_GetText(text, LV_GetNext())
	if (key = "Enter") {
		ControlGetText, input, Edit1
		if (type = "Commands:") {
			GuiControl 1:, input, % (text.startsWith("docs") ? "/docs " : "")
			ControlSend, Edit1, ^{Right}
			if (temp := InStr(text, " - "))
				cmd[SubStr(text, 1, temp - 1)]()
			else if (text = "Result") {
				param := []
				Loop, parse, input, % " "
				{
					if !func {
						func := SubStr(A_LoopField, 2)
						continue
					} param .= " " A_LoopField
				} cmd[func](Trim(param))
			}
		} else if (type = "AHK Documentation:") {
			if FileExist(Substr(A_AhkPath, 1, InStr(A_AhkPath, "\",, 0)) "AutoHotkey.chm")
				run % "hh mk:@MSITStore:" Substr(A_AhkPath, 1, InStr(A_AhkPath, "\",, 0)) "AutoHotkey.chm::" IniRead("docslist", text, "url")
			else
				run % "http://www.ahkscript.org" IniRead("docslist", text, "url")
			Gui.Hide()
		} else if (type.EndsWith(" search:")) {
			LV_GetText(text, 2)
			run % (InStr(type, "Google") ? "https://www.google.com/?q=" : "http://www.wolframalpha.com/input/?i=") UriEncode(text)
			Gui.Hide()
		} else {
			Print("Run: " text)
			if run(IniRead("items", text, "dir"))
				Item.AddFreq(text)
			Gui.Hide()
			list(true)
			GuiControl 1:, input, % ""
		}
	} else
		
	if (key = "^Backspace") {
		GuiControl 1: -Redraw, Edit1
		ControlSend, Edit1, ^+{Left}{Backspace}
		GuiControl 1: +Redraw, Edit1
	} else
		
	if (key = "Escape") {
		ControlGetText, input, Edit1
		if (InStr(input, "/") = 1)
			GuiControl 1:, input, % ""
		else
			Gui.Hide()
	} else
		
	if (key = "^Z") {
		scroll := ScrollBarAt(HWND_MAIN_LISTVIEW)
		print(scroll)
		if !Item.action.MaxIndex()
			return
		act := Item.action[Item.action.MaxIndex()]
		pos := SubStr(act, 1, InStr(act, " ") - 1)
		name := SubStr(act, InStr(act, " ") + 1)
		Item.Restore(name, pos)
		Item.action.Remove(Item.action.MaxIndex())
		saved_pos := LV_GetNext()
		list(true)
		input()
		ControlGetText, input, Edit1, % AppName
		LV_Modify(saved_pos + (saved_pos > (input ? LV_GetNext() : pos) ? 1 : 0), "Select")
		LV_Modify(Floor((Settings.Height - 25) / 25) + Floor((LV_GetCount() - Floor((Settings.Height - 25) / 25)) * scroll), "Vis")
	} else
		
	if (key = "Delete") {
		if (type.equals("Commands:|AHK Documentation:")) || (LV_GetCount() = 0)
			return
		LV_Delete(pos := LV_GetNext())
		Item.Delete(text)
		for a, b in list()
			if (b.name = text) {
			Item.action.Insert(A_Index " " text)
			break
		}
		list(, text)
		LV_Modify((LV_GetCount() < pos ? LV_GetCount() : pos), "Select")
	} else
		
	if (key = "TAB") {
		if (type = "Commands:")
			if (text && text <> type) && (LV_GetCount() > 0) && (text <> "Result") {
			temp := InStr(text, " - ")
			GuiControl 1:, input, % "/" SubStr(text, 1, temp ? temp - 1 : text.length)
			Loop 3
				Send ^{Right}
			if text.contains("docs - |g - |w - ") || (LV_GetNext() > 15) ; commands that have a second parameter
				Send {space}
		}
	} else
		
	if key.equals("WheelDown|WheelUp") {
		ControlClick, SysListView321,,, % InStr(key, "Down") ? "WheelDown" : "WheelUp", ahk_id%HWND_MAIN%
	} else
		
	
	if (key.equals("Down|Up")) {
		offset := 1
		LV_GetText(text, 1)
		if (LV_GetNext() = 0) && (text = "Commands:")
			LV_Modify(3, "Select")
		else if LV_Modify(LV_GetNext() + (key = "down" ? offset : -offset), "vis") && !(LV_GetNext() = 1 && key = "up")
			LV_Modify(LV_GetNext() + (key = "down" ? 1 : -1), "Select")
		sleep 1
	}
}