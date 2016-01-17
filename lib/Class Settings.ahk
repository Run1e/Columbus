Class Settings {
	__New() {
		for a, b in this.default := {   Hotkeys: 			{Main:"^!P"}
								, StartUp: 			true
								, UpdateCheck: 		true
								, Debug: 				false
								, ScanTime:			5
								, FreqSort:			true
								, Verify:				false
								, Prefix:				(A_ComputerName = "DARKNIGHT-PC" ? "." : "/") ; gonna love that punctuation mark, man
								, UpdateExt: 			FileExt(A_ScriptFullPath)
								, LastUpdatePrompt: 	0
								, List:				"items"
								, Fade:				65
								, Rows:				11
								, RowSnap:			true
								, LargeIcons:			true 
								, RunAsAdmin:			true
								, Font:				{Type:"Candara", Size:13, Bold:false}
								, Color:				"3A3A3A"
								, Compress:			true
								, Pos:				this.getpos()}
		{
			if IsObject(b) {
				for z, x in b
					if (xml.ea("//settings/" a)[z] = "") ; if attribute is empty, make it default
						xml.add("settings/" a).SetAttribute(z, x)
			} else if !xml.ssn("//settings/" a) ; if node doesn't exist, make it default
				xml.add("settings/" a).text := b
		}
	}
	
	getpos(return := true) {
		task := GetTaskbarPos(pos := WinGetPos("ahk_class Shell_TrayWnd"))
		z := {X:A_ScreenWidth-502-(task=3?pos.W:0), Y:A_ScreenHeight-357-(task=1?pos.H:0), Width:500, Height:355}
		if return
			return z
		else
			this.default.Pos := z
	}
	
	action(key, value) {
		if (key = "StartUp") {
			if value
				RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, Columbus, % A_ScriptFullPath
			else
				RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run, Columbus
		} if (key = "FreqSort")
			Items.FreqSort := value
		else if (key = "ScanTime")
			SetTimer, ScanTimer, % value * 1000
		else if (key = "List")
			ItemList.Lists[value].Refresh(), Main.SetText()
		else if (key = "Prefix") {
			if (value.length != 1)
				m("Prefix too long or too short.`n`nResetting Prefix to ""/"""), Settings.Prefix := "/"
		} else if (key = "Rows") {
			if value > 0
				Main.SetRows(value)
			else
				m("Value invalid: " value "`nKey: " key)
		} else if (key = "RunAsAdmin") {
			if !value
				m("WARNING: Some features of Columbus might not work with RunAsAdmin set to 0")
			MsgBox,52,Restart?,Do you want to restart Columbus because of the RunAsAdmin change?
			ifMsgBox yes
				reload
		} else if (InStr(key, "Pos.") = 1) {
			
		}
	}
	
	__Get(key := "") {
		if key {
			if NumGet(&(g := xml.ea("//settings/" key)), 4*A_PtrSize)
				return g
			return xml.ssn("//settings/" key).text
		} for a, b in this.default ; Settings[] print thingy
			t := xml.ssn("//settings/" a), x .= "[" a "]" (t.text <> "" ? " => " t.text: "") . (NumGet(&(g := xml.ea(t)), 4*A_PtrSize) ? "`n" pa(g,, "   ") : "") . "`n"
		return x
	}
	
	__Set(key, value) {
		if (this.default[key] <> "") && (key <> "default") {
			if IsObject(value)
				X := xml.add("settings/" key, value)
			else
				x := xml.add("settings/" key).text := value
			this.action(key, value)
			return x
		}
	}
}