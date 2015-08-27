#SingleInstance force
#MaxHotkeysPerInterval 200
; #notrayicon
#NoEnv
SetRegView 64
SetBatchLines -1
DetectHiddenWindows On
OnExit, Exit

; string base definitions
"".base.__Get := Func("String_PseudoProperties")
"".base.find := Func("String_Find")
"".base.split := Func("String_Split")
"".base.equals := Func("String_Equals")
"".base.contains := Func("String_Contains")
"".base.startsWith := Func("String_StartsWith")
"".base.endsWith := Func("String_EndsWith")

; init classes and vars
global version
;auto_version
global xml := New xmlfile("Columbus", A_WorkingDir "\Columbus.xml")
global Settings := New Settings()
global Plugin := New Plugin("{436cf066-cf70-4ca9-990f-c7083fea8367}")
global Main := New MainGui("Columbus")
global Fokus := New FokusGui("Fokus")
global Items := New Items("items")
global Hotkey := New Hotkey()
global Commands := New Commands()
global Tray := New Tray()

if !A_IsAdmin && Settings.RunAsAdmin {
	if A_IsCompiled
		DllCall("shell32\ShellExecute" . (A_IsUnicode ? "" :"A"), (A_PtrSize=8 ? ptr : uint), 0, str, "RunAs", str, A_ScriptFullPath, str, "" , str, A_WorkingDir, int, 1)
	else	
		DllCall("shell32\ShellExecute" . (A_IsUnicode ? "" :"A"), (A_PtrSize=8 ? ptr : uint), 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . "", str, A_WorkingDir, int, 1)
	ExitApp
}

if !FileExist(A_ProgramFiles "\Columbus")
	FileCreateDir % A_ProgramFiles "\Columbus"
if ErrorLevel {
	m("Unable to create directory.`nMake sure the program is running as administrator.")
	ExitApp
}

SetWorkingDir % A_ProgramFiles "\Columbus"

if !FileExist(A_WorkingDir "\Plugins")
	FileCreateDir % A_WorkingDir "\Plugins"

/*
	if A_IsCompiled && !FileExist(A_WorkingDir "\Columbus.exe") { ; save exe to programfiles and create a shortcut
		FileMove, % A_ScriptFullPath, % A_WorkingDir "\Columbus.exe"
		FileCreateShortcut, % A_WorkingDir "\Columbus.exe", % A_Desktop "\Columbus.lnk", % A_WorkingDir,, Columbus - A fast program launcher made by Runar Borge, % A_WorkingDir "\Columbus.exe"
		ControlSend, SysListView321, {F5}, ahk_class Progman ; refresh desktop.. GHETTTOOOOOO BUT WORKS PRETTY WELL
		run % A_Desktop "\Columbus.lnk"
		ExitApp
	}
*/

; ! testing
; RegWrite, REG_SZ, HKEY_CLASSES_ROOT\columbus\shell\open\command,, % """" A_WorkingDir """" " -- """ "%1" """"

if FileExist(A_Appdata "\Columbus") {
	Convert()
	Loop % A_Appdata "\Columbus\commands\*.*"
	{
		FileMoveDir, % A_Appdata "\Columbus\commands", % A_Desktop "\commands"
		m("Contents of Columbus\commands have been copied to a folder on your desktop.`n`nThe command functionality is no longer avaliable.")
		break
	} FileRemoveDir % A_Appdata "\Columbus", 1
}

; fixes drag&drop on vista+
Loop 2
	DllCall("ChangeWindowMessageFilter",uint,(a:=!a ? 0x49 : 0x233),uint,1)

; set up tray menu
Menu, Tray, NoStandard
Menu, Tray, Add, Show Columbus, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Settings, MenuHandler
Menu, Tray, Add, Manager, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Reset GUI position, MenuHandler
Menu, Tray, Add, Report a bug, MenuHandler
; Menu, Tray, Add, Show Commands, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Check for updates, MenuHandler
Menu, Tray, Add
Menu, Tray, Tip, Columbus v%version%

for a, b in xml.get("//lists/*")
	if (b.node.nodeName != "items")
		ItemList.Lists[b.node.nodeName] := New ItemList(b.node.nodeName)

Loop % A_WorkingDir "\Plugins\*.ahk"
{
	if !xml.ssn("//plugins/plugin[@name='" SubStr(A_LoopFileName, 1, -4) "']") ; add files to plugin node
		xml.add("plugins/plugin", {name:SubStr(A_LoopFileName, 1, -4), run:false},, true)
	if (A_Index = 1) {
		Menu, Tray, Add, Plugins, :Plugins
		Menu, Tray, Add
	} Menu, Plugins, Add, % SubStr(A_LoopFileName, 1, -4), MenuHandler
}

Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 2
Menu, Tray, Default, Show Columbus

if FileExist("icon.ico") && !A_IsCompiled
	Menu, Tray, Icon, % A_WorkingDir "\icon.ico"

; gui drag
OnMessage(0x201, "WM_LBUTTONDOWN")

; Main gui
Main.Font("s" Settings.Font.Size " cWhite Q1" (Settings.Font.Bold ? " Bold" : ""), Settings.Font.Type)
Main.Color(454545, Settings.Color)
Main.Margin(0, 0)
Main.CLV := new LV_Colors(Main.Add("ListView", "h" Settings.Pos.Height - 25 " w" Settings.Pos.Width " gListAction -E0x200 -Grid -TabStop -Hdr +AltSubmit", "Result|TimesRun"))
;Main.AltRows()
Main.Font("italic s13")
Main.Add("Edit", "x0 h25 w" Settings.Pos.Width " y" Settings.Pos.Height - 25 " gEditAction")
Main.Font("Norm")
Main.Add("Text", "x5 y5 w204 Center", "Press Escape to save position")
Main.Control("Hide", "Static1")
Main.Options("-Caption +LastFound +ToolWindow -Resize +MinSize300x50 +OwnDialogs +Border -DPIScale +AlwaysOnTop")
Main.SetEvents({Size:Main.Size.Bind(Main), DropFiles:Main.DropFiles.Bind(Main)})
Main.SetDefault()
LV_ModifyCol(2, 0)

; Fokus gui
Fokus.Font("cWhite s11")
Fokus.Margin(0, 0)
Fokus.Color(454545, Settings.Color)
Fokus.Add("Button", "Hidden gFokusSubmit Default")
Fokus.Add("Edit", "x0 y0 w505 h25 gFokusEdit")
Fokus.Add("ListView", "x-3 y25 w508 h9999 gFokusListView -E0x200 -Grid -TabStop -Hdr -Multi +AltSubmit", "Result")
Fokus.Options("-Caption +AlwaysOnTop +Border +ToolWindow")
Fokus.SetEvents({Escape:"FokusClose"})

; parse registry for items
Items.Search()

; save the xml file
xml.save(true)

ItemList.Lists[Settings.List].Refresh()

; populate listview
EditAction()

; RowSnap at start in case user changed font.size
if Settings.RowSnap
	Main.RowSnap(Settings.Pos.Height)

; size gui
Main.Pos(Settings.Pos.X, Settings.Pos.Y, Settings.Pos.Width, Settings.Pos.Height)

Hotkey.Bind(Settings.Hotkeys.Main, Main.Toggle.Bind(Main))
Hotkey.Bind(Settings.Hotkeys.Fokus, "Fokus")
Hotkey.Bind("Enter", "Submit", Main.hwnd)
Hotkey.Bind("Escape", "Hotkeys", Main.hwnd)
Hotkey.Bind("Delete", "Hotkeys", Main.hwnd)
Hotkey.Bind("^Z", "Hotkeys", Main.hwnd)
Hotkey.Bind("WheelUp", "Hotkeys", Main.hwnd)
Hotkey.Bind("WheelDown", "Hotkeys", Main.hwnd)
Hotkey.Bind("^WheelUp", Main.FontSize.Bind(Main, 1), Main.hwnd)
Hotkey.Bind("^WheelDown", Main.FontSize.Bind(Main, -1), Main.hwnd)
Hotkey.Bind("~Ctrl Up", Main.SizeList.Bind(Main), Main.hwnd)
Hotkey.Bind("Up", "Hotkeys", Main.hwnd)
Hotkey.Bind("Down", "Hotkeys", Main.hwnd)
Hotkey.Bind("*MButton", "Hotkeys", Main.hwnd)
Hotkey.Bind("^Backspace", "Hotkeys", Main.hwnd)
Hotkey.Bind("+Up", "Hotkeys", Main.hwnd)
Hotkey.Bind("+Down", "Hotkeys", Main.hwnd)

if FileExist("old") {
	FileDelete old
	Tray.Tip("Succesfully updated to version " version "!")
}

for a, b in xml.get("//plugins/plugin")
	if b.run
		Run(A_WorkingDir "\Plugins\" b.name ".ahk")

SetTimer, ScanTimer, % Settings.ScanTime * 1000 * 60

return

Convert() {
	for a, b in ["items", "del_items"] {
		IniRead, file, % A_Appdata "\Columbus\" b ".ini"
		Loop, parse, file, % "`n", % "`r"
		{
			IniRead, dir, % A_Appdata "\Columbus\" b ".ini", % A_LoopField, dir
			IniRead, icon, % A_Appdata "\Columbus\" b ".ini", % A_LoopField, icon
			IniRead, freq, % A_Appdata "\Columbus\" b ".ini", % A_LoopField, freq
			Items.Add({name:A_LoopField, run:dir, icon:icon, freq:freq, hide:(b = "del_items" ? 1 : 0)})
		}
	}
}

ScanTimer:
if Main.IsVisible
	return
Items.Search(), Main.SetText()
if Settings.UpdateCheck
	Update()
return

Exit:
Plugin.Exit()
ObjRegisterActive(Plugin, "") ; revoke plugin object
xml.save(true)
ExitApp

#Include lib\Class Commands.ahk
#Include lib\Class CtlColors.ahk
#Include lib\Class FokusGui.ahk
#Include lib\Class Gui.ahk
#Include lib\Class Hotkey.ahk
#Include lib\Class Items.ahk
#Include lib\Class List.ahk
#Include lib\Class MainGui.ahk
#Include lib\Class Plugin.ahk
#Include lib\Class Settings.ahk
#Include lib\Class Tray.ahk
#Include lib\Class xmlfile.ahk
#Include lib\EditAction.ahk
#Include lib\Fokus.ahk
#Include lib\Functions.ahk
#Include lib\Fuzzy.ahk
#Include lib\Hotkeys.ahk
#Include lib\ListAction.ahk
#Include lib\Manager.ahk
#Include lib\Menus.ahk
#Include lib\Settings.ahk
#Include lib\String.ahk
#Include lib\Submit.ahk
#Include lib\Update.ahk