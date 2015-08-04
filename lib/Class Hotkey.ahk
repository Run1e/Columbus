class Hotkey {
	__New() {
		this.Keys := []
	}
	
	; bind a hotkey to a function
	Bind(key, target, hwnd := "") { ; target = label, function reference or function name
		Hotkey, IfWinActive, % ((hwnd+=0) ? "ahk_id" hwnd : "") ; hwnd+=0 forces hex to dec
		Hotkey, % key, % (this.Keys[key].disabled ? "On" : (IsLabel(target) ? target : "HotkeyLabel")), UseErrorLevel
		return !ErrorLevel ? this.Keys[key] := {target:IsFunc(target) ? Func(target) : target, hwnd:hwnd} : ErrorLevel
	}
	
	; rebind an existing hotkey
	Rebind(key, new_key) {
		if a := this.Disable(key)
			return a
		return this.Bind(new_key, this.Keys[key].target, this.Keys[key].hwnd)
	}
	
	; enable a hotkey
	Enable(key) {
		Hotkey, IfWinActive, % (this.Keys[key].hwnd ? "ahk_id" this.Keys[key].hwnd : "")
		Hotkey, % key, On, UseErrorLevel
		return ErrorLevel ? ErrorLevel : this.Keys[key].Remove("disabled")
	}
	; disable a hotkey
	Disable(key) {
		Hotkey, IfWinActive, % (this.Keys[key].hwnd ? "ahk_id" this.Keys[key].hwnd : "")
		Hotkey, % key, Off, UseErrorLevel
		return ErrorLevel ? ErrorLevel : !(this.Keys[key].disabled := true)
	}
	
	; returns a text representation of the hotkeys
	__Get() {
		return pa(this.Keys)
	}
}

HotkeyLabel:
Hotkey.Keys[A_ThisHotkey].target.Call(A_ThisHotkey)
return