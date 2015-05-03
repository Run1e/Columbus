class Commands {
	__New() {
	}
	
	__Call(command) {
		if !IsFunc(this[command]) {
			if FileExist("commands\" (cmd_file := SubStr(command, 1, InStr(command, " ") ? InStr(command, " ") - 1 : command.length)) ".ahk") || FileExist("commands\" cmd_file ".exe") {
				arg := SubStr(command, cmd_file.length + 2)
				if FileExist("commands\" cmd_file ".ahk")
					run(A_WorkingDir "\commands\" cmd_file ".ahk", arg)
				else if FileExist("commands\" cmd_file ".exe")
					run(A_WorkingDir "\commands\" cmd_file ".exe", arg)
			}
		} if command.equals("reload|rel")
			reload
	}
	
	settings() {
		Settings()
	}
	
	manager() {
		Gui.Hide()
		Manager()
	}
	
	bug() {
		Gui.Hide()
		BugReport()
	}
	
	move() {
		Gui.Move()
	}
	
	update() {
		Update(true)
	}
	
	tips() {
		Tray.Tip("Command has not been implemented yet.")
	}
	
	reset() {
		MsgBox, 4, WARNING, Proceeding will reset every aspect of the program.`n`nContinue?
		ifMsgBox no
			return
		FileDelete items.ini
		FileDelete del_items.ini
		LV_Delete()
		Gui.Hide()
		Settings.Default()
		Item.Search()
		list(true)
		Gui.Show()
		input()
	}
	
	about() {
		static HWND_ABOUT
		Gui.Hide()
		if WinExist("ahk_id" HWND_ABOUT) {
			WinActivate, % "ahk_id" HWND_ABOUT
			return
		} Gui 8: Color, 383838, 454545
		Gui 8: Font, s12
		Gui 8: Add, Text, x10 w200 Center cWhite, Columbus v%AppVersion%
		Gui 8: Font, s9
		Gui 8: Add, Link, w200 x10 yp+34 Center, <a href="http://www.autohotkey.com/board/topic/108566-columbus-a-fast-program-launcher-and-focus-switcher/">AutoHotkey.com thread</a>
		Gui 8: Add, Link, w200 yp+22 Center, <a href="http://ahkscript.org/boards/viewtopic.php?f=6&t=3478">AHKScript.org thread</a>
		Gui 8: Add, Text, w200 x10 yp+30 cWhite, Thanks to tidbit, GeekDude, maestrith, BigVent && the rest of you.
		Gui 8: Add, Text, x10 w200 yp+44 Center cWhite, Written by Runar "Run1e" Borge
		Gui 8: Font, s7
		Gui 8: Add, Text, x10 w200 yp+20 Center cWhite, If you have any questions, please contact me at runar-borge@hotmail.com
		Gui 8: +hwndHWND_ABOUT -0x20000
		Gui 8: Show,, About
		GuiControl 8: focus, Columbus v
		return
		
		8GuiEscape:
		Gui 8: Destroy
		return
	}
	
	uninstall() {
		Gui.Hide()
		MsgBox, 4, WARNING, Are you sure you want to uninstall %AppName%?`n`nEverything related to Columbus will be removed.
		ifMsgBox no
			return Tray.Tip("Phew, that was close.")
		RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, % AppName
		temp := A_WorkingDir
		SetWorkingDir, C:\
		Loop
			FileRemoveDir % temp, 1
		until !ErrorLevel
		MsgBox, 4, WARNING, Remove main file (%A_ScriptName%)?
		ifMsgBox yes
			FileDelete % A_ScriptFullPath
		ExitApp
	}
	
	Exit() {
		if A_ScriptName.EndsWith("exe") ; 4 u xZomBie <3
			Process, Close, % A_ScriptName
		ExitApp
	}
	
	mail() {
		try
			run mailto:runar-borge@hotmail.com?subject=Columbus - for developer&body=
		catch
			return PrintError("Commands.mail(): No software association with mailto:") Tray.Tip("No mail software installed.")
	}
	
	listvars() {
		ListVars
	}
	
	set(text) {
		a := text.split(" ")
		Settings.Write(a[1], a[2])
	}
	
	run(text) {
		if (r := RunFunc(text))
			Tray.Tip(r)
	}
	
	specs() {
		Gui.Hide()
		Specs()
	}
}