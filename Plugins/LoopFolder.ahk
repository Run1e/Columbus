#SingleInstance force
#NoEnv

x := ComObjActive("Columbus")
xml := x.get("xml")
items := x.get("Items") ; class that extends from the ItemList class, it contains the main program list, we want to use the add() function

FileSelectFolder, folder, C:\

if !folder
	ExitApp

list := [] ; create array to keep the found items

Loop, Files, % folder "\*.exe", R
	list[SubStr(A_LoopFileName, 1, -4)] := A_LoopFileFullPath


Gui Add, Text,, Slowly double-click on a row to edit it (or press F2)
Gui Add, ListView, Checked w650 h800 -ReadOnly, Name|Path
Gui Add, Button, gSubmit, Add selected

for a, b in list
	if !xml.ssn("//lists/items/item[@run='" b "' or @name = '" a "']") ; make sure the executable doesn't already exist in the items list
		LV_Add("Check0", a, b)
LV_ModifyCol(1, 200)
Gui Show

return

Submit:
i:=0
while (i := LV_GetNext(i, "C")) { ; parse through the selected items
	LV_GetText(name, i, 1)
	LV_GetText(path, i, 2)
	items.Add(name, path, path, true) ; add a new item
	added .= name "`n"
} items.Refresh()
msgbox % "Items added:`n`n" trim(added)
ExitApp
