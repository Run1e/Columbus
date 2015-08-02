EditAction(GuiEvent := "", EventInfo := "") {
	
	Main.SetDefault()
	
	input := Main.GetText()
	
	if Plugin.Event("OnInput", false, input)
		return
	
	if !input.startsWith(Settings.Prefix) { ; input is not a command, fuzzy search the program list
		FuzzyWrap(input, ItemList.Lists[Settings.List].List)
	} else { ; input starts with the prefix
		LV_GetText(top, 1)
		if (input = Settings.Prefix) {
			LV_Delete()
			LV_Add("Icon0", "Commands:")
			LV_Add("Icon0", "")
			for a, b in Commands.List
				LV_Add("Icon0", b)
		} else if input.contains(Settings.Prefix "g", Settings.Prefix "w") {
			if !top.contains("Wolfram", "Google") {
				LV_Delete()
				LV_Add("Icon0", (input.startsWith(Settings.Prefix "w") ? "Wolfram" : "Google") . " search:")
				SendInput % A_Space
			} LV_Delete(3)
			LV_Add("Icon0", trim(SubStr(input, 3)))
			return
		}
		
		Main.SizeCol()
		Loop % LV_GetCount()
			LV_Modify(A_Index, "-Select")
		if (input.length > 1) {
			Loop % LV_GetCount() - 2 {
				LV_Modify(A_Index + 2, "-Select")
				LV_GetText(text, A_Index + 2)
				if (text.startsWith(input.split(Settings.Prefix)[2])) {
					LV_Modify(A_Index + 2, "Select")
					break
				}
			}
		}
	}
	
	Plugin.Event("OnInput", true, input)
	
}

EditAction:
EditAction(A_GuiEvent, A_EventInfo)
return

; https://steamcommunity.com/tradeoffer/new/?partner=230429861&token=WngV3KAf