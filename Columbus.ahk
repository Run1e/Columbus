#SingleInstance force
#MaxHotkeysPerInterval 200
#NoTrayIcon
#NoEnv
SetBatchLines, -1
SetControlDelay, -1
SetKeyDelay, -1
SetWinDelay, -1
SetRegView 64
CoordMode, ToolTip, Screen()
Menu, Tray, Icon
timer("startup")

; make objects and other things
global AppName := "Columbus"
global AppVersion := 0.60
global Gui := new MainGui()
global cmd := new Commands()
global Settings := new Settings("settings")
global Item := new ItemHandler()
global Tray := new Tray()
global ImageList
	,  HWND_MAIN
	,  HWND_MAIN_LISTVIEW
	,  HWND_MAIN_INPUT
	,  HWND_MAIN_TOGGLE

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x4a, "Receive")

if !FileExist(A_Appdata "\" AppName)e
	FileCreateDir % A_Appdata "\" AppName
SetWorkingDir % A_AppData "\" AppName

if !FileExist(A_WorkingDir "\commands\")
	FileCreateDir % A_WorkingDir "\commands\"

if !FileExist("settings.ini")
	Settings.Default()
Settings.Read()

Print(AppName " v" AppVersion " created by Runar ""Run1e"" Borge`n")

if FileExist("old") {
	Tray.Tip("Successfully updated to v" AppVersion)
	FileDelete old
}

Menu, Tray, NoStandard

; set up string functions/properties
"".base.__Get := Func("String_PseudoProperties")
"".base.find := Func("String_Find")
"".base.split := Func("String_Split")
"".base.equals := Func("String_Equals")
"".base.contains := Func("String_Contains")
"".base.endsWith := Func("String_EndsWith")
"".base.startsWith := Func("String_StartsWith")

Item.Search()
Item.Verify()

if Settings.StartUp
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, % AppName, % A_ScriptFullPath
else
	RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, % AppName

Menu, Tray, Add, Show %AppName%, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Settings, MenuHandler
Menu, Tray, Add, Manager, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Reset GUI position, MenuHandler
Menu, Tray, Add, Report a bug, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Check for updates, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 2
Menu, Tray, Default, Show %AppName%

if (!FileExist(A_WorkingDir "\ico.ico") && !A_IsCompiled) {
	Print("Autoexecute section: Downloading icon")
	URLDownloadToFile, http://runie.me/dl/ico.ico, % A_WorkingDir "\ico.ico"
}

if FileExist(A_WorkingDir "\ico.ico") && !A_IsCompiled
	Menu, Tray, Icon, % A_WorkingDir "\ico.ico"

Gui Font, s13 cWhite Q1, Candara
Gui Color, 454545, 383838
Gui Margin, 0, 0

Gui Add, ListView, gListAction hwndHWND_MAIN_LISTVIEW -Grid -LV0x10 +LV0x20 -E0x200 +LV0x100 -TabStop -Hdr -Multi +AltSubmit, Result|Score|Contains|Abbreviation|Beginning|spacer
Gui Font, italic
Gui Add, Edit, % "w" Settings.Width - 100 " y" Settings.Height - 25 " h25 x0 vinput hwndHWND_MAIN_INPUT gEditAction"
Gui Font, -italic
Gui Add, Text, % "w39 h23 yp gCMDtoggle vtoggle hwndHWND_MAIN_TOGGLE Center", CMD
Gui Add, Text, x5 y5 w204 Center, Press Escape to save position
GuiControl hide, Static2
Gui -0x20000 -Caption +LastFound +ToolWindow -Resize +MinSize300x200 +hwndHWND_MAIN +OwnDialogs +Border -DPIScale +AlwaysOnTop
Gui Show, % "x" Settings.X " y" Settings.Y " w" Settings.Width " h" Settings.Height " hide", % AppName

LV_ModifyCol(1, Settings.Width - 18)
Loop 5
	LV_ModifyCol(A_Index + 1, "Integer"), LV_ModifyCol(A_Index + 1, 0)

Hotkey(Settings.Hotkey, "GuiToggle")
Hotkey(Settings.WindowHotkey, "WindowSwitcher")
Hotkey("Enter", "Hotkey", HWND_MAIN)
Hotkey("Delete", "Hotkey", HWND_MAIN)
Hotkey("TAB", "Hotkey", HWND_MAIN)
Hotkey("Enter", "Hotkey", HWND_MAIN)
Hotkey("Escape", "Hotkey", HWND_MAIN)
Hotkey("^Backspace", "Hotkey", HWND_MAIN)
Hotkey("^Z", "Hotkey", HWND_MAIN)
Hotkey("MButton", "Hotkey", HWND_MAIN)
Hotkey("WheelUp", "Hotkey", HWND_MAIN)
Hotkey("WheelDown", "Hotkey", HWND_MAIN)
Hotkey("Up", "Hotkey", HWND_MAIN)
Hotkey("Down", "Hotkey", HWND_MAIN)

if Settings.UpdateCheck
	Update()

list(true) ; create the program list
input() ; populate the listview
SetTimer, ScanTimer, % Settings.ScanTime * 1000 * 60
Print("Autoexecute section finished in " timer("startup") "ms")
return

; Hotkey handler
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

; Input handler
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

; you're not expected to understand this
FuzzySort(needle := "", arr := "", ForceSequential := false) {
	list := []
	for i, b in arr {
		score:=prefound:=0, pos:=1, approx:=b.name
		Loop % needle.length {
			if !ForceSequential
				if (muddy := InStr(approx, SubStr(needle, A_Index, 1)))
					approx := SubStr(approx, 1, muddy - 1) . SubStr(approx, muddy + 1)
			if (found := InStr(SubStr(b.name, pos), SubStr(needle, A_Index, 1)))
				pos += found, score += prefound - found, prefound := found * -1
			else if (!muddy)
				break
			if (A_Index = needle.length) {
				list[i, "name"] := b.name
				list[i, "icon"] := b.icon
				list[i, "score"] := score * -1
				list[i, "contains"] := !!InStr(b.name, needle)
				for x, v in StrSplit(needle)
					temp .= v ".*?\s+"
				list[i, "abbreviation"] := !!RegExMatch(b.name, "i)" SubStr(temp, 1, -6)) || InStr(RegExReplace(b.name, "[^A-Z]"), needle)
				beg := InStr(b.name, needle)
				list[i, "beginning"] := (beg = 1) || (SubStr(b.name, beg - 1, 1) = " ")
				temp:=""
			}
		}
	} return list
}

; List action handler
ListAction(GuiEvent) {
	if (GuiEvent = "Normal") || (GuiEvent = "RightClick")
		GuiControl 1: focus, input
	if (GuiEvent = "DoubleClick")
		Hotkeys("Enter") ; we want to simulate an "enter" click.
	LV_GetText(text, 1)
	if (text = "AHK Documentation:") {
		LV_GetText(text, LV_GetNext())
		WinGetPos, x, y,,, ahk_id%HWND_MAIN%
		if (desc := IniRead("docslist", text, "desc"))
			ToolTip % desc, x, y - 25
		else
			ToolTIp
	} else
		ToolTip
}

; Menu handler
MenuHandler(menuitem) {
	if (menuitem = "Show " AppName) {
		Gui.Toggle()
	} else
		
	if (menuitem = "Settings") {
		Settings()
	} else
		
	if (menuitem = "Manager") {
		Manager()
	} else
		
	if (menuitem = "Reset GUI position") {
		Gui.Reset()
	} else
		
	if (menuitem = "Check for updates") {
		Update(true)
	} else
		
	if (InStr(menuitem, "Bug")) {
		BugReport()
	}
}

; Command handler
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
		}
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
	
	reload() {
		reload
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
	
	Uninstall() {
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

; Used to manage hotkeys
Hotkey(key, label := "", hwnd := "") {
	if hwnd
		Hotkey, IfWinActive, % "ahk_id" hwnd
	else
		Hotkey, IfWinActive
	if key
		Hotkey, % key, % label, UseErrorLevel
	if ErrorLevel
		PrintError("Hotkey(): Failed assignment: " key " - " label " - " hwnd)
}

; Either refreshes [the whole array] or deletes a key in the array and always returns it
list(refresh := false, remove := "") {
	static list
	if remove {
		tmp := list, list := []
		for a, b in tmp
			if (b.name <> remove) {
			i++
			list[i, "name"] := b.name
			list[i, "icon"] := b.icon
			list[i, "freq"] := b.freq
			list[i, "priv"] := b.priv
		}
		return list
	} if !refresh
		return list
	Gui, +hwndhwnd
	Gui 1: Default
	IL_Destroy(ImageList)
	list := []
	LV_SetImageList(ImageList := IL_Create(LV_GetCount()))
	tmp := IniRead("items")
	if Settings.SortByPopularity {
		Loop, parse, tmp, % "`n", % "`r"
			items .= IniRead("items", A_LoopField, "freq") " " A_LoopField "`n"
		Sort, items, NR
		items := SubStr(items, 1, -1)
	} else
		items := tmp
	Loop, parse, items, % "`n", % "`r"se
	{
		i++
		tmp := (Settings.SortByPopularity ? SubStr(A_LoopField, InStr(A_LoopField, " ") + 1) : A_LoopField)
		list[i, "name"] := br(tmp)
		if ((icon := IL_Add(ImageList, IniRead("items", tmp, "icon"))) = 0)
			icon := IL_Add(ImageList, IniRead("items", tmp, "dir"))
		list[i, "icon"] := icon
		list[i, "freq"] := IniRead("items", tmp, "freq")
		list[i, "priv"] := IniRead("items", tmp, "priv")
	} Menu, Tray, Tip, Columbus v%AppVersion%`nTotal items: %i% ; update the traytip information
	Gui %hwnd%: Default
	return list
}

BugReport() {
	static
	if WinExist("ahk_id" HWND_BUG) {
		WinActivate
		return
	} Gui 6: Color, 383838, 454545
	Gui 6: Margin, 5, 10
	Gui 6: Font, s9
	Gui 6: Add, Text, cWhite y8, Email: (optional)
	Gui 6: Add, Edit, cWhite vemail w200 yp+20 hwndlol Limit50
	Gui 6: Add, Text, cWhite, Description:
	Gui 6: Add, Edit, cWhite vdesc gBugDescLabel w300 r10 Limit800 yp+20
	Gui 6: Add, CheckBox, cWhite vsendsettingssummary hwndHWND_BUG_CHECK1 Checked1, Send settings file
	Gui 6: Add, CheckBox, cWhite vsenditemlist yp x150 hwndHWND_BUG_CHECK2, Send program file
	AddToolTip(HWND_BUG_CHECK1, "Send your current settings file")
	AddToolTip(HWND_BUG_CHECK2, "Send the files containing the program information for Columbus")
	Gui 6: Add, Text, cWhite x5 yp+26, % "USER: " SubStr(A_ComputerName, 1, 7) ".. (v" AppVersion ", DEBUG: " Settings.Debug ")"
	Gui 6: Add, Button, gBugCancel x211 yp-5, Cancel
	Gui 6: Add, Button, gBugSend x265 yp Disabled, Send
	Gui 6: -0x20000 hwndHWND_BUG
	Gui 6: Show, h280, Bug report form
	GuiControl 6: focus, Edit2
	return
	
	BugDescLabel:
	Gui Submit, NoHide
	if (desc.length > 5)
		GuiControl 6: Enable, Button4
	else
		GuiControl 6: Disable, Button4
	return
	
	BugSend:
	Gui Submit, NoHide
	GuiControl 6:, Static3, Sending..
	resp := Send("http://runie.me/bugreport.php", "desc=" UriEncode(desc)
				. "&name=" UriEncode(A_ComputerName)
				. "&email=" (email ? UriEncode(email) : "Disabled")
				. "&version=" AppVersion
				. "&settings=" (sendsettingssummary ? UriEncode(FileRead("settings.ini")) : "Disabled")
				. "&itemlist=" (senditemlist ? UriEncode(FileRead("items.ini")) : "Disabled")
				. "&deleteditemlist=" (senditemlist ? UriEncode(FileRead("deleted_items.ini")) : "Disabled"))
	if (resp <> "failed") {
		GuiControl 6:, Static3, Success!
		sleep 500
		gosub BugCancel
		Tray.Tip("Thank you for contributing to making Columbus better!")
	} else {
		GuiControl 6:, Static3, Failed! (ERROR: %resp%)
	} return
	
	BugCancel:
	6GuiClose:
	6GuiEscape:
	Gui 6: Destroy
	return
}

WindowSwitcher() {
	static
	if WinExist("ahk_id" HWND_SWITCHER) {
		Gui 2: Show
		return
	} Hotkey(Settings.Hotkey, "Off")
	Hotkey(Settings.WindowHotkey, "2GuiEscape")
	Gui 2: Font, cWhite s11
	Gui 2: Color, 454545, 454545
	Gui 2: Add, Button, Hidden gQuickSubmit Default
	Gui 2: Add, Edit, x0 y0 w505 h25 vQuickInput gQuickAction
	Gui 2: Add, ListView, x-3 y25 w508 h9999 gQuickListView -Grid -LV0x10 +LV0x20 -E0x200 +LV0x100 -TabStop -Hdr -Multi +AltSubmit, Result|Rating|contains|beginning
	Gui 2: -Caption +AlwaysOnTop +Border +hwndHWND_SWITCHER +ToolWindow
	Gui 2: Default
	Hotkey("Up", "QuickScroll", HWND_SWITCHER)
	Hotkey("Down", "QuickScroll", HWND_SWITCHER)
	Hotkey("WheelUp", "QuickScroll", HWND_SWITCHER)
	Hotkey("WheelDown", "QuickScroll", HWND_SWITCHER)
	Hotkey("Delete", "QuickClose", HWND_SWITCHER)
	Hotkey("^Backspace", "QuickBackspace", HWND_SWITCHER)
	LV_ModifyCol(1, 508)
	LV_SetImageList(QuickImageList := IL_Create(8))
	WinGet, processlist, list
	process := []
	loop % processlist {
		WinGetTitle, name, % "ahk_id" processlist%A_Index%
		WinGet, path, ProcessPath, % name
		if (name <> "")  && (!name.equals("Start|WindowSwitcher|Program Manager") && !name.contains("Columbus.exe")) {
			process[A_Index, "name"] := name
			process[A_Index, "icon"] := IL_Add(QuickImageList, path)
		}
	}
	
	; runs when something is typed into the edit control
	QuickAction:
	Gui Submit, NoHide
	2resort:
	LV_Delete()
	for a, b in (QuickInput ? FuzzySort(QuickInput, process, Settings.ForceSequential) : process)
		LV_Add("Icon" . b.icon, b.name, b.score, b.contains, b.abbreviation, b.beginning)
	ControlGetText, temp, Edit1, WindowSwitcher
	if (temp <> QuickInput) {
		QuickInput := temp
		gosub 2resort
		return
	} LV_ModifyCol(2, "Sort")
	LV_ModifyCol(3, "SortDesc")
	LV_ModifyCol(5, "SortDesc")
	LV_ModifyCol(4, "SortDesc")
	LV_Modify(1, "Select")
	if (A_ThisLabel = "WindowSwitcher") {
		Gui 2: Show, % "x" A_ScreenWidth / 2 - 250 " y" A_ScreenHeight / 2 - 115 " w507 h" LV_GetCount() * 20 + 27 " hide", WindowSwitcher
		DllCall("AnimateWindow", "UInt", HWND_SWITCHER, "Int", 65, "UInt", "0xa0000")
		Gui 2: Show
	} else
		WinMove % "ahk_id" HWND_SWITCHER,
	, % A_ScreenWidth / 2 - 250
	, % A_ScreenHeight / 2 - 115
	, 507
	, % LV_GetCount() * 20 + 27
	return
	
	; UP+DOWN and WHEELUP+WHEELDOWN scrolling logic
	QuickScroll:
	Gui 2: Default
	if LV_Modify(LV_GetNext() + (InStr(A_ThisHotkey, "Down") ? 1 : -1), "vis") && !(LV_GetNext() = 1 && InStr(A_ThisHotkey, "Up"))
		LV_Modify(LV_GetNext() + (InStr(A_ThisHotkey, "Down") ? 1 : -1), "Select")
	return
	
	; DELETE, closes the window
	QuickClose:
	Gui 2: Default
	pos := LV_GetNext()
	LV_GetText(text, pos)
	LV_Delete(pos)
	LV_Modify(pos > LV_GetCount() ? LV_GetCount() : pos, "Select")
	temp := process
	process := []
	for a, b in temp
		if (b.name <> text) {
		i++
		process[i, "name"] := b.name
		process[i, "icon"] := b.icon
	}
	WinMove % "ahk_id" HWND_SWITCHER,
			, % A_ScreenWidth / 2 - 250
			, % A_ScreenHeight / 2 - 115
			, 507
			, % LV_GetCount() * 20 + 27
	WinClose % text
	return
	
	; CTRL+BACKSPACE logic
	QuickBackspace:
	Gui 2: Default
	GuiControl 2: -Redraw, Edit1
	ControlSend, Edit1, ^+{Left}{Backspace}
	GuiControl 2: +Redraw, Edit1
	return
	
	; unfocuses the listview when an event occurs
	QuickListView:
	if (A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")
		GuiControl 2: focus, Edit1
	if (A_GuiEvent = "DoubleClick")
		gosub QuickSubmit
	return
	
	QuickSubmit:
	LV_GetText(text, LV_GetNext())
	gosub 2GuiEscape
	WinActivate % text
	return
	
	2GuiClose:
	2GuiEscape:
	Hotkey(Settings.Hotkey, "On")
	Hotkey(Settings.WindowHotkey, "WindowSwitcher")
	Hotkey("^Backspace", "Hotkey", HWND_MAIN)
	Hotkey("WheelUp", "Hotkey", HWND_MAIN)
	Hotkey("WheelDown", "Hotkey", HWND_MAIN)
	Hotkey("Up", "Hotkey", HWND_MAIN)
	Hotkey("Down", "Hotkey", HWND_MAIN)
	Hotkey("Delete", "Hotkey", HWND_MAIN)
	DllCall("AnimateWindow", "UInt", HWND_SWITCHER, "Int", 65, "UInt", "0x90000")
	IL_Destroy(QuickImageList)
	Gui 2: Destroy
	Gui 1: Default
	return
}

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
	if Settings.StartUp
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, % AppName, % A_ScriptFullPath
	else
		RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, % AppName
	SetTimer, ScanTimer, % Settings.ScanTime * 1000 * 60
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

Manager() {
	static
	global HWND_MANAGER
	if WinExist("ahk_id" HWND_MANAGER) {
		WinActivate
		return
	} Gui 2: Destroy
	Hotkey(Settings.Hotkey, "Off")
	Hotkey(Settings.WindowHotkey, "Off")
	Gui 1: +Disabled
	Gui 4: Default
	Gui 4: Color, 383838, 454545
	Gui 4: Add, Text, w200 Center cWhite, Visible items
	Gui 4: Add, Text, yp xp+270 w200 Center cWhite, Hidden items
	Gui 4: Add, ListView, x10 h294 vActiveListView gActiveLabel -LV0x10 -Multi NoSortHdr NoSort -Hdr AltSubmit cWhite Checked, Active|freq|priv
	Gui 4: Add, ListView, hp xp+250 yp vDeletedListView gDeletedLabel -LV0x10 -Multi NoSortHdr NoSort -Hdr AltSubmit cWhite Checked, Deleted|freq|priv
	Gui 4: Add, Text, y330 x10 w250 cWhite, Drag && drop. Check an item to bypass file validation.
	Gui 4: Font, s9
	Gui 4: Add, Edit, yp-3 x260 w190 gManagerSearch vmanagerinfo cWhite
	Gui 4: Font, s8
	Gui 4: Add, Button, yp-2 x461 w40 h24 gManagerSave hwndHWND_MANAGER_SAVE, Save
	Gui 4: ListView, SysListView321
	for a, b in list()
		LV_Add((b.priv ? "Check" : ""), b.name, b.freq, b.priv)
	LV_ModifyCol(2, "SortDesc")
	LV_ModifyCol(1, 182)
	LV_ModifyCol(2, 36)
	LV_ModifyCol(3, 0)
	temp := FileRead(A_WorkingDir "\del_items.ini")
	Gui 4: ListView, SysListView322
	Loop, parse, temp, % "`n", % "`r"
		if InStr(A_LoopField, "[") = 1
			LV_Add((IniRead("del_items", SubStr(A_LoopField, 2, -1), "priv") ? "Check" : ""), br(SubStr(A_LoopField, 2, -1)), IniRead("del_items", SubStr(A_LoopField, 2, -1), "freq"), IniRead("del_items", SubStr(A_LoopField, 2, -1), "priv"))
	LV_ModifyCol(2, "SortDesc")
	LV_ModifyCol(1, 182)
	LV_ModifyCol(2, 36)
	LV_ModifyCol(3, 0)
	Gui 4: Show,, Program Manager
	Gui 4: -0x20000 +hwndHWND_MANAGER
	GuiControl 4: Focus, Edit1
	Hotkey("^Backspace", "ManagerBackspace", HWND_MANAGER)
	Hotkey("MButton", "ManagerMButton", HWND_MANAGER)
	Hotkey("WheelUp", "ManagerScroll", HWND_MANAGER)
	Hotkey("WheelDown", "ManagerScroll", HWND_MANAGER)
	Hotkey("Up", "Off", HWND_MAIN)
	Hotkey("Down", "Off", HWND_MAIN)
	return
	
	; handles the moving of items when dragging
	DeletedLabel:
	ActiveLabel:
	Critical
	if (A_GuiEvent = "D") {
		Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "2" : "1")
		LV_GetText(name, A_EventInfo)
		LV_GetText(freq, A_EventInfo, 2)
		LV_GetText(priv, A_EventInfo, 3)
		while GetKeyState("LButton", "P") {
			ToolTip % name
			sleep 5
		} ToolTip
		MouseGetPos,,,,control
		if (control = "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "1" : "2")) {
			IsChecked := LV_IsChecked(A_EventInfo)
			LV_Delete(A_EventInfo)
			Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "1" : "2")
			max := pos := ""
			if freq
				pos := LV_Add((IsChecked ? "Check" : ""), name, freq, IsChecked)
			else
				while (pos = 0 || max = "")
					pos := LV_Insert(Random(1, Random(1, max := Ceil((LV_GetCount() / 4) * 3))), (IsChecked ? "Check" : ""), name, freq, IsChecked)
			LV_ModifyCol(2, "SortDesc")
			GuiControl 4:, Static3, % (A_ThisLabel = "DeletedLabel" ? "Showing: " : "Hiding: ") . name
			Print("Manager(): " (A_ThisLabel = "DeletedLabel" ? "Showing: " : "Hiding: ") name)
		}
	} else if (A_GuiEvent = "I") {
		if !WinExist("ahk_id" HWND_MANAGER)
			return
		Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? "2" : "1")
		LV_Modify(A_EventInfo, "Col3", LV_IsChecked(A_EventInfo))
	} else if A_GuiEvent.equals("Normal|RightClick|C") {
		Gui 4: ListView, % "SysListView32" . (A_ThisLabel = "DeletedLabel" ? 1 : 2)
		if LV_GetNext()
			LV_Modify(LV_GetNext(), "-Select")
		GuiControl 4: Focus, Visible items
	}
	return
	
	; scrolls the listview which the mouse hovers over
	ManagerScroll:
	MouseGetPos,,,,control
	ControlClick, % control,,, % InStr(A_ThisHotkey, "Down") ? "WheelDown" : "WheelUp", ahk_id%HWND_MAIN%
	return
	
	; focuses on a static when MButton is pressed
	ManagerMButton:
	GuiControl 4: Focus, Visible items
	return
	
	; runs when anything is written into the edit control
	ManagerSearch:
	Gui 4: Submit, NoHide
	if (managerinfo = "") {
		Loop 2 {
			Gui 4: ListView, % "SysListView32" A_Index
			LV_Modify(LV_GetNext(), "-Select")
		} return
	} Loop 2 {
		LV_Modify(LV_GetNext(), "-Select")
		Gui 4: ListView, % "SysListView32" A_Index
		Loop % LV_GetCount() {
			LV_GetText(text, A_Index)
			if InStr(text, managerinfo) {
				LV_Modify(A_Index, "Select Vis")
				return
			}
		}
	} return
	
	; CTRL+BACKSPACE logic
	ManagerBackspace:
	ControlGetFocus, control, % "ahk_id" HWND_MANAGER
	if (control = "Edit1") {
		GuiControl 3: -Redraw, Edit1
		Send ^+{Left}{Backspace}
		GuiControl 3: +Redraw, Edit1
	} return
	
	; save!
	ManagerSave:
	Gui 4: +Disabled
	ControlGetText, temp, Static3
	GuiControl 4:, Static3, % "Saving.. please wait.."
	list := []
	for a, b in ["items", "del_items"] {
		par := IniRead(b)
		Loop, parse, par, % "`n", % "`r"
		{
			list[A_LoopField, "dir"] := IniRead(b, A_LoopField, "dir")
			list[A_LoopField, "icon"] := IniRead(b, A_LoopField, "icon")
			list[A_LoopField, "freq"] := IniRead(b, A_LoopField, "freq")
			for c, d in [1, 2] {
				Gui 4: ListView, % "SysListView32" . d
				Loop % LV_GetCount() {
					LV_GetText(text, A_Index)
					if (text = A_LoopField) {
						LV_GetText(IsChecked, A_Index, 3)
						list[A_LoopField, "priv"] := IsChecked
						break 2
					}
				}
			}
		}
	} 
	for a, b in ["items", "del_items"] {
		FileDelete % b ".ini"
		Gui 4: ListView, % "SysListView32" A_Index
		Loop % LV_GetCount()
		{
			LV_GetText(text, A_Index)
			IniWrite(b, text, "dir", list[text, "dir"])
			IniWrite(b, text, "icon", list[text, "icon"])
			IniWrite(b, text, "freq", list[text, "freq"])
			IniWrite(b, text, "priv", (list[text, "priv"] ? list[text, "priv"] : 0))
		}
	}
	
	list(true)
	GuiControl 1:, input, % ""
	
	Item.action := []
	
	4GuiEscape:
	4GuiClose:
	Hotkey(Settings.Hotkey, "On")
	Hotkey(Settings.WindowHotkey, "On")
	Hotkey("^Backspace", "Hotkey", HWND_MAIN)
	Hotkey("MButton", "Hotkey", HWND_MAIN)
	Hotkey("MButton", "Hotkey", HWND_MAIN)
	Hotkey("WheelUp", "Hotkey", HWND_MAIN)
	Hotkey("WheelDown", "Hotkey", HWND_MAIN)
	Hotkey("Up", "On", HWND_MAIN)
	Hotkey("Down", "On", HWND_MAIN)
	Gui 4: Destroy
	Gui 1: -Disabled
	Gui 1: Default
	GuiControl 1: focus, input
	return
}

LV_IsChecked(row) {
	RowNumber = 0
	Loop {
		if !(RowNumber := LV_GetNext(RowNumber, "C"))
			break
		if (RowNumber = row)
			return LV_Modify(A_EventInfo, "Col" 3, 1)
	} return false
}

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

Specs() {
	Gui 1: +Disabled
	Tray.timeout := 99
	Tray.Tip("Working..")
	comp:=sys:=net:=[]
	sys["graphics"] := []
	sys["network"] := []
	RunWait,%comspec% /c systeminfo > %A_Temp%\sysinfo.txt,,hide
	FileRead, systeminfo, %A_Temp%\sysinfo.txt
	FileDelete %A_Temp%\sysinfo.txt
	Loop 8 {
		RegRead temp, HKEY_LOCAL_MACHINE, HARDWARE\DEVICEMAP\VIDEO, \Device\Video%A_Index%
		if (SubStr(temp, -3) & 1)
			continue
		RegRead, card, HKEY_LOCAL_MACHINE, % SubStr(temp, 19), Device Description
		RegRead, memory, HKEY_LOCAL_MACHINE, % SubStr(temp, 19), HardwareInformation.MemorySize
		if memory
			sys["graphics"].Insert(card (memory ? " (" Floor(memory / 1000000) - 100 " MB)" : ""))
	} parsenet := SubStr(systeminfo, InStr(systeminfo, "Network card(s):"))
	Loop, parse, parsenet, % "`n", % "`r"
	{
		if RegExMatch(A_LoopField, "\[\d\d\]") {
			if !indent
				indent := InStr(A_LoopField, "[")
			if (InStr(A_LoopField, "[") = indent)
				sys["network"].Insert(SubStr(trim(A_LoopField), 7))
		}
	}
	comp["owner"] := RegRead("HKEY_LOCAL_MACHINE", "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "RegisteredOwner")
	comp["system"] := RegRead("HKEY_LOCAL_MACHINE", "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName") " (" (A_Is64BitOS = true ? "64-bit" : "32-bit") ")"
	comp["lang"] := LangCode(A_Language) " (" A_Language ")"
	comp["compname"] := A_ComputerName
	comp["admin"] := A_IsAdmin ? "Yes" : "No"
	sys["cpu"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString")
	sys["mobo"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\BIOS", "BaseBoardProduct")
	sys["RAM"] := RegExReplace(SubStr(systeminfo, pos := InStr(systeminfo, "Physical") + 20, InStr(SubStr(systeminfo, pos), "MB") + 2), Chr(255), "")
	sys["bios"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\BIOS", "BaseBoardManufacturer")
	sys["bios_vendor"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\BIOS", "BIOSVendor")
	net["connected_state"] := DllCall("wininet\InternetGetConnectedState", "Uint", 0)
	net["ext_ip"] := Send("http://runie.me/ip.php")
	net["connected"] := (InStr(net["ext_ip"], "DOCTYPE") || !net["ext_ip"] ? "No" : "Yes")
	net["int_ip"] := A_IPAddress1
	net["proxy_enabled"] := (RegRead("HKEY_CURRENT_USER", "Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable") ? "Yes" : "No")
	net["proxy_server"] := ProxyServer := RegRead("HKEY_CURRENT_USER", "Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer") ? ProxyServer : "None"
	
	for a, b in sys["graphics"]
		grphcs .= A_Space A_Space A_Space a ". " b "`n"
	for a, b in sys["network"]
		ntwrk .= A_Space A_Space A_Space a ". " b "`n"
	
	s .=  "--- Computer ---`n"
	. "Registered: " comp["owner"] "`n"
	. "System: " comp["system"] "`n"
	. "Language: " comp["lang"] "`n"
	. "Computer Name: " comp["compname"] "`n"
	. "Administrator: " comp["admin"] "`n"
	. "`n"
	. "--- System ---`n"
	. "CPU: " sys["cpu"] "`n"
	. "Motherboard: " sys["mobo"] "`n"
	. "RAM: " sys["RAM"] "`n"
	. "BIOS: " sys["bios"] "`n"
	. "BIOS Vendor: " sys["bios_vendor"] "`n"
	. "Graphics:`n"
	. grphcs
	. "Network card(s):`n"
	. ntwrk
	. "`n"
	. "--- Internet ---`n"
	. "Connected: " net["connected"] "`n"
	. "Connected state: " net["connected_state"] "`n"
	. "External IP: " net["ext_ip"] "`n"
	. "Internal IP: " net["int_ip"] "`n"
	. "Proxy Enabled: " net["proxy_enabled"] "`n"
	. "Proxy IP: " net["proxy_server"] "`n"
	Print("`n" s)
	Tray.Destroy()
	msgbox,, System Information %A_ComputerName%, % s
	Gui 1: -Disabled
}

ScanTimer:
Item.Search()
Item.Verify()
list(true)
return

CMDtoggle:
Gui Submit, NoHide
ControlGetText, input, Edit1
if (input.startsWith("/"))
	GuiControl 1:, input, % ""
else {
	GuiControl 1:, input, % "/"
	ControlSend, Edit1, {Right}
} GuiControl 1: Focus, Edit1
return


GuiSize:
GuiControl 1: Move, input, % "w" A_GuiWidth - 40 " y" A_GuiHeight - 25
GuiControl 1: Move, SysListView321, % "w" A_GuiWidth " h" A_GuiHeight - 25
GuiControl 1: Move, Static1, % "x" A_GuiWidth - 39 " y" A_GuiHeight - 24
GuiControl 1: Move, Static2, % "x" A_GuiWidth / 2 - 102 " y" A_GuiHeight / 2 - 18
LV_ModifyCol(1, A_GuiWidth - 18)
return

Hotkey:
Hotkeys(A_ThisHotkey)
return

EditAction:
Gui Submit, NoHide
input(input)
return

WindowSwitcher:
WindowSwitcher()
return

ListAction:
ListAction(A_GuiEvent)
return

MenuHandler:
MenuHandler(A_ThisMenuItem)
return

GuiDropFiles:
GuiToggle:
GuiHide:
GuiShow:
Gui[SubStr(A_ThisLabel, 4)](A_ThisLabel = "GuiDropFiles" ? A_GuiEvent : "")	; hahahah this is some clever shit
return

Class ItemHandler {
	__New() {
		this.bad_name_keywords := "unin|driver|help|update|NVIDIA|eReg|.NET|Microsoft Security Client|Battlelog|AutoHotkey " A_AhkVersion
		this.bad_dir_keywords := "unin|driver|help|update|{|["
		this.action := []
	}
	
	; Pack all the .scan() calls into one function that is called from outside
	Search() {
		this.exists := FileExist("items.ini")
		this.scan("HKEY_CURRENT_USER", "Software\Microsoft\Windows\CurrentVersion\Uninstall")
		;this.chrome_apps()
		if (A_ComputerName = "DARKNIGHT-PC") && FileExist("C:\debug_columbus.txt")
			this.lol()
		this.scan("HKEY_LOCAL_MACHINE", "Software\Microsoft\Windows\CurrentVersion\Uninstall")
		this.scan("HKEY_LOCAL_MACHINE", "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
		this.exists := true
	}
	
	; Moves an item back to items.ini using .Insert()
	Restore(item, pos := "") {
		if !IniRead("del_items", item) {
			PrintError("Items.Restore(): Not found - " item)
			return
		} this.Insert(item, IniRead("del_items", item, "dir"), IniRead("del_items", item, "icon"), IniRead("del_items", item, "freq"), IniRead("del_items", item, "priv"), pos)
		IniDelete("del_items", item)
	}
	
	; Moves an item to the del_items.ini file
	Delete(item) {
		Print("Item.Delete(): " item)
		IniWrite("del_items", item, "dir", IniRead("items", item, "dir"))
		IniWrite("del_items", item, "icon", IniRead("items", item, "icon"))
		IniWrite("del_items", item, "freq", IniRead("items", item, "freq"))
		IniWrite("del_items", item, "priv", IniRead("items", item, "priv"))
		IniDelete("items", item)
	}
	
	; adds to the bottom of items.ini, unless items.ini is more than 5 seconds old (iow not the first parse), in which case it will call .Insert() instead
	Add(name, dir, icon, priv := 0, freq := 0) {
		if !IniRead("items", name) && !IniRead("del_items", name) {
			if this.exists
				return Item.Insert(name, dir, icon, priv)
			IniWrite("items", name, "dir", dir)
			IniWrite("items", name, "icon", icon)
			IniWrite("items", name, "freq", 0)
			IniWrite("items", name, "priv", priv)
			return true
		} else
			return false
	}
	
	; Verifies items
	Verify() {
		if !Settings.Verify
			return
		for a, b in ["items", "del_items"] {
			list := IniRead(b)
			Loop, parse, list, % "`n", % "`r"
				if RegExMatch(IniRead(b, A_LoopField, "dir"), "\.\w+$") && !FileExist(IniRead(b, A_LoopField, "dir")) && (!IniRead(b, A_LoopField, "priv")) {
				print("Item.Verify(): " A_LoopField " removed from program list")
				IniDelete(b, A_LoopField)
			}
		}
	}
	
	; Loops & parses the registry for programs to add to the list
	scan(key, subkey) {
		Loop, % key, % subkey, 1, 1
			if (A_LoopRegName = "DisplayName") {
			RegRead name
			icon := RegExReplace(RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayIcon"), """", "")
			if (InStr(icon, ","))
				icon := SubStr(icon, 1, InStr(icon, ",",, 0) - 1)
			if (FileExt(icon) = "exe")
				dir := icon
			else if InStr(A_LoopRegSubKey, "Steam App ")
				dir := "steam://rungameid/" SubStr(A_LoopRegSubKey, InStr(A_LoopRegSubKey, " ",, 0) + 1)
			else if (dir := RegRead(A_LoopRegKey, A_LoopRegSubkey, "InstallLocation"))
				dir := this.search_directory(name, dir)
			dir := RegExReplace(dir, "\\\\", "\")
			if !icon
				icon := dir
			if (name && dir && icon && !dir.contains(this.bad_dir_keywords) && !name.contains(this.bad_name_keywords))
				this.Add(name, dir, icon)
		}
	}
	
	; iterates the freq value in a section
	AddFreq(item) {
		freq := IniRead("items", item, "freq")
		if (freq <> "")
			return IniWrite("items", item, "freq", freq + 1)
		else if IniRead("items", item)
			return IniWrite("items", item, "freq", 1)
		return false
	}
	
	; Adds an item to a random position in the items.ini file
	Insert(name, dir, icon, priv := 0, freq := 0, pos := "") {
		if (name = "" || dir = "" || icon = "" || freq = "") {
			PrintError("Items.Insert(): failed! missing parameters: " name)
			return false
		} else if (IniRead("items", name)) {
			PrintError("Item.Insert(): failed! already existent: " name)
			return false
		} temp := IniRead("items")
		StringReplace, temp, temp, `n, `n, UseErrorLevel
		item_amount := ErrorLevel
		if !pos
			pos := Floor(Random(1, (item_amount / 3) * 2))
		name := br(name, true)		; fix the [] problems
		Loop, parse, temp, % "`n", % "`r"
		{
			if (A_Index >= pos && !done)
				done := true, list .= "[" br(name, true) "]`ndir=" dir "`nicon=" icon "`nfreq=" freq "`npriv=" priv "`n"
			list .= "[" br(A_LoopField, true) "]`n" IniRead("items", A_LoopField) "`n"
		} if !done
			list .= "[" br(name, true) "]`ndir=" dir "`nicon=" icon "`nfreq=" freq "`npriv=" priv "`n"
		FileDelete items.ini
		FileAppend % list, % A_WorkingDir "\items.ini"
		Print("Item.Insert(): " name " (" pos "/" item_amount ")")
		return true
	}
	
	; Searches a directory for the .exe which is most likely to be the correct one based on the name
	; Does not work perfectly, but probably never will..
	search_directory(name, dir) {
		
		; determines how much filesize matters
		size_weight := 0.65
		
		if FileExist(dir "\" name ".exe") ; trying some simple FileExists before we go to the more advanced method
			return dir "\" name ".exe"
		if FileExist(dir "\" RegExReplace(name, " ", "") ".exe")
			return dir "\" RegExReplace(name, " ", "") ".exe"
		arr := []		; create a temp array
		Loop % dir "\*.exe", 1, ; loop the dir to find all the exe files
			if (short_exe := SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, ".",, 0) - 1)).contains(this.bad_name_keywords) { 		; check that it doesn't contain any excluded words
			FileGetSize, size, % A_LoopFileFullPath, K 			; get filesize
			if (size > max_size)			; get the size of the biggest size
				max_size := size
			i := 0, temp := name
			Loop, parse, short_exe			; find the number of matching letters
				if (pos := InStr(temp, A_LoopField)) {
				temp := SubStr(temp, 1, pos - 1) . SubStr(temp, pos + 1)
				i++			; i = number of letters matched
			}
			arr[A_LoopFileName, "match"] := i / short_exe.length	; put the letter match ratio in the array
			arr[A_LoopFileName, "size"] := size 					; put the filesize in the array
		} for a, b in arr 			; apply weight to the sizes
			arr[a, "size"] := Round((b.size / max_size), 3)
		rank := []	; create a new array to list all the possibilities
		for a, b in arr
			rank[a] := b.match + (b.size * size_weight)
		for a, b in rank		; find the highest scoring exe
			if (b > bm)
				fin := a, bm := b
		if fin			; if it exists, return it! :D
			return dir "\" fin
	}
	
	lol() {
		if (dir := this.search_directory("fraps", "C:\" A_ProgramFiles "\Fraps"))
			this.Add("Fraps", dir, dir, 1)
		if (dir :=this.search_directory("Deluge", "C:\Program Files (x86)\Deluge"))
			this.Add("Deluge", dir, dir, 1)
		if (dir :=this.search_directory("Steam", "C:\Program Files (x86)\Steam"))
			this.Add("Steam", dir, dir, 1)
		dir := "C:\Program Files (x86)\AHK Studio\AHK Studio Launcher.exe"
		this.Add("AHK Studio", dir, dir, 1)
	}
}

Class MainGui {
	__New() {
	}
	
	Enable() {
		Gui 1: -Disabled
	}
	
	Disable() {
		Gui 1: +Disabled
	}
	
	; Processes items dropped on gui
	DropFiles(GuiEvent) {
		timer("dropfiles")
		Loop, parse, GuiEvent, % "`n", % "`r"
		{
			FileGetShortcut, % A_LoopField, target,, args
			SplitPath, A_LoopField,,,, name
			if (ErrorLevel = 1)
				target := A_LoopField
			print("`n" name "`n" target "`n" )
			if (name&&target)
				if Item.Add(name, target " " args, target, true)
					tmp .= name "`n"
			else
				Print("Gui.DropFiles(): Adding of " name " failed")
		} Print("Gui.DropFiles(): Finished in " timer("dropfiles") "ms")
		list(true)
		input()
		TrayTip, Added:, %tmp%, 3
	}
	
	; Toggles the gui window
	Toggle() {
		if !WinExist("ahk_id" HWND_MAIN)
			Gui.Show()
		else
			Gui.Hide()
	}
	
	; Shows the gui window
	Show() {
		Hotkey(Settings.WindowHotkey, "Off")
		Gui 1: Show, % "x" Settings.X " y" Settings.Y " w" Settings.Width " h" Settings.Height " hide"
		DllCall("AnimateWindow", "UInt", HWND_MAIN, "Int", 65, "UInt", "0xa0000")
		Gui 1: Show
		GuiControl 1: -Redraw, Edit1
		GuiControl 1: +Redraw, Edit1
		this.IsVisible := true
	}
	
	; Hides the gui window
	Hide() {
		Hotkey(Settings.WindowHotkey, "On")
		DllCall("AnimateWindow", "UInt", HWND_MAIN, "Int", 65, "UInt", "0x90000")
		Gui 1: Hide
		GuiControl 1:, input, % ""
		this.IsVisible := false
	}
	
	; Used to change pos of gui, or reset pos
	Move() {
		Hotkey("Escape", "stopmove", HWND_MAIN)
		Hotkey(Settings.Hotkey, "Off")
		GuiControl 1: hide, SysListView321
		GuiControl 1: hide, input
		GuiControl 1: show, Static2
		GuiControl 1: hide, Static1
		if !WinActive("ahk_id" HWND_MAIN)
			Gui.Show()
		Gui +AlwaysOnTop +Resize
		return
		
		stopmove:
		Hotkey("Escape", "GuiHide", HWND_MAIN)
		Hotkey(Settings.Hotkey, "On")
		Gui -Resize -AlwaysOnTop
		WinGetPos, x, y, w, h, ahk_id %HWND_MAIN%
		GuiControl 1: show, SysListView321
		GuiControl 1: show, input
		GuiControl 1: hide, Static2
		GuiControl 1: Show, Static1
		GuiControl 1: focus, input
		if (x&&y&&w&&h) {
			Settings.Write("X", x)
			Settings.Write("Y", y)
			Settings.Write("Width", w-2) ; remove two pixels because of the border!
			Settings.Write("Height", h-2) ; you have no idea how long time that took to figure out. AND HOW MUCH TROUBLES IT CAUSED.
		} else {
			PrintError("Saving new position failed! Reverting to default position")
			Tray.Tip("Saving new position failed! Reverting to default position", "Error :(")
			Settings.Default(["X", "Y", "Width", "Height"])
			Gui Show, % "x" Settings.X " y" Settings.Y " w" Settings.Width " h" Settings.Height
		} return
	}
	
	Reset() {
		Print("GUI: Resetting position.")
		Settings.Default(["X", "Y", "Width", "Height"])
		Gui Show, % "x" Settings.X " y" Settings.Y " w" Settings.Width " h" Settings.Height (!WinExist("ahk_id" HWND_MAIN) ? " hide" : "")
		return
	}
}

Class Settings {
	__New(file) {
		this.file := file
		this.defaults := {"Hotkey": 			"^!P"
						, "WindowHotkey": 		"^!O"
						, "StartUp": 			true
						, "UpdateCheck": 		true
						, "Debug": 				false
						, "ForceSequential": 	false
						, "ScanTime":			5
						, "Verify":				true
						, "SortByPopularity":	true
						, "DownloadFileExt": 	FileExt(A_ScriptFullPath)
						, "LastUpdatePrompt": 	AppVersion
						, "X": 					A_ScreenWidth - 502
						, "Y":					A_ScreenHeight - 392
						, "Width": 				500
						, "Height": 			350}
	}
	
	; Sets all values to default or just the ones passed in the array x
	Default(x := "") {
		if x {
			for a, b in x
				if (b && this.defaults[b] <> "")
					this.Write(b, this.defaults[b])
		} else
			for a, b in this.defaults
				this.Write(a, b)
	}
	
	; Reads all the keys listed in .defaults
	Read() {
		for a, b in this.defaults
			if ((this[a] := IniRead(this.file, "Settings", a)) = "") && (!InStr(a, "Hotkey"))
				this.Write(a, b)
	}
	
	
	; Writes a key
	Write(key, value) {
		IniWrite(this.file, "Settings", key, value)
		this[key] := value
		Print("Settings: " key "=" value)
	}
	
	; Deletes a key
	Delete(key) {
		IniDelete(this.file, "Settings", key)
		this[key] := ""
	}
}

Class Tray {
	__New() {
		this.fade := 65
		this.timeout := 6
		this.IsVisible := false
	}
	
	Tip(message, title := "") {
		this.title := title
		this.message := message
		if WinExist("ahk_id" this.hwnd)
			this.Destroy()
		Gui 7: +AlwaysOnTop +ToolWindow -SysMenu -Caption +Border hwndhwnd
		this.hwnd := hwnd
		Gui 7: Color, 0x464646
		Gui 7: Font, c0x999999 s16 wBold, Segoe UI
		if title
			Gui 7: Add, Text, % " x" 12 " y" 9, % title
		Gui 7: Font, cWhite s12 wRegular
		Gui 7: Add, Text, % " x" 12 " y" (title ? 45 : 9), % message
		Gui 7: Show, hide
		DetectHiddenWindows on
		WinGetPos,,, w, h, % "ahk_id" this.hwnd
		DetectHiddenWindows off
		Gui 7: Show, % "x" A_ScreenWidth - w - 20 " y" A_ScreenHeight - h - 50 " NoActivate hide"
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", this.fade, "UInt", "0x80000")
		Gui 7: Show, NoActivate
		SetTimer, NotifyDestroy, % this.timeout * 1000
		this.IsVisible := true
		return
		
		NotifyDestroy:
		SetTimer, NotifyDestroy, off
		Tray.Destroy()
		return
	}
	
	Destroy() {
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", this.fade, "UInt", "0x90000")
		Gui 7: Destroy
		this.IsVisible := false
		this.title := ""
		this.message := ""
		this.fade := 65
		this.timeout := 6
		return
	}
	
	SetTimeout(timeout) {
		return this.timeout := timeout
	}
	
	SetFade(fade) {
		return this.fade := fade
	}
	
	Click() {
		Tray.Destroy()
	}
}

; wrapper for FileRead
FileRead(file) {
	FileRead, temp, % file
	return temp
}

; wrapper for FileReadLine
FileReadLine(file, line) {
	FileReadLine, temp, % file, % line
	return temp
}

; runs a file
Run(file, args := "") {
	run % file (args ? " " args : ""), % SubStr(file, 1, InStr(file, "\",, 0)), UseErrorLevel
	if ErrorLevel
		return PrintError("run(): ERROR - " ErrorLevel)
	print("run(): " file (args ? " ARGS: " args : ""))
	return true
}

; returns how old a file is, in seconds (not used)
FileOld(file) {
	FileGetTime, ft, %file% ; file time
	ft-=a_now, s ; ft gets replaced with the time difference.
	return ft*-1
}

FileExt(file) {
	SplitPath, file,,, ext
	return ext
}

RegRead(root, sub, value) {
	RegRead, output, % root, % sub, % value
	return output
}

IniRead(file, section := "", key := "") {
	IniRead, output, % A_WorkingDir "\" file ".ini", % br(section, true), % key, % A_Space
	if (section = "" && key = "")
		output := br(output)
	return output
}

IniWrite(file, section, key, value) {
	IniWrite, % value, % A_WorkingDir "\" file ".ini", % br(section, true), % key
	return ErrorLevel
}

IniDelete(file, section, key := "") {
	if key
		IniDelete, % A_WorkingDir "\" file ".ini", % br(section, true), % key
	else
		IniDelete, % A_WorkingDir "\" file ".ini", % br(section, true)
}

Send(URL, POST_DATA := "", TIMEOUT_SECONDS := 5, PROXY := "") {
	static HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Print("Send(): " URL)
	HTTP.Open("POST", URL, true)
	HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	RegRead ProxyEnable, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable
	if (ProxyEnable||PROXY) {
		RegRead ProxyServer, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer
		HTTP.SetProxy(2, (PROXY ? PROXY : ProxyServer))
	} if IsObject(POST_DATA) {
		for a, b in POST_DATA
			POST .= (A_Index>1?"&":"") a "=" b
	} HTTP.Send((POST?POST:POST_DATA))
	if HTTP.WaitForResponse(TIMEOUT_SECONDS)
		return HTTP.ResponseText
	return
}

Receive(wParam, lParam) {
	return RunFunc(StrGet(NumGet(lParam + 2 * A_PtrSize)))
}

RunFunc(data) {
	if InStr(data, "(")
		func := SubStr(data, 1, InStr(data, "(") - 1), params := SubStr(data, InStr(data, "(") + 1)
	else
		func := data
	if InStr(func, ".")
		class := SubStr(func, 1, InStr(func, ".") - 1), func := SubStr(func, InStr(func, ".") + 1)
	p := []
	Loop, parse, params
	{
		if (A_LoopField = """")
			fin := !fin
		else if ((A_LoopField = ",") || (A_Index = params.length)) && (!fin) {
			i++
			p[i] := trim(temp)
			temp := ""
		} else
			temp .= A_LoopField
	} if InStr(data, "print(") <> 1
		print("Receive(): Calling " (class ? class "." : "") func "()" (params ? " with the parameters (" params : ""))
	if class
		return %class%[func](p*)
	else if func
		return %func%(p*)
	return 0
}

timer(name) {
	static start := []
	if start[name] {
		temp := start[name], start[name] := ""
		return STMS() - temp
	} else
		start[name] := STMS()
}

br(string, encode := false) {
	if encode {
		StringReplace, string, string, [, |(|, 1
		StringReplace, string, string, ], |)|, 1
	} else {
		StringReplace, string, string, |(|, [, 1
		StringReplace, string, string, |)|, ], 1
	} return string
}

Random(min, max) {
	Random, out, % min, % max
	return out
}

RandomString(length, special := false) {
	Loop % length
		str .= (r := Random(1, special ? 4 : 3)) = 1
	? Random(0, 9) : r = 2
	? Chr(Random(65, 90)) : r = 3
	? Chr(Random(97, 122)) : SubStr("-_?!&:", r := Random(1, 6), 1)
	return % str
}

String_Equals(str, needle) {
	Loop, parse, needle, % "|"
		if (A_LoopField = str)
			return true
	return false
}

String_Split(str, delim) {
	arr := []
	Loop, parse, str, % delim
		arr[A_Index] := A_LoopField
	return arr
}

String_Contains(str, needle) {
	Loop, parse, needle, % "|"
		if InStr(str, A_LoopField)
			return true
	return false
}

String_StartsWith(str, string) {
	if (InStr(str, string) = 1)
		return true
	return false	
}

String_EndsWith(str, string) {
	if (string = SubStr(str, StrLen(str) - StrLen(string) + 1))
		return true
	return false
}

String_Find(str, string) {
	return InStr(str, string)
}

String_PseudoProperties(str, key) {
	if key in sqrt,ceil,floor,round,abs,exp,log,ln,cos,tan,sin
		return %key%(str)
	else if (key = "length")
		return StrLen(str)
	else if (key = "toUpper") {
		StringUpper, str, str
		return str
	} else if (key = "toLower") {
		StringLower, str, str
		return str
	} else if (key = "type") {
		for a, b in ["integer", "float", "digit", "xdigit"] {
			if str is %b%
				return "integer"
		} if RegExMatch(str, "\w")
			return "string"
	}
}

WM_LBUTTONDOWN() {
	WinGet, style, Style
	if (Style & 0x40000) && (A_Gui = 1)
		PostMessage, 0xA1, 2
	else if (A_Gui = 7)
		Tray.Destroy()
}

ScrollBarAt(ControlHWND) { ; thanks to VxE - http://www.autohotkey.com/board/topic/44657-how-to-check-if-its-the-end-of-page/?p=278091
	VarSetCapacity(sbi, 60, 0)
	NumPut(60, sbi, 0, "int")
	if DllCall("GetScrollBarInfo", uint, ControlHWND, int, 0xFFFFFFFB, uint, &sbi) {
		sbwid := NumGet(sbi, 20, "int")
		sbbot := NumGet(sbi, 16, "int") - NumGet(sbi, 8, "int") - sbwid*2
		thtop := NumGet(sbi, 24, "int") - sbwid
		thbot := NumGet(sbi, 28, "int") - sbwid
		thlen := thbot - thtop
		if NumGet(sbi, 36, "int") || NumGet(sbi, 48, "int") || thtop < 0
			return "Disabled"
		else if (thtop = 0)
			return 0
		else if (thbot = sbbot)
			return 1
		else
			return Round(thtop / (sbbot - thlen), 2)
	} return ""
}

AddToolTip(CtrlHwnd,text,Modify=0) {
	static TThwnd, GuiHwnd, Ptr
	if (!TThwnd) {
		Gui,+LastFound
		GuiHwnd:=WinExist()
		TThwnd:=DllCall("CreateWindowEx","Uint",0,"Str","TOOLTIPS_CLASS32","Uint",0,"Uint",2147483648 | 3,"Uint",-2147483648
	,"Uint",-2147483648,"Uint",-2147483648,"Uint",-2147483648,"Uint",GuiHwnd,"Uint",0,"Uint",0,"Uint",0)
		Ptr:=(A_PtrSize ? "Ptr" : "UInt"), DllCall("uxtheme\SetWindowTheme","Uint",TThwnd,Ptr,0,"UintP",0)
	} Varsetcapacity(TInfo,44,0), Numput(44,TInfo), Numput(1|16,TInfo,4), Numput(GuiHwnd,TInfo,8), Numput(CtrlHwnd,TInfo,12), Numput(&text,TInfo,36)
	!Modify   ? (DllCall("SendMessage",Ptr,TThwnd,"Uint",1028,Ptr,0,Ptr,&TInfo,Ptr))
. (DllCall("SendMessage",Ptr,TThwnd,"Uint",1048,Ptr,0,Ptr,A_ScreenWidth))
	DllCall("SendMessage",Ptr,TThwnd,"UInt",(A_IsUnicode ? 0x439 : 0x40c),Ptr,0,Ptr,&TInfo,Ptr)
}

SetCueBanner(HWND, STRING) { ; thaaanks tidbit
	static EM_SETCUEBANNER := 0x1501
	if (A_IsUnicode) ; thanks just_me! http://www.autohotkey.com/community/viewtopic.php?t=81973
		return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", false, "WStr", STRING)
	else {
		if !(HWND + 0) {
			GuiControlGet, CHWND, HWND, %HWND%
			HWND := CHWND
		} VarSetCapacity(WSTRING, (StrLen(STRING) * 2) + 1)
		DllCall("MultiByteToWideChar", UInt, 0, UInt, 0, UInt, &STRING, Int, -1, UInt, &WSTRING, Int, StrLen(STRING) + 1)
		DllCall("SendMessageW", "UInt", HWND, "UInt", EM_SETCUEBANNER, "UInt", SHOWALWAYS, "UInt", &WSTRING)
		return
	}
}

UriEncode(Uri) { ; thanks to GeekDude for providing this function!
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0)
	StrPut(Uri, &Var, "UTF-8")
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	while Code := NumGet(Var, A_Index - 1, "UChar")
		if (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
	else
		Res .= "%" . SubStr(Code + 0x100, -1)
	SetFormat, IntegerFast, %f%
	return, Res
}

STMS() { ; System Time in MS / STMS() returns milliseconds elapsed since 16010101000000 UT
	static GetSystemTimeAsFileTime, T1601                              ; By SKAN / 21-Apr-2014
	if !GetSystemTimeAsFileTime
		GetSystemTimeAsFileTime := DllCall("GetProcAddress", UInt, DllCall("GetModuleHandle", Str,"Kernel32.dll"), A_IsUnicode ? "AStr" : "Str","GetSystemTimeAsFileTime")
	DllCall(GetSystemTimeAsFileTime, Int64P, T1601)
	return T1601 // 10000
} ; http://ahkscript.org/boards/viewtopic.php?p=17076#p17076

Exit:
ExitApp

PrintError(text) {
	Print(, "Red")
	Print(text)
	Print(, "White")
	return false
}

Print(text := "", col := "") {
	static Colors := {"Black":0,"Navy":1,"Green":2,"Teal":3,"Maroon":4,"Purple":5,"Olive":6
		,"Silver":7,"Gray":8,"Blue":9,"Lime":10,"Aqua":11,"Red":12,"Fuchsia":13,"Yellow":14,"White":15}
	if !Settings.Debug
		return
	if !handle
		Handle := DllCall("GetStdHandle", "UInt", (-11,DllCall("AllocConsole")), "UPtr"), col := "White"
	if col
		DllCall("SetConsoleTextAttribute", "UPtr", Handle, "UShort", Colors[col]|0<<4)
	if text
		return FileOpen("CONOUT$", "w").Write(text . "`n")
}

LangCode(code) {
	lang := { "0436": "Afrikaans", "041c": "Albanian", "0401": "Arabic Saudi Arabia", "0801": "Arabic Iraq", "0c01": "Arabic Egypt", "0401": "Arabic Saudi Arabia", "0801": "Arabic Iraq", "0c01": "Arabic Egypt", "1001": "Arabic Libya"
	, "1401": "Arabic Algeria", "1801": "Arabic Morocco", "1c01": "Arabic Tunisia", "2001": "Arabic Oman", "2401": "Arabic Yemen", "2801": "Arabic Syria", "2c01": "Arabic Jordan", "3001": "Arabic Lebanon", "3401": "Arabic Kuwait"
	, "3801": "Arabic UAE", "3c01": "Arabic Bahrain", "4001": "Arabic Qatar", "042b": "Armenian", "042c": "Azeri Latin", "082c": "Azeri Cyrillic", "042d": "Basque", "0423": "Belarusian", "0402": "Bulgarian", "0403": "Catalan"
	, "0404": "Chinese Taiwan", "0804": "Chinese PRC", "0c04": "Chinese Hong Kong", "1004": "Chinese Singapore", "1404": "Chinese Macau", "041a": "Croatian", "0405": "Czech", "0406": "Danish", "0413": "Dutch Standard"
	, "0813": "Dutch Belgian", "0409": "English United States", "0809": "English United Kingdom", "0c09": "English Australian", "1009": "English Canadian", "1409": "English New Zealand", "1809": "English Irish"
	, "1c09": "English South Africa", "2009": "English Jamaica", "2409": "English Caribbean", "2809": "English Belize", "2c09": "English Trinidad", "3009": "English Zimbabwe", "3409": "English Philippines", "0425": "Estonian"
	, "0438": "Faeroese", "0429": "Farsi", "040b": "Finnish", "040c": "French Standard", "080c": "French Belgian", "0c0c": "French Canadian", "100c": "French Swiss", "140c": "French Luxembourg", "180c": "French Monaco"
	, "0437": "Georgian", "0407": "German Standard", "0807": "German Swiss", "0c07": "German Austrian", "1007": "German Luxembourg", "1407": "German Liechtenstein", "0408": "Greek", "040d": "Hebrew", "0439": "Hindi"}
	lang2 := {"040e": "Hungarian", "040f": "Icelandic", "0421": "Indonesian", "0410": "Italian Standard", "0810": "Italian Swiss", "0411": "Japanese", "043f": "Kazakh", "0457": "Konkani", "0412": "Korean", "0426": "Latvian"
	, "0427": "Lithuanian", "042f": "Macedonian", "043e": "Malay Malaysia", "083e": "Malay Brunei Darussalam", "044e": "Marathi", "0414": "Norwegian Bokmal", "0814": "Norwegian Nynorsk", "0415": "Polish"
	, "0416": "Portuguese Brazilian", "0816": "Portuguese Standard", "0418": "Romanian", "0419": "Russian", "044f": "Sanskrit", "081a": "Serbian Latin", "0c1a": "Serbian Cyrillic", "041b": "Slovak", "0424": "Slovenian"
	, "040a": "Spanish Traditional Sort", "080a": "Spanish Mexican", "0c0a": "Spanish Modern Sort", "100a": "Spanish Guatemala", "140a": "Spanish Costa Rica", "180a": "Spanish Panama", "1c0a": "Spanish Dominican Republic"
	, "200a": "Spanish Venezuela", "240a": "Spanish Colombia", "280a": "Spanish Peru", "2c0a": "Spanish Argentina", "300a": "Spanish Ecuador", "340a": "Spanish Chile", "380a": "Spanish Uruguay", "3c0a": "Spanish Paraguay"
	, "400a": "Spanish Bolivia", "440a": "Spanish El Salvador", "480a": "Spanish Honduras", "4c0a": "Spanish Nicaragua", "500a": "Spanish Puerto Rico", "0441": "Swahili", "041d": "Swedish", "081d": "Swedish Finland"
	, "0449": "Tamil", "0444": "Tatar", "041e": "Thai", "041f": "Turkish", "0422": "Ukrainian", "0420": "Urdu", "0443": "Uzbek Latin", "0843": "Uzbek Cyrillic", "042a": "Vietnamese"}
	for x, y in [lang, lang2]
		for a, b in y
			if (a = code)
				return b
}
