input(input := "") {
	static docslist
	LV_GetText(type, 1)
	if (InStr(input, "/") = 1) {
		ControlGetText, toggle, Button1
		command := SubStr(input, 2)
		if (InStr(command, "docs") = 1) {
			if !docslist {
				docslist := []
				temp := IniRead("docslist")
				Loop, parse, temp, % "`n", % "`r"
					docslist[A_Index, "name"] := A_LoopField
			} if InStr(command, " ")
				input := SubStr(command, InStr(command, " ",, 0) + 1)
			else
				input := SubStr(command, 5)
			GuiControl 1: -Redraw, SysListView321
			LV_Delete()
			for a, b in (input ? FuzzySort(input, docslist, Settings.ForceSequential) : docslist)
				LV_Add("Icon0", b.name, b.score, b.contains, b.abbreviation, b.beginning)
			LV_ModifyCol(2, "Sort")
			LV_ModifyCol(3, "SortDesc")
			LV_ModifyCol(4, "SortDesc")
			LV_ModifyCol(5, "SortDesc")
			LV_ModifyCol(6, LV_GetCount() > Floor((Settings.Height - 25) / 28) ? 0 : 18)
			LV_Insert(1, "Icon0", "AHK Documentation:")
			LV_Insert(2, "Icon0")
			LV_Modify(3, "Select")
			GuiControl 1: +Redraw, SysListView321
			return
		} else
			ToolTip
		
		if (input.startsWith("/g") || input.startsWith("/w")) {
			LV_GetText(text, 1)
			if (input.contains("/g|/w") = 1) && (!InStr(text, "search:"))
				ControlSend, Edit1, {Space}
			LV_Delete()
			LV_Add("Icon0", (input.startsWith("/g") ? "Google" : "Wolfram") . " search:")
			LV_Add("Icon0", InStr(input, " ") ? SubStr(input, InStr(input, " ") + 1) : " ")
			return
		}
		
		commands := [ "manager - open the item manager"
					, "settings - open the settings menu"
					, "docs - search through the AHK documentation"
					, "g/w - google/wolfram search"
					, "move - drag and resize the window"
					, "update - check for updates"
					, "specs - systeminfo (beta)"
					, "about - about Columbus"
					, "reset - reset everything"
					, "exit - exit the program"]
		
		Loop % A_WorkingDir "\commands\*.*"
		{
			if (A_Index = 1)
				commands.Insert("")
			commands.Insert(SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, ".") - 1))
		} if (type <> "Commands:") {
			LV_Delete()
			LV_Add("Icon0", "Commands:")
			LV_Add("Icon0", "")
			for a, b in commands
				LV_Add("Icon0", b)
		} else {
			for a, b in commands {
				if (InStr(b, SubStr(input, 2)) = 1) && (input.length > 1) {
					LV_Modify(a + 2, "Select")
					return
				}
			} LV_Modify(LV_GetNext(), "-Select")
		}
	} else {
		GuiControl 1: -Redraw, SysListView321
		resort:
		LV_Delete()
		for a, b in (input ? FuzzySort(input, list(), Settings.ForceSequential) : list())
			LV_Add("Icon" . b.icon, b.name, b.score, b.contains, b.abbreviation, b.beginning)
		LV_ModifyCol(2, "Sort")
		LV_ModifyCol(3, "SortDesc")
		LV_ModifyCol(4, "SortDesc")
		LV_ModifyCol(5, "SortDesc")
		LV_Modify(1, "Select")
		LV_ModifyCol(6, LV_GetCount() > Floor((Settings.Height - 25) / 25) ? 0 : 18)
		ControlGetText, temp, Edit1, % "ahk_id" HWND_MAIN
		if (input <> temp) {
			input := temp
			gosub resort
		} GuiControl 1: +Redraw, SysListView321
		return
	}
}