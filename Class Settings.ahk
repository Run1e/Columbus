Class Settings {
	__New(file) {
		this.file := file
		this.defaults := {"Hotkey": 			"^!P"
						, "WindowHotkey": 		"^!O"
						, "StartUp": 			true
						, "UpdateCheck": 		true
						, "Debug": 				false
						, "ForceSequential": 	false
						, "ScanTime":			5
						, "Verify":				true
						, "SortByPopularity":	true
						, "DownloadFileExt": 	FileExt(A_ScriptFullPath)
						, "LastUpdatePrompt": 	AppVersion
						, "X": 					A_ScreenWidth - 502
						, "Y":					A_ScreenHeight - 392
						, "Width": 				500
						, "Height": 			350}
	}
	
	; Sets all values to default or just the ones passed in the array x
	Default(x := "") {
		if x {
			for a, b in x
				if (b && this.defaults[b] <> "")
					this.Write(b, this.defaults[b])
		} else
			for a, b in this.defaults
				this.Write(a, b)
	}
	
	; Reads all the keys listed in .defaults
	Read() {
		for a, b in this.defaults
			if ((this[a] := IniRead(this.file, "Settings", a)) = "") && (!InStr(a, "Hotkey"))
				this.Write(a, b)
	}
	
	
	; Writes a key
	Write(key, value) {
		IniWrite(this.file, "Settings", key, value)
		this[key] := value
		this.action(key)
	}
	
	; Deletes a key
	Delete(key) {
		IniDelete(this.file, "Settings", key)
		this[key] := ""
	}
	
	action(key) {
		if (key = "StartUp") {
			if this.StartUp
				RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, % AppName, % A_ScriptFullPath
			else
				RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, % AppName
		} else if (key = "ScanTime") {
			SetTimer, ScanTimer, % this.ScanTime * 1000 * 60
		}
	}
}