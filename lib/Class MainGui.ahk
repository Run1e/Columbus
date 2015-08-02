Class MainGui extends Gui {
	Show(force := false) {
		if !force
			if Plugin.Event("OnShow", false, force)
				return
		this.IsVisible := true
		Hotkey.Disable(Settings.Hotkeys.Fokus)
		Gui % this.hwnd ": Show", Hide
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", Settings.Fade, "UInt", "0xa0000")
		this.Control("-Redraw", "Edit1")
		this.Control("+Redraw", "Edit1")
		Gui % this.hwnd ": Show"
		Plugin.Event("OnShow", true)
	}
	
	Hide(force := false) {
		if !force
			if Plugin.Event("OnHide", false, force)
				return
		this.IsVisible := false
		Hotkey.Enable(Settings.Hotkeys.Fokus)
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", Settings.Fade, "UInt", "0x90000")
		Gui % this.hwnd ": Hide"
		this.SetText()
		Plugin.Event("OnHide", true)
	}
	
	SetText(text := "") {
		GuiControl % this.hwnd ":", Edit1, % text
	}
	
	DropFiles(GuiEvent) {
		
		if Plugin.Event("OnDropFiles", false, GuiEvent) || (Settings.List != "items")
			return
		
		for a, file in GuiEvent.split("`n") {
			FileGetShortcut, % file, target,, Args
			SplitPath, file,,, ext, name
			run := (target ? target : file) . (Args ? " " Args : "")
			if (node := xml.ssn("//" Settings.List "[@name='" name "']")) {
				if (ext != "exe") {
					m("'" name "' does not point to an executable")
					continue
				} else if xml.ea(node).hide {
					MsgBox, 52, Columbus, % "'" name "' already exists but is hidden.`n`nDo you want to unhide it?"
					ifMsgBox yes
						node.RemoveAttribute("hide")
				} else {
					m("'" name "' already exists in the list")
					continue
				}
			}
			if (run.length && name.length)
				Items.add({name:name, run:run}), added.=name "`n"
		} if added {
			Items.Refresh(), this.SetText()
			TrayTip, Programs added, % added
		}
		
		Plugin.Event("OnDropFiles", true)
		
	}
	
	FontSize(i) {
		MouseGetPos,,,, control
		if (control = "SysListView321") {
			Settings.Font := {Size:bound(Settings.Font.Size + i, 8, 24)}
			this.Font("s" Settings.Font.Size)
			this.Control("Font", "SysListView321")
			this.GetRowHeight() ; set Settings.Rows so Size() can resize the spacer
			this.Size(Settings.Pos.Width, Settings.Pos.Height, true) ; size controls
		}
	}
	
	; function calculating the new window height if RowSnap is enabled
	; mode 1 = don't add 2 pixels to y value and subtract 2 from height ; mode 2 = add 2 pixels to y value and subtract 2 from height
	RowSnap(mode:=0, y:="", h:="") {
		pixels := 27
		y := y.length ? y : Settings.Pos.Y
		h := h.length ? h : Settings.Pos.Height
		rowheight := this.GetRowHeight()
		h_old:=h
		Settings.Rows := Round((h_old-pixels)/rowheight) ; rowcount=height-excess/rowheight
		h := ((Settings.Rows*rowheight)+pixels) ; height := (rowcount*rowheight)+excess
		y -= (h-h_old)
		if (h.length && y.length)
			Settings.Pos := {Y:y+(mode>1?2:0), Height:h-(mode?2:0)}
	}
	
	SetRows(rows) {
		ControlGet, lvhwnd, hwnd,, SysListView321, % this.ahkid
		VarSetCapacity(rect,4*A_PtrSize)
		SendMessage,% 0x1000+14,0, &rect,, % "ahk_id" lvhwnd
	}
	
	GetRowHeight() {
		ControlGet, lvhwnd, hwnd,, SysListView321, % this.ahkid
		VarSetCapacity(rect,4*A_PtrSize)
		SendMessage,% 0x1000+14,0, &rect,, % "ahk_id" lvhwnd
		Settings.Rows := Round((Settings.Pos.Height-27)/(height := NumGet(rect,12,"uint")-NumGet(rect,4,"uint")))
		return height
	}
	
	Move() {
		if Plugin.Event("OnResize", false)
			return
		Hotkey.Disable(Settings.Hotkeys.Main)
		Hotkey.Disable(Settings.Hotkeys.Fokus)
		Hotkey.Disable("~Ctrl Up")
		Hotkey.Bind("Escape", "stopmove", Main.hwnd)
		Main.Control("Hide", "SysListView321")
		Main.Control("Hide", "Edit1")
		Main.Control("Show", "Static1")
		if !WinActive(Main.ahkid)
			Main.Show()
		Main.Options("+Resize")
		return
		
		stopmove:
		Main.Options("-Resize")
		WinGetPos, x, y, w, h, % Main.ahkid
		Main.Control("Show", "SysListView321")
		Main.Control("Show", "Edit1")
		Main.Control("Hide", "Static1")
		Main.Control("Focus", "Edit1")
		if (x.length && y.length && w.length && h.length) {
			if Settings.RowSnap
				Main.RowSnap(1, y, h), Settings.Pos := {X:x, Width:w-2}
			else
				Settings.Pos := {X:x, Y:y, Width:w-2, Height:h-2}
		} else ; failed :~)
			Settings.Pos := Settings.default.Pos
		Main.Pos(Settings.Pos.X, Settings.Pos.Y, Settings.Pos.Width, Settings.Pos.Height)
		Main.Size(Settings.Pos.Width, Settings.Pos.Height)
		Plugin.Event("OnResize", true)
		Hotkey.Enable(Settings.Hotkeys.Main)
		Hotkey.Enable(Settings.Hotkeys.Fokus)
		Hotkey.Enable("~Ctrl Up")
		Hotkey.Bind("Escape", "Hotkeys", Main.hwnd)
		return
	}
	
	; size the listview item width, part of Main.Size()
	SizeCol() {  ;#[add := false]
		Main.SetDefault()
		LV_ModifyCol(1, Settings.Pos.Width - (LV_GetCount() <= Settings.Rows ? 0 : 17))
	}
	
	; size the controls to fit.
	Size(w, h) {
		this.Control("Move", "Edit1", "w" w " y" h - 25)
		this.Control("Move", "SysListView321", "w" w " h" h - 25)
		this.Control("Move", "Static1", "x" w / 2 - 102 " y" h / 2 - 21)
		this.SizeCol()
	}
	
	; runs after ctrl has been released
	SizeList() {
		if Settings.RowSnap
			Main.RowSnap(2)
		Main.Size(Settings.Pos.Width, Settings.Pos.Height)
		Main.Pos(, Settings.Pos.Y,, Settings.Pos.Height)
	}
}