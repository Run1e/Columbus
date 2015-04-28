Update(notify := false) {
	static
	
	pastebin_url := "http://pastebin.com/raw.php?i=NwCdgRVy"
	
	Gui 5: Destroy
	Gui.Hide()
	Gui 2: Destroy
	Hotkey(Settings.Hotkey, "Off")
	Hotkey(Settings.WindowHotkey, "Off")
	
	; make sure pastebin is avaliable
	RunWait, ping.exe www.pastebin.com -n 1,, Hide UseErrorlevel
	if ErrorLevel {
		gosub UpdateEnd
		return PrintError("Update(): Update page unavaliable")
	} else
		Print("Update(): Checking for updates.." timer("update"))
	
	; download the pastebin file
	master := Send(pastebin_url)
	
	; "DOCTYPE" is usually in the string if something went wrong
	if (master.contains("DOCTYPE|<div>") || !master) {
		gosub UpdateEnd
		if notify
			Tray.Tip("Masterfile could not be fetched.", "Error")
		return PrintError("Update(): Masterfile could not be fetched")
	}
	
	; if we made it this far, we have the masterfile fetched succesfully!
	Print("Update(): Masterfile fetched successfully in " timer("update") "ms")
	
	; this part gets all the key/value pairs from the masterfile and also the feature list
	vars := [], new_feat:=""
	Loop, parse, master, % "`n", % "`r"
	{
		if (A_LoopField = "")
			continue
		if InStr(A_LoopField, "=")
			vars[SubStr(A_LoopField, 1, InStr(A_LoopField, "=") - 1)] := SubStr(A_LoopField, InStr(A_LoopField, "=") + 1)
		else {
			if RegExMatch(A_LoopField, "\d\.\d\d:") {
				ver := SubStr(A_LoopField, 1, -1)
				continue
			} if (ver > AppVersion)
				new_feat .= A_LoopField "`n"
		}
	}
	
	; if ahk is installed & the docslist is outdated, download the new one
	if A_AhkPath {
		FileReadLine, docsversion, docslist.ini, 1
		if (docsversion < vars["docsver"])
			FileDelete docslist.ini
		if !FileExist("docslist.ini") {
			Print("Update(): Updating docslist [" (docsversion ? docsversion : "NONE") " -> " vars["docsver"] "]")
			FileAppend % vars["docsver"] "`r`n" Send(vars["docs"]), docslist.ini
		}
	}
	
	; if blablabla, show the update gui
	if (vars["version"] > AppVersion) && (Settings.LastUpdatePrompt <> (notify ? 0 : vars["version"])) {
		Print("Update(): Showing update prompt for update [" AppVersion " -> " vars["version"] "]")
		Gui 5: Add, Text,, A new update is avaliable!
		Gui 5: Font, s12
		Gui 5: Add, Text,, % "New version: " vars["version"]
		Gui 5: Font, s9
		if A_AhkPath {
			Gui 5: Add, Text,, Download as:
			Gui 5: Add, Radio, % "vDownloadFileExt Checked" (Settings.DownloadFileExt = "exe" ? 1 : 0), exe
			Gui 5: Add, Radio, % "x55 yp Checked" (Settings.DownloadFileExt = "ahk" ? 1 : 0), ahk
		} Gui 5: Add, Button, yp-8 x373 gUpdateUpdate, Update
		Gui 5: Add, Button, yp xp+60 gUpdateCancel, Not now
		Gui 5: Add, Edit, w480 x5 h125 ReadOnly c505050, % new_feat
		Gui 5: Show, w500, %AppName% Updater
	} else {
		Print("Update(): No updates found (" AppVersion " -> " vars["version"] ")")
		if notify
			Tray.Tip("No updates found.")
		gosub UpdateEnd
	} return
	
	; update!
	UpdateUpdate:
	Gui 5: Submit, NoHide
	if (!A_AhkPath && DownloadFileExt = 2) {
		MsgBox, 4, Warning, % "You have selected to download as an AHK file, but you do not have AHK installed.`n`nDo you want to download as an EXE instead?"
		ifMsgBox yes
			DownloadFileExt := 1
	} Gui 1: Destroy
	Gui 2: Destroy
	Gui 5: Destroy
	Settings.Write("DownloadFileExt", (DownloadFileExt = 1 ? "exe" : "ahk"))
	Print("Update(): Starting update [" AppVersion " -> " vars["version"] "] as " Settings.DownloadFileExt)
	if (Settings.DownloadFileExt = "exe") {
		Tray.Tip("Downloading update.. (might take a few seconds)")
		UrlDownloadToFile % vars["exe"], download
	} else
		FileAppend % Send(vars["ahk"]), download
	FileMove, % A_ScriptFullPath, old
	FileMove, download, % A_ScriptDir "\" AppName "." Settings.DownloadFileExt
	sleep 200
	run % A_ScriptDir "\" AppName "." Settings.DownloadFileExt,, UseErrorLevel
	if (ErrorLevel = "ERROR") {
		FileDelete % A_ScriptDir "\" AppName "." Settings.DownloadFileExt
		FileMove old, % A_ScriptFullPath
		Tray.SetTimout(4)
		Tray.Tip("Download failed.. restarting Columbus..", "ERROR")
		while Tray.IsVisible
			continue
		reload
	} ExitApp
	return
	
	; cancel! (and write to LastUpdatePrompt)
	UpdateCancel:
	Settings.Write("LastUpdatePrompt", vars["version"])
	5GuiEscape:
	5GuiClose:
	UpdateEnd:
	Gui 5: Destroy
	Hotkey(Settings.Hotkey, "On")
	Hotkey(Settings.WindowHotkey, "On")
	Gui 1: -Disabled
	GuiControl 1: Focus, Edit1
	return
}