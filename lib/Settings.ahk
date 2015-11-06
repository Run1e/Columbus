; gui code by jNiZm! big thanks to him!
Settings() {
	static 
	static set, pl
	static men := []
	static arrMenu := ["General", "Style", "Hotkeys", "Plugins"]
	static texthwnd
	static tab := 1
	static height := 120
	static fonts := "Arial|Calibri|Cambria|Candara|Century Gothic|Comic Sans MS|Lucida Console|Consolas|Courier New|Georgia|Segoe UI|Tahoma|Terminal|Times New Roman|Verdana"
	
	Main.Hide(), Main.Disable()
	set := new Gui("Settings (" A_ComputerName ")")
	set.SetEvents({Close:"SettingsClose", Escape:"SettingsClose"})
	Hotkey.Disable(Settings.Hotkeys.Main)
	Hotkey.Disable("~Ctrl Up")
	
	set.Margin(3, 3)
	set.Color(0xF0F0F0)
	set.Font("s11 normal", "Segoe UI")
	
	
	set.Add("Text", "y3 w123 h1 0x10")
	for i, b in arrMenu
	{
		men[i] := set.Add("Text", "xp yp+3 w120 h25 0x200 gSelect", "  " b)
		CtlColors.Attach(men[i], MenuBG, "000000")
		set.Add("Text", "yp+27 w123 h1 0x10")
	}
	
	set.Font("s10 cC0C0C0", "MS Shell Dlg 2")
	set.Add("Text", "xm ym+" height " w123 h1 0x10")
	set.Add("Text", "xm yp+5 w215 h23 0x200", " " Chr(169) " Created by Runar ""Run1e"" Borge")
	set.Add("Button", "yp x230 h23 gDefault", "Defaults")
	set.Add("Button", "yp x302 h23 gSettingsSave", "Save")
	
	set.Add("Tab2", "xp yp w0 h0 -Wrap Choose1 AltSubmit", "1|2|3|4")
	set.Font("s10 Norm c000000")
	
	set.Margin(8, 6)
	
	set.Tab(1)    ; General
	set.Add("Groupbox", "x126 y-6 w220 h" height+11)
	set.Add("CheckBox", "x135 y10 Checked" Settings.StartUp, "Launch on Startup")
	set.Add("CheckBox", "Checked" Settings.UpdateCheck, "Check for Updates")
	set.Add("CheckBox", "Checked" Settings.RowSnap, "Enable RowSnap")
	set.Add("CheckBox", "Checked" Settings.FreqSort, "Sort items by popularity")
	set.Add("CheckBox", "Checked" Settings.Verify, "Verify Items")
	
	set.Tab(2)    ; Style
	set.Add("Groupbox", "x126 y-6 w220 h" height+11)
	set.Add("Text", "x135 y13", "Font:")
	set.Add("DropDownList", "yp-3 x170", fonts)
	set.Control("ChooseString", "ComboBox1", Settings.Font.Type)
	set.Add("Text", "x135 yp+42", "Size:")
	set.Add("Edit", "x170 yp-3 w45")
	set.Add("UpDown", "Range6-26", Settings.Font.Size)
	set.Add("CheckBox", "x238 yp-6 Checked" Settings.LargeIcons, "Large Icons")
	set.Add("CheckBox", "x238 yp+20 Checked" Settings.Font.Bold, "Bold")
	set.Add("Button", "gSelectColor x135 y85", "Change GUI Color")
	texthwnd := set.Add("Text", "yp+2 x260 0x200 h25 w75 Center", Settings.Color)
	CtlColors.Attach(texthwnd, 0x454545, "0x000000", "0x000000")
	
	set.Tab(3)    ; Hotkey
	set.Add("Groupbox", "x126 y-6 w220 h" height+11)
	set.Add("Text", "x135 y10", "Main Hotkey:")
	mainhwnd := set.Add("Hotkey", "", Settings.Hotkeys.Main)
	
	set.Tab(4)    ; Plugins
	set.Add("Groupbox", "x126 y-6 w220 h" height+11)
	set.Add("ListView", "-Hdr +Checked gSettingsLV x126 y2 w219 h" height+2, "Plugins")
	set.SetDefault()
	set.Options("ListView", "SysListView321")
	Plugin.UpdatePluginList()
	for a, b in xml.get("//plugins/plugin")
		LV_Add(b.run ? "Check" : "", b.name)
	LV_ModifyCol(1, "AutoHdr")
	
	set.Show("AutoSize")
	set.Control("focus", "Static1") ; change focus
	CtlColors.Change(men[1], "33b5e5", "F0F0F0")
	CtlColors.Change(texthwnd, Settings.Color, "FFFFFF")
	SetTimer, UpdatePluginList, 2500
	return
	
	Default:
	if (tab = 1) {
		set.Control(, "Button4", Settings.default.StartUp)
		set.Control(, "Button5", Settings.default.UpdateCheck)
		set.Control(, "Button6", Settings.default.RowSnap)
		set.Control(, "Button7", Settings.default.FreqSort)
		set.Control(, "Button8", Settings.default.Verify)
	} else if (tab = 2) {
		set.Control("ChooseString", "ComboBox1", Settings.default.Font.Type)
		set.Control(, "msctls_updown321", Settings.default.Font.Size)
		set.Control(, "Button10", Settings.default.LargeIcons)
		set.Control(, "Button11", Settings.default.Font.Bold)
		set.Control(, "Static14", Settings.default.Color)
		CtlColors.Change(texthwnd, Settings.default.Color, "FFFFFF")
	} else if (tab = 3) {
		set.Control(, "msctls_hotkey321", Settings.default.Hotkeys.Main)
		; set.Control(, "msctls_hotkey322", Settings.default.Hotkeys.Fokus)
	} else if (tab = 4) {
		Run(A_WorkingDir "\Plugins")
	}
	return
	
	SelectColor:
	set.Disable()
	ControlGetText, col, Static14, % set.ahkid
	if !((col := ColorPicker(col)).length) {
		WinActivate % set.ahkid
		return
	} WinActivate % set.ahkid
	CtlColors.Change(texthwnd, col, "FFFFFF")
	set.Control(, "Static14", col)
	set.Enable()
	return
	
	UpdatePluginList:
	if Plugin.UpdatePluginList() {
		set.SetDefault()
		LV_Delete()
		for a, b in xml.get("//plugins/plugin")
			LV_Add(b.run ? "Check" : "", b.name)
		LV_ModifyCol(1, "AutoHdr")
	} return
	
	Select:
	for a, b in arrMenu
		if (b = trim(A_GuiControl))
			tab := k := a
	if (k ~= "1|2|3|4")
		loop % arrMenu.MaxIndex()
			CtlColors.Change(men[A_Index], ((k = A_Index) ? "33b5e5" : "F0F0F0"), ((k = A_Index) ? "F0F0F0" : "000000"))
	set.Control("Choose", "SysTabControl321", k)
	if (tab = 4)
		set.Control(, "Button1", "Folder")
	else
		set.Control(, "Button1", "Defaults")
	return
	
	SettingsLV:
	if (A_GuiEvent = "DoubleClick") {
		LV_GetText(text, A_EventInfo)
		Run(A_WorkingDir "\Plugins\" text ".ahk")
	}
	return
	
	SettingsSave:
	set.Submit("NoHide")
	MainHotkey := set.GuiControlGet(, "msctls_hotkey321")
	; FokusHotkey := set.GuiControlGet(, "msctls_hotkey322")
	
	; sets the plugin states
	i:=0, arr:=[]
	while (i := LV_GetNext(i, "C")) {
		arr[i] := true
	} Loop % LV_GetCount() {
		LV_GetText(text, A_Index)
		xml.ssn("//plugins/plugin[@name='" text "']").SetAttribute("run", arr.HasKey(A_Index) ? true : false)
	} arr:=[]
	
	col := set.GetText("Static14")
	
	Settings.StartUp := set.ControlGet("Checked",, "Button4")
	Settings.UpdateCheck := set.ControlGet("Checked",, "Button5")
	Settings.RowSnap := set.ControlGet("Checked",, "Button6")
	FreqSort := set.ControlGet("Checked",, "Button7")
	Settings.Verify := set.ControlGet("Checked",, "Button8")
	
	Settings.Font := {Type:set.GetText("ComboBox1"), Size:set.GetText("Edit1"), Bold:set.ControlGet("Checked",, "Button11")}
	LargeIcons := set.ControlGet("Checked",, "Button10")
	
	Settings.Hotkeys := {Main:MainHotkey}
	
	set.Hide()
	Main.SetDefault()
	
	Main.Color(454545, col)
	Main.Font("Norm")
	Main.Font("s" Settings.Font.Size (Settings.Font.Bold ? " Bold" : ""), Settings.Font.Type)
	Main.Control("Font", "SysListView321")
	Main.Control("Font", "Edit1")
	Main.Font("s13")
	Main.Control("Font", "Edit1")
	
	if (Settings.FreqSort != FreqSort) || (Settings.LargeIcons != LargeIcons) {
		Settings.FreqSort := FreqSort
		Settings.LargeIcons := LargeIcons
		ItemList.Lists[Settings.List].Refresh() ; refresh list
		Main.SetText() ; refresh listview
		Main.SizeList()
		if Settings.RowSnap
			Main.RowSnap(Settings.Pos.Height)
	} 
	
	if (col != Settings.Color) {
		Settings.Color := col
		msgbox, 0, Restart, Restarting Columbus because of Color change., 2
		reload
	}
	
	SettingsClose:
	SetTimer, UpdatePluginList, Off
	for a, b in xml.get("//plugins/plugin") {
		if (A_Index = 1)
			pl := New Menu("Plugins"), add := true
		pl.Add(b.name)
	}
	if add {
		Tray.Delete("Plugins")
		Tray.Insert(Tray.Items.MaxIndex() - 1, pl)
	}
	CtlColors.Free()
	Hotkey.Bind(Settings.Hotkeys.Main, Main.Toggle.Bind(Main))
	Hotkey.Enable("~Ctrl Up")
	set.Destroy()
	Main.Enable()
	return
}