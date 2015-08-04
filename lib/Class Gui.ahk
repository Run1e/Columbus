Class Gui {
	static Instances := []
	static params := {Size:["A_GuiWidth", "A_GuiHeight"], DropFiles:["A_GuiEvent"]}
	
	__New(title := "AutoHotkey Window", options := "") {
		Gui, New, % "+hwndhwnd " options, % title
		this.hwnd := hwnd
		this.ahkid := "ahk_id" hwnd
		this.IsVisible := false
		this.Events := []
		Gui.Instances[hwnd] := this
	}
	
	__Delete() {
		this.Destroy()
	}
	
	SetDefault() {
		Gui % this.hwnd ":Default"
	}
	
	Disable() {
		Gui % this.hwnd ": +Disabled"
	}
	
	Enable() {
		Gui % this.hwnd ": -Disabled"
	}
	
	Destroy() {
		Gui % this.hwnd ":Destroy"
	}
	
	Options(options, ext := "") {
		Gui % this.hwnd ":" options, % ext
	}
	
	Show(options := "") {
		this.IsVisible := true
		Gui % this.hwnd ":Show", % options
	}
	
	Hide() {
		this.IsVisible := false
		Gui % this.hwnd ":Hide"
	}
	
	Toggle() {
		this[this.IsVisible ? "Hide" : "Show"]()
	}
	
	Pos(x := "", y := "", w := "", h := "") {
		Gui % this.hwnd ":Show", % (x.length ? "x" x : "") 
								. (y.length ? " y" y : "") 
								. (w.length ? " w" w : "") 
								. (h.length ? " h" h : "")
								. (this.IsVisible ? "" : " hide")
	}
	
	Control(cmd := "", control := "", param := "") {
		GuiControl % this.hwnd ":" (cmd.length ? cmd : ""), % (control.length ? control : ""), % (param.length ? param : "")
	}
	
	ControlGet(cmd, value := "", control := "") {
		ControlGet, out, % cmd, % (value.length ? value : ""), % (control.length ? control : ""), % this.ahkid
		return out
	}
	
	GuiControlGet(cmd := "", control := "", param := "") {
		GuiControlGet, out, % (cmd.length ? cmd : ""), % (control.length ? control : ""), % (param.length ? param : "")
		return out
	}
	
	Add(control, options := "", param := "") {
		if InStr(options, "hwnd")
			return m("HWNDS are returned!")
		Gui % this.hwnd ":Add", % control, % options " hwndcontrolhwnd", % param
		return controlhwnd
	}
	
	Font(font := "", type := "") {
		Gui % this.hwnd ":Font", % font, % type
	}
	
	Tab(num) {
		Gui % this.hwnd ":Tab", % num
	}
	
	Color(BG, FG) {
		Gui % this.hwnd ":Color", % BG, % FG
	}
	
	Margin(x, y) {
		Gui % this.hwnd ":Margin", % x, % y
	}
	
	GetText(control := "Edit1") {
		ControlGetText, text, % control, % this.ahkid
		return text
	}
	
	SetText(control := "Edit1", text := "") {
		this.Control(, control, text)
	}
	
	SetEvents(x) {
		for a, b in x
			this.Events[a] := b
	}
}

GuiSize:
GuiClose:
GuiEscape:
GuiDropFiles:
params := []
for a, b in Gui.Params[SubStr(A_ThisLabel, 4)]
	params.Insert(%b%)
for a, b in Gui.Instances 
	if (a = A_Gui+0) {
		if IsLabel(b["Events"][SubStr(A_ThisLabel, 4)])
			SetTimer, % b["Events"][SubStr(A_ThisLabel, 4)], -1
		else if A_ThisLabel.contains("escape", "close")
			Gui % a ":Destroy"
		else
			b["Events"][SubStr(A_ThisLabel, 4)].Call(params*)
	}
return