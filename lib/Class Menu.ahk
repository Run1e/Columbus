Class Menu {
	__New(name) {
		this.Items := []
		this.name := name
	}
	
	Add(text := "") {
		if IsObject(text)
			Menu, % this.name, Add, % text.name, % ":" text.name
		else
			Menu, % this.name, Add, % text, MenuHandler
		this.Items.Insert(IsObject(text.Items) ? (a:=text.Items,a.name:=text.name) : text)
	}
	
	Delete(item) {
		Menu, % this.name, Delete, % item
		for a, b in this.Items {
			if (b = item)
				this.Items.Remove(a)
			else if IsObject(b)
				if (b.name = item)
					this.Items.Remove(a)
		}
	}
	
	Insert(pos, text := "") {
		temp := []
		Loop % pos - 1
			temp.Insert(this.Items[A_Index])
		temp.Insert(IsObject(text.Items) ? (a:=text.Items,a.name:=text.name) : text)
		Loop % this.Items.MaxIndex() - pos + 1
			temp[A_Index + pos] := this.Items[A_Index - 1 + pos]
		this.Update(temp)
	}
	
	Update(arr) {
		this.Clear(), this.Items := []
		for a, b in arr {
			if IsObject(b) {
				x := New Menu(b.name)
				for c, v in b
					if (c != "name")
						x.Add(v)
				this.Add(x), x:=""
			} else
				this.Add(b)
		} if this.default.length
			Menu, % this.name, Default, % this.default
	}
	
	Clear() {
		Menu, % this.name, DeleteAll
		Menu, % this.name, NoDefault
		Menu, % this.name, NoStandard
	}
	
	NoDefault() {
		Menu, % this.name, NoDefault
	}
	
	NoStandard() {
		Menu, % this.name, NoStandard
	}
	
	SetDefault(item) {
		this.default := item
		Menu, % this.name, Default, % item
	}
}