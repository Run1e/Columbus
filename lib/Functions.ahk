WM_LBUTTONDOWN() {
	WinGet, style, Style
	if (Style & 0x40000) && (A_Gui = Main.hwnd+0)
		PostMessage, 0xA1, 2
}

FileExt(file) {
	SplitPath, file,,, ext
	return ext
}

ColorPicker(col := ""){
	col := SubStr(col, 5, 2) . SubStr(col, 3, 2) . SubStr(col, 1, 2)
	col := Format("0x{:x}", (InStr(col, "0x") ? col : "0x" col))
	VarSetCapacity(CUSTOM,16*A_PtrSize,0)
	size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
	NumPut(size,CHOOSECOLOR,0,"UInt")
	NumPut(col,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt")
	NumPut(&CUSTOM,CHOOSECOLOR,4*A_PtrSize,"UPtr")
	ret:=DllCall("comdlg32\ChooseColor","UPtr",&CHOOSECOLOR,"UInt")
	if !ret.length
		return
	c:=NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt")
	return Format("{:06x}", (c<<16&0xFF0000 | c&0xFF00 | c>>16&0xFF)).toUpper
}

print(text) {
	if text.find(".") {
		obj := text.split(".")[1]
		return %obj%[text.split(".")[2]]
	} else
		return _:=%text%
}

ApplyGradient(Hwnd, RB := "101010", LT := "0000AA", Vertical := 1)
{
	ControlGetPos,,, W, H,, ahk_id %Hwnd%
	PixelData := Vertical ? LT "|" LT "|" RB "|" RB : RB "|" RB "|" LT "|" LT
	hBitmap := CreateDIB(PixelData, 2, 2, W, H, True)
	oBitmap := DllCall("User32.dll\SendMessage", "Ptr", Hwnd, "UInt", 0x172, "Ptr", 0, "Ptr", hBitmap)
	return hBitmap, DllCall("Gdi32.dll\DeleteObject", "Ptr", oBitmap)
}

; by SKAN - http://ahkscript.org/boards/viewtopic.php?t=3203
CreateDIB(PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1) {
	WB := Ceil((W * 3) / 2) * 2, VarSetCapacity(BMBITS, WB * H + 1, 0), P := &BMBITS
	loop, Parse, PixelData, |
		P := Numput("0x" A_LoopField, P + 0, 0, "UInt") - (W & 1 && Mod(A_Index * 3, W * 3) = 0 ? 0 : 1)
	hBM := DllCall("Gdi32.dll\CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")    
	hBM := DllCall("User32.dll\CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
	DllCall("Gdi32.dll\SetBitmapBits", "Ptr", hBM, "UInt", WB * H, "Ptr", &BMBITS)
	if !(Gradient + 0)
		hBM := DllCall("User32.dll\CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x0008, "Ptr")
	return DllCall("User32.dll\CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "Int", 0x200C, "UPtr")
}

RandomString(length, special := false) {
	Loop % length
		str .= (r := Random(1, special ? 4 : 3)) = 1
				? Random(0, 9) : r = 2
				? Chr(Random(65, 90)) : r = 3
				? Chr(Random(97, 122)) : SubStr("-_?!&:", r := Random(1, 6), 1)
	return % str
}

Run(file, args := "") {
	SplitPath, file,, dir
	if !RegExMatch(dir, "\w:/")
		dir := ""
	run % file (args ? " " args : ""), % (dir.length ? dir : ""), UseErrorLevel
	if ErrorLevel
		return m("Failed to run:`n`nfile: " file "`nargs: " args "`ndir: " dir)
	return
}

Random(min, max) {
	Random, out, % min, % max
	return out
}

RegRead(root, sub, value) {
	RegRead, output, % root, % sub, % value
	return output
}

Send(URL, POST := "", TIMEOUT_SECONDS := 5, PROXY := "") {
	static HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	HTTP.Open("POST", URL, true)
	HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	RegRead ProxyEnable, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable
	if (ProxyEnable || PROXY) {
		RegRead ProxyServer, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer
		HTTP.SetProxy(2, (PROXY ? PROXY : ProxyServer))
	} if IsObject(POST) {
		for a, b in POST
			POST .= (A_Index > 1 ? "&" : "") a "=" b
	} HTTP.Send(POST)
	try {
		if HTTP.WaitForResponse(TIMEOUT_SECONDS)
			return HTTP.ResponseText
	} catch e
		return
	return
}

UriEncode(Uri) { ; thanks to GeekDude for providing this function!
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0)
	StrPut(Uri, &Var, "UTF-8")
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	while Code := NumGet(Var, A_Index - 1, "UChar")
		if (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
	else
		Res .= "%" . SubStr(Code + 0x100, -1)
	SetFormat, IntegerFast, %f%
	return, Res
}

pa(array, depth=5, indentLevel:="   ") {
	for k,v in Array {
		list.= indentLevel "[" k "]"
		if (IsObject(v) && depth>1)
			list.="`n" pa(v, depth-1, indentLevel . "    ")
		else
			list.=" => " v
		list.="`n"
	} return rtrim(list, "`r`n `t")
}

p(text := "") {
	Plugin.Event("Print", text)
	/*
		if !handle && Settings.Debug
			Handle := DllCall("GetStdHandle", "UInt", (-11,DllCall("AllocConsole")), "UPtr"), DllCall("SetConsoleTextAttribute", "UPtr", Handle, "UShort", 15|0<<4)
		if text
			return FileOpen("CONOUT$", "w").Write(text . "`n")
	*/
	
}

gk(x) {
	for a, b in x {
		if IsObject(b) {
			for c, v in b
				temp .= c ": " ((v+0) ? v : """" v """") ", "
		} else
			temp.= ((b+0).length ? b : """" b """") ", "
	} temp := trim(temp, ", ")
	return IsObject(b) ? "{" temp "}" : temp
}

bound(i, min, max) {
	return (i>max?max:i<min?min:i)
}

m(x*){
	for a,b in x
		list.=b "`n"
	MsgBox,0,Columbus, % list
}

t(text:="") {
	ToolTip % text
} 

ObjRegisterActive(Object, CLSID, Flags:=0) {
	static cookieJar := {}
	if (!CLSID) {
		if (cookie := cookieJar.Remove(Object)) != ""
			DllCall("oleaut32\RevokeActiveObject", "uint", cookie, "ptr", 0)
		return
	} if cookieJar[Object]
		throw Exception("Object is already registered", -1)
	VarSetCapacity(_clsid, 16, 0)
	if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", &_clsid)) < 0
		throw Exception("Invalid CLSID", -1, CLSID)
	hr := DllCall("oleaut32\RegisterActiveObject"
	, "ptr", &Object, "ptr", &_clsid, "uint", Flags, "uint*", cookie
	, "uint")
	if hr < 0
		throw Exception(format("Error 0x{:x}", hr), -1)
	cookieJar[Object] := cookie
}