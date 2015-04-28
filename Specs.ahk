Specs() {
	Gui 1: +Disabled
	Tray.timeout := 99
	Tray.Tip("Working..")
	comp:=sys:=net:=[]
	sys["graphics"] := []
	sys["network"] := []
	RunWait,%comspec% /c systeminfo > %A_Temp%\sysinfo.txt,,hide
	FileRead, systeminfo, %A_Temp%\sysinfo.txt
	FileDelete %A_Temp%\sysinfo.txt
	Loop 8 {
		RegRead temp, HKEY_LOCAL_MACHINE, HARDWARE\DEVICEMAP\VIDEO, \Device\Video%A_Index%
		if (SubStr(temp, -3) & 1)
			continue
		RegRead, card, HKEY_LOCAL_MACHINE, % SubStr(temp, 19), Device Description
		RegRead, memory, HKEY_LOCAL_MACHINE, % SubStr(temp, 19), HardwareInformation.MemorySize
		if memory
			sys["graphics"].Insert(card (memory ? " (" Floor(memory / 1000000) - 100 " MB)" : ""))
	} parsenet := SubStr(systeminfo, InStr(systeminfo, "Network card(s):"))
	Loop, parse, parsenet, % "`n", % "`r"
	{
		if RegExMatch(A_LoopField, "\[\d\d\]") {
			if !indent
				indent := InStr(A_LoopField, "[")
			if (InStr(A_LoopField, "[") = indent)
				sys["network"].Insert(SubStr(trim(A_LoopField), 7))
		}
	}
	comp["owner"] := RegRead("HKEY_LOCAL_MACHINE", "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "RegisteredOwner")
	comp["system"] := RegRead("HKEY_LOCAL_MACHINE", "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName") " (" (A_Is64BitOS = true ? "64-bit" : "32-bit") ")"
	comp["lang"] := LangCode(A_Language) " (" A_Language ")"
	comp["compname"] := A_ComputerName
	comp["admin"] := A_IsAdmin ? "Yes" : "No"
	sys["cpu"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString")
	sys["mobo"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\BIOS", "BaseBoardProduct")
	sys["RAM"] := RegExReplace(SubStr(systeminfo, pos := InStr(systeminfo, "Physical") + 20, InStr(SubStr(systeminfo, pos), "MB") + 2), Chr(255), "")
	sys["bios"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\BIOS", "BaseBoardManufacturer")
	sys["bios_vendor"] := RegRead("HKEY_LOCAL_MACHINE", "HARDWARE\DESCRIPTION\System\BIOS", "BIOSVendor")
	net["connected_state"] := DllCall("wininet\InternetGetConnectedState", "Uint", 0)
	net["ext_ip"] := Send("http://runie.me/ip.php")
	net["connected"] := (InStr(net["ext_ip"], "DOCTYPE") || !net["ext_ip"] ? "No" : "Yes")
	net["int_ip"] := A_IPAddress1
	net["proxy_enabled"] := (RegRead("HKEY_CURRENT_USER", "Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable") ? "Yes" : "No")
	net["proxy_server"] := ProxyServer := RegRead("HKEY_CURRENT_USER", "Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer") ? ProxyServer : "None"
	
	for a, b in sys["graphics"]
		grphcs .= A_Space A_Space A_Space a ". " b "`n"
	for a, b in sys["network"]
		ntwrk .= A_Space A_Space A_Space a ". " b "`n"
	
	s .=  "--- Computer ---`n"
	. "Registered: " comp["owner"] "`n"
	. "System: " comp["system"] "`n"
	. "Language: " comp["lang"] "`n"
	. "Computer Name: " comp["compname"] "`n"
	. "Administrator: " comp["admin"] "`n"
	. "`n"
	. "--- System ---`n"
	. "CPU: " sys["cpu"] "`n"
	. "Motherboard: " sys["mobo"] "`n"
	. "RAM: " sys["RAM"] "`n"
	. "BIOS: " sys["bios"] "`n"
	. "BIOS Vendor: " sys["bios_vendor"] "`n"
	. "Graphics:`n"
	. grphcs
	. "Network card(s):`n"
	. ntwrk
	. "`n"
	. "--- Internet ---`n"
	. "Connected: " net["connected"] "`n"
	. "Connected state: " net["connected_state"] "`n"
	. "External IP: " net["ext_ip"] "`n"
	. "Internal IP: " net["int_ip"] "`n"
	. "Proxy Enabled: " net["proxy_enabled"] "`n"
	. "Proxy IP: " net["proxy_server"] "`n"
	Print("`n" s)
	Tray.Destroy()
	msgbox,, System Information %A_ComputerName%, % s
	Gui 1: -Disabled
}