#SingleInstance force
OnExit, Disconnect

x:=ComObjActive("Columbus") ; connect to Columbus
x.Connect(A_ScriptHwnd, Event) ; make the plugin close when Columbus closes and make the Event class listen to events

; get objects - note some of these methods might not be the best idea to call without knowledge how to use them
Gui := x.Get("Gui") ; Show(), Hide(), Toggle(), GetText(), SetText(), Move()

Settings := x.Get("Settings") ; get setting: Settings.RowSnap | set setting: Settings.RowSnap := true

xml := x.Get("xml") ; primarily used for writing lists, check the xmlfile object in the source

Commands := x.Get("Commands") ; Manager(), Settings(), Update(), Exit()

Hotkey := x.Get("Hotkey") ; Bind(), Rebind(), Disable(), Enable()

Items := x.Get("Items") ; Add(), scan(), Search()

Tray := x.Get("Tray") ; Tip(), Destroy(), SetTimeout(), SetFade()

; display object information
msgbox % Hotkey[]
msgbox % Settings[]
msgbox % xml[]

return

Class Event {
	
	OnInput(input, done) { ; something is typed
		
	}
	
	OnSelect(num) { ; user selected an item in the listview
		
	}	
	
	OnSubmit(input, text, done) { ; user submitted an item
		
	}
	
	OnDropFiles(files, done) { ; user dropped file(s) - seperated by newlines
		
	}
	
	OnResize(done) { ; user is resizing
		
	}
	
	OnHotkey(key, done) { ; user pressed a hotkey
		
	}
	
	Print(text) { ; text printed to console
		
	}
	
}

Disconnect:
ComObjError(false) ; set to false so a popup won't appear if Columbus is already closed.
x.Disconnect(A_ScriptHwnd) ; disconnect from Columbus
ExitApp

label:
return