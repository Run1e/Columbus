Submit() {  ;#[what if result is "No results!"?????]
	Main.SetDefault()
	
	input := Main.GetText()
	LV_GetText(text, LV_GetNext())
	
	if Plugin.Event("OnSubmit", false, text, input)
		return
	
	if !input.startsWith(Settings.Prefix) {
		Main.Hide(true)
		if text {
			;Run(xml.ea(xml.ssn("//lists/" Settings.List "/item[@name='" text "']")).run)
			ItemList.Lists[Settings.List].AddFreq(text)
		}
	} else {
		param := input.split(" ")
		cmd := SubStr(param[1], 2)
		param.Remove(1)
		if (i := LV_GetNext()) && !IsFunc(Commands[cmd] && InStr(input, " "))
			LV_GetText(cmd, i), cmd := cmd.split(" - ")[1]
		Main.SetText()
		Commands[cmd](param*)
		; Plugin.Event("OnCommand", cmd, param*)
	}
	
	Plugin.Event("OnSubmit", true, text, input)
}