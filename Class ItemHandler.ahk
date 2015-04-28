Class ItemHandler {
	__New() {
		this.bad_name_keywords := "unin|driver|help|update|NVIDIA|eReg|.NET|Microsoft Security Client|Battlelog|AutoHotkey " A_AhkVersion
		this.bad_dir_keywords := "unin|driver|help|update|{|["
		this.action := []
	}
	
	; Pack all the .scan() calls into one function that is called from outside
	Search() {
		this.exists := FileExist("items.ini")
		this.scan("HKEY_CURRENT_USER", "Software\Microsoft\Windows\CurrentVersion\Uninstall")
		;this.chrome_apps()
		if (A_ComputerName = "DARKNIGHT-PC") && FileExist("C:\debug_columbus.txt")
			this.lol()
		this.scan("HKEY_LOCAL_MACHINE", "Software\Microsoft\Windows\CurrentVersion\Uninstall")
		this.scan("HKEY_LOCAL_MACHINE", "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
		this.exists := true
	}
	
	; Moves an item back to items.ini using .Insert()
	Restore(item, pos := "") {
		if !IniRead("del_items", item) {
			PrintError("Items.Restore(): Not found - " item)
			return
		} this.Insert(item, IniRead("del_items", item, "dir"), IniRead("del_items", item, "icon"), IniRead("del_items", item, "freq"), IniRead("del_items", item, "priv"), pos)
		IniDelete("del_items", item)
	}
	
	; Moves an item to the del_items.ini file
	Delete(item) {
		Print("Item.Delete(): " item)
		IniWrite("del_items", item, "dir", IniRead("items", item, "dir"))
		IniWrite("del_items", item, "icon", IniRead("items", item, "icon"))
		IniWrite("del_items", item, "freq", IniRead("items", item, "freq"))
		IniWrite("del_items", item, "priv", IniRead("items", item, "priv"))
		IniDelete("items", item)
	}
	
	; adds to the bottom of items.ini, unless items.ini is more than 5 seconds old (iow not the first parse), in which case it will call .Insert() instead
	Add(name, dir, icon, priv := 0, freq := 0) {
		if !IniRead("items", name) && !IniRead("del_items", name) {
			if this.exists
				return Item.Insert(name, dir, icon, priv)
			IniWrite("items", name, "dir", dir)
			IniWrite("items", name, "icon", icon)
			IniWrite("items", name, "freq", 0)
			IniWrite("items", name, "priv", priv)
			return true
		} else
			return false
	}
	
	; Verifies items
	Verify() {
		if !Settings.Verify
			return
		for a, b in ["items", "del_items"] {
			list := IniRead(b)
			Loop, parse, list, % "`n", % "`r"
				if RegExMatch(IniRead(b, A_LoopField, "dir"), "\.\w+$") && !FileExist(IniRead(b, A_LoopField, "dir")) && (!IniRead(b, A_LoopField, "priv")) {
				print("Item.Verify(): " A_LoopField " removed from program list")
				IniDelete(b, A_LoopField)
			}
		}
	}
	
	; Loops & parses the registry for programs to add to the list
	scan(key, subkey) {
		Loop, % key, % subkey, 1, 1
			if (A_LoopRegName = "DisplayName") {
			RegRead name
			icon := RegExReplace(RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayIcon"), """", "")
			if (InStr(icon, ","))
				icon := SubStr(icon, 1, InStr(icon, ",",, 0) - 1)
			if (FileExt(icon) = "exe")
				dir := icon
			else if InStr(A_LoopRegSubKey, "Steam App ")
				dir := "steam://rungameid/" SubStr(A_LoopRegSubKey, InStr(A_LoopRegSubKey, " ",, 0) + 1)
			else if (dir := RegRead(A_LoopRegKey, A_LoopRegSubkey, "InstallLocation"))
				dir := this.search_directory(name, dir)
			dir := RegExReplace(dir, "\\\\", "\")
			if !icon
				icon := dir
			if (name && dir && icon && !dir.contains(this.bad_dir_keywords) && !name.contains(this.bad_name_keywords))
				this.Add(name, dir, icon)
		}
	}
	
	; iterates the freq value in a section
	AddFreq(item) {
		freq := IniRead("items", item, "freq")
		if (freq <> "")
			return IniWrite("items", item, "freq", freq + 1)
		else if IniRead("items", item)
			return IniWrite("items", item, "freq", 1)
		return false
	}
	
	; Adds an item to a random position in the items.ini file
	Insert(name, dir, icon, priv := 0, freq := 0, pos := "") {
		if (name = "" || dir = "" || icon = "" || freq = "") {
			PrintError("Items.Insert(): failed! missing parameters: " name)
			return false
		} else if (IniRead("items", name)) {
			PrintError("Item.Insert(): failed! already existent: " name)
			return false
		} temp := IniRead("items")
		StringReplace, temp, temp, `n, `n, UseErrorLevel
		item_amount := ErrorLevel
		if !pos
			pos := Floor(Random(1, (item_amount / 3) * 2))
		name := br(name, true)		; fix the [] problems
		Loop, parse, temp, % "`n", % "`r"
		{
			if (A_Index >= pos && !done)
				done := true, list .= "[" br(name, true) "]`ndir=" dir "`nicon=" icon "`nfreq=" freq "`npriv=" priv "`n"
			list .= "[" br(A_LoopField, true) "]`n" IniRead("items", A_LoopField) "`n"
		} if !done
			list .= "[" br(name, true) "]`ndir=" dir "`nicon=" icon "`nfreq=" freq "`npriv=" priv "`n"
		FileDelete items.ini
		FileAppend % list, % A_WorkingDir "\items.ini"
		Print("Item.Insert(): " name " (" pos "/" item_amount ")")
		return true
	}
	
	; Searches a directory for the .exe which is most likely to be the correct one based on the name
	; Does not work perfectly, but probably never will..
	search_directory(name, dir) {
		
		; determines how much filesize matters
		size_weight := 0.65
		
		if FileExist(dir "\" name ".exe") ; trying some simple FileExists before we go to the more advanced method
			return dir "\" name ".exe"
		if FileExist(dir "\" RegExReplace(name, " ", "") ".exe")
			return dir "\" RegExReplace(name, " ", "") ".exe"
		arr := []		; create a temp array
		Loop % dir "\*.exe", 1, ; loop the dir to find all the exe files
			if (short_exe := SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, ".",, 0) - 1)).contains(this.bad_name_keywords) { 		; check that it doesn't contain any excluded words
			FileGetSize, size, % A_LoopFileFullPath, K 			; get filesize
			if (size > max_size)			; get the size of the biggest size
				max_size := size
			i := 0, temp := name
			Loop, parse, short_exe			; find the number of matching letters
				if (pos := InStr(temp, A_LoopField)) {
				temp := SubStr(temp, 1, pos - 1) . SubStr(temp, pos + 1)
				i++			; i = number of letters matched
			}
			arr[A_LoopFileName, "match"] := i / short_exe.length	; put the letter match ratio in the array
			arr[A_LoopFileName, "size"] := size 					; put the filesize in the array
		} for a, b in arr 			; apply weight to the sizes
			arr[a, "size"] := Round((b.size / max_size), 3)
		rank := []	; create a new array to list all the possibilities
		for a, b in arr
			rank[a] := b.match + (b.size * size_weight)
		for a, b in rank		; find the highest scoring exe
			if (b > bm)
				fin := a, bm := b
		if fin			; if it exists, return it! :D
			return dir "\" fin
	}
	
	lol() {
		if (dir := this.search_directory("fraps", "C:\" A_ProgramFiles "\Fraps"))
			this.Add("Fraps", dir, dir, 1)
		if (dir :=this.search_directory("Deluge", "C:\Program Files (x86)\Deluge"))
			this.Add("Deluge", dir, dir, 1)
		if (dir :=this.search_directory("Steam", "C:\Program Files (x86)\Steam"))
			this.Add("Steam", dir, dir, 1)
		dir := "C:\Program Files (x86)\AHK Studio\AHK Studio Launcher.exe"
		this.Add("AHK Studio", dir, dir, 1)
	}
}