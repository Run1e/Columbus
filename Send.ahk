Send(URL, POST_DATA := "", TIMEOUT_SECONDS := 5, PROXY := "") {
	static HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Print("Send(): " URL)
	HTTP.Open("POST", URL, true)
	HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	RegRead ProxyEnable, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable
	if (ProxyEnable||PROXY) {
		RegRead ProxyServer, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer
		HTTP.SetProxy(2, (PROXY ? PROXY : ProxyServer))
	} if IsObject(POST_DATA) {
		for a, b in POST_DATA
			POST .= (A_Index>1?"&":"") a "=" b
	} HTTP.Send((POST?POST:POST_DATA))
	if HTTP.WaitForResponse(TIMEOUT_SECONDS)
		return HTTP.ResponseText
	return
}