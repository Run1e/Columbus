AddToolTip(CtrlHwnd,text,Modify=0) {
	static TThwnd, GuiHwnd, Ptr
	if (!TThwnd) {
		Gui,+LastFound
		GuiHwnd:=WinExist()
		TThwnd:=DllCall("CreateWindowEx","Uint",0,"Str","TOOLTIPS_CLASS32","Uint",0,"Uint",2147483648 | 3,"Uint",-2147483648
	,"Uint",-2147483648,"Uint",-2147483648,"Uint",-2147483648,"Uint",GuiHwnd,"Uint",0,"Uint",0,"Uint",0)
		Ptr:=(A_PtrSize ? "Ptr" : "UInt"), DllCall("uxtheme\SetWindowTheme","Uint",TThwnd,Ptr,0,"UintP",0)
	} Varsetcapacity(TInfo,44,0), Numput(44,TInfo), Numput(1|16,TInfo,4), Numput(GuiHwnd,TInfo,8), Numput(CtrlHwnd,TInfo,12), Numput(&text,TInfo,36)
	!Modify   ? (DllCall("SendMessage",Ptr,TThwnd,"Uint",1028,Ptr,0,Ptr,&TInfo,Ptr))
. (DllCall("SendMessage",Ptr,TThwnd,"Uint",1048,Ptr,0,Ptr,A_ScreenWidth))
	DllCall("SendMessage",Ptr,TThwnd,"UInt",(A_IsUnicode ? 0x439 : 0x40c),Ptr,0,Ptr,&TInfo,Ptr)
}