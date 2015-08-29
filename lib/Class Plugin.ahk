Class Plugin {
	__New(CLSID) {
		this.Connections := []
		ObjRegisterActive(this, CLSID)
		RegWrite,REG_SZ,HKCU,Software\Classes\Columbus,,Columbus
		RegWrite,REG_SZ,HKCU,Software\Classes\Columbus\CLSID,,%CLSID%
		RegWrite,REG_SZ,HKCU,Software\Classes\CLSID\%CLSID%,,Columbus
		for a, b in xml.get("//plugins/plugin")
			if !FileExist(A_WorkingDir "\Plugins\" b.name ".ahk") ; delete plugins if they've been removed
				xml.Delete(b.node)
		this.version := version
		this.path := A_ScriptFullPath
		this.directory := A_ProgramFiles "\Columbus"
		this.hwnd := A_ScriptHwnd
	}
	
	; call the msgbox function
	m(x*) {
		m(x*)
	}
	
	; connect a plugin
	Connect(hwnd, obj) {
		this.Connections[hwnd] := obj
	}
	
	; disconnect a plugin
	Disconnect(hwnd) {
		this.Connections.Remove(hwnd)
	}
	
	; create a new list, return the list object if the list already exists
	CreateList(name) {
		if ItemList.Lists[name]
			return ItemList.Lists[name]
		else
			return ItemList.Lists[name] := New ItemList(name)
	}
	
	DeleteList(name) {
		ItemList.Lists[name] := ""
		xml.delete("//lists/" name)
	}
	
	; set a new list to the listview
	SetList(list) {
		Settings.List := list
	}
	
	; call ANY function. be careful with this
	call(func, param*) {
		return %func%(param*)
	}
	
	; set a key/value pair
	set(key, value) {
		Settings[key] := value
	}
	
	; call a command
	cmd(cmd, param*) {
		return Command[cmd](param*)
	}
	
	; call any listview function
	lv(func, param*) {
		Main.SetDefault()
		Func("LV_" func).Call(param*)
	}
	
	; call the run function
	run(file) {
		Run(file)
	}
	
	; set input
	Input(text := "") {
		Main.SetText(text)
		ControlSend, Edit1, {End}, % Main.ahkid
	}
	
	; append input
	AppendInput(text) {
		Main.SetText(Main.GetText() . text)
		ControlSend, Edit1, {End}, % Main.ahkid
	}
	
	; get input typed into the edit field in the main window
	GetInput() {
		return Main.GetText()
	}
	
	; get text from a row in the current listview
	GetText(row := "") {
		Main.SetDefault()
		LV_GetText(text, (row ? row : LV_GetNext()))
		return text
	}
	
	; select a new row, if stay is false, the last row enabled will not be disabled
	Select(i, stay := false) {
		Main.SetDefault()
		if !stay
			LV_Modify(LV_GetNext(), "-Select")
		LV_Modify(i, "Select Vis")
	}
	
	; submit, ie an "Enter" click
	Submit() {
		Submit()
	}
	
	; get a global variable
	get(name) {
		return _:=%name%
	}
	
	; reload the script
	reload() {
		reload
	}
	
	; select node from the xml file
	sn(node, path) {
		node.SelectNodes(path)
	}
	
	; select single node from the xml file
	ssn(node, path) {
		return node.SelectSingleNode(path)
	}
	
	
	
	; =========== methods below this comment should not be called by a plugin script!! they are used by columbus to manage connected plugins! ===========
	
	Event(event, param*) {
		for a, b in this.Connections {
			try {
				if b[Event](param*)
					x:=true
			} catch e ; if an error occured we remove the plugin from the list
				this.Connections.Remove(a)
		} return x
	}
	
	Exit() {
		for a in this.Connections
			PostMessage, 0x10,,,, % "ahk_id" a ; WM_CLOSE=0x10
		this.Connections := []
	}
}