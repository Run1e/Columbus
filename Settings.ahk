Settings() {
	static
	if WinExist("ahk_id" HWND_SETTINGS) {
		Gui 3: Show
		return
	} Gui 2: Destroy
	Gui.Hide()
	Hotkey(Settings.Hotkey, "Off")
	Hotkey(Settings.WindowHotkey, "Off")
	Gui 3: Add, Text,, Hotkey:
	Gui 3: Add, Hotkey, vHotkey, % Settings.Hotkey
	Gui 3: Add, Text,, WindowSwitcher Hotkey:
	Gui 3: Add, Hotkey, vWindowHotkey, % Settings.WindowHotkey
	Gui 3: Add, CheckBox, % "vStartUp Checked" Settings.StartUp, Launch at startup
	Gui 3: Add, CheckBox, % "vUpdateCheck Checked" Settings.UpdateCheck, Check for updates
	Gui 3: Add, CheckBox, % "vSortByPopularity Checked" Settings.SortByPopularity, Sort by popularity
	Gui 3: Add, Text, % "yp+23", Scan every
	Gui 3: Add, Edit, % "vScanTime yp-2 x72 w30", % Settings.ScanTime
	Gui 3: Add, Text, % "yp+2 x108", mins
	Gui 3: Add, Text, x10, Download updates as:
	Gui 3: Add, Radio, % "vDownloadFileExt Checked" (Settings.DownloadFileExt = "exe" ? 1 : 0), exe
	Gui 3: Add, Radio, % "yp x70 Checked" (Settings.DownloadFileExt = "ahk" ? 1 : 0), ahk
	Gui 3: Add, Button, gSettingsDefaults x10, Defaults
	Gui 3: Add, Button, gSettingsSave yp x85, Save
	Gui 3: -0x20000 +hwndHWND_SETTINGS
	Gui 3: Show,, Settings
	GuiControl 2: Focus, Static1
	return
	
	SettingsSave:
	Gui 3: Submit, NoHide
	if (Hotkey = WindowHotkey) {
		Tray.Tip("Hotkeys have to be unique.", "Error")
		return PrintError("Settings(): Duplicated hotkey, can't save")
	} else if (ScanTime < 1) || (ScanTime.type <> "integer") {
		Tray.Tip("Scan time has to be a number above 1.")
		return PrintError("Settings(): ScanTime below 1 or invalid input.")
	} pHotkey := Settings.Hotkey
	pWindowHotkey := Settings.WindowHotkey
	Settings.Write("Hotkey", Hotkey)
	Settings.Write("WindowHotkey", WindowHotkey)
	Settings.Write("ScanTime", ScanTime)
	Settings.Write("SortByPopularity", SortByPopularity)
	Settings.Write("StartUp", StartUp)
	Settings.Write("UpdateCheck", UpdateCheck)
	Settings.Write("DownloadFileExt", (DownloadFileExt = 1 ? "exe" : "ahk"))
	Hotkey(Settings.Hotkey, (Settings.Hotkey = pHotkey ? "On" : "GuiToggle"))
	Hotkey(Settings.WindowHotkey, (Settings.WindowHotkey = pWindowHotkey ? "On" : "WindowSwitcher"))
	list(true)
	GuiControl 1:, input, % ""
	
	3GuiEscape:
	3GuiClose:
	Hotkey(Settings.Hotkey, "On")
	Hotkey(Settings.WindowHotkey, "On")
	Gui 3: Destroy
	return
	
	SettingsDefaults:
	GuiControl 3:, msctls_hotkey321, % Settings.defaults["Hotkey"]
	GuiControl 3:, msctls_hotkey322, % Settings.defaults["WindowHotkey"]
	GuiControl 3:, Button1, % Settings.defaults["StartUp"]
	GuiControl 3:, Button2, % Settings.defaults["UpdateCheck"]
	GuiControl 3:, Button3, % Settings.defaults["SortByPopularity"]
	GuiControl 3:, Edit1, % Settings.defaults["ScanTime"]
	GuiControl 3:, % "Button" . (Settings.defaults["DownloadFileExt"] = "exe" ? 3 : 4), 1
	return
}