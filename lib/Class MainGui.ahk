Class MainGui extends Gui {
	Show(force := false) {
		if !force
			if Plugin.Event("OnShow", false, force)
				return
		this.IsVisible := true
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
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", Settings.Fade, "UInt", "0x90000")
		Gui % this.hwnd ": Hide"
		this.SetText()
		Plugin.Event("OnHide", true)
	}
	
	AltRows() { ; wrapper
		this.CLV.AlternateRows(hexshade(Settings.Color, 2))
	}
	
	SetText(text := "") {
		GuiControl % this.hwnd ":", Edit1, % text
	}
	
	DropFiles(GuiEvent) {
		
		if Plugin.Event("OnDropFiles", false, GuiEvent)
			return
		
		for a, file in GuiEvent.split("`n") {
			FileGetShortcut, % file, target,, Args
			SplitPath, file,,, ext, name
			run := (target ? target : file) . (Args ? " " Args : "")
			if (node := xml.ssn("//items[@name='" name "']")) {
				if (ext != "exe") {
					m("'" name "' does not point to an executable")
					continue
				} else if xml.ea(node).hide {
					MsgBox, 52, Columbus, % "'" name "' already exists but is hidden.`n`nDo you want to unhide it?"
					ifMsgBox yes
						node.Removeute("hide")
				} else {
					m("'" name "' already exists in the list")
					continue
				}
			}
			if (run.length && name.length)
				Items.add({name:name, run:run}), added.=name "`n"
		} if added {
			Items.Refresh(), this.SetText(), this.AltRows()
			TrayTip, Programs added, % added
		}
		
		Plugin.Event("OnDropFiles", true)
		
	}
	
	Move() {
		if Plugin.Event("OnResize", false)
			return
		Hotkey.Disable(Settings.Hotkeys.Main)
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
			Settings.Pos := {X:x, Y:y, Width:w-2, Height:h-2}
			if Settings.RowSnap
				Main.RowSnap(h)
		} else ; failed :~)
			Settings.Pos := Settings.default.Pos
		Main.Pos(Settings.Pos.X, Settings.Pos.Y, Settings.Pos.Width, Settings.Pos.Height)
		Main.Size(Settings.Pos.Width, Settings.Pos.Height)
		Hotkey.Enable(Settings.Hotkeys.Main)
		Hotkey.Enable("~Ctrl Up")
		Hotkey.Bind("Escape", "Hotkeys", Main.hwnd)
		Plugin.Event("OnResize", true)
		return
	}
	
	Pos(x := "", y := "", w := "", h := "") {
		Gui % this.hwnd ":Show", % (x.length ? "x" x : "") 
							. (y.length ? " y" y : "") 
							. (w.length ? " w" w : "") 
							. (h.length ? " h" h : "")
							. (this.IsVisible ? "" : " hide")
		arr := []
		if x.length
			arr.X := x
		if y.length
			arr.Y := y
		if w.length
			arr.Width := w
		if h.length
			arr.Height := h
		Settings.Pos := arr
	}
	
	FontSize(i) {
		MouseGetPos,,,, control
		if (control = "SysListView321") {
			Settings.Font := {Size:bound(Settings.Font.Size + i, 8, 24)}
			this.Font("s" Settings.Font.Size)
			this.Control("Font", "SysListView321")
			this.GetRowHeight() ; set Settings.Rows so Size() can resize the spacer
			this.Size(Settings.Pos.Width, Settings.Pos.Height, true) ; size controls
			this.ListResized := true
		}
	}
	
	RowSnap(h := "") {
		Settings.Rows := Round(((h ? h : Settings.Pos.Height) - 25) / this.GetRowHeight())
		if (Settings.Rows < 1) {
			m("An error occured, resetting gui position.")
			Settings.Pos := Settings.default.Pos
			Main.Pos(Settings.Pos.X, Settings.Pos.Y, Settings.Pos.Width, Settings.Pos.Height)
		}
	}
	
	SetRows(rows) {
		h := 25 + rows * this.GetRowHeight() ; excess + rows * rowheight
		y := Settings.Pos.Y + Settings.Pos.Height - h
		Settings.Pos := {Y:y, Height:h}
		this.Pos(Settings.Pos.X, Settings.Pos.Y, Settings.Pos.Width, Settings.Pos.Height)
	}
	
	GetRowHeight() {
		ControlGet, lvhwnd, hwnd,, SysListView321, % this.ahkid
		VarSetCapacity(rect,4*A_PtrSize)
		SendMessage,% 0x1000+14,0, &rect,, % "ahk_id" lvhwnd
		return NumGet(rect,12,"uint")-NumGet(rect,4,"uint")
	}
	
	; size the listview item width, part of Main.Size()
	SizeCol() {
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
		if !this.ListResized
			return
		if Settings.RowSnap
			Main.RowSnap(Settings.Pos.Height)
		Main.Size(Settings.Pos.Width, Settings.Pos.Height)
		Main.Pos(, Settings.Pos.Y,, Settings.Pos.Height)
		this.ListResized := false
	}
}