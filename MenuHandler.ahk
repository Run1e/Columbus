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