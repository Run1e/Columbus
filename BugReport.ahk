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