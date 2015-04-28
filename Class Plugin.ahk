Class Plugin {
	__New() {
		this.Scripts:=[]
	}
	
	__Call(a, b) {
		if IsFunc(this[a])
			return
		if IsFunc(cmd[a])
			return cmd[a](b)
		return %a%(b)
	}
	
	Close() {
		for a, b in this.Scripts
			PostMessage 0x10,,,, ahk_id %b% ; WM_CLOSE=0x10
	}
	
	AutoClose(hwnd) {
		this.Scripts.Insert(hwnd)
		Print("Plugin connected: " hwnd)
	}
	
	tip(text) {
		Tray.Tip(text)
	}
	
	run(input) {
		RunFunc(input)
	}
	
	set(key, value) {
		Settings.Write(key, value)
	}
}