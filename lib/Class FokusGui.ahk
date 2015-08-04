Class FokusGui extends Gui {
	Show(opt := "") {
		this.IsVisible := true
		Gui % this.hwnd ": Show", Hide
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", Settings.Fade, "UInt", "0xa0000")
		this.Control("-Redraw", "Edit1")
		this.Control("+Redraw", "Edit1")
		Gui % this.hwnd ": Show"
	}
	
	Hide() {
		this.IsVisible := false
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", Settings.Fade, "UInt", "0x90000")
		Gui % this.hwnd ": Hide"
	}
}