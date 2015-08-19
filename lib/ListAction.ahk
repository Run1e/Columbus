ListAction(GuiEvent, EventInfo) {
	static cha, name, node, tage
	if (GuiEvent = "I") {
		Plugin.Event("OnSelect", LV_GetNext())
	} else if GuiEvent.equals("Normal") {
		Main.Control("focus", "Edit1")
	} else if (GuiEvent = "DoubleClick")
		Submit() ; we want to simulate an "enter" click
	else if (GuiEvent = "RightClick") { ; edit item thing
		Main.Disable()
		Main.Control("focus", "Edit1")
		LV_GetText(name, EventInfo)
		node := xml.ssn("//lists/" Settings.List "/item[@name='" name "']")
		if !node
			return
		tage := []
		Hotkey.Disable(Settings.Hotkeys.Main)
		Hotkey.Disable(Settings.Hotkeys.Fokus)
		cha := new Gui("Edit item")
		cha.Add("Text",, "Name:")
		cha.Margin(5, 4)
		cha.Add("Edit", "x50 y4 w130 R1 gChangeEdit", name)
		cha.Add("Button", "gChangerun x7", "Change directory")
		cha.Add("Button", "gChangeicon x107 yp", "Change icon")
		if Settings.Debug
			cha.Add("Button", "gChangePrint x7 y57", "Print info")
		cha.Add("Button", "gChangeCancel x" (Settings.Debug ? 90 : 7) " y57", "Cancel")
		cha.Add("Button", "gChangeSave x142 yp", "Save")
		cha.Options("-0x20000")
		cha.Control("focus", "Static1")
		cha.Show()
		cha.SetEvents({Close:"ChangeCancel", Escape:"ChangeCancel"})
		
		ChangeEdit:
		tage["name"] := cha.GetText("Edit1")
		return
		
		Changeicon:
		Changerun:
		type := SubStr(A_ThisLabel, 7)
		ea := xml.ea(node)
		FileSelectFile, file,, % ea.icon ? ea.icon : ea.run
		if FileExist(file)
			tage[type] := file
		return
		
		ChangePrint:
		m(name, pa(xml.ea(node)))
		return
		
		ChangeSave:
		ea := xml.ea(node)
		if !tage.name.length
			return m("Please enter a new name.")
		if tage.icon.length
			node.SetAttribute("icon", tage.icon)
		else if (ea.run != tage.run) && !ea.icon.length
			node.SetAttribute("icon", ea.run)
		if tage.run.length
			node.SetAttribute("run", tage.run)
		if tage.name.length
			node.SetAttribute("name", tage.name)
		
		ChangeCancel:
		ChangeClose:
		cha.Destroy(), cha:=name:=node:=tage:=""
		Main.Enable()
		if (A_ThisLabel != "ChangeCancel") {  ;#[make it not have to refresh the list?]
			ItemList.Lists[Settings.List].Refresh(), Main.SetText()
		}
		Hotkey.Enable(Settings.Hotkeys.Main)
		Hotkey.Enable(Settings.Hotkeys.Fokus)
		return
	}
}

ListAction:
ListAction(A_GuiEvent, A_EventInfo)
return