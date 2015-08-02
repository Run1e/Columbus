#SingleInstance force
; GUID generator https://www.guidgenerator.com/online-guid-generator.aspx

OnExit, Disconnect

global x, Gui, xml, hwnd
try
	x:=ComObjActive("Columbus")
catch e {
	msgbox Columbus is not running!
	ExitApp
}
x.Connect(A_ScriptHwnd, Events)
Gui := x.get("Main")
xml := x.get("xml")
Items := x.get("Items")
Gui Margin, 10, 10
Gui Font, s10
Gui Add, Text,, Input:
Gui Add, Edit, vEditInput gInputAction x75 w800 yp-3, % x.GetInput()
Gui Add, Text, y40 x10, Selected:
Gui Add, Edit, vEditText x75 w800 yp-3 ReadOnly, % x.GetText()
Gui Add, Button, gPrintList x10, Program list
Gui Add, Button, gPrintHotkey x100 yp, Hotkeys
Gui Add, Button, gPrintSettings x170 yp, Settings
Gui Add, Button, gGuiShow x240 yp+, Gui Show
Gui Add, Button, gGuiHide x315 yp, Gui Hide
Gui Add, Button, gGuiToggle x390 yp, Gui Toggle
Gui Add, ListView, r14 x10 w870 -Hdr -E0x200 +Grid, Debug
Gui Show, % (A_ComputerName = "DARKNIGHT-PC" ? "x-960 y-60" : "") " w900 h455 NoActivate", Columbus Debug Window
Gui +hwndhwnd +MinSize900x300 +MaxSize900x1024 +Resize
LV_ModifyCol(1, 850)
return

test:

/*
	Loop, D:\Documents\AHK\*.ahk
		x.add("ahklist/ahk", A_LoopFileName, A_LoopFileFullPath, A_AhkPath)
	return
*/

Items.Refresh()
x.Input("")
return

InputAction:
ControlGetFocus, focus
if (focus = "Edit1")
	x.Input(EditInput)
return

GuiSize:
GuiControl, Move, SysListView321, % "h" A_GuiHeight - 120
ControlSend, SysListView321, {End}, % "ahk_id" hwnd
return

GuiShow:
GuiHide:
GuiToggle:
Gui[SubStr(A_ThisLabel, 4)]()
return

PrintSettings:
PrintHotkey:
msgbox % x.get(SubStr(A_ThisLabel, 6))[]
return

PrintList:
Loop {
	name := x.GetText(A_Index)
	d .= name "`n"
} until (name = "")
msgbox % d
name:=d:=""
return

m(x*) {
	for a, b in x
		list.=b "`n"
	msgbox % b
}

Class Events {
	static list:=[]
	
	OnInput(done, input) {
		GuiControl,, EditInput, % input
		GuiControl,, EditText, % x.GetText()
	}
	
	Print(text) {
		msgbox % text
		this.list.InsertAt(1, text)
		LV_Add(, text)
		ControlSend, SysListView321, {End}, % "ahk_id" hwnd
	}
	
	OnSelect(num:="") {
		GuiControl,, EditText, % x.GetText()
	}
}

GuiEscape:
GuiClose:
Disconnect:
ComObjError(false)
x.Disconnect(A_ScriptHwnd)
ExitApp

label:
return