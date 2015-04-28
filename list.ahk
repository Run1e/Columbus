list(refresh := false, remove := "") {
	static list
	if remove {
		tmp := list, list := []
		for a, b in tmp
			if (b.name <> remove) {
			i++
			list[i, "name"] := b.name
			list[i, "icon"] := b.icon
			list[i, "freq"] := b.freq
			list[i, "priv"] := b.priv
		}
		return list
	} if !refresh
		return list
	Gui, +hwndhwnd
	Gui 1: Default
	IL_Destroy(ImageList)
	list := []
	LV_SetImageList(ImageList := IL_Create(LV_GetCount()))
	tmp := IniRead("items")
	if Settings.SortByPopularity {
		Loop, parse, tmp, % "`n", % "`r"
			items .= IniRead("items", A_LoopField, "freq") " " A_LoopField "`n"
		Sort, items, NR
		items := SubStr(items, 1, -1)
	} else
		items := tmp
	Loop, parse, items, % "`n", % "`r"se
	{
		i++
		tmp := (Settings.SortByPopularity ? SubStr(A_LoopField, InStr(A_LoopField, " ") + 1) : A_LoopField)
		list[i, "name"] := br(tmp)
		if ((icon := IL_Add(ImageList, IniRead("items", tmp, "icon"))) = 0)
			icon := IL_Add(ImageList, IniRead("items", tmp, "dir"))
		list[i, "icon"] := icon
		list[i, "freq"] := IniRead("items", tmp, "freq")
		list[i, "priv"] := IniRead("items", tmp, "priv")
	} Menu, Tray, Tip, Columbus v%AppVersion%`nTotal items: %i% ; update the traytip information
	Gui %hwnd%: Default
	return list
}