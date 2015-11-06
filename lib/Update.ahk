Update(notify := false, force := false) {
	static
	
	if WinExist(upd.ahkid) && upd.ahkid
		return
	
	Main.Hide()
	Hotkey.Disable(Settings.Hotkeys.Main)
	
	url := "http://runie.me/Columbus/"	
	
	master := Send(url . "Columbus.text")
	
	if (master.contains("DOCTYPE", "<div>") || !master.length) {
		if notify
			Notify.Tip("Failed fetching changelog file..")
		gosub UpdateClose
		return
	}
	
	new_version := trim(master.split("`n")[1], "`r")
	
	if force {
		gosub UpdateUpdate
		return
	}
	
	if (new_version > version) && (new_version <> (notify ? 0 : Settings.LastUpdatePrompt)) { ; new unnotified update! set up the gui!!!!!!
		upd := New Gui("Columbus Updater")
		upd.Add("Text",, "A new update is avaliable!")
		upd.Font("s12")
		upd.Add("Text",, "Newest version: " new_version)
		upd.Font("s9")
		if FileExist(A_AhkPath) {
			upd.Add("Text",, "Download as:")
			upd.Add("Radio", "Checked" (Settings.UpdateExt = "exe" ? 1 : 0), "exe")
			upd.Add("Radio", "x55 yp Checked" (Settings.UpdateExt = "ahk" ? 1 : 0), "ahk")
		} upd.Add("Button", "yp-8 x373 gUpdateUpdate", "Update")
		upd.Add("Button", "yp xp+60 gUpdateCancel", "Not now")
		upd.Add("Text", "x8 yp+35", "New features since last update:")
		Loop, parse, master, % "`n" ; parse to get all new features
		{
			if (trim(A_LoopField, "`r") = version)
				break
			else if (trim(A_LoopField, "`r").type = "integer")
				continue
			else
				changes .= " - " A_LoopField "`n"
		}
		upd.Add("Edit", "w480 x5 h125 ReadOnly c505050", changes), changes := ""
		upd.Add("Link", "", "<a href=""" url "Columbus.text" """>Read the changelog online</a>")
		upd.Control("focus", "Static1")
		upd.Options("")
		upd.Show("NoActivate")
		upd.SetEvents({Escape:"UpdateCancel", Close:"UpdateCancel"})
	} else {
		if notify
			Notify.Tip("No new updates!")
		gosub UpdateClose
	}
	return
	
	UpdateUpdate:
	ControlGet, exe, Checked,, Button1, % upd.ahkid
	upd.Destroy(), Main.Destroy(), upd:=Main:=""
	Tray.SetTimeout(999)
	Notify.Tip("Downloading update..")
	if force
		exe := (Settings.UpdateExt = "exe")
	else {
		if (!A_AhkPath.length && !exe) {
			MsgBox, 4, Warning, % "You have selected to download as an AHK file, but you do not have AHK installed.`n`nDo you want to download as an EXE instead?"
			ifMsgBox yes
				exe := true
		} Settings.UpdateExt := (exe ? "exe" : "ahk")
	} if exe
		UrlDownloadToFile % url . "Columbus.exe", download
	else
		FileAppend % Send(url . "Columbus.ahk"), download
	FileMove, % A_ScriptFullPath, old
	FileMove, download, % A_ScriptDir "\Columbus." Settings.UpdateExt
	sleep 200
	run % A_ScriptDir "\Columbus." Settings.UpdateExt,, UseErrorLevel
	if (ErrorLevel = "ERROR") {
		FileDelete % A_ScriptDir "\Columbus." Settings.UpdateExt
		FileMove old, % A_ScriptFullPath
		Tray.SetTimout(3)
		Notify.Tip("Error", "Download failed.. restarting Columbus..")
		while Tray.IsVisible
			continue
		reload
	} ExitApp
	return
	
	UpdateCancel:
	Settings.LastUpdatePrompt := RTrim(new_version, 0)
	UpdateClose:
	Hotkey.Enable(Settings.Hotkeys.Main)
	upd.Destroy(), upd:=changes:=""
	return
}