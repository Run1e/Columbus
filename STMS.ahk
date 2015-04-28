STMS() { ; System Time in MS / STMS() returns milliseconds elapsed since 16010101000000 UT
	static GetSystemTimeAsFileTime, T1601                              ; By SKAN / 21-Apr-2014
	if !GetSystemTimeAsFileTime
		GetSystemTimeAsFileTime := DllCall("GetProcAddress", UInt, DllCall("GetModuleHandle", Str,"Kernel32.dll"), A_IsUnicode ? "AStr" : "Str","GetSystemTimeAsFileTime")
	DllCall(GetSystemTimeAsFileTime, Int64P, T1601)
	return T1601 // 10000
} ; http://ahkscript.org/boards/viewtopic.php?p=17076#p17076