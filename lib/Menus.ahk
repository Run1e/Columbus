MenuHandler(menu, item) {
	if (menu = "Tray") {
		if (item = "Show Columbus")
			Main.Toggle()
		else
			
		if (item = "Reset GUI position") {
			Settings.Pos := Settings.default.Pos
			if Settings.RowSnap
				Main.RowSnap(2)
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
			throw Exception("Not implemented")
		else
			
		if (item = "Exit")
			ExitApp
		else
			
		if (item = "Show Commands") {
			if !Main.IsVisible
				Main.Show()
			Main.SetText(Settings.Prefix)
		}
	} else if (menu = "Plugins") ; run plugin
		Run("Plugins\" item ".ahk")
}

MenuHandler:
MenuHandler(A_ThisMenu, A_ThisMenuitem)
return

