ObjRegisterActive(Object, CLSID, Flags:=0) {
	static cookieJar := {}
	if (!CLSID) {
		if (cookie := cookieJar.Remove(Object)) != ""
			DllCall("oleaut32\RevokeActiveObject", "uint", cookie, "ptr", 0)
		return
	}
	if cookieJar[Object]
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
	if CLSID {
		RegWrite,REG_SZ,HKCU,Software\Classes\Columbus,,Columbus
		RegWrite,REG_SZ,HKCU,Software\Classes\Columbus\CLSID,,%CLSID%
		RegWrite,REG_SZ,HKCU,Software\Classes\CLSID\%CLSID%,,Columbus
	}
}