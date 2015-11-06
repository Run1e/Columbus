MenuHandler(menu, item) {
	if Plugin.Event("OnMenu", false, menu, item)
		return
	if (menu = "Tray") {
		if (item = "Show Columbus")
			Main.Toggle()
		else
			
		if (item = "Reset GUI position") {
			Settings.Pos := Settings.default.Pos
			if Settings.RowSnap
				Main.RowSnap(Settings.Pos.Height)
			Main.Pos(Settings.Pos.X, Settings.Pos.Y, Settings.Pos.Width, Settings.Pos.Height)
		} else
			
		if (item = "Check for Updates")
			Update(true)
		
		if (item = "Settings")
			Settings()
		else
			
		if (item = "Manager")
			Manager()
		else
			
		if (item = "Report a bug") 
			run https://github.com/Run1e/Columbus/issues/new
		else
			
		if (item = "Show Commands") {
			if !Main.IsVisible
				Main.Show()
			Main.SetText(Settings.Prefix)
		} else
			
		if (item = "Exit") {
			Plugin.Exit()
			ObjRegisterActive(Plugin, "") ; revoke plugin object
			xml.save(true)
			ExitApp
		}
	} else if (menu = "Plugins") ; run plugin
		Run("Plugins\" item ".ahk")
	Plugin.Event("OnMenu", true, menu, item)
}

MenuHandler:
MenuHandler(A_ThisMenu, A_ThisMenuItem)
return