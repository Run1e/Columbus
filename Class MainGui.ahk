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