; created by 'just me' -> http://ahkscript.org/boards/viewtopic.php?t=2197
Class CtlColors {
	Static Attached := {}
	Static HandledMessages := {Edit: 0, ListBox: 0, Static: 0}
	Static MessageHandler := "CtlColors_OnMessage"
	Static WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
	Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
	, LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
	, SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
	Static SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
	Static ErrorMsg := ""
	Static InitClass := CtlColors.ClassInit()
	__New() { ; You must not instantiate this class!
		If (This.InitClass == "!DONE!") { ; external call after class initialization
			This["!Access_Denied!"] := True
			Return False
		}
	}
	
	__Delete() {
		If This["!Access_Denied!"]
			Return
		This.Free() ; free GDI resources
	}
	
	ClassInit() {
		CtlColors := New CtlColors
		Return "!DONE!"
	}
	
	CheckBkColor(ByRef BkColor, Class) {
		This.ErrorMsg := ""
		If (BkColor != "") && !This.HTML.HasKey(BkColor) && !RegExMatch(BkColor, "^[[:xdigit:]]{6}$") {
			This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
			Return False
		}
		BkColor := BkColor = "" ? This.SYSCOLORS[Class]
		:  This.HTML.HasKey(BkColor) ? This.HTML[BkColor]
		:  "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
		Return True
	}
	
	CheckTxColor(ByRef TxColor) {
		This.ErrorMsg := ""
		If (TxColor != "") && !This.HTML.HasKey(TxColor) && !RegExMatch(TxColor, "i)^[[:xdigit:]]{6}$") {
			This.ErrorMsg := "Invalid parameter TextColor: " . TxColor
			Return False
		}
		TxColor := TxColor = "" ? ""
		:  This.HTML.HasKey(TxColor) ? This.HTML[TxColor]
		:  "0x" . SubStr(TxColor, 5, 2) . SubStr(TxColor, 3, 2) . SubStr(TxColor, 1, 2)
		Return True
	}
	
	Attach(HWND, BkColor, TxColor := "") {
		Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
		Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x8
		Static ES_READONLY := 0x800
		Static COLOR_3DFACE := 15, COLOR_WINDOW := 5
		If (This.SYSCOLORS.Edit = "") {
			This.SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "UInt")
			This.SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "UInt")
			This.SYSCOLORS.ListBox := This.SYSCOLORS.Edit
		}
		This.ErrorMsg := ""
		; Check colors ---------------------------------------------------------------------------------------------------
		If (BkColor = "") && (TxColor = "") {
			This.ErrorMsg := "Both parameters BkColor and TxColor are empty!"
			Return False
		}
		; Check HWND -----------------------------------------------------------------------------------------------------
		If !(CtrlHwnd := HWND + 0) || !DllCall("User32.dll\IsWindow", "UPtr", HWND, "UInt") {
			This.ErrorMsg := "Invalid parameter HWND: " . HWND
			Return False
		}
		If This.Attached.HasKey(HWND) {
			This.ErrorMsg := "Control " . HWND . " is already registered!"
			Return False
		}
		Hwnds := [CtrlHwnd]
		; Check control's class ------------------------------------------------------------------------------------------
		Classes := ""
		WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
		This.ErrorMsg := "Unsupported control class: " . CtrlClass
		If !ClassNames.HasKey(CtrlClass)
			Return False
		ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%
		If (CtrlClass = "Edit")
			Classes := ["Edit", "Static"]
		Else If (CtrlClass = "Button") {
			IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
				Classes := ["Static"]
			Else
				Return False
		}
		Else If (CtrlClass = "ComboBox") {
			VarSetCapacity(CBBI, 40 + (A_PtrSize * 3), 0)
			NumPut(40 + (A_PtrSize * 3), CBBI, 0, "UInt")
			DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
			Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize * 2, "UPtr")) + 0)
			Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize, "UPtr") + 0)
			Classes := ["Edit", "Static", "ListBox"]
		}
		If !IsObject(Classes)
			Classes := [CtrlClass]
		; Check background color -----------------------------------------------------------------------------------------
		If !This.CheckBkColor(BkColor, Classes[1])
			Return False
		; Check text color -----------------------------------------------------------------------------------------------
		If !This.CheckTxColor(TxColor)
			Return False
		; Activate message handling on the first call for a class --------------------------------------------------------
		For I, V In Classes {
			If (This.HandledMessages[V] = 0)
				OnMessage(This.WM_CTLCOLOR[V], This.MessageHandler)
			This.HandledMessages[V] += 1
		}
		; Store values for HWND ------------------------------------------------------------------------------------------
		Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
		For I, V In Hwnds
			This.Attached[V] := {Brush: Brush, TxColor: TxColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}
		; Redraw control -------------------------------------------------------------------------------------------------
		DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
		This.ErrorMsg := ""
		Return True
	}
	
	Change(HWND, BkColor, TxColor := "") {
		; Check HWND -----------------------------------------------------------------------------------------------------
		This.ErrorMsg := ""
		HWND += 0
		If !This.Attached.HasKey(HWND)
			Return This.Attach(HWND, BkColor, TxColor)
		CTL := This.Attached[HWND]
		; Check BkColor --------------------------------------------------------------------------------------------------
		If !This.CheckBkColor(BkColor, CTL.Classes[1])
			Return False
		; Check TxColor ------------------------------------------------------------------------------------------------
		If !This.CheckTxColor(TxColor)
			Return False
		; Store Colors ---------------------------------------------------------------------------------------------------
		If (BkColor <> CTL.BkColor) {
			If (CTL.Brush) {
				DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
				This.Attached[HWND].Brush := 0
			}
			Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
			This.Attached[HWND].Brush := Brush
			This.Attached[HWND].BkColor := BkColor
		}
		This.Attached[HWND].TxColor := TxColor
		This.ErrorMsg := ""
		DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
		Return True
	}
	
	Detach(HWND) {
		This.ErrorMsg := ""
		HWND += 0
		If This.Attached.HasKey(HWND) {
			CTL := This.Attached[HWND].Clone()
			If (CTL.Brush)
				DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
			For I, V In CTL.Classes {
				If This.HandledMessages[V] > 0 {
					This.HandledMessages[V] -= 1
					If This.HandledMessages[V] = 0
						OnMessage(This.WM_CTLCOLOR[V], "")
			}  }
			For I, V In CTL.Hwnds
				This.Attached.Remove(V, "")
			DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
			CTL := ""
			Return True
		}
		This.ErrorMsg := "Control " . HWND . " is not registered!"
		Return False
	}
	
	Free() {
		For K, V In This.Attached
			DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
		For K, V In This.HandledMessages
			If (V > 0) {
				OnMessage(This.WM_CTLCOLOR[K], "")
				This.HandledMessages[K] := 0
			}
		This.Attached := {}
		Return True
	}
	
	IsAttached(HWND) {
		Return This.Attached.HasKey(HWND)
	}
}

CtlColors_OnMessage(HDC, HWND) {
	Critical
	If CtlColors.IsAttached(HWND) {
		CTL := CtlColors.Attached[HWND]
		If (CTL.TxColor != "")
			DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CTL.TxColor)
		DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "UInt", CTL.BkColor)
		Return CTL.Brush
	}
}