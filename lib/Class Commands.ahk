Class Commands {
	static List := [ "manager - open the item manager"
				, "settings - open the settings menu"
				; , "docs - search through the AHK documentation"
				, "g/w - google/wolfram search"
				, "move - drag and resize the window"
				, "update - check for updates"
				; , "specs - systeminfo (beta)"
				, "about - about Columbus"
				, "reset - reset everything"
				, "exit - exit the program"]
	
	test() {
		
	}
	
	listvars() {
		listvars
	}
	
	refresh() {
		ItemList.Lists[Settings.List].Search(), Main.SetText()
	}
	
	reload() {
		reload
	}
	
	lice() {
		run C:\Program Files (x86)\LICEcap\licecap.exe
	}
	
	rel(gui := false) {
		reload
	}
	
	set(key, value) {
		if !key.length || !value.length
			return
		if key.find(".") {
			node := key.split(".")[1]
			att := key.split(".")[2]
			if (xml.ea(n := xml.ssn("//settings/" node))[att] != "")
				n.SetAttribute(att, value)
			else
				return m("The key '" key "' doesn't appear to exist`nHere's a list of keys and their values:`n`n" Settings[])
		} else if xml.ssn("//settings/" key).text.length && value.length
			Settings[key] := value
		else
			return m("The key '" key "' doesn't appear to exist`nHere's a list of keys and their values:`n`n" Settings[])
	}
	
	def(key) {
		Settings[key] := Settings.default[key]
	}
	
	pset() {
		m(Settings[])
	}
	
	hotkeys() {
		m(Hotkey[])
	}
	
	xml() {
		m(xml[])
	}
	
	dir() {
		run % A_WorkingDir
	}
	
	icon() {
		UrlDownloadToFile, http://runie.me/Columbus/Columbus.ico, icon.ico
		reload
	}
	
	tip(msg) {
		Tray.Tip(msg)
	}
	
	endtip() {
		Tray.Destroy()
	}
	
	g(search*) {
		for a, b in search
			c .= b " "
		Main.Hide()
		run("https://www.google.com/?q=" UriEncode(SubStr(c, 1, -1)))
	}
	
	w(search*) {
		for a, b in search
			c .= b " "
		Main.Hide()
		run("http://www.wolframalpha.com/input/?i=" UriEncode(SubStr(c, 1, -1)))
	}
	
	move(res := false) {
		if (res = true)
			MenuHandler("Tray", "Reset GUI position")
		else
			Main.Move()
	}
	
	update(force := false) {
		Update(true, force)
	}
	
	reset(force := false) {
		if !force {
			MsgBox, 4, WARNING, Proceeding will reset every aspect of the program.`n`nContinue?
			ifMsgBox no
				return
		} FileDelete, Columbus.xml
		xml := "" ; destroy xml object so it doesn't write anything at exit
		reload
	}
	
	manager() {
		Manager()
	}
	
	repwin() { ; places window in the top-left corner
		Settings.Pos := {X:5, Y:5, Width:500, Height:355}
		Main.Pos(Settings.Pos.X, Settings.Pos.Y, Settings.Pos.Width, Settings.Pos.Height)
	}
	
	settings() {
		Settings()
	}
	
	uninstall() {
		Main.Hide(), Fokus.Hide()
		MsgBox, 4, WARNING, Are you sure you want to uninstall Columbus?`n`nEverything related to Columbus will be removed.
		ifMsgBox no
			return Tray.Tip("Phew, that was close.")
		Plugin.Exit()
		FileDelete % A_Desktop "\Columbus.lnk"
		RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, Columbus
		Loop % A_WorkingDir "\Plugins\*.*"
		{
			MsgBox, 4, WARNING, Delete plugins?
			ifMsgBox yes
				FileRemoveDir % A_WorkingDir "\Plugins", 1
			else {
				FileMoveDir, % A_WorkingDir "\Plugins", % A_Desktop "\Plugins"
				m("Files in Columbus\Plugins has been moved to Desktop\Plugins")
			} break
		} FileMove % A_ScriptFullPath, % A_Temp "\Columbus." (A_IsCompiled ? "exe" : "ahk"), 1
		FileRemoveDir % A_ProgramFiles "\Columbus", 1
		MsgBox, 4, WARNING, Remove main file? (Columbus.exe/ahk)
		ifMsgBox yes
			FileDelete % A_Temp "\Columbus." (A_IsCompiled ? "exe" : "ahk")
		else {
			FileMove % A_Temp "\Columbus." (A_IsCompiled ? "exe" : "ahk"), % A_Desktop "\Columbus." (A_IsCompiled ? "exe" : "ahk"), 1
			m("Main file copied to desktop")
		} ExitApp
	}
	
	exit() {
		ExitApp
	}
	
	about() {
		static ab
		Main.Hide()
		ab := New Gui("About")
		ab.Color(383838, 454545)
		ab.Font("s12")
		ab.Add("Text", "x10 w200 Center cWhite", "Columbus version " version)
		ab.Font("s9")
		ab.Add("Link", "w200 x10 yp+34 Center", "<a href=""http://www.autohotkey.com/board/topic/108566-columbus-a-fast-program-launcher-and-focus-switcher/"">AutoHotkey.com thread</a>")
		ab.Add("Link", "w200 yp+22 Center", "<a href=""http://ahkscript.org/boards/viewtopic.php?f=6&t=3478"">AHKScript.org thread</a>")
		ab.Add("Link", "w200 yp+22 Center", "<a href=""https://github.com/Run1e/Columbus"">GitHub.com repo</a>")
		ab.Add("Link", "w200 yp+22 Center", "<a href=""https://github.com/Run1e/Columbus/wiki"">GitHub.com wiki</a>")
		ab.Add("Text", "w200 x10 yp+30 Center cWhite", "Thanks to maestrith, jNiZm, tidbit, GeekDude, BigVent && the rest of you.")
		ab.Add("Text", "x10 w200 yp+44 Center cWhite", "Written by Runar ""Run1e"" Borge")
		ab.Font("s7")
		ab.Add("Text", "x10 w200 yp+20 Center cWhite", "If you have any questions, you can contact me at runar-borge@hotmail.com")
		ab.Options("-0x20000")
		ab.Show()
		ab.Control("focus", "Columbus")
		ab.SetEvents({Close:"aboutclose", Escape:"aboutclose"})
		return
		
		aboutclose:
		ab.Destroy(), ab := ""
		return
	}
}