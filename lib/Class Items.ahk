Class Items extends ItemList {
	static name_keywords := ["unin", "driver", "help", "update", "NVIDIA", "eReg", ".NET", "Microsoft Security Client", "Battlelog", "AutoHotkey " A_AhkVersion]
	, dir_keywords := ["unin", "driver", "help", "update", "{", "["]
	
	; Pack all the .scan() calls into one function that is called from outside
	Search() {
		this.scan("HKEY_CURRENT_USER", "Software\Microsoft\Windows\CurrentVersion\Uninstall")
		this.scan("HKEY_LOCAL_MACHINE", "Software\Microsoft\Windows\CurrentVersion\Uninstall")
		this.scan("HKEY_LOCAL_MACHINE", "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
		this.chrome_apps()
		if Settings.Verify
			this.Verify()
		this.Refresh()
		this.FreqSort := Settings.FreqSort
	}
	
	; detects chrome apps
	chrome_apps() {
		EnvGet, ProgFiles, ProgramFiles(x86)
		Loop, Files, %A_AppData%\..\Local\Google\Chrome\User Data\Default\Web Applications\*.*, R
			if (A_LoopFileExt = "ico")
				this.add({name:SubStr(A_LoopFileName, 1, -4)
		, run:"""" ProgFiles "\Google\Chrome\Application\chrome.exe"" --app-id=" SubStr(A_LoopFileDir, InStr(A_LoopFileDir, "_crx_") + 5)
		, icon:A_LoopFileFullPath
		, freq:0},,,, true)
	}
	
	; Verifies items
	Verify() {
		for a, b in xml.get("//items/item")
			if !b.run.contains("steam://rungameid/", "--app-id=") && !FileExist(b.run)
				xml.Delete(a)
	}
	
	; Loops & parses the registry for programs to add to the list
	scan(key, subkey) {
		Loop, % key, % subkey, 1, 1
			if (A_LoopRegName = "DisplayName") {
				DisplayName := RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayName")
				DisplayIcon := trim(RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayIcon"), """").split(",")[1]
				InstallLocation := RegRead(A_LoopRegKey, A_LoopRegSubkey, "InstallLocation")
				FileLocation := ""
				SplitPath, DisplayIcon,,, ext
				if (ext = "exe") ; the file with the icon is the target file
					FileLocation := DisplayIcon
				else if InStr(A_LoopRegSubKey, "Steam App ") ; it's a steam application
					FileLocation := "steam://rungameid/" A_LoopRegSubKey.split(" ")[3]
				else if InstallLocation ; if all fails, attempt to parse the InstallLocation with search_directory()
					FileLocation := this.search_directory(DisplayName, InstallLocation)
				;FileLocation := RegExReplace(FileLocation, "\\\\", "\")
				if DisplayName.length && FileLocation && DisplayIcon && !FileLocation.contains(this.dir_keywords) && !DisplayName.contains(this.name_keywords)
					this.Add({name:DisplayName, run:FileLocation, icon:DisplayIcon, freq:0},,,, true)
			}
	}
	
	; Searches a directory for the .exe which is most likely to be the correct one based on the name, not perfect! I dare you to make one that works better though >:D
	search_directory(name, dir) {
		; determines how much filesize matters
		size_weight := 0.65
		
		if FileExist(dir "\" name ".exe") ; trying some simple FileExists before we go to the more advanced method
			return dir "\" name ".exe"
		if FileExist(dir "\" RegExReplace(name, " ", "") ".exe")
			return dir "\" RegExReplace(name, " ", "") ".exe"
		arr := []		; create a temp array
		Loop % dir "\*.exe", 1, ; loop the dir to find all the exe files
			if (short_exe := SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, ".",, 0) - 1)).contains(this.name_keywords) { 		; check that it doesn't contain any excluded words
				FileGetSize, size, % A_LoopFileFullPath, K 			; get filesize
		if (size > max_size)			; get the size of the biggest size
			max_size := size
		i := 0, temp := name
		Loop, parse, short_exe			; find the number of matching letters
			if (pos := InStr(temp, A_LoopField)) {
				temp := SubStr(temp, 1, pos - 1) . SubStr(temp, pos + 1)
				i++			; i = number of letters matched
			} arr[A_LoopFileName, "match"] := i / short_exe.length	; put the letter match ratio in the array
		arr[A_LoopFileName, "size"] := size 					; put the filesize in the array
	}
	for a, b in arr 			; apply weight to the sizes
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
}