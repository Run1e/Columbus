SetCueBanner(HWND, STRING) { ; thaaanks tidbit
	static EM_SETCUEBANNER := 0x1501
	if (A_IsUnicode) ; thanks just_me! http://www.autohotkey.com/community/viewtopic.php?t=81973
		return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", false, "WStr", STRING)
	else {
		if !(HWND + 0) {
			GuiControlGet, CHWND, HWND, %HWND%
			HWND := CHWND
		} VarSetCapacity(WSTRING, (StrLen(STRING) * 2) + 1)
		DllCall("MultiByteToWideChar", UInt, 0, UInt, 0, UInt, &STRING, Int, -1, UInt, &WSTRING, Int, StrLen(STRING) + 1)
		DllCall("SendMessageW", "UInt", HWND, "UInt", EM_SETCUEBANNER, "UInt", SHOWALWAYS, "UInt", &WSTRING)
		return
	}
}