Class ItemList {
	static Lists := []
	
	__New(name) {
		this.name := name
		if !xml.ssn("//lists/" name)
			xml.add("lists/" name)
		this.Refresh()
		ItemList.Lists[name] := this
	}
	
	; add a new item, it will be placed randomly in the list
	Add(item, run := "", icon := "", hide := false) {
		if run.length
			temp := item, item := {name:temp, run:run, icon:icon, freq:0, hide:hide}
		if !xml.ssn("//lists/" this.name "/item[@name='" item.name "']") {
			if (item.run = item.icon)
				item.Remove("icon")
			if (item.hide = 0)
				item.Remove("hide")
			return xml.move(xml.add("lists/" this.name "/item", item,, true), xml.sn("//lists/" this.name "/item").item[Random(1, xml.sn("//lists/" this.name "/item").length)])
		}
	}
	
	; iterates the freq value in a section
	AddFreq(item) {
		node := xml.ssn("//lists/" this.name "/item[@name='" item "']")
		node.SetAttribute("freq", tot := (((t := xml.ea(node).freq) ? t : 0) + 1))
		this.Freq[item] := tot
	}
	
	; show item
	Show(item) {
		xml.ssn("//lists/" this.name "/item[@name='" item "']").SetAttribute("hide", false)
	}
	
	; hide item
	Hide(item) {
		xml.ssn("//lists/" this.name "/item[@name='" item "']").SetAttribute("hide", true)
	}
	
	; refresh the list
	Refresh() {
		Main.SetDefault()
		this.Icon := [], this.List := [], this.History := []
		IL_Destroy(this.ImageList)
		this.ImageList := IL_Create(15,, Settings.LargeIcons)
		if (Settings.List = this.name)
			LV_SetImageList(this.ImageList, 1)
		IL_Add(this.ImageList, "shell32.dll", 132) ; "No results" icon
		for a, b in xml.get("//lists/" this.name "/item")
			if !b.hide { ; yes, I'm using three arrays to store the item information. ahk is borderline stupid and always sorts array indexes alphabetically.
				this.List.Insert(b.name)
				this.Icon[b.name] := IL_Add(this.ImageList, b.icon ? b.icon : b.run)
				this.Freq[b.name] := b.freq
			}
	}
}