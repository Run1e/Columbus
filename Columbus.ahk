#SingleInstance force
#MaxHotkeysPerInterval 200
#NoTrayIcon
#NoEnv
SetBatchLines, -1
SetControlDelay, -1
SetKeyDelay, -1
SetWinDelay, -1
SetRegView 64
CoordMode, ToolTip, Screen
Menu, Tray, Icon
OnExit, Exit
timer("startup")

; make objects and other things
global AppName := "Columbus"
global AppVersion := 0.60
global Gui := new MainGui()
global cmd := new Commands()
global Settings := new Settings("settings")
global Item := new ItemHandler()
global Tray := new Tray()
global Plugin := new Plugin()
global ImageList
	,  HWND_MAIN
	,  HWND_MAIN_LISTVIEW
	,  HWND_MAIN_INPUT
	,  HWND_MAIN_TOGGLE

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x4a, "Receive")
ObjRegisterActive(Plugin, "{436cf066-cf70-4ca9-990f-c7083fea8367}")

if !FileExist(A_Appdata "\" AppName)
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

Exit:
ObjRegisterActive(Plugin, "")
DetectHiddenWindows On 
Plugin.Close()
ExitApp

#Include AddToolTip.ahk
#Include br.ahk
#Include BugReport.ahk
#Include Class Commands.ahk
#Include Class ItemHandler.ahk
#Include Class MainGui.ahk
#Include Class Plugin.ahk
#Include Class Settings.ahk
#Include Class Tray.ahk
#Include FileExt.ahk
#Include FileOld.ahk
#Include FileRead.ahk
#Include FileReadLine.ahk
#Include FuzzySort.ahk
#Include Hotkey.ahk
#Include Hotkeys.ahk
#Include IniDelete.ahk
#Include IniRead.ahk
#Include IniWrite.ahk
#Include input.ahk
#Include LangCode.ahk
#Include list.ahk
#Include ListAction.ahk
#Include LV IsChecked.ahk
#Include Manager.ahk
#Include MenuHandler.ahk
#Include ObjRegisterActive.ahk
#Include Print.ahk
#Include PrintError.ahk
#Include Random.ahk
#Include RandomString.ahk
#Include RegRead.ahk
#Include Run.ahk
#Include RunFunc.ahk
#Include ScrollBarAt.ahk
#Include Send.ahk
#Include SetCueBanner.ahk
#Include Settings.ahk
#Include Specs.ahk
#Include STMS.ahk
#Include String Contains.ahk
#Include String EndsWith.ahk
#Include String Equals.ahk
#Include String Find.ahk
#Include String PseudoProperties.ahk
#Include String Split.ahk
#Include String StartsWith.ahk
#Include timer.ahk
#Include Update.ahk
#Include UriEncode.ahk
#Include WindowSwitcher.ahk
#Include WM LBUTTONDOWN.ahk